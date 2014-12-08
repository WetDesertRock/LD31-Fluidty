local Entity = require("base.entity")
local Vector = require("base.vector")
local Media = require("base.mediamanager")

local coil = require("lib.coil")


local Actor = Entity:extend()

function Actor:new()
  Actor.super.new(self)
  self.group = "actor"
  self.hp = 1
  self.rotation = 0
  self.maxspeed = 70
  self.radius = 0
end

function Actor:tryShoot()
  if self.canshoot then
    self.canshoot = false
    self.threads:add(function()
      coil.wait(self.shotrate)
      self.canshoot = true
    end)
    self:shoot()
  end
end

function Actor:update(dt)
  self.velocity:limit(self.maxspeed)
  Actor.super.update(self,dt)
end

function Actor:drawDebug()
  love.graphics.setLineWidth(1)
  love.graphics.setColor(255,0,0)
  love.graphics.circle("line",self:middleX(),self:middleY(),self.radius)

  love.graphics.setColor(0,0,255)
  love.graphics.line(self:middleX(),self:middleY(),self.velocity.x+self.x,self.velocity.y+self.y)

  love.graphics.setColor(0,255,0)
  local a = Vector.fromAngleMag(self.rotation,10)
  love.graphics.line(self.x,self.y,a.x+self.x,a.y+self.y)
end


return Actor
