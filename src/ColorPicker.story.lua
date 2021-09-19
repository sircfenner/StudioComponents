local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local ColorPicker = require(script.Parent.ColorPicker)
local Label = require(script.Parent.Label)

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({ Color = Color3.fromRGB(128, 196, 92) })
end

function Wrapper:render()
	local color = self.state.Color
	return Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 25),
		}),
		Picker = Roact.createElement(ColorPicker, {
			Size = UDim2.fromOffset(250, 200),
			Color = color,
			OnChange = function(newColor)
				self:setState({ Color = newColor })
			end,
		}),
		Swatch = Roact.createElement("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(250, 30),
			BackgroundColor3 = color,
			Font = Enum.Font.SourceSansBold,
			TextSize = 24,
			Text = string.format("%i, %i, %i", color.r * 255, color.g * 255, color.b * 255),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0.5,
		}, {
			Disclaimer = Roact.createElement(Label, {
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextColorStyle = Enum.StudioStyleGuideColor.SubText,
				Text = "(not part of ColorPicker component)",
			}),
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
