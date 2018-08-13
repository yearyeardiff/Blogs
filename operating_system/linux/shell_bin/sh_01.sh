#!/bin/bash
# Program:
# History:
# 2018/08/08	zch	First release
PATH=${PATH}:~/bin
export PATH
read -p "Please input your first name: " firstname  # 提示使用者输入
read -p "Please input your last name:  " lastname   # 提示使用者输入
echo "\nYour full name is: $firstname $lastname" # 结果由萤幕输出
exit 0

