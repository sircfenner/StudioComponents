local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Background = require(script.Parent.Background)

return function(target)
	local element = Roact.createElement(Background)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
