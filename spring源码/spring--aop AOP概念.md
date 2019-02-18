---
title: spring--aop AOP概念
tags: 新建,模板,小书匠
grammar_cjkRuby: true
---

1.  [Spring源码-AOP(一)-代理模式](https://my.oschina.net/u/2377110/blog/1504596)
2.  [Spring源码-AOP(二)-AOP概念](https://my.oschina.net/u/2377110/blog/1506098)
3.  [Spring源码-AOP(三)-Spring AOP的四种实现](https://my.oschina.net/u/2377110/blog/1507532)
4.  [Spring源码-AOP(四)-ProxyFactory](https://my.oschina.net/u/2377110/blog/1510684)
5.  [Spring源码-AOP(五)-ProxyFactoryBean](https://my.oschina.net/u/2377110/blog/1512222)
6.  [Spring源码-AOP(六)-自动代理与DefaultAdvisorAutoProxyCreator](https://my.oschina.net/u/2377110/blog/1517915)
7.  [Spring源码-AOP(七)-整合AspectJ](https://my.oschina.net/u/2377110/blog/1529575)

# 1.AOP概念

AOP中文翻译为面向方面编程或面向切面编程，维基百科对它的解释是

> 
> 
> AOP指一种程序设计范型，该范型以一种称为aspect(切面)的语言构造为基础，切面是一种新的**模块化机制**，用来描述分散在对象、类或函数中的**横切关注点**(crosscutting concern)。
> 
> 

谈到模块化机制，自然会想到OOP(面向对象编程)。OOP也是一种模块化的方法，它将数据和处理方法组合在一起，摆脱了函数式中数据杂乱无章的场景，使得程序的功能整齐且清晰，并且通过设计类的继承关系让代码得以重用，进一步提高开发效率。之后出现的多种设计模式使得程序设计更加便捷方便。

然而世界是复杂的，尽管OOP已经能够解决大部分的问题，还是存在一些非强业务相关的通用功能，明明大家都需要，一旦要归类却发现很复杂，往往最后写出来一个工具类。这些功能就如同城市中的水电交通一般，渗透到家家户户中，却不能交由每家每户自己来维护。这些功能就像城市的一个个切面，需要一个统筹管理的方式。这个就是AOP形成的原因。

而什么叫横切关注点？先解释下关注点，就是对软件工程有意义的小的，可管理的可描述的软件组成部分。太拗口了对不对，我的理解就是一个操作一个方法都是对一个关注点的实现，比如插入订单，扣减库存，记录日志等等。而有些关注点是软件的核心功能，称为主关注点，比如插入订单，有些关注点则弥散在软件内部，比如记录日志，这些关注点同许多不同的主关注点都有交集，称为横切关注点。**主关注点大都通过OOP的方式去设计更加清晰，而从主关注点中分离出横切关注点则就是面向切面的程序设计的核心概念。**

> 
> 
> 分离关注点使得解决特定领域问题的代码从业务逻辑中独立出来，业务逻辑的代码中不再含有针对特定领域问题代码的调用，业务逻辑同特定领域问题的关系通过切面来封装、维护，这样原本分散在整个应用程序中的变动就可以很好的管理起来。
> 
> 

维基百科中对面向切面编程的操作方式给了很专业的解说。而当前已经出现了AOP的特定实现或AOP相关技术，比如

*   AspectJ：源代码和字节码级别的编织器，需用使用Aspect语言
*   AspectWerkz：AOP框架，使用字节码动态编织器和XML配置
*   JBoss-AOP:基于拦截器和元数据的AOP框架，运行在JBoss应用服务器上
*   BCEL(Byte-Code Engineering Library):Java字节码操作类库
*   Javassist：Java字节码操作类库

同时有一个AOP联盟对AOP做了一个抽象和规范，形成了一个三层的代表性架构，以及一个通用的AOP API，这个API就是经常使用的aopalliance-api-1.0.jar。它定义了AOP的几个通用接口：

*   连接点(Join Point)：程序执行过程中的某个点，如方法的调用或异常的处理
*   增强(Advice)：对特定连接点的动作的扩展或改变
*   拦截器(Inteceptor)：继承了Advice接口，增强(Advice)模型的封装，一般围绕连接点形成拦截器链
*   调用(Invocation)：继承了JoinPoint接口，指围绕连接点的拦截器触发的调用

而对于增强(Advice)，通常又分为以下几种类型

1.  前置增强(Before advice)：在连接点之前执行，它不能阻止流程继续执行(除非抛出异常)
2.  后置增强(After returning advice)：连接点正常完成后将被执行
3.  最终增强(After finally advice)：无论连接点是否正常执行完成，最后都将被执行(相当于finally语句)
4.  抛出增强(After throwing advice)：当方法抛出一个异常时将被执行
5.  环绕增强(Around advice)：最强大的增强方式，围绕连接点的增强。它可以在方法执行前后触发自定义行为，甚至可以选择是否执行原方法以及通过定义自己的返回值或抛出异常来提前结束方法执行。

# 2.Spring AOP

在AOP框架的实现上，在Spring之前已经已有很多，但Spring做出了一些独特的创新。

1.  完全由java实现，无须特殊的编译过程。无论是AspectJ还是JBoss-AOP，都需要特定的编译器。对于追求便捷的开发者来说，无疑并不是最优的。
2.  集成IOC容器，从而解决企业应用上的通用问题。这点上，Spring并不是最完善的AOP框架，但是其自身的AOP实现以及同AspectJ的集成，已经能覆盖从简单到复杂的绝大部分使用场景，而注解的使用更是大大简化了AOP的配置。

而Spring AOP在实现过程中，对Aop联盟定义的API进行了扩展和增强。

*   增强(Advice)：沿用AOP联盟的接口
*   切点(Pointcut)：相当于连接点(Join Point)，增加了getClassFilter和getMethodMatcher两个接口方法，用于对不同Advice的所作用的横切关注点的过滤和匹配。
*   切面(Advisor)：结合增强与切点，形成切面。

而对于AOP的具体实现，Spring AOP默认使用JDK的动态代理来代理接口。而对于没有实现接口的类，或非接口中的方法，则通过CGLIB来实现代理。**通过Advisor封装Advice和Pointcut并初始化成拦截器链，当方法调用请求时，匹配其所围绕的所有Advisor，然后按顺序执行，从而达到面向切面编程的核心，分离出横切关注点进行统一配置与管理**。具体的实现方式将在之后的章节里详细介绍。

# 参考
转自：[Spring源码-AOP(二)-AOP概念 ](https://my.oschina.net/u/2377110/blog/1506098)