/*
 * WASI 入口桥接。
 *
 * clang 在 wasm 目标上会将 main(argc, argv) 重命名为 __main_argc_argv。
 * 我们用 __attribute__((used)) 和 asm label 来确保这个 main 符号不被重命名，
 * 从而让 __main_void 能正确找到它。
 *
 * 实际的 busybox 入口在 libbb/appletlib.c 中（也被重命名为 __main_argc_argv）。
 */
extern int busybox_real_main(int argc, char **argv) __asm__("__main_argc_argv");

__attribute__((used))
int main(int argc, char **argv) {
    return busybox_real_main(argc, argv);
}
