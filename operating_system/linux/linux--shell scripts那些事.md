---
title: linux--shell scripts那些事
tags: linux,shell
grammar_cjkRuby: true
---


# 什么是 Shell Script
> shell script 是利用 shell 的功能所写的一个『程序 (program)』，这个程序是使用纯文字档，将一些 shell 的语法与命令(含外部命令)写在里面， 搭配正规表示法、管线命令与数据流重导向等功能，以达到我们所想要的处理目的。

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

## hello,wrold
- 代码：
```tex?linenums
#!/bin/bash
# Program:
#       This program shows "Hello World!" in your screen.
# History:
# 2018/08/08	zch	First release
PATH=${PATH}:~/bin
export PATH
echo "Hello World! \a \n"
exit 0
```

-  运行结果：
```tex?linenums
~/github_repo/Blogs/operating_system/linux/shell_bin(temp*) » sh sh_hellowrold.sh
Hello World!
```

上面的写法当中，鸟哥主要将整个程序的撰写分成数段，大致是这样：

- 第一行 #!/bin/bash 在宣告这个 script 使用的 shell 名称：
  因为我们使用的是 bash ，所以，必须要以『 #!/bin/bash 』来宣告这个文件内的语法使用 bash 的语法！那么当这个程序被运行时，他就能够加载 bash 的相关环境配置档 (一般来说就是 non-login shell 的 ~/.bashrc)， 并且运行 bash 来使我们底下的命令能够运行！这很重要的！(在很多状况中，如果没有配置好这一行， 那么该程序很可能会无法运行，因为系统可能无法判断该程序需要使用什么 shell 来运行啊！)

- 程序内容的说明：
  整个 script 当中，除了第一行的『 #! 』是用来宣告 shell 的之外，其他的 # 都是『注解』用途！ 所以上面的程序当中，第二行以下就是用来说明整个程序的基本数据。一般来说， 建议你一定要养成说明该 script 的：1. 内容与功能； 2. 版本资讯； 3. 作者与联络方式； 4. 建档日期；5. 历史纪录 等等。这将有助於未来程序的改写与 debug 呢！

- 主要环境变量的宣告：
  建议务必要将一些重要的环境变量配置好，鸟哥个人认为， PATH 与 LANG (如果有使用到输出相关的资讯时) 是当中最重要的！ 如此一来，则可让我们这支程序在进行时，可以直接下达一些外部命令，而不必写绝对路径呢！比较好啦！

- 主要程序部分
  就将主要的程序写好即可！在这个例子当中，就是 echo 那一行啦！

- 运行成果告知 (定义回传值)
  是否记得我们在第十一章里面要讨论一个命令的运行成功与否，可以使用 $? 这个变量来观察～ 那么我们也可以利用 exit 这个命令来让程序中断，并且回传一个数值给系统。 在我们这个例子当中，鸟哥使用 exit 0 ，这代表离开 script 并且回传一个 0 给系统， 所以我运行完这个 script 后，若接著下达 echo $? 则可得到 0 的值喔！ 更聪明的读者应该也知道了，呵呵！利用这个 exit n (n 是数字) 的功能，我们还可以自订错误信息， 让这支程序变得更加的 smart 呢！

### 简单的例子
- 对谈式脚本：变量内容由使用者决定
```tex?linenums
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
```

- 随日期变化：利用 date 进行文件的创建

```tex?linenums
# 1. 让使用者输入文件名称，并取得 fileuser 这个变量；

echo -e "I will use 'touch' command to create 3 files." # 纯粹显示资讯
read -p "Please input your filename: " fileuser         # 提示使用者输入

# 2. 为了避免使用者随意按 Enter ，利用变量功能分析档名是否有配置？
filename=${fileuser:-"filename"}           # 开始判断有否配置档名

# 3. 开始利用 date 命令来取得所需要的档名了；
date1=$(date --date='2 days ago' +%Y%m%d)  # 前两天的日期
date2=$(date --date='1 days ago' +%Y%m%d)  # 前一天的日期
date3=$(date +%Y%m%d)                      # 今天的日期
file1=${filename}${date1}                  # 底下三行在配置档名
file2=${filename}${date2}
file3=${filename}${date3}

# 4. 将档名创建吧！
touch "$file1"                             # 底下三行在创建文件
touch "$file2"
touch "$file3"
```

- 数值运算：简单的加减乘除
```tex?linenums
echo -e "You SHOULD input 2 numbers, I will cross them! \n"
read -p "first number:  " firstnu
read -p "second number: " secnu
total=$(($firstnu*$secnu))
echo -e "\nThe result of $firstnu x $secnu is ==> $total"
```
在数值的运算上，我们可以使用『 declare -i total=$firstnu * $secnu 』 也可以使用上面的方式来进行！基本上，鸟哥比较建议使用这样的方式来进行运算：
`var=$((运算内容))`

## script 的运行方式差异 (source, sh script, ./script)
### 利用直接运行的方式来运行 script
当使用直接命令下达 (不论是绝对路径/相对路径还是 $PATH 内)，或者是利用 bash (或 sh) 来下达脚本时， 该 script 都会使用一个新的 bash 环境来运行脚本内的命令！也就是说，使用者种运行方式时， 其实 script 是在子程序的 bash 内运行的！我们在谈到 export 的功能时，曾经就父程序/子程序谈过一些概念性的问题， 重点在於：『当子程序完成后，在子程序内的各项变量或动作将会结束而不会传回到父程序中』！ 这是什么意思呢？

举例：
```bash?linenums
[root@www scripts]# echo $firstname $lastname
    <==确认了，这两个变量并不存在喔！
[root@www scripts]# sh sh02.shn #见：简单例子  对谈式脚本
Please input your first name: VBird <==这个名字是鸟哥自己输入的
Please input your last name:  Tsai 

Your full name is: VBird Tsai      <==看吧！在 script 运行中，这两个变量有生效
[root@www scripts]# echo $firstname $lastname
    <==事实上，这两个变量在父程序的 bash 中还是不存在的！
```

![sh02.sh 在子程序中运行]( ./images/1533808781401.jpg )


### 利用 source 来运行脚本：在父程序中运行
```tex?linenums
[root@www scripts]# source sh02.sh
Please input your first name: VBird
Please input your last name:  Tsai

Your full name is: VBird Tsai
[root@www scripts]# echo $firstname $lastname
VBird Tsai  <==嘿嘿！有数据产生喔！
```

![sh02.sh 在父程序中运行](./images/1533808931718.jpg)

# 善用判断式
## 命令运行的判断依据： ; , &&, ||
- cmd ; cmd (不考虑命令相关性的连续命令下达)
- $? (命令回传值) 与 && 或 ||
>若前一个命令运行的结果为正确，在 Linux 底下会回传一个 $? = 0 的值

|命令下达情况|	说明|
|---|---|
|cmd1 && cmd2	|1. 若 cmd1 运行完毕且正确运行($?=0)，则开始运行 cmd2。2. 若 cmd1 运行完毕且为错误 ($?≠0)，则 cmd2 不运行。|
|cmd1 \|\| cmd2	|1. 若 cmd1 运行完毕且正确运行($?=0)，则 cmd2 不运行。2. 若 cmd1 运行完毕且为错误 ($?≠0)，则开始运行 cmd2。|

## 利用 test 命令的测试功能

```tex?linenums
# 我要检查 /dmtsai 是否存在时,如果存在打印exist，不存在打印Not exist
[zch@localhost shell_bin]$ test -e /dmtsai && echo "exist" || echo "Not exist"
Not exist
```


|测试的标志	|代表意义|
|---|---|
|1. 关於某个档名的『文件类型』判断，如 test -e filename 表示存在否|
|-e|	该『档名』是否存在？(常用)|
|-f|	该『档名』是否存在且为文件(file)？(常用)|
|-d	|该『档名』是否存在且为目录(directory)？(常用)|
|-b	|该『档名』是否存在且为一个 block device 装置？|
|-c	|该『档名』是否存在且为一个 character device 装置？|
|-S	|该『档名』是否存在且为一个 Socket 文件？|
|-p	|该『档名』是否存在且为一个 FIFO (pipe) 文件？|
|-L	|该『档名』是否存在且为一个连结档？|
|2. 关於文件的权限侦测，如 test -r filename 表示可读否 (但 root 权限常有例外)|
|-r	|侦测该档名是否存在且具有『可读』的权限？|
|-w|	侦测该档名是否存在且具有『可写』的权限？|
|-x	|侦测该档名是否存在且具有『可运行』的权限？|
|-u	|侦测该档名是否存在且具有『SUID』的属性？|
|-g	|侦测该档名是否存在且具有『SGID』的属性？|
|-k	|侦测该档名是否存在且具有『Sticky bit』的属性？|
|-s	|侦测该档名是否存在且为『非空白文件』？|
|3. 两个文件之间的比较，如： test file1 -nt file2|
|-nt|	(newer than)判断 file1 是否比 file2 新|
|-ot|	(older than)判断 file1 是否比 file2 旧|
|-ef|	判断 file1 与 file2 是否为同一文件，可用在判断 hard link 的判定上。 主要意义在判定，两个文件是否均指向同一个 inode 哩！|
|4. 关於两个整数之间的判定，例如 test n1 -eq n2|
|-eq|	两数值相等 (equal)|
|-ne|	两数值不等 (not equal)|
|-gt|	n1 大於 n2 (greater than)|
|-lt	|n1 小於 n2 (less than)|
|-ge	|n1 大於等於 n2 (greater than or equal)|
|-le|	n1 小於等於 n2 (less than or equal)|
|5. 判定字串的数据|
|test -z string	|判定字串是否为 0 ？若 string 为空字串，则为 true|
|test -n string	|判定字串是否非为 0 ？若 string 为空字串，则为 false。注： -n 亦可省略|
|test str1 = str2|	判定 str1 是否等於 str2 ，若相等，则回传 true|
|test str1 != str2|	判定 str1 是否不等於 str2 ，若相等，则回传 false|
|6. 多重条件判定，例如： test -r filename -a -x filename|
|-a	|(and)两状况同时成立！例如 test -r file -a -x file，则 file 同时具有 r 与 x 权限时，才回传 true。|
|-o	|(or)两状况任何一个成立！例如 test -r file -o -x file，则 file 具有 r 或 x 权限时，就可回传 true。|
|!	|反相状态，如 test ! -x file ，当 file 不具有 x 时，回传 true|

- 举例
```bash?linenums
#!/bin/bash
echo -e 'plz input filename, then i will check its type and permissions\n'
read -p 'input a filename:' filename
# 文件名是否为空
test -z $filename && echo -e 'filename cant be empty' && exit 0
# 文件是否存在
test ! -e $filename && echo -e '$filename not exists' && exit 0
# 判断文件类型
test -f $filename && filetype='regular file'
test -d $filename && filetype='directory'
# 判断文件属性
test -r $filename && permission="$permission readable"
test -w $filename && permission="$permission writable"
test -x $filename && permission="$permission executalbe"

# 输出结果
echo -e "$filename is a $filetype"
echo -e "and its permission are:$permission"
```

## 利用判断符号 [ ]

>如果要在 bash 的语法当中使用中括号作为 shell 的判断式时，必须要注意中括号的两端需要有空白字节来分隔喔！ 假设我空白键使用『□』符号来表示，那么，在这些地方你都需要有空白键：

``` tex?linenums
[  "$HOME"  ==  "$MAIL"  ]
[□"$HOME"□==□"$MAIL"□]
 ↑       ↑  ↑       ↑
 ```
 
 注意事项：
 
- 在中括号 [] 内的每个组件都需要有空白键来分隔；
- 在中括号内的变量，最好都以双引号括号起来；
- 在中括号内的常数，最好都以单或双引号括号起来。
 
 为什么要这么麻烦啊？直接举例来说，假如我配置了 name="VBird Tsai" ，然后这样判定：
```tex?linenums
[zch@localhost shell_bin]$ name="hello hello hello "
[zch@localhost shell_bin]$ [ $name == "hello" ]
-bash: [: 参数太多
# 变量加上双引号就不会报错
[zch@localhost shell_bin]$ [ "$name" == "hello" ]
[zch@localhost shell_bin]$
```
见鬼了！怎么会发生错误啊？bash 还跟我说错误是由於『太多参数 (arguments)』所致！ 为什么呢？因为 $name 如果没有使用双引号刮起来，那么上面的判定式会变成：
`[ VBird Tsai == "VBird" ]`
上面肯定不对嘛！因为一个判断式仅能有两个数据的比对，上面 VBird 与 Tsai 还有 "VBird" 就有三个数据！ 这不是我们要的！我们要的应该是底下这个样子：
`[ "VBird Tsai" == "VBird" ]`

- 举例
```bash?linenums
#!/bin/bash
echo -e "if you input y/Y,i will say OK,if you input n/N, i will say Oh,No\n"
read -p 'plz input y/n:' yn
[ "$yn" == "y" -o "$yn" == "Y" ] && echo -e "OK,boy" && exit 0;
[ "$yn" == "n" -o "$yn" == "N" ] && echo -e "Oh,No" && exit 0;
echo -e "bad boy ,i cant recognize what you input"
```

## Shell script 的默认变量($0, $1...)
>我们知道命令可以带有选项与参数，例如 ls -la 可以察看包含隐藏档的所有属性与权限。那么 shell script 能不能在脚本档名后面带有参数呢？
>script 是怎么达成这个功能的呢？其实 script 针对参数已经有配置好一些变量名称了！对应如下：

```tex?linenums
/path/to/scriptname  opt1  opt2  opt3  opt4 
       $0             $1    $2    $3    $4
```
这样够清楚了吧？运行的脚本档名为 $0 这个变量，第一个接的参数就是 $1 啊～ 所以，只要我们在 script 里面善用 $1 的话，就可以很简单的立即下达某些命令功能了！除了这些数字的变量之外， 我们还有一些较为特殊的变量可以在 script 内使用来呼叫这些参数喔！

- $# ：代表后接的参数『个数』，以上表为例这里显示为『 4 』；
- $@ ：代表『 "$1" "$2" "$3" "$4" 』之意，每个变量是独立的(用双引号括起来)；
- $\* ：代表『 "$1c$2c$3c$4" 』，其中 c 为分隔字节，默认为空白键， 所以本例中代表『 "$1 $2 $3 $4" 』之意。

```tex?linenums
[zch@localhost shell_bin]$ sh sh_07.sh one two three
$0 is: sh_07.sh
$# is: 3
$@ is: one two three
$1 is: one
$2 is: two
[zch@localhost shell_bin]$ cat sh_07.sh
#!/bin/bash
echo -e '$0 is:' $0
echo -e '$# is:' $#
echo -e '$@ is:' $@
echo -e '$1 is:' $1
echo -e '$2 is:' $2
```

## shift：造成参数变量号码偏移
```bash?linenums

[root@www scripts]# vi sh08.sh
#!/bin/bash

echo "Total parameter number is ==> $#"
echo "Your whole parameter is   ==> '$@'"
shift   # 进行第一次『一个变量的 shift 』
echo "Total parameter number is ==> $#"
echo "Your whole parameter is   ==> '$@'"
shift 3 # 进行第二次『三个变量的 shift 』
echo "Total parameter number is ==> $#"
echo "Your whole parameter is   ==> '$@'"
```
这玩意的运行成果如下：
```bash?linenums
[root@www scripts]# sh sh08.sh one two three four five six <==给予六个参数
Total parameter number is ==> 6   <==最原始的参数变量情况
Your whole parameter is   ==> 'one two three four five six'
Total parameter number is ==> 5   <==第一次偏移，看底下发现第一个 one 不见了
Your whole parameter is   ==> 'two three four five six'
Total parameter number is ==> 2   <==第二次偏移掉三个，two three four 不见了
Your whole parameter is   ==> 'five six'
```
光看结果你就可以知道啦，那个 shift 会移动变量，而且 shift 后面可以接数字，代表拿掉最前面的几个参数的意思。 上面的运行结果中，第一次进行 shift 后他的显示情况是『 one two three four five six』，所以就剩下五个啦！第二次直接拿掉三个，就变成『 two three four five six 』啦！

# 条件判断式
## 利用 if .... then

- 单层、简单条件判断式
```tex?linenums
if [ 条件判断式 ]; then
	当条件判断式成立时，可以进行的命令工作内容；
fi   <==将 if 反过来写，就成为 fi 啦！结束 if 之意！
```

- 多重、复杂条件判断式
```tex?linenums
# 一个条件判断，分成功进行与失败进行 (else)
if [ 条件判断式 ]; then
	当条件判断式成立时，可以进行的命令工作内容；
else
	当条件判断式不成立时，可以进行的命令工作内容；
fi

# 多个条件判断 (if ... elif ... elif ... else) 分多种不同情况运行
if [ 条件判断式一 ]; then
	当条件判断式一成立时，可以进行的命令工作内容；
elif [ 条件判断式二 ]; then
	当条件判断式二成立时，可以进行的命令工作内容；
else
	当条件判断式一与二均不成立时，可以进行的命令工作内容；
fi
```

我还可以有多个中括号来隔开喔！而括号与括号之间，则以 && 或 || 来隔开，他们的意义是：

- && 代表 AND ；
- || 代表 or ；

所以，在使用中括号的判断式中， && 及 || 就与命令下达的状态不同了。举例来说：
`[ "$yn" == "Y" -o "$yn" == "y" ]`
上式可替换为
`[ "$yn" == "Y" ] || [ "$yn" == "y" ]`
之所以这样改，很多人是习惯问题！很多人则是喜欢一个中括号仅有一个判别式的原因。


 - 举例 1
```bash?linenums
#!/bin/bash
echo -e "if you input y/Y,i will say OK,if you input n/N, i will say Oh,No\n"
read -p 'plz input y/n:' yn

if [ "$yn" == "y" ] || [ "$yn" == "Y" ];then
  echo -e "OK,boy"
  exit 0
fi

if [ "$yn" == "n" ] || [ "$yn" == "N" ];then
  echo -e "Oh,no"
  exit 0
fi

echo -e "bad boy ,i cannot recognize what you input"
```

- 举例2
```bash?linenums
#!/bin/bash
echo -e "if you input y/Y,i will say OK,if you input n/N, i will say Oh,No\n"
read -p 'plz input y/n:' yn

if [ "$yn" == "y" ] || [ "$yn" == "Y" ];then
  echo -e "OK,boy"
  exit 0
elif [ "$yn" == "n" ] || [ "$yn" == "N" ];then
  echo -e "Oh,no"
  exit 0
else
  echo -e "bad boy ,i cannot recognize what you input"
fi
```

## 利用 case ..... esac 判断

```tex?linenums
case  $变量名称 in   <==关键字为 case ，还有变量前有钱字号
  "第一个变量内容")   <==每个变量内容建议用双引号括起来，关键字则为小括号 )
	程序段
	;;            <==每个类别结尾使用两个连续的分号来处理！
  "第二个变量内容")
	程序段
	;;
  *)                  <==最后一个变量内容都会用 * 来代表所有其他值
	不包含第一个变量内容与第二个变量内容的其他程序运行段
	exit 1
	;;
esac                  <==最终的 case 结尾！『反过来写』思考一下！
```

- 举例
```bash?linenums
#/bin/bash
case $1 in
  "hello")
	echo "Hello, how are you ?"
	;;
  "")
	echo "You MUST input parameters, ex> {$0 someword}"
	;;
  *)   # 其实就相当於万用字节，0~无穷多个任意字节之意！
	echo "Usage $0 {hello}"
	;;
esac
```

## 利用 function 功能
```tex?linenums
function fname() {
	程序段
}
```

- 举例
```bash?linenums
function funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73
```
运行结果：
```bash?linenums
[zch@localhost shell_bin]$ sh sh_function.sh 9 9 9 9
第一个参数为 1 !
第二个参数为 2 !
第十个参数为 10 !
第十个参数为 34 !
第十一个参数为 73 !
参数总数有 11 个!
作为一个字符串输出所有参数 1 2 3 4 5 6 7 8 9 34 73 !
```
[shell function](http://www.runoob.com/linux/linux-shell-func.html)

# 回圈 (loop)
## while/until
```tex?linenums
while [ condition ]  <==中括号内的状态就是判断式
do            <==do 是回圈的开始！
	程序段落
done 
```

```tex?linenums
until [ condition ]
do
	程序段落
done
```

- 举例1
```bash?linenums

until [ "$yn" == "yes" -o "$yn" == "YES" ]
do
	read -p "Please input yes/YES to stop this program: " yn
done
echo "OK! you input the correct answer."
```

- 举例2

```bash?linenums
#/bin/bash

while [ "$yn" != "yes" ] && [ "$yn" != "y" ]
do
	read -p "please input yes/y to stop this programe:" yn
done
echo -e "this programe stopped!!!"
```

- 举例3

```bash?linenums
#/bin/bash

s=0
i=0
while [ "$i" != "100" ]
do
	i=$(($i+1))
	s=$(($s+$i))
done

echo -e "the result is:$s"
```
## for
```bash?linenums
for var in con1 con2 con3 ...
do
	程序段
done
```
```bash?linenums
for (( 初始值; 限制值; 运行步阶 ))
do
	程序段
done

#这种语法适合於数值方式的运算当中，在 for 后面的括号内的三串内容意义为：

#1. 初始值：某个变量在回圈当中的起始值，直接以类似 i=1 配置好；
#2. 限制值：当变量的值在这个限制值的范围内，就继续进行回圈。例如 i<=100；
#3. 运行步阶：每作一次回圈时，变量的变化量。例如 i=i+1。
```

- 举例1

```bash?linenums
#/bin/bash

# 1. 先看看这个目录是否存在啊？
read -p "Please input a directory: " dir
if [ "$dir" == "" -o ! -d "$dir" ]; then
	echo "The $dir is NOT exist in your system."
	exit 1
fi

# 2. 开始测试文件罗～
filelist=$(ls $dir)        # 列出所有在该目录下的文件名称
for filename in $filelist
do
	perm=""
	test -r "$dir/$filename" && perm="$perm readable"
	test -w "$dir/$filename" && perm="$perm writable"
	test -x "$dir/$filename" && perm="$perm executable"
	echo "The file $dir/$filename's permission is $perm "
done
```
- 举例2

```bash?linenums
#!/bin/bash

read -p "Please input a number, I will count for 1+2+...+your_input: " nu

s=0
for (( i=1; i<=$nu; i=i+1 ))
do
	s=$(($s+$i))
done
echo "The result of '1+2+3+...+$nu' is ==> $s"
```

# 参考
[鸟哥的linux私房菜](http://cn.linux.vbird.org/linux_basic/linux_basic.php)
