/*
 * wsh_parse.h — wsh 解析器接口
 *
 * 负责 ; 分割、赋值检测等解析逻辑。
 * Step 6 将扩展为完整的递归下降解析器。
 */
#ifndef WSH_PARSE_H
#define WSH_PARSE_H

/** 最大命令段数（; 分割） */
#define WSH_MAX_SEGS 256

/**
 * 按 ; 分割命令列表。
 * 尊重 $() 嵌套和引号，不在嵌套/引号内分割。
 *
 * @param input  命令字符串（会被修改，\0 插入分割点）
 * @param segs   输出段数组（指向 input 内部子串）
 * @param max    数组容量
 * @return 段数
 */
int wsh_split_semi(char *input, char *segs[], int max);

/**
 * 检测并执行变量赋值（NAME=VALUE 模式）。
 *
 * @param cmd  命令字符串（展开后的）
 * @return 1 是赋值（已执行 wsh_var_set），0 不是赋值
 */
int wsh_try_assign(const char *cmd);

#endif /* WSH_PARSE_H */
