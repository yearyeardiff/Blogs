---
title: shell scripts in action -- 提取nginx数据生成sql脚本
tags: shell,linux
grammar_cjkRuby: true
---

# 背景
公司开发了一个基于openresty的网关系统，可以可视化配置nginx 的一些参数，例如：ip,port,weight,location,server,server_name;在nginx---->openresty网关,迁移过程中，需要根据nginx的配置写初始化脚本。这项工作够无聊，够没有技术含量，够耗时....（满屏幕的吐槽）
为了终结这个噩梦，我就尝试写了这么一个shell脚本，可以根据配置文件自动生成脚本；这是我第一次shell脚本，刚开始语法不熟...

# 一些语法
- [条件判断式](http://cn.linux.vbird.org/linux_basic/0340bashshell-scripts_4.php)
```bash?linenums
if [ 条件判断式 ]; then
	当条件判断式成立时，可以进行的命令工作内容；
fi 
```
个人比较喜欢这个if 和then写在一期的风格

- [善用判断式](http://cn.linux.vbird.org/linux_basic/0340bashshell-scripts_3.php#test)

```bash?linenums
test "$var1" = "$var2"
```
比较时变量和=直接要有空格，变量最好要用`""`引起来

- [Loop](http://cn.linux.vbird.org/linux_basic/0340bashshell-scripts_5.php)
没有do...while语法，很气

- [Shell 变量](http://www.runoob.com/linux/linux-shell-variable.html)

- [Shell中脚本变量的作用域](https://blog.csdn.net/abc86319253/article/details/46341839)
默认：全局


# 一些坑
- 变量作为入参时,最好要用`""`引起来；当入参中有空格时，一定要

```	
	function split(){
		echo "1, $1"
		echo "2, $2"
	}
	
	string="1 2 3 4"
	split "$string"
```
试一下就知道

- 在test方法中变量也最好用`""`引起来

- #后面的代码会被注释掉

`upstream_name_len="${#upstream_name}"`

#是注释标志，但是用`""`引起来就可以开心地使用了

- grep 正向预查不支持？

# 一些简单的总结

- 切割字符串
推荐awk (ps:也可以使用下面我写的split的方法)
`$(echo  $line | awk '{print $1}')`

- 数字计算
`brace_num=$(($brace_num+1))`

- awk引用外部变量
```bash?linenums
1.  awk '{print a, b}' a=111 b=222 yourfile
注意, 变量位置要在 file 名之前, 否则就不能调用。
还有, 于 BEGIN{}中是不能调用这些的variable. 要用之后所讲的第二种方法才可解决.

2.  awk –v a=111 –v b=222 '{print a,b}' yourfile
注意, 对每一个变量加一个 –v 作传递.

3.  awk '{print " ' "$LOGNAME" ' "}' yourfile
如果想调用environment variable, 要用以上的方式调用, 方法是:
"  '  "  $LOGNAME  "  '  "
```
[awk引用外部变量](https://www.cnblogs.com/mydomain/archive/2012/09/24/2699467.html)

- 字符串的长度
`upstream_name_len="${#upstream_name}"`，这个方式比较短

- 操作数组
```
#!/bin/bash

#基本数组操作
a=(1 2 3)   ##()表示空数组
echo "第0个元素:"${a[0]}
echo "所有元素: "${a[@]}
echo "数组长度: "${#a[@]}
echo "----------------------------------------------"

#遍历数组
echo "遍历数组:"
for item in ${a[@]}
do
    echo $item
done
echo "----------------------------------------------"

##元素操作
a=(${a[@]} 4)
echo "末尾追加1个元素后: "${a[@]}
a[1]=5
echo "修改第1个元素后: "${a[@]}
unset a[1]
echo "删除第1个元素后: "${a[@]}
unset a
echo "删除所有元素后:  "${a[@]}
echo "----------------------------------------------"
```

- 使用数组作为入参

```bash?linenums
function is_unique_in_array(){
    array=($1) 
    element=$2

    for item in ${array[@]}
    do
        if test "$item" = "$element";then
            return 1
        fi
    done
    return 0
}

http_server_infos=()
is_unique_in_array "${http_server_infos[@]}" "$server_name"
```

- [利用Shell脚本循环读取文件中每一行的方法详解](https://www.jb51.net/article/122918.htm)

# debug

```
[root@www ~]# sh [-nvx] scripts.sh
选项与参数：
-n  ：不要运行 script，仅查询语法的问题；
-v  ：再运行 sccript 前，先将 scripts 的内容输出到萤幕上；
-x  ：将使用到的 script 内容显示到萤幕上，这是很有用的参数！

范例一：测试 sh16.sh 有无语法的问题？
[root@www ~]# sh -n sh16.sh 
# 若语法没有问题，则不会显示任何资讯！

范例二：将 sh15.sh 的运行过程全部列出来～
[root@www ~]# sh -x sh15.sh 
+ PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/bin
+ export PATH
+ for animal in dog cat elephant
+ echo 'There are dogs.... '
There are dogs....
+ for animal in dog cat elephant
+ echo 'There are cats.... '
There are cats....
+ for animal in dog cat elephant
+ echo 'There are elephants.... '
There are elephants....
```
# 一些实用的方法
写脚本的时候写了一些工具方法，感觉挺好用的
```bash?linenums
# 字符串是否匹配正则
# 1 否；0 是
function is_string_match_regular(){
	str=$(echo $1 | grep -ioE $2)
	if test -z "$str"
	then
		return 1
	else
		return 0
	fi
}

# 字符串字符转小写
function to_lower(){
	lower_string=$1
	lower_string=`echo $lower_string|awk '{print tolower($0)}'`
}

#字符串切割，分隔符是空白的话,第二个参数不用传
function split(){
    split_string=$1 #字符串
    split_char=$2 #分隔符号

    split_array=()

    if test -z "$split_char";then
        split_array_len=$(echo ${split_string} | awk '{print NF}')

        for (( i=1; i<=$split_array_len; i=i+1 ))
        do
            temp_item=$(echo  ${split_string} | awk -v num=${i} '{print $num}')
            split_array=(${split_array[@]} "$temp_item")
        done
    else
        split_array_len=$(echo  ${split_string} | awk -v c=${split_char} 'BEGIN {FS=c} {print NF}')

        for (( i=1; i<=$split_array_len; i=i+1 ))
        do
            temp_item=$(echo  ${split_string} | awk -v num=${i} -v c=${split_char} 'BEGIN {FS=c} {print $num}')
            split_array=(${split_array[@]} "$temp_item")
        done

    fi
}
```
# 脚本地址
https://github.com/yearyeardiff/code_learn/blob/master/springboot-start/src/main/resources/bin/gen_sql.sh
