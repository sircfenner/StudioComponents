local RunService = game:GetService("RunService")

local React = require("@pkg/@jsdotlua/react")

local useFreshCallback = require("../../Hooks/useFreshCallback")
local useTheme = require("../../Hooks/useTheme")

local Constants = require("./Constants")
local Types = require("./Types")

local ARROW_IMAGE = "rbxassetid://6677623152"
local SCROLLBAR_THICKNESS = Constants.ScrollBarThickness
local ARROW_SCROLL_AMOUNT = Constants.ArrowScrollAmount

local function getArrowImageOffset(orientation: Types.BarOrientation, side: number)
	if orientation == "Vertical" then
		return Vector2.new(0, side * SCROLLBAR_THICKNESS)
	end
	return Vector2.new(SCROLLBAR_THICKNESS, side * SCROLLBAR_THICKNESS)
end

local function getScrollVector(orientation: Types.BarOrientation, side: number)
	local scrollAmount = ARROW_SCROLL_AMOUNT * (if side == 0 then -1 else 1)
	local scrollVector = Vector2.new(0, scrollAmount)
	if orientation == "Horizontal" then
		scrollVector = Vector2.new(scrollAmount, 0)
	end
	return scrollVector
end

type ScrollBarArrowProps = {
	BumpScroll: (scrollVector: Vector2) -> (),
	Orientation: Types.BarOrientation,
	Side: number,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Disabled: boolean?,
}

local function ScrollBarArrow(props: ScrollBarArrowProps)
	local theme = useTheme()
	local connection = React.useRef(nil) :: { current: RBXScriptConnection? }

	local pressed, setPressed = React.useState(false)
	local hovered, setHovered = React.useState(false)

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	end

	local maybeScroll = useFreshCallback(function()
		if hovered then
			props.BumpScroll(getScrollVector(props.Orientation, props.Side))
		end
	end, { hovered, props.BumpScroll, props.Orientation, props.Side } :: { unknown })

	local function startHolding()
		if connection.current then
			connection.current:Disconnect()
		end
		local nextScroll = os.clock() + 0.35
		connection.current = RunService.PostSimulation:Connect(function()
			if os.clock() >= nextScroll then
				maybeScroll()
				nextScroll += 0.05
			end
		end)
		props.BumpScroll(getScrollVector(props.Orientation, props.Side))
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

	local hostClass = "ImageLabel"
	local hostProps = {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		Size = UDim2.fromOffset(SCROLLBAR_THICKNESS, SCROLLBAR_THICKNESS),
		Image = ARROW_IMAGE,
		ImageRectSize = Vector2.new(SCROLLBAR_THICKNESS, SCROLLBAR_THICKNESS),
		ImageRectOffset = getArrowImageOffset(props.Orientation, props.Side),
		ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText, modifier),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
	}

	if props.Disabled ~= true then
		hostClass = "ImageButton"
		hostProps.AutoButtonColor = false
		hostProps[React.Event.InputBegan] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(true)
				startHolding()
			end
		end
		hostProps[React.Event.InputEnded] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				setPressed(false)
				stopHolding()
			end
		end
	end

	return React.createElement(hostClass, hostProps)
end

return ScrollBarArrow
