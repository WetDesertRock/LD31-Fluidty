-- None of this was stolen from rxi

local Object = require("lib.classic")
local lume = require("lib.lume")

local MediaManager = Object:extend()

function MediaManager:new()
    self:purge()
end

function MediaManager:getImage(path)
    path = "assets/images/"..path
    if self.graphics[path] == nil then
        self.graphics[path] = love.graphics.newImage( path )
    end
    return self.graphics[path]
end

function MediaManager:getFont(path,size)
    path = "assets/fonts/"..path
    fpath = tostring(size)..path
    if self.fonts[fpath] == nil then
        self.fonts[fpath] = love.graphics.newFont( path,size )
    end
    return self.fonts[fpath]
end

function MediaManager:getSound(path)
    path = "assets/sounds/"..path
    if self.sounds[path] == nil then
        self.sounds[path] = love.audio.newSource( path,"static" )
    end
    return self.sounds[path]:clone()
end

function MediaManager:playSound(path,volume,pitch)
    local snd = self:getSound(path)
    if volume ~= nil then
        snd:setVolume(volume)
    end
    if pitch ~= nil then
        snd:setPitch(pitch)
    end
    snd:play()

    return snd
end

function MediaManager:playRandSound(snds,volume,pitch)
    self:playSound(lume.randomchoice(snds),volume,pitch)
end

function MediaManager:getItemCount()
    return getTableLength(self.graphics) + getTableLength(self.fonts) + getTableLength(self.sounds)
end

function MediaManager:purge()
    self.graphics = {}
    self.fonts = {}
    self.sounds = {}
end

return MediaManager()
