local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local TextInput = require(script.Parent.TextInput)

local Helper = Hooks.new(Roact)(function(props, hooks)
	local text, setText = hooks.useState(props.InitText)
	return Roact.createElement(TextInput, {
		LayoutOrder = props.LayoutOrder,
		PlaceholderText = props.PlaceholderText,
		Disabled = props.Disabled,
		Text = text,
		OnChanged = setText,
	})
end)

return function(target)
	local element = Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Input0 = Roact.createElement(Helper, {
			LayoutOrder = 0,
			PlaceholderText = "Enabled",
		}),
		Input1 = Roact.createElement(Helper, {
			LayoutOrder = 1,
			Disabled = true,
			PlaceholderText = "Disabled",
			InitText = "Disabled",
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
