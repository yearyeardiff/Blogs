---
title: dubbo---spi 
tags: dubbo,spi,源码解析
grammar_cjkRuby: true
---

# 为什么dubbo不采用JDK的SPI？

 - JDK标准的SPI会一次性实例化扩展点所有实现，如果有扩展实现初始化很耗时，但如果没用上也加载，会很浪费资源.
 - 增加了对扩展点IoC和AOP的支持，一个扩展点可以直接setter注入其它扩展点!
# dubbo spi  有哪些约定？
 - spi 文件 存储路径 在 META-INF\dubbo\internal 目录下 并且文件名为接口的全路径名 就是=接口的包名+接口名
 - 每个spi 文件里面的格式定义为： 扩展名=具体的类名，例如 dubbo=com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol

# dubbo spi
dubbo spi 的目的：获取一个指定实现类的对象。
途径：ExtensionLoader.getExtension(String name)
实现路径：

 - getExtensionLoader(Class&lt;T&gt; type) 就是为该接口**new一个ExtensionLoader**，然后缓存起来。
 - getAdaptiveExtension()获取一个扩展类，**如果@Adaptive注解在类上就是一个装饰类；如果注解在方法上就是一个动态代理类**，例如    Protocol$Adaptive对象。
 - getExtension(String name) 获取一个指定对象。

-----------------------ExtensionLoader.getExtensionLoader(Class&lt;T&gt;type)
入口：

``` java
com.alibaba.dubbo.container.Main.main(args);
	-->private static final ExtensionLoader<Container> loader = ExtensionLoader.getExtensionLoader(Container.class);
```
调用过程：

``` java
ExtensionLoader.getExtensionLoader(Container.class)
	-->new ExtensionLoader<T>(type)
		-->this.type = type;
	    -->objectFactory = (type == ExtensionFactory.class ? null : ExtensionLoader.getExtensionLoader(ExtensionFactory.class).getAdaptiveExtension());
			-->ExtensionLoader.getExtensionLoader(ExtensionFactory.class).getAdaptiveExtension()
				-->this.type = type;
				-->objectFactory =null;
```

执行以上代码完成了2个属性的初始化:

 1. 每个一个ExtensionLoader都包含了2个值 type 和 objectFactory;  
    Class&lt;?&gt; type；//构造器  初始化时要得到的接口名   
	ExtensionFactory objectFactory//构造器  初始化时 AdaptiveExtensionFactory[SpiExtensionFactory,SpringExtensionFactory]
 2. new 一个ExtensionLoader 存储在ConcurrentMap&lt;Class&lt;?&gt;, ExtensionLoader&lt;?&gt;&gt; EXTENSION_LOADERS

关于这个objectFactory的一些细节：

 1. objectFactory就是ExtensionFactory，它也是通过ExtensionLoader.getExtensionLoader(ExtensionFactory.class)来实现的，但是它的objectFactory=null
 2. objectFactory作用，它就是**为dubbo的IOC提供所有对象**。

-----------------------getAdaptiveExtension()
adaptive注解在类和方法上的区别:
 1. 注解在类上:代表人工实现编码，即实现了一个装饰类，例如：ExtensionFactory
 2. 注解在方法是：代表自动生成和编译的adaptive类，例如：Protocol$Adaptive
 
入口：

``` java
public class ServiceBean<T> extends ServiceConfig<T> 
public class ServiceConfig<T> extends AbstractServiceConfig
		-->private static final Protocol protocol = ExtensionLoader.getExtensionLoader(Protocol.class).getAdaptiveExtension();
```

调用过程：

``` java
//
-->getAdaptiveExtension()//为cachedAdaptiveInstance赋值
	-->createAdaptiveExtension()
		-->getAdaptiveExtensionClass()
			-->getExtensionClasses()//为cachedClasses 赋值
				-->loadExtensionClasses()
					-->loadFile
			-->createAdaptiveExtensionClass()//自动生成和编译一个动态的adpative类，这个类是一个代理类
				-->ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.common.compiler.Compiler.class).getAdaptiveExtension()
				-->compiler.compile(code, classLoader)
		-->injectExtension()//作用：进入IOC的反转控制模式，实现了动态入注
```

        
          
关于loadfile的一些细节

 - 目的：通过把配置文件META-INF/dubbo/internal/com.alibaba.dubbo.rpc.Protocol的内容，存储在缓存变量里面。
 - cachedAdaptiveClass//如果这个class含有adative注解就赋值，例如ExtensionFactory，而例如Protocol在这个环节是没有的。
 - cachedWrapperClasses//只有当该class无adative注解，并且构造函数包含目标接口（type）类型，
   例如protocol里面的spi就只有ProtocolFilterWrapper和ProtocolListenerWrapper能命中
 - cachedActivates//剩下的类，包含Activate注解
 - cachedNames//剩下的类就存储在这里。

``` java
package <扩展点接口所在包>;
 
public class <扩展点接口名>$Adpative implements <扩展点接口> {
    public <有@Adaptive注解的接口方法>(<方法参数>) {
        if(是否有URL类型方法参数?) 使用该URL参数
        else if(是否有方法类型上有URL属性) 使用该URL属性
        # <else 在加载扩展点生成自适应扩展点类时抛异常，即加载扩展点失败！>
         
        if(获取的URL == null) {
            throw new IllegalArgumentException("url == null");
        }
 
              根据@Adaptive注解上声明的Key的顺序，从URL获致Value，作为实际扩展点名。
               如URL没有Value，则使用缺省扩展点实现。如没有扩展点， throw new IllegalStateException("Fail to get extension");
 
               在扩展点实现调用该方法，并返回结果。
    }
 
    public <有@Adaptive注解的接口方法>(<方法参数>) {
        throw new UnsupportedOperationException("is not adaptive method!");
    }
}
```
-----------------------getExtension(String name)
入口：

``` java
//Protocol$Adpative
com.alibaba.dubbo.rpc.Protocol extension = (com.alibaba.dubbo.rpc.Protocol) ExtensionLoader
				.getExtensionLoader(com.alibaba.dubbo.rpc.Protocol.class)
				.getExtension(extName);
```

调用过程：

``` java
getExtension(String name) //指定对象缓存在cachedInstances；get出来的对象wrapper对象，例如protocol就是ProtocolFilterWrapper和ProtocolListenerWrapper其中一个。
	-->createExtension(String name)
		-->getExtensionClasses()//读取该类型的spi配置文件缓存起来
		-->injectExtension(T instance)//dubbo的IOC反转控制，就是从spi和spring里面提取对象赋值。
			-->objectFactory.getExtension(pt, property)
				-->SpiExtensionFactory.getExtension(type, name)
					-->ExtensionLoader.getExtensionLoader(type)
					-->loader.getAdaptiveExtension()
				-->SpringExtensionFactory.getExtension(type, name)
					-->context.getBean(name)
		-->injectExtension((T) wrapperClass.getConstructor(type).newInstance(instance))//AOP的简单设计
```
