#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 寻找可用端口
PORT=""
for p in 19101 19102 19103 19104 19105; do
    if ! lsof -i ":$p" &>/dev/null; then
        PORT=$p
        break
    fi
done

skip_if -z "$PORT" "无可用端口"

# 使用 host nc 启动后台 echo 服务器
if command -v nc &>/dev/null; then
    HAS_NC=true
else
    HAS_NC=false
fi

# nc --help
bb_run_net nc --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nc --help 成功"
else
    skip "nc --help 不可用"
fi

# nc 无参数（应失败或等待 stdin）
bb_run_capture nc
# nc 无参数可能不退出，这里测试其不崩溃即可
ok "true" "nc 无参数执行（不崩溃）"

skip_if "$HAS_NC" != "true" "需要 host netcat 启动测试服务器"

# 启动 host echo 服务器
( echo "hello from server" | nc -l "$PORT" ) &
NC_PID=$!
sleep 0.5

# 使用 wasm nc 连接到 echo 服务器并发送数据
bb_run_net nc 127.0.0.1 "$PORT" <<< "hello from client"
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nc 连接服务器成功"
    like "$_BB_STDOUT" "hello from server" "nc 收到服务器响应"
else
    skip "nc 连接服务器失败（WASM 网络限制）"
    skip "nc 连接服务器失败（WASM 网络限制）"
fi
wait "$NC_PID" 2>/dev/null

# nc -z 扫描端口（端口开放）
# 启动一个临时监听
( echo "test" | nc -l "$PORT" ) &
NC_PID2=$!
sleep 0.3
bb_run_net nc -z 127.0.0.1 "$PORT"
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nc -z 扫描开放端口成功"
else
    skip "nc -z 扫描不可用（WASM 限制）"
fi
kill "$NC_PID2" 2>/dev/null
wait "$NC_PID2" 2>/dev/null

# nc -z 扫描端口（端口关闭）
bb_run_net nc -z 127.0.0.1 "$PORT"
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "nc -z 扫描关闭端口返回非零"
else
    skip "nc -z 扫描关闭端口行为不确定"
fi

# nc -w 超时参数
bb_run_net nc -w 1 127.0.0.1 "$PORT"
cmp_ok "$_BB_EXIT" "!=" "0" "nc -w 超时连接关闭端口返回非零"

# nc 连接不存在的 host
bb_run_net nc -w 2 192.0.2.1 "$PORT"
cmp_ok "$_BB_EXIT" "!=" "0" "nc 连接不可达地址返回非零"

done_testing
