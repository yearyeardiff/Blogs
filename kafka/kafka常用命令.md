---
title: kafka常用命令
tags: kafka
grammar_cjkRuby: true
---


# 启动kafka服务

```
kafka_2.12-0.11.0.0/bin » ./kafka-server-start.sh -daemon ../config/server.properties
```
# topic 操作

- 创建topic

```
# 创建了一个topic：test20181116，其分区数量：3，复制因子：3
[deploy@rdpops-vm71 bin]$ ./kafka-topics.sh --zookeeper 127.0.0.1:2181 --create --topic test20181116 --replication-factor 3 --partitions 3
Created topic "test20181116".
```

- 列出集群中的所有主题

```
[deploy@rdpops-vm71 bin]$ ./kafka-topics.sh --zookeeper 127.0.0.1:2181 --list
GiraffeBus
__consumer_offsets
bookCloudBus
bookCloudBus-1
bookCloudBus1
chargeCloudBus
test
test20181116
```

- 列出主题的详细信息

```
[deploy@rdpops-vm71 bin]$ ./kafka-topics.sh --zookeeper 127.0.0.1:2181 --describe --topic test20181116
Topic:test20181116	PartitionCount:3	ReplicationFactor:3	Configs:
	Topic: test20181116	Partition: 0	Leader: 2	Replicas: 2,3,1	Isr: 2,3,1
	Topic: test20181116	Partition: 1	Leader: 3	Replicas: 3,1,2	Isr: 3,1,2
	Topic: test20181116	Partition: 2	Leader: 1	Replicas: 1,2,3	Isr: 1,2,3
```
第一行显示partitions的概况，列出了Topic名字，partition总数，存储这些partition的broker数
以下每一行都是其中一个partition的详细信息：
- leader 
是该partitons所在的所有broker中担任leader的broker id，每个broker都有可能成为leader
- replicas 
显示该partiton所有副本所在的broker列表，包括leader，不管该broker是否是存活，不管是否和leader保持了同步。
- isr 
in-sync replicas的简写，表示存活且副本都已同步的的broker集合，是replicas的子集


- 删除主题

```
[deploy@rdpops-vm71 bin]$ ./kafka-topics.sh --zookeeper 127.0.0.1:2181 --delete --topic test20181116
Topic test20181116 is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```

- 为topic增加副本
`./kafka-reassign-partitions.sh -zookeeper 127.0.0.1:2181 -reassignment-json-file json/partitions-to-move.json -execute`
[apache kafka-- Increasing replication factor](http://kafka.apache.org/documentation/#basic_ops_increase_replication_factor)

- 为topic增加partition
`./kafka-topics.sh –zookeeper 127.0.0.1:2181 –alter –partitions 5 –topic test`


# 消费者群组

- 列出消费者群组

```
[deploy@rdpops-vm71 bin]$ ./kafka-consumer-groups.sh --bootstrap-server 10.0.19.71:9092 --list
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).

anonymous.693673df-1256-4ca1-b3e1-a757d957925b
anonymous.4f708c75-6ba5-4d35-88ac-5abb71b7e251
anonymous.3764e49d-3e40-46dc-8c4b-d996aef42cd1
anonymous.d892fc12-290f-480a-ab05-77bca7519be2
anonymous.64e73784-bbf7-4e4f-b9a9-ef54ecb951a4
anonymous.0bb69dff-1999-4e54-bfea-8d0441861243
anonymous.d54a5753-7f25-456b-b4e6-d8e32412b73d
anonymous.bdd86c7e-8fdb-44af-9c36-5b67d92740fa
anonymous.f5ad477a-eff2-45ff-8650-e28e8a65bd57
anonymous.16f5a90b-a5dc-4ca0-b8b3-bd1241e8b6a6
```

- 查看群组的详细信息

```
[deploy@rdpops-vm71 bin]$ ./kafka-consumer-groups.sh --bootstrap-server 10.0.19.71:9092 --describe --group anonymous.693673df-1256-4ca1-b3e1-a757d957925b
Note: This will only show information about consumers that use the Java consumer API (non-ZooKeeper-based consumers).


TOPIC                          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID                                       HOST                           CLIENT-ID
springCloudBus                 0          0               0               0          consumer-2-3fe12774-d412-4774-b293-42660f5d0098   /10.0.19.102                   consumer-2
```

# 控制台生产者

- 发送消息

```
[deploy@rdpops-vm71 bin]$ ./kafka-console-producer.sh --broker-list 10.0.19.71:9092 --topic test
>message1
>message2
```

# 控制台消费者

- 查看指定topic的所有消息

```
>[deploy@rdpops-vm71 bin]$ ./kafka-consoleconsumer.sh --bootstrap-server 10.0.19.71:9092 --topic test --from-beginning
message1
message2
```

