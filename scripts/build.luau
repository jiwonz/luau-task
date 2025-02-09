local multitarget = require("../lune_packages/multitarget")

multitarget.build(nil, "dist", {
	luau = true,
	lune = true,
	roblox = true,
}, { "src" }, nil, true)
