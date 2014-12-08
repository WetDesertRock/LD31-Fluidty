local json = require('lib.dkjson')

local _ = {}

function _.init()
  _.channel = love.thread.getChannel("stat_channel")
  _.thread = love.thread.newThread("statsender.lua")
  if REPORTSTATS then
    _.thread:start()
  end
end

function _.report(type,data,debugmode)
  local msg = {type=type,data=data,debug=debugmode}
  msg.data.game = love.filesystem.getIdentity()
  if REPORTSTATS then
    _.channel:push(json.encode(msg,{indent=false}))
  end
end

return _
