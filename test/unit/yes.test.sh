#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 1

# yes 无限输出，wsh 串行管道需要第一个命令先完整输出到临时文件
# WASI 无 SIGPIPE 终止它，所以 yes 通过 wsh 管道会永久阻塞
skip "yes 无限输出，WASI 无 SIGPIPE，通过 wsh 管道会永久阻塞"

done_testing
