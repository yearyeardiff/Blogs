---
title: java并发---双重检查锁定与延迟初始化
tags: java,并发,单例模式
grammar_cjkRuby: true
---


## 双重检查锁定的由来

 1. 例子1

``` java
public class UnsafeLazyInitialization {
	private static Instance instance;
		public static Instance getInstance() {
			if (instance == null) // 1：A线程执行
				instance = new Instance(); // 2：B线程执行
				return instance;
			}
	}
```
线程不安全

 2. 例子2
``` java
public class SafeLazyInitialization {
	private static Instance instance;
		public synchronized static Instance getInstance() {
			if (instance == null)
				instance = new Instance();
			return instance;
	}
}
```
由于对getInstance()方法做了同步处理，synchronized将导致性能开销。如果getInstance()方法被多个线程频繁的调用，将会导致程序执行性能的下降


 3. 例子3
``` java
public class DoubleCheckedLocking { // 1
	private static Instance instance; // 2
	
	public static Instance getInstance() { // 3
		if (instance == null) { // 4:第一次检查
			synchronized (DoubleCheckedLocking.class) { // 5:加锁
				if (instance == null) // 6:第二次检查
					instance = new Instance(); // 7:问题的根源出在这里
				} // 8
			} // 9
		return instance; // 10
	} // 11
}
```
这是一个错误的优化！在线程执行到第4行，代码读取到instance不为null时，instance引用的对象有可能还没有完成初始化

## 问题的根源

前面的双重检查锁定示例代码的第7行（instance=new Singleton();）创建了一个对象。这一行代码可以分解为如下的3行伪代码。

```  C
memory = allocate(); // 1：分配对象的内存空间
ctorInstance(memory); // 2：初始化对象
instance = memory; // 3：设置instance指向刚分配的内存地址
```

上面3行伪代码中的2和3之间，可能会被重排序（在一些JIT编译器上，这种重排序是真实发生的，详情见参考文献1的“Out-of-order writes”部分）。2和3之间重排序之后的执行时序如下。

``` C
memory = allocate(); // 1：分配对象的内存空间
instance = memory; // 3：设置instance指向刚分配的内存地址
// 注意，此时对象还没有被初始化！
ctorInstance(memory); // 2：初始化对象
```


例子3 示例代码的第7行（instance=new Singleton();）如果发生重排序，另一个并发执行的线程B就有可能在第4行判断instance不为null。线程B接下来将访问instance所引用的对象，但此时这个对象可能还没有被A线程初始化！如下表是这个场景的具体执行时序。

![enter description here][1]
这里A2和A3虽然重排序了，但Java内存模型的intra-thread semantics将确保A2一定会排在A4前面执行。因此，线程A的intra-thread semantics没有改变，但A2和A3的重排序，将导致线程B在B1处判断出instance不为空，线程B接下来将访问instance引用的对象。此时，线程B将会访问到一个还未初始化的对象。

在知晓了问题发生的根源之后，我们可以想出两个办法来实现线程安全的延迟初始化。

 1. 不允许2和3重排序。
 2. 允许2和3重排序，但不允许其他线程“看到”这个重排序。

## 基于volatile的解决方案

``` java
public class SafeDoubleCheckedLocking {
	private volatile static Instance instance;
	public static Instance getInstance() {
		if (instance == null) {
			synchronized (SafeDoubleCheckedLocking.class) {
				if (instance == null)
					instance = new Instance(); // instance为volatile，现在没问题了
				}
			}
		return instance;
	}
}
```
这个方案本质上是通过禁止2和3之间的重排序，来保证线程安全的延迟初始化

## 基于类初始化的解决方案
JVM在类的初始化阶段（即在Class被加载后，且被线程使用之前），会执行类的初始化。在执行类的初始化期间，JVM会去获取一个锁。这个锁可以同步多个线程对同一个类的初始化。

基于这个特性，可以实现另一种线程安全的延迟初始化方案（这个方案被称之为Initialization On Demand Holder idiom）


``` java
public class InstanceFactory {

	private static class InstanceHolder {
		public static Instance instance = new Instance();
	}
		
	public static Instance getInstance() {
		return InstanceHolder.instance ; // 这里将导致InstanceHolder类被初始化
	}
}
```


  [1]: ./images/1523360858603.jpg