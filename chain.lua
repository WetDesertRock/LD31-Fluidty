local Object = require("lib.classic")

local Chain = Object:extend()

function Chain:new(world,segs,dist,rad)
  self.dist = dist or 20
  self.rad = rad or 5

  self.chain = {}
  self.color = {117, 129, 255, 0.42*255}
  self.visible = true

  self.tgtx,self.tgty = 0,0

  local obj = {}
  obj.body = love.physics.newBody(world, 0, 0, "dynamic")
  obj.shape = love.physics.newCircleShape(self.rad)
  obj.fixture = love.physics.newFixture(obj.body, obj.shape)
  obj.joint = love.physics.newMouseJoint(obj.body, 0,0)
  obj.joint:setMaxForce(1000)
  table.insert(self.chain,obj)

  for i=1,segs do
    local prevobj = obj
    obj = {}
    obj.body = love.physics.newBody(world, 0,0-i*self.dist, "dynamic")
    obj.shape = love.physics.newCircleShape(self.rad)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)
    obj.body:setLinearDamping(3)
    local x1,y1 = prevobj.body:getPosition()
    local x2,y2 = obj.body:getPosition()
    obj.joint = love.physics.newRopeJoint(prevobj.body,obj.body,x1,y1,x2,y2,50,true)
    table.insert(self.chain,obj)
  end

  local verts = self:getVerts()
  self.curve = love.math.newBezierCurve( verts )
  self.hitboxes = {}
  self.light = nil
end

function Chain:getVerts()
  local verts = {}
  for _,link in ipairs(self.chain) do
    local x,y = link.body:getPosition()
    table.insert(verts,x)
    table.insert(verts,y)
  end
  return verts
end

function Chain:update(dt)
  self.chain[1].joint:setTarget(self.tgtx,self.tgty)
  local line = {}
  for i,link in ipairs(self.chain) do
    local x,y = link.body:getPosition()
    self.curve:setControlPoint(i,x,y)
    table.insert(line,x)
    table.insert(line,y)
  end
  self.hitboxes = self.curve:render(3)
  if self.light then
    local x,y = self.chain[1].body:getPosition()
    self.light:setPosition(x,y)
  end
end

function Chain:draw(debug)
  love.graphics.setColor(self.color)
  love.graphics.setLineWidth(3)
  if self.visible then
    love.graphics.line(self.hitboxes)
  end
  if debug then
    for i=1,#self.hitboxes,16 do
      love.graphics.setColor(255,255,255)
      love.graphics.circle("fill",self.hitboxes[i],self.hitboxes[i+1],self.rad)
    end
  end
end


return Chain
