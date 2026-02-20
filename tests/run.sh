#!/usr/bin/env sh
set -eu

fail=0
for t in tests/test_*.sh; do
	echo "[test] $t"
	if ! "$t"; then
		fail=1
	fi
done

exit "$fail"
