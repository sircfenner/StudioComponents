local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local ScrollFrame = require(script.Parent.ScrollFrame)

return function(target)
	local children = {}
	for i = 1, 15 do
		local shade = 0.18 + (i % 2) * 0.02
		children[i] = Roact.createElement("TextLabel", {
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 24),
			Text = string.format("Entry%i", i),
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHSV(0, 0, shade),
		})
	end
	local element = Roact.createElement(ScrollFrame, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.7),
	}, children)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
