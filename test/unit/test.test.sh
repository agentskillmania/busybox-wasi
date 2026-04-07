#!/bin/bash
# test 是 shell 关键字，测试文件为 test_cmd.test.sh
exec "$(dirname "$0")/test_cmd.test.sh" "$@"
