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

-- NB: use purecomponent children to avoid re-rendering them every time split changes

local function safeClamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function maybeFlip(shouldFlip, value)
	if not shouldFlip then
		return value
	elseif typeof(value) == "Vector2" then
		return Vector2.new(value.Y, value.X)
	elseif typeof(value) == "UDim2" then
		return UDim2.new(value.Height, value.Width)
	end
end

local function Splitter(props, hooks)
	local theme = useTheme(hooks)
	local plugin = usePlugin(hooks)

	local containerRef = hooks.useValue(Roact.createRef())

	local drag = useDragInput(hooks, function(_, position)
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
		local newAlpha = if props.Orientation == Constants.SplitterOrientation.Vertical then alpha.x else alpha.y
		if newAlpha ~= props.Alpha then
			props.OnAlphaChanged(newAlpha)
		end
	end)

	local mouseIconId = hooks.useValue(nil)
	local mouseIconUsed = hooks.useValue(nil)

	local function resetMouseIcon()
		if plugin and mouseIconId.value then
			plugin.popMouseIcon(mouseIconId.value)
			mouseIconId.value = nil
			mouseIconUsed.value = nil
		end
	end

	hooks.useEffect(function()
		if plugin ~= nil then
			local using = drag.hovered or drag.active
			local icon = string.format(
				"rbxasset://SystemCursors/Split%s",
				if props.Orientation == Constants.SplitterOrientation.Vertical then "EW" else "NS"
			)
			if using then
				if not mouseIconId.value then
					mouseIconId.value = plugin.pushMouseIcon(icon)
				elseif mouseIconUsed.value ~= icon then
					plugin.popMouseIcon(mouseIconId.value)
					mouseIconId.value = plugin.pushMouseIcon(icon)
				end
				mouseIconUsed.value = icon
			elseif not using and mouseIconId.value then
				resetMouseIcon()
			end
		end
	end, { plugin, drag.hovered, drag.active, props.Orientation })

	hooks.useEffect(function()
		if props.Disabled == true then
			drag.cancel()
		end
	end, { props.Disabled })

	hooks.useEffect(function()
		return resetMouseIcon
	end, {})

	local alpha = safeClamp(props.Alpha, props.MinAlpha, props.MaxAlpha)
	local barColor = theme:GetColor(Enum.StudioStyleGuideColor.DialogButton)
	local flip = props.Orientation ~= Constants.SplitterOrientation.Vertical

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
			Size = maybeFlip(flip, UDim2.new(alpha, -HANDLE_THICKNESS / 2, 1, 0)),
			BackgroundTransparency = 1,
			ZIndex = 0,
			ClipsDescendants = true,
		}, { Content = props[Roact.Children][1] }),
		Side1 = Roact.createElement("Frame", {
			AnchorPoint = maybeFlip(flip, Vector2.new(1, 0)),
			Position = maybeFlip(flip, UDim2.fromScale(1, 0)),
			Size = maybeFlip(flip, UDim2.new(1 - alpha, -HANDLE_THICKNESS / 2, 1, 0)),
			BackgroundTransparency = 1,
			ZIndex = 0,
			ClipsDescendants = true,
		}, { Content = props[Roact.Children][2] }),
		Bar = Roact.createElement("TextButton", {
			Active = false,
			AutoButtonColor = false,
			Text = "",
			AnchorPoint = maybeFlip(flip, Vector2.new(0.5, 0)),
			Position = maybeFlip(flip, UDim2.fromScale(alpha, 0)),
			Size = maybeFlip(flip, UDim2.new(0, HANDLE_THICKNESS, 1, 0)),
			BackgroundColor3 = barColor,
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
