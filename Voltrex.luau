local BASE = "https://raw.githubusercontent.com/cwcodemaker1/VoltrexDB/main/"

local function Download(file)
	local success, source = pcall(function()
		return game:HttpGet(BASE .. file)
	end)

	if not success then
		error("Failed to download " .. file .. ": " .. tostring(source))
	end

	return source
end

local function LoadModule(file)
	local source = Download(file)

	local chunk, err = loadstring(source)

	if not chunk then
		error("Failed to compile " .. file .. ": " .. tostring(err))
	end

	local success, result = pcall(chunk)

	if not success then
		error("Failed to run " .. file .. ": " .. tostring(result))
	end

	return result
end

-- Load dependencies first
local Interface = LoadModule("Interface.luaui")
local Communications = LoadModule("Communications.luaui")

-- Store them temporarily for Main
local ENV = getgenv and getgenv() or _G

ENV.__VOLTREX_INTERFACE = Interface
ENV.__VOLTREX_COMMUNICATIONS = Communications

-- Download Main
local MainSource = Download("Main.luaui")

-- Replace normal Roblox ModuleScript requires
MainSource = MainSource:gsub(
	"local Interface = require%(script%.Parent%.Interface%)",
	"local Interface = (getgenv and getgenv() or _G).__VOLTREX_INTERFACE"
)

MainSource = MainSource:gsub(
	"local Communications = require%(script%.Parent%.Communications%)",
	"local Communications = (getgenv and getgenv() or _G).__VOLTREX_COMMUNICATIONS"
)

-- Compile Main
local MainChunk, MainError = loadstring(MainSource)

if not MainChunk then
	error("Failed to compile Main.luaui: " .. tostring(MainError))
end

local success, Main = pcall(MainChunk)

if not success then
	error("Failed to initialize Main.luaui: " .. tostring(Main))
end

if type(Main) ~= "table" then
	error("Main.luaui did not return a module table")
end

if type(Main.Start) ~= "function" then
	error("Main.Start() does not exist")
end

-- Start Voltrex
Main.Start()

-- Remove temporary bootstrap globals
ENV.__VOLTREX_INTERFACE = nil
ENV.__VOLTREX_COMMUNICATIONS = nil

return Main
