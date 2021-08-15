local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local MainButton = require(script.Parent.MainButton)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Button0 = Roact.createElement(MainButton, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(100, 32),
			Text = "Enabled",
			OnActivated = function() end,
		}),
		Button1 = Roact.createElement(MainButton, {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(100, 32),
			Text = "Selected",
			Selected = true,
			OnActivated = function() end,
		}),
		Button2 = Roact.createElement(MainButton, {
			LayoutOrder = 2,
			Size = UDim2.fromOffset(100, 32),
			Text = "Disabled",
			Disabled = true,
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
