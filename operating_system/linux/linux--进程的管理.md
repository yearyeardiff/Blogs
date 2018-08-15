---
title: linux--进程的管理
tags: linux
grammar_cjkRuby: true
---

# 查看进程

## ps ：将某个时间点的程序运行情况撷取下来
```bash?linenums
[root@www ~]# ps aux  <==观察系统所有的程序数据
[root@www ~]# ps -lA  <==也是能够观察所有系统的数据
[root@www ~]# ps axjf <==连同部分程序树状态
选项与参数：
-A  ：所有的 process 均显示出来，与 -e 具有同样的效用；
-a  ：不与 terminal 有关的所有 process ；
-u  ：有效使用者 (effective user) 相关的 process ；
x   ：通常与 a 这个参数一起使用，可列出较完整资讯。
输出格式规划：
l   ：较长、较详细的将该 PID 的的资讯列出；
j   ：工作的格式 (jobs format)
-f  ：做一个更为完整的输出。
```

### 仅观察自己的 bash 相关程序： ps -l
```bash?linenums
[root@localhost zch]# ps -l
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0 109291 108919  0  80   0 - 52481 wait   pts/1    00:00:00 su
4 S     0 109296 109291  0  80   0 - 29167 wait   pts/1    00:00:00 bash
0 R     0 109325 109296  0  80   0 - 34343 -      pts/1    00:00:00 ps
```

- F：代表这个程序旗标 (process flags)，说明这个程序的总结权限，常见号码有：
	- 若为 4 表示此程序的权限为 root ；
	- 若为 1 则表示此子程序仅进行复制(fork)而没有实际运行(exec)。
- S：代表这个程序的状态 (STAT)，主要的状态有：
	- R (Running)：该程序正在运行中；
	- S (Sleep)：该程序目前正在睡眠状态(idle)，但可以被唤醒(signal)。
	- D ：不可被唤醒的睡眠状态，通常这支程序可能在等待 I/O 的情况(ex>列印)
	- T ：停止状态(stop)，可能是在工作控制(背景暂停)或除错 (traced) 状态；
	- Z (Zombie)：僵尸状态，程序已经终止但却无法被移除至内存外。
- UID/PID/PPID：代表『此程序被该 UID 所拥有/程序的 PID 号码/此程序的父程序 PID 号码』
- C：代表 CPU 使用率，单位为百分比；
- PRI/NI：Priority/Nice 的缩写，代表此程序被 CPU 所运行的优先顺序，数值越小代表该程序越快被 CPU 运行。
- ADDR/SZ/WCHAN：都与内存有关，ADDR 是 kernel function，指出该程序在内存的哪个部分，如果是个 running 的程序，一般就会显示『 - 』 / SZ 代表此程序用掉多少内存 / WCHAN 表示目前程序是否运行中，同样的， 若为 - 表示正在运行中。
- TTY：登陆者的终端机位置，若为远程登陆则使用动态终端介面 (pts/n)；
- TIME：使用掉的 CPU 时间，注意，是此程序实际花费 CPU 运行的时间，而不是系统时间；
- CMD：就是 command 的缩写，造成此程序的触发程序之命令为何。

### 观察系统所有程序： ps aux
```bash?linenums
# 列出目前所有的正在内存当中的程序：
[root@www ~]# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   2064   616 ?        Ss   Mar11   0:01 init [5]
root         2  0.0  0.0      0     0 ?        S<   Mar11   0:00 [migration/0]
root         3  0.0  0.0      0     0 ?        SN   Mar11   0:00 [ksoftirqd/0]
.....(中间省略).....
root     13639  0.0  0.2   5148  1508 pts/1    Ss   11:44   0:00 -bash
root     14232  0.0  0.1   4452   876 pts/1    R+   15:52   0:00 ps aux
root     18593  0.0  0.0   2240   476 ?        Ss   Mar14   0:00 /usr/sbin/atd
```

- USER：该 process 属於那个使用者帐号的？
- PID ：该 process 的程序识别码。
- %CPU：该 process 使用掉的 CPU 资源百分比；
- %MEM：该 process 所占用的实体内存百分比；
- VSZ ：该 process 使用掉的虚拟内存量 (Kbytes)
- RSS ：该 process 占用的固定的内存量 (Kbytes)
- TTY ：该 process 是在那个终端机上面运行，若与终端机无关则显示 ?，另外， tty1-tty6 是本机上面的登陆者程序，若为 pts/0 等等的，则表示为由网络连接进主机的程序。
- STAT：该程序目前的状态，状态显示与 ps -l 的 S 旗标相同 (R/S/T/Z)
- START：该 process 被触发启动的时间；
- TIME ：该 process 实际使用 CPU 运行的时间。
- COMMAND：该程序的实际命令为何


除此之外，我们必须要知道的是『僵尸 (zombie) 』程序是什么？ 通常，造成僵尸程序的成因是因为该程序应该已经运行完毕，或者是因故应该要终止了， 但是该程序的父程序却无法完整的将该程序结束掉，而造成那个程序一直存在内存当中。 如果你发现在某个程序的 CMD 后面还接上 `<defunct>` 时，就代表该程序是僵尸程序啦，例如：
`apache  8683  0.0  0.9 83384 9992 ?   Z  14:33   0:00 /usr/sbin/httpd <defunct> `

## top：动态观察程序的变化
相对於 ps 是撷取一个时间点的程序状态， top 则可以持续侦测程序运行的状态！使用方式如下：
```bash?linenums
[root@www ~]# top [-d 数字] | top [-bnp]
选项与参数：
-d  ：后面可以接秒数，就是整个程序画面升级的秒数。默认是 5 秒；
-b  ：以批量的方式运行 top ，还有更多的参数可以使用喔！
      通常会搭配数据流重导向来将批量的结果输出成为文件。
-n  ：与 -b 搭配，意义是，需要进行几次 top 的输出结果。
-p  ：指定某些个 PID 来进行观察监测而已。
在 top 运行过程当中可以使用的按键命令：
	? ：显示在 top 当中可以输入的按键命令；
	P ：以 CPU 的使用资源排序显示；
	M ：以 Memory 的使用资源排序显示；
	N ：以 PID 来排序喔！
	T ：由该 Process 使用的 CPU 时间累积 (TIME+) 排序。
	k ：给予某个 PID 一个讯号  (signal)
	r ：给予某个 PID 重新制订一个 nice 值。
	q ：离开 top 软件的按键。
```
```bash?linenums
# 每两秒钟升级一次 top ，观察整体资讯：
[root@www ~]# top -d 2
top - 17:03:09 up 7 days, 16:16,  1 user,  load average: 0.00, 0.00, 0.00
Tasks:  80 total,   1 running,  79 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.5%us,  0.5%sy,  0.0%ni, 99.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:    742664k total,   681672k used,    60992k free,   125336k buffers
Swap:  1020088k total,       28k used,  1020060k free,   311156k cached
    <==如果加入 k 或 r 时，就会有相关的字样出现在这里喔！
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND     
14398 root      15   0  2188 1012  816 R  0.5  0.1   0:00.05 top
    1 root      15   0  2064  616  528 S  0.0  0.1   0:01.38 init
    2 root      RT  -5     0    0    0 S  0.0  0.0   0:00.00 migration/0
    3 root      34  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd/0
```
上面的画面为整个系统的资源使用状态，基本上总共有六行，显示的内容依序是：

- 第一行(top...)：这一行显示的资讯分别为：
	- 目前的时间，亦即是 17:03:09 那个项目；
	- 启动到目前为止所经过的时间，亦即是 up 7days, 16:16 那个项目；
	- 已经登陆系统的使用者人数，亦即是 1 user项目；
	- 系统在 1, 5, 15 分钟的平均工作负载。我们在第十六章谈到的 batch 工作方式为负载小於 0.8 就是这个负载罗！代表的是 1, 5, 15 分钟，系统平均要负责运行几个程序(工作)的意思。 越小代表系统越闲置，若高於 1 得要注意你的系统程序是否太过繁复了！

- 第二行(Tasks...)：显示的是目前程序的总量与个别程序在什么状态(running, sleeping, stopped, zombie)。 比较需要注意的是最后的 zombie 那个数值，如果不是 0 ！好好看看到底是那个 process 变成僵尸了吧？
- 第三行(Cpus...)：显示的是 CPU 的整体负载，每个项目可使用 ? 查阅。需要特别注意的是 %wa ，那个项目代表的是 I/O wait， 通常你的系统会变慢都是 I/O 产生的问题比较大！因此这里得要注意这个项目耗用 CPU 的资源喔！ 另外，如果是多核心的设备，可以按下数字键『1』来切换成不同 CPU 的负载率。
- 第四行与第五行：表示目前的实体内存与虚拟内存 (Mem/Swap) 的使用情况。 再次重申，要注意的是 swap 的使用量要尽量的少！如果 swap 被用的很大量，表示系统的实体内存实在不足！
- 第六行：这个是当在 top 程序当中输入命令时，显示状态的地方。

至於 top 下半部分的画面，则是每个 process 使用的资源情况。比较需要注意的是：

- PID ：每个 process 的 ID 啦！
- USER：该 process 所属的使用者；
- PR ：Priority 的简写，程序的优先运行顺序，越小越早被运行；
- NI ：Nice 的简写，与 Priority 有关，也是越小越早被运行；
- %CPU：CPU 的使用率；
- %MEM：内存的使用率；
- TIME+：CPU 使用时间的累加；
# 管理进程
如何互相管理的呢？其实是透过给予该程序一个讯号 (signal) 去告知该程序你想要让她作什么！

|代号 |	名称|	内容|
|---|---|---|
|1	|SIGHUP	|启动被终止的程序，可让该 PID 重新读取自己的配置档，类似重新启动|
|2	|SIGINT	|相当於用键盘输入 [ctrl]-c 来中断一个程序的进行|
|9	|SIGKILL|	代表强制中断一个程序的进行，如果该程序进行到一半， 那么尚未完成的部分可能会有『半产品』产生，类似 vim会有 .filename.swp 保留下来。|
|15	|SIGTERM|	以正常的结束程序来终止该程序。由於是正常的终止， 所以后续的动作会将他完成。不过，如果该程序已经发生问题，就是无法使用正常的方法终止时， 输入这个 signal 也是没有用的。|
|17	|SIGSTOP|	相当於用键盘输入 [ctrl]-z 来暂停一个程序的进行|

## kill -signal PID
```bash?linenums
zch@localhost ~]$ kill -9 12345
```