local React = require("@pkg/@jsdotlua/react")

export type PublicIconProps = {
	Image: string,
	Size: Vector2,
	Transparency: number?,
	Color: Color3?,
	ResampleMode: Enum.ResamplerMode?,
	RectOffset: Vector2?,
	RectSize: Vector2?,
}

export type BaseIconProps = {
	Disabled: boolean?,
	LayoutOrder: number?,
	PublicIconProps: PublicIconProps,
}

local function BaseIcon(props: BaseIconProps)
	return React.createElement("ImageLabel", {
		Image = props.PublicIconProps.Image,
		Size = UDim2.fromOffset(props.PublicIconProps.Size.X, props.PublicIconProps.Size.Y),
		LayoutOrder = props.LayoutOrder or 1,
		BackgroundTransparency = 1,
		ImageColor3 = props.PublicIconProps.Color,
		ImageTransparency = 1
			- (1 - (props.PublicIconProps.Transparency or 0)) * (1 - if props.Disabled then 0.2 else 0),
		ResampleMode = props.PublicIconProps.ResampleMode,
		ImageRectOffset = props.PublicIconProps.RectOffset,
		ImageRectSize = props.PublicIconProps.RectSize,
	})
end

return BaseIcon
