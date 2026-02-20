#!/usr/bin/env sh

backend_log_failure() {
	_backend="$1"
	_code="$2"
	_message="$3"
	_log="${session_temp_dir:-${YTFZF_TEMP_DIR}}/backend-failures.log"
	printf "%s\t%s\t%s\t%s\n" "$(date +%FT%T%z)" "$_backend" "$_code" "$_message" >>"$_log"
}

normalize_backend_name() {
	case "$1" in
	invidious | youtube-html | yt-dlp) printf "%s\n" "$1" ;;
	yt_html) printf "%s\n" "youtube-html" ;;
	ytdlp) printf "%s\n" "yt-dlp" ;;
	*) printf "%s\n" "" ;;
	esac
}

scrape_ytdlp_search() {
	page_query=$1
	output_json_file=$2
	[ "$page_query" = ":help" ] && print_info "Search youtube through yt-dlp metadata fallback" && return 100
	command_exists "${ytdl_path}" || return 127
	_count=$((20 * ${pages_to_scrape:-1}))
	[ "$_count" -le 0 ] && _count=20
	[ "$_count" -gt 200 ] && _count=200
	_tmp_json="${session_temp_dir}/yt-dlp-search.json"
	"${ytdl_path}" --dump-single-json --flat-playlist "ytsearch${_count}:${page_query}" >"$_tmp_json" || return "$?"
	jq '
	def pad_left(n; num):
		num | tostring | if (n > length) then ((n - length) * "0") + (.) else . end;
	[ (.entries // [])[] |
		{
			scraper: "yt_dlp_search",
			ID: (.id // ""),
			url: "'"${yt_video_link_domain}"'/watch?v=\(.id // "")",
			title: (.title // ""),
			channel: (.channel // .uploader // ""),
			thumbs: (.thumbnail // ""),
			duration: (
				if (.duration | type) == "number"
				then "\(.duration / 60 | floor):\(pad_left(2; .duration % 60))"
				else (.duration_string // "")
				end
			),
			views: (
				if (.view_count | type) == "number" then "\(.view_count)" else "" end
			),
			date: (.upload_date // ""),
			description: (.description // "")
		}
	]' <"$_tmp_json" >>"$output_json_file"
}

scrape_youtube_with_backends() {
	_page_query="$1"
	_output_json_file="$2"
	_b3="$3"
	_b4="$4"
	_last_status=1

	_old_ifs=$IFS
	IFS=","
	set -- $backend_order
	IFS=$_old_ifs

	for _raw_backend in "$@"; do
		_backend=$(normalize_backend_name "$(trim_blank "$_raw_backend")")
		[ -z "$_backend" ] && continue
		case "$_backend" in
		invidious)
			scrape_invidious_search "$_page_query" "$_output_json_file" "$_b3" "$_b4"
			_last_status=$?
			;;
		youtube-html)
			scrape_yt "$_page_query" "$_output_json_file" "$_b3" "$_b4"
			_last_status=$?
			;;
		yt-dlp)
			scrape_ytdlp_search "$_page_query" "$_output_json_file" "$_b3" "$_b4"
			_last_status=$?
			;;
		esac

		if [ "$_last_status" -eq 0 ] && grep -q -v -e '^\[\]$' "$_output_json_file"; then
			return 0
		fi

		backend_log_failure "$_backend" "$_last_status" "backend failed for query: ${_page_query}"
		[ "${backend_strict:-0}" -eq 1 ] && return "$_last_status"
	done

	return "$_last_status"
}
