#!/bin/bash
# netcat 是 nc 的别名
exec "$(dirname "$0")/nc.test.sh" "$@"
