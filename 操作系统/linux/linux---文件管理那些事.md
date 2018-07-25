---
title: linux---文件管理那些事
tags: linux
grammar_cjkRuby: true
---
# 文件权限
## 改变权限, chmod
文件权限的改变使用的是chmod这个指令，但是，权限的设定方法有两种， 分别可以使用数字或者是符号来进行权限的变更。我们就来谈一谈：

### 数字类型改变文件权限
我们可以使用数字来代表各个权限，各权限的分数对照表如下：
```tex?linenums
r:4
w:2
x:1
```
每种身份(owner/group/others)各自的三个权限(r/w/x)分数是需要累加的，例如当权限为： [-rwxrwx---] 分数则是：
``` tex?linenums
owner = rwx = 4+2+1 = 7
group = rwx = 4+2+1 = 7
others= --- = 0+0+0 = 0
```
所以等一下我们设定权限的变更时，该文件的权限数字就是770啦！变更权限的指令chmod的语法是这样的：

``` tex?linenums
[root@www ~]# chmod [-R] xyz 文件或目录
选项与参数：
xyz : 就是刚刚提到的数字类型的权限属性，为 rwx 属性数值的相加。
-R : 进行递归(recursive)的持续变更，亦即连同次目录下的所有文件都会变更
```
举例：
``` tex?linenums
[root@192 zch]# ls -ld test/
drwxr--r--. 2 root root 19 7月  24 18:10 test/
[root@192 zch]# chmod 755 test
[root@192 zch]# ls -ld test/
drwxr-xr-x. 2 root root 19 7月  24 18:10 test/
```

### 符号类型改变文件权限
还有一个改变权限的方法呦！从之前的介绍中我们可以发现，基本上就九个权限分别是(1)user (2)group (3)others三种身份啦！那么我们就可以藉由u, g, o来代表三种身份的权限！此外， a 则代表 all 亦即全部的身份！那么读写的权限就可以写成r, w, x！也就是可以使用底下的方式来看：

![chmod](./images/1532508958274.png)

举例
``` tex?linenums
[root@192 zch]# ls -ld test/
drwxr-xr-x. 2 root root 19 7月  24 18:10 test/
[root@192 zch]# chmod u=rwx,go=r test
# 注意喔！那个 u=rwx,go=rx 是连在一起的，中间并没有任何空格！
[root@192 zch]# ls -ld test
drwxr--r--. 2 root root 19 7月  24 18:10 test
[root@192 zch]# chmod go+x test
[root@192 zch]# ls -ld test
drwxr-xr-x. 2 root root 19 7月  24 18:10 test
```

## 权限对目录的重要性

 - r (read contents in directory)：
表示具有读取目录结构列表的权限，所以当你具有读取(r)一个目录的权限时，表示你可以查询该目录下的文件名数据。 所以你就可以利用 ls 这个指令将该目录的内容列表显示出来！

- w (modify contents of directory)：
这个可写入的权限对目录来说，是很了不起的！ 因为他表示你具有异动该目录结构列表的权限，也就是底下这些权限：
建立新的文件与目录；
删除已经存在的文件与目录(不论该文件的权限为何！)
将已存在的文件或目录进行更名；
搬移该目录内的文件、目录位置。
总之，目录的w权限就与该目录底下的文件名异动有关就对了啦！

- x (access directory)：
咦！目录的执行权限有啥用途啊？目录只是记录文件名而已，总不能拿来执行吧？没错！目录不可以被执行，目录的x代表的是用户能否进入该目录成为工作目录的用途！ 所谓的工作目录(work directory)就是你目前所在的目录啦！举例来说，当你登入Linux时， 你所在的家目录就是你当下的工作目录。而变换目录的指令是『cd』(change directory)啰！
大致的目录权限概念是这样，底下我们来看几个范例，让你了解一下啥是目录的权限啰！

- 例题：
有个目录的权限如下所示：
drwxr--r--  3  root  root  4096   Jun 25 08:35   .ssh
系统有个账号名称为vbird，这个账号并没有支持root群组，请问vbird对这个目录有何权限？是否可切换到此目录中？
答：
vbird对此目录仅具有r的权限，因此vbird可以查询此目录下的文件名列表。因为vbird不具有x的权限， 因此vbird并不能切换到此目录内！(相当重要的概念！)

- 举例
``` tex?linenums
[root@192 zch]# ls -ld test
drwxr--r--. 2 root root 19 7月  24 18:10 test
[root@192 zch]# su zch
[zch@192 ~]$ ls -ld test
drwxr--r--. 2 root root 19 7月  24 18:10 test
[zch@192 ~]$ ls -l test/
ls: 无法访问test/hh.txt: 权限不够
总用量 0
?????????? ? ? ? ?            ? hh.txt
[zch@192 ~]$ cd test/
bash: cd: test/: 权限不够
```

# 目录配置
## FHS(Filesystem Hierarchy Standard)

- / (root, 根目录)：与开机系统有关；
- /usr (unix software resource)：与软件安装/执行有关；
- /var (variable)：与系统运作过程有关。
- /etc：配置文件
- /bin：重要执行文件
- /dev：所需要的装置文件
- /lib：执行档所需的函式库与核心所需的模块
- /sbin：重要的系统执行文件

# 目录与路径

比较特殊的目录：
``` tex?linenums
.         代表此层目录
..        代表上一层目录
-         代表前一个工作目录
~         代表『目前使用者身份』所在的家目录
~account  代表 account 这个使用者的家目录(account是个帐号名称)
```
## 关於运行文件路径的变量： $PATH
『为什么我可以在任何地方运行/bin/ls这个命令呢？ 』 为什么我在任何目录下输入 ls 就一定可以显示出一些信息而不会说找不到该 /bin/ls 命令呢？ 这是因为环境变量 PATH 的帮助所致呀！
``` tex?linenums
范例：先用root的身份列出搜寻的路径为何？
[root@www ~]# echo $PATH
/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin
:/bin:/usr/sbin:/usr/bin:/root/bin  <==这是同一行！

范例：用vbird的身份列出搜寻的路径为何？
[root@www ~]# su - vbird
[vbird@www ~]# echo $PATH
/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/vbird/bin
# 仔细看，一般用户vbird的PATH中，并不包含任何『sbin』的目录存在喔！
```
PATH(一定是大写)这个变量的内容是由一堆目录所组成的，每个目录中间用冒号(:)来隔开， 每个目录是有『顺序』之分的。

- 不同身份使用者默认的PATH不同，默认能够随意运行的命令也不同(如root与vbird)；
- PATH是可以修改的，所以一般使用者还是可以透过修改PATH来运行某些位於/sbin或/usr/sbin下的命令来查询；
- 使用绝对路径或相对路径直接指定某个命令的档名来运行，会比搜寻PATH来的正确；
- 命令应该要放置到正确的目录下，运行才会比较方便；
- 本目录(.)最好不要放到PATH当中。
# 文件与目录管理
## 修改文件时间与建置新档： touch


# 参考文档
- [鸟哥的linux私房菜](http://cn.linux.vbird.org/linux_basic/linux_basic.php)