---
title: linux---命令那些事
tags: linux
grammar_cjkRuby: true
---

- cd
``` tex?linenums
[root@192 zch]# pwd
/home/zch
[root@192 zch]# cd test/
[root@192 test]# cd -  #表示回到刚刚的那个目录
/home/zch
[root@192 zch]# 
```
- pwd
``` tex?linenums
[root@192 zch]# cd /var/mail
[root@192 mail]# pwd
/var/mail
[root@192 mail]# pwd -P
#-P  ：显示出确实的路径，而非使用连结 (link) 路径。
/var/spool/mail
[root@192 mail]# ls -ld /var/mail
lrwxrwxrwx. 1 root root 10 6月  22 06:35 /var/mail -> spool/mail
```
- mkdir
``` tex?linenums
选项与参数：
-m ：配置文件的权限喔！直接配置，不需要看默认权限 (umask) 的脸色～
-p ：帮助你直接将所需要的目录(包含上一级目录)递回创建起来！

[root@192 zch]# mkdir -m 744 -p test1/test2/test3
[root@192 zch]# ls -ld test1
drwxr-xr-x. 3 root root 18 7月  25 17:51 test1
```

- rmdir (删除『空』的目录)
``` tex?linenums
[root@192 zch]# rmdir test1
rmdir: 删除 "test1" 失败: 目录非空
```

- ls
``` tex?linenums
选项与参数：
-a  ：全部的文件，连同隐藏档( 开头为 . 的文件) 一起列出来(常用)
-A  ：全部的文件，连同隐藏档，但不包括 . 与 .. 这两个目录
-d  ：仅列出目录本身，而不是列出目录内的文件数据(常用)
-f  ：直接列出结果，而不进行排序 (ls 默认会以档名排序！)
-F  ：根据文件、目录等资讯，给予附加数据结构，例如：
      *:代表可运行档； /:代表目录； =:代表 socket 文件； |:代表 FIFO 文件；
-h  ：将文件容量以人类较易读的方式(例如 GB, KB 等等)列出来；
-i  ：列出 inode 号码，inode 的意义下一章将会介绍；
-l  ：长数据串列出，包含文件的属性与权限等等数据；(常用)
-n  ：列出 UID 与 GID 而非使用者与群组的名称 (UID与GID会在帐号管理提到！)
-r  ：将排序结果反向输出，例如：原本档名由小到大，反向则为由大到小；
-R  ：连同子目录内容一起列出来，等於该目录下的所有文件都会显示出来；
-S  ：以文件容量大小排序，而不是用档名排序；
-t  ：依时间排序，而不是用档名。

# 查看文件夹
[root@192 zch]# ls -ld test
drwxr-xr-x. 2 root root 19 7月  24 18:10 test
[root@192 zch]# ls -l test/
总用量 0
-rw-r--r--. 1 root root 0 7月  24 18:10 hh.txt

[root@192 test1]# ls -l
总用量 0
drwxr-xr-x. 3 root root 18 7月  25 17:51 test2
drwxr-xr-x. 2 root root  6 7月  25 18:14 test9
# 递归展示，子目录内容一起列出来
[root@192 test1]# ls -lR
.:
总用量 0
drwxr-xr-x. 3 root root 18 7月  25 17:51 test2
drwxr-xr-x. 2 root root  6 7月  25 18:14 test9

./test2:
总用量 0
drwxr--r--. 2 root root 6 7月  25 17:51 test3

./test2/test3:
总用量 0

./test9:
总用量 0

# 按文件大小排序输出
[root@192 zch]# ls -lSh
总用量 16K
drwxrwxr-x. 5 zch  zch  4.0K 7月  18 09:53 dev-software
-rw-r--r--. 1 root root 1.7K 7月  23 10:45 zch.key
-rw-r--r--. 1 root root 1.2K 7月  23 10:48 zch.crt
-rw-r--r--. 1 root root 1.1K 7月  23 10:45 zch.csr
drwxr-xr-x. 4 root root   30 7月  25 18:14 test1
drwxr-xr-x. 2 root root   19 7月  24 18:10 test
drwxr-xr-x. 2 zch  zch     6 6月  22 07:15 公共
# 按时间排序输出
[root@192 zch]# ls -lt
总用量 16
drwxr-xr-x. 4 root root   30 7月  25 18:14 test1
drwxr-xr-x. 2 root root   19 7月  24 18:10 test
-rw-r--r--. 1 root root 1208 7月  23 10:48 zch.crt
-rw-r--r--. 1 root root 1066 7月  23 10:45 zch.csr
-rw-r--r--. 1 root root 1704 7月  23 10:45 zch.key
drwxrwxr-x. 5 zch  zch  4096 7月  18 09:53 dev-software
drwxr-xr-x. 2 zch  zch     6 6月  22 07:15 公共

# 模糊查询
[root@192 zch]# ls zch*
zch.crt  zch.csr  zch.key
```

- cp (复制文件或目录)
``` tex?linenums
选项与参数：
-a  ：相当於 -pdr 的意思，至於 pdr 请参考下列说明；(常用)
-d  ：若来源档为连结档的属性(link file)，则复制连结档属性而非文件本身；
-f  ：为强制(force)的意思，若目标文件已经存在且无法开启，则移除后再尝试一次；
-i  ：若目标档(destination)已经存在时，在覆盖时会先询问动作的进行(常用)
-l  ：进行硬式连结(hard link)的连结档创建，而非复制文件本身；
-p  ：连同文件的属性一起复制过去，而非使用默认属性(备份常用)；
-r  ：递回持续复制，用於目录的复制行为；(常用)
-s  ：复制成为符号连结档 (symbolic link)，亦即『捷径』文件；
-u  ：若 destination 比 source 旧才升级 destination ！

```
- which (寻找『运行档』)
``` tex?linenums
[root@www ~]# which [-a] command
选项或参数：
-a ：将所有由 PATH 目录中可以找到的命令均列出，而不止第一个被找到的命令名称

[root@192 zch]# which ifconfig
/usr/sbin/ifconfig
[root@192 zch]# which ls
alias ls='ls --color=auto'
        /usr/bin/ls
```
- whereis (寻找特定文件)
``` tex?linenums
[root@www ~]# whereis [-bmsu] 文件或目录名
选项与参数：
-b    :只找 binary 格式的文件
-m    :只找在说明档 manual 路径下的文件
-s    :只找 source 来源文件
-u    :搜寻不在上述三个项目当中的其他特殊文件

[zch@192 ~]$ whereis ifconfig
ifconfig: /usr/sbin/ifconfig /usr/share/man/man8/ifconfig.8.gz

那么 whereis 到底是使用什么咚咚呢？为何搜寻的速度会比 find 快这么多？ 其实那也没有什么！这是因为 Linux 系统会将系统内的所有文件都记录在一个数据库文件里面， 而当使用 whereis 或者是底下要说的 locate 时，都会以此数据库文件的内容为准， 因此，有的时后你还会发现使用这两个运行档时，会找到已经被杀掉的文件！ 而且也找不到最新的刚刚创建的文件呢！这就是因为这两个命令是由数据库当中的结果去搜寻文件的所在啊！ 更多与这个数据库有关的说明，请参考下列的 locate 命令。
```

- find
```tex?linenums
[root@www ~]# find [PATH] [option] [action]
# man find 

# 查找名为test1的文件
[zch@192 ~]$ find -name test1
./test/test1
./test1

# 查找名为test1的文件 并 查看详细信息
[zch@192 ~]$ find -name test1 | xargs ls -ld
drwxr-xr-x. 4 root root 30 7月  27 10:36 ./test1
-rw-r--r--. 1 root root  0 7月  27 10:37 ./test/test1

# 查找名为test1的文本文件
[zch@192 ~]$ find -name test1 -type f
./test/test1
# 查找名为test1的目录
[zch@192 ~]$ find -name test1 -type d
./test1

# 查找一天之内变更过的文件
[zch@192 ~]$ find -mtime 0 | xargs ls -ld
drwx------. 18 zch  zch  4096 7月  27 10:36 .
drwxrwxr-x.  2 zch  zch    50 7月  27 10:44 ./.cache/abrt
-rw-------.  1 zch  zch    11 7月  27 10:44 ./.cache/abrt/lastnotification
drwxr-xr-x.  2 root root   31 7月  27 10:37 ./test
drwxr-xr-x.  4 root root   30 7月  27 10:36 ./test1
-rw-r--r--.  1 root root    0 7月  27 10:36 ./test1.txt
-rw-r--r--.  1 root root    0 7月  27 10:37 ./test/test1
[zch@192 ~]$ date
2018年 07月 27日 星期五 10:57:56 CST

# 正则 查找后缀为txt的文件
[zch@192 ~]$ find -regex .*\.txt
./.mozilla/firefox/mloqpkz5.default/revocations.txt
./dev-software/openresty-1.13.6.1/build/lua-cjson-2.1.0.5/CMakeLists.txt
./dev-software/openresty-1.13.6.1/build/lua-cjson-2.1.0.5/performance.txt
./test/hh.txt
./test1.txt  
```