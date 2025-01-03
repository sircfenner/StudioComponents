local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../../CommonProps")
local Constants = require("../../Constants")

local getTextSize = require("../../getTextSize")
local useTheme = require("../../Hooks/useTheme")

local BaseIcon = require("./BaseIcon")

local PADDING_X = 8
local PADDING_Y = 4
local DEFAULT_HEIGHT = Constants.DefaultButtonHeight

export type BaseButtonIconProps = {
	Image: string,
	Size: Vector2,
	Transparency: number?,
	Color: Color3?,
	ResampleMode: Enum.ResamplerMode?,
	RectOffset: Vector2?,
	RectSize: Vector2?,
	UseThemeColor: boolean?,
	Alignment: Enum.HorizontalAlignment?,
}

export type BaseButtonConsumerProps = CommonProps.T & {
	AutomaticSize: Enum.AutomaticSize?,
	OnActivated: (() -> ())?,
	Selected: boolean?,
	Text: string?,
	TextTransparency: number?,
	Icon: BaseButtonIconProps?,
}

export type BaseButtonProps = BaseButtonConsumerProps & {
	BackgroundColorStyle: Enum.StudioStyleGuideColor?,
	BorderColorStyle: Enum.StudioStyleGuideColor?,
	TextColorStyle: Enum.StudioStyleGuideColor?,
}

local function BaseButton(props: BaseButtonProps)
	local theme = useTheme()

	local textSize = if props.Text then getTextSize(props.Text) else Vector2.zero
	local iconSize = if props.Icon then props.Icon.Size else Vector2.zero

	local contentWidth = textSize.X + iconSize.X
	if props.Text and props.Icon then
		contentWidth += PADDING_X
	end

	local contentHeight = textSize.Y
	if props.Icon then
		contentHeight = math.max(contentHeight, iconSize.Y)
	end

	local hovered, setHovered = React.useState(false)
	local pressed, setPressed = React.useState(false)
	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Selected
	elseif pressed and hovered then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local backColorStyle = props.BackgroundColorStyle or Enum.StudioStyleGuideColor.Button
	local borderColorStyle = props.BorderColorStyle or Enum.StudioStyleGuideColor.ButtonBorder
	local textColorStyle = props.TextColorStyle or Enum.StudioStyleGuideColor.ButtonText

	local backColor = theme:GetColor(backColorStyle, modifier)
	local borderColor3 = theme:GetColor(borderColorStyle, modifier)
	local textColor = theme:GetColor(textColorStyle, modifier)

	local size = props.Size or UDim2.new(1, 0, 0, DEFAULT_HEIGHT)
	local autoSize = props.AutomaticSize
	if autoSize == Enum.AutomaticSize.X or autoSize == Enum.AutomaticSize.XY then
		size = UDim2.new(UDim.new(0, contentWidth + PADDING_X * 2), size.Height)
	end
	if autoSize == Enum.AutomaticSize.Y or autoSize == Enum.AutomaticSize.XY then
		size = UDim2.new(size.Width, UDim.new(0, math.max(DEFAULT_HEIGHT, contentHeight + PADDING_Y * 2)))
	end

	local iconNode: React.Node?
	if props.Icon then
		local iconProps = (table.clone(props.Icon) :: any) :: BaseIcon.BaseIconProps
		iconProps.Disabled = props.Disabled
		iconProps.Color = iconProps.Color or if props.Icon.UseThemeColor then textColor else nil
		iconProps.LayoutOrder = if props.Icon.Alignment == Enum.HorizontalAlignment.Right then 3 else 1
		iconProps.Size = UDim2.fromOffset(props.Icon.Size.X, props.Icon.Size.Y)

		iconNode = React.createElement(BaseIcon, iconProps)
	end

	return React.createElement("TextButton", {
		AutoButtonColor = false,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = size,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Text = "",
		BackgroundColor3 = backColor,
		BorderColor3 = borderColor3,
		[React.Event.InputBegan] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(true)
			end
		end,
		[React.Event.InputEnded] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(false)
			end
		end,
		[React.Event.Activated] = function()
			if not props.Disabled and props.OnActivated then
				props.OnActivated()
			end
		end,
	}, {
		Layout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, PADDING_X),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Icon = iconNode,
		Label = props.Text and React.createElement("TextLabel", {
			TextColor3 = textColor,
			Font = Constants.DefaultFont,
			TextSize = Constants.DefaultTextSize,
			Text = props.Text,
			TextTransparency = props.TextTransparency or 0,
			Size = UDim2.new(0, textSize.X, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}),
	})
end

return BaseButton
