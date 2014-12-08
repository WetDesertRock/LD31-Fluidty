local states = require("lib.statements")
local lume = require("lib.lume")
local Media = require("base.mediamanager")


statreporter = require("statreporter")
local Game = require("game")

REPORTSTATS = true

local loveerr = love.errhand
local function errhand(msg)
  local report = {
    msg = tostring(msg),
    trace = debug.traceback(),
  }
  statreporter.report("error",report,false)
  loveerr(msg)
end

love.errhand = errhand

function love.load()
  G = Game()
  states.switchState(G)

  statreporter.init()

  local resw,resh = love.window.getDesktopDimensions( display )
  local report = {
    version = 1.0,
    res = {resw,resh},
    os = love.system.getOS( ),
    snowmanlover = true,
    fused = love.filesystem.isFused(),
    support = {}
  }
  for _,k in ipairs({"canvas","npot","subtractive","shader","hdrcanvas","multicanvas","mipmap","dxt","bc5","srgb"}) do
    report.support[k] = love.graphics.isSupported(k)
  end
  statreporter.report("initial",report,false)

  local soundfiles = love.filesystem.getDirectoryItems("assets/sounds/")
  for k,path in pairs(soundfiles) do
    if string.sub(path, -4) == ".ogg" or string.sub(path, -4) == ".wav" then
      Media:getSound(path)
      print(string.format("Preloaded %s",path))
    end
  end
  Media:getFont("novamono.ttf")
  print("Preloaded novamono.ttf")

  Music = Media:playSound("background.ogg",0.3,lume.random(0.6,0.8))
  Music:setLooping(true)

  love.graphics.setBackgroundColor(200,200,200)
end
