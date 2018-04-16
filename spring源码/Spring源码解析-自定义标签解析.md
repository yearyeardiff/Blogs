---
title: Spring源码解析-自定义标签解析
tags: spring,自定义标签
grammar_cjkRuby: true
---
# 自定义标签配置步骤

 - 创建一个需要扩展的组件。
 - 定义一个xsd文件描述组件内容。
 - 创建一个文件，实现BeanDefinitionParser接口，用来解析xsd文件中的定义和组件定义。
 - 创建一个handle文件，扩展自NamespaceHandlerSupport，目的是将组件注册到spring容器。
 - 编写spring.handlers和spring.schemas文件，这两个文件的存放位置默认在工程的/META-INF/文件夹下。

# Demo

## 创建接收配置的POJO

```
public class RpcService implements Serializable{

    // 协议名称
    private String contact;

    // 服务名称
    private String serviceName;

    // 服务实现
    private String serviceImplName;

    public RpcService(){

    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getServiceImpl() {
        return serviceImplName;
    }

    public void setServiceImplName(String serviceImplName) {
        this.serviceImplName = serviceImplName;
    }

    @Override
    public String toString() {
        return "RpcService{" +
                "contact='" + contact + '\'' +
                ", serviceName='" + serviceName + '\'' +
                ", serviceImplName='" + serviceImplName + '\'' +
                '}';
    }
}
```

```
public class UserInfoService {

    private String name = "xu";

    private int age = 18;

    public UserInfoService(){}

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    @Override
    public String toString() {
        return "UserInfoService{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

## 元素的XSD文件

```
<?xml version="1.0" encoding="UTF-8"?>

<schema xmlns="http://www.w3.org/2001/XMLSchema"
        targetNamespace="http://www.qbb.com/schema/qbb"
        xmlns:tns="http://www.qbb.com/schema/qbb"
        elementFormDefault="qualified">

    <element name="service-publish">
        <complexType>
            <attribute name="id" type="string" default="" />
            <attribute name="contact" type="string" default="" />
            <attribute name="serviceName" type="string" default="" />
            <attribute name="serviceImplName" type="string" default="" />
        </complexType>
    </element>

</schema>
```

##  Handler处理

```
public class RpcServiceNamespaceHandler extends NamespaceHandlerSupport {

    @Override
    public void init() {
        registerBeanDefinitionParser("service-publish", new RpcServicePublishBeanDefinitionParser());
    }
}
```

## BeanDefinitionParser

```
public class RpcServicePublishBeanDefinitionParser extends AbstractSingleBeanDefinitionParser {

    @Override
    protected void doParse(Element element, BeanDefinitionBuilder builder) {
        String contact = element.getAttribute("contact");
        String serviceName = element.getAttribute("serviceName");
        String serviceImplName = element.getAttribute("serviceImplName");
        if (StringUtils.hasText(contact)){
            builder.addPropertyValue("contact", contact);
        }

        if (StringUtils.hasText(serviceName)){
            builder.addPropertyValue("serviceName", serviceName);
        }

        if (StringUtils.hasText(serviceImplName)){
            builder.addPropertyValue("serviceImplName", serviceImplName);
        }
    }

    @Override
    protected Class<?> getBeanClass(Element element) {
        return RpcService.class;
    }

    @Override
    protected String getBeanClassName(Element element) {
        return RpcService.class.getSimpleName();
    }

}
```

## spring.handlers和spring.schemals

spring.handlers

```
http\://www.qbb.com/schema/qbb=qbb.rpc.RpcServiceNamespaceHandler1
```

spring.schemals

```
http\://www.qbb.com/schema/qbb.xsd=META-INF/qbb-rpc.xsd1
```

注意这2个文件要放在META-INF下，要不把上面这些都打jar，要不META-INF放到class目录去，否则找不到。

## Test

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:rpc="http://www.qbb.com/schema/qbb"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       http://www.qbb.com/schema/qbb
       http://www.qbb.com/schema/qbb.xsd">

    <rpc:service-publish id="userInfoService" contact="UserInfoCenter" serviceName="UserInfoQuery"
                         serviceImplName="qbb.rpc.UserInfoService"/>

</beans>
```

注意添加，我的是Intellij，eclipse应该也有地方添加：
Intellij：
![添加xsd][1]

```
public class MyBeanTest {

    public static void main(String[] args) throws ClassNotFoundException, IllegalAccessException, InstantiationException {
        BeanFactory ctx = new XmlBeanFactory(new ClassPathResource("spring.xml"));

        RpcService rpcService = ctx.getBean("userInfoService",RpcService.class);

        System.out.println(rpcService);

        String rpcServiceImplName = rpcService.getServiceImpl();

        UserInfoService userInfoService = (UserInfoService)Class.forName(rpcServiceImplName).newInstance();

        System.out.println(userInfoService);

    }
}
```
# 自定义标签解析时序图
![自定义标签解析时序图][2]
# 源码解析

之前看beanfactory的解析的时候，解析标签的时候，会区分是默认的namespaces还是自定义的：

```
//DefaultBeanDefinitionDocumentReader
protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
    // 默认beans标签
    if (delegate.isDefaultNamespace(root)) {
        NodeList nl = root.getChildNodes();
        for (int i = 0; i < nl.getLength(); i++) {
            Node node = nl.item(i);
            if (node instanceof Element) {
                Element ele = (Element) node;
                if (delegate.isDefaultNamespace(ele)) {
                    parseDefaultElement(ele, delegate);
                }
                else {
                    delegate.parseCustomElement(ele);
                }
            }
        }
    }
    else {
        //自定义标签
        delegate.parseCustomElement(root);
    }
}
```

还是委托BeanDefinitionParserDelegate处理：

```

public BeanDefinition parseCustomElement(Element ele) {
    return parseCustomElement(ele, null);
}

public BeanDefinition parseCustomElement(Element ele, BeanDefinition containingBd) {
    // 获取uri
    String namespaceUri = getNamespaceURI(ele);
    // 根据uri获取处理handler
    NamespaceHandler handler = this.readerContext.getNamespaceHandlerResolver().resolve(namespaceUri);
    if (handler == null) {
        error("Unable to locate Spring NamespaceHandler for XML schema namespace [" + namespaceUri + "]", ele);
        return null;
    }
    // 解析标签，返回对应的beanDefinition
    return handler.parse(ele, new ParserContext(this.readerContext, this, containingBd));
}
```

## getNamespaceHandlerResolver()-resolve

```
//DefaultNamespaceHandlerResolver
//DefaultNamespaceHandlerResolver
public NamespaceHandler resolve(String namespaceUri) {
    //获取META-INF/spring.handlers所有配置的namespace的handler
    Map<String, Object> handlerMappings = getHandlerMappings();
    //获取到自定义标签解析的handler
    Object handlerOrClassName = handlerMappings.get(namespaceUri);
    if (handlerOrClassName == null) {
        return null;
    }
    else if (handlerOrClassName instanceof NamespaceHandler) {
        return (NamespaceHandler) handlerOrClassName;
    }
    else {
        String className = (String) handlerOrClassName;
        try {
            Class<?> handlerClass = ClassUtils.forName(className, this.classLoader);
            //如果不是NamespaceHandle的子类的话，抛异常
            if (!NamespaceHandler.class.isAssignableFrom(handlerClass)) {
                throw new FatalBeanException("Class [" + className + "] for namespace [" + namespaceUri +
                        "] does not implement the [" + NamespaceHandler.class.getName() + "] interface");
            }
            //实例化NamespaceHandler
            NamespaceHandler namespaceHandler = (NamespaceHandler) BeanUtils.instantiateClass(handlerClass);
            //调用初始化注册beanDefinitionParser
            namespaceHandler.init();
            handlerMappings.put(namespaceUri, namespaceHandler);
            return namespaceHandler;
        }
        catch (ClassNotFoundException ex) {
            throw new FatalBeanException("NamespaceHandler class [" + className + "] for namespace [" +
                    namespaceUri + "] not found", ex);
        }
        catch (LinkageError err) {
            throw new FatalBeanException("Invalid NamespaceHandler class [" + className + "] for namespace [" +
                    namespaceUri + "]: problem with handler class file or dependent class", err);
        }
    }
}

//获取META-INF/spring.handlers所有配置的namespace的handler
private Map<String, Object> getHandlerMappings() {
    if (this.handlerMappings == null) {
        synchronized (this) {
            if (this.handlerMappings == null) {
                try {
                    //handlerMappingsLocation默认是META-INF/spring.handlers
                    Properties mappings =
                            PropertiesLoaderUtils.loadAllProperties(this.handlerMappingsLocation, this.classLoader);
                    if (logger.isDebugEnabled()) {
                        logger.debug("Loaded NamespaceHandler mappings: " + mappings);
                    }
                    Map<String, Object> handlerMappings = new ConcurrentHashMap<String, Object>();
                    CollectionUtils.mergePropertiesIntoMap(mappings, handlerMappings);
                    this.handlerMappings = handlerMappings;
                }
                catch (IOException ex) {
                    throw new IllegalStateException(
                            "Unable to load NamespaceHandler mappings from location [" + this.handlerMappingsLocation + "]", ex);
                }
            }
        }
    }
    return this.handlerMappings;
}
```

到这里获取到处理自定义标签的NamespaceHandler。

## NamespaceHandler-parse

```
//NamespaceHandlerSupport
public BeanDefinition parse(Element element, ParserContext parserContext) {
    return findParserForElement(element, parserContext).parse(element, parserContext);
}

// 获取对应的beanDefinitionParse来解析对应的标签
private BeanDefinitionParser findParserForElement(Element element, ParserContext parserContext) {
    String localName = parserContext.getDelegate().getLocalName(element);
    //this.parsers需要我们在NamespaceHandler的init注册进来
    BeanDefinitionParser parser = this.parsers.get(localName);
    if (parser == null) {
        parserContext.getReaderContext().fatal(
                "Cannot locate BeanDefinitionParser for element [" + localName + "]", element);
    }
    return parser;
}

//NamespaceHandler的init注册自定义标签的beanDefinitionParse
protected final void registerBeanDefinitionParser(String elementName, BeanDefinitionParser parser) {
    this.parsers.put(elementName, parser);
}
```

看下BeanDefinition的parser方法：

```
//AbstractBeanDefinitionParser
public final BeanDefinition parse(Element element, ParserContext parserContext) {
    //子类继承覆盖parseInternal完成解析BeanDefinition
    AbstractBeanDefinition definition = parseInternal(element, parserContext);
    if (definition != null && !parserContext.isNested()) {
        try {
            //bean的id，可以通过覆盖shouldGenerateId返回true，选择spring自己生成，要不然就自定义标签里面自己提供一个id
            String id = resolveId(element, definition, parserContext);
            if (!StringUtils.hasText(id)) {
                parserContext.getReaderContext().error(
                        "Id is required for element '" + parserContext.getDelegate().getLocalName(element)
                                + "' when used as a top-level tag", element);
            }
            String[] aliases = new String[0];
            String name = element.getAttribute(NAME_ATTRIBUTE);
            if (StringUtils.hasLength(name)) {
                aliases = StringUtils.trimArrayElements(StringUtils.commaDelimitedListToStringArray(name));
            }
            BeanDefinitionHolder holder = new BeanDefinitionHolder(definition, id, aliases);
            //注册beanDefinition到spring
            registerBeanDefinition(holder, parserContext.getRegistry());
            if (shouldFireEvents()) {
                BeanComponentDefinition componentDefinition = new BeanComponentDefinition(holder);
                postProcessComponentDefinition(componentDefinition);
                parserContext.registerComponent(componentDefinition);
            }
        }
        catch (BeanDefinitionStoreException ex) {
            parserContext.getReaderContext().error(ex.getMessage(), element);
            return null;
        }
    }
    return definition;
}
```

上面Demo里面我们继承的是AbstractSingleBeanDefinitionParser，提供了进一步的封装：

```
//AbstractSingleBeanDefinitionParser
public abstract class AbstractSingleBeanDefinitionParser extends AbstractBeanDefinitionParser {

    @Override
    protected final AbstractBeanDefinition parseInternal(Element element, ParserContext parserContext) {
        BeanDefinitionBuilder builder = BeanDefinitionBuilder.genericBeanDefinition();
        String parentName = getParentName(element);
        if (parentName != null) {
            builder.getRawBeanDefinition().setParentName(parentName);
        }
        //子类覆盖getBeanClass返回beanclass
        Class<?> beanClass = getBeanClass(element);
        if (beanClass != null) {
            builder.getRawBeanDefinition().setBeanClass(beanClass);
        }
        else {
            //子类覆盖getBeanClassName返回beanClassName
            String beanClassName = getBeanClassName(element);
            if (beanClassName != null) {
                builder.getRawBeanDefinition().setBeanClassName(beanClassName);
            }
        }
        builder.getRawBeanDefinition().setSource(parserContext.extractSource(element));
        if (parserContext.isNested()) {
            // Inner bean definition must receive same scope as containing bean.
            builder.setScope(parserContext.getContainingBeanDefinition().getScope());
        }
        if (parserContext.isDefaultLazyInit()) {
            // Default-lazy-init applies to custom bean definitions as well.
            builder.setLazyInit(true);
        }
        doParse(element, parserContext, builder);
        return builder.getBeanDefinition();
    }

    protected void doParse(Element element, ParserContext parserContext, BeanDefinitionBuilder builder) {
        doParse(element, builder);
    }

    //需要子类覆盖完成标签解析
    protected void doParse(Element element, BeanDefinitionBuilder builder) {
    }

}
```

最主要的还是工具类BeanDefinitionBuilder利用Builder模式封装了BeanDefinition，提供了简单设置构造方法、属性的方法。

# 应用

 - AOP标签（AOPNamespaceHandler）

# 总结

1.  自定义的标签的扩展还是挺牛，看到好多地方用到，例如：通过自定义实现rpc的服务发现注册到zk；
2.  NamespaceHandler的init方法不一定要注册BeanDefinitionParser，可以注册个bean到spring里面，可以继承实现实例化前、实例化后、初始化前、初始化后处理器的方法，来拦截其他的bean注册，Aop就是这么处理的，当时看的时候还挺疑惑的，还感觉怎么不按常理出牌。

参考：[Spring源码解析-自定义标签解析][3]


  [1]: ./images/20170119141940736.png "20170119141940736"
  [2]: ./images/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A0%87%E7%AD%BE%E7%9A%84%E8%A7%A3%E6%9E%90_1.jpg "自定义标签的解析"
  [3]: http://blog.csdn.net/xiaoxufox/article/details/54603921