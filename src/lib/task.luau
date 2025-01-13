-- Licensed under the MIT License, Copyright (c) 2024 jack.ink
-- Modified by jiwonz

local types = require("./types")

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

local task = {} :: types.TaskLibrary

function task.wait(duration)
	-- selene: allow(shadowing)
	local duration = duration or 0

	waitingThreads[coroutine.running()] = { resume = last_tick + duration, start = last_tick }
	return coroutine.yield()
end

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

function task.defer(functionOrThread, ...)
	local thread = if type(functionOrThread) == "thread" then functionOrThread else coroutine.create(functionOrThread)
	table.insert(deferredThreads, { thread = thread, args = table.pack(...) })

	return thread
end

function task.spawn(functionOrThread, ...)
	local thread = if type(functionOrThread) == "thread" then functionOrThread else coroutine.create(functionOrThread)
	resumeWithErrorCheck(thread, ...)

	return thread
end

function task.cancel(thread)
	coroutine.close(thread)
end

function task.start()
	while true do
		last_tick = os.clock()

		processWaiting()
		processDeferred()
	end
end

return task
