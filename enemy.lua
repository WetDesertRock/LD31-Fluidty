local Vector = require("base.vector")
local Media = require("base.mediamanager")

local Actor = require("actor")

local lume = require("lib.lume")

local Enemy = Actor:extend()

function Enemy:new(x,y)
  Enemy.super.new(self)
  self:setImage("enemy.png",40)
  self.x,self.y = x,y
  self.range = 0
  self.radius = 20
  self.lightobj = nil
  self.dying = false
end

function Enemy:setTarget(tgtx,tgty,range)
  self.velocity = Vector(tgtx-self:middleX(),tgty-self:middleY())
  self.rotation = self.velocity:heading()
  self.targetx,self.targety = tgtx,tgty
  self.range = range
end

function Enemy:setLight(light)
  self.lightobj = light
end

function Enemy:initBody()
  self.lightobj = G.lightWorld:newCircle(self:middleX(), self:middleY(), self.radius)
end
function Enemy:update(dt)
  Enemy.super.update(self,dt)
  if not self.dying and lume.distance(self:middleX(),self:middleY(),self.targetx,self.targety,true) < self.range then
    G:hurt()
    self:kill(true)
  end
  if self.lightobj then
    self.lightobj:setPosition(self:middleX(), self:middleY())
  end
end

function Enemy:onKill(nosound)
  if self.lightobj then
    G.lightWorld:remove(self.lightobj)
  end
  if not nosound then
    Media:playRandSound({"newunvshvshvsh.wav","newunvshvshvsh2.wav","newunvshvshvsh3.wav"},lume.random(0.3,0.6),lume.random(0.9,1.1))
  end
end

return Enemy
