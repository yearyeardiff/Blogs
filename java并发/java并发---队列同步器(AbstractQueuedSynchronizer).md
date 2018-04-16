---
title: java并发---队列同步器(AbstractQueuedSynchronizer) 
tags: java,并发,AQS
grammar_cjkRuby: true
---

> 队列同步器AbstractQueuedSynchronizer（以下简称同步器），是用来构建锁或者其他同步组件的基础框架，它使用了一个int成员变量表示同步状态，通过内置的FIFO队列来完成资源获取线程的排队工作，并发包的作者（Doug Lea）期望它能够成为实现大部分同步需求的基础

以下博客写的都很好，讲解也很详细：

 1. [Java并发之AQS详解][1]
 2. [AQS实现分析][2]

  [1]: https://www.cnblogs.com/waterystone/p/4920797.html
  [2]: https://blog.csdn.net/fjse51/article/details/54694714