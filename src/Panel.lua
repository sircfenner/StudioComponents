local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local Background = require(script.Parent.Background)
local Label = require(script.Parent.Label)
local ImageButton = require(script.Parent.ImageButton)
local useTheme = require(script.Parent.useTheme)
local useDragInput = require(script.Parent.useDragInput)
local usePlugin = require(script.Parent.usePlugin)

local ICON_TEXTURE = "rbxasset://textures/AnimationEditor/icon_close.png"
local TITLEBAR_HEIGHT = 24
local ICON_PADDING = 4
local ICON_SIZE = TITLEBAR_HEIGHT - ICON_PADDING * 2

local DRAGGABLE_AREA_OUTSET = 6

local defaultProps = {
	Title = "Panel.defaultProps.Title",
	MaximumWindowSize = Vector2.new(math.huge, math.huge),
	InitalWindowSize = Vector2.new(300, 200),
	MinimumWindowSize = Vector2.new(0, 0),
	InitalPlacement = Vector2.new(20, 20),
	OnClosed = function() end,
}

local function getResizeDirection(rbx, maybeMouseHit)
	local maybeLeftHit = maybeMouseHit - rbx.AbsolutePosition
	local maybeRightHit = maybeLeftHit - rbx.AbsoluteSize

	local maybeDirectionX = if maybeLeftHit.X >= 0 and maybeLeftHit.X <= DRAGGABLE_AREA_OUTSET
		then -1
		elseif maybeRightHit.X >= -DRAGGABLE_AREA_OUTSET and maybeRightHit.X <= 0 then 1
		else 0

	local maybeDirectionY = if maybeLeftHit.Y >= 0 and maybeLeftHit.Y <= DRAGGABLE_AREA_OUTSET
		then -1
		elseif maybeRightHit.Y >= -DRAGGABLE_AREA_OUTSET and maybeRightHit.Y <= 0 then 1
		else 0

	if maybeDirectionX == 0 and maybeDirectionY == 0 then
		return
	end

	return Vector2.new(maybeDirectionX, maybeDirectionY)
end

local function getCursorIconWithDirection(direction)
	return if direction.X == 1
		then if direction.Y == 0
			then "rbxasset://SystemCursors/SizeEW"
			elseif direction.Y == -1 then "rbxasset://SystemCursors/SizeNESW"
			else "rbxasset://SystemCursors/SizeNWSE"
		elseif direction.X == -1 then if direction.Y == 0
			then "rbxasset://SystemCursors/SizeEW"
			elseif direction.Y == -1 then "rbxasset://SystemCursors/SizeNWSE"
			else "rbxasset://SystemCursors/SizeNESW"
		else if direction.Y == 0 then error("Impossible") else "rbxasset://SystemCursors/SizeNS"
end

local function Panel(props, hooks)
	local theme = useTheme(hooks)
	local plugin = usePlugin(hooks)

	local closed, setClosed = hooks.useState(false)
	local windowSize, setWindowSize = hooks.useState(props.InitalWindowSize)
	local windowPosition, setWindowPosition = hooks.useState(props.InitalPlacement)
	local currentCursor = hooks.useValue({ id = nil, direction = nil })

	local directionOfResizeRef = hooks.useValue(nil)
	local lastPositionReizedToRef = hooks.useValue(nil)

	local lastPositionDraggedToRef = hooks.useValue(nil)

	-- Potentially, the widget may close while there's still a cursor.
	-- Make sure to clean it up!
	hooks.useEffect(function()
		return function()
			plugin.popMouseIcon(currentCursor.value.id)
		end
	end, {})

	local cursorMaybeChanged = function(rbx, inputObject)
		-- We're still dragging, thus should not try to change the cursor icon.
		if directionOfResizeRef.value ~= nil then
			return
		end

		local position = Vector2.new(inputObject.Position.X, inputObject.Position.Y)

		if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local direction = getResizeDirection(rbx, position)

		if direction == nil then
			plugin.popMouseIcon(currentCursor.value.id)
			return
		end

		if currentCursor.value.direction == direction then
			return
		end

		plugin.popMouseIcon(currentCursor.value.id)

		currentCursor.value.direction = getCursorIconWithDirection(direction)
		currentCursor.value.id = plugin.pushMouseIcon(currentCursor.value.direction)
	end

	local windowDragging = useDragInput(hooks, function(rbx, position)
		-- Guard against conflicting with resizing.
		if directionOfResizeRef.value ~= nil then
			return
		end

		-- Inital click, no dragging yet.
		if lastPositionDraggedToRef.value == nil then
			lastPositionDraggedToRef.value = position
			return
		end

		local lastPosition = lastPositionDraggedToRef.value
		local newWindowPosition = windowPosition + (position - lastPosition)
		lastPositionDraggedToRef.value = position

		setWindowPosition(newWindowPosition)
	end)

	local windowResizing = useDragInput(hooks, function(rbx, position)
		-- Guard against conflicting with dragging input.
		if lastPositionDraggedToRef.value ~= nil then
			return
		end

		-- Inital click, no resizing yet.
		if directionOfResizeRef.value == nil then
			lastPositionReizedToRef.value = position
			local draggingDirection = getResizeDirection(rbx, position)

			directionOfResizeRef.value = draggingDirection
			return
		end

		local directionOfResize = directionOfResizeRef.value
		local lastPosition = lastPositionReizedToRef.value

		local newX = if directionOfResize.X == 1
			then (position.X - lastPosition.X) + windowSize.X
			elseif directionOfResize.X == -1 then (lastPosition.X - position.X) + windowSize.X
			else windowSize.X
		local newY = if directionOfResize.Y == 1
			then (position.Y - lastPosition.Y) + windowSize.Y
			elseif directionOfResize.Y == -1 then (lastPosition.Y - position.Y) + windowSize.Y
			else windowSize.Y

		setWindowSize(Vector2.new(newX, newY))

		local delta = position - lastPosition

		setWindowPosition(
			Vector2.new(
				if directionOfResize.X == -1 then delta.X + windowPosition.X else windowPosition.X,
				if directionOfResize.Y == -1 then delta.Y + windowPosition.Y else windowPosition.Y
			)
		)

		lastPositionReizedToRef.value = position
	end)

	if closed then
		return
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
		Position = UDim2.new(0, windowPosition.X, 0, windowPosition.Y),
		AnchorPoint = Vector2.new(0, 0),
		BorderSizePixel = 1,
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
	}, {
		ResizeHitBox = Roact.createElement("Frame", {
			Size = UDim2.new(1, DRAGGABLE_AREA_OUTSET * 2, 1, DRAGGABLE_AREA_OUTSET * 2),
			Position = UDim2.new(0, -DRAGGABLE_AREA_OUTSET, 0, -DRAGGABLE_AREA_OUTSET),
			BackgroundTransparency = 1,
			ZIndex = -1,
			[Roact.Event.InputBegan] = function(rbx, inputObject)
				cursorMaybeChanged(rbx, inputObject)
				windowResizing.onInputBegan(rbx, inputObject)
			end,
			[Roact.Event.InputChanged] = function(rbx, inputObject)
				cursorMaybeChanged(rbx, inputObject)
			end,
			[Roact.Event.InputEnded] = function(rbx, inputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
					-- On dragging ending, make sure that the last position was cleared.
					directionOfResizeRef.value = nil
					lastPositionReizedToRef.value = nil
				end

				cursorMaybeChanged(rbx, inputObject)
				windowResizing.onInputEnded(rbx, inputObject)
			end,
		}),
		Titlebar = Roact.createElement("Frame", {
			Active = true,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
			Size = UDim2.new(1, 0, 0, TITLEBAR_HEIGHT),
			BorderSizePixel = 0,
			[Roact.Event.InputBegan] = function(rbx, inputObject)
				windowDragging.onInputBegan(rbx, inputObject)
			end,
			[Roact.Event.InputEnded] = function(rbx, inputObject)
				-- On dragging ending, make sure that the last position was cleared.
				if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
					lastPositionDraggedToRef.value = nil
				end
				windowDragging.onInputEnded(rbx, inputObject)
			end,
		}, {
			Label = Roact.createElement(Label, {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Text = props.Title,
				TextColorStyle = Enum.StudioStyleGuideColor.TitlebarText,
			}),
			CloseButton = Roact.createElement(ImageButton, {
				BackgroundColorStyle = Enum.StudioStyleGuideColor.Button,
				BorderColorStyle = Enum.StudioStyleGuideColor.DialogButtonBorder,
				BackgroundTransparency = 0,
				Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
				Position = UDim2.new(1, -ICON_SIZE - ICON_PADDING, 0, ICON_PADDING),
				Padding = 3,
				Image = ICON_TEXTURE,
				OnActivated = function()
					setClosed(true)
					props.OnClosed()
				end,
			}),
		}),
		Container = Roact.createElement(Background, {
			Active = true,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -TITLEBAR_HEIGHT),
			Position = UDim2.fromOffset(0, TITLEBAR_HEIGHT),
		}, props[Roact.Children]),
	})
end

return Hooks.new(Roact)(Panel, {
	defaultProps = defaultProps,
})
