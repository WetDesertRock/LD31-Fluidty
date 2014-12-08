-- None of this was stolen from rxi

local Rect = require("base.rect")
local Camera = Rect:extend()

function Camera:new(x,y,w,h)
  self.x = x or 0
  self.y = y or 0
  self.width = w or love.graphics.getWidth()
  self.height = h or love.graphics.getHeight()
  self.focus = nil
end

function Camera:focus(obj)
  self.focus = obj
end

function Camera:update(td)
  if self.focus then
    self:at(self.focus)
  end
end

function Camera:attach()
  love.graphics.push()
  love.graphics.translate(-self.x,-self.y)
end

function Camera:detach()
  love.graphics.pop()
end

function Camera:getMouseX()
  return love.mouse.getX()+self.x
end
function Camera:getMouseY()
  return love.mouse.getY()+self.y
end
function Camera:getMousePos()
  return self:getMouseX(),self:getMouseY()
end


return Camera
