local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Checkbox = require(script.Parent.Checkbox)

local onActivated = function()
end

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Checkbox0 = Roact.createElement(Checkbox, {
			LayoutOrder = 0,
			Value = false,
			Label = "Checkbox0",
			OnActivated = onActivated,
		}),
		Checkbox1 = Roact.createElement(Checkbox, {
			LayoutOrder = 1,
			Value = true,
			Label = "Checkbox1",
			OnActivated = onActivated,
		}),
		Checkbox2 = Roact.createElement(Checkbox, {
			LayoutOrder = 2,
			Value = Checkbox.Indeterminate,
			Label = "Checkbox2",
			OnActivated = onActivated,
		}),
		Checkbox3 = Roact.createElement(Checkbox, {
			LayoutOrder = 3,
			Value = true,
			Disabled = true,
			Label = "Checkbox3",
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
