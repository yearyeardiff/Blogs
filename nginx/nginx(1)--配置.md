---
title: nginx(1)--配置
tags: nginx
grammar_cjkRuby: true
---

# nginx安装
- 安装&启动
``` tex?linenums
#解压nginx压缩包
[zch@192 nginx-1.15.1]$ ls -l
总用量 744
drwxr-xr-x. 6 1001 1001   4096 7月  18 09:53 auto
-rw-r--r--. 1 1001 1001 288893 7月   3 23:07 CHANGES
-rw-r--r--. 1 1001 1001 440534 7月   3 23:07 CHANGES.ru
drwxr-xr-x. 2 1001 1001   4096 7月  18 09:53 conf
-rwxr-xr-x. 1 1001 1001   2502 7月   3 23:07 configure
drwxr-xr-x. 4 1001 1001     68 7月  18 09:53 contrib
drwxr-xr-x. 2 1001 1001     38 7月  18 09:53 html
-rw-r--r--. 1 1001 1001   1397 7月   3 23:07 LICENSE
-rw-r--r--. 1 root root    376 7月  18 09:59 Makefile
drwxr-xr-x. 2 1001 1001     20 7月  18 09:55 man
drwxr-xr-x. 3 root root   4096 7月  18 10:00 objs
-rw-r--r--. 1 1001 1001     49 7月   3 23:07 README
drwxr-xr-x. 9 1001 1001     84 7月  18 09:53 src


#然后 (此处忘记复制了)
# ./configure
# make & sudo make install

#默认安装路径
[zch@192 nginx]$ pwd
/usr/local/nginx

#启动nginx
[root@192 nginx]# ./sbin/nginx -c ./conf/nginx.conf -p .
#查看是否启动成功
[root@192 nginx]# ps -ef | grep nginx
root      17907      1  0 12:34 ?        00:00:00 nginx: master process ./sbin/nginx -c ./conf/nginx.conf -p .
nobody    17908  17907  0 12:34 ?        00:00:00 nginx: worker process
root      17919  17877  0 12:35 pts/0    00:00:00 grep --color=auto nginx
```
- 访问
``` tex?linenums
[zch@192 nginx]$ curl http://127.0.0.1
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
[nginx download](http://nginx.org/en/download.html)
# 基本配置
## 主配置文件

``` nginxconf?linenums

worker_process # 表示工作进程的数量， 一般设置为cpu的核数
worker_connections # 表示每个工作进程的最大连接数
server{} # 块定义了虚拟主机
	listen # 监听端口
	server_name # 监听域名
		location {} # 是用来为匹配的 URI 进行配置， URI 即语法中的“/uri/”
		location /{} # 匹配任何查询， 因为所有请求都以 / 开头
			root # 指定对应uri的资源查找路径， 这里html为相对路径
			index # 指定首页index文件的名称， 可以配置多个， 以空格分开。 如有多个， 按配置顺序查找。
```

## 使用 include 文件
在 Nginx 的配置文件中， include 文件可以在任何地方，以便增强配置文件的可读性，并且能够使得部分配置文件重新使用。使用 include 文件， 要确保被包含的文件自身有正确的 Nginx 语法，即配置指令和块（ blocks ），然后指定这些文件的路径。
include /opt/local/etc/nginx/mime.types;
在路径中出现通配符，表示可以配置多个文件。
include ／opt/local/etc/nginx/vhost/* . conf;
如果没有给定全路径，那么 Nginx 将会依据它的主配置文件路径进行搜索。 Nginx 测试配置文件很容易，通过下面的命令来完成。
nginx -t -c <path-to-nginx.conf>
该命令将测试 Nginx 的配置文件，包括 include 文件，但是它只检查语法错误 。

## location
- 语法规则
```
location [=|~|~*|^~] /uri/ { … }
```



|模式| 含义|
| --- | --- |
|location = /uri |= 表示精确匹配， 只有完全匹配上才能生效|
|location ^~ /uri |^~ 开头对URL路径进行前缀匹配， 并且在正则之前。|
|location ~pattern |开头表示区分大小写的正则匹配|
|location ~* pattern |开头表示不区分大小写的正则匹配|
|location /uri |不带任何修饰符， 也表示前缀匹配， 但是在正则匹配之后|
|location / | 通用匹配， 任何未匹配到其它location的请求都会匹配到， 相当于switch中的default|

前缀匹配时，Nginx 不对 url 做编码，因此请求为 /static/20%/aa ，可以被规则 ^~ /static/ /aa 匹配到（ 注意是空格）
多个 location 配置的情况下匹配顺序为（ 参考资料而来， 还未实际验证， 试试就知道了， 不必拘泥， 仅供参考） :

- 首先精确匹配 =
- 其次前缀匹配 ^~
- 其次是按文件中顺序的正则匹配
- 然后匹配不带任何修饰的前缀匹配。
- 最后是交给 / 通用匹配
- 当有匹配成功时候， 停止匹配， 按当前匹配规则处理请求

注意： 前缀匹配，如果有包含关系时， 按最大匹配原则进行匹配。 比如在前缀匹配： location /dir01 与 location /dir01/dir02 ， 如有请求http://localhost/dir01/dir02/file 将最终匹配到 location /dir01/dir02

- 测试规则
nginx-location.conf文件
``` nginxconf?linenums

worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;
        
        location = / {
			root   html;
		} 
		location = /login {
			root   indexB;
		} 
		location ~ \.(gif|jpg|png|js|css)$ {
			root   indexE;
		} 
		location ~* \.png$ {
			root   indexF;
		}
		location ^~ /static/ {
			root   indexC;
		} 
		location ^~ /static/files {
			root   indexD;
		}  
		location /img {
			root   indexG;
		} 
		location / {
			root   htmlH;
		}

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```

``` tex?linenums
[root@192 nginx]# ./sbin/nginx -c ./conf/nginx-location.conf -p .

[root@192 nginx]# curl http://127.0.0.1/static/hh.png
#error.log(后台打印的日志)
#2018/07/19 11:18:37 [error] 8550#0: *2 open() "./indexC/static/hh.png" 
[root@192 nginx]# curl http://127.0.0.1/img/hh
#error.log(后台打印的日志)
#2018/07/19 11:19:53 [error] 8550#0: *3 open() "./indexG/img/hh"
[root@192 nginx]# curl http://127.0.0.1/img/hh.png
#error.log(后台打印的日志)
#2018/07/19 11:20:52 [error] 8550#0: *4 open() "./indexE/img/hh.png"
[root@192 nginx]# curl http://127.0.0.1/static/files/hh.css
#error.log(后台打印的日志)
#2018/07/19 11:21:45 [error] 8550#0: *5 open() "./indexD/static/files/hh.css"
[root@192 nginx]# curl http://127.0.0.1/login
#error.log(后台打印的日志)
#2018/07/19 11:24:37 [error] 8550#0: *6 open() "./indexB/login" 
```

- 所以实际使用中， 笔者觉得至少有三个匹配规则定义， 如下：
``` nginxconf?linenums
# 直接匹配网站根，通过域名访问网站首页比较频繁，使用这个会加速处理，官网如是说。
# 这里是直接转发给后端应用服务器了，也可以是一个静态首页
# 第一个必选规则
location = / {
	proxy_pass http://tomcat:8080/index
} 
#第二个必选规则是处理静态文件请求，这是 nginx 作为 http 服务器的强项
#有两种配置模式，目录匹配或后缀匹配，任选其一或搭配使用
location ^~ /static/ {
	root /webroot/static/;
} 
location ~* \.(gif|jpg|jpeg|png|css|js|ico)$ {
	root /webroot/res/;
} 
# 第三个规则就是通用规则，用来转发动态请求到后端应用服务器
# 非静态文件请求就默认是动态请求，自己根据实际把握
# 毕竟目前的一些框架的流行，带.php、.jsp后缀的情况很少了
location / {
	proxy_pass http://tomcat:8080/
}
```

## Nginx静态文件服务
``` nginxconf?linenums
http {
	# 这个将为打开文件指定缓存， 默认是没有启用的， max 指定缓存数量，
	# 建议和打开文件数一致， inactive 是指经过多长时间文件没被请求后删除缓存。
	open_file_cache max=204800 inactive=20s;
	
	# open_file_cache 指令中的inactive 参数时间内文件的最少使用次数，
	# 如果超过这个数字， 文件描述符一直是在缓存中打开的， 如上例， 如果有一个
	# 文件在inactive 时间内一次没被使用， 它将被移除。
	open_file_cache_min_uses 1;
	
	# 这个是指多长时间检查一次缓存的有效信息
	open_file_cache_valid 30s;
	
	# 默认情况下， Nginx的gzip压缩是关闭的， gzip压缩功能就是可以让你节省不
	# 少带宽， 但是会增加服务器CPU的开销哦， Nginx默认只对text/html进行压缩 ，
	# 如果要对html之外的内容进行压缩传输， 我们需要手动来设置。
	gzip on;
	gzip_min_length 1k;
	gzip_buffers 4 16k;
	gzip_http_version 1.0;
	gzip_comp_level 2;
	gzip_types text/plain application/x-javascript text/css application/xml;
	
	server {
		listen 80;
		server_name www.test.com;
		charset utf-8;
		root html;
		index index.html index.htm;
	}
}
```

##  rewrite重写

## 日志
Nginx 日志主要有两种： access_log(访问日志) 和 error_log(错误日志)。

### access_log 访问日志
access_log 主要记录客户端访问 Nginx 的每一个请求， 格式可以自定义。 通过 access_log你可以得到用户地域来源、 跳转来源、 使用终端、 某个 URL 访问量等相关信息。
- log_format 指令用于定义日志的格式， 语法: `log_format name string`; 其中 name 表示格式名称， string 表示定义的格式字符串。 log_format 有一个默认的无需设置的组合日志格式。
>默认的无需设置的组合日志格式
```nginxconf?linenums
log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';
```
- access_log 指令用来指定访问日志文件的存放路径（ 包含日志文件名） 、 格式和缓存大小，语法： `access_log path [format_name [buffer=size | off]];` 其中 path 表示访问日志存放路径， format_name 表示访问日志格式名称， buffer 表示缓存大小， off 表示关闭访问日志。

> log_format 使用示例： 在 access.log 中记录客户端 IP 地址、 请求状态和请求时间

``` nginxconf?linenums
log_format myformat '$remote_addr $status $time_local';
access_log logs/access.log myformat;
```
需要注意的是： log_format 配置必须放在 http 内， 否则会出现警告。 Nginx 进程设置的用户和组必须对日志路径有创建文件的权限， 否则， 会报错。

定义日志使用的字段及其作用：
|字段 |作用|
| --- | --- |
|$remote_addr与$http_x_forwarded_for| 记录客户端IP地址|
|$remote_user |记录客户端用户名称|
|$request| 记录请求的URI和HTTP协议|
|$status |记录请求状态|
|$body_bytes_sent |发送给客户端的字节数， 不包括响应头的大小|
|$bytes_sent| 发送给客户端的总字节数
|$connection |连接的序列号|
|$connection_requests |当前通过一个连接获得的请求数量|
|$msec |日志写入时间。 单位为秒， 精度是毫秒|
|$pipe| 如果请求是通过HTTP流水线(pipelined)发送， pipe值为“p”， 否则为“.”|
|$http_referer |记录从哪个页面链接访问过来的|
|$http_user_agent |记录客户端浏览器相关信息|
|$request_length |请求的长度（ 包括请求行， 请求头和请求正文）|
|$request_time |请求处理时间， 单位为秒， 精度毫秒|
|$time_iso8601| ISO8601标准格式下的本地时间|
|$time_local |记录访问时间与时区|

[Alphabetical index of variables](http://nginx.org/en/docs/varindex.html)

### error_log 错误日志

error_log 主要记录客户端访问 Nginx 出错时的日志， 格式不支持自定义。 通过查看错误日志， 你可以得到系统某个服务或 server 的性能瓶颈等。 因此， 将日志利用好， 你可以得到很多有价值的信息。
- error_log 指令用来指定错误日志， 语法: `error_log path [level] ; `其中 path 表示错误日志存放路径， level 表示错误日志等级， 日志等级包括 debug、 info、 notice、 warn、 error、 crit、alert、 emerg， 从左至右， 日志详细程度逐级递减， 即 debug 最详细， emerg 最少， 默认为error。

### 测试

- nginx-log.conf
``` nginxconf?linenums
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    
    #Access Log日志格式
    log_format main '$proxy_add_x_forwarded_for||$remote_user||$time_local||$request||$status||$body_bytes_sent||$http_user_agent||$remote_addr||$http_host||$request_body||$request_time||$host';
    access_log  logs/http-access.log  main;
    error_log logs/http-error.log debug;

    server {
        listen       80;
        access_log  logs/server-access.log  main;
        error_log logs/server-error.log debug;
        
        location = / {
					root   html;
					index index.html;
				} 
    }
}
```
- 启动nginx&测试
``` tex?linenums
[root@192 nginx]#  ./sbin/nginx -c ./conf/nginx-log.conf -p .
[root@192 nginx]# curl -H 'HOST:zch' http://localhost
```
- 查看日志
``` tex?linenums
[zch@192 nginx]$ tail -f ./logs/server-access.log 
127.0.0.1||-||21/Jul/2018:14:56:01 +0800||GET / HTTP/1.1||403||169||curl/7.29.0||127.0.0.1||localhost||-||0.000||localhost
127.0.0.1||-||21/Jul/2018:15:08:29 +0800||GET / HTTP/1.1||200||612||curl/7.29.0||127.0.0.1||zch||-||0.000||zch
127.0.0.1||-||21/Jul/2018:15:08:50 +0800||GET / HTTP/1.1||200||612||curl/7.29.0||127.0.0.1||zch||-||0.000||zch
```
### 日志切割
[Nginx运行日志自动切割](https://blog.csdn.net/wangkai_123456/article/details/71056758)
## 反向代理

### 什么是反向代理
反向代理（ Reverse Proxy） 方式是指用代理服务器来接受 internet 上的连接请求， 然后将请求转发给内部网络上的服务器， 并将从服务器上得到的结果返回给 internet 上请求连接的客户端， 此时代理服务器对外就表现为一个反向代理服务器。
举个例子， 一个用户访问 http://www.example.com/readme， 但是 www.example.com 上并不存在 readme 页面， 它是偷偷从另外一台服务器上取回来， 然后作为自己的内容返回给用户。 但是用户并不知情这个过程。 对用户来说， 就像是直接从 www.example.com 获取readme 页面一样。 这里所提到的 www.example.com 这个域名对应的服务器就设置了反向代理功能。

![反向代理](./images/1532158550530.png)

> 场景描述： 访问本地服务器上的 README.md 文件 http://localhost/README.md， 本地
服务器进行反向代理， 从 https://github.com/moonbingbing/openresty-bestpractices/blob/master/README.md 获取页面内容。

- ginx-proxy.conf 配置示例：
``` nginxconf?linenums
worker_processes 1;
pid logs/nginx.pid;
error_log logs/error.log warn;
events {
	worker_connections 3000;
} 
http {
	include mime.types;
	server_tokens off;
	## 下面配置反向代理的参数
	server {
		listen 80;
		## 1. 用户访问 http://ip:port， 则反向代理到 https://github.com
		location / {
			proxy_pass https://github.com; # proxy_pass 后面跟着一个 URL， 用来将请求反向代理到 URL 参数指定的服务器上。 
			proxy_redirect off;
			proxy_set_header Host $host; #默认情况下， 反向代理不会转发原始请求中的 Host 头部， 如果需要转发,                               #就需要加上这句：proxy_set_header Host $host;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		} 
		## 2.用户访问 http://ip:port/README.md， 则反向代理到
		## https://github.com/.../README.md
		location /README.md {
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_pass https://github.com/moonbingbing/openresty-best-practices/blob/master/README.md;
		}
	}
}
```
[参考：Module ngx_http_proxy_module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)

## 负载均衡
upstream 负载均衡概要
配置示例， 如下：

``` nginxconf?linenums
upstream test.net{
	ip_hash;
	server 192.168.10.13:80;
	server 192.168.10.14:80 down;
	server 192.168.10.15:8009 max_fails=3 fail_timeout=20s;
	server 192.168.10.16:8080;
	} 
	server {
		location / {
		proxy_pass http://test.net;
	}
}
```
upstream 是 Nginx 的 HTTP Upstream 模块， 这个模块通过一个简单的调度算法来实现客户端 IP 到后端服务器的负载均衡。 在上面的设定中， 通过 upstream 指令指定了一个负载均衡器的名称 test.net。 这个名称可以任意指定， 在后面需要用到的地方直接调用即可。
### upstream 支持的负载均衡算法
Nginx 的负载均衡模块目前支持 6 种调度算法， 下面进行分别介绍， 其中后两项属于第三方调度算法。
- 轮询（ 默认） ： 每个请求按时间顺序逐一分配到不同的后端服务器， 如果后端某台服务器宕机， 故障系统被自动剔除， 使用户访问不受影响。 Weight 指定轮询权值， Weight 值越大， 分配到的访问机率越高， 主要用于后端每个服务器性能不均的情况下。
- ip_hash： 每个请求按访问 IP 的 hash 结果分配， 这样来自同一个 IP 的访客固定访问一个后端服务器， 有效解决了动态网页存在的 session 共享问题。
- fair： 这是比上面两个更加智能的负载均衡算法。 此种算法可以依据页面大小和加载时间长短智能地进行负载均衡， 也就是根据后端服务器的响应时间来分配请求， 响应时间短的优先分配。 Nginx 本身是不支持 fair 的， 如果需要使用这种调度算法， 必须下载 Nginx的 upstream_fair 模块
- url_hash： 此方法按访问 url 的 hash 结果来分配请求， 使每个 url 定向到同一个后端服务器， 可以进一步提高后端缓存服务器的效率。 Nginx 本身是不支持 url_hash 的， 如果需要使用这种调度算法， 必须安装 Nginx 的 hash 软件包。
- least_conn： 最少连接负载均衡算法， 简单来说就是每次选择的后端都是当前最少连接的一个 server(这个最少连接不是共享的， 是每个 worker 都有自己的一个数组进行记录后端 server 的连接数)。
- hash： 这个 hash 模块又支持两种模式 hash, 一种是普通的 hash, 另一种是一致性hash(consistent)。

### upstream 支持的状态参数
在 HTTP Upstream 模块中， 可以通过 server 指令指定后端服务器的 IP 地址和端口， 同时还可以设定每个后端服务器在负载均衡调度中的状态。 常用的状态有：

- down： 表示当前的 server 暂时不参与负载均衡。
- backup： 预留的备份机器。 当其他所有的非 backup 机器出现故障或者忙的时候， 才会请求 backup 机器， 因此这台机器的压力最轻。
- max_fails： 允许请求失败的次数， 默认为 1 。 当超过最大次数时， 返回proxy_next_upstream 模块定义的错误。
- fail_timeout： 在经历了 max_fails 次失败后， 暂停服务的时间。 max_fails 可以和fail_timeout 一起使用。
当负载调度算法为 ip_hash 时， 后端服务器在负载均衡调度中的状态不能是 backup。

### 配置 Nginx 负载均衡
- 配置 Nginx 进行健康状态检查
利用 max_fails、 fail_timeout 参数， 控制异常情况， 示例配置如下：
``` nginxconf?linenums
upstream webservers {
	server 192.168.18.201 weight=1 max_fails=2 fail_timeout=2;
	server 192.168.18.202 weight=1 max_fails=2 fail_timeout=2;
}
```
如果不幸的是所有服务器都不能提供服务了怎么办， 用户打开页面就会出现出错页面， 那么会带来用户体验的降低，答案是配置 backup。
- 配置 backup 服务器
```nginxconf?linenums
upstream webservers {
	server 192.168.18.201 weight=1 max_fails=2 fail_timeout=2;
	server 192.168.18.202 weight=1 max_fails=2 fail_timeout=2;
	server 127.0.0.1:8080 backup;
}
```
- 配置 ip_hash 负载均衡
ip_hash： 每个请求按访问 IP 的 hash 结果分配， 这样来自同一个 IP 的访客固定访问一个后端服务器， 有效解决了动态网页存在的 session 共享问题， 电子商务网站用的比较多。

``` nginxconf?linenums
# vim /etc/nginx/nginx.conf
upstream webservers {
	ip_hash;
	server 192.168.18.201 weight=1 max_fails=2 fail_timeout=2;
	server 192.168.18.202 weight=1 max_fails=2 fail_timeout=2;
	#server 127.0.0.1:8080 backup;
}
```
注: 当负载调度算法为 ip_hash 时， 后端服务器在负载均衡调度中的状态不能有 backup。 有人可能会问， 为什么呢？ 大家想啊， 如果负载均衡把你分配到 backup 服务器上， 你能访问到页面吗？ 不能， 所以不能配置 backup 服务器。

## 参考
[精通nginx.pdf](https://download.csdn.net/download/u011535387/10548524)
[nginx documentation](http://nginx.org/en/docs/)
[nginx使用](https://github.com/caojx-git/learn/blob/master/notes/nginx/nginx%E4%BD%BF%E7%94%A8.md)


