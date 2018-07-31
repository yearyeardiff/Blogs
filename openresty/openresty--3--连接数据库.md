---
title: openresty--3--连接数据库
tags: openresty,nginx,lua
grammar_cjkRuby: true
---

# mysql

[lua-resty-mysql](https://github.com/openresty/lua-resty-mysql)

``` nginxconf
location /resty_mysql{
		content_by_lua_file lua/resty_mysql.lua;
}
```

```lua
local cjson = require "cjson"
local mysql = require "resty.mysql"

local db = mysql:new()
local ok, err, errcode, sqlstate = db:connect({
	host = "192.168.140.1",
	port = 3306,
	database = "wukong",
	user = "root",
	password = "root"})

if not ok then
	ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
	return ngx.exit(500)
end

res, err, errcode, sqlstate = db:query("select 1; select 2; select 3;")
if not res then
	ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
	return ngx.exit(500)
end

ngx.say("result #1: ", cjson.encode(res))

local i = 2
while err == "again" do
	res, err, errcode, sqlstate = db:read_result()
	if not res then
		ngx.log(ngx.ERR, "bad result #", i, ": ", err, ": ", errcode, ": ", sqlstate, ".")
		return ngx.exit(500)
	end

	ngx.say("result #", i, ": ", cjson.encode(res))
	i = i + 1
end

local ok, err = db:set_keepalive(10000, 50)
if not ok then
	ngx.log(ngx.ERR, "failed to set keepalive: ", err)
	ngx.exit(500)
end
```

如果mysql无法远程访问，参考:[
mysql 拒绝远程主机连接问题](https://blog.csdn.net/jasnet_u/article/details/52456076)

# redis

[lua-resty-redis](https://github.com/openresty/lua-resty-redis)
``` lua
local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)

red:init_pipeline()
red:set("cat", "Marry")
red:set("horse", "Bob")
red:get("cat")
red:get("horse")
local results, err = red:commit_pipeline()
if not results then
    ngx.say("failed to commit the pipelined requests: ", err)
    return
end

for i, res in ipairs(results) do
    if type(res) == "table" then
        if res[1] == false then
            ngx.say("failed to run command ", i, ": ", res[2])
        else
            -- process the table value
        end
    else
        -- process the scalar value
    end
end

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

-- or just close the connection right away:
-- local ok, err = red:close()
-- if not ok then
--     ngx.say("failed to close: ", err)
--     return
-- end
```