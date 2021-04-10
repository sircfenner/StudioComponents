local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local ScrollFrame = require(script.Parent.ScrollFrame)

local function Children()
	local children = {}
	for i = 1, 25 do
		local shade = 0.18 + (i % 2) * 0.02
		children[i] = Roact.createElement("TextLabel", {
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 24),
			Text = string.format("Entry%i", i),
			Font = Enum.Font.SourceSans,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHSV(0, 0, shade),
		})
	end
	return Roact.createFragment(children)
end

return function(target)
	local element = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 20),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		ScrollFrame0 = Roact.createElement(ScrollFrame, {
			Size = UDim2.fromOffset(160, 240),
			LayoutOrder = 0,
		}, { Roact.createElement(Children) }),
		ScrollFrame1 = Roact.createElement(ScrollFrame, {
			Size = UDim2.fromOffset(160, 240),
			LayoutOrder = 1,
			Disabled = true,
		}, { Roact.createElement(Children) }),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
