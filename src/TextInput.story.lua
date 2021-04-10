local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local TextInput = require(script.Parent.TextInput)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Input0 = Roact.createElement(TextInput, {
			LayoutOrder = 0,
			PlaceholderText = "TextInput0",
		}),
		TextInput1 = Roact.createElement(TextInput, {
			LayoutOrder = 1,
			Disabled = true,
			PlaceholderText = "TextInput1",
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
