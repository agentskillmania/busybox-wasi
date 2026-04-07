#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# 寻找可用端口
PORT=""
for p in 19001 19002 19003 19004 19005; do
    if ! lsof -i ":$p" &>/dev/null; then
        PORT=$p
        break
    fi
done

skip_if -z "$PORT" "无可用端口"

# 创建测试文件目录
mkdir -p "$TMPDIR/www"
mkfile "www/index.html" "<html><body>Hello wget test</body></html>"
mkfile "www/data.txt" "wget data file content"

# 启动 python http server 在后台
python3 -m http.server "$PORT" --directory "$TMPDIR/www" >/dev/null 2>&1 &
HTTP_PID=$!
# 等待服务器启动
for i in $(seq 1 10); do
    if curl -s "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

# wget 下载文件
bb_run_net wget "http://127.0.0.1:$PORT/index.html" -O "$TMPDIR/downloaded.html"
is "$_BB_EXIT" "0" "wget 下载文件成功"
is "$(cat "$TMPDIR/downloaded.html")" "<html><body>Hello wget test</body></html>" "wget 下载内容正确"

# wget -O 指定输出文件
bb_run_net wget "http://127.0.0.1:$PORT/data.txt" -O "$TMPDIR/data_out.txt"
is "$_BB_EXIT" "0" "wget -O 指定输出文件成功"
is "$(cat "$TMPDIR/data_out.txt")" "wget data file content" "wget -O 输出内容正确"

# wget 下载不存在的路径（404）
bb_run_net wget "http://127.0.0.1:$PORT/nonexistent.html" -O "$TMPDIR/404.html"
cmp_ok "$_BB_EXIT" "!=" "0" "wget 下载不存在的文件返回非零（404）"

# wget 连接被拒绝（关闭服务器后的请求）
kill "$HTTP_PID" 2>/dev/null
wait "$HTTP_PID" 2>/dev/null
bb_run_net wget "http://127.0.0.1:$PORT/index.html" -O "$TMPDIR/refused.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "wget 连接被拒绝返回非零"

# wget 无参数
bb_run_net wget
cmp_ok "$_BB_EXIT" "!=" "0" "wget 无参数返回非零"

# wget --help（输出到 stderr）
bb_run_capture wget --help
is "$_BB_EXIT" "0" "wget --help 成功"
_wget_help="${_BB_STDOUT}${_BB_STDERR}"
like "$_wget_help" "wget" "wget --help 输出包含 wget"

done_testing
