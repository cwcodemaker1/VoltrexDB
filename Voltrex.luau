-- Voltrex GitHub bootstrap
-- Repository: https://github.com/cwcodemaker1/VoltrexDB

local BASE = "https://raw.githubusercontent.com/cwcodemaker1/VoltrexDB/main/"
local ENV = (typeof(getgenv) == "function" and getgenv()) or _G

local function fetch(fileName)
	local ok, source = pcall(function()
		return game:HttpGet(BASE .. fileName)
	end)

	if not ok then
		error("[Voltrex] Failed to download " .. fileName .. ": " .. tostring(source))
	end

	if type(source) ~= "string" or source == "" then
		error("[Voltrex] Empty response for " .. fileName)
	end

	return source
end

local function loadFile(fileName)
	local source = fetch(fileName)
	local chunk, compileError = loadstring(source, "@" .. fileName)

	if not chunk then
		error("[Voltrex] Compile error in " .. fileName .. ": " .. tostring(compileError))
	end

	local ok, result = pcall(chunk)
	if not ok then
		error("[Voltrex] Runtime error in " .. fileName .. ": " .. tostring(result))
	end

	return result
end

local Interface = loadFile("interface.luaui")
if type(Interface) ~= "table" then
	error("[Voltrex] interface.luaui did not return a table")
end

local Communications = loadFile("Communications.luaui")
if type(Communications) ~= "table" then
	error("[Voltrex] Communications.luaui did not return a table")
end

ENV.__VOLTREX_INTERFACE = Interface
ENV.__VOLTREX_COMMUNICATIONS = Communications

local Main
local ok, mainResult = pcall(function()
	return loadFile("Main.luaui")
end)

ENV.__VOLTREX_INTERFACE = nil
ENV.__VOLTREX_COMMUNICATIONS = nil

if not ok then
	error(mainResult)
end

Main = mainResult

if type(Main) ~= "table" then
	error("[Voltrex] Main.luaui did not return a table")
end

if type(Main.Start) ~= "function" then
	error("[Voltrex] Main.Start is missing")
end

local started, startResult, startError = pcall(Main.Start)
if not started then
	error("[Voltrex] Main.Start failed: " .. tostring(startResult))
end

if startResult == nil and startError ~= nil then
	error("[Voltrex] Main.Start returned an error: " .. tostring(startError))
end

return Main
