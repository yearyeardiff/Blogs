---
title: openresty--4--缓存
tags: openresty,nginx,lua
grammar_cjkRuby: true
---

# shared_dict 字典缓存

 1. 修改nginx.conf ，申请缓存lua_shared_dict，128M。   
``` nginxconf   
lua_shared_dict my_cahe 128m;  
```
 2. 在lua文件中使用缓存“my_cahe”。
 ``` lua
function get_from_cache(key)
	local mycache = ngx.shared.my_cache
	local value = mycache:get(key)
	return value
end
```
> shared_dict多个work共享；会有锁的操作，保证数据的原子性；会根据功能拆分出多个shared_dict避免锁的竞争； [lua_shared_dict](https://github.com/openresty/lua-nginx-module#lua_shared_dict)


# lua_resty_lrucache

``` lua
-- file myapp.lua: example "myapp" module

local _M = {}

-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the lua module level so that
-- it can be shared by all the requests served by each nginx worker process:
local c, err = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

function _M.go()
    c:set("dog", 32)
    c:set("cat", 56)
    ngx.say("dog: ", c:get("dog"))
    ngx.say("cat: ", c:get("cat"))

    c:set("dog", { age = 10 }, 0.1)  -- expire in 0.1 sec
    c:delete("dog")

    c:flush_all()  -- flush all the cached data
end

return _M
```

> 每个work单独占用，不会共享。 [lua_restyy_lurcache](https://github.com/openresty/lua-resty-lrucache)


