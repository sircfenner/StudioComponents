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
			Value = true,
			Label = "Enabled, true",
			OnActivated = onActivated,
		}),
		Checkbox1 = Roact.createElement(Checkbox, {
			LayoutOrder = 1,
			Value = false,
			Label = "Enabled, false",
			OnActivated = onActivated,
		}),
		Checkbox2 = Roact.createElement(Checkbox, {
			LayoutOrder = 2,
			Value = Checkbox.Indeterminate,
			Label = "Enabled, indeterminate",
			OnActivated = onActivated,
		}),
		Checkbox3 = Roact.createElement(Checkbox, {
			LayoutOrder = 3,
			Value = true,
			Disabled = true,
			Label = "Disabled, true",
		}),
		Checkbox4 = Roact.createElement(Checkbox, {
			LayoutOrder = 4,
			Value = false,
			Disabled = true,
			Label = "Disabled, false",
		}),
		Checkbox5 = Roact.createElement(Checkbox, {
			LayoutOrder = 5,
			Value = Checkbox.Indeterminate,
			Disabled = true,
			Label = "Disabled, indeterminate",
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
