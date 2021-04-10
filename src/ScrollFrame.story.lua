local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local ScrollFrame = require(script.Parent.ScrollFrame)

return function(target)
	local children = {}
	for i = 1, 17 do
		local shade = 0.18 + (i % 2) * 0.02
		children[i] = Roact.createElement("TextLabel", {
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 32),
			Text = string.format("Label%i", i),
			TextColor3 = Color3.fromRGB(220, 220, 220),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHSV(0, 0, shade),
		})
	end
	local element = Roact.createElement(ScrollFrame, {}, children)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
