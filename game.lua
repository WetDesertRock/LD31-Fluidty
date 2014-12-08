local Group = require("base.group")
local Media = require("base.mediamanager")

local Chain = require("chain")
local Enemy = require("enemy")

local Object = require("lib.classic")
local states = require("lib.statements")
local lume = require("lib.lume")
local coil = require("lib.coil")
local flux = require("lib.flux")
local LightWorld = require("lib.lightWorld")

local Game = Object:extend()

function Game:new()
  self.entities = Group()
  self.entities.collidable = false
  self.camera = require("base.camera")()
  self.world = love.physics.newWorld(0, 0)

  self.debug = false
  self.gameover = false
  self.displaydeath = false
  self.kills = 0
  self.spawnrate = 0.6
  self.difficulty = 3
  self.targets = {
    {love.graphics.getWidth()/3,love.graphics.getHeight()/2},
    {2*love.graphics.getWidth()/3,love.graphics.getHeight()/2}
  }
  self.health = 5
  self.timer = 0

  self.threads = coil.group()
  self.tweens = flux.group()

  self.threads:add(function()
    while true do
      coil.wait(self.spawnrate)
      if self.gameover then
        return
      end
      self:addEnemy()
    end
  end)

  self.chain = Chain(self.world,5,10,5)

  self.lightWorld = LightWorld({
    ambient = {50, 50, 50}
    })
  self.chrom = {
    r = {x=0,y=0},
    g = {x=0,y=0},
    b = {x=0,y=0}
  }

  local mco = 7--max chrom off
  self.chromoffamt = 0.2
  self.chromjitter = {0.03,0.08}

  local function tweenchromr()
    local moff = mco*self.chromoffamt
    local x,y = lume.random(-moff,moff),lume.random(-moff,moff)
    self.tweens:to(self.chrom.r,lume.random(unpack(self.chromjitter)),{x=x,y=y}):oncomplete(tweenchromr)
  end
  local function tweenchromg()
    local moff = mco*self.chromoffamt
    local x,y = lume.random(-moff,moff),lume.random(-moff,moff)
    self.tweens:to(self.chrom.g,lume.random(unpack(self.chromjitter)),{x=x,y=y}):oncomplete(tweenchromr)
  end
  local function tweenchromb()
    local moff = mco*self.chromoffamt
    local x,y = lume.random(-moff,moff),lume.random(-moff,moff)
    self.tweens:to(self.chrom.b,lume.random(unpack(self.chromjitter)),{x=x,y=y}):oncomplete(tweenchromr)
  end
  tweenchromr()
  tweenchromg()
  tweenchromb()

  self.targetlights = {}
  self.lightSmooth = 1.8

  for k,v in pairs(self.targets) do
    l = self.lightWorld:newLight(v[1], v[2], 255, 255, 255, 500)
    l:setSmooth(self.lightSmooth)
    l:setPosition(v[1], v[2],20)
    self.targetlights[k] = l
  end

  self.chain.light = self.lightWorld:newLight(self.targetx, self.targety, 100, 100, 100, 100)
  self.chain.light:setSmooth(1.7)
  self.points = 0
end

function Game:update(dt)
  if not self.gameover then
    self.entities:update(dt)
    self.chain.tgtx = love.mouse.getX()
    self.chain.tgty = love.mouse.getY()

    table.sort(self.entities.membersCollision, function(a,b) return a.x < b.x end)

    for h=1,#self.chain.hitboxes,16 do
      local curx,cury = self.chain.hitboxes[h],self.chain.hitboxes[h+1]
      for i=1, #self.entities.membersCollision do
        local o = self.entities.membersCollision[i]
        if o:is(Enemy) and not o.dying then
          ox,oy = o:middleX(),o:middleY()
          if curx + self.chain.rad < ox-o.radius then break end --WILL BREAK WITH VARIABLE SIZED ENTITIES
          if lume.distance(curx,cury,ox,oy) - self.chain.rad - o.radius < 0 then
            o.tweens:to(o,0.2,{opacity=0}):oncomplete(function() o:kill() end)
            o.dying = true
            self.points = self.points + self.timer/2
          end
        end
      end
    end

    self.chain:update(dt)
    self.world:update(dt)
    self.chromoffamt = math.max(0,self.chromoffamt - (dt*2))
  end
  for k,l in pairs(self.targetlights) do
    l:setSmooth(self.lightSmooth)
  end
  self.timer = self.timer + dt
  self.threads:update(dt)
  self.tweens:update(dt)
end

function Game:addEnemy()
  local x,y = lume.random(0,love.graphics.getWidth()),lume.random(0,love.graphics.getHeight())
  local e = Enemy(x,y)
  self.camera:reject(e)
  local tx,ty = unpack(lume.randomchoice(self.targets))
  e:setTarget(tx,ty,30*30)
  e:initBody()
  self.entities:add(e)
  self.spawnrate = self.spawnrate * 0.995
end

function Game:draw()
  love.graphics.setBackgroundColor(0,0,0)

  self.lightWorld.post_shader:addEffect("chromatic_aberration",
    {self.chrom.r.x,self.chrom.r.y},
    {self.chrom.g.x,self.chrom.g.y},
    {self.chrom.b.x,self.chrom.b.y}
  )

  self.lightWorld:draw(function()
    love.graphics.setColor(178, 223, 225)
    love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())

    love.graphics.setColor(0,0,0)
    self.entities:draw()
    love.graphics.setColor(255,255,255,255)
    for t,pos in ipairs(self.targets) do
      local x,y = unpack(pos)
      love.graphics.draw(Media:getImage("target.png"),x-50,y-50)
    end

    if self.displaydeath then
      love.graphics.setColor(255,255,255)
      love.graphics.setFont(Media:getFont("novamono.ttf",100))
      local s = "Game Over\nPoints: %.4d"
      local x = love.graphics.getWidth()-200-400
      love.graphics.printf(string.format(s,self.points),x,100,400,'right')
      love.graphics.setFont(Media:getFont("novamono.ttf",50))
      love.graphics.printf("Hit any key to restart.",x,500,400,'right')
    end

    self.chain:draw(self.debug)
  end)

  if self.debug then
    self.entities:drawDebug()
  end
end

function Game:hurt()
  self.chromoffamt = 2
  self.health = self.health -1
  self.points = self.points-10
  if self.health <= 0 then
    self.gameover = true
    self.chromjitter = {0.02,0.04}
    Media:playRandSound({"death2.ogg","death3.ogg"},1,1)
    self.tweens:to(self,0.5,{chromoffamt=5}):oncomplete( function()
      self.displaydeath = true
    end):after(self,0.1,{chromoffamt = 0.5})
    self.tweens:to(self,0.5,{lightSmooth=3}):after(self,0.1,{lightSmooth=0.6}):after(self,1,{lightSmooth=1.3})

    local report = {
      points = self.points,
      timer = self.timer,
      spawnrate = self.spawnrate
    }
    statreporter.report("gameend",report,self.debug)

  else
    Media:playRandSound({"newbthluthulthul1.wav","newbthluthulthul2.wav","newbthluthulthul3.wav"},lume.random(0.4,0.7),lume.random(0.9,1.1))
    self.tweens:to(self,0.2,{lightSmooth=1.5}):after(self,0.1,{lightSmooth=1.8})
  end
end

function Game:keypressed(key,isrepeat)
  if key == "\\" then
    self.debug = not self.debug
    return
  end
  if key == "p" then
    local screenshot = love.graphics.newScreenshot( )
    screenshot:encode( string.format("screenshot_%d.png",os.time()) )
    return
  end
  if self.gameover then
    states.switchState(Game())
  end
end

return Game
