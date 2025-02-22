-- Licensed under the MIT License, Copyright (c) 2024 jack.ink
-- Modified by jiwonz

-- Original types credit to: https://github.com/lune-org/lune/blob/414d8ff8f3f6a566dada5ad17375260ee312b293/types/task.luau
-- Original descriptions credit to: https://create.roblox.com/docs/reference/engine/libraries/task

if _G.LUA_ENV ~= "luau" then
	error("unreachable")
	return nil :: any
end

local function resumeWithErrorCheck(thread: thread, ...: any): ()
	local success, message = coroutine.resume(thread, ...)

	if not success then
		print(string.char(27) .. "[31m" .. message)
	end
end

local last_tick = os.clock()

local waitingThreads: { [thread]: { resume: number } & ({ start: number } | { start: nil, n: number, [number]: any }) } =
	{}

local function processWaiting(): ()
	local processing = waitingThreads
	waitingThreads = {}

	for thread, data in processing do
		if coroutine.status(thread) ~= "dead" then
			if type(data) == "table" and last_tick >= data.resume then
				if data.start then
					resumeWithErrorCheck(thread, last_tick - data.start)
				else
					resumeWithErrorCheck(thread, table.unpack(data, 1, data.n))
				end
			else
				waitingThreads[thread] = data
			end
		end
	end
end

--[=[
	@class TaskLibrary

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
local task = {}

--[=[
	@within TaskLibrary

	Yields the current thread until the next Heartbeat in which the given duration (in seconds) has passed, without throttling.
]=]
function task.wait(duration)
	-- selene: allow(shadowing)
	local duration = duration or 0

	waitingThreads[coroutine.running()] = { resume = last_tick + duration, start = last_tick }
	return coroutine.yield()
end

--[=[
	@within TaskLibrary

	Schedules a function/coroutine to be called/resumed on the next Heartbeat after the given duration (in seconds) has passed, without throttling.
]=]
function task.delay(duration, functionOrThread, ...)
	local thread = if type(functionOrThread) == "thread" then functionOrThread else coroutine.create(functionOrThread)

	local data: { [any]: any } = table.pack(...)
	data.resume = last_tick + duration
	waitingThreads[thread] = data

	return thread
end

local deferredThreads: { { thread: thread, args: { [number]: any, n: number } } } = {}

local function processDeferred(): ()
	local i = 1

	while i <= #deferredThreads do
		local data = deferredThreads[i]

		if coroutine.status(data.thread) ~= "dead" then
			resumeWithErrorCheck(data.thread, table.unpack(data.args))
		end

		i += 1
	end

	table.clear(deferredThreads)
end

--[=[
	@within TaskLibrary

	Calls/resumes a function/coroutine at the end of the current resumption cycle.
]=]
function task.defer(functionOrThread, ...)
	local thread = if type(functionOrThread) == "thread" then functionOrThread else coroutine.create(functionOrThread)
	table.insert(deferredThreads, { thread = thread, args = table.pack(...) })

	return thread
end

--[=[
	@within TaskLibrary

	Calls/resumes a function/coroutine immediately through the engine scheduler.
]=]
function task.spawn(functionOrThread, ...)
	local thread = if type(functionOrThread) == "thread" then functionOrThread else coroutine.create(functionOrThread)
	resumeWithErrorCheck(thread, ...)

	return thread
end

--[=[
	@within TaskLibrary

	Cancels a thread, preventing it from being resumed.
]=]
function task.cancel(thread)
	coroutine.close(thread)
end

--[=[
	@within TaskLibrary

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
function task.start(asyncMainFunction)
	if asyncMainFunction then
		coroutine.resume(coroutine.create(asyncMainFunction))
	end

	while next(waitingThreads) or next(deferredThreads) do
		last_tick = os.clock()

		processWaiting()
		processDeferred()
	end
end

return task
