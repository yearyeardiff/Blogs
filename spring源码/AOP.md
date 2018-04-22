---
title: Spring源码解析---AOP
tags: spring,AOP,BeanPostProcessor
grammar_cjkRuby: true
---

# 动态AOP自定义标签
![动态AOP自定义标签][1]

``` java
	private static BeanDefinition registerOrEscalateApcAsRequired(Class<?> cls, BeanDefinitionRegistry registry, Object source) {
		Assert.notNull(registry, "BeanDefinitionRegistry must not be null");
		if (registry.containsBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME)) {
			BeanDefinition apcDefinition = registry.getBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME);
			if (!cls.getName().equals(apcDefinition.getBeanClassName())) {
				int currentPriority = findPriorityForClass(apcDefinition.getBeanClassName());
				int requiredPriority = findPriorityForClass(cls);
				if (currentPriority < requiredPriority) {
					apcDefinition.setBeanClassName(cls.getName());
				}
			}
			return null;
		}
		RootBeanDefinition beanDefinition = new RootBeanDefinition(cls);
		beanDefinition.setSource(source);
		beanDefinition.getPropertyValues().add("order", Ordered.HIGHEST_PRECEDENCE);
		beanDefinition.setRole(BeanDefinition.ROLE_INFRASTRUCTURE);
		registry.registerBeanDefinition(AUTO_PROXY_CREATOR_BEAN_NAME, beanDefinition);//注册BeanDefinition
		return beanDefinition;
	}
```
# 代理对象生成的过程
AbstractAutoProxyCreator是一种InstantiationAwareBeanPostProcessor,其url图如下，其有效的方法是:postProcessBeforeInstantiation，postProcessAfterInitialization。

![enter description here][2]

代理对象生成过程的时序图如下：

![enter description here][3]

# 代理对象调用的过程

以JdkDynamicAopProxy为例：

![enter description here][4]


以下博客写得很好：
https://my.oschina.net/u/2377110/blog/1507532


  [1]: ./images/AOP%E5%8A%A8%E6%80%81%E6%A0%87%E7%AD%BE.png "AOP动态标签"
  [2]: ./images/instantiationAwareBeanPostprocessor-uml.png "instantiationAwareBeanPostprocessor-uml"
  [3]: ./images/%E5%88%9B%E5%BB%BAaop%E4%BB%A3%E7%90%86_1.png "创建aop代理"
  [4]: ./images/aop%E8%B0%83%E7%94%A8%E8%BF%87%E7%A8%8B.png "aop调用过程"