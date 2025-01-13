local task = require("../src/lib")

task.delay(1, function()
	print("hello there")
end)

if task.start then
	task.start()
end
