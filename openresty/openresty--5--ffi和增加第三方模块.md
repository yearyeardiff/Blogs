---
title: openresty--5--ffi和增加第三方模块
tags: openresy,nginx,ffi
grammar_cjkRuby: true
---

# ffi
[ffi](http://luajit.org/ext_ffi.html)
``` lua
local ffi = require("ffi")
ffi.cdef[[
int printf(const char *fmt, ...);
]]
ffi.C.printf("Hello %s!", "world")
```

```
[root@192 openresty]# ./luajit/bin/luajit-2.1.0-beta3 ./nginx/lua/ffi.lua 
Hello world
```

# 增加第三方模块
1. 查询相关模块
![查询相关模块](./images/1530448307237.png)

2. 把第三方模块复制到resty下
![路径1](./images/1530448624307.png)
![路径2](./images/1530448574436.png)
