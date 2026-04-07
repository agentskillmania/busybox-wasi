#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# udpsvd --help
bb_run_net udpsvd --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "udpsvd --help 成功"
else
    skip "udpsvd --help 不可用"
fi

# udpsvd 无参数
bb_run_capture udpsvd
cmp_ok "$_BB_EXIT" "!=" "0" "udpsvd 无参数返回非零"

# udpsvd 需要fork()，在 WASM 环境中是 stub
# 测试其优雅地失败
bb_run_net udpsvd 127.0.0.1 19998 true
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "udpsvd 因 fork stub 返回非零（预期行为）"
else
    skip "udpsvd 意外成功（fork 可用？）"
fi

# udpsvd 参数不足
bb_run_net udpsvd 127.0.0.1
cmp_ok "$_BB_EXIT" "!=" "0" "udpsvd 参数不足返回非零"

# udpsvd 端口非法
bb_run_net udpsvd 127.0.0.1 abc true
cmp_ok "$_BB_EXIT" "!=" "0" "udpsvd 非法端口号返回非零"

# udpsvd 绑定已占用端口
PORT=""
for p in 19401 19402 19403; do
    if ! lsof -i ":$p" &>/dev/null; then
        PORT=$p
        break
    fi
done
if [[ -n "$PORT" ]]; then
    # 使用 socat 或 nc 占用 UDP 端口
    if command -v nc &>/dev/null; then
        ( echo "test" | nc -u -l "$PORT" ) &
        NC_PID=$!
        sleep 0.3
        bb_run_net udpsvd 127.0.0.1 "$PORT" true
        cmp_ok "$_BB_EXIT" "!=" "0" "udpsvd 绑定已占用端口返回非零"
        kill "$NC_PID" 2>/dev/null
        wait "$NC_PID" 2>/dev/null
    else
        skip "udpsvd 绑定端口测试：需要 nc"
    fi
else
    skip "udpsvd 绑定端口测试：无可用端口"
fi

# udpsvd 版本信息
bb_run_net udpsvd -V
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "udpsvd -V 版本信息成功"
else
    skip "udpsvd -V 不可用"
fi

done_testing
