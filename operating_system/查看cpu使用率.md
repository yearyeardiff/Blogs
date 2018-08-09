---
title: 查看cpu使用率
tags: cpu
grammar_cjkRuby: true
---

# linux 查看cpu的命令以及各参数的含义
- mpstat
``` tex?linenums
[zch@192 ~]$ mpstat
Linux 3.10.0-327.el7.x86_64 (192.168.186.128)   2018年07月20日  _x86_64_        (2 CPU)

13时56分56秒  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
13时56分56秒  all    0.45    0.19    1.18    0.16    0.00    0.03    0.00    0.00    0.00   97.99
[zch@192 ~]$ man mpstat

 %usr
         Show the percentage of CPU utilization that occurred while executing at the user level (application).
 %nice
         Show the percentage of CPU utilization that occurred while executing at the user level with nice priority.
 %sys
         Show  the  percentage  of CPU utilization that occurred while executing at the system level (kernel). Note that this does not include time spent servicing hardware and software interrupts.
 %iowait
         Show the percentage of time that the CPU or CPUs were idle during which the system had an outstanding disk I/O request.
 %irq
         Show the percentage of time spent by the CPU or CPUs to service hardware interrupts.
%soft
         Show the percentage of time spent by the CPU or CPUs to service software interrupts.
 %steal
         Show the percentage of time spent in involuntary wait by the virtual CPU or CPUs while the hypervisor was servicing another  virtual  pro‐cessor.
%guest
         Show the percentage of time spent by the CPU or CPUs to run a virtual processor.
%gnice
         Show the percentage of time spent by the CPU or CPUs to run a niced guest.
 %idle
         Show the percentage of time that the CPU or CPUs were idle and the system did not have an outstanding disk I/O request.
```
- top
``` tex?linenums
[zch@192 ~]$ top
top - 13:58:46 up 29 min,  2 users,  load average: 0.00, 0.01, 0.05
Tasks: 436 total,   1 running, 435 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.5 sy,  0.0 ni, 99.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1001360 total,    89664 free,   461632 used,   450064 buff/cache
KiB Swap:  2097148 total,  2096780 free,      368 used.   349988 avail Mem 

   PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                                                                       
  5158 zch       20   0  148484   2396   1428 R   1.3  0.2   0:00.11 top                                                                                           
   281 root      20   0       0      0      0 S   0.3  0.0   0:03.64 kworker/0:1                                                                                   
     1 root      20   0  191600   5256   2512 S   0.0  0.5   0:03.44 systemd                                                                                       
     2 root      20   0       0      0      0 S   0.0  0.0   0:00.03 kthreadd                                                                                      
     3 root      20   0       0      0      0 S   0.0  0.0   0:00.05 ksoftirqd/0   
	 
	 
[zch@192 ~]$ man top

us, user    : time running un-niced user processes
sy, system  : time running kernel processes
ni, nice    : time running niced user processes
id, idle    : time spent in the kernel idle handler
wa, IO-wait : time waiting for I/O completion
hi : time spent servicing hardware interrupts
si : time spent servicing software interrupts
st : time stolen from this vm by the hypervisor
```

# 参考文档
[%iowait和CPU使用率的正确认知](http://www.cnblogs.com/echo1937/p/6240020.html)
[Linux CPU占用率原理与精确度分析](https://wenku.baidu.com/view/b1ae22fbc8d376eeaeaa31a7.html)
[What does 'nice' mean on CPU utilization graphs?](https://serverfault.com/questions/116950/what-does-nice-mean-on-cpu-utilization-graphs)


