---
title: linux--命令那些事
tags: linux
grammar_cjkRuby: true
---
# 常用命令
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
[root@www ~]# cp [-adfilprsu] 来源档(source) 目标档(destination)
[root@www ~]# cp [options] source1 source2 source3 .... directory
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

[root@192 zch]# cp -a test1 temp
[root@192 zch]# ls -ld temp
drwxrwxr-x. 3 zch zch 18 7月  26 06:52 temp
[root@192 zch]# su zch
[zch@192 ~]$ ls -ld test1
drwxrwxr-x. 3 zch zch 18 7月  26 06:52 test1
```

- rm (移除文件或目录)

``` tex?linenums
[root@www ~]# rm [-fir] 文件或目录
选项与参数：
-f  ：就是 force 的意思，忽略不存在的文件，不会出现警告信息；
-i  ：互动模式，在删除前会询问使用者是否动作
-r  ：递回删除啊！最常用在目录的删除了！这是非常危险的选项！！！

[zch@192 ~]$ rm -i temp
rm: 无法删除"temp": 是一个目录
[zch@192 ~]$ rm -r temp  #删除temp目录以及下面所有的文件
[zch@192 ~]$ ls
```

- mv (移动文件与目录，或更名)

```tex?linenums
[root@www ~]# mv [-fiu] source destination
[root@www ~]# mv [options] source1 source2 source3 .... directory
选项与参数：
-f  ：force 强制的意思，如果目标文件已经存在，不会询问而直接覆盖；
-i  ：若目标文件 (destination) 已经存在时，就会询问是否覆盖！
-u  ：若目标文件已经存在，且 source 比较新，才会升级 (update)

# 可以用来重命名
[zch@192 ~]$ mv test1 temp
[zch@192 ~]$ ls
temp  VMwareTools-10.2.5-8068393.tar.gz  vmware-tools-distrib
```

- more (一页一页翻动)
``` tex?linenums
[root@www ~]# more /etc/man.config
#
# Generated automatically from man.conf.in by the
# configure script.
#
# man.conf from man-1.6d
....(中间省略)....
--More--(28%)  <== 重点在这一行喔！你的光标也会在这里等待你的命令



空白键 (space)：代表向下翻一页；
Enter         ：代表向下翻『一行』；
/字串         ：代表在这个显示的内容当中，向下搜寻『字串』这个关键字；
:f            ：立刻显示出档名以及目前显示的行数；
q             ：代表立刻离开 more ，不再显示该文件内容。
b 或 [ctrl]-b ：代表往回翻页，不过这动作只对文件有用，对管线无用。
```

- less (一页一页翻动)
``` tex?linenums
less 的用法比起 more 又更加的有弹性，怎么说呢？在 more 的时候，我们并没有办法向前面翻， 只能往后面看，但若使用了 less 时，呵呵！就可以使用 [pageup] [pagedown] 等按键的功能来往前往后翻看文件，你瞧，是不是更容易使用来观看一个文件的内容了呢！

除此之外，在 less 里头可以拥有更多的『搜寻』功能喔！不止可以向下搜寻，也可以向上搜寻～ 实在是很不错用～基本上，可以输入的命令有：

空白键    ：向下翻动一页；
[pagedown]：向下翻动一页；
[pageup]  ：向上翻动一页；
/字串     ：向下搜寻『字串』的功能；
?字串     ：向上搜寻『字串』的功能；
n         ：重复前一个搜寻 (与 / 或 ? 有关！)
N         ：反向的重复前一个搜寻 (与 / 或 ? 有关！)
q         ：离开 less 这个程序；
```

- head (取出前面几行)

``` tex?linenums

[root@www ~]# head [-n number] 文件
选项与参数：
-n  ：后面接数字，代表显示几行的意思

[root@www ~]# head /etc/man.config
# 默认的情况中，显示前面十行！若要显示前 20 行，就得要这样：
[root@www ~]# head -n 20 /etc/man.config

范例：如果后面100行的数据都不列印，只列印/etc/man.config的前面几行，该如何是好？
[root@www ~]# head -n -100 /etc/man.config
```

- tail (取出后面几行)
```tex?linenums
[root@www ~]# tail [-n number] 文件
选项与参数：
-n  ：后面接数字，代表显示几行的意思
-f  ：表示持续侦测后面所接的档名，要等到按下[ctrl]-c才会结束tail的侦测

[root@www ~]# tail /etc/man.config
# 默认的情况中，显示最后的十行！若要显示最后的 20 行，就得要这样：
[root@www ~]# tail -n 20 /etc/man.config

范例一：如果不知道/etc/man.config有几行，却只想列出100行以后的数据时？
[root@www ~]# tail -n +100 /etc/man.config

范例二：持续侦测/var/log/messages的内容
[root@www ~]# tail -f /var/log/messages
  <==要等到输入[crtl]-c之后才会离开tail这个命令的侦测！
```

- touch(修改文件时间或建置新档)
```tex?linenums
[root@www ~]# touch [-acdmt] 文件
选项与参数：
-a  ：仅修订 access time；
-c  ：仅修改文件的时间，若该文件不存在则不创建新文件；
-d  ：后面可以接欲修订的日期而不用目前的日期，也可以使用 --date="日期或时间"
-m  ：仅修改 mtime ；
-t  ：后面可以接欲修订的时间而不用目前的时间，格式为[YYMMDDhhmm]

范例一：新建一个空的文件并观察时间
[root@www ~]# cd /tmp
[root@www tmp]# touch testtouch
[root@www tmp]# ls -l testtouch
-rw-r--r-- 1 root root 0 Sep 25 21:09 testtouch
# 注意到，这个文件的大小是 0 呢！在默认的状态下，如果 touch 后面有接文件，
# 则该文件的三个时间 (atime/ctime/mtime) 都会升级为目前的时间。若该文件不存在，
# 则会主动的创建一个新的空的文件喔！例如上面这个例子！

范例二：将 ~/.bashrc 复制成为 bashrc，假设复制完全的属性，检查其日期
[root@www tmp]# cp -a ~/.bashrc bashrc
[root@www tmp]# ll bashrc; ll --time=atime bashrc; ll --time=ctime bashrc
-rw-r--r-- 1 root root 176 Jan  6  2007 bashrc  <==这是 mtime
-rw-r--r-- 1 root root 176 Sep 25 21:11 bashrc  <==这是 atime
-rw-r--r-- 1 root root 176 Sep 25 21:12 bashrc  <==这是 ctime
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

- file(查看文件类型)

```tex?linenums
[zch@192 ~]$ file pom.xml

pom.xml: exported SGML document, UTF-8 Unicode text
[zch@192 ~]$ 
[zch@192 ~]$ file temp
temp: directory
[zch@192 ~]$ file VMwareTools-10.2.5-8068393.tar.gz 
VMwareTools-10.2.5-8068393.tar.gz: gzip compressed data, from Unix, last modified: Thu Mar 22 17:10:52 2018
```

- tar(打包压缩)
```tex?linenums
[root@www ~]# tar [-j|-z] [cv] [-f 创建的档名] filename... <==打包与压缩
[root@www ~]# tar [-j|-z] [tv] [-f 创建的档名]             <==察看档名
[root@www ~]# tar [-j|-z] [xv] [-f 创建的档名] [-C 目录]   <==解压缩
选项与参数：
-c  ：创建打包文件，可搭配 -v 来察看过程中被打包的档名(filename)
-t  ：察看打包文件的内容含有哪些档名，重点在察看『档名』就是了；
-x  ：解打包或解压缩的功能，可以搭配 -C (大写) 在特定目录解开
      特别留意的是， -c, -t, -x 不可同时出现在一串命令列中。
-j  ：透过 bzip2 的支持进行压缩/解压缩：此时档名最好为 *.tar.bz2
-z  ：透过 gzip  的支持进行压缩/解压缩：此时档名最好为 *.tar.gz
-v  ：在压缩/解压缩的过程中，将正在处理的档名显示出来！
-f filename：-f 后面要立刻接要被处理的档名！建议 -f 单独写一个选项罗！
-C 目录    ：这个选项用在解压缩，若要在特定目录解压缩，可以使用这个选项。

其他后续练习会使用到的选项介绍：
-p  ：保留备份数据的原本权限与属性，常用於备份(-c)重要的配置档
-P  ：保留绝对路径，亦即允许备份数据中含有根目录存在之意；
--exclude=FILE：在压缩的过程中，不要将 FILE 打包！ 


压　缩：tar -jcv -f filename.tar.bz2 要被压缩的文件或目录名称
查　询：tar -jtv -f filename.tar.bz2
解压缩：tar -jxv -f filename.tar.bz2 -C 欲解压缩的目录

# 压缩
[zch@192 ~]$ tar -zcvf temp.tar.gz temp
temp/
temp/test2/
temp/test2/test3/
temp/hh
[zch@192 ~]$ ls -l temp.tar.gz 
-rw-rw-r--. 1 zch zch 177 7月  29 21:35 temp.tar.gz

# 把文件解压到指定目录
[zch@192 ~]$ tar -zxvf temp.tar.gz -C temp2
temp/
temp/test2/
temp/test2/test3/
temp/hh
[zch@192 ~]$ ls ./temp2
temp
```
# 数据流重导向 (Redirection)
> 数据流重导向 (redirect) 由字面上的意思来看，好像就是将『数据给他传导到其他地方去』的样子？ 没错～数据流重导向就是将某个命令运行后应该要出现在屏幕上的数据， 给他传输到其他的地方

![命令运行过程的数据传输情况](./images/1533697350348.jpg)

## standard output 与 standard error output
>简单的说，标准输出指的是『命令运行所回传的正确的信息』，而标准错误输出可理解为『 命令运行失败后，所回传的错误信息』

标准输入　　(stdin) ：代码为 0 ，使用 < 或 << ；
标准输出　　(stdout)：代码为 1 ，使用 > 或 >> ；
标准错误输出(stderr)：代码为 2 ，使用 2> 或 2>> ；

- 举例
```tex?linenums
# 输出重定向
[zch@localhost ~]$ ll >> ./linux_test/ll.log
[zch@localhost ~]$ cat ./linux_test/ll.log
总用量 0
drwxrwxr-x. 2 zch zch 19 8月   8 11:24 linux_test
drwxr-xr-x. 2 zch zch  6 8月   8 09:53 公共
drwxr-xr-x. 2 zch zch  6 8月   8 09:53 模板

# 重导向 标准信息和错误信息
[zch@localhost ~]$ find /home -name .bashrc 1>>./linux_test/result.log 2>>error.log
[zch@localhost ~]$ cat ./linux_test/result.log
/home/zch/.bashrc
[zch@localhost ~]$ cat ./error.log
find: ‘/home/test’: 权限不够
```

## /dev/null 垃圾桶黑洞装置与特殊写法
```tex?linenums
#将错误的数据丢弃，屏幕上显示正确的数据
[zch@localhost ~]$ find /home -name .bashrc
/home/zch/.bashrc
find: ‘/home/test’: 权限不够
[zch@localhost ~]$ find /home -name .bashrc 2>>/dev/null
/home/zch/.bashrc
```

如果我要将正确与错误数据通通写入同一个文件去呢？这个时候就得要使用特殊的写法了！ 我们同样用底下的案例来说明：
```tex?linenums
# 错误
[zch@localhost ~]$ find /home -name .bashrc > list 2> list
[zch@localhost ~]$ cat list
find: ‘/home/test’: 权限不够

# 正确
zch@localhost ~]$ find /home -name .bashrc > list 2>&1
[zch@localhost ~]$ cat list
/home/zch/.bashrc
find: ‘/home/test’: 权限不够

#正确
[zch@localhost ~]$ find /home -name .bashrc &> list
[zch@localhost ~]$ cat list
/home/zch/.bashrc
find: ‘/home/test’: 权限不够
```

上述表格第一行错误的原因是，由于两股数据同时写入一个文件，又没有使用特殊的语法， 此时两股数据可能会交叉写入该文件内，造成次序的错乱。

## standard input ： < 与 <<
> 以最简单的说法来说， 那就是『将原本需要由键盘输入的数据，改由文件内容来取代』的意思

```tex?linenums
# 用 stdin 取代键盘的输入以创建新文件的简单流程
[zch@localhost ~]$ cat > list < .bashrc
[zch@localhost ~]$ cat list
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
```

# 管道命令
> 这个管线命令『 | 』仅能处理经由前面一个命令传来的正确信息，也就是 standard output 的信息，对于 stdandard error 并没有直接处理的能力。那么整体的管线命令可以使用下图表示：

![管线命令的处理示意图](./images/1533708522895.jpg)
在每个管线后面接的第一个数据必定是『命令』喔！而且这个命令必须要能够接受 standard input 的数据才行，这样的命令才可以是为『管线命令』，例如 less, more, head, tail 等都是可以接受 standard input 的管线命令啦。至于例如 ls, cp, mv 等就不是管线命令了！因为 ls, cp, mv 并不会接受来自 stdin 的数据。 也就是说，管线命令主要有两个比较需要注意的地方：

- 管线命令仅会处理 standard output，对于 standard error output 会予以忽略
- 管线命令必须要能够接受来自前一个命令的数据成为 standard input 继续处理才行。
## 选取命令
>什么是撷取命令啊？说穿了，就是将一段数据经过分析后，取出我们所想要的。或者是经由分析关键词，取得我们所想要的那一行！ 不过，要注意的是，一般来说，撷取信息通常是针对『一行一行』来分析的

### cut

```tex?linenums
[root@www ~]# cut -d'分隔字符' -f fields <==用于有特定分隔字符
[root@www ~]# cut -c 字符区间            <==用于排列整齐的信息
选项与参数：
-d  ：后面接分隔字符。与 -f 一起使用；
-f  ：依据 -d 的分隔字符将一段信息分割成为数段，用 -f 取出第几段的意思；
-c  ：以字符 (characters) 的单位取出固定字符区间；

#将 PATH 变量取出，我要找出第一个路径。
[zch@localhost ~]$ echo $PATH
/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/zch/.local/bin:/home/zch/bin
[zch@localhost ~]$ echo $PATH | cut -d':' -f 1
/usr/local/bin
[zch@localhost ~]$ echo $PATH | cut -d':' -f 1,2        #1,2
/usr/local/bin:/usr/bin
[zch@localhost ~]$ echo $PATH | cut -d':' -f 1-3        #1~3
/usr/local/bin:/usr/bin:/usr/local/sbin


#将 export 输出的信息，取得第 12 字符以后的所有字符串
[root@www ~]# export
declare -x HISTCONTROL="ignoredups"
declare -x HISTSIZE="1000"
declare -x HOME="/home/zch"
declare -x HOSTNAME="localhost.localdomain"
declare -x LANG="zh_CN.UTF-8"
declare -x LC_CTYPE="zh_CN.UTF-8"
declare -x LESSOPEN="||/usr/bin/lesspipe.sh %s"
declare -x LOGNAME="zch"
# 每个数据都是排列整齐的输出！如果我们不想要『 declare -x 』时
# 我们还可以指定某个范围的值，例如第 12-20 的字符，就是 cut -c 12-20
zch@localhost ~]$ export | cut -c 12-
HISTCONTROL="ignoredups"
HISTSIZE="1000"
HOME="/home/zch"
HOSTNAME="localhost.localdomain"
LANG="zh_CN.UTF-8"
LC_CTYPE="zh_CN.UTF-8"
LESSOPEN="||/usr/bin/lesspipe.sh %s"
LOGNAME="zch"
```
### grep
>刚刚的 cut 是将一行信息当中，取出某部分我们想要的，而 grep 则是分析一行信息， 若当中有我们所需要的信息，就将该行拿出来～简单的语法是这样的：

```tex?linenums
[root@www ~]# grep [-acinv] [--color=auto] '搜寻字符串' filename
选项与参数：
-a ：将 binary 文件以 text 文件的方式搜寻数据
-c ：计算找到 '搜寻字符串' 的次数
-i ：忽略大小写的不同，所以大小写视为相同
-n ：顺便输出行号
-v ：反向选择，亦即显示出没有 '搜寻字符串' 内容的那一行！
--color=auto ：可以将找到的关键词部分加上颜色的显示喔！

# grep 对指定文件查询字符串
[zch@localhost ~]$ grep bashrc ./list
# .bashrc
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
[zch@localhost ~]$ cat list
# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
[zch@localhost ~]$ grep bashrc ./list
# .bashrc
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
	
# 将 last 当中，有出现 zch 的那一行就取出来；
[zch@localhost ~]$ last | grep 'zch'
zch      pts/2        172.16.98.1      Wed Aug  8 10:31   still logged in
zch      pts/1        172.16.98.1      Wed Aug  8 09:56 - 11:58  (02:01)
# 只要筛选没有zch的记录
[zch@localhost ~]$ last | grep -v zch'
(unknown :0           :0               Wed Aug  8 09:53 - 09:53  (00:00)
reboot   system boot  3.10.0-327.el7.x Wed Aug  8 09:52 - 15:24  (05:32)

wtmp begins Wed Aug  8 09:52:25 2018
```

## 排序命令 sort, wc, uniq

```tex?linenums
[root@www ~]# wc [-lwm]
选项与参数：
-l  ：仅列出行；
-w  ：仅列出多少字(英文单字)；
-m  ：多少字符；

# 输出的三个数字中，分别代表： 『行、字数、字符数』
[zch@localhost ~]$ wc list
 11  36 231 list
 
 # 统计文件数量
 [zch@localhost ~]$ ls | wc -l
12
```
## 双向重定向 tee

![tee 的工作流程示意图](./images/1533716217738.jpg)
> tee 会同时将数据流分送到文件去与屏幕 (screen)；而输出到屏幕的，其实就是 stdout ，可以让下个命令继续处理喔

```tex?linenums
[root@www ~]# tee [-a] file
选项与参数：
-a  ：以累加 (append) 的方式，将数据加入 file 当中！

# 这个范例则是将 ll 的数据存一份到 ~/linux_test/ll.log ，同时屏幕也有输出信息！
[zch@localhost ~]$ ll | tee ~/linux_test/ll.log | cat
总用量 8
-rw-rw-r--. 1 zch zch  37 8月   8 11:30 error.log
drwxrwxr-x. 2 zch zch  36 8月   8 11:30 linux_test
-rw-rw-r--. 1 zch zch 231 8月   8 13:44 list
drwxr-xr-x. 2 zch zch   6 8月   8 09:53 公共
drwxr-xr-x. 2 zch zch   6 8月   8 09:53 模板
[zch@localhost ~]$ cat ~/linux_test/ll.log
总用量 8
-rw-rw-r--. 1 zch zch  37 8月   8 11:30 error.log
drwxrwxr-x. 2 zch zch  36 8月   8 11:30 linux_test
-rw-rw-r--. 1 zch zch 231 8月   8 13:44 list
drwxr-xr-x. 2 zch zch   6 8月   8 09:53 公共
drwxr-xr-x. 2 zch zch   6 8月   8 09:53 模板
```
## 字符转换命令 tr, col, join, paste, expand
## 切割命令 split
## 参数代换 xargs
> xargs 可以读入 stdin 的数据，并且以空格符或断行字符作为分辨，将 stdin 的数据分隔成为 arguments 。 因为是以空格符作为分隔，所以，如果有一些档名或者是其他意义的名词内含有空格符的时候， xargs 可能就会误判了～

```tex?linenums
[root@www ~]# xargs [-0epn] command
选项与参数：
-0  ：如果输入的 stdin 含有特殊字符，例如 `, \, 空格键等等字符时，这个 -0 参数
      可以将他还原成一般字符。这个参数可以用于特殊状态喔！
-e  ：这个是 EOF (end of file) 的意思。后面可以接一个字符串，当 xargs 分析到
      这个字符串时，就会停止继续工作！
-p  ：在运行每个命令的 argument 时，都会询问使用者的意思；
-n  ：后面接次数，每次 command 命令运行时，要使用几个参数的意思。看范例三。
当 xargs 后面没有接任何的命令时，默认是以 echo 来进行输出喔！

# xargs 没有接命令，echo输出
[zch@localhost ~]$ find . -name error.log |xargs
./error.log
# 很多命令其实并不支持管线命令，因此我们可以透过 xargs 来提供该命令引用 standard input 之用
[zch@localhost ~]$ find . -name error.log |xargs ls -l
-rw-rw-r--. 1 zch zch 37 8月   8 11:30 ./error.log
```
## 关于减号-的用途
> 在管线命令当中，常常会使用到前一个命令的 stdout 作为这次的 stdin ， **某些命令需要用到文件名 (例如 tar) 来进行处理时，该 stdin 与 stdout 可以利用减号 "-" 来替代**， 举例来说：
```tex?linenums
[root@www ~]# tar -cvf - /home | tar -xvf -
```

上面这个例子是说：『我将 /home 里面的文件给他打包，但打包的数据不是纪录到文件，而是传送到 stdout； 经过管线后，将 tar -cvf - /home 传送给后面的 tar -xvf - 』。后面的这个 - 则是取用前一个命令的 stdout， 因此，我们就不需要使用 file 了！这是很常见的例子喔！注意注意！

 


