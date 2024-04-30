--[=[
	@class Label

	A basic text label with default styling to match built-in labels as closely as possible.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/label/dark.png) | ![Light](/StudioComponents/components/label/light.png) |

	By default, text color matches the current theme's MainText color, which is the color
	used in the Explorer and Properties widgets as well as most other places. It can be overriden
	in two ways:
	1. Passing a [StudioStyleGuideColor](https://create.roblox.com/docs/reference/engine/enums/StudioStyleGuideColor)
	to the `TextColorStyle` prop. This is the preferred way to recolor text
	because it will use the correct version of the color for the user's current selected theme.
	2. Passing a [Color3] value to the `TextColor3` prop. This is useful when a color is not represented
	by any StudioStyleGuideColor or should remain constant regardless of theme.

	Example of creating an error message label:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.Label, {
			Text = "Please enter at least 5 characters!",
			TextColorStyle = Enum.StudioStyleGuideColor.ErrorText,
		})
	end
	```

	Plugins like [Theme Color Shower](https://create.roblox.com/store/asset/3115567199/Theme-Color-Shower)
	are useful for finding a StudioStyleGuideColor to use.

	This component will parent any children passed to it to the underlying TextLabel instance.
	This is useful for things like adding extra padding around the text using a nested UIPadding,
	or adding a UIStroke / UIGradient.

	Labels use [Constants.DefaultFont] for Font and [Constants.DefaultTextSize] for TextSize. This
	cannot currently be overriden via props.
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local Constants = require("../Constants")
local useTheme = require("../Hooks/useTheme")

--[=[
	@within Label
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Text string
	@field TextWrapped boolean?
	@field TextXAlignment Enum.TextXAlignment?
	@field TextYAlignment Enum.TextYAlignment?
	@field TextTruncate Enum.TextTruncate?
	@field TextTransparency number?
	@field TextColor3 Color3?
	@field RichText boolean?
	@field MaxVisibleGraphemes number?
	@field TextColorStyle Enum.StudioStyleGuideColor?
	@field children React.ReactNode
]=]

type LabelProps = CommonProps.T & {
	Text: string,
	TextWrapped: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
	TextTruncate: Enum.TextTruncate?,
	TextTransparency: number?,
	TextColor3: Color3?,
	RichText: boolean?,
	MaxVisibleGraphemes: number?,
	TextColorStyle: Enum.StudioStyleGuideColor?,
	children: React.ReactNode,
}

local function Label(props: LabelProps)
	local theme = useTheme()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	local style = props.TextColorStyle or Enum.StudioStyleGuideColor.MainText
	local color = theme:GetColor(style, modifier)
	if props.TextColor3 ~= nil then
		color = props.TextColor3
	end

	return React.createElement("TextLabel", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Text = props.Text,
		BackgroundTransparency = 1,
		Font = Constants.DefaultFont,
		TextSize = Constants.DefaultTextSize,
		TextColor3 = color,
		TextTransparency = props.TextTransparency,
		TextXAlignment = props.TextXAlignment,
		TextYAlignment = props.TextYAlignment,
		TextTruncate = props.TextTruncate,
		TextWrapped = props.TextWrapped,
		RichText = props.RichText,
		MaxVisibleGraphemes = props.MaxVisibleGraphemes,
	}, props.children)
end

return Label
