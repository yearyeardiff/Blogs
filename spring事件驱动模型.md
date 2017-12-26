---
title: spring事件驱动模型
tags: spring,事件驱动模型
grammar_cjkRuby: true
---

* [spring事件驱动模型的结构.](#spring事件驱动模型的结构)
	* [　　1.ApplicationEvent](#1applicationevent)
	* [　　2.ApplicationListener(Observer)](#2applicationlistenerobserver)
	* [　　3.ApplicationContext(publisher)](#3applicationcontextpublisher)
	* [　　4.ApplicationEventMulticaster](#4applicationeventmulticaster)
* [在spring 中使用事件监听机制的Demo](#在spring-中使用事件监听机制的demo)
* [总结](#总结)

　　spring中的事件驱动模型也叫作发布订阅模式,是观察者模式的一个典型的应用。

# spring事件驱动模型的结构.

![结构图][1]

　　首先明确几个spring提供的类的概念

## 　　1.ApplicationEvent


``` java
public abstract class ApplicationEvent extends EventObject {
    private static final long serialVersionUID = 7099057708183571937L;
    private final long timestamp;
    public ApplicationEvent(Object source) {
        super(source);
        this.timestamp = System.currentTimeMillis();
    }
    public final long getTimestamp() {
        return this.timestamp;
    }
}
```

　　ApplicationEvent继承自jdk的EventObject,所有的事件都需要继承ApplicationEvent,并且通过source得到事件源.该类的实现类ApplicationContextEvent表示ApplicaitonContext的容器事件.

## 　　2.ApplicationListener(Observer)

``` java
public interface ApplicationListener<E extends ApplicationEvent> extends EventListener {
    void onApplicationEvent(E event);
}
```


　　ApplicationListener继承自jdk的EventListener,所有的监听器都要实现这个接口,这个接口只有一个onApplicationEvent()方法,该方法接受一个ApplicationEvent或其子类对象作为参数,在方法体中,可以通过不同对Event类的判断来进行相应的处理.当事件触发时所有的监听器都会收到消息,如果你需要对监听器的接收顺序有要求,可是实现该接口的一个实现SmartApplicationListener,通过这个接口可以指定监听器接收事件的顺序.

## 　　3.ApplicationContext(publisher)

　　　事件机制的实现需要三个部分,事件源,事件,事件监听器,在上面介绍的ApplicationEvent就相当于事件,ApplicationListener相当于事件监听器,这里的事件源说的就是applicaitonContext.

　　 ApplicationContext是spring中的全局容器,翻译过来是"应用上下文"的意思,它用来负责读取bean的配置文档,管理bean的加载,维护bean之间的依赖关系,可以说是负责bean的整个生命周期,再通俗一点就是我们平时所说的IOC容器.　

　　 Application作为一个事件源,需要显示的调用publishEvent方法,传入一个ApplicationEvent的实现类对象作为参数,每当ApplicationContext发布ApplicationEvent时,所有的ApplicationListener就会被自动的触发.

　　ApplicationContext接口实现了ApplicationEventPublisher接口,后者有一个很重要的方法:

```java
public interface ApplicationEventPublisher {
    void publishEvent(ApplicationEvent event);
}
```


　　我们常用的ApplicationContext都继承了AbstractApplicationContext,像我们平时常见的ClassPathXmlApplicationContext、XmlWebApplicationContex也都是继承了它,AbstractApplicationcontext是ApplicationContext接口的抽象实现类,在该类中实现了publishEvent方法

```java
    public void publishEvent(ApplicationEvent event) {
        Assert.notNull(event, "Event must not be null");
        if (logger.isTraceEnabled()) {
            logger.trace("Publishing event in " + getDisplayName() + ": " + event);
        }
        getApplicationEventMulticaster().multicastEvent(event);
        if (this.parent != null) {
            this.parent.publishEvent(event);
        }
    }
```

　　在这个方法中,我们看到了一个getApplicationEventMulticaster().这就要牵扯到另一个类ApplicationEventMulticaster.

## 　　4.ApplicationEventMulticaster

　　属于事件广播器,它的作用是把Applicationcontext发布的Event广播给所有的监听器.

　　在AbstractApplicationcontext中有一个applicationEventMulticaster的成员变量,提供了监听器Listener的注册方法.


``` java
public abstract class AbstractApplicationContext extends DefaultResourceLoader
        implements ConfigurableApplicationContext, DisposableBean {

　　private ApplicationEventMulticaster applicationEventMulticaster;
　　protected void registerListeners() {
        // Register statically specified listeners first.
        for (ApplicationListener<?> listener : getApplicationListeners()) {
            getApplicationEventMulticaster().addApplicationListener(listener);
        }
        // Do not initialize FactoryBeans here: We need to leave all regular beans
        // uninitialized to let post-processors apply to them!
        String[] listenerBeanNames = getBeanNamesForType(ApplicationListener.class, true, false);
        for (String lisName : listenerBeanNames) {
            getApplicationEventMulticaster().addApplicationListenerBean(lisName);
        }
    }
}
```

# 在Spring 中使用事件监听机制的Demo

　　1\. 建立事件类,继承applicationEvent



``` java
public class MyEvent extends ApplicationEvent {

    public MyEvent(Object source) {
        super(source);
        System.out.println("my Event");
    }
    public void print(){
        System.out.println("hello spring event[MyEvent]");
    }
}
```

　　2.建立监听类,实现ApplicationListener接口


``` java
public class MyListener  implements ApplicationListener{

    public void onApplicationEvent(ApplicationEvent event) {
        if(event instanceof MyEvent){
            System.out.println("into My Listener");
            MyEvent myEvent=(MyEvent)event;
            myEvent.print();
        }
    }
}
```



这里再建一个监听类

``` java
public class MyListener  implements ApplicationListener{

    public void onApplicationEvent(ApplicationEvent event) {
        if(event instanceof MyEvent){
            System.out.println("into My Listener");
            MyEvent myEvent=(MyEvent)event;
            myEvent.print();
        }
    }
}
```


　　3.创建一个发布事件的类,该类实现ApplicationContextAware接口,得到ApplicationContext对象,使用该对象的publishEvent方法发布事件.



``` java
public class MyPubisher implements ApplicationContextAware {

    private ApplicationContext applicationContext;

    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext=applicationContext;
    }
    public void publishEvent(ApplicationEvent event){
        System.out.println("into My Publisher's method");
        applicationContext.publishEvent(event);
    }
}
```



　　3.在spring配置文件中,注册事件类和监听类,当然使用注解的方式也是一样的.(略)

　　4.测试



``` java
public class MyTest {
    public static void main(String[] args) {
        ApplicationContext context=new ClassPathXmlApplicationContext("classpath:spring/application-database.xml");
        MyPubisher myPubisher=(MyPubisher) context.getBean("myPublisher");
        myPubisher.publishEvent(new MyEvent("1"));
    }
}
```




　　查看控制台打印

> 
> 
> my Event
> 
> into My Publisher's method
> 
> **into My Listener**
> hello spring event[MyEvent]
> **into My second Listener**
> hello spring event[MyEvent]
> 
> 

# 总结

　　spring的事件驱动模型使用的是 观察者模式

　　通过ApplicationEvent抽象类和ApplicationListener接口,可以实现ApplicationContext事件处理

　　监听器在处理Event时,通常会进行判断传入的Event是不是自己所想要处理的,使用instanceof关键字

　　ApplicationEventMulticaster事件广播器实现了监听器的注册,一般不需要我们实现,只需要显示的调用applicationcontext.publisherEvent方法即可


 参考：[spring事件驱动模型--观察者模式在spring中的应用][2]


  [1]: ./images/1512979281891.jpg
  [2]: https://www.cnblogs.com/fingerboy/p/6393644.html