-- Most of this file was stolen from rxi

local lume = require("lib.lume")
local Object = require("lib.classic")
local Entity = require("base.entity")

local Group = Entity:extend()

function Group:new()
    Group.super.new(self)
    self.members = {}
    self.membersCollision = {}
    self.collidable = true
    self.solid = false
end

function Group:clear()
    self.members = {}
    self.membersCollision = {}
end


function Group:add(e, idx)
    assert(e and e:is(Entity), "bad entity")
    if idx then
        table.insert(self.members, idx, e)
    else
        table.insert(self.members, e)
    end
    if e.collidable then
        table.insert(self.membersCollision, e)
    end
    e.parent = self
end


function Group:remove(e)
    table.remove(self.members, lume.find(self.members, e))
    if e.collidable then
        table.remove(self.membersCollision, lume.find(self.membersCollision, e))
    end
    if e.parent == self then e.parent = nil end
end


function Group:updateCollision(dt)
    table.sort(self.membersCollision, function(a,b) return a.x < b.x end)
    for i = 1, #self.membersCollision do
        for j = i + 1, #self.membersCollision do
            local a = self.membersCollision[i]
            local b = self.membersCollision[j]
            if a.x + a.width < b.x then break end
            if a:overlaps(b) then
                a:onCollide(b)
                b:onCollide(a)
            end
        end
    end
end


function Group:update(dt)
    Group.super.update(self, dt)
    -- Update
    for i = #self.members, 1, -1 do
        local e = self.members[i]
        e:update(dt)
    end
    -- Purge dead
    for i = #self.members, 1, -1 do
        local e = self.members[i]
        if e.dead then self:remove(e) end
    end
    if self.collidable then self:updateCollision(dt) end
end


function Group:drawDebug()
    lume.each(self.members, "drawDebug")
end

function Group:draw()
    for i, e in ipairs(self.members) do
      e:draw()
    end
end


return Group
