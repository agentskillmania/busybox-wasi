#!/bin/bash
# wasm-ld 包装器：过滤 BusyBox Kbuild 传给链接器的不兼容参数
# wasm-ld 不支持 -nostdlib 等参数，但 ld -r 部分链接本身是支持的
WASM_LD="$HOME/wasi-sdk/bin/wasm-ld"

# 过滤不兼容的参数
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -nostdlib)
            # wasm-ld 不需要此参数，跳过
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

exec "$WASM_LD" "${ARGS[@]}"
