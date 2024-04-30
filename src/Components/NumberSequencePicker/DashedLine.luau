local React = require("@pkg/@jsdotlua/react")

local useTheme = require("../../Hooks/useTheme")

local TEX_HORIZONTAL = "rbxassetid://15431624045"
local TEX_VERTICAL = "rbxassetid://15431692101"

local function DashedLine(props: {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2,
	Direction: Enum.FillDirection,
	Transparency: number?,
	Disabled: boolean?,
})
	local theme = useTheme()
	local horizontal = props.Direction == Enum.FillDirection.Horizontal

	local transparency = props.Transparency or 0
	if props.Disabled then
		transparency = 1 - 0.5 * (1 - transparency)
	end

	return React.createElement("ImageLabel", {
		Image = if horizontal then TEX_HORIZONTAL else TEX_VERTICAL,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = if horizontal then UDim2.fromOffset(4, 1) else UDim2.fromOffset(1, 4),
		BackgroundTransparency = 1,
		ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
		ImageTransparency = transparency,
		ZIndex = 0,
	})
end

return DashedLine
