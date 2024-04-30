local React = require("@pkg/@jsdotlua/react")

local TEX = "rbxassetid://15434098501"

local function FreeLine(props: {
	Pos0: Vector2,
	Pos1: Vector2,
	Color: Color3,
	Transparency: number?,
	ZIndex: number?,
	Disabled: boolean?,
})
	local mid = (props.Pos0 + props.Pos1) / 2
	local vector = props.Pos1 - props.Pos0
	local rotation = math.atan2(-vector.X, vector.Y) + math.pi / 2
	local length = vector.Magnitude

	local transparency = props.Transparency or 0
	if props.Disabled then
		transparency = 1 - 0.5 * (1 - transparency)
	end

	return React.createElement("ImageLabel", {
		AnchorPoint = Vector2.one / 2,
		Position = UDim2.fromOffset(math.round(mid.X), math.round(mid.Y)),
		Size = UDim2.fromOffset(vector.Magnitude, 3),
		Rotation = math.deg(rotation),
		BackgroundTransparency = 1,
		ImageColor3 = props.Color,
		ImageTransparency = transparency,
		Image = TEX,
		ScaleType = if length < 128 then Enum.ScaleType.Crop else Enum.ScaleType.Stretch,
		ZIndex = props.ZIndex,
	})
end

return FreeLine
