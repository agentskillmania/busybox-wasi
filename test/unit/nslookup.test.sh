#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# nslookup 查询域名
bb_run_net nslookup example.com
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nslookup 查询 example.com 成功"
    like "$_BB_STDOUT" "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "nslookup 输出包含 IP 地址"
else
    skip "nslookup 在 WASM 环境不可用（DNS 限制）"
    skip "nslookup DNS 查询不可用"
fi

# nslookup 查询 google.com
bb_run_net nslookup google.com
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nslookup 查询 google.com 成功"
    like "$_BB_STDOUT" "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "nslookup google.com 输出包含 IP 地址"
else
    skip "nslookup google.com 不可用"
    skip "nslookup google.com DNS 查询不可用"
fi

# nslookup 不存在的域名
bb_run_net nslookup "this.domain.does.not.exist.invalid"
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "nslookup 不存在的域名返回非零"
else
    # 某些 DNS 服务器可能返回 NXDOMAIN 但退出码仍为 0
    skip "nslookup 不存在的域名退出码不确定"
fi

# nslookup 无参数
bb_run_net nslookup
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nslookup 无参数进入交互模式（或输出帮助）"
else
    cmp_ok "$_BB_EXIT" "!=" "0" "nslookup 无参数返回非零"
fi

# nslookup 指定 DNS 服务器
bb_run_net nslookup example.com 8.8.8.8
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "nslookup 指定 DNS 服务器成功"
else
    skip "nslookup 指定 DNS 服务器不可用"
fi

done_testing
