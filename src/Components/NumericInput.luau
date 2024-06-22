--[=[
	@class NumericInput
	
	An input field matching the appearance of a [TextInput] but which filters inputted text to only
	allow numeric values, optionally with arrow and slider controls.
	
	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/numericinput/dark.png) | ![Light](/StudioComponents/components/numericinput/light.png) |


	This is a controlled component with similar behavior to [TextInput]. The current numeric value
	to display should be passed to the `Value` prop, and a callback should be passed to the
	`OnValidChanged` prop which is run when the user types a (valid) numeric input.

	Optionally, a minimum value can be passed to the `Min` prop, as well as a maximum value to the
	`Max` prop. A step (increment) value may also be passed to the the `Step` prop, which defaults 
	to 1 (allowing only whole number values). Passing a non-integer step value will also allow a 
	decimal point to be typed in the input box. 

	Use the `Arrows` and `Slider` props to specify whether up/down arrows and a slider should be
	included. If arrows or a slider are displayed, they will increment the value by the amount of the step. 
	Completing a slide with a slider will call the `OnSubmitted` prop (if provided) with the latest value.
	
	Only decimal inputs are allowed (so, for example, hex characters a-f will not be permitted).
]=]

local RunService = game:GetService("RunService")

local React = require("@pkg/@jsdotlua/react")

local BaseTextInput = require("./Foundation/BaseTextInput")
local Slider = require("./Slider")

local Constants = require("../Constants")
local useFreshCallback = require("../Hooks/useFreshCallback")
local useTheme = require("../Hooks/useTheme")

--[=[
	@within NumericInput
	@interface Props
	@tag Component Props

	@field ... CommonProps

	@field Value number
	@field OnValidChanged ((n: number) -> ())?
	@field Min number?
	@field Max number?
	@field Step number?
	@field OnSubmitted ((n: number) -> ())?
	@field FormatValue ((n: number) -> string)?
	@field Arrows boolean?
	@field Slider boolean?
	@field PlaceholderText string?
	@field ClearTextOnFocus boolean?
	@field OnFocused (() -> ())?
	@field OnFocusLost ((text: string, enterPressed: boolean, input: InputObject) -> ())?
]=]

type NumericInputProps = BaseTextInput.BaseTextInputConsumerProps & {
	OnValidChanged: ((n: number) -> ())?,
	Value: number,
	Min: number?,
	Max: number?,
	Step: number?,
	OnSubmitted: ((n: number) -> ())?,
	FormatValue: ((n: number) -> string)?,
	Arrows: boolean?,
	Slider: boolean?,
}

local MAX = 2 ^ 53
local ARROW_WIDTH = 19
local SLIDER_SPLIT = 0.45

local function roundToStep(n: number, step: number): number
	if step == 0 then
		return n
	end
	return math.round(n / step) * step
end

local function tonumberPositiveZero(s: string): number?
	local n = tonumber(s)
	if n == -0 then
		return 0
	end
	return n
end

local function applyFormat(n: number, formatter: ((n: number) -> string)?)
	if n == -0 then
		n = 0
	end
	if formatter ~= nil then
		return formatter(n)
	end
	return tostring(n)
end

local function NumericInputArrow(props: {
	HeightBinding: React.Binding<number>,
	Side: number,
	Callback: (side: number) -> (),
	Disabled: boolean?,
})
	local theme = useTheme()
	local connection = React.useRef(nil) :: { current: RBXScriptConnection? }

	local hovered, setHovered = React.useState(false)
	local pressed, setPressed = React.useState(false)
	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local maybeActivate = useFreshCallback(function()
		if hovered then
			props.Callback(props.Side)
		end
	end, { hovered, props.Callback, props.Side } :: { unknown })

	local function startHolding()
		if connection.current then
			connection.current:Disconnect()
		end
		local nextScroll = os.clock() + 0.35
		connection.current = RunService.PostSimulation:Connect(function()
			if os.clock() >= nextScroll then
				maybeActivate()
				nextScroll += 0.05
			end
		end)
		props.Callback(props.Side)
	end

	local function stopHolding()
		if connection.current then
			connection.current:Disconnect()
			connection.current = nil
		end
	end
	React.useEffect(stopHolding, {})

	React.useEffect(function()
		if props.Disabled and pressed then
			stopHolding()
			setPressed(false)
		end
		if props.Disabled then
			setHovered(false)
		end
	end, { props.Disabled, pressed })

	return React.createElement("TextButton", {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, modifier),
		Size = props.HeightBinding:map(function(height: number)
			if props.Side == 0 then
				return UDim2.new(1, 0, 0, math.floor(height / 2))
			else
				return UDim2.new(1, 0, 0, math.ceil(height / 2) - 1)
			end
		end),
		Position = props.HeightBinding:map(function(height: number)
			if props.Side == 0 then
				return UDim2.fromOffset(0, 0)
			else
				return UDim2.fromOffset(0, math.floor(height / 2) + 1)
			end
		end),
		[React.Event.InputBegan] = function(_, input)
			if props.Disabled then
				return
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(true)
				startHolding()
			end
		end,
		[React.Event.InputEnded] = function(_, input)
			if props.Disabled then
				return
			elseif input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(false)
				stopHolding()
			end
		end,
	}, {
		Image = React.createElement("ImageLabel", {
			Image = "rbxassetid://14699332993",
			Size = UDim2.fromOffset(7, 4),
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText, modifier),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageRectSize = Vector2.new(7, 4),
			ImageRectOffset = Vector2.new(0, if props.Side == 0 then 0 else 4),
			ImageTransparency = if props.Disabled then 0.2 else 0,
		}),
	})
end

local function NumericInput(props: NumericInputProps)
	local theme = useTheme()

	local min = math.max(props.Min or -MAX, -MAX)
	local max = math.min(props.Max or MAX, MAX)
	local step = props.Step or 1
	assert(max >= min, `max ({max}) was less than min ({min})`)
	assert(step >= 0, `step ({step}) was less than 0`)

	local pattern = if step % 1 == 0 and step ~= 0 then "[^%-%d]" else "[^%-%.%d]"
	local lastCleanText, setLastCleanText = React.useState(applyFormat(props.Value, props.FormatValue))

	local onValidChanged: (number) -> () = props.OnValidChanged or function() end

	React.useEffect(function()
		setLastCleanText(function(freshLastCleanText)
			if tonumberPositiveZero(freshLastCleanText) ~= props.Value then
				return applyFormat(props.Value, props.FormatValue)
			end
			return freshLastCleanText
		end)
	end, { props.Value, props.FormatValue } :: { unknown })

	local heightBinding, setHeightBinding = React.useBinding(0)
	local function buttonCallback(side: number)
		local usingStep = (if step == 0 then 1 else step) * (if side == 0 then 1 else -1)
		local newValue = math.clamp(props.Value + usingStep, min, max)
		if newValue ~= props.Value then
			onValidChanged(newValue)
		end
	end

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.new(1, 0, 0, Constants.DefaultInputHeight),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}, {
		InputHolder = React.createElement("Frame", {
			Size = UDim2.fromScale(if props.Slider then SLIDER_SPLIT else 1, 1),
			BackgroundTransparency = 1,
		}, {
			Input = React.createElement(BaseTextInput, {
				Disabled = props.Disabled,
				Size = UDim2.fromScale(1, 1),
				ClearTextOnFocus = props.ClearTextOnFocus,
				PlaceholderText = props.PlaceholderText,
				Text = lastCleanText,
				RightPaddingExtra = if props.Arrows then ARROW_WIDTH + 1 else 0,
				OnChanged = function(newText: string)
					local cleanText = string.gsub(newText, pattern, "")
					local number = tonumberPositiveZero(cleanText)
					if number ~= nil then
						if number >= min and number <= max and roundToStep(number, step) == number then
							onValidChanged(number)
						end
					end
					setLastCleanText(cleanText)
				end,
				OnFocusLost = function(_, enterPressed: boolean, inputObject: InputObject)
					local number = tonumberPositiveZero(lastCleanText)
					local outValue = props.Value
					if number ~= nil then
						outValue = math.clamp(roundToStep(number, step), min, max)
					end
					onValidChanged(outValue)
					if props.OnSubmitted then
						props.OnSubmitted(outValue)
					end
					setLastCleanText(applyFormat(outValue, props.FormatValue))
					if props.OnFocusLost then
						props.OnFocusLost(lastCleanText, enterPressed, inputObject)
					end
				end,
				OnFocused = props.OnFocused,
			}),
			Arrows = props.Arrows and React.createElement("Frame", {
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, modifier),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -1, 0, 1),
				Size = UDim2.new(0, ARROW_WIDTH, 1, -2),
				[React.Change.AbsoluteSize] = function(rbx)
					setHeightBinding(rbx.AbsoluteSize.Y)
				end,
			}, {
				Up = React.createElement(NumericInputArrow, {
					Disabled = props.Disabled or props.Value >= max,
					Callback = buttonCallback,
					HeightBinding = heightBinding,
					Side = 0,
				}),
				Down = React.createElement(NumericInputArrow, {
					Disabled = props.Disabled or props.Value <= min,
					Callback = buttonCallback,
					HeightBinding = heightBinding,
					Side = 1,
				}),
			}),
		}),
		Slider = props.Slider and React.createElement(Slider, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(1 - SLIDER_SPLIT, -5, 1, 0),
			Value = props.Value,
			Min = min,
			Max = max,
			Step = step,
			OnChanged = props.OnValidChanged,
			OnCompleted = props.OnSubmitted,
			Disabled = props.Disabled,
		}),
	})
end

return NumericInput
