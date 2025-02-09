# luau-task
Get the task library for `Roblox` or `Lune` or `Luau`. Inspired by [seaofvoices/luau-task](https://github.com/seaofvoices/luau-task).

## Installation
via pesde
```sh
pesde add jiwonz/task
pesde install
```

## Example Usage
```luau
-- It works almost identically in cross-environment.
local task = require("./path/to/task")

local function main() -- We need a separate thread from a main thread in luau.
	local s = task.wait(1) -- Since we cannot yield a main thread in luau.
	print(`{s} seconds has passed`)
end

if task.start then -- 'task.start' is only available in luau. Starts a new thread(optional) and scheduler.
	task.start(main)
else
	main()
end
```

## Credits
- [jackdotink/task.luau](https://gist.github.com/jackdotink/5cd1757f599ba13d37f447fd7f41604c) - Pure luau task implementation
