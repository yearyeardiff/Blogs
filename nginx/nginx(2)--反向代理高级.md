---
title: nginx(2)--反向代理高级
tags: 新建,模板,小书匠
grammar_cjkRuby: true
---

# 安全隔离
## 使用 SSL 对流量进行加密
要使用 SSL 就需要在编译安装 Nginx 时在 Nginx 的二进制文件中添加对SSL 的支持（--with_http_ssl_module ），并且要安装 SSL 证书和密钥。

### 生成SSL证书
``` tex?linenums
[root@192 zch]# openssl req -newkey rsa:2048 -nodes -out zch.csr -keyout zch.key
[root@192 zch]# openssl x509 -req -days 365 -in zch.csr -signkey zch.key -out zch.crt
Signature ok
subject=/C=zh/ST=js/L=xz/O=zch/OU=zch/CN=zch/emailAddress=zch.com
Getting Private key
```
### 配置

# 性能优化
## 缓冲数据

## 缓存数据

## 存储数据

## 压缩数据