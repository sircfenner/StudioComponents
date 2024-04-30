local React = require("@pkg/@jsdotlua/react")

local useMouseDrag = require("../../Hooks/useMouseDrag")
local useTheme = require("../../Hooks/useTheme")

local Constants = require("./Constants")
local ScrollBarArrow = require("./ScrollBarArrow")
local Types = require("./Types")

local SCROLLBAR_THICKNESS = Constants.ScrollBarThickness
local INPUT_MOVE = Enum.UserInputType.MouseMovement

local function flipVector2(vector: Vector2, shouldFlip: boolean)
	return if shouldFlip then Vector2.new(vector.Y, vector.X) else vector
end

local function flipUDim2(udim: UDim2, shouldFlip: boolean)
	return if shouldFlip then UDim2.new(udim.Height, udim.Width) else udim
end

type ScrollData = Types.ScrollData

type ScrollBarProps = {
	BumpScroll: (scrollVector: Vector2) -> (),
	Orientation: Types.BarOrientation,
	ScrollData: React.Binding<ScrollData>,
	ScrollOffset: React.Binding<Vector2>,
	SetScrollOffset: (offset: Vector2) -> (),
	Disabled: boolean?,
}

local function ScrollBar(props: ScrollBarProps)
	local vertical = props.Orientation == "Vertical"
	local scrollDataBinding = props.ScrollData

	local theme = useTheme()

	local hovered, setHovered = React.useState(false)
	local dragStartMouse = React.useRef(nil) :: { current: Vector2? }
	local dragStartCanvas = React.useRef(nil) :: { current: Vector2? }

	local function onDragStarted(_, input: InputObject)
		dragStartMouse.current = Vector2.new(input.Position.X, input.Position.Y)
		dragStartCanvas.current = props.ScrollOffset:getValue()
	end

	local function onDragEnded()
		dragStartMouse.current = nil
		dragStartCanvas.current = nil
	end

	local function onDragged(_, input: InputObject)
		local scrollData = scrollDataBinding:getValue()
		local contentSize = scrollData.ContentSize
		local windowSize = scrollData.WindowSize
		local innerBarSize = scrollData.InnerBarSize

		local offsetFrom = dragStartCanvas.current :: Vector2
		local mouseFrom = dragStartMouse.current :: Vector2
		local mouseDelta = Vector2.new(input.Position.X, input.Position.Y) - mouseFrom

		local shiftAlpha = mouseDelta / (innerBarSize - scrollData.BarSize)
		local overflow = contentSize - windowSize

		local newOffset = offsetFrom + overflow * shiftAlpha
		newOffset = newOffset:Min(overflow)
		newOffset = newOffset:Max(Vector2.zero)

		local freshScrollOffset = props.ScrollOffset:getValue()
		if vertical then
			props.SetScrollOffset(Vector2.new(freshScrollOffset.X, newOffset.Y))
		else
			props.SetScrollOffset(Vector2.new(newOffset.X, freshScrollOffset.Y))
		end
	end

	local dragDeps = { props.ScrollOffset, props.SetScrollOffset } :: { unknown }
	local drag = useMouseDrag(onDragged, dragDeps, onDragStarted, onDragEnded)

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
			onDragEnded()
		end
		-- if props.Disabled then
		-- 	setHovered(false)
		-- end
	end, { props.Disabled, drag.isActive() })

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif hovered or drag.isActive() then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	end

	return React.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		Visible = scrollDataBinding:map(function(data: ScrollData)
			return if vertical then data.BarVisible.Y else data.BarVisible.X
		end),
		AnchorPoint = flipVector2(Vector2.new(1, 0), not vertical),
		Position = flipUDim2(UDim2.fromScale(1, 0), not vertical),
		Size = scrollDataBinding:map(function(data)
			local extra = if (vertical and data.BarVisible.X) or (not vertical and data.BarVisible.Y)
				then -SCROLLBAR_THICKNESS - 1
				else 0
			return flipUDim2(UDim2.new(0, SCROLLBAR_THICKNESS, 1, extra), not vertical)
		end),
	}, {
		Arrow0 = React.createElement(ScrollBarArrow, {
			Side = 0,
			Orientation = props.Orientation,
			BumpScroll = props.BumpScroll,
			Disabled = props.Disabled,
		}),
		Arrow1 = React.createElement(ScrollBarArrow, {
			Side = 1,
			Orientation = props.Orientation,
			BumpScroll = props.BumpScroll,
			Position = flipUDim2(UDim2.fromScale(0, 1), not vertical),
			AnchorPoint = flipVector2(Vector2.new(0, 1), not vertical),
			Disabled = props.Disabled,
		}),
		Region = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = flipUDim2(UDim2.fromOffset(0, SCROLLBAR_THICKNESS + 1), not vertical),
			Size = flipUDim2(UDim2.new(1, 0, 1, -(SCROLLBAR_THICKNESS + 1) * 2), not vertical),
		}, {
			Handle = React.createElement("Frame", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar, modifier),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
				Size = scrollDataBinding:map(function(data: ScrollData)
					local size = if vertical then data.BarSize.Y else data.BarSize.X
					return flipUDim2(UDim2.new(1, 0, 0, size), not vertical)
				end),
				Position = scrollDataBinding:map(function(data: ScrollData)
					local position = if vertical then data.BarPosition.Y else data.BarPosition.X
					return flipUDim2(UDim2.fromScale(0, position), not vertical)
				end),
				AnchorPoint = scrollDataBinding:map(function(data: ScrollData)
					local position = if vertical then data.BarPosition.Y else data.BarPosition.X
					return flipVector2(Vector2.new(0, position), not vertical)
				end),
				[React.Event.InputBegan] = function(rbx: Frame, input: InputObject)
					if input.UserInputType == INPUT_MOVE then
						setHovered(true)
					end
					if not props.Disabled then
						drag.onInputBegan(rbx, input)
					end
				end,
				[React.Event.InputChanged] = function(rbx: Frame, input: InputObject)
					if not props.Disabled then
						drag.onInputChanged(rbx, input)
					end
				end,
				[React.Event.InputEnded] = function(rbx: Frame, input: InputObject)
					if input.UserInputType == INPUT_MOVE then
						setHovered(false)
					end
					if not props.Disabled then
						drag.onInputEnded(rbx, input)
					end
				end,
			}),
		}),
	})
end

return ScrollBar
