local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local RadioButton = require(script.Parent.RadioButton)

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		Selected = 1,
	})
end

function Wrapper:render()
	local count = 3

	local buttons = {}
	for i = 1, count do
		buttons[i] = Roact.createElement(RadioButton, {
			LayoutOrder = i,
			Value = self.state.Selected == i,
			Label = "Button" .. tostring(i),
			Disabled = i == count,
			OnActivated = function()
				self:setState({ Selected = i })
			end,
		})
	end

	return Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Buttons = Roact.createFragment(buttons),
	})
end

return function(target)
	local element = Roact.createElement(Wrapper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
