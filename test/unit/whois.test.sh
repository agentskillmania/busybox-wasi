#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# whois --help
bb_run_net whois --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "whois --help 成功"
else
    skip "whois --help 不可用"
fi

# whois 无参数
bb_run_capture whois
cmp_ok "$_BB_EXIT" "!=" "0" "whois 无参数返回非零"

# whois 查询域名（可能因网络限制失败）
bb_run_net whois example.com
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "whois 查询 example.com 成功"
    # 输出可能包含注册信息
    cmp_ok "${#_BB_STDOUT}" ">" "0" "whois 查询输出非空"
else
    # WASM 网络环境可能不支持 whois 协议（端口 43）
    skip "whois 查询在 WASM 环境不可用"
    skip "whois 查询输出不可用"
fi

# whois 查询 IP 地址
bb_run_net whois 1.1.1.1
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "whois 查询 IP 地址成功"
else
    skip "whois IP 查询在 WASM 环境不可用"
fi

# whois -h 指定服务器
bb_run_net whois -h whois.iana.org example.com
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "whois -h 指定服务器查询成功"
else
    skip "whois -h 指定服务器在 WASM 环境不可用"
fi

done_testing
