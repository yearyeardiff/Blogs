---
title: linux---shell那些事
tags: linux,shell
grammar_cjkRuby: true
---

# Shell 的变量功能
## 变量的取用与配置
### 变量的取用: echo
举例
``` tex?linenums
[zch@192 ~]$ echo $var
[zch@192 ~]$ var=123
[zch@192 ~]$ echo $var
123
[zch@192 ~]$ echo ${var}
123
```
### 变量的配置守则
- 变量与变量内容以一个等号『=』来连结，如下所示： 
『myname=VBird』
- 等号两边不能直接接空格符，如下所示为错误： 
『myname = VBird』或『myname=VBird Tsai』
- 变量名称只能是英文字母与数字，但是开头字符不能是数字，如下为错误： 
『2myname=VBird』
- 变量内容若有空格符可使用双引号『"』或单引号『'』将变量内容结合起来，但
1.**双引号内的特殊字符如 $ 等，可以保有原本的特性**，如下所示：
『var="lang is $LANG"』则『echo $var』可得『lang is en_US』
2.单引号内的特殊字符则仅为一般字符 (纯文本)，如下所示：
『var='lang is $LANG'』则『echo $var』可得『lang is $LANG』
- 可用跳脱字符『 \ 』将特殊符号(如 [Enter], $, \, 空格符, '等)变成一般字符；
- 在一串命令中，还需要藉由其他的命令提供的信息，**可以使用反单引号『\`命令\`』或 『$(命令)』**。特别注意，那个\` 是键盘上方的数字键 1 左边那个按键，而不是单引号！ 例如想要取得核心版本的配置：
『version=$(uname -r)』再『echo $version』可得『2.6.18-128.el5』
- 若该变量为扩增变量内容时，则可用 "$变量名称" 或 ${变量} 累加内容，如下所示：
『PATH="$PATH":/home/bin』
- 若该变量需要在其他子程序运行，则需要以 **export 来使变量变成环境变量**：
『export PATH』
- 通常大写字符为系统默认变量，自行配置变量可以使用小写字符，方便判断 (纯粹依照使用者兴趣与嗜好) ；
- 取消变量的方法为使用 unset ：『unset 变量名称』例如取消 myname 的配置：
『unset myname』

举例
```tex?linenums
[zch@192 ~]$ varStr="var string"
[zch@192 ~]$ echo $varStr 
var string
#在字符串中引用变量
[zch@192 ~]$ concat="$varStr"1
[zch@192 ~]$ echo $concat
var string1
[zch@192 ~]$ concat=${varStr}2
[zch@192 ~]$ echo $concat 
var string2
#使用命令获取信息
[zch@192 ~]$ properties=$(ls -ld test)
[zch@192 ~]$ echo $properties 
drwxr-xr-x. 2 root root 31 7月 27 10:37 test
#注销变量
[zch@192 ~]$ unset varStr 
[zch@192 ~]$ echo $varStr

[zch@192 ~]$ 

#export
[root@www ~]# name=VBird
[root@www ~]# bash        <==进入到所谓的子程序
[root@www ~]# echo $name  <==子程序：再次的 echo 一下；
       <==嘿嘿！并没有刚刚配置的内容喔！
[root@www ~]# exit        <==子程序：离开这个子程序
[root@www ~]# export name
[root@www ~]# bash        <==进入到所谓的子程序
[root@www ~]# echo $name  <==子程序：在此运行！
VBird  <==看吧！出现配置值了！
[root@www ~]# exit        <==子程序：离开这个子程序
```

## 环境变量的功能
### 用 env 观察环境变量与常见环境变量说明
```tex?linenums
[zch@192 ~]$ env
XDG_SESSION_ID=1
HOSTNAME=192.168.186.128
SELINUX_ROLE_REQUESTED=
SHELL=/bin/bash
TERM=vt100
HISTSIZE=1000
SSH_CLIENT=192.168.186.1 56338 22
SELINUX_USE_CURRENT_RANGE=
...
```
env 是 environment (环境) 的简写啊，上面的例子当中，是列出来所有的环境变量。当然，如果使用 export 也会是一样的内容.
### 用 set 观察所有变量 (含环境变量与自定义变量)
```tex?linenums
[root@www ~]# set
BASH=/bin/bash           <== bash 的主程序放置路径
BASH_VERSINFO=([0]="3" [1]="2" [2]="25" [3]="1" [4]="release" 
[5]="i686-redhat-linux-gnu")      <== bash 的版本啊！
BASH_VERSION='3.2.25(1)-release'  <== 也是 bash 的版本啊！
COLORS=/etc/DIR_COLORS.xterm      <== 使用的颜色纪录文件
COLUMNS=115              <== 在目前的终端机环境下，使用的字段有几个字符长度
HISTFILE=/root/.bash_history      <== 历史命令记录的放置文件，隐藏档
HISTFILESIZE=1000        <== 存起来(与上个变量有关)的文件之命令的最大纪录笔数。
HISTSIZE=1000            <== 目前环境下，可记录的历史命令最大笔数。
HOSTTYPE=i686            <== 主机安装的软件主要类型。我们用的是 i686 兼容机器软件
IFS=$' \t\n'             <== 默认的分隔符
LINES=35                 <== 目前的终端机下的最大行数
MACHTYPE=i686-redhat-linux-gnu    <== 安装的机器类型
MAILCHECK=60             <== 与邮件有关。每 60 秒去扫瞄一次信箱有无新信！
OLDPWD=/home             <== 上个工作目录。我们可以用 cd - 来取用这个变量。
OSTYPE=linux-gnu         <== 操作系统的类型！
PPID=20025               <== 父程序的 PID (会在后续章节才介绍)
PS1='[\u@\h \W]\$ '      <== PS1 就厉害了。这个是命令提示字符，也就是我们常见的
                             [root@www ~]# 或 [dmtsai ~]$ 的配置值啦！可以更动的！
PS2='> '                 <== 如果你使用跳脱符号 (\) 第二行以后的提示字符也
name=VBird               <== 刚刚配置的自定义变量也可以被列出来喔！
$                        <== 目前这个 shell 所使用的 PID
?                        <== 刚刚运行完命令的回传值。
```
- $：(关于本 shell 的 PID)
钱字号本身也是个变量喔！这个咚咚代表的是『目前这个 Shell 的线程代号』，亦即是所谓的 PID (Process ID)。 更多的程序观念，我们会在第四篇的时候提及。想要知道我们的 shell 的 PID ，就可以用：『 echo $$ 』即可！出现的数字就是你的 PID 号码。
- ?：(关于上个运行命令的回传值)
这个变量是：『上一个运行的命令所回传的值』， 上面这句话的重点是『上一个命令』与『回传值』两个地方。当我们运行某些命令时， 这些命令都会回传一个运行后的代码。一般来说，**如果成功的运行该命令， 则会回传一个 0 值**，如果运行过程发生错误，就会回传『错误代码』才对！一般就是以非为 0 的数值来取代。 我们以底下的例子来看看：
```tex?linenums
[root@www ~]# echo $SHELL
/bin/bash                                  <==可顺利显示！没有错误！
[root@www ~]# echo $?
0                                          <==因为没问题，所以回传值为 0
[root@www ~]# 12name=VBird
-bash: 12name=VBird: command not found     <==发生错误了！bash回报有问题
[root@www ~]# echo $?
127                                        <==因为有问题，回传错误代码(非为0)
# 错误代码回传值依据软件而有不同，我们可以利用这个代码来搜寻错误的原因喔！
[root@www ~]# echo $?
0
# 咦！怎么又变成正确了？这是因为 "?" 只与『上一个运行命令』有关，
# 所以，我们上一个命令是运行『 echo $? 』，当然没有错误，所以是 0 没错！
```
### export： 自定义变量转成环境变量
谈了 env 与 set 现在知道有所谓的环境变量与自定义变量，那么这两者之间有啥差异呢？其实这两者的差异在于『 该变量是否会被子程序所继续引用』.
当你登陆 Linux 并取得一个 bash 之后，你的 bash 就是一个独立的程序，被称为 PID 的就是。 接下来你在这个 bash 底下所下达的任何命令都是由这个 bash 所衍生出来的，那些被下达的命令就被称为子程序了。 我们可以用底下的图示来简单的说明一下父程序与子程序的概念：

![程序相关性示意图](./images/1532924388282.png)

```tex?linenums
[root@www ~]# export 变量名称

[zch@192 ~]$ export
declare -x HISTCONTROL="ignoredups"
declare -x HISTSIZE="1000"
declare -x HOME="/home/zch"
declare -x HOSTNAME="192.168.186.128"
declare -x LANG="zh_CN.UTF-8"
declare -x LESSOPEN="||/usr/bin/lesspipe.sh %s"
declare -x LOGNAME="zch"
...
```
那如何将环境变量转成自定义变量呢？可以使用本章后续介绍的 declare 呢！

在学理方面，为什么环境变量的数据可以被子程序所引用呢？这是因为内存配置的关系！理论上是这样的：

- 当启动一个 shell，操作系统会分配一记忆区块给 shell 使用，此内存内之变量可让子程序取用
- 若在父程序利用 export 功能，可以让自定义变量的内容写到上述的记忆区块当中(环境变量)；
- 当加载另一个 shell 时 (亦即启动子程序，而离开原本的父程序了)，子 shell 可以将父 shell 的环境变量所在的记忆区块导入自己的环境变量区块当中。

## declare / typeset
```tex?linenums
[root@www ~]# declare [-aixr] variable
选项与参数：
-a  ：将后面名为 variable 的变量定义成为数组 (array) 类型
-i  ：将后面名为 variable 的变量定义成为整数数字 (integer) 类型
-x  ：用法与 export 一样，就是将后面的 variable 变成环境变量；
-r  ：将变量配置成为 readonly 类型，该变量不可被更改内容，也不能 unset

范例一：让变量 sum 进行 100+300+50 的加总结果
[root@www ~]# sum=100+300+50
[root@www ~]# echo $sum
100+300+50  <==咦！怎么没有帮我计算加总？因为这是文字型态的变量属性啊！
[root@www ~]# declare -i sum=100+300+50
[root@www ~]# echo $sum
450         
```
由于在默认的情况底下， bash 对于变量有几个基本的定义：
- 变量类型默认为『字符串』，所以若不指定变量类型，则 1+2 为一个『字符串』而不是『计算式』。 所以上述第一个运行的结果才会出现那个情况的；
- bash 环境中的数值运算，默认最多仅能到达整数形态，所以 1/3 结果是 0；

```tex?linenums
范例二：将 sum 变成环境变量
[root@www ~]# declare -x sum
[root@www ~]# export | grep sum
declare -ix sum="450"  <==果然出现了！包括有 i 与 x 的宣告！

范例三：让 sum 变成只读属性，不可更动！
[root@www ~]# declare -r sum
[root@www ~]# sum=tesgting
-bash: sum: readonly variable  <==老天爷～不能改这个变量了！

范例四：让 sum 变成非环境变量的自定义变量吧！
[root@www ~]# declare +x sum  <== 将 - 变成 + 可以进行『取消』动作
[root@www ~]# declare -p sum  <== -p 可以单独列出变量的类型
declare -ir sum="450" <== 看吧！只剩下 i, r 的类型，不具有 x 啰！
```

## 命令别名配置： alias, unalias
```tex?linenums
[zch@192 ~]$ alias lm ='ls -al|more'
[zch@192 ~]$ lm
总用量 72
drwx------. 18 zch  zch  4096 7月  27 10:36 .
drwxr-xr-x.  3 root root   16 6月  22 06:48 ..
-rw-------.  1 zch  zch  3072 7月  30 11:23 .bash_history
-rw-r--r--.  1 zch  zch    18 11月 20 2015 .bash_logout
[zch@192 ~]$ alias
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias lm='ls -al |more'
alias ls='ls --color=auto'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'

[zch@192 ~]$ unalias lm
```