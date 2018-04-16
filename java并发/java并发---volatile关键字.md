---
title: java并发---volatile关键字
tags: java,并发,volatile
grammar_cjkRuby: true
---


## volatile的特性

 - 可见性:对一个volatile变量的读，总是能看到（任意线程）对这个volatile变量最后的写入
 - 原子性:对任意单个volatile变量的读/写具有原子性，但类似于volatile++这种复合操作不具有原子性

## volatile写-读建立的happens-before关系

从内存语义的角度来说，volatile的写-读与锁的释放-获取有相同的内存效果：volatile写和锁的释放有相同的内存语义；volatile读与锁的获取有相同的内存语义。

## volatile写-读的内存语义

当写一个volatile变量时，JMM会把该线程对应的本地内存中的共享变量值刷新到主内存。

 - 线程A写一个volatile变量，实质上是线程A向接下来将要读这个volatile变量的某个线程发出了（其对共享变量所做修改的）消息。
 - 线程B读一个volatile变量，实质上是线程B接收了之前某个线程发出的（在写这个volatile变量之前对共享变量所做修改的）消息。
 - 线程A写一个volatile变量，随后线程B读这个volatile变量，这个过程实质上是线程A通过主内存向线程B发送消息。

## volatile内存语义的实现

JMM针对编译器制定的volatile重排序规则表

![enter description here][1]

举例来说，第三行最后一个单元格的意思是：在程序中，当第一个操作为普通变量的读或写时，如果第二个操作为volatile写，则编译器不能重排序这两个操作。

从表我们可以看出。

 - 当第二个操作是volatile写时，不管第一个操作是什么，都不能重排序。这个规则确保volatile写之前的操作不会被编译器重排序到volatile写之后。
 - 当第一个操作是volatile读时，不管第二个操作是什么，都不能重排序。这个规则确保volatile读之后的操作不会被编译器重排序到volatile读之前。
 - 当第一个操作是volatile写，第二个操作是volatile读时，不能重排序。
 为了实现volatile的内存语义，编译器在生成字节码时，会在指令序列中插入内存屏障来禁止特定类型的处理器重排序。对于编译器来说，发现一个最优布置来最小化插入屏障的总数几乎不可能。为此，JMM采取保守策略。下面是基于保守策略的JMM内存屏障插入策略。
 
 - 在每个volatile写操作的前面插入一个StoreStore屏障。
 - 在每个volatile写操作的后面插入一个StoreLoad屏障。
 - 在每个volatile读操作的后面插入一个LoadLoad屏障。
 - 在每个volatile读操作的后面插入一个LoadStore屏障。

上述内存屏障插入策略非常保守，但它可以保证在任意处理器平台，任意的程序中都能得到正确的volatile内存语义。


  [1]: ./images/%E9%87%8D%E6%8E%92%E5%BA%8F.PNG "重排序"