/*
 * wsh_vars.h — wsh 变量存储和展开接口
 *
 * 管理用户变量（X=hello）和特殊变量（$?），
 * 提供 wsh_expand() 将 $VAR / ${VAR} / $? / $(cmd) 展开为实际值。
 */
#ifndef WSH_VARS_H
#define WSH_VARS_H

/**
 * 初始化变量表。
 * 必须在使用其他 wsh_var_* 函数之前调用。
 */
void wsh_vars_init(void);

/**
 * 清理变量表（释放所有 strdup 的 name/value）。
 */
void wsh_vars_cleanup(void);

/**
 * 设置变量。name 和 value 会被 strdup。
 * 如果 name 已存在，更新 value。
 */
void wsh_var_set(const char *name, const char *value);

/**
 * 获取变量值。
 * @return 值字符串（内部指针，不要 free），不存在返回 NULL。
 */
const char *wsh_var_get(const char *name);

/**
 * 设置上一个命令的退出码（用于 $?）。
 */
void wsh_set_last_exitcode(int rc);

/**
 * 获取上一个命令的退出码。
 */
int wsh_get_last_exitcode(void);

/**
 * 展开字符串中的变量和命令替换。
 *
 * 处理：$VAR, ${VAR}, $?, $(cmd)
 * 单引号内不展开。
 *
 * @param str 原始字符串
 * @return 展开后的新字符串（malloc），调用方 free。失败返回 NULL。
 */
char *wsh_expand(const char *str);

/**
 * 子 shell 变量快照（不透明类型）。
 */
struct wsh_var_snapshot;

/**
 * 保存当前变量表快照（深拷贝）。
 * @return 快照指针（堆分配），传给 wsh_vars_restore 后自动释放。
 */
struct wsh_var_snapshot *wsh_vars_save(void);

/**
 * 从快照恢复变量表并释放快照。
 * 子 shell 退出后调用，恢复外层变量环境。
 */
void wsh_vars_restore(struct wsh_var_snapshot *snap);

#endif /* WSH_VARS_H */
