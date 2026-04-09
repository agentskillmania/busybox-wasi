/*
 * WASI TLS 内联粘合层。
 *
 * BusyBox wget 的 spawn_ssl_client 用 fork+socketpair 做双向 TLS 代理，
 * WASM 单进程环境不支持。此模块提供内联 TLS 方案：
 *   1. 直接在 network fd 上做 TLS 握手
 *   2. 通过全局 TLS 状态拦截 read/write，透明加解密
 *   3. 对 wget 来说，读写 network fd 和普通 fd 没有区别
 *
 * 依赖：
 *   - arch/wasm32/Makefile 中的 -Wl,--wrap=read,write
 *   - networking/tls.c 中导出的 tls_xwrite/tls_xread_record 等函数
 */

#include "libbb.h"

/* tls.c 内部导出的函数（已从 static 改为 extern） */
extern void *tls_get_outbuf(tls_state_t *tls, int len);
extern void tls_xwrite(tls_state_t *tls, int len);
extern int tls_xread_record(tls_state_t *tls, const char *expected);
extern int tls_has_buffered_record(tls_state_t *tls);

/* tls.c 内部常量，RECHDR_LEN = 5 (record header: type(1) + version(2) + len16(2)) */
#define _TLS_RECHDR_LEN 5

/* ========== 全局 TLS 状态 ========== */

static tls_state_t *g_tls = NULL;
static int g_tls_fd = -1;
static int g_tls_read_pos = 0;
static int g_tls_read_avail = 0;

/* 重入保护：TLS 内部也会调用 read/write（通过 xwrite/xread），
 * 这些调用必须直接走系统调用，不能再次进入 TLS 路径。 */
static int g_tls_in_write = 0;
static int g_tls_in_read = 0;

/* 供 __wrap_write/__wrap_read 查询的重入标志 */
int wasi_tls_in_write(void) { return g_tls_in_write; }
int wasi_tls_in_read(void) { return g_tls_in_read; }

/* 初始化 TLS：在 network fd 上完成握手 */
void wasi_tls_setup(const char *host, int fd)
{
	g_tls = new_tls_state();
	g_tls->ifd = g_tls->ofd = fd;
	tls_handshake(g_tls, host);
	g_tls_fd = fd;
	g_tls_read_pos = 0;
	g_tls_read_avail = 0;
}

/* 判断 fd 是否为 TLS 连接 */
int wasi_tls_is_active(int fd)
{
	return (g_tls != NULL && fd == g_tls_fd);
}

/* TLS 感知的 read：从 TLS 记录中读取（带缓冲） */
ssize_t wasi_tls_read(void *buf, size_t count)
{
	g_tls_in_read = 1;

	/* 先返回上次记录中未读完的数据 */
	if (g_tls_read_pos < g_tls_read_avail) {
		int avail = g_tls_read_avail - g_tls_read_pos;
		int n = (count < (size_t)avail) ? count : avail;
		memcpy(buf, g_tls->inbuf + _TLS_RECHDR_LEN + g_tls_read_pos, n);
		g_tls_read_pos += n;
		g_tls_in_read = 0;
		return n;
	}

	/* 读一条新的 TLS 记录 */
	int nread = tls_xread_record(g_tls, "encrypted data");
	if (nread < 1) {
		g_tls_in_read = 0;
		return 0; /* EOF 或错误 */
	}

	g_tls_read_avail = nread;
	g_tls_read_pos = 0;

	int n = (count < (size_t)nread) ? count : nread;
	memcpy(buf, g_tls->inbuf + _TLS_RECHDR_LEN, n);
	g_tls_read_pos = n;
	g_tls_in_read = 0;
	return n;
}

/* TLS 感知的 write：加密后发送 */
ssize_t wasi_tls_write(const void *buf, size_t count)
{
	g_tls_in_write = 1;
	void *outbuf = tls_get_outbuf(g_tls, (int)count);
	memcpy(outbuf, buf, count);
	tls_xwrite(g_tls, (int)count);
	g_tls_in_write = 0;
	return (ssize_t)count;
}

/* 清理 TLS 状态 */
void wasi_tls_close(void)
{
	g_tls_fd = -1;
	g_tls = NULL;
	g_tls_read_pos = 0;
	g_tls_read_avail = 0;
}
