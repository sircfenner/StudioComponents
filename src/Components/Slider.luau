--[=[
	@class Slider

	A component for selecting a numeric value from a range of values with an optional increment.
	These are seen in some number-valued properties in the built-in Properties widget, as well as in
	various built-in plugins such as the Terrain Editor.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/slider/dark.png) | ![Light](/StudioComponents/components/slider/light.png) |

	As with other components in this library, this is a controlled component. You should pass a
	value to the `Value` prop representing the current value, as well as a callback to the `OnChanged`
	prop which will be run when the user changes the value via dragging or clicking on the slider.

	In addition to these, you must also provide a `Min` and a `Max` prop, which together define the
	range of the slider. Optionally, a `Step` prop can be provided, which defines the increment of
	the slider. This defaults to 0, which allows any value in the range. For a complete example:
	
	```lua
	local function MyComponent()
		local value, setValue = React.useState(1)
		return React.createElement(StudioComponents.Slider, {
			Value = value,
			OnChanged = setValue,
			Min = 0,
			Max = 10,
			Step = 1,
		})
	end
	```

	Optionally, an `OnCompleted` callback prop can be provided. This will be called with the latest
	value of the Slider when sliding is finished. It is also called if, while sliding is in progress,
	the component becomes Disabled via props or is unmounted.

	Two further props can optionally be provided:
	1. `Border` determines whether a border is drawn around the component.
	This is useful for giving visual feedback when the slider is hovered or selected. 
	2. `Background` determines whether the component has a visible background.
	If this is value is missing or set to `false`, any border will also be hidden.

	Both of these props default to `true`.

	By default, the height of sliders is equal to the value found in [Constants.DefaultSliderHeight].
	While this can be overriden by props, in order to keep inputs accessible it is not recommended 
	to make the component any smaller than this.
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local Constants = require("../Constants")

local useFreshCallback = require("../Hooks/useFreshCallback")
local useMouseDrag = require("../Hooks/useMouseDrag")
local useTheme = require("../Hooks/useTheme")

--[=[
	@within Slider
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Value number
	@field OnChanged ((newValue: number) -> ())?
	@field OnCompleted ((newValue: number) -> ())?
	@field Min number
	@field Max number
	@field Step number?
	@field Border boolean?
	@field Background boolean?
]=]

type SliderProps = CommonProps.T & {
	Value: number,
	OnChanged: ((newValue: number) -> ())?,
	OnCompleted: ((newValue: number) -> ())?,
	Min: number,
	Max: number,
	Step: number?,
	Border: boolean?,
	Background: boolean?,
}

local PADDING_BAR_SIDE = 3
local PADDING_REGION_TOP = 1
local PADDING_REGION_SIDE = 6

local INPUT_MOVE = Enum.UserInputType.MouseMovement

local function Slider(props: SliderProps)
	local theme = useTheme()

	local onChanged: (number) -> () = props.OnChanged or function() end

	local dragCallback = function(rbx: GuiObject, input: InputObject)
		local regionPos = rbx.AbsolutePosition.X + PADDING_REGION_SIDE
		local regionSize = rbx.AbsoluteSize.X - PADDING_REGION_SIDE * 2
		local inputPos = input.Position.X

		local alpha = (inputPos - regionPos) / regionSize
		local step = props.Step or 0

		local value = props.Min * (1 - alpha) + props.Max * alpha
		if step > 0 then
			value = math.round(value / step) * step
		end
		value = math.clamp(value, props.Min, props.Max)
		if value ~= props.Value then
			onChanged(value)
		end
	end

	local dragEndedCallback = useFreshCallback(function()
		if props.OnCompleted then
			props.OnCompleted(props.Value)
		end
	end, { props.Value, props.OnCompleted } :: { unknown })

	local dragDeps = { props.Value, props.Min, props.Max, props.Step, props.OnCompleted, onChanged } :: { unknown }
	local drag = useMouseDrag(dragCallback, dragDeps, nil, dragEndedCallback)

	local hovered, setHovered = React.useState(false)
	local mainModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
	end

	local handleModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		handleModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif hovered or drag.isActive() then
		handleModifier = Enum.StudioStyleGuideModifier.Hover
	end

	local handleFill = theme:GetColor(Enum.StudioStyleGuideColor.Button, handleModifier)
	local handleBorder = theme:GetColor(Enum.StudioStyleGuideColor.Border, handleModifier)

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
		end
	end, { props.Disabled, drag.isActive() })

	local function inputBegan(rbx: Frame, input: InputObject)
		if input.UserInputType == INPUT_MOVE then
			setHovered(true)
		end
		if not props.Disabled then
			drag.onInputBegan(rbx, input)
		end
	end

	local function inputChanged(rbx: Frame, input: InputObject)
		if not props.Disabled then
			drag.onInputChanged(rbx, input)
		end
	end

	local function inputEnded(rbx: Frame, input: InputObject)
		if input.UserInputType == INPUT_MOVE then
			setHovered(false)
		end
		if not props.Disabled then
			drag.onInputEnded(rbx, input)
		end
	end

	-- if we use a Frame here, the 2d studio selection rectangle will appear when dragging
	-- we could prevent that using Active = true, but that displays the Click cursor
	-- ... the best workaround is a TextButton with Active = false
	return React.createElement("TextButton", {
		Text = "",
		Active = false,
		AutoButtonColor = false,
		Size = props.Size or UDim2.new(1, 0, 0, Constants.DefaultSliderHeight),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, handleModifier),
		BorderMode = Enum.BorderMode.Inset,
		BorderSizePixel = if props.Border == false then 0 else 1,
		BackgroundTransparency = if props.Background == false then 1 else 0,
		[React.Event.InputBegan] = inputBegan,
		[React.Event.InputChanged] = inputChanged,
		[React.Event.InputEnded] = inputEnded,
	}, {
		Bar = React.createElement("Frame", {
			ZIndex = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, PADDING_BAR_SIDE, 0.5, 0),
			Size = UDim2.new(1, -PADDING_BAR_SIDE * 2, 0, 2),
			BorderSizePixel = 0,
			BackgroundTransparency = props.Disabled and 0.4 or 0,
			BackgroundColor3 = theme:GetColor(
				-- surprising values, but provides correct colors
				Enum.StudioStyleGuideColor.TitlebarText,
				Enum.StudioStyleGuideModifier.Disabled
			),
		}),
		HandleRegion = React.createElement("Frame", {
			ZIndex = 2,
			Position = UDim2.fromOffset(PADDING_REGION_SIDE, PADDING_REGION_TOP),
			Size = UDim2.new(1, -PADDING_REGION_SIDE * 2, 1, -PADDING_REGION_TOP * 2),
			BackgroundTransparency = 1,
		}, {
			Handle = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale((props.Value - props.Min) / (props.Max - props.Min), 0),
				Size = UDim2.new(0, 10, 1, 0),
				BorderMode = Enum.BorderMode.Inset,
				BorderSizePixel = 1,
				BorderColor3 = handleBorder:Lerp(handleFill, props.Disabled and 0.5 or 0),
				BackgroundColor3 = handleFill,
			}),
		}),
	})
end

return Slider
