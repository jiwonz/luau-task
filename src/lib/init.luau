local types = require("./types")

local task: any

if _G.LUA_ENV == "luau" then
	task = require("./task")
elseif _G.LUA_ENV == "lune" then
	task = require("@lune/task")
elseif _G.LUA_ENV == "roblox" then
	task = task
end

return task :: types.TaskLibrary
