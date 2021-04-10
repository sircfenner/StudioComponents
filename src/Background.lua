local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.withTheme)

local function Background(props)
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.fromScale(0, 0),
			AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
			LayoutOrder = props.LayoutOrder or 0,
			ZIndex = props.ZIndex or 0,
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		})
	end)
end

return Background
