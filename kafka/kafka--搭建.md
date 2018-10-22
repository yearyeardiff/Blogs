---
title: kafka--搭建
tags: 新建,模板,小书匠
grammar_cjkRuby: true
---


# 下载

[Kafka downloads](http://kafka.apache.org/downloads)

# 启动zookeeper
-  启动zookeeper
```tex?linenums
~/software-dev/kafka_2.11-2.0.0/bin » ./zookeeper-server-start.sh ../config/zookeeper.properties
```

- 验证zookeeper是否启动成功
可以连到 Zookeeper端口上，通过发送四字命令 srvr来验证 Zookeeper是否安装正确
```tex?linenums
~ » telnet localhost 2181                                                                                                                                                                                               zhangchenghao@zhangch
Trying ::1...
Connected to localhost.
Escape character is '^]'.
srvr
Zookeeper version: 3.4.13-2d71af4dbe22557fda74f9a9b4309b15a7487f03, built on 06/29/2018 00:39 GMT
Latency min/avg/max: 0/0/3
Received: 14
Sent: 13
Connections: 2
Outstanding: 0
Zxid: 0xed
Mode: standalone
Node count: 138
Connection closed by foreign host.
```
# 启动kafka

## 创建并验证主题

- 创建主题
```tex?linenums

~/software-dev/kafka_2.11-2.0.0/bin » ./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test                                                
Created topic "test".
```

- 验证主题
往测试主题上发布消息 :
```tex?linenums
~/software-dev/kafka_2.11-2.0.0/bin » ./kafka-console-producer.sh --broker-list localhost:9092 --topic test                                                                                                             zhangchenghao@zhangch
>test message 1
>test message 2
>%
```

从测试主题上读取消息:
```tex?linenums
~/software-dev/kafka_2.11-2.0.0/bin » ./kafka-console-consumer.sh  --topic test --from-beginning --bootstrap-server localhost:9092                                                                                      zhangchenghao@zhangch
test message 1
test message 2
```

# kafka 和zookeeper的关系
Apache Kafka的一个关键依赖是Apache Zookeeper，它是一个分布式配置和同步服务。 Zookeeper是Kafka代理和消费者之间的协调接口。 Kafka服务器通过Zookeeper集群共享信息。 Kafka在Zookeeper中存储基本元数据，例如关于主题，代理，消费者偏移(队列读取器)等的信息。

由于所有关键信息存储在Zookeeper中，并且它通常在其整体上复制此数据，因此Kafka代理/ Zookeeper的故障不会影响Kafka集群的状态。 Kafka将恢复状态，一旦Zookeeper重新启动。 这为Kafka带来了零停机时间。 Kafka代理之间的领导者选举也通过使用Zookeeper在领导者失败的情况下完成。

![Kafka 和 Zookeeper][1]


  [1]: ./images/1540189648210.jpg "1540189648210.jpg"