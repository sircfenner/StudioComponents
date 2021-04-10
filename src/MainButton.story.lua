local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local MainButton = require(script.Parent.MainButton)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Button0 = Roact.createElement(MainButton, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(120, 35),
			Text = "Button0",
			OnActivated = function()
			end,
		}),
		Button1 = Roact.createElement(MainButton, {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(120, 35),
			Text = "Button1",
			Disabled = true,
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
