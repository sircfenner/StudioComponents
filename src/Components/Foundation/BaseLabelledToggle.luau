local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../../CommonProps")
local Constants = require("../../Constants")

local getTextSize = require("../../getTextSize")
local useTheme = require("../../Hooks/useTheme")

local DEFAULT_HEIGHT = Constants.DefaultToggleHeight
local BOX_SIZE = 16
local INNER_PADDING = 6

export type BaseLabelledToggleConsumerProps = CommonProps.T & {
	ContentAlignment: Enum.HorizontalAlignment?,
	ButtonAlignment: Enum.HorizontalAlignment?,
	OnChanged: (() -> ())?,
	Label: string?,
}

export type BaseLabelledToggleProps = BaseLabelledToggleConsumerProps & {
	RenderButton: React.FC<{ Hovered: boolean }>?,
}

local function BaseLabelledToggle(props: BaseLabelledToggleProps)
	local theme = useTheme()
	local hovered, setHovered = React.useState(false)

	local mainModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif hovered then
		mainModifier = Enum.StudioStyleGuideModifier.Hover
	end

	local contentAlignment = props.ContentAlignment or Enum.HorizontalAlignment.Left
	local buttonAlignment = props.ButtonAlignment or Enum.HorizontalAlignment.Left

	local textWidth = if props.Label then getTextSize(props.Label).X else 0
	local textAlignment = Enum.TextXAlignment.Left
	local buttonOrder = 1
	local labelOrder = 2
	if buttonAlignment == Enum.HorizontalAlignment.Right then
		buttonOrder = 2
		labelOrder = 1
		textAlignment = Enum.TextXAlignment.Right
	end

	local content = nil
	if props.RenderButton then
		content = React.createElement(props.RenderButton, {
			Hovered = hovered,
		})
	end

	return React.createElement("TextButton", {
		Size = props.Size or UDim2.new(1, 0, 0, DEFAULT_HEIGHT),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
		Text = "",
		[React.Event.InputBegan] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			end
		end,
		[React.Event.InputEnded] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
		end,
		[React.Event.Activated] = function()
			if not props.Disabled and props.OnChanged then
				props.OnChanged()
			end
		end,
	}, {
		Layout = React.createElement("UIListLayout", {
			HorizontalAlignment = contentAlignment,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, INNER_PADDING),
		}),
		Button = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(BOX_SIZE, BOX_SIZE),
			LayoutOrder = buttonOrder,
		}, {
			Content = content,
		}),
		Label = props.Label and React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -BOX_SIZE - INNER_PADDING, 1, 0),
			TextXAlignment = textAlignment,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = props.Label,
			Font = Constants.DefaultFont,
			TextSize = Constants.DefaultTextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier),
			LayoutOrder = labelOrder,
		}, {
			Constraint = React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(textWidth, math.huge),
			}),
			Pad = React.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
			}),
		}),
	})
end

return BaseLabelledToggle
