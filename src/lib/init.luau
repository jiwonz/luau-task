local types = require("./types")

local task: types.TaskLibrary? = task :: any
if task then -- when roblox's task built-in library is available
	return task
end

if (_VERSION :: string):sub(1, 4) == "Lune" then
	task = require("@lune/task") :: any
end

if (_VERSION :: string) == "Luau" then
	task = require("./task")
end

if task == nil then
	error("Failed to get task library.")
end

return task
