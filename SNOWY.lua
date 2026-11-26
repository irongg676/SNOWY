--[[
    SNOWY ❄️ Bootstrap v2.2
    Place this file in the root of irongg676/SNOWY and run it from Delta.
    It downloads src/Main.lua; Main.lua then loads the shared modules from src/.
]]

local RAW_BASE = "https://raw.githubusercontent.com/irongg676/SNOWY/main"
local MAIN_URL = RAW_BASE .. "/src/Main.lua"

local function fail(message)
    warn("SNOWY ❄️: " .. tostring(message))
end

if type(loadstring) ~= "function" then
    fail("loadstring is not available in this environment.")
    return
end

local requestOk, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)
if not requestOk or type(source) ~= "string" or source == "" then
    fail("Could not download src/Main.lua. Check internet access and that the GitHub repository is Public.")
    return
end

local compileOk, chunk = pcall(loadstring, source)
if not compileOk or type(chunk) ~= "function" then
    fail("Could not compile src/Main.lua.")
    return
end

local runOk, runtimeError = pcall(chunk)
if not runOk then
    fail("Startup failed: " .. tostring(runtimeError))
end
