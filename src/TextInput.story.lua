local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local TextInput = require(script.Parent.TextInput)

local Helper = Roact.Component:extend("Helper")

function Helper:init()
	self:setState({ text = "" })
end

function Helper:render()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.25, 0.7),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Input0 = Roact.createElement(TextInput, {
			LayoutOrder = 0,
			PlaceholderText = "Enabled",
			Text = self.state.text,
			OnChanged = function(newText)
				self:setState({text = newText})
			end,
			ClearTextOnFocus = false,
		}),
		TextInput1 = Roact.createElement(TextInput, {
			LayoutOrder = 1,
			Disabled = true,
			PlaceholderText = "Disabled",
			Text = "Disabled",
		}),
	})
end

return function(target)
	local element = Roact.createElement(Helper, {})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
