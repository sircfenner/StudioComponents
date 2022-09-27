local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Tooltip = require(script.Parent.Tooltip)

local Button = require(script.Parent.Button)
local Checkbox = require(script.Parent.Checkbox)
local Dropdown = require(script.Parent.Dropdown)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Button = Roact.createElement(Button, {
			LayoutOrder = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(200, 40),
			Text = "Example button",
		}, {
			Tooltip = Roact.createElement(Tooltip, {
				Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
			}),
		}),

		Checkbox = Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(120, 16),
			BackgroundTransparency = 1,
		}, {
			Actual = Roact.createElement(Checkbox, {
				Value = true,
				Label = "Example checkbox",
				OnActivated = function() end,
			}, {
				Tooltip = Roact.createElement(Tooltip, {
					Text = "This is an explanation of the checkbox",
				}),
			}),
		}),

		Dropdown = Roact.createElement(Dropdown, {
			LayoutOrder = 2,
			Width = UDim.new(0, 120),
			Items = { "OptionA", "OptionB", "OptionC", "OptionD", "OptionE", "OptionF" },
			MaxVisibleRows = 4,
			SelectedItem = "OptionA",
			OnItemSelected = function() end,
		}, {
			Tooltip = Roact.createElement(Tooltip, {
				Text = "This is an explanation of the dropdown",
			}),
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
