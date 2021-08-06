local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Slider = require(script.Parent.Slider)

local MIN = 0
local MAX = 10
local STEP = 1
local INIT = 3

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({ Value = INIT })
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
			OnChange = function(newValue)
				self:setState({ Value = newValue })
			end,
			Disabled = false,
			LayoutOrder = 0,
		}),
		Slider1 = Roact.createElement(Slider, {
			Min = MIN,
			Max = MAX,
			Step = STEP,
			Value = INIT,
			OnChange = function() end,
			Disabled = true,
			LayoutOrder = 1,
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
