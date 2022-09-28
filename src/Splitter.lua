local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local Constants = require(script.Parent.Constants)
local useTheme = require(script.Parent.useTheme)

local HANDLE_THICKNESS = 4

local defaultProps = {
	Size = UDim2.fromScale(1, 1),
	MinAlpha = 0.05,
	MaxAlpha = 0.95,
	Orientation = Constants.SplitterOrientation.Vertical,
}

--[[
TODO: 
- figure out how (whether?) to do mouse icon
- disabled?
- self-managed version?
- make sure no perf concerns from re-rendering complex children (?)
- make dragging still work when cursor is outside of a widget/background (getDragInput?)
]]

-- handles case where min is greater than max by prioritizing the min operation
local function safeClamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function Splitter(props, hooks)
	local theme = useTheme(hooks)
	local dragging, setDragging = hooks.useState(false)

	local onInputBegan = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setDragging(true)
		end
	end

	local onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setDragging(false)
		end
	end

	local onInputChanged = function(container, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging == true then
				local size = container.AbsoluteSize
				local offset = Vector2.new(input.Position.x, input.Position.y) - container.AbsolutePosition
				offset = Vector2.new(
					-- prevent handle escaping container
					safeClamp(offset.x, HANDLE_THICKNESS + 1, size.x - HANDLE_THICKNESS - 1),
					safeClamp(offset.y, HANDLE_THICKNESS + 1, size.y - HANDLE_THICKNESS - 1)
				)
				local relative = offset / size
				local alpha = Vector2.new(
					-- additionally clamp within min/max from props
					safeClamp(relative.x, props.MinAlpha, props.MaxAlpha),
					safeClamp(relative.y, props.MinAlpha, props.MaxAlpha)
				)
				props.OnAlphaChanged(
					if props.Orientation == Constants.SplitterOrientation.Vertical then alpha.x else alpha.y
				)
			end
		end
	end

	local size0 = UDim2.new(props.Alpha, -HANDLE_THICKNESS / 2, 1, 0)
	local size1 = UDim2.new(1 - props.Alpha, -HANDLE_THICKNESS / 2, 1, 0)
	local anchor1 = Vector2.new(1, 0)
	local position1 = UDim2.fromScale(1, 0)
	local barAnchorPoint = Vector2.new(0.5, 0)
	local barPosition = UDim2.fromScale(props.Alpha, 0)
	local barSize = UDim2.new(0, HANDLE_THICKNESS, 1, 0)
	if props.Orientation == Constants.SplitterOrientation.Horizontal then
		size0 = UDim2.new(size0.Height, size0.Width)
		size1 = UDim2.new(size1.Height, size1.Width)
		anchor1 = Vector2.new(anchor1.y, anchor1.x)
		position1 = UDim2.new(position1.Height, position1.Width)
		barAnchorPoint = Vector2.new(barAnchorPoint.y, barAnchorPoint.x)
		barPosition = UDim2.new(barPosition.Height, barPosition.Width)
		barSize = UDim2.new(barSize.Height, barSize.Width)
	end

	return Roact.createElement("Frame", {
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
		[Roact.Event.InputChanged] = onInputChanged,
	}, {
		Side0 = Roact.createElement("Frame", {
			Size = size0,
			BackgroundTransparency = 1,
			ZIndex = 0,
		}, { props[Roact.Children][1] }),
		Side1 = Roact.createElement("Frame", {
			AnchorPoint = anchor1,
			Position = position1,
			Size = size1,
			BackgroundTransparency = 1,
			ZIndex = 0,
		}, { props[Roact.Children][2] }),
		Bar = Roact.createElement("TextButton", {
			AutoButtonColor = false,
			Text = "",
			AnchorPoint = barAnchorPoint,
			Position = barPosition,
			Size = barSize,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogButton),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			ZIndex = 1,
			[Roact.Event.InputBegan] = onInputBegan,
			[Roact.Event.InputEnded] = onInputEnded,
		}),
	})
end

return Hooks.new(Roact)(Splitter, {
	defaultProps = defaultProps,
})
