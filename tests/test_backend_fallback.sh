#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM HUP

BIN_DIR="$TMP_DIR/bin"
CACHE_DIR="$TMP_DIR/cache"
CONF_DIR="$TMP_DIR/conf"
mkdir -p "$BIN_DIR" "$CACHE_DIR" "$CONF_DIR"

cat >"$BIN_DIR/curl" <<'EOF'
#!/usr/bin/env sh
exit 22
EOF
chmod +x "$BIN_DIR/curl"

cat >"$BIN_DIR/yt-dlp" <<'EOF'
#!/usr/bin/env sh
cat <<JSON
{"entries":[{"id":"abc123","title":"fixture title","uploader":"fixture channel","duration":125,"view_count":42,"upload_date":"20260101","description":"fixture description","thumbnail":"https://example.invalid/thumb.jpg"}]}
JSON
EOF
chmod +x "$BIN_DIR/yt-dlp"

cat >"$CONF_DIR/conf.sh" <<EOF
cache_dir="$CACHE_DIR"
instances_file="$CACHE_DIR/instancesV2.json"
invidious_cache_ttl_seconds=999999
EOF
printf '%s\n' "https://example.invalid" >"$CACHE_DIR/instancesV2.json"

OUT=$(
	PATH="$BIN_DIR:$PATH" \
	YTFZF_CONFIG_DIR="$CONF_DIR" \
	YTFZF_CONFIG_FILE="$CONF_DIR/conf.sh" \
	"$ROOT_DIR/ytfzf" --backend-order=invidious,yt-dlp -a -L "fixture query" 2>/dev/null
)

printf '%s' "$OUT" | grep -q "watch?v=abc123"
