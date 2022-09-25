local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)

local function Background(props, hooks)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = props.ZIndex or 1,
		BorderSizePixel = 0,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
	}, props[Roact.Children])
end

return Hooks.new(Roact)(Background)
