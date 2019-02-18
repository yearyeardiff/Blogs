---
title: spring--aop AOP的四种实现
tags: spring,aop
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

Spring AOP的实现从Spring自身的实现到集成AspectJ的实现，从硬编码到xml配置再到注解的方式，都是随着Spring的更新而不断演进。这一章我将介绍多种不同的实现方式，既为Spring AOP的实现及配置做一个粗略的指南，同时为后续源码的解析做一个引子。

# 1.硬编码(ProxyFactory)

以之前的浏览器举例，有一个Browser接口

```
public interface Browser {

	void visitInternet();

}

```

它的实现ChromeBrowser

```
public class ChromeBrowser implements Browser{

	public void visitInternet() {
		System.out.println("visit YouTube");
	}

}

```

众所周知，为了更自由的上网，需要一个境外服务器作为中转，这里就通过加密(encrypt)和解密(decrypt)两个方法模拟visitInternet方法执行前后的额外动作。

```
// 加密
private void encrypt(){
	System.out.println("encrypt ...");
}

// 解密
private void decrypt(){
	System.out.println("decrypt ...");
}

```

而真正访问时通过一个代理类来操作，使用Spring AOP最原始也是最底层的方式ProxyFactory来实现。另外还需要封装上面两个方法的增强类，分别实现Spring定义的MethodBeforeAdvice和AfterReturningAdvice两个Advice增强接口。

```
public class BrowserBeforeAdvice implements MethodBeforeAdvice{

	public void before(Method method, Object[] args, Object target) throws Throwable {
		encrypt();
	}

	//加密
	private void encrypt(){
		System.out.println("encrypt ...");
	}

}

public class BrowserAfterReturningAdvice implements AfterReturningAdvice{

	public void afterReturning(Object returnValue, Method method, Object[] args, Object target) throws Throwable {
		decrypt();
	}

	//解密
	private void decrypt(){
		System.out.println("decrypt ...");
	}

}

```

我们使用硬编码的方式来实现代理

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

以上的前置增强和后置增强可以通过环绕增强统一处理，不过需要实现org.aopalliance.intercept.MethodInterceptor,它并不是Spring定义的接口，而是来自AOP联盟提供的API。

```
public class BrowserAroundAdvice implements MethodInterceptor{

	public Object invoke(MethodInvocation invocation) throws Throwable {
		encrypt();
		Object retVal = invocation.proceed();
		decrypt();
		return retVal;
	}

	// 加密
	private void encrypt(){
		System.out.println("encrypt ...");
	}

	// 解密
	private void decrypt(){
		System.out.println("decrypt ...");
	}
}

```

上面的

```
// 3.添加前置增强
factory.addAdvice(new BrowserBeforeAdvice());
// 4.添加后置增强
factory.addAdvice(new BrowserAfterReturningAdvice());

```

可以改为

```
// 添加环绕增强
factory.addAdvice(new BrowserAroundAdvice());

```

另外在上面的测试类中，并没有增强(Advice)类的作用范围，也就是说只要Browser接口中的方法都会被代理。如果在Browser接口中增加一个听音乐的方法。

```
public interface Browser {

	void visitInternet();

	void listenToMusic();

}

public class ChromeBrowser implements Browser{

	public void visitInternet() {
		System.out.println("visit YouTube");
	}

	public void listenToMusic(){
		System.out.println("listen to Cranberries");
	}

}

```

而我只想对visitInternet进行代理，可以通过正则表达式的切面类RegexpMethodPointcutAdvisor来设置，其内部使用的Pointcut类为JdkRegexpMethodPointcut。

```
// 创建正则表达式切面类
RegexpMethodPointcutAdvisor advisor = new RegexpMethodPointcutAdvisor();
// 添加环绕增强
advisor.setAdvice(new BrowserAroundAdvice());
// 设置切入点正则表达式
advisor.setPattern("com.lcifn.spring.aop.bean.ChromeBrowser.visitInternet");

```

完整的测试类

```
public class RegexpProxyFactoryTest {

	public static void main(String[] args) {
		// 1.创建代理工厂
		ProxyFactory factory = new ProxyFactory();
		// 2.设置目标对象
		factory.setTarget(new ChromeBrowser());
		// 3.设置代理实现接口
		factory.setInterfaces(new Class[]{Browser.class});
		// 4.创建正则表达式切面类
		RegexpMethodPointcutAdvisor advisor = new RegexpMethodPointcutAdvisor();
		// 5.添加环绕增强
		advisor.setAdvice(new BrowserAroundAdvice());
		// 6.设置切入点正则表达式
		advisor.setPattern("com.lcifn.spring.aop.bean.ChromeBrowser.visitInternet");
		// 7.工厂增加切面
		factory.addAdvisor(advisor);
		// 8.获取代理对象
		Browser browser = (Browser) factory.getProxy();
		browser.visitInternet();
	}
}

```

毕竟硬编码的方式过于繁琐，也不适合项目的开发，还是配置化的方式更加便捷。

# 2.XML配置(ProxyFactoryBean)

在写AOP概念的时候，看Spring的官方文档中对其AOP的定位不是要做最强大的AOP实现，而是通过与IOC容器的结合从而达到便捷的使用。ProxyFactoryBean实现了FactoryBean接口(关于FactoryBean见[FactoryBean](https://my.oschina.net/u/2377110/blog/918659))，从而完美地结合了AOP与IOC。

来看简单的例子

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
	http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
	http://www.springframework.org/schema/aop
	http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">

	<!-- 原始对象 -->
	<bean id="chromeBrowser" class="com.lcifn.spring.aop.bean.ChromeBrowser"/>
	<!-- 环绕增强对象 -->
	<bean id="browserAroundAdvice" class="com.lcifn.spring.aop.advice.BrowserAroundAdvice"></bean>

	<bean id="browserProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
		<!-- 接口 -->
		<property name="interfaces" value="com.lcifn.spring.aop.bean.Browser"/>
		<!-- 要代理的对象 -->
		<property name="target" ref="chromeBrowser"/>
		<!-- 拦截器组 -->
		<property name="interceptorNames">
			<list>
				<value>browserAroundAdvice</value>
			</list>
		</property>
	</bean>
</beans>

```

ProxyFactoryBean相当于ProxyFactory实现了FactoryBean接口，通过IOC动态地创建代理对象。主要配置的属性有：

*   interfaces:代理对象要实现的接口集合，其实也就是原始对象实现的接口集合。所以也可以省略掉，因为Spring会通过原始对象获取其所有的接口。
*   target:原始对象，即要被代理的对象
*   interceptorNames:拦截器名称集合，可以是Advice(增强)或Advisor(切面)的实现类，而最终形成拦截器链时都转化成Advisor。

测试类如下：

```
public class ProxyFactoryBeanTest {

	public static void main(String[] args) {
		ApplicationContext context = new ClassPathXmlApplicationContext("aop/proxyfactorybean.xml");
		Browser browser = (Browser) context.getBean("browserProxy");
		browser.visitInternet();
	}
}

```

可以发现以上所有的代理都是通过接口的方式来接收，也就是说，底层是通过JDK自带的Proxy生成的代理。但是它的代理只能基于接口，如果想对未在接口中定义的方法或者类本身就没有实现接口的方法进行代理，那就要使用CGLIB的方式了。

在ChromeBrowser中增加一个非接口定义的方法

```
public String seeMovie(String movie){
	System.out.println("see a movie:" + movie);
	return movie + " has bean seen";
}

```

通过正则表达式去匹配此方法进行代理，XML配置如下

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
	http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
	http://www.springframework.org/schema/aop
	http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">

	<!-- 原始对象 -->
	<bean id="chromeBrowser" class="com.lcifn.spring.aop.bean.ChromeBrowser"/>
	<!-- 环绕增强对象 -->
	<bean id="browserAroundAdvice" class="com.lcifn.spring.aop.advice.BrowserAroundAdvice"></bean>
	<!-- 切面 -->
	<bean id="regexpAdvisor" class="org.springframework.aop.support.RegexpMethodPointcutAdvisor">
		<property name="advice" ref="browserAroundAdvice"></property>
		<!-- 切入点正则表达式 -->
		<property name="pattern" value="com.lcifn.spring.aop.bean.ChromeBrowser.seeMovie"></property>
	</bean>

	<bean id="browserProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
		<!-- 要代理的对象 -->
		<property name="target" ref="chromeBrowser"/>
		<!-- 拦截器组 -->
		<property name="interceptorNames" value="regexpAdvisor"/>
		<!-- proxyTargetClass -->
		<property name="proxyTargetClass" value="true"></property>
	</bean>
</beans>

```

对ProxyFactoryBean的配置新增proxyTargetClass属性，网上对此属性的解释是强制使用CGLIB代理对象，而在Spring的文档中对此的解释则是

> 
> 
> force proxying for the TargetSource's exposed target class. If that target class is an interface, a JDK proxy will be created for the given interface. If that target class is any other class, a CGLIB proxy will be created for the given class.
> 
> 

即强制暴露TargetSource中的目标class，如果此class是接口，则使用JDK代理，如果是类对象，则使用CGLIB代理。但是正常情况下，都是使用CGLIB代理。

来看测试类

```
public class RegexpProxyFactoryBeanTest {

	public static void main(String[] args) {
		ApplicationContext context = new ClassPathXmlApplicationContext("aop/proxyfactorybean-regexp.xml");
		ChromeBrowser browser = (ChromeBrowser) context.getBean("browserProxy");
		browser.seeMovie("The Great Wall");
	}
}

```

此时已经能解决大部分的问题了，但AOP所处理的就是多个业务中相似的非逻辑相关的问题。因而ProxyFactoryBean的配置会有很多，太多的XML配置总会很麻烦。Spring设计时也考虑到这个问题，因而有了自动代理。

# 3.自动代理(DefaultAdvisorAutoProxyCreator)

自动代理，即自动发现Advisor(切面)配置，意味着不再需要一个个地配置ProxyFactoryBean，只需要配置特定的切面即可。来看配置：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
	http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
	http://www.springframework.org/schema/aop
	http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">

	<!-- 原始对象 -->
	<bean id="chromeBrowser" class="com.lcifn.spring.aop.bean.ChromeBrowser"/>
	<!-- 环绕增强对象 -->
	<bean id="browserAroundAdvice" class="com.lcifn.spring.aop.advice.BrowserAroundAdvice"></bean>
	<!-- 切面 -->
	<bean id="regexpAdvisor" class="org.springframework.aop.support.RegexpMethodPointcutAdvisor">
		<property name="advice" ref="browserAroundAdvice"></property>
		<!-- 切入点正则表达式 -->
		<property name="pattern" value="com.lcifn.spring.aop.bean.ChromeBrowser.visit.*"></property>
	</bean>

	<!-- 自动扫描切面代理类 -->
	<bean class="org.springframework.aop.framework.autoproxy.DefaultAdvisorAutoProxyCreator">
		<property name="optimize" value="true"></property>
	</bean>
</beans>

```

此时如果增加一种AOP逻辑，只需要配置一个新的切面类，指定要代理的切入点和增强类即可。自动代理的测试同ProxyFactoryBean相同，就不展示了。

这里涉及到一个新的属性optimize，此属性在使用JDK还是CGLIB代理的判断上同proxyTargetClass一致。但其文档上阐述了一些其他信息。

> 
> 
> Set whether proxies should perform aggressive optimizations.The exact meaning of "aggressive optimizations" will differ between proxies, but there is usually some tradeoff.
> 
> 

> 
> 
> 用来设置代理时是否使用激进的优化策略。但不同的代理间的优化策略也不相同，通常情况只是一种权衡。
> 
> 

> 
> 
> For example, optimization will usually mean that advice changes won't take effect after a proxy has been created. For this reason, optimization is disabled by default. An optimize value of "true" may be ignored if other settings preclude optimization: for example, if "exposeProxy" is set to "true" and that's not compatible with the optimization.
> 
> 

> 
> 
> 比如，优化通常意味着对于已经生成的代理，增强(Advice)的变化无法对其产生影响。鉴于此，默认优化配置是禁止的。另外如果其他配置阻止了优化策略的，optimize=true将被忽略。比如exposeProxy=true与优化策略是不兼容的。
> 
> 

将自动代理类DefaultAdvisorAutoProxyCreator的optimize属性设置为true，是因为并不清楚代理的切面是什么情况，因而需要Spring帮助我们对各种情况做一些权衡。

做到这里，当年Spring的罗大侠觉得这下应该满足你们这群用户了吧。可是很多用户又提出新的问题：业务越来越复杂，我们需要更加精细的控制。另外JDK5的出现让人们意识到注解相比于XML更简洁。因此，罗大侠又说，ok，都满足你们，集成AspectJ，支持注解，你们满意了吧。

# 4.Spring+AspectJ+注解

Spring3.0的发布通过配置类让XML配置可以完美地被取代，而AOP的配置也可以通过注解的方式更加便捷的设置。下面还以浏览器举例，来看注解的AOP如何配置。

```
@Component
[@Aspect](https://my.oschina.net/aspect)
public class AspectJAnnotationBrowserAroundAdvice {
	@Pointcut("execution(* com.lcifn.spring.aop.bean.ChromeBrowser.*(..))")
	private void pointcut(){

	}

	@Around(value="pointcut()")
	public Object aroundIntercept(ProceedingJoinPoint pjp) throws Throwable{
		encrypt();
		Object retVal = pjp.proceed();
		decrypt();
		return retVal;
	}

	// 加密
	private void encrypt(){
		System.out.println("encrypt ...");
	}

	// 解密
	private void decrypt(){
		System.out.println("decrypt ...");
	}
}

```

*   @Aspect作用在类上，标识这是一个切面类。
*   @Pointcut一般标识在一个空方法上，值为aspectj的连接点表达式。关于连接点表达式这里就不详述了。
*   @Around标识此方法为环绕增强，值为@Pointcut标识的方法名，或者直接使用连接点表达式也可。

比如

```
@Around("execution(* com.lcifn.spring.aop.bean.ChromeBrowser.*(..))")

```

类上的@Component注解表示它被Spring所管理。当然要使这些注解生效，也需要启用相关配置，来看配置类。

```
@Configuration
@ComponentScan("com.lcifn.spring.aop.bean,com.lcifn.spring.aop.advice")
@EnableAspectJAutoProxy(proxyTargetClass=true)
public class AppConfig {

}

```

*   @Configuration标识这是Spring的配置类
*   @ComponentScan则是注解方式的类扫描，值为要扫描的包路径
*   @EnableAspectJAutoProxy表示使用AspectJ注解，proxyTargetClass=true标识启用CGLIB代理

没有了XML配置，启动Spring容器当然不能再用ClassPathXmlApplicationContext类，而是使用AnnotationConfigApplicationContext。在创建对象时传入配置类的Class对象作为参数。

```
public class AspectJAnnotationAopTest {

	public static void main(String[] args) {
		ApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
		ChromeBrowser browser = (ChromeBrowser) context.getBean("chromeBrowser");
		browser.visitInternet();
		browser.listenToMusic();
		browser.seeMovie("The Great Wall");
	}
}

```

有人可能觉得因为历史的缘故或其他原因，不想使用AspectJ注解配置AOP，而是通过XML配置，可不可以呢？Spring也考虑到此种情况了。

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
	http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
	http://www.springframework.org/schema/aop
	http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">

	<!-- 原始对象 -->
	<bean id="chromeBrowser" class="com.lcifn.spring.aop.bean.ChromeBrowser"/>
	<!-- 环绕增强对象 -->
	<bean id="aspectjBrowserAroundAdvice" class="com.lcifn.spring.aop.advice.AspectJBrowserAroundAdvice"></bean>

	<!-- aspectj aop 配置 -->
	<aop:config>
		<!-- 切入点配置 -->
		<aop:pointcut id="browserPointcut" expression="execution(* com.lcifn.spring.aop.bean.*.*(..))"/>
		<aop:aspect ref="aspectjBrowserAroundAdvice">
			<!-- 环绕增强 -->
			<aop:around method="aroundIntercept" pointcut-ref="browserPointcut" />
		</aop:aspect>
	</aop:config>
</beans>

```

通过[aop:config](aop:config)标签及其子标签配置，其中[aop:pointcut](aop:pointcut)切入点的配置可以和[aop:aspect](aop:aspect)同级，这样可以被多个aspect重复使用，也可以配置再[aop:aspect](aop:aspect)内部，只被单个aspect使用。

如果存在外部的advice配置，比如事务管理的[tx:advice](tx:advice)，则可以通过[aop:advisor](aop:advisor)进行整合。这里也不详细介绍了。

上面介绍了纯注解和纯XML两种方式，但实际项目中往往是简单的XML+注解的方式。AOP的配置使用注解，同纯注解中的AspectJAnnotationBrowserAroundAdvice类一致，而不使用配置类，启用XML配置的方式。

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
	http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
	http://www.springframework.org/schema/context
    http://www.springframework.org/schema/context/spring-context-3.0.xsd
	http://www.springframework.org/schema/aop
	http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
	<!-- 类扫描 -->
	<context:component-scan base-package="com.lcifn.spring.aop.bean,com.lcifn.spring.aop.advice"/>
	<!-- 启用AspectJ注解 -->
	<aop:aspectj-autoproxy/>
</beans>

```

可以发现此时的XML配置变得特别的简单且能兼容历史，而注解使用也是便捷，因而很多人喜欢采用此种方式也就可以理解。

对于Spring AOP的增强，本文都是采用AroundAdvice环绕增强来举例，对于其他的增强以他人的一个表格简单总结下。而对于引入增强(IntroductionAdvice)后续会有单独的章节介绍。

| 增强类型 | 基于 AOP 接口 | 基于 @Aspect | 基于 [aop:config](aop:config) |
| --- | --- | --- | --- |
| Before Advice（前置增强） | MethodBeforeAdvice | @Before | [aop:before](aop:before) |
| AfterReturningAdvice（后置增强） | AfterReturningAdvice | @AfterReturning | [aop:after-returning](aop:after-returning) |
| AfterAdvice(Finally增强) | 无 | @After | [aop:after](aop:after) |
| AroundAdvice（环绕增强） | MethodInterceptor | @Around | [aop:around](aop:around) |
| ThrowsAdvice（抛出增强） | ThrowsAdvice | @AfterThrowing | [aop:after-throwing](aop:after-throwing) |
| IntroductionAdvice（引入增强） | DelegatingIntroductionInterceptor | @DeclareParents | [aop:declare-parents](aop:declare-parents) |

本文介绍了Spring AOP的各种实现，从ProxyFactory, 到ProxyFactoryBean，再到自动代理DefaultAdvisorAutoProxyCreator，最后到与AspectJ的结合。现在可能很少人会使用前三种方式来配置AOP，但了解这些实现能够帮助我们更好地理解Spring AOP的实现原理和架构设计。**我们研究一个框架的使用，实现乃至于源码，更多地应该理解它的整体架构以及设计理念，尤其是一个设计优秀的框架。**希望通过对优秀的框架地学习，来提升自己的编码水平甚至软件架构水平。后面的章节会深入Spring AOP的源码，希望通过对它的学习能够进一步地提升自己，也希望看文章的同学们也能够同我一起加油！

参考文档：

1.[https://my.oschina.net/huangyong/blog/161402](https://my.oschina.net/huangyong/blog/161402)


# 参考
转自：[Spring源码-AOP(三)-Spring AOP的四种实现](https://my.oschina.net/u/2377110/blog/1507532#h1_3)