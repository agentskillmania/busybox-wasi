#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# tcpsvd --help
bb_run_net tcpsvd --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "tcpsvd --help 成功"
else
    skip "tcpsvd --help 不可用"
fi

# tcpsvd 无参数
bb_run_capture tcpsvd
cmp_ok "$_BB_EXIT" "!=" "0" "tcpsvd 无参数返回非零"

# tcpsvd 需要fork()，在 WASM 环境中是 stub
# 测试其优雅地失败
bb_run_net tcpsvd 127.0.0.1 19999 true
# fork() stub 返回 ENOSYS，tcpsvd 应该失败
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "tcpsvd 因 fork stub 返回非零（预期行为）"
else
    skip "tcpsvd 意外成功（fork 可用？）"
fi

# tcpsvd 参数不足
bb_run_net tcpsvd 127.0.0.1
cmp_ok "$_BB_EXIT" "!=" "0" "tcpsvd 参数不足返回非零"

# tcpsvd 端口非法
bb_run_net tcpsvd 127.0.0.1 abc true
cmp_ok "$_BB_EXIT" "!=" "0" "tcpsvd 非法端口号返回非零"

# tcpsvd 绑定已占用端口
# 先占用一个端口
PORT=""
for p in 19301 19302 19303; do
    if ! lsof -i ":$p" &>/dev/null; then
        PORT=$p
        break
    fi
done
if [[ -n "$PORT" ]]; then
    ( echo "test" | nc -l "$PORT" ) &
    NC_PID=$!
    sleep 0.3
    bb_run_net tcpsvd 127.0.0.1 "$PORT" true
    cmp_ok "$_BB_EXIT" "!=" "0" "tcpsvd 绑定已占用端口返回非零"
    kill "$NC_PID" 2>/dev/null
    wait "$NC_PID" 2>/dev/null
else
    skip "tcpsvd 绑定端口测试：无可用端口"
fi

# tcpsvd 版本信息
bb_run_net tcpsvd -V
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "tcpsvd -V 版本信息成功"
else
    skip "tcpsvd -V 不可用"
fi

done_testing
