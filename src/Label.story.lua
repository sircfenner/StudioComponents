local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Label = require(script.Parent.Label)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Label0 = Roact.createElement(Label, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(120, 20),
			Text = "Default",
		}),
		Label1 = Roact.createElement(Label, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(120, 20),
			Text = "SubText",
			StyleColor = Enum.StudioStyleGuideColor.SubText,
		}),
		Label2 = Roact.createElement(Label, {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(120, 20),
			Text = "Disabled",
			Disabled = true,
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
