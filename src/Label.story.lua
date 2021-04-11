local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Label = require(script.Parent.Label)

local textColorItems = {}
for _, colorItem in ipairs(Enum.StudioStyleGuideColor:GetEnumItems()) do
	local name = colorItem.Name
	if string.sub(name, -4) == "Text" then
		table.insert(textColorItems, colorItem)
	end
end

return function(target)
	local textElements = {}
	for i, colorItem in ipairs(textColorItems) do
		local name = colorItem.Name
		if colorItem == Enum.StudioStyleGuideColor.MainText then
			name ..= " (Default)"
		end
		textElements[i] = Roact.createElement(Label, {
			LayoutOrder = i,
			Size = UDim2.fromOffset(120, 16),
			Text = name,
			TextColorStyle = colorItem,
		})
	end
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Roact.createElement(Label, {
			LayoutOrder = 0,
			Size = UDim2.fromOffset(120, 32),
			Text = "MainText (Disabled)",
			Disabled = true,
		}),
		Roact.createFragment(textElements),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
