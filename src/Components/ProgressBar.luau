--[=[
	@class ProgressBar

	A basic progress indicator. This should be used for longer or more detailed loading processes.
	For shorter loading processes, consider using a [LoadingDots] component.
	
	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/progressbar/dark.png) | ![Light](/StudioComponents/components/progressbar/light.png) |

	Pass a number representing the current progress into the `Value` prop. You can optionally pass a 
	number representing the maximum value into the `Max` prop, which defaults to 1 if not provided. 
	The `Value` prop should be between 0 and `Max`. For example:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.ProgressBar, {
			Value = 5, -- loaded 5 items
			Max = 10, -- out of a total of 10 items
		})
	end
	```

	By default, the progress bar will display text indicating the progress as a percentage,
	rounded to the nearest whole number. This can be customized by providing a prop to `Formatter`,
	which should be a function that takes two numbers representing the current value and the maximum value
	and returns a string to be displayed. For example:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.ProgressBar, {
			Value = 3,
			Max = 20,
			Formatter = function(current, max)
				return `Loaded {current} / {max} assets...`
			end,
		})
	end
	```

	By default, the height of a progress bar is equal to the value in [Constants.DefaultProgressBarHeight].
	This can be configured via props.
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local Constants = require("../Constants")
local useTheme = require("../Hooks/useTheme")

--[=[
	@within ProgressBar
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Value number
	@field Max number?
	@field Formatter ((value: number, max: number) -> string)?
]=]

type ProgressBarProps = CommonProps.T & {
	Value: number,
	Max: number?,
	Formatter: ((value: number, max: number) -> string)?,
}

local function defaultFormatter(value: number, max: number)
	return string.format("%i%%", 100 * value / max)
end

local function ProgressBar(props: ProgressBarProps)
	local theme = useTheme()

	local formatter: (number, number) -> string = defaultFormatter
	if props.Formatter then
		formatter = props.Formatter
	end

	local max = props.Max or 1
	local value = math.clamp(props.Value, 0, max)
	local alpha = value / max
	local text = formatter(value, max)

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.new(1, 0, 0, Constants.DefaultProgressBarHeight),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, modifier),
	}, {
		Bar = React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton, modifier),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(alpha, 1),
			ClipsDescendants = true,
			ZIndex = 1,
		}, {
			Left = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1 / alpha, 1) - UDim2.fromOffset(0, 1),
				Font = Constants.DefaultFont,
				TextSize = Constants.DefaultTextSize,
				TextColor3 = Color3.fromRGB(12, 12, 12),
				TextTransparency = if props.Disabled then 0.5 else 0,
				Text = text,
			}),
		}),
		Under = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, 1),
			Font = Constants.DefaultFont,
			TextSize = Constants.DefaultTextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			Text = text,
			ZIndex = 0,
		}),
	})
end

return ProgressBar
