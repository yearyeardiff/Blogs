---
title: kafka--集群搭建
tags: kafka,zookeeper
grammar_cjkRuby: true
---

# 版本信息
-  zookeeper-3.4.10
-  kafka_2.12-0.11.0.0 

# 安装zookeeper集群

- 把项目解压到下面的目录中
```tex?linenums
~/software-dev/zk » ls                                                                                                                                                                                                  
zk1 zk2 zk3
```

- 修改zoo.cfg配置文件，如果没有新建该文件;修改zoo.cfg
```tex?linenums
~/software-dev/zk/zk1/zookeeper-3.4.10/conf » cp zoo_sample.cfg zoo.cfg                                                                                                                                                 
~/software-dev/zk/zk1/zookeeper-3.4.10/conf » vi zoo.cfg

# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/Users/zhangchenghao/software-dev/zk/zk1/data

dataLogDir=/Users/zhangchenghao/software-dev/zk/zk1/log
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1=localhost:2287:3387
server.2=localhost:2288:3388
server.3=localhost:2289:3389
```

其他zk的配置也做同样的修改，如下:

```tex?linenums
# zk2
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/Users/zhangchenghao/software-dev/zk/zk2/data

dataLogDir=/Users/zhangchenghao/software-dev/zk/zk2/log
# the port at which the clients will connect
clientPort=2182
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1=localhost:2287:3387
server.2=localhost:2288:3388
server.3=localhost:2289:3389

# zk3
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/Users/zhangchenghao/software-dev/zk/zk3/data

dataLogDir=/Users/zhangchenghao/software-dev/zk/zk3/log
# the port at which the clients will connect
clientPort=2183
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1=localhost:2287:3387
server.2=localhost:2288:3388
server.3=localhost:2289:3389

```

- 在data文件夹中新建myid，并指定server的id
```tex?linenums
~/software-dev/zk/zk1/zookeeper-3.4.10/bin » echo 1 >> ~/software-dev/zk/zk1/data/myid
~/software-dev/zk/zk1/zookeeper-3.4.10/bin » echo 2 >> ~/software-dev/zk/zk2/data/myid
~/software-dev/zk/zk1/zookeeper-3.4.10/bin » echo 3 >> ~/software-dev/zk/zk3/data/myid
```

注：因为是在一台机器上模拟集群，所以端口不能重复，这里用2181-2183，2287-2289，以及3387-3389相互错开。另外每个zk的instance，都需要设置独立的数据存储目录、日志存储目录，所以dataDir、dataLogDir这二个节点对应的目录，需要手动先创建好。

另外还有一个灰常关键的设置，在每个zk server配置文件的dataDir所对应的目录下，必须创建一个名为myid的文件，其中的内容必须与zoo.cfg中server.x 中的x相同，即：

 ~/software-dev/zk/zk1/data/myid 中的内容为1，对应server.1中的1
 ~/software-dev/zk/zk2/data/myid 中的内容为2，对应server.2中的2
 ~/software-dev/zk/zk3/data/myid 中的内容为3，对应server.3中的3

生产环境中，分布式集群部署的步骤与上面基本相同，只不过因为各zk server分布在不同的机器，上述配置文件中的localhost换成各服务器的真实Ip即可。分布在不同的机器后，不存在端口冲突问题，可以让每个服务器的zk均采用相同的端口，这样管理起来比较方便。


- 启动zookeeper
```tex?linenums
~/software-dev/zk/zk1/zookeeper-3.4.10/bin » ~/software-dev/zk/zk1/zookeeper-3.4.10/bin/zkServer.sh start      
ZooKeeper JMX enabled by default
Using config: /Users/zhangchenghao/software-dev/zk/zk1/zookeeper-3.4.10/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

~/software-dev/zk/zk1/zookeeper-3.4.10/bin » ~/software-dev/zk/zk2/zookeeper-3.4.10/bin/zkServer.sh start  
ZooKeeper JMX enabled by default
Using config: /Users/zhangchenghao/software-dev/zk/zk2/zookeeper-3.4.10/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

~/software-dev/zk/zk1/zookeeper-3.4.10/bin » ~/software-dev/zk/zk3/zookeeper-3.4.10/bin/zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /Users/zhangchenghao/software-dev/zk/zk3/zookeeper-3.4.10/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```
## zk的配置

-  client:监听客户端连接的端口。 
-  tickTime:基本事件单元,这个时间是作为Zookeeper服务器之间或客户端与服务器之间维持心跳的时间间隔,每隔tickTime时间就会发送一个心跳;最小的session过期时间为2倍tickTime 
-  dataDir:存储内存中数据库快照的位置,如果不设置参数,更新事务的日志将被存储到默认位置。
-  dataLogdDir
	这个操作让管理机器把事务日志写入“dataLogDir”所指定的目录中,而不是“dataDir”所指定的目录。这将允许使用一个专用的日志设备,帮助我们避免日志和快照的竞争。
- maxClientCnxns
	这个操作将限制连接到Zookeeper的客户端数量,并限制并发连接的数量,通过IP来区分不同的客户端。此配置选项可以阻止某些类别的Dos攻击。将他设置为零或忽略不进行设置将会取消对并发连接的限制。
- minSessionTimeout和maxSessionTimeout
	即最小的会话超时和最大的会话超时时间。在默认情况下,`minSession=2*tickTime;maxSession=20*tickTime`
	`# the directory where the snapshot is storeddataDir=/usr/local/zk/data`
- initLimit
	此配置表示,允许follower(相对于Leader言的“客户端”)连接并同步到Leader的初始化连接时间,以tickTime为单位。当初始化连接时间超过该值,则表示连接失败。
- syncLimit
	此配置项表示Leader与Follower之间发送消息时,请求和应答时间长度。如果follower在设置时间内不能与leader通信,那么此follower将会被丢弃。 
- server.A=B:C:D
	A:其中 A 是一个数字,表示这个是服务器的编号; B:是这个服务器的 ip 地址; C:Leader选举的端口; D:Zookeeper服务器之间的通信端口。
- myid和zoo.cfg
	除了修改 zoo.cfg 配置文件,集群模式下还要配置一个文件 myid,这个文件在 dataDir 目录下,这个文件里面就有一个数据就是 A 的值,Zookeeper 启动时会读取这个文件,拿到里面的数据与 zoo.cfg 里面的配置信息比较从而判断到底是那个 server
# 安装kafka集群

- 把kafka解压到下面的目录中
```tex?linenums
~/software-dev/kafka » ls 
kafka1 kafka2 kafka3
```

- 修改server.properties

```tex?linenums
~/software-dev/kafka/kafka1/kafka_2.12-0.11.0.0/config » vi server.properties

broker.id=0
log.dirs =/Users/zhangchenghao/software-dev/kafka/kafka1/log
port=9092
zookeeper.connect=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880
```

其他kafka的配置也做同样的修改
```tex?linenums
# kafka2
broker.id=1
log.dirs =/Users/zhangchenghao/software-dev/kafka/kafka2/log
port=9093
zookeeper.connect=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880



# kafka3
broker.id=2
log.dirs =/Users/zhangchenghao/software-dev/kafka/kafka3/log
port=9094
zookeeper.connect=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880
```

- 启动kafka
```tex?linenums
~/software-dev/kafka/kafka1/kafka_2.12-0.11.0.0 » ./bin/kafka-server-start.sh -daemon ./config/server.properties

~/software-dev/kafka/kafka2/kafka_2.12-0.11.0.0 » ./bin/kafka-server-start.sh -daemon ./config/server.properties

~/software-dev/kafka/kafka3/kafka_2.12-0.11.0.0 » ./bin/kafka-server-start.sh -daemon ./config/server.properties
```

- 查看进程
```tex?linenums
~/software-dev/kafka/kafka3/kafka_2.12-0.11.0.0 » jps                                                                                                                                                                   zhangchenghao@zhangch
13936 Kafka
13444 Kafka
25012 Launcher
9956 QuorumPeerMain
25013 GiraffeAdminServer
10085 QuorumPeerMain
1143 GiraffeGitConfigServer
10104 QuorumPeerMain
26664 Jps
590
13695 Kafka
```

## kafka的配置

- broker.id
	每个 broker都需要有一个标识符，使用 broker.id来表示。它的默认值是 0，也可以被设置 成其他任意整数。这个值在整个 Kafka集群里必须是唯一的。这个值可以任意选定，如果 出于维护的需要，可以在服务器节点间交换使用这些 ID。
-  host.name
	broker的hostname；
-  port
	如果使用配置样本来启动 Kafka，它会监听 9092 端口
-  zookeeper.connect
	用于保存 broker元数据的 Zookeeper地址是通过 zookeeper.connect来指定的。 localhost:2181表示这个 Zookeeper是运行在本地的 2181端口上。该配置参数是用冒号分 隔的一组 hostnam:port/path 列表，每一部分的含义如下 :
	hostname是 Zookeeper服务器的机器名或 IP地址;
	port是 Zookeeper的客户端连接端口 ;
	/path是可选的 Zookeeper路径，作为 Kafka集群的 chroot环境。如果不指定，默认使用 根路径。
	如果指定的 chroot路径不存在， broker会在启动的时候创建它。
-  log.dirs
	Kafka把所有消息都保存在磁盘上，存放这些日志片段的目录是通过 log.dirs指定的。它是 一组用逗号分隔的本地文件系统路径。如果指定了多个路径，那么 broker会根据“最少使 用”原则，把同一个分区的日志片段保存到同一个路径下。要注意， broker会往拥有最少 数目分区的路径新增分区，而不是往拥有最小磁盘空间的路径新增分区。
-  num.recovery.threads.per.data.dir
	对于如下 3种情况， Kafka会使用可配置的钱程池来处理日志片段 :
	服务器正常启动，用于打开每个分区的日志片段 ;
	服务器崩溃后重启，用于检查和截短每个分区的日志片段: . 服务器正常关闭，用于关闭日志片段。
	默认情况下 ，每个日志目录只使用 一个线程。因为这些线程只是在服务器启动和关闭时会 用到 ，所以完全可以设置大量的线程来达到并行操作的目的。特别是对于包含大量分区的 服务器来说， 一旦发生崩愤，在进行恢复时使用并行操作可能会省下数小时的时间。设置 此参数时需要注意，所配置的数字对应的是 log.dirs指定的单个日志目录。 也就是说，如 果 num.recovery.threads.per.data.dir被设为 8， 井且 log.dir指定了 3个路径，那么总 共需要 24个线程。
- auto.create.topics.enable
	默认情况下， Kafka会在如下几种情形下自动创建主题 :
	•  当一个生产者开始往主题写入消息时 ;
	• 当一个消费者开始从主题读取消息时 ;
	• 当任意一个客户端向主题发送元数据请求时。
-  num.partions
	参数指定了新创建的主题将包含多少个分区。如果启用了主题自动创建功 能(该功能默认是启用的)，主题分区的个数就是该参数指定的值。该参数的默认值是1。 要注意，我们可以增加主题分区的个数，但不能减少分区的个数
-  message.max.bytes
	server可以接收的消息最大尺寸。重要的是，**consumer和producer有关这个属性的设置必须同步**，否则producer发布的消息对consumer来说太大。
- default.replication.factor
	默认创建topic的时候创建replication-factor的数量。
-  offsets.topic.replication.factor
	topic的offset的备份份数。建议设置更高的数字保证更高的可用性
-  log.retention.ms
	Kafka通常根据时间来决定数据可以被保留多久。默认使用 log.retention.ms参数来配 置时间 ，默认值为 168 小时，也就是一周。
-  log.retention.bytes
	另 一 种方式是通过保留的消息字节数来判断消息是否过期。它的值通过参数log.retention.bytes 来指定，作用在每一个分区上。也就是说，如果有一个包含 8 个分区的主 题，并且 log.retention.bytes 被设为 1GB，那么这个主题最多可以保留 8GB 的数据。所 以，当主题的分区个数增加时，整个主题可以保留的数据也随之增加。
-  log.segment.bytes
	以上的设置都作用在日志片段上，而不是作用在单个消息上。当消息到达 broker时，它 们被迫加到分区的当前日志片段上。当日志片段大小达到log.segment.bytes指定的上限 (默认是 1GB)时，当前日志片段就会被关闭，一个新的日志片段被打开。如果一个日志 片段被关闭，就开始等待过期。这个参数的值越小，就会越频繁地关闭和分配新文件，从而降低磁盘写入的整体效率。
	如果主题的消息量不大，那么 如何调整这个参数的大小就变得尤为重要。例如，如果一个 主题 每天只接收 100MB 的消息，而  log.segment.bytes 使用默认设置，那么需要 10 天时间才能填满一个日志片段。因为在日志片段被关闭之前消息是不会过期的，所以如果  log.segment.bytes 被设为 604 800 000 (也就是 1 周)，那么日志片段最多需要 17 天才会过期 。 这是因为关闭日志片段需要10天的时间，而根据配置的过期时间，还需要再保留7天时间(要等到日志片段里的最后一个消息过期才能被删除) 
-  log.retention.check.interval.ms
   检查日志分段文件的间隔时间，以确定是否文件属性是否到达删除要求。
-  num.network.threads
	用于接收并处理网络请求的线程数，默认为3。其内部实现是采用Selector模型。启动一个线程作为Acceptor来负责建立连接，再配合启动num.network.threads个线程来轮流负责从Sockets里读取请求，一般无需改动，除非上下游并发请求量过大。主要处理网络io，读写缓冲区数据，基本没有io等待，配置线程数量为cpu核数加1
-  num.io.threads
	主要进行磁盘io操作，高峰期可能有些io等待，因此配置需要大些。配置线程数量为cpu核数2倍，最大不超过3倍.
-  socket.send.buffer.bytes
	SO_SNDBUFF 缓存大小，server进行socket 连接所用
-  socket.receive.buffer.bytes
	SO_RCVBUFF缓存大小，server进行socket连接时所用
-  socket.request.max.bytes
	server允许的最大请求尺寸；  这将避免server溢出，它应该小于Java  heap size
-  transaction.state.log.replication.factor
	事务主题的复制因子。 内部主题创建将失败，直到群集大小满足此复制因素要求。
-  transaction.state.log.min.isr
	覆盖事务主题的min.insync.replicas配置
- 当生产者将ack设置为“全部”（或“-1”）时，min.insync.replicas指定必须确认写入被认为成功的最小副本数（必须确认每一个repica的写数据都是成功的）。 如果这个最小值不能满足，那么生产者将会引发一个异常（NotEnoughReplicas或NotEnoughReplicasAfterAppend）。当一起使用时，min.insync.replicas和acks允许您强制更大的耐久性保证。 一个典型的情况是创建一个复制因子为3的主题，将min.insync.replicas设置为2，并且生产者使用“all”选项。 这将确保如果大多数副本没有写入生产者则抛出异常。
-  group.initial.rebalance.delay.ms
	对于用户来说，这个改进最直接的效果就是新增了一个broker配置：group.initial.rebalance.delay.ms，默认是3秒钟。用户需要在server.properties文件中自行修改为想要配置的值。这个参数的主要效果就是让coordinator推迟空消费组接收到成员加入请求后本应立即开启的rebalance。在实际使用时，假设你预估你的所有consumer组成员加入需要在10s内完成，那么你就可以设置该参数=10000。


# zookeeper与kafka的关系
[zookeeper在kafka中的作用](https://blog.csdn.net/dly1580854879/article/details/71403867)

# kafka消息机制
[kafka消息与同步机制](https://blog.csdn.net/wingofeagle/article/details/60965867)

# 参考资料
[在本地模拟搭建zookeeper集群环境实例](https://www.cnblogs.com/baihaojie/p/6688358.html)
[ZooKeeper 一台机器搭建集群](https://www.aliyun.com/jiaocheng/793335.html)
[Zookeeper集群搭建](https://www.cnblogs.com/linuxprobe/p/5851699.html)


