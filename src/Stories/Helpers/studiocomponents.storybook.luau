--!nocheck

local React = require("@pkg/@jsdotlua/react")
local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

return {
	name = "StudioComponents",
	storyRoots = {
		script.Parent.Parent,
	},
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
