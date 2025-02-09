-- Original types credit to: https://github.com/lune-org/lune/blob/414d8ff8f3f6a566dada5ad17375260ee312b293/types/task.luau
-- Original descriptions credit to: https://create.roblox.com/docs/reference/engine/libraries/task

--[=[
	Allows for functions and threads to be coordinated with the Task Scheduler.

	### Example usage

	```luau
	local task = require("./task")

	-- Waiting for a certain amount of time
	task.wait(1)
	print("Waited for one second")

	-- Running a task after a given amount of time
	task.delay(2, function()
		print("Ran after two seconds")
	end)

	-- Spawning a new task that runs concurrently
	task.spawn(function()
		print("Running instantly")
		task.wait(1)
		print("One second passed inside the task")
	end)

	print("Running after task.spawn yields")
	```
]=]
export type TaskLibrary = {
	--[=[
		Cancels a thread, preventing it from being resumed.
	]=]
	cancel: (thread: thread) -> (),
	--[=[
		Calls/resumes a function/coroutine at the end of the current resumption cycle.
	]=]
	defer: <A..., R...>(functionOrThread: thread | (A...) -> R..., A...) -> thread,
	--[=[
		Schedules a function/coroutine to be called/resumed on the next Heartbeat after the given duration (in seconds) has passed, without throttling.
	]=]
	delay: <A..., R...>(duration: number, functionOrThread: thread | (A...) -> R..., A...) -> thread,
	--[=[
		Calls/resumes a function/coroutine immediately through the engine scheduler.
	]=]
	spawn: <A..., R...>(functionOrThread: thread | (A...) -> R..., A...) -> thread,
	--[=[
		Yields the current thread until the next Heartbeat in which the given duration (in seconds) has passed, without throttling.
	]=]
	wait: (duration: number?) -> number,
	--[=[
		Causes the following code to be run in parallel.

		### Warning
		This function can be `nil`. (Only available in runtime `roblox`)

		### Example Usage
		```luau
		local task = require("./task")

		if not task.desynchronize then
			error("'task.desynchronize' is nil. Are you in roblox runtime?")
		end

		task.desynchronize()
		```
	]=]
	desynchronize: (() -> ())?,
	--[=[
		Causes the following code to be run in serial.

		### Warning
		This function can be `nil`. (Only available in runtime `roblox`)

		### Example Usage
		```luau
		local task = require("./task")

		if not task.synchronize then
			error("'task.synchronize' is nil. Are you in roblox runtime?")
		end

		task.synchronize()
		```
	]=]
	synchronize: (() -> ())?,
	--[=[
		Starts the scheduler. this blocks the current thread.

		### Warning
		This function can be `nil`. (Only available in runtime `luau`)

		### Example Usage
		```luau
		-- example of cross-environment script with task lib
		-- works almost same in roblox, luau, and lune
		local task = require("./task")

		local function main()
			task.wait(1)
			print("1 second passed")
		end

		if task.start then
			task.start(main)
		else
			main()
		end
		```
	]=]
	start: (<A..., R...>(asyncMainFunction: ((A...) -> R...)?) -> ())?,
}

return {}
