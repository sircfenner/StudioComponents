local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Dropdown = require(script.Parent.Dropdown)

local Wrapper = Roact.Component:extend("Wrapper")

local items = string.split(
	"Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
	" "
)

function Wrapper:init()
	self:setState({ Item = "Lorem" })
end

function Wrapper:render()
	return Roact.createElement(Dropdown, {
		Items = items,
		Item = self.state.Item,
		OnSelected = function(item)
			self:setState({ Item = item })
		end,
	})
end

return function(target)
	local element = Roact.createElement(Wrapper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
