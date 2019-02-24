---
title: spring--aop ProxyFactory
tags: spring,aop,ProxyFactory
grammar_cjkRuby: true
---

Spring AOP 源码解析系列，建议大家按顺序阅读，欢迎讨论

1.  [Spring源码-AOP(一)-代理模式](https://my.oschina.net/u/2377110/blog/1504596)
2.  [Spring源码-AOP(二)-AOP概念](https://my.oschina.net/u/2377110/blog/1506098)
3.  [Spring源码-AOP(三)-Spring AOP的四种实现](https://my.oschina.net/u/2377110/blog/1507532)
4.  [Spring源码-AOP(四)-ProxyFactory](https://my.oschina.net/u/2377110/blog/1510684)
5.  [Spring源码-AOP(五)-ProxyFactoryBean](https://my.oschina.net/u/2377110/blog/1512222)
6.  [Spring源码-AOP(六)-自动代理与DefaultAdvisorAutoProxyCreator](https://my.oschina.net/u/2377110/blog/1517915)
7.  [Spring源码-AOP(七)-整合AspectJ](https://my.oschina.net/u/2377110/blog/1529575)

本章来解析最基础的ProxyFactory的源码。有人会说，现在都没人用编码的方式来写AOP了，解析它有什么用呢？我想从两点强调下：

1.  不论是注解还是XML配置，其底层的实现还是通过编码的方式来组建相互之间的关系。可以说ProxyFactory的基本实现就是Spring AOP抛开一切配置后真正核心的东西。
2.  我理解中优秀的框架都是不断演进的，逐渐演化从而形成强大的功能。从理解简单的实现逐步到了解复杂的功能结构，才能一步步把握框架设计的思路，而这也是我们学习优秀框架的主要目的。

# 1.ProxyFactory类结构

在深入源码前，我们应当对ProxyFactory的结构有一个概览，就如同读一本书，先浏览下目录结构，会对接下来的阅读大有裨益。

![ProxyFactory类结构][1]


*   ProxyConfig：代理相关的全局配置，常见的有proxyTargetClass，exposeProxy。
*   AdvisedSupport：在Spring AOP中，Advisor(切面)就是将Advice(增强)和Pointcut(切入点)连接起来的东西。此类主要支持切面相关的操作。
*   ProxyCreatorSupport：代理创建的辅助类，主要方法就是创建代理对象。

可以看出整个层级架构中每个类的职责很确定，符合了职责单一原则，在Spring中好的设计理念存在于点点滴滴里。

# 2.ProxyFactory源码解析

在上一篇[AOP的四种实现](https://my.oschina.net/u/2377110/blog/1507532)里列举了ProxyFactory创建代理的Demo。

```
public class ProxyFactoryTest {

	public static void main(String[] args) {
		// 1.创建代理工厂
		ProxyFactory factory = new ProxyFactory();
		// 2.设置目标对象
		factory.setTarget(new ChromeBrowser());
		// 3.设置代理实现接口
		factory.setInterfaces(new Class[]{Browser.class});
		// 4.添加前置增强
		factory.addAdvice(new BrowserBeforeAdvice());
		// 5.添加后置增强
		factory.addAdvice(new BrowserAfterReturningAdvice());
		// 6.获取代理对象
		Browser browser = (Browser) factory.getProxy();

		browser.visitInternet();
	}
}

```

我们就以基于接口代理这个简单的例子来分析ProxyFactory的实现。

## ProxyFactory初始化

首先，基于接口的代理需要准备的元素：

1.  被代理的对象
2.  代理对象要实现的接口
3.  要对被代理对象实施的增强(额外操作)

Demo中的前5步都是处理准备工作

1.  ProxyFactory的构造函数是空方法

2.  setTarget时，将target对象封装成TargetSource对象，而调用的setTargetSource是AdvisedSupport的方法。

    ```
     public void setTarget(Object target) {
     	setTargetSource(new SingletonTargetSource(target));
     }

     public void setTargetSource(TargetSource targetSource) {
     	this.targetSource = (targetSource != null ? targetSource : EMPTY_TARGET_SOURCE);
     }

    ```

3.  setInterfaces，赋值的也是AdvisedSupport中的interfaces属性，但是是先清空再赋值。

    ```
     /**
      * Set the interfaces to be proxied.
      */
     public void setInterfaces(Class<?>... interfaces) {
     	Assert.notNull(interfaces, "Interfaces must not be null");
     	this.interfaces.clear();
     	for (Class<?> ifc : interfaces) {
     		addInterface(ifc);
     	}
     }

     /**
      * Add a new proxied interface.
      * [@param](https://my.oschina.net/u/2303379) intf the additional interface to proxy
      */
     public void addInterface(Class<?> intf) {
     	Assert.notNull(intf, "Interface must not be null");
     	if (!intf.isInterface()) {
     		throw new IllegalArgumentException("[" + intf.getName() + "] is not an interface");
     	}
     	if (!this.interfaces.contains(intf)) {
     		this.interfaces.add(intf);
     		adviceChanged();
     	}
     }

    ```

4.  addAdvice方法则是直接调用AdvisedSupport，将Advice封装成Advisor然后添加到advisors集合中。

    ```
     public void addAdvice(int pos, Advice advice) throws AopConfigException {
     	Assert.notNull(advice, "Advice must not be null");
     	// 引用增强单独处理
     	if (advice instanceof IntroductionInfo) {
     		// We don't need an IntroductionAdvisor for this kind of introduction:
     		// It's fully self-describing.
     		addAdvisor(pos, new DefaultIntroductionAdvisor(advice, (IntroductionInfo) advice));
     	}
     	// DynamicIntroductionAdvice不能单独添加，必须作为IntroductionAdvisor的一部分
     	else if (advice instanceof DynamicIntroductionAdvice) {
     		// We need an IntroductionAdvisor for this kind of introduction.
     		throw new AopConfigException("DynamicIntroductionAdvice may only be added as part of IntroductionAdvisor");
     	}
     	else {
     		addAdvisor(pos, new DefaultPointcutAdvisor(advice));
     	}
     }

     public void addAdvisor(int pos, Advisor advisor) throws AopConfigException {
     	if (advisor instanceof IntroductionAdvisor) {
     		validateIntroductionAdvisor((IntroductionAdvisor) advisor);
     	}
     	addAdvisorInternal(pos, advisor);
     }

     private void addAdvisorInternal(int pos, Advisor advisor) throws AopConfigException {
     	Assert.notNull(advisor, "Advisor must not be null");
     	if (isFrozen()) {
     		throw new AopConfigException("Cannot add advisor: Configuration is frozen.");
     	}
     	if (pos > this.advisors.size()) {
     		throw new IllegalArgumentException(
     				"Illegal position " + pos + " in advisor list with size " + this.advisors.size());
     	}
     	// 添加到advisor集合
     	this.advisors.add(pos, advisor);
     	updateAdvisorArray();
     	adviceChanged();
     }

    ```

上述的Advice都被封装成DefaultPointcutAdvisor，可以看下其构造函数

```
public DefaultPointcutAdvisor(Advice advice) {
	this(Pointcut.TRUE, advice);
}

```

Pointcut.TRUE表示支持任何切入点。

## 创建代理

准备工作做完了，直接通过getProxy方法获取代理对象。

```
public Object getProxy() {
	return createAopProxy().getProxy();
}

```

这里的createAopProxy()返回的是AopProxy类型，方法是final，并且加了锁操作。

```
protected final synchronized AopProxy createAopProxy() {
	if (!this.active) {
		activate();
	}
	return getAopProxyFactory().createAopProxy(this);
}

```

而AopProxy又是通过一个Factory工厂来创建，因为不同的外部配置决定了返回的是JDK代理还是CGLIB代理。这里涉及到两种设计模式，**工厂模式和策略模式**，来看一张类图。

![enter description here][2]

可以清晰地看出，**AopProxyFactory->AopProxy->Prxoy**之间的结构。

先来看DefaultAopProxyFactory中创建AopProxy的方法

```
public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
	// optimize=true或proxyTargetClass=true或接口集合为空
	if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
		Class<?> targetClass = config.getTargetClass();
		if (targetClass == null) {
			throw new AopConfigException("TargetSource cannot determine target class: " +
					"Either an interface or a target is required for proxy creation.");
		}
		// 目标对象Class为接口，正常使用时不会出现
		if (targetClass.isInterface()) {
			return new JdkDynamicAopProxy(config);
		}
		return new ObjenesisCglibAopProxy(config);
	}
	else {
		return new JdkDynamicAopProxy(config);
	}
}

```

基于外部的配置，比如设置optimize或proxyTargetClass为true，或者目标对象没有实现接口，则会返回CGLIB代理(内部有个判断targetClass是否为接口的操作，本人尝试过多种方式，除了硬编码，正常配置时都不会走)，否则返回JDK代理。

对于不同的代理方式，getProxy调用的是各自内部的实现。

### JdkDynamicAopProxy

**JDK代理通过Proxy.newProxyInstance来实现，并且JdkDynamicAopProxy自身实现InvocationHandler代理回调接口。**

```
[@Override](https://my.oschina.net/u/1162528)
public Object getProxy() {
	return getProxy(ClassUtils.getDefaultClassLoader());
}

[@Override](https://my.oschina.net/u/1162528)
public Object getProxy(ClassLoader classLoader) {
	if (logger.isDebugEnabled()) {
		logger.debug("Creating JDK dynamic proxy: target source is " + this.advised.getTargetSource());
	}
	// 处理代理接口
	Class<?>[] proxiedInterfaces = AopProxyUtils.completeProxiedInterfaces(this.advised);
	// 判断接口定义是否有equals和hashCode方法
	findDefinedEqualsAndHashCodeMethods(proxiedInterfaces);
	// 调用JDK创建代理方法
	return Proxy.newProxyInstance(classLoader, proxiedInterfaces, this);
}

```

方法调用时的回调方法invoke处理真正的代理请求

```
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
	MethodInvocation invocation;
	Object oldProxy = null;
	boolean setProxyContext = false;

	// 获取目标对象
	TargetSource targetSource = this.advised.targetSource;
	Class<?> targetClass = null;
	Object target = null;

	try {
		// equals方法特殊处理
		if (!this.equalsDefined && AopUtils.isEqualsMethod(method)) {
			// The target does not implement the equals(Object) method itself.
			return equals(args[0]);
		}
		// hashCode方法特殊处理
		if (!this.hashCodeDefined && AopUtils.isHashCodeMethod(method)) {
			// The target does not implement the hashCode() method itself.
			return hashCode();
		}
		// 调用Advised接口中的方法，直接反射执行
		if (!this.advised.opaque && method.getDeclaringClass().isInterface() &&
				method.getDeclaringClass().isAssignableFrom(Advised.class)) {
			// Service invocations on ProxyConfig with the proxy config...
			return AopUtils.invokeJoinpointUsingReflection(this.advised, method, args);
		}

		Object retVal;

		// 如果exposeProxy设置为true，设置当前Proxy，它是ThreadLocal级别的
		if (this.advised.exposeProxy) {
			// Make invocation available if necessary.
			oldProxy = AopContext.setCurrentProxy(proxy);
			setProxyContext = true;
		}

		// May be null. Get as late as possible to minimize the time we "own" the target,
		// in case it comes from a pool.
		target = targetSource.getTarget();
		if (target != null) {
			targetClass = target.getClass();
		}

		// Get the interception chain for this method.
		// 获取拦截器链
		List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(method, targetClass);

		// Check whether we have any advice. If we don't, we can fallback on direct
		// reflective invocation of the target, and avoid creating a MethodInvocation.
		// 如果拦截器链为空，则直接反射调用
		if (chain.isEmpty()) {
			// We can skip creating a MethodInvocation: just invoke the target directly
			// Note that the final invoker must be an InvokerInterceptor so we know it does
			// nothing but a reflective operation on the target, and no hot swapping or fancy proxying.
			retVal = AopUtils.invokeJoinpointUsingReflection(target, method, args);
		}
		else {
			// We need to create a method invocation...
			// 生成MethodInvocation，进行链式调用
			invocation = new ReflectiveMethodInvocation(proxy, target, method, args, targetClass, chain);
			// Proceed to the joinpoint through the interceptor chain.
			retVal = invocation.proceed();
		}

		// Massage return value if necessary.
		// 支持返回this的流式调用
		Class<?> returnType = method.getReturnType();
		if (retVal != null && retVal == target && returnType.isInstance(proxy) &&
				!RawTargetAccess.class.isAssignableFrom(method.getDeclaringClass())) {
			// Special case: it returned "this" and the return type of the method
			// is type-compatible. Note that we can't help if the target sets
			// a reference to itself in another returned object.
			retVal = proxy;
		}
		// 返回值为基础类型报错
		else if (retVal == null && returnType != Void.TYPE && returnType.isPrimitive()) {
			throw new AopInvocationException(
					"Null return value from advice does not match primitive return type for: " + method);
		}
		return retVal;
	}
	finally {
		// 释放target资源，由TargetSource子类实现
		if (target != null && !targetSource.isStatic()) {
			// Must have come from TargetSource.
			targetSource.releaseTarget(target);
		}
		// 恢复currentProxy，防止被误用
		if (setProxyContext) {
			// Restore old proxy.
			AopContext.setCurrentProxy(oldProxy);
		}
	}
}

```

在整个调用过程中，需要关注的有几点：

1.  **如果设置exposeProxy，则会设置ThreadLocal级别的currentProxy为当前执行方法的代理对象。可以在方法内使用AopContext.currentProxy()来获取代理对象**。方法执行结束后，会在finally中清除currentProxy防止被误用

2.  拦截器链的获取是一个通用方法，都是调用AdvisedSupport类，并设置了缓存以重用。

    ```
     public List<Object> getInterceptorsAndDynamicInterceptionAdvice(Method method, Class<?> targetClass) {
     	MethodCacheKey cacheKey = new MethodCacheKey(method);
     	List<Object> cached = this.methodCache.get(cacheKey);
     	if (cached == null) {
     		cached = this.advisorChainFactory.getInterceptorsAndDynamicInterceptionAdvice(
     				this, method, targetClass);
     		this.methodCache.put(cacheKey, cached);
     	}
     	return cached;
     }

    ```

真正的调用在DefaultAdvisorChainFactory中，它实现了AdvisorChainFactory接口。通过遍历所有的Advisor切面，如果是PointcutAdvisor，则提取出Pointcut，然后匹配当前类和方法是否适用。另外通过AdvisorAdapterRegistry切面注册适配器将Advisor中的Advice都封装成MethodInteceptor以方便形成拦截器链。

```
public List<Object> getInterceptorsAndDynamicInterceptionAdvice(
		Advised config, Method method, Class<?> targetClass) {

	// This is somewhat tricky... We have to process introductions first,
	// but we need to preserve order in the ultimate list.
	List<Object> interceptorList = new ArrayList<Object>(config.getAdvisors().length);
	Class<?> actualClass = (targetClass != null ? targetClass : method.getDeclaringClass());
	// 是否有引入增强
	boolean hasIntroductions = hasMatchingIntroductions(config, actualClass);
	// 切面适配注册器，封装Advice为Advisor或MethodInterceptor
	AdvisorAdapterRegistry registry = GlobalAdvisorAdapterRegistry.getInstance();

	for (Advisor advisor : config.getAdvisors()) {
		// 切入点切面
		if (advisor instanceof PointcutAdvisor) {
			// Add it conditionally.
			PointcutAdvisor pointcutAdvisor = (PointcutAdvisor) advisor;
			// Advisor是否匹配当前对象
			if (config.isPreFiltered() || pointcutAdvisor.getPointcut().getClassFilter().matches(actualClass)) {
				// 获取advisor所有拦截器
				MethodInterceptor[] interceptors = registry.getInterceptors(advisor);
				MethodMatcher mm = pointcutAdvisor.getPointcut().getMethodMatcher();
				// 当前方法是否使用切入点配置
				if (MethodMatchers.matches(mm, method, actualClass, hasIntroductions)) {
					if (mm.isRuntime()) {
						// Creating a new object instance in the getInterceptors() method
						// isn't a problem as we normally cache created chains.
						for (MethodInterceptor interceptor : interceptors) {
							// 添加动态拦截器
							interceptorList.add(new InterceptorAndDynamicMethodMatcher(interceptor, mm));
						}
					}
					else {
						// 添加普通拦截器
						interceptorList.addAll(Arrays.asList(interceptors));
					}
				}
			}
		}
		// 引入增强单独校验添加
		else if (advisor instanceof IntroductionAdvisor) {
			IntroductionAdvisor ia = (IntroductionAdvisor) advisor;
			if (config.isPreFiltered() || ia.getClassFilter().matches(actualClass)) {
				Interceptor[] interceptors = registry.getInterceptors(advisor);
				interceptorList.addAll(Arrays.asList(interceptors));
			}
		}
		// 其他类型的Advisor直接添加
		else {
			Interceptor[] interceptors = registry.getInterceptors(advisor);
			interceptorList.addAll(Arrays.asList(interceptors));
		}
	}

	return interceptorList;
}

```

3.链式调用，将所有元素封装成ReflectiveMethodInvocation，通过方法proceed进行链式调用

```
    invocation = new ReflectiveMethodInvocation(proxy, target, method, args, targetClass, chain);

	retVal = invocation.proceed();

```

4.Spring对于方法返回this的流式调用也做出了兼容，将返回的this替换为代理对象。

```
	Class<?> returnType = method.getReturnType();
	if (retVal != null && retVal == target && returnType.isInstance(proxy) &&
			!RawTargetAccess.class.isAssignableFrom(method.getDeclaringClass())) {
		// Special case: it returned "this" and the return type of the method
		// is type-compatible. Note that we can't help if the target sets
		// a reference to itself in another returned object.
		retVal = proxy;
	}

```

### CglibAopProxy

**CGLIB代理通过CglibAopProxy来实现**，在Spring4.0时，封装了一个ObjenesisCglibAopProxy，它继承了CglibAopProxy。Objenesis是一个轻量级框架，可以不调用构造函数来创建对象。另外它以代理对象的className为key做了一层cache，多次生成代理时可以提高性能。

CGLIB通过Enhancer类生成字节码对象，然后创建代理对象。来看下getProxy方法

```
public Object getProxy(ClassLoader classLoader) {
	if (logger.isDebugEnabled()) {
		logger.debug("Creating CGLIB proxy: target source is " + this.advised.getTargetSource());
	}

	try {
		Class<?> rootClass = this.advised.getTargetClass();
		Assert.state(rootClass != null, "Target class must be available for creating a CGLIB proxy");

		Class<?> proxySuperClass = rootClass;
		if (ClassUtils.isCglibProxyClass(rootClass)) {
			proxySuperClass = rootClass.getSuperclass();
			Class<?>[] additionalInterfaces = rootClass.getInterfaces();
			for (Class<?> additionalInterface : additionalInterfaces) {
				this.advised.addInterface(additionalInterface);
			}
		}

		// Validate the class, writing log messages as necessary.
		validateClassIfNecessary(proxySuperClass, classLoader);

		// Configure CGLIB Enhancer...
		// 创建Enhancer对象
		Enhancer enhancer = createEnhancer();
		if (classLoader != null) {
			enhancer.setClassLoader(classLoader);
			if (classLoader instanceof SmartClassLoader &&
					((SmartClassLoader) classLoader).isClassReloadable(proxySuperClass)) {
				enhancer.setUseCache(false);
			}
		}
		// 设置目标对象
		enhancer.setSuperclass(proxySuperClass);
		// 设置要实现的接口
		enhancer.setInterfaces(AopProxyUtils.completeProxiedInterfaces(this.advised));
		enhancer.setNamingPolicy(SpringNamingPolicy.INSTANCE);
		enhancer.setStrategy(new UndeclaredThrowableStrategy(UndeclaredThrowableException.class));

		// 返回所有回调类
		Callback[] callbacks = getCallbacks(rootClass);
		Class<?>[] types = new Class<?>[callbacks.length];
		for (int x = 0; x < types.length; x++) {
			types[x] = callbacks[x].getClass();
		}
		// fixedInterceptorMap only populated at this point, after getCallbacks call above
		enhancer.setCallbackFilter(new ProxyCallbackFilter(
				this.advised.getConfigurationOnlyCopy(), this.fixedInterceptorMap, this.fixedInterceptorOffset));
		enhancer.setCallbackTypes(types);

		// Generate the proxy class and create a proxy instance.
		// 生成代理Class并创建代理实例
		return createProxyClassAndInstance(enhancer, callbacks);
	}
	catch (CodeGenerationException ex) {
		throw new AopConfigException("Could not generate CGLIB subclass of class [" +
				this.advised.getTargetClass() + "]: " +
				"Common causes of this problem include using a final class or a non-visible class",
				ex);
	}
	catch (IllegalArgumentException ex) {
		throw new AopConfigException("Could not generate CGLIB subclass of class [" +
				this.advised.getTargetClass() + "]: " +
				"Common causes of this problem include using a final class or a non-visible class",
				ex);
	}
	catch (Exception ex) {
		// TargetSource.getTarget() failed
		throw new AopConfigException("Unexpected AOP exception", ex);
	}
}

```

getProxy方法是调用自CglibAopProxy类的，所做的无非就是创建Enhancer类，并配置目标对象，接口，回调类等，最后通过父类ObjenesisCglibAopProxy的createProxyClassAndInstance来创建或者返回缓存中的代理对象。对于CGLIB的原理这里就不细究了，毕竟本人也未深入了解(_^__^_)。我们重点关注下回调操作，通过getCallbacks方法返回的Callback集合，只用关注下DynamicAdvisedInterceptor，它即是代理实际操作的回调类，回调方法为intercept。

```
public Object intercept(Object proxy, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
		Object oldProxy = null;
		boolean setProxyContext = false;
		Class<?> targetClass = null;
		Object target = null;
		try {
			if (this.advised.exposeProxy) {
				// Make invocation available if necessary.
				oldProxy = AopContext.setCurrentProxy(proxy);
				setProxyContext = true;
			}
			// May be null. Get as late as possible to minimize the time we
			// "own" the target, in case it comes from a pool...
			target = getTarget();
			if (target != null) {
				targetClass = target.getClass();
			}
			List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(method, targetClass);
			Object retVal;
			// Check whether we only have one InvokerInterceptor: that is,
			// no real advice, but just reflective invocation of the target.
			if (chain.isEmpty() && Modifier.isPublic(method.getModifiers())) {
				// We can skip creating a MethodInvocation: just invoke the target directly.
				// Note that the final invoker must be an InvokerInterceptor, so we know
				// it does nothing but a reflective operation on the target, and no hot
				// swapping or fancy proxying.
				retVal = methodProxy.invoke(target, args);
			}
			else {
				// We need to create a method invocation...
				retVal = new CglibMethodInvocation(proxy, target, method, args, targetClass, chain, methodProxy).proceed();
			}
			retVal = processReturnType(proxy, target, method, retVal);
			return retVal;
		}
		finally {
			if (target != null) {
				releaseTarget(target);
			}
			if (setProxyContext) {
				// Restore old proxy.
				AopContext.setCurrentProxy(oldProxy);
			}
		}
	}

```

可以发现DynamicAdvisedInterceptor的intercept方法同JdkDynamicAopProxy的invoke方法几乎相同，最后执行链式调用的CglibMethodInvocation也是ReflectiveMethodInvocation的子类。只是对一些特殊情况选择用其他的Callback来辅助实现。

# 3.总结

看到这里你可能觉得源码还是很复杂啊，是的，任何强大的功能的底层实现离不开对各种情况的考虑以及异常的处理等等。但是优秀的框架会把复杂的实现细节封装起来，而通过简单的架构设计向外部暴露便捷的API。因此在看源码的过程中，不仅要关注一些实现细节，更多地要关注整个架构的设计。对于Spring AOP来说，其实就是AopProxyFactory-AopProxy-Proxy三层结构，把握住这个就把握住了骨架，剩下的就是依附于骨架的血肉。

# 参考
转自：[Spring源码-AOP(四)-ProxyFactory](https://my.oschina.net/u/2377110/blog/1510684)


  [1]: ./images/1551003716766.jpg "1551003716766.jpg"
  [2]: ./images/1551003805705.jpg "1551003805705.jpg"