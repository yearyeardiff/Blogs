---
title: java并发---线程池
tags: java,并发,线程池
grammar_cjkRuby: true
---


# 线程池的实现原理
当向线程池提交一个任务之后，线程池是如何处理这个任务的呢？本节来看一下线程池的主要处理流程，处理流程图如图所示。
从图中可以看出，当提交一个新任务到线程池时，线程池的处理流程如下。

 1. 线程池判断核心线程池里的线程是否都在执行任务。如果不是，则创建一个新的工作线程来执行任务。如果核心线程池里的线程都在执行任务，则进入下个流程。
 2. 线程池判断工作队列是否已经满。如果工作队列没有满，则将新提交的任务存储在这个工作队列里。如果工作队列满了，则进入下个流程。
 3. 线程池判断线程池的线程是否都处于工作状态。如果没有，则创建一个新的工作线程来执行任务。如果已经满了，则交给饱和策略来处理这个任务。

![enter description here][1]

ThreadPoolExecutor执行execute()方法的示意图，如图所示

![enter description here][2]

ThreadPoolExecutor执行execute方法分下面4种情况:

 1. 如果当前运行的线程少于corePoolSize，则创建新线程来执行任务（注意，执行这一步骤需要获取全局锁）。
 2. 如果运行的线程等于或多于corePoolSize，则将任务加入BlockingQueue。
 3. 如果无法将任务加入BlockingQueue（队列已满），则创建新的线程来处理任务（注意，执行这一步骤需要获取全局锁）。
 4. 如果创建新线程将使当前运行的线程超出maximumPoolSize，任务将被拒绝，并调用RejectedExecutionHandler.rejectedExecution()方法。

# 线程池的使用

## 线程池的创建

``` java
ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> runnableTaskQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler)
```

创建一个线程池时需要输入几个参数，如下：

 1. corePoolSize（线程池的基本大小）：当提交一个任务到线程池时，线程池会创建一个线程来执行任务，即使其他空闲的基本线程能够执行新任务也会创建线程，等到需要执行的任务数大于线程池基本大小时就不再创建。如果调用了线程池的prestartAllCoreThreads()方法，线程池会提前创建并启动所有基本线程。
 
 2. runnableTaskQueue（任务队列）：用于保存等待执行的任务的阻塞队列。可以选择以下几 个阻塞队列:
 
	   ArrayBlockingQueue：是一个基于数组结构的有界阻塞队列，此队列按FIFO（先进先出）原 则对元素进行排序。
	   LinkedBlockingQueue：一个基于链表结构的阻塞队列，此队列按FIFO排序元素，吞吐量通常要高于ArrayBlockingQueue。静态工厂方法Executors.newFixedThreadPool()使用了这个队列。
	   SynchronousQueue：一个不存储元素的阻塞队列。每个插入操作必须等到另一个线程调用移除操作，否则插入操作一直处于阻塞状态，吞吐量通常要高于Linked-BlockingQueue，静态工厂方法Executors.newCachedThreadPool使用了这个队列。
	   PriorityBlockingQueue：一个具有优先级的无限阻塞队列。
   
 3. maximumPoolSize（线程池最大数量）：线程池允许创建的最大线程数。如果队列满了，并且已创建的线程数小于最大线程数，则线程池会再创建新的线程执行任务。值得注意的是，如果使用了无界的任务队列这个参数就没什么效果。
 
 4. ThreadFactory：用于设置创建线程的工厂，可以通过线程工厂给每个创建出来的线程设置更有意义的名字。使用开源框架guava提供的ThreadFactoryBuilder可以快速给线程池里的线 程设置有意义的名字，代码如下。

``` java
new ThreadFactoryBuilder().setNameFormat("XX-task-%d").build();
```

 5. RejectedExecutionHandler（饱和策略）：当队列和线程池都满了，说明线程池处于饱和状 态，那么必须采取一种策略处理提交的新任务。这个策略默认情况下是AbortPolicy，表示无法 处理新任务时抛出异常。在JDK1.5中Java线程池框架提供了以下4种策略。

	·AbortPolicy：直接抛出异常。
	·CallerRunsPolicy：只用调用者所在线程来运行任务。
	·DiscardOldestPolicy：丢弃队列里最近的一个任务，并执行当前任务。
	·DiscardPolicy：不处理，丢弃掉。
当然，也可以根据应用场景需要来实现RejectedExecutionHandler接口自定义策略。

 6. keepAliveTime（线程活动保持时间）：线程池的工作线程空闲后，保持存活的时间。所以，如果任务很多，并且每个任务执行的时间比较短，可以调大时间，提高线程的利用率。

 7. TimeUnit（线程活动保持时间的单位）：可选的单位有天（DAYS）、小时（HOURS）、分钟（MINUTES）、毫秒（MILLISECONDS）、微秒（MICROSECONDS，千分之一毫秒）和纳秒（NANOSECONDS，千分之一微 秒）。


## 向线程池提交任务
可以使用两个方法向线程池提交任务，分别为execute()和submit()方法
execute()方法用于提交不需要返回值的任务，所以无法判断任务是否被线程池执行成功。通过以下代码可知execute()方法输入的任务是一个Runnable类的实例。

``` java
threadsPool.execute(new Runnable() {
	@Override
	public void run() {
		// TODO Auto-generated method stub
	}
});
```
submit()方法用于提交需要返回值的任务。线程池会返回一个future类型的对象，通过这个future对象可以判断任务是否执行成功，并且可以通过future的get()方法来获取返回值，get()方法会阻塞当前线程直到任务完成，而使用get（long timeout，TimeUnit unit）方法则会阻塞当前线程一段时间后立即返回，这时候有可能任务没有执行完。

``` java
Future<Object> future = executor.submit(harReturnValuetask);
	try {
				Object s = future.get();
			} catch (InterruptedException e) {
				// 处理中断异常
			} catch (ExecutionException e) {
				// 处理无法执行任务异常
			} finally {
				// 关闭线程池
				executor.shutdown();
		}
```

## 合理地配置线程池

要想合理地配置线程池，就必须首先分析任务特性，可以从以下几个角度来分析。

 - ·任务的性质：CPU密集型任务、IO密集型任务和混合型任务。
 - ·任务的优先级：高、中和低。
 - ·任务的执行时间：长、中和短。
 - ·任务的依赖性：是否依赖其他系统资源，如数据库连接。

> 性质不同的任务可以用不同规模的线程池分开处理。
> CPU密集型任务应配置尽可能小的线程，如配置Ncpu+1个线程的线程池。
> 由于IO密集型任务线程并不是一直在执行任务，则应配置尽可能多的线程，如2\*Ncpu。
> 混合型的任务，如果可以拆分，将其拆分成一个CPU密集型任务和一个IO密集型任务，只要这两个任务执行的时间相差不是太大，那么分解后执行的吞吐量将高于串行执行的吞吐量。如果这两个任务执行时间相差太大，则没必要进行分解。可以通过Runtime.getRuntime().availableProcessors()方法获得当前设备的CPU个数
> 
> 优先级不同的任务可以使用优先级队列PriorityBlockingQueue来处理。它可以让优先级高 的任务先执行。
> 
> 依赖数据库连接池的任务，因为线程提交SQL后需要等待数据库返回结果，等待的时间越
长，则CPU空闲时间就越长，那么线程数应该设置得越大，这样才能更好地利用CPU
> 
> 建议使用有界队列。有界队列能增加系统的稳定性和预警能力，可以根据需要设大一点
儿，比如几千。



  [1]: ./images/%E7%BA%BF%E7%A8%8B%E6%B1%A0%E7%9A%84%E4%B8%BB%E8%A6%81%E5%A4%84%E7%90%86%E6%B5%81%E7%A8%8B.png "线程池的主要处理流程"
  [2]: ./images/ThreadPoolExecutor%E6%89%A7%E8%A1%8C%E7%A4%BA%E6%84%8F%E5%9B%BE.png "ThreadPoolExecutor执行示意图"