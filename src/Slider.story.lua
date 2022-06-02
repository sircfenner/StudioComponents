local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Slider = require(script.Parent.Slider)
local Checkbox = require(script.Parent.Checkbox)

local MIN = 0
local MAX = 10
local STEP = 1
local INIT = 3

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({ Disabled = false, Value = INIT })
end

function Wrapper.renderCustomBackground(props)
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromHSV(210 / 360, props.Value / 10, if props.Disabled then 0.25 else 0.8),
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
	})
end

function Wrapper:render()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 100, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
		Slider0 = Roact.createElement(Slider, {
			Min = MIN,
			Max = MAX,
			Step = STEP,
			Value = self.state.Value,
			Disabled = self.state.Disabled,
			OnChange = function(newValue)
				self:setState({ Value = newValue })
			end,
			LayoutOrder = 0,
		}),
		Slider1 = Roact.createElement(Slider, {
			Min = MIN,
			Max = MAX,
			Step = STEP,
			Background = self.renderCustomBackground,
			Disabled = self.state.Disabled,
			Value = self.state.Value,
			OnChange = function(newValue)
				self:setState({ Value = newValue })
			end,
			LayoutOrder = 1,
		}),
		Disabled = Roact.createElement(Checkbox, {
			Value = self.state.Disabled,
			Label = "Disabled",
			Alignment = "Left",
			OnActivated = function()
				self:setState({ Disabled = not self.state.Disabled })
			end,
			LayoutOrder = 2,
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
