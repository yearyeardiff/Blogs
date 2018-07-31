---
title: openresty--2--API
tags: openresty,nginx,lua
grammar_cjkRuby: true
---

# 指令

[指令](https://github.com/openresty/lua-nginx-module#directives)

# api

[api](https://github.com/openresty/lua-nginx-module#nginx-api-for-lua)


# demo

nginx.conf配置
```nginxconf
location /decode_info{
		content_by_lua_file lua/decode_info.lua;
}
```
代码如下：

``` 
[root@192 lua]# ls
decode_info.lua  get_random_string.lua  hello2.lua
[root@192 lua]# pwd
/usr/local/openresty/nginx/lua
[root@192 lua]# vi decode_info.lua 

local json = require("cjson")

ngx.req.read_body()
local args = ngx.req.get_post_args()

if not args or not args.info then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local client_ip = ngx.var.remote_addr
local user_agent = ngx.req.get_headers()["user-agent"] or ''
local info = ngx.decode_base64(args.info)

local response = {}
response.info = info
response.ip = client_ip
response.user_agent = user_agent

ngx.say(json.encode(response))
```

如果不想每次更改lua文件都重启nginx，那么在nginx.conf中配置[lua_code_cache](https://github.com/openresty/lua-nginx-module#lua_code_cache)：
```nginxconf
lua_code_cache off;
```



