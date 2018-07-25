---
title: linux基础---常用命令
tags: linux
grammar_cjkRuby: true
---


## 文件命名规范

``` 
 1. 除了/之外，所有字符都是合法的；
 2. 有些字符最好不用，如空格符、制表符、退格符和字符@#$（）-等
 3. 避免使用.作为普通文件名的第一个字符（以.开头的文件 是隐藏文件）
 4. 大小写敏感
```

## 命令格式

``` 
命令格式： 命令 -选项 参数
eg: ls -la /etc

```

## 文件处理命令 ls


![ls][1]

``` 
权限不同，命令的文件路径也不同

root:
/sbin
/usr/sbin

all users:
/bin
/usr/bin
---------------------------------------------
-a all
-l  long
-d directory

drwxr-xr-x 2 root root

文件类型：
d 目录文件directory
- 二进制文件
l 软链接文件 link

r -read 读、w-write 写 、x-execute 执行

|   rwx   |  r-x   |  r-x   |
| --- | --- | --- |
|  所有者u   |   所属组g  |    其他人o |
|   user  |   group  |  others   |
|    owner |     |     |


drwxr-xr-x     2                       root          root         4096          12-01 20:52                             hh
                    硬链接数           所属者      所属组     文件大小     创建或者最后修改的时间       文件名

文件大小：数据块 block  512字节

```

## 文件处理命令
![cd][2]
![pwd][3]
![touch][4]
![mkdir][5]
![cp][6]
![mv][7]
![rm][8]
![cat][9]
![more][10]
![head][11]
![tail][12]
![ln][13]

``` 
软链接像快捷方式；硬链接同步更新

ls -i      i-inode i节点 
每个文件都有自己的inode，是内核文件调用的数字标示；硬链接与源文件有相同的inode，所以可以同步更新
软链接可以跨分区；硬链接不可以。


```
## 权限管理命令

![chmod][14]
![rwx总结][15]
![chown][16]
![chgrp][17]
![umask][18]
``` 
chmod u+rw
chmod g-w
chmod o=rwx

数字表示权限
r-4,w-2,x-1
eg： rwxr-xr-- 754
        rw-r-x--x  651
		chmod 754 file1
		
查看默认权限：
umask -S


umask 
0002
0---特殊权限位
002---用户权限位，权限掩码值

   777
 - 002
-----------
   775
linux权限规则：缺省创建的文件不能授予可执行x权限（一种安全的机制）

```
## 文件搜索命令
![which][19]
![find1][20]
![find2][21]
![find3][22]
![locate][23]
![updatedb][24]
![grep][25]
``` 
which 可以找到命令的别名记录
whereis 可以找到帮助文档所在位置

find
-name 文件名
* 匹配任意字符 eg：init*
? 匹配单个字符 eg: ?init


-size 文件大小 block数据块 512字节=0.5kb
大于+  find / -size +2048
小于-   find / -size -2048
等于     find / -size 2048

时间
1. 天 ctime、atime、mtime
2. 分钟 cmin、amin、mmin
c-change 改变，表示文件的属性被修改过，eg：所有者、属性、文件名等
a-access 访问
m-modify 修改，表示文件内容被修改过
之内（-），超过（+）
eg: find /etc -mmin -120 120min内文件内容被修改过的文件

-type 文件类型
f  二进制文件 、l 软链接文件、 d 目录

-num  inode
find -num 16

连接符
1. -a and 逻辑与
2. -o or 逻辑或
3. find ----  -exec 命令 {} \;     
    {}  find查询的结果 
	\   转义符，使用符号或者命令本身的含义
	； 

```
## 帮助命令
![man][26]
![info][27]
![whatis][28]

``` 
help 查看shell内置命令
```

## 压缩命令
![gzip][29]
![gunzip][30]
![tar][31]
![tar2][32]
![tar3][33]
![zip][34]
![zip2][35]
![unzip][36]
![bz2][37]
![bunzip2][38]


``` 
gzip
1.只压缩文件
2.不保留文件
3.gunzip gzip -d

tar
1.如果linux机器比较老，不支持打包并且压缩可以先打包再压缩。
    eg：1. tar -cf newdir.tar newdir
	        2. gzip newdir.tar


zip
linux和windows默认通用支持的格式

bz2
压缩比很高
```

## 网络通信命令
![write][39]
![wall][40]
![ping][41]
![ifconfig][42]

## shell应用技巧
![alias][43]
![重定向][44]
![管道][45]
![命令顺序连接符][46]
![命令替换符][47]


  [1]: ./images/1527386208852.jpg
  [2]: ./images/1527388275958.jpg
  [3]: ./images/1527388299428.jpg
  [4]: ./images/1527388358457.jpg
  [5]: ./images/1527388431841.jpg
  [6]: ./images/1527388536205.jpg
  [7]: ./images/1527388655660.jpg
  [8]: ./images/1527388753141.jpg
  [9]: ./images/1527403655637.jpg
  [10]: ./images/1527403694714.jpg
  [11]: ./images/1527403757782.jpg
  [12]: ./images/1527403855367.jpg
  [13]: ./images/1527403895729.jpg
  [14]: ./images/1527405047172.jpg
  [15]: ./images/1527405872776.jpg
  [16]: ./images/1527406042954.jpg
  [17]: ./images/1527406132146.jpg
  [18]: ./images/1527406302526.jpg
  [19]: ./images/1527406689927.jpg
  [20]: ./images/1527406969900.jpg
  [21]: ./images/1527407025954.jpg
  [22]: ./images/1527415579260.jpg
  [23]: ./images/1527416986846.jpg
  [24]: ./images/1527417013390.jpg
  [25]: ./images/1527417073640.jpg
  [26]: ./images/1527417242661.jpg
  [27]: ./images/1527427606911.jpg
  [28]: ./images/1527427655165.jpg
  [29]: ./images/1527428418543.jpg
  [30]: ./images/1527428755782.jpg
  [31]: ./images/1527428806747.jpg
  [32]: ./images/1527428885327.jpg
  [33]: ./images/1527429321307.jpg
  [34]: ./images/1527429405532.jpg
  [35]: ./images/1527429433405.jpg
  [36]: ./images/1527429453452.jpg
  [37]: ./images/1527429542167.jpg
  [38]: ./images/1527429653706.jpg
  [39]: ./images/1527429799307.jpg
  [40]: ./images/1527429852129.jpg
  [41]: ./images/1527429883194.jpg
  [42]: ./images/1527429959130.jpg
  [43]: ./images/1527430836794.jpg
  [44]: ./images/1527431302935.jpg
  [45]: ./images/1527431357371.jpg
  [46]: ./images/1527431462543.jpg
  [47]: ./images/1527431557001.jpg