local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local ImageButton = require(script.Parent.ImageButton)

return function(target)
	local element = Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		BackgroundTransparency = 1,
	}, {
		ImageButton = Roact.createElement(ImageButton, {
			Image = "http://www.roblox.com/asset/?id=14808588",
			Size = UDim2.fromOffset(50, 50),
			Position = UDim2.new(0.5, -25, 0.5, -25),
			Padding = 5,
		})
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
