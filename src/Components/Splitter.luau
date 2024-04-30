--[=[
	@class Splitter

	A container frame similar to a [Background] but split into two panels, with a draggable control 
	for	resizing the panels within the container. Resizing one section to be larger will reduce the
	size of the other section, and vice versa. This is useful for letting users resize content.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/splitter/dark.png) | ![Light](/StudioComponents/components/splitter/light.png) |

	This is a controlled component. The current split location should be passed as a number between
	0 and 1 to the `Alpha` prop, and a callback should be passed to the `OnChanged` prop, which
	is run with the new alpha value when the user uses the splitter. 

	You can also optionally provide `MinAlpha` and `MaxAlpha` props (numbers between 0 and 1) which
	limit the resizing. These values default to 0.1 and 0.9.

	To render children in each side, use the `children` parameters in createElement and provide the 
	keys `Side0` and `Side1`. For a complete example:

	```lua
	local function MyComponent()
		local division, setDivision = React.useState(0.5)
		return React.createElement(StudioComponents.Splitter, {
			Alpha = division,
			OnChanged = setDivision,
		}, {
			Side0 = React.createElement(...),
			Side1 = React.createElement(...),
		})
	end
	```

	By default, the split is horizontal, which means that the frame is split into a left and right
	side. This can be changed, for example to a vertical split (top and bottom), by providing an 
	[Enum.FillDirection] value to the `FillDirection` prop.

	This component can use your system's splitter mouse icons when interacting with the splitter bar. 
	To enable this behavior, ensure you have rendered a [PluginProvider] somewhere higher up in 
	the tree.
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")

local useMouseDrag = require("../Hooks/useMouseDrag")
local useMouseIcon = require("../Hooks/useMouseIcon")
local useTheme = require("../Hooks/useTheme")

local function flipVector2(vector: Vector2, shouldFlip: boolean)
	return if shouldFlip then Vector2.new(vector.Y, vector.X) else vector
end

local function flipUDim2(udim: UDim2, shouldFlip: boolean)
	return if shouldFlip then UDim2.new(udim.Height, udim.Width) else udim
end

local HANDLE_THICKNESS = 6
local DEFAULT_MIN_ALPHA = 0.1
local DEFAULT_MAX_ALPHA = 0.9

--[=[
	@within Splitter
	@interface Props
	@tag Component Props

	@field ... CommonProps

	@field Alpha number
	@field OnChanged ((newAlpha: number) -> ())?
	@field FillDirection Enum.FillDirection?
	@field MinAlpha number?
	@field MaxAlpha number?

	@field children { Side0: React.ReactNode?, Side1: React.ReactNode? }?
]=]

export type SplitterProps = CommonProps.T & {
	Alpha: number,
	OnChanged: ((newAlpha: number) -> ())?,
	FillDirection: Enum.FillDirection?,
	MinAlpha: number?,
	MaxAlpha: number?,
	children: {
		Side0: React.ReactNode,
		Side1: React.ReactNode,
	}?,
}

local icons = {
	[Enum.FillDirection.Horizontal] = "rbxasset://SystemCursors/SplitEW",
	[Enum.FillDirection.Vertical] = "rbxasset://SystemCursors/SplitNS",
}

local function Splitter(props: SplitterProps)
	local theme = useTheme()
	local mouseIcon = useMouseIcon()

	local fillDirection = props.FillDirection or Enum.FillDirection.Horizontal
	local children = props.children or {
		Side0 = nil,
		Side1 = nil,
	}

	local drag = useMouseDrag(function(bar: GuiObject, input: InputObject)
		local region = bar.Parent :: Frame
		local position = Vector2.new(input.Position.X, input.Position.Y)
		local alpha = (position - region.AbsolutePosition) / region.AbsoluteSize
		alpha = alpha:Max(Vector2.one * (props.MinAlpha or DEFAULT_MIN_ALPHA))
		alpha = alpha:Min(Vector2.one * (props.MaxAlpha or DEFAULT_MAX_ALPHA))
		if props.OnChanged then
			if fillDirection == Enum.FillDirection.Horizontal and alpha.X ~= props.Alpha then
				props.OnChanged(alpha.X)
			elseif fillDirection == Enum.FillDirection.Vertical and alpha.Y ~= props.Alpha then
				props.OnChanged(alpha.Y)
			end
		end
	end, { props.Alpha, props.OnChanged, props.MinAlpha, props.MaxAlpha, fillDirection } :: { unknown })

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
		end
	end, { props.Disabled, drag.isActive() })

	local hovered, setHovered = React.useState(false)

	React.useEffect(function()
		if (hovered or drag.isActive()) and not props.Disabled then
			local icon = icons[fillDirection]
			mouseIcon.setIcon(icon)
		else
			mouseIcon.clearIcon()
		end
	end, { mouseIcon, hovered, drag.isActive(), props.Disabled, fillDirection } :: { unknown })

	local function onInputBegan(rbx: Frame, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		end
		if not props.Disabled then
			drag.onInputBegan(rbx, input)
		end
	end
	local function onInputChanged(rbx: Frame, input: InputObject)
		if not props.Disabled then
			drag.onInputChanged(rbx, input)
		end
	end
	local function onInputEnded(rbx: Frame, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
		if not props.Disabled then
			drag.onInputEnded(rbx, input)
		end
	end

	local shouldFlip = fillDirection == Enum.FillDirection.Vertical
	local alpha = props.Alpha
	alpha = math.max(alpha, props.MinAlpha or DEFAULT_MIN_ALPHA)
	alpha = math.min(alpha, props.MaxAlpha or DEFAULT_MAX_ALPHA)

	local handleTransparency = if props.Disabled then 0.75 else 0
	local handleColorStyle = Enum.StudioStyleGuideColor.DialogButton
	if props.Disabled then
		handleColorStyle = Enum.StudioStyleGuideColor.Border
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
	}, {
		Handle = React.createElement("Frame", {
			Active = true, -- prevents the drag-box when in coregui mode
			AnchorPoint = flipVector2(Vector2.new(0.5, 0), shouldFlip),
			Position = flipUDim2(UDim2.fromScale(alpha, 0), shouldFlip),
			Size = flipUDim2(UDim2.new(0, HANDLE_THICKNESS, 1, 0), shouldFlip),
			BackgroundTransparency = handleTransparency,
			BackgroundColor3 = theme:GetColor(handleColorStyle),
			BorderSizePixel = 0,
			[React.Event.InputBegan] = onInputBegan,
			[React.Event.InputChanged] = onInputChanged,
			[React.Event.InputEnded] = onInputEnded,
			ZIndex = 1,
		}, {
			LeftBorder = not props.Disabled and React.createElement("Frame", {
				Size = flipUDim2(UDim2.new(0, 1, 1, 0), shouldFlip),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
				BorderSizePixel = 0,
			}),
			RightBorder = not props.Disabled and React.createElement("Frame", {
				Position = flipUDim2(UDim2.new(1, -1, 0, 0), shouldFlip),
				Size = flipUDim2(UDim2.new(0, 1, 1, 0), shouldFlip),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
				BorderSizePixel = 0,
			}),
		}),
		Side0 = React.createElement("Frame", {
			Size = flipUDim2(UDim2.new(alpha, -math.floor(HANDLE_THICKNESS / 2), 1, 0), shouldFlip),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 0,
		}, {
			Child = children.Side0,
		}),
		Side1 = React.createElement("Frame", {
			AnchorPoint = flipVector2(Vector2.new(1, 0), shouldFlip),
			Position = flipUDim2(UDim2.fromScale(1, 0), shouldFlip),
			Size = flipUDim2(UDim2.new(1 - alpha, -math.ceil(HANDLE_THICKNESS / 2), 1, 0), shouldFlip),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 0,
		}, {
			Child = children.Side1,
		}),
	})
end

return Splitter
