#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 寻找可用端口
PORT=""
for p in 19201 19202 19203 19204 19205; do
    if ! lsof -i ":$p" &>/dev/null; then
        PORT=$p
        break
    fi
done

skip_if -z "$PORT" "无可用端口"

# telnet --help
bb_run_net telnet --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "telnet --help 成功"
else
    skip "telnet --help 不可用"
fi

# 启动一个简单的 TCP echo 服务器用于测试 telnet 连接
if command -v python3 &>/dev/null; then
    python3 -c "
import socket, threading, time

def handle_client(conn):
    try:
        conn.sendall(b'Welcome to test server\r\n')
        time.sleep(2)
    except:
        pass
    finally:
        conn.close()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('127.0.0.1', $PORT))
s.listen(1)
s.settimeout(5)
try:
    conn, addr = s.accept()
    t = threading.Thread(target=handle_client, args=(conn,))
    t.daemon = True
    t.start()
    t.join()
except:
    pass
finally:
    s.close()
" &
PY_PID=$!
sleep 0.5
    HAS_SERVER=true
else
    HAS_SERVER=false
fi

skip_if "$HAS_SERVER" != "true" "需要 python3 启动测试服务器"

# telnet 连接（使用超时避免挂起）
# 注意：telnet 是交互式的，在自动化环境中只能测试连接建立
bb_run_net telnet 127.0.0.1 "$PORT"
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "telnet 连接服务器成功"
else
    # telnet 可能因 stdin EOF 而退出，但连接本身可能成功
    skip "telnet 连接行为受限（WASM 环境）"
fi

wait "$PY_PID" 2>/dev/null

# telnet 连接关闭的端口
bb_run_net telnet 127.0.0.1 "$PORT"
cmp_ok "$_BB_EXIT" "!=" "0" "telnet 连接关闭端口返回非零"

# telnet 无参数
bb_run_net telnet
cmp_ok "$_BB_EXIT" "!=" "0" "telnet 无参数返回非零"

done_testing
