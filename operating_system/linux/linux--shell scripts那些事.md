---
title: linux--shell scripts那些事
tags: linux,shell
grammar_cjkRuby: true
---

## 撰写与运行
在 shell script 的撰写中还需要用到底下的注意事项：

1. 命令的运行是从上而下、从左而右的分析与运行；
2. 命令、选项与参数间的多个空白都会被忽略掉；
3. 空白行也将被忽略掉，并且 [tab] 按键所推开的空白同样视为空白键；
4. 如果读取到一个 Enter 符号 (CR) ，就尝试开始运行该行 (或该串) 命令；
5. 至於如果一行的内容太多，则可以使用『 \[Enter] 』来延伸至下一行；
6. 『 # 』可做为注解！任何加在 # 后面的数据将全部被视为注解文字而被忽略！

那如何运行这个文件？很简单，可以有底下几个方法：

- 直接命令下达： shell.sh 文件必须要具备可读与可运行 (rx) 的权限，然后：
  - 绝对路径：使用 /home/dmtsai/shell.sh 来下达命令；
  - 相对路径：假设工作目录在 /home/dmtsai/ ，则使用 ./shell.sh 来运行
  - 变量『PATH』功能：将 shell.sh 放在 PATH 指定的目录内，例如： ~/bin/
- 以 bash 程序来运行：透过『 bash shell.sh 』或『 sh shell.sh 』来运行