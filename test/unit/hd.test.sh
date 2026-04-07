#!/bin/bash
# hd 是 hexdump -C 的别名
exec "$(dirname "$0")/hexdump.test.sh" "$@"
