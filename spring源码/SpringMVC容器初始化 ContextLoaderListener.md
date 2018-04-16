---
title: SpringMVC容器初始化 ContextLoaderListener
tags: spring,springMVC,ContextLoaderListener
grammar_cjkRuby: true
---
 ContextLoaderListener的作用就是启动Web容器时，自动装配ApplicationContext的配置信息。
* [web.xml配置](#webxml配置)
* [ContextLoaderListener UML类图](#contextloaderlistener-uml类图)
* [UML 时序图](#uml-时序图)
* [createWebApplicationContext](#createwebapplicationcontext)
	* [寻找用来实例化ConfigurableWebApplicationContext的class(determineContextClass)](#寻找用来实例化configurablewebapplicationcontext的classdeterminecontextclass)
* [loadParentContext](#loadparentcontext)
* [configureAndRefreshWebApplicationContext](#configureandrefreshwebapplicationcontext)


# web.xml配置
通常在web.xml中如下配置：

``` xml
	<context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>classpath:spring/spring-context-test.xml</param-value>
	</context-param>
	<listener>
		<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
	</listener>
```
# ContextLoaderListener UML类图
![enter description here][1]
  ServletContext启动后会调用ServletContextListener的contextInitialized方法。

# UML 时序图
![enter description here][2]
# createWebApplicationContext
用指定的contextClass或者默认class实例化ConfigurableWebApplicationContext
``` java  
	//ContextLoader
	protected WebApplicationContext createWebApplicationContext(ServletContext sc) {
		Class<?> contextClass = determineContextClass(sc);
		if (!ConfigurableWebApplicationContext.class.isAssignableFrom(contextClass)) {
			throw new ApplicationContextException("Custom context class [" + contextClass.getName() +
					"] is not of type [" + ConfigurableWebApplicationContext.class.getName() + "]");
		}
		return (ConfigurableWebApplicationContext) BeanUtils.instantiateClass(contextClass);
	}
```


## 寻找用来实例化ConfigurableWebApplicationContext的class(determineContextClass)
	
先寻找web.xml 中指定的contextClass，如果没有再使用ContextLoader.properties配置的默认实现类
``` java 
	//ContextLoader.java
	protected Class<?> determineContextClass(ServletContext servletContext) {
		String contextClassName = servletContext.getInitParameter(CONTEXT_CLASS_PARAM);//contextClass
		if (contextClassName != null) {
			try {
				return ClassUtils.forName(contextClassName, ClassUtils.getDefaultClassLoader());
			}
			catch (ClassNotFoundException ex) {
				throw new ApplicationContextException(
						"Failed to load custom context class [" + contextClassName + "]", ex);
			}
		}
		else {
			contextClassName = defaultStrategies.getProperty(WebApplicationContext.class.getName());
			try {
				return ClassUtils.forName(contextClassName, ContextLoader.class.getClassLoader());
			}
			catch (ClassNotFoundException ex) {
				throw new ApplicationContextException(
						"Failed to load default context class [" + contextClassName + "]", ex);
			}
		}
	}
```
其中，在ContextLoader类中有这样的静态代码块：

``` java
	static {
		// Load default strategy implementations from properties file.
		// This is currently strictly internal and not meant to be customized
		// by application developers.
		try {
		    //DEFAULT_STRATEGIES_PATH = "ContextLoader.properties";
			ClassPathResource resource = new ClassPathResource(DEFAULT_STRATEGIES_PATH, ContextLoader.class);
			defaultStrategies = PropertiesLoaderUtils.loadProperties(resource);
		}
		catch (IOException ex) {
			throw new IllegalStateException("Could not load 'ContextLoader.properties': " + ex.getMessage());
		}
	}
```
ContextLoader.properties文件如下，配置了WebApplicationContext接口的默认实现类

``` profile
# Default WebApplicationContext implementation class for ContextLoader.
# Used as fallback when no explicit context implementation has been specified as context-param.
# Not meant to be customized by application developers.

org.springframework.web.context.WebApplicationContext=org.springframework.web.context.support.XmlWebApplicationContext
```



# loadParentContext
日后分析

# configureAndRefreshWebApplicationContext
主要功能是调用AbstractApplicationContext的refresh方法，加载bean
``` java
	protected void configureAndRefreshWebApplicationContext(ConfigurableWebApplicationContext wac, ServletContext sc) {
		if (ObjectUtils.identityToString(wac).equals(wac.getId())) {
			// The application context id is still set to its original default value
			// -> assign a more useful id based on available information
			String idParam = sc.getInitParameter(CONTEXT_ID_PARAM);
			if (idParam != null) {
				wac.setId(idParam);
			}
			else {
				// Generate default id...
				wac.setId(ConfigurableWebApplicationContext.APPLICATION_CONTEXT_ID_PREFIX +
						ObjectUtils.getDisplayString(sc.getContextPath()));
			}
		}

		wac.setServletContext(sc);
		String configLocationParam = sc.getInitParameter(CONFIG_LOCATION_PARAM);
		if (configLocationParam != null) {
			wac.setConfigLocation(configLocationParam);
		}

		// The wac environment's #initPropertySources will be called in any case when the context
		// is refreshed; do it eagerly here to ensure servlet property sources are in place for
		// use in any post-processing or initialization that occurs below prior to #refresh
		ConfigurableEnvironment env = wac.getEnvironment();
		if (env instanceof ConfigurableWebEnvironment) {
			((ConfigurableWebEnvironment) env).initPropertySources(sc, null);
		}

		customizeContext(sc, wac);
		wac.refresh();
	}
```


  [1]: ./images/ContextLoaderListener.png "ContextLoaderListener"
  [2]: ./images/springMVC-ContextLoaderListener.png "springMVC-ContextLoaderListener"