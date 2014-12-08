
-- Not stolen from rxi: Original: https://gist.github.com/BlackBulletIV/1055480
local Object = require("lib.classic")
local Vector = Object:extend()

function Vector.fromAngleMag(a,m)
    local x = math.cos(a)*m
    local y = math.sin(a)*m
    return Vector(x,y)
end

function Vector.__add(a, b)
    if type(a) == "number" then
        return Vector(b.x + a, b.y + a)
    elseif type(b) == "number" then
        return Vector(a.x + b, a.y + b)
    else
        return Vector(a.x + b.x, a.y + b.y)
    end
end

function Vector.__sub(a, b)
    if type(a) == "number" then
        return Vector(b.x - a, b.y - a)
    elseif type(b) == "number" then
        return Vector(a.x - b, a.y - b)
    else
        return Vector(a.x - b.x, a.y - b.y)
    end
end

function Vector.__mul(a, b)
    if type(a) == "number" then
        return Vector(b.x * a, b.y * a)
    elseif type(b) == "number" then
        return Vector(a.x * b, a.y * b)
    else
        return Vector(a.x * b.x, a.y * b.y)
    end
end

function Vector.__div(a, b)
    if type(a) == "number" then
        return Vector(b.x / a, b.y / a)
    elseif type(b) == "number" then
        return Vector(a.x / b, a.y / b)
    else
        return Vector(a.x / b.x, a.y / b.y)
    end
end

function Vector.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector.__lt(a, b)
    return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a, b)
    return a.x <= b.x and a.y <= b.y
end

function Vector.__tostring(a)
    return "(" .. a.x .. ", " .. a.y .. ")"
end

function Vector:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Vector.distance(a, b)
    return (b - a):len()
end

function Vector:clone()
    return Vector(self.x, self.y)
end

function Vector:unpack()
    return self.x, self.y
end

function Vector:len()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:lenSq()
    return self.x * self.x + self.y * self.y
end

function Vector:normalize()
    local len = self:len()
    if len == 0 then
        return self
    end

    self.x = self.x / len
    self.y = self.y / len
    return self
end

function Vector:normalized()
    return self / self:len()
end

function Vector:rotate(phi)
    local c = math.cos(phi)
    local s = math.sin(phi)
    self.x = c * self.x - s * self.y
    self.y = s * self.x + c * self.y
    return self
end

function Vector:rotated(phi)
    return self:clone():rotate(phi)
end

function Vector:perpendicular()
    return Vector(-self.y, self.x)
end

function Vector:projectOn(other)
    return (self * other) * other / other:lenSq()
end

function Vector:cross(other)
    return self.x * other.y - self.y * other.x
end

function Vector:heading()
    return math.atan2(self.y,self.x)
end

function Vector:angleTo(other)
  return math.atan2(self.y, self.x) - math.atan2(other.y, other.x)
end

function Vector:limit(mag)
    local a = self:heading()
    local m = self:len()
    m = math.min(mag,m)
    self.x = math.cos(a)*m
    self.y = math.sin(a)*m
end


return Vector
