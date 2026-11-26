--[[
    SNOWY Bootstrap v2.5
    Place in the repository root and run this file only.
]]
local BASE = "https://raw.githubusercontent.com/irongg676/SNOWY/main"
local url = BASE .. "/src/Main.lua"
local function report(msg) warn("SNOWY ❄️: " .. tostring(msg)) end
if type(loadstring) ~= "function" then
    report("loadstring غير متاح في بيئة التشغيل.")
    return
end
local ok, source = pcall(function() return game:HttpGet(url) end)
if not ok or type(source) ~= "string" or source == "" then
    report("تعذر تحميل src/Main.lua. تحقق من Public ومن مسار main.")
    return
end
local compiled, chunk = pcall(loadstring, source)
if not compiled or type(chunk) ~= "function" then
    report("تعذر ترجمة Main.lua.")
    return
end
local ran, err = pcall(chunk)
if not ran then report("Startup failed: " .. tostring(err)) end
