local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Label = require(script.Parent.Label)

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Label0 = Roact.createElement(Label, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(120, 20),
			Text = "Label0",
		}),
		Label1 = Roact.createElement(Label, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(120, 20),
			Text = "Label1",
			StyleColor = Enum.StudioStyleGuideColor.SubText,
		}),
		Label2 = Roact.createElement(Label, {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(120, 20),
			Text = "Label2",
			Disabled = true,
		}),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
