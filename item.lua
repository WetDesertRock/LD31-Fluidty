local Object = require("lib.classic")
local Media = require("base.mediamanager")

local guient = require("guientity")

local Store = Object:extend()
function Store:new()
  self.picture = Media:getImage("store_item.png")
end

function Store:use()
  local ent = guient()
  ent:at(G.player)
  G.entities:add(ent)
end


local _ = {store=Store}
return _
