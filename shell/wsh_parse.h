/*
 * wsh_parse.h — wsh 解析器接口
 *
 * 递归下降解析器：tokenize → parse_list → parse_if/for/while/exec。
 */
#ifndef WSH_PARSE_H
#define WSH_PARSE_H

/**
 * 执行完整输入（主入口）。
 * 处理 ;, if/elif/else/fi, for/in/do/done, while/do/done。
 *
 * @param input  命令字符串
 * @return 最后一个命令的退出码
 */
int wsh_execute_input(const char *input);

/**
 * 检测并执行变量赋值（NAME=VALUE 模式）。
 *
 * @param cmd  命令字符串（展开后的）
 * @return 1 是赋值（已执行 wsh_var_set），0 不是赋值
 */
int wsh_try_assign(const char *cmd);

#endif /* WSH_PARSE_H */
