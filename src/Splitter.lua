local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local Constants = require(script.Parent.Constants)
local useTheme = require(script.Parent.useTheme)
local usePlugin = require(script.Parent.usePlugin)
local useDragInput = require(script.Parent.useDragInput)

local HANDLE_THICKNESS = 4

local defaultProps = {
	Size = UDim2.fromScale(1, 1),
	MinAlpha = 0.05,
	MaxAlpha = 0.95,
	Orientation = Constants.SplitterOrientation.Vertical,
}

--[[
TODO: 
- is there a strategy for preventing child re-renders when the only thing that changed is the split?
- self-managed version?
]]

-- handles min > max by prioritizing min operation
local function safeClamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function Splitter(props, hooks)
	local theme = useTheme(hooks)
	local plugin = usePlugin(hooks)

	local containerRef = hooks.useValue(Roact.createRef())

	local drag = useDragInput(hooks, function(position)
		local container = containerRef.value:getValue()
		local size = container.AbsoluteSize
		local offset = Vector2.new(position.x, position.y) - container.AbsolutePosition
		offset = Vector2.new(
			safeClamp(offset.x, HANDLE_THICKNESS + 1, size.x - HANDLE_THICKNESS - 1),
			safeClamp(offset.y, HANDLE_THICKNESS + 1, size.y - HANDLE_THICKNESS - 1)
		)
		local relative = offset / size
		local alpha = Vector2.new(
			safeClamp(relative.x, props.MinAlpha, props.MaxAlpha),
			safeClamp(relative.y, props.MinAlpha, props.MaxAlpha)
		)
		props.OnAlphaChanged(if props.Orientation == Constants.SplitterOrientation.Vertical then alpha.x else alpha.y)
	end)

	local mouseIconId = hooks.useValue(nil)
	local mouseIconUsed = hooks.useValue(nil)

	hooks.useEffect(function()
		if plugin ~= nil then
			local active = drag.hovered or drag.dragging
			local icon = string.format(
				"rbxasset://SystemCursors/Split%s",
				if props.Orientation == Constants.SplitterOrientation.Vertical then "EW" else "NS"
			)
			if active then
				if not mouseIconId.value then
					mouseIconId.value = plugin.pushMouseIcon(icon)
				elseif mouseIconUsed.value ~= icon then
					plugin.popMouseIcon(mouseIconId.value)
					mouseIconId.value = plugin.pushMouseIcon(icon)
				end
				mouseIconUsed.value = icon
			elseif not active and mouseIconId.value then
				plugin.popMouseIcon(mouseIconId.value)
				mouseIconId.value = nil
				mouseIconUsed.value = nil
			end
		end
	end, { plugin, drag.hovered, drag.dragging, props.Orientation })

	hooks.useEffect(function()
		return function()
			if plugin and mouseIconId.value then
				plugin.popMouseIcon(mouseIconId.value)
				mouseIconId.value = nil
				mouseIconUsed.value = nil
			end
		end
	end, {})

	local alpha = safeClamp(props.Alpha, props.MinAlpha, props.MaxAlpha)

	local size0 = UDim2.new(alpha, -HANDLE_THICKNESS / 2, 1, 0)
	local size1 = UDim2.new(1 - alpha, -HANDLE_THICKNESS / 2, 1, 0)
	local anchor1 = Vector2.new(1, 0)
	local position1 = UDim2.fromScale(1, 0)
	local barAnchorPoint = Vector2.new(0.5, 0)
	local barPosition = UDim2.fromScale(alpha, 0)
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
		[Roact.Ref] = containerRef.value,
	}, {
		Side0 = Roact.createElement("Frame", {
			Size = size0,
			BackgroundTransparency = 1,
			ZIndex = 0,
		}, { Content = props[Roact.Children][1] }),
		Side1 = Roact.createElement("Frame", {
			AnchorPoint = anchor1,
			Position = position1,
			Size = size1,
			BackgroundTransparency = 1,
			ZIndex = 0,
		}, { Content = props[Roact.Children][2] }),
		Bar = Roact.createElement("TextButton", {
			Active = false,
			AutoButtonColor = false,
			Text = "",
			AnchorPoint = barAnchorPoint,
			Position = barPosition,
			Size = barSize,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogButton),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BackgroundTransparency = props.Disabled and 0.75 or 0,
			ZIndex = 1,
			[Roact.Event.InputBegan] = if not props.Disabled then drag.onInputBegan else nil,
			[Roact.Event.InputEnded] = if not props.Disabled then drag.onInputEnded else nil,
		}),
	})
end

return Hooks.new(Roact)(Splitter, {
	defaultProps = defaultProps,
})
