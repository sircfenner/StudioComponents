local React = require("@pkg/@jsdotlua/react")

local useMouseDrag = require("../../Hooks/useMouseDrag")
local useMouseIcon = require("../../Hooks/useMouseIcon")
local useTheme = require("../../Hooks/useTheme")

local PickerConstants = require("./Constants")

local CATCHER_SIZE = 15
local ENVELOPE_GRAB_HEIGHT = PickerConstants.EnvelopeHandleHeight
local ENVELOPE_TRANSPARENCY = PickerConstants.EnvelopeTransparency
local ENVELOPE_COLOR_STYLE = PickerConstants.EnvelopeColorStyle

local function EnvelopeHandle(props: {
	Top: boolean,
	Size: UDim2,
	OnDragBegan: () -> (),
	OnDragEnded: () -> (),
	OnEnvelopeDragged: (y: number, top: boolean) -> (),
	Disabled: boolean?,
})
	local theme = useTheme()

	local dragStart = React.useRef(0)
	local dragOffset = React.useRef(0)

	local function onDragBegin(rbx: GuiObject, input: InputObject)
		local pos = input.Position.Y
		local reference
		if props.Top then
			reference = rbx.AbsolutePosition.Y
		else
			reference = rbx.AbsolutePosition.Y + rbx.AbsoluteSize.Y
		end
		dragStart.current = pos
		dragOffset.current = reference - pos
		props.OnDragBegan()
	end

	local drag = useMouseDrag(function(_, input: InputObject)
		local position = input.Position.Y
		if not dragStart.current or math.abs(position - dragStart.current) > 0 then
			local outPosition
			if props.Top then
				outPosition = position + dragOffset.current :: number + ENVELOPE_GRAB_HEIGHT
			else
				outPosition = position + dragOffset.current :: number - ENVELOPE_GRAB_HEIGHT
			end
			props.OnEnvelopeDragged(outPosition, props.Top)
			dragStart.current = nil
		end
	end, { props.OnEnvelopeDragged }, onDragBegin, props.OnDragEnded)

	local hovered, setHovered = React.useState(false)
	local mouseIcon = useMouseIcon()

	React.useEffect(function()
		if (hovered or drag.isActive()) and not props.Disabled then
			mouseIcon.setIcon("rbxasset://SystemCursors/SplitNS")
		else
			mouseIcon.clearIcon()
		end
	end, { hovered, drag.isActive(), props.Disabled } :: { unknown })

	React.useEffect(function()
		return function()
			mouseIcon.clearIcon()
		end
	end, {})

	return React.createElement("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = props.Size,
		AnchorPoint = Vector2.new(0, if props.Top then 0 else 1),
		Position = UDim2.fromScale(0, if props.Top then 0 else 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[React.Event.InputBegan] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			end
			drag.onInputBegan(rbx, input)
		end,
		[React.Event.InputChanged] = drag.onInputChanged,
		[React.Event.InputEnded] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
			drag.onInputEnded(rbx, input)
		end,
		ZIndex = 2,
	}, {
		Visual = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, if props.Top then 0 else 1),
			Position = UDim2.fromScale(0.5, if props.Top then 0 else 1),
			Size = UDim2.fromOffset(if drag.isActive() or hovered then 3 else 1, ENVELOPE_GRAB_HEIGHT + 2),
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
		}, {
			Bar = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, if props.Top then 1 else 0),
				Position = UDim2.fromScale(0.5, if props.Top then 1 else 0),
				Size = UDim2.fromOffset(9, if drag.isActive() or hovered then 3 else 1),
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
			}),
		}),
	})
end

local function SequenceNode(props: {
	ContentSize: Vector2,
	Keypoint: NumberSequenceKeypoint,
	OnNodeDragged: (position: Vector2) -> (),
	OnEnvelopeDragged: (y: number, top: boolean) -> (),
	Active: boolean,
	OnHovered: () -> (),
	OnDragBegan: () -> (),
	OnDragEnded: () -> (),
	Disabled: boolean?,
})
	local theme = useTheme()
	local mouseIcon = useMouseIcon()

	local nodeDragStart = React.useRef(Vector2.zero)
	local nodeDragOffset = React.useRef(Vector2.zero)
	local function onNodeDragBegin(rbx: GuiObject, input: InputObject)
		local pos = Vector2.new(input.Position.X, input.Position.Y)
		local corner = rbx.AbsolutePosition
		local center = corner + rbx.AbsoluteSize / 2
		nodeDragStart.current = pos
		nodeDragOffset.current = center - pos
		props.OnDragBegan()
	end
	local nodeDrag = useMouseDrag(function(_, input: InputObject)
		local position = Vector2.new(input.Position.X, input.Position.Y)
		if not nodeDragStart.current or (position - nodeDragStart.current).Magnitude > 0 then
			props.OnNodeDragged(position + nodeDragOffset.current :: Vector2)
			nodeDragStart.current = nil
		end
	end, { props.OnNodeDragged }, onNodeDragBegin, props.OnDragEnded)

	local px = math.round(props.Keypoint.Time * props.ContentSize.X)
	local py = math.round((1 - props.Keypoint.Value) * props.ContentSize.Y)

	local envelopeHeight = math.round(props.Keypoint.Envelope * props.ContentSize.Y) * 2 + 1
	local fullHeight = envelopeHeight + (ENVELOPE_GRAB_HEIGHT + 1) * 2
	local handleClearance = (fullHeight - CATCHER_SIZE) / 2 - 1

	local innerSize = if props.Active then 11 else 7

	local nodeHovered, setNodeHovered = React.useState(false)
	React.useEffect(function()
		if props.Active and nodeDrag.isActive() then
			mouseIcon.setIcon("rbxasset://SystemCursors/ClosedHand")
		elseif props.Active and nodeHovered then
			mouseIcon.setIcon("rbxasset://SystemCursors/OpenHand")
		else
			mouseIcon.clearIcon()
		end
	end, { props.Active, nodeHovered, nodeDrag.isActive() })

	React.useEffect(function()
		if props.Disabled then
			mouseIcon.clearIcon()
		end
		if nodeDrag.isActive() then
			nodeDrag.cancel()
		end
	end, { props.Disabled })

	local envelopeTransparency = ENVELOPE_TRANSPARENCY
	local mainModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		envelopeTransparency = 1 - 0.5 * (1 - envelopeTransparency)
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("Frame", {
		Position = UDim2.fromOffset(px - (CATCHER_SIZE - 1) / 2, py - (fullHeight - 1) / 2),
		Size = UDim2.fromOffset(CATCHER_SIZE, fullHeight),
		BackgroundTransparency = 1,
		ZIndex = 2,
	}, {
		Line = React.createElement("Frame", {
			AnchorPoint = Vector2.one / 2,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(1, envelopeHeight),
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(ENVELOPE_COLOR_STYLE),
			BackgroundTransparency = envelopeTransparency,
			ZIndex = 0,
		}),

		Node = React.createElement("TextButton", {
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.one / 2,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 0, CATCHER_SIZE),
			BackgroundTransparency = 1,
			[React.Event.InputBegan] = function(rbx, input)
				if props.Disabled then
					return
				elseif input.UserInputType == Enum.UserInputType.MouseMovement then
					setNodeHovered(true)
					props.OnHovered()
				end
				nodeDrag.onInputBegan(rbx, input)
			end,
			[React.Event.InputChanged] = function(rbx, input)
				if props.Disabled then
					return
				end
				nodeDrag.onInputChanged(rbx, input)
			end,
			[React.Event.InputEnded] = function(rbx, input)
				if props.Disabled then
					return
				elseif input.UserInputType == Enum.UserInputType.MouseMovement then
					setNodeHovered(false)
				end
				nodeDrag.onInputEnded(rbx, input)
			end,
			ZIndex = 1,
		}, {
			Inner = React.createElement("Frame", {
				AnchorPoint = Vector2.one / 2,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(innerSize, innerSize),
				BackgroundColor3 = if props.Active
					then theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, mainModifier)
					else theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
				ZIndex = 2,
			}, {
				Stroke = React.createElement("UIStroke", {
					Color = if props.Active
						then theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier)
						else theme:GetColor(Enum.StudioStyleGuideColor.DimmedText, mainModifier),
					Thickness = if nodeDrag.isActive() then 2 else 1,
				}),
			}),
		}),

		Top = props.Active and React.createElement(EnvelopeHandle, {
			Top = true,
			Size = UDim2.new(1, 0, 0, math.min(ENVELOPE_GRAB_HEIGHT, handleClearance)),
			OnDragBegan = props.OnDragBegan,
			OnDragEnded = props.OnDragEnded,
			OnEnvelopeDragged = props.OnEnvelopeDragged,
		}),

		Bottom = props.Active and React.createElement(EnvelopeHandle, {
			Top = false,
			Size = UDim2.new(1, 0, 0, math.min(ENVELOPE_GRAB_HEIGHT, handleClearance)),
			OnDragBegan = props.OnDragBegan,
			OnDragEnded = props.OnDragEnded,
			OnEnvelopeDragged = props.OnEnvelopeDragged,
		}),
	})
end

return SequenceNode
