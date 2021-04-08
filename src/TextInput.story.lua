local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local TextInput = require(script.Parent.TextInput)
local Checkbox = require(script.Parent.Checkbox)

local Wrapper = Roact.Component:extend("TestWrapper")

function Wrapper:init()
	self:setState({
		Disabled = false,
	})
end

function Wrapper:render()
	return Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Input = Roact.createElement(TextInput, {
			LayoutOrder = 0,
			PlaceholderText = "Placeholder text",
			Disabled = self.state.Disabled,
		}),
		Checkbox = Roact.createElement(Checkbox, {
			LayoutOrder = 1,
			Value = not self.state.Disabled,
			Label = "Enable input",
			OnActivated = function()
				self:setState({ Disabled = not self.state.Disabled })
			end,
		}),
	})
end

return function(target)
	local element = Roact.createElement(Wrapper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
