local http = require("socket.http")
local ltn12 = require("ltn12")

local function sendMessage(m)
    local message = m
    local respbody = {} -- for the response body

    local result, respcode, respheaders, respstatus = http.request {
        method = "POST",
        url = "http://192.3.115.168:8888",
        -- url = "http://localhost:8888",
        source = ltn12.source.string(message),
        headers = {
            ["content-type"] = "text/json",
            ["content-length"] = tostring(#message)
        },
        sink = ltn12.sink.table(respbody)
    }
    -- get body as string by concatenating table filled by sink
    respbody = table.concat(respbody)
    return respbody, dresult, respcode, respheaders, respstatus
end

local channel = love.thread.getChannel("stat_channel")
while true do
    local m = channel:demand()
    sendMessage(m)
end
