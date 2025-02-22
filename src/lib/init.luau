return if _G.LUA_ENV == "luau"
	then require("./task")
	elseif _G.LUA_ENV == "lune" then require("@lune/task")
	elseif _G.LUA_ENV == "roblox" then task
	else {}
