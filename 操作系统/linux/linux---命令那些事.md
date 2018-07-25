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

