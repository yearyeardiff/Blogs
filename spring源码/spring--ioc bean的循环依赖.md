---
title: spring--ioc bean的循环依赖
tags: 新建,模板,小书匠
grammar_cjkRuby: true
---

# 循环依赖的产生和解决的前提
循环依赖的产生可能有很多种情况，例如：

- A的构造方法中依赖了B的实例对象，同时B的构造方法中依赖了A的实例对象
- A的构造方法中依赖了B的实例对象，同时B的某个field或者setter需要A的实例对象，以及反之
- A的某个field或者setter依赖了B的实例对象，同时B的某个field或者setter依赖了A的实例对象，以及反之

当然，Spring对于循环依赖的解决不是无条件的，首先前提条件是针对scope单例并且没有显式指明不需要解决循环依赖的对象，而且要求该对象没有被代理过。同时Spring解决循环依赖也不是万能，以上三种情况只能解决两种，第一种在构造方法中相互依赖的情况Spring也无力回天。结论先给在这，下面来看看Spring的解决方法，知道了解决方案就能明白为啥第一种情况无法解决了。

# Spring对于循环依赖的解决
Spring循环依赖的理论依据其实是Java基于引用传递，当我们获取到对象的引用时，对象的field或者或属性是可以延后设置的。
Spring单例对象的初始化其实可以分为三步：

- createBeanInstance， 实例化，实际上就是调用对应的构造方法构造对象，此时只是调用了构造方法，spring xml中指定的property并没有进行populate
- populateBean，填充属性，这步对spring xml中指定的property进行populate
- initializeBean，调用spring xml中指定的init方法，或者AfterPropertiesSet方法会发生循环依赖的步骤集中在第一步和第二步。

## 三级缓存
对于单例对象来说，在Spring的整个容器的生命周期内，有且只存在一个对象，很容易想到这个对象应该存在Cache中，Spring大量运用了Cache的手段，在循环依赖问题的解决过程中甚至使用了“三级缓存”。

“三级缓存”主要是指

``` java
/** Cache of singleton objects: bean name --> bean instance */
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<String, Object>(256);
/** Cache of singleton factories: bean name --> ObjectFactory */
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<String, ObjectFactory<?>>(16);
/** Cache of early singleton objects: bean name --> bean instance not autowire */
private final Map<String, Object> earlySingletonObjects = new HashMap<String, Object>(16);
```
从字面意思来说：singletonObjects指单例对象的cache，singletonFactories指单例对象工厂的cache，earlySingletonObjects指提前曝光的单例对象的cache。以上三个cache构成了三级缓存，Spring就用这三级缓存巧妙的解决了循环依赖问题。

# 解决方法
在Bean创建的过程中，首先Spring会尝试从缓存中获取，这个缓存就是指singletonObjects，主要调用的方法是：

``` java
Object sharedInstance = getSingleton(beanName);

public Object getSingleton(String beanName) {
	return getSingleton(beanName, true);
}

protected Object getSingleton(String beanName, boolean allowEarlyReference) {
	// 查询缓存中是否有创建好的单例
	Object singletonObject = this.singletonObjects.get(beanName);
	// 如果缓存不存在，判断是否正在创建中
	if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
		// 加锁防止并发
		synchronized (this.singletonObjects) {
			// 从earlySingletonObjects中查询是否有early缓存
			singletonObject = this.earlySingletonObjects.get(beanName);
			// early缓存也不存在，且允许early引用
			if (singletonObject == null && allowEarlyReference) {
				// 从单例工厂Map里查询beanName
				ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
				if (singletonFactory != null) {
					// singletonFactory存在，则调用getObject方法拿到单例对象
					singletonObject = singletonFactory.getObject();
					// 将单例对象添加到early缓存中
					this.earlySingletonObjects.put(beanName, singletonObject);
					// 移除单例工厂中对应的singletonFactory
					this.singletonFactories.remove(beanName);
				}
			}
		}
	}
	return (singletonObject != NULL_OBJECT ? singletonObject : null);
}
```
分析getSingleton的整个过程，Spring首先从singletonObjects（一级缓存）中尝试获取，如果获取不到并且对象在创建中，则尝试从earlySingletonObjects(二级缓存)中获取，如果还是获取不到并且允许从singletonFactories通过getObject获取，则通过singletonFactory.getObject()(三级缓存)获取。如果获取到了则

``` java

this.earlySingletonObjects.put(beanName, singletonObject);
this.singletonFactories.remove(beanName);
```
则移除对应的singletonFactory,将singletonObject放入到earlySingletonObjects，其实就是将三级缓存提升到二级缓存中！

上面最重要的就是singletonFactories何时放入了可以通过getObject获得bean对象的ObjectFactory(也就是什么时候放到二级缓存中去的)。根据我们的猜测，应该会是bean对象实例化后，而属性注入之前。仔细寻找后发现，在AbstractAutowireCapableBeanFactory类的doCreateBean方法，也就是实际bean创建的方法中，执行完createBeanInstance实例化bean之后有一段代码：

``` java
// bean为单例且允许循环引用且正在创建中
boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
		isSingletonCurrentlyInCreation(beanName));
if (earlySingletonExposure) {
	if (logger.isDebugEnabled()) {
		logger.debug("Eagerly caching bean '" + beanName +
				"' to allow for resolving potential circular references");
	}
	// 创建ObjectFactory并添加到singletonFactories中
	addSingletonFactory(beanName, new ObjectFactory<Object>() {
		@Override
		public Object getObject() throws BeansException {
			return getEarlyBeanReference(beanName, mbd, bean);
		}
	});
}


protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
	Assert.notNull(singletonFactory, "Singleton factory must not be null");
	synchronized (this.singletonObjects) {
		// 判断默认缓存中没有beanName
		if (!this.singletonObjects.containsKey(beanName)) {
			// 添加ObjectFactory到singletonFactories
			this.singletonFactories.put(beanName, singletonFactory);
			this.earlySingletonObjects.remove(beanName);
			this.registeredSingletons.add(beanName);
		}
	}
}

```
当判断bean为单例且正在创建中，而Spring允许循环引用时，将能获得bean对象的引用的ObjectFactory添加到singletonFactories中，此时就与之前的getSingleton方法相呼应。而allowCircularReferences标识在spring中默认为true，但是也可以通过setAllowCircularReferences方法对AbstractAutowireCapableBeanFactory进行设置。

来梳理一下上面getBean("beanA"）的执行过程

1. 实例化BeanA
2. 将能获取BeanA对象的ObjectFactory添加到singletonFactories中
3. BeanA注入BeanB属性，调用getBean("beanB")方法
4. 实例化BeanB
5. 将能获取BeanB对象的ObjectFactory添加到singletonFactories中
6. BeanB注入BeanA属性，调用getBean("beanA")
7. 从singletonFactories中获取ObjectFactory并调用getObject方法拿到beanA对象的引用
8. BeanB创建完成，注入到BeanA的beanB属性中
9. BeanA创建完成返回


# 参考
转自:[Spring源码初探-IOC(4)-Bean的初始化-循环依赖的解决](https://www.jianshu.com/p/6c359768b1dc)，[Spring源码-IOC容器(六)-bean的循环依赖](https://my.oschina.net/u/2377110/blog/979226)

