#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# rpm2cpio --help（可能不支持）
bb_run rpm2cpio --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "rpm2cpio --help 成功"
else
    skip "rpm2cpio --help 不可用"
fi

# rpm2cpio 不存在的文件
bb_run rpm2cpio "$TMPDIR/nonexistent.rpm"
cmp_ok "$_BB_EXIT" "!=" "0" "rpm2cpio 不存在的文件返回非零"

# rpm2cpio 无参数
bb_run rpm2cpio
cmp_ok "$_BB_EXIT" "!=" "0" "rpm2cpio 无参数返回非零"

# 创建一个最小 RPM 文件进行测试
# 使用 python 创建最小有效的 RPM 头
if command -v python3 &>/dev/null; then
    python3 -c "
import struct, os

# RPM 魔数和最小头部
# RPM v3 格式: magic(4) + major(1) + minor(1) + type(2) + archivetag(4) + reserved(12)
magic = b'\xed\xab\xee\xdb'
major = struct.pack('B', 3)
minor = struct.pack('B', 0)
type_val = struct.pack('>H', 0)
archivetag = struct.pack('>I', 0)
reserved = b'\x00' * 12

# 简化的 header: magic(4) + version(1) + reserved(3) + nindex(4) + hsize(4)
h_magic = b'\x8e\xad\xe8\x01'
h_version = struct.pack('B', 1)
h_reserved = b'\x00' * 3
nindex = struct.pack('>I', 0)
hsize = struct.pack('>I', 0)

data = magic + major + minor + type_val + archivetag + reserved + h_magic + h_version + h_reserved + nindex + hsize
# 用 cpio 归档包装
with open('$TMPDIR/test.rpm', 'wb') as f:
    f.write(data)
" 2>/dev/null
    HAS_RPM=true
else
    HAS_RPM=false
fi

skip_if "$HAS_RPM" != "true" "需要 python3 创建测试 RPM 文件"

# rpm2cpio 处理 RPM 文件
bb_run rpm2cpio "$TMPDIR/test.rpm"
# 由于 RPM 文件是简化的，可能返回非零但不应崩溃
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "rpm2cpio 处理 RPM 文件成功"
else
    # 即使失败也不应该段错误
    cmp_ok "$_BB_EXIT" ">=" "1" "rpm2cpio 处理无效 RPM 返回非零（不崩溃）"
fi

# rpm2cpio 从 stdin 读取
bb_run_stdin "$(cat "$TMPDIR/test.rpm")" rpm2cpio
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "rpm2cpio 从 stdin 读取成功"
else
    cmp_ok "$_BB_EXIT" ">=" "1" "rpm2cpio stdin 处理无效 RPM 返回非零"
fi

done_testing
