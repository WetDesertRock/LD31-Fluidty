local states = {}

states.currentstate = nil
states.globalstate = nil
states.pendingstate = nil

-- Used to call methods as if it was a love handler on the state tables. Also
-- defaults back to the actual love callbacks.
local function callMethod(deffun,m,...)
    if states.pendingstate ~= nil then
        states.currentstate = states.pendingstate
        states.pendingstate = nil
        callMethod(nil,"enter",states.currentstate,...)
    end

    local called = false
    if states.globalstate and states.globalstate[m] then
        states.globalstate[m](states.globalstate,...)
        called = true
    end
    if states.currentstate and states.currentstate[m] then
        states.currentstate[m](states.currentstate,...)
        called = true
    end
    if not called and deffun then
        deffun(...)
    end
end

function states.switchState(s,...)
    callMethod(nil,"leave",s,...)
    states.pendingstate = s
end

function states.setGlobalState(s)
    states.globalstate = s
end

function states.new()
    return {}
end

--[[ Neat python code to find callbacks:
import re
s = <insert wiki contents here>
callbacks = re.findall("^love\.(\w+)",s,re.MULTILINE)
]]--

local callbacks = {'draw', 'errhand', 'focus', 'keypressed', 'keyreleased',
    'load', 'mousefocus', 'mousepressed', 'mousereleased', 'quit', 'resize',
    'run', 'textinput', 'threaderror', 'update', 'visible', 'gamepadaxis',
    'gamepadpressed', 'gamepadreleased', 'joystickadded', 'joystickaxis',
    'joystickhat', 'joystickpressed', 'joystickreleased', 'joystickremoved'}

for k, name in pairs(callbacks) do
    if name ~= "load" then
        local old = love[name]
        love[name] = function(...)
            return callMethod(old, name, ...)
        end
    end
end

return states