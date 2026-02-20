#!/usr/bin/env sh
set -eu

echo "[check] shell syntax"
sh -n ytfzf

find addons -type f -perm -111 | while IFS= read -r f; do
	case "$(head -n1 "$f" 2>/dev/null || true)" in
	"#!/bin/sh" | "#!/usr/bin/env sh" | "#!/bin/bash" | "#!/usr/bin/env bash")
		sh -n "$f"
		;;
	esac
done

echo "[check] python/perl helper syntax"
find addons -type f | while IFS= read -r f; do
	case "$(head -n1 "$f" 2>/dev/null || true)" in
	"#!/bin/python" | "#!/usr/bin/env python" | "#!/usr/bin/env python3")
		python3 -m py_compile "$f"
		;;
	"#!/bin/perl" | "#!/usr/bin/env perl")
		perl -c "$f" >/dev/null
		;;
	esac
done
find addons -type d -name __pycache__ -prune -exec rm -rf {} +

if command -v shellcheck >/dev/null 2>&1; then
	echo "[check] shellcheck"
	shellcheck -s sh ytfzf addons/*/* addons/*/*/* 2>/dev/null || shellcheck -s sh ytfzf
else
	echo "[check] shellcheck not installed, skipping"
fi

echo "[check] tests"
./tests/run.sh
