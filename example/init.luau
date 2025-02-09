_G.LUA_ENV = "lune"

local task = require("../")

local function main()
	task.delay(1, function()
		print("hi")
	end)

	print(task.wait(1))
	print("bruh")

	task.spawn(function()
		print("ez")
		task.wait(1)
		print("no")
	end)
end

if task.start then
	task.start(main)
else
	main()
end
