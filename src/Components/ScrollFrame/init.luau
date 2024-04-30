--[=[
	@class ScrollFrame

	A container with scrollable contents. This works the same way as a built-in [ScrollingFrame] but
	has visual changes to match the appearance of built-in scrollers in Studio. 

	| Dark | Light |
	| - | - |
	| ![Dark](/components/scrollframe/dark.png) | ![Light](/components/scrollframe/light.png) |

	ScrollFrames automatically size their canvas to fit their contents, which are passed via the
	`children` parameters in createElement. By default, children are laid out with a [UIListLayout];
	this can be overriden via the `Layout` prop. Either "UIListLayout" or "UIGridLayout" may be
	passed to `Layout.ClassName`. Any other properties to be applied to the layout should also be 
	passed in the `Layout` prop. For example:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.ScrollFrame, {
			Layout = {
				ClassName = "UIListLayout",
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Horizontal,
			}
		}, {
			SomeChild = React.createElement(...),
			AnotherChild = React.createElement(...),
		})
	end
	```

	By default, scrolling on both the X and Y axes is enabled. To configure this, pass an
	[Enum.ScrollingDirection] value to the `ScrollingDirection` prop. Padding around the outside of
	contents can also be configured via the `PaddingLeft`, `PaddingRight`, `PaddingTop`, and 
	`PaddingBottom` props.

	:::info
	The built-in Studio scrollers were changed during this project's lifetime to be significantly
	narrower. This component retains the old, wider, size because it is more accessible.
	:::
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../../CommonProps")
local useTheme = require("../../Hooks/useTheme")

local Constants = require("./Constants")
local ScrollBar = require("./ScrollBar")
local Types = require("./Types")

local SCROLL_WHEEL_SPEED = Constants.WheelScrollAmount
local SCROLLBAR_THICKNESS = Constants.ScrollBarThickness
local SCROLLBAR_MIN_LENGTH = SCROLLBAR_THICKNESS

local function clampVector2(v: Vector2, vmin: Vector2, vmax: Vector2)
	return Vector2.new(math.clamp(v.X, vmin.X, vmax.X), math.clamp(v.Y, vmin.Y, vmax.Y))
end

type ScrollData = Types.ScrollData

local defaultLayout = {
	ClassName = "UIListLayout",
	SortOrder = Enum.SortOrder.LayoutOrder,
}

--[=[
	@within ScrollFrame
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Layout { ClassName: string, [string]: any }?
	@field ScrollingDirection Enum.ScrollingDirection?
	@field PaddingLeft UDim?
	@field PaddingRight UDim?
	@field PaddingTop UDim?
	@field PaddingBottom UDim?
	@field OnScrolled ((scrollOffset: Vector2) -> ())?
	@field children React.ReactNode
]=]

type ScrollFrameProps = CommonProps.T & {
	ScrollingDirection: Enum.ScrollingDirection?,
	PaddingLeft: UDim?,
	PaddingRight: UDim?,
	PaddingTop: UDim?,
	PaddingBottom: UDim?,
	OnScrolled: ((scrollOffset: Vector2) -> ())?,
	Layout: {
		ClassName: string, -- Luau: should be "UIListLayout | "UIGridLayout" but causes problems
		[string]: any, -- native props
	}?,
	children: React.ReactNode,
}

local function computePaddingSize(data: {
	PaddingLeft: UDim?,
	PaddingRight: UDim?,
	PaddingTop: UDim?,
	PaddingBottom: UDim?,
	WindowSize: Vector2,
})
	local paddingX = (data.PaddingLeft or UDim.new(0, 0)) + (data.PaddingRight or UDim.new(0, 0))
	local paddingY = (data.PaddingTop or UDim.new(0, 0)) + (data.PaddingBottom or UDim.new(0, 0))
	return Vector2.new(
		paddingX.Scale * data.WindowSize.X + paddingX.Offset,
		paddingY.Scale * data.WindowSize.Y + paddingY.Offset
	)
end

local function getRegionData(props: ScrollFrameProps, contentSize: Vector2, windowSize: Vector2)
	local scrollingEnabled = {
		X = props.ScrollingDirection ~= Enum.ScrollingDirection.Y,
		Y = props.ScrollingDirection ~= Enum.ScrollingDirection.X,
	}

	local paddingSize = computePaddingSize({
		PaddingLeft = props.PaddingLeft,
		PaddingRight = props.PaddingRight,
		PaddingTop = props.PaddingTop,
		PaddingBottom = props.PaddingBottom,
		WindowSize = windowSize,
	})
	contentSize += paddingSize

	local overflow = contentSize - windowSize
	local visible = { X = false, Y = false }
	for _ = 1, 2 do -- in case Y relayout affects X, we do it twice
		if overflow.X > 0 and not visible.X and scrollingEnabled.X then
			windowSize -= Vector2.new(0, SCROLLBAR_THICKNESS + 1)
			visible.X = true
		end
		if overflow.Y > 0 and not visible.Y and scrollingEnabled.Y then
			windowSize -= Vector2.new(SCROLLBAR_THICKNESS + 1, 0)
			visible.Y = true
		end
		overflow = contentSize - windowSize
	end

	return {
		ContentSize = contentSize,
		WindowSize = windowSize,
		Overflow = overflow,
		Visible = visible,
	}
end

local function ScrollFrame(props: ScrollFrameProps)
	local theme = useTheme()

	local scrollOffsetBinding, setScrollOffsetBinding = React.useBinding(Vector2.zero)
	local contentSizeBinding, setContentSizeBinding = React.useBinding(Vector2.zero)
	local windowSizeBinding, setWindowSizeBinding = React.useBinding(Vector2.zero)

	local function setScrollOffset(offset: Vector2)
		if offset ~= scrollOffsetBinding:getValue() then
			setScrollOffsetBinding(offset)
			if props.OnScrolled then
				props.OnScrolled(offset)
			end
		end
	end

	local function getScrollData(): ScrollData
		local regionData = getRegionData(props, contentSizeBinding:getValue(), windowSizeBinding:getValue())
		local contentSize = regionData.ContentSize
		local windowSize = regionData.WindowSize
		local overflow = regionData.Overflow
		local visible = regionData.Visible

		local alpha = clampVector2(windowSize / contentSize, Vector2.zero, Vector2.one)
		local innerBarSize = windowSize - Vector2.one * (SCROLLBAR_THICKNESS + 1) * 2

		local scrollOffset = scrollOffsetBinding:getValue()
		local offset = alpha * innerBarSize
		offset = offset:Max(Vector2.one * SCROLLBAR_MIN_LENGTH)
		offset = offset:Min(innerBarSize + Vector2.one * 2)
		offset = offset:Max(Vector2.zero)

		local sizeX = if visible.X then offset.X else 0
		local sizeY = if visible.Y then offset.Y else 0
		local size = Vector2.new(sizeX, sizeY)
		local position = clampVector2(scrollOffset / overflow, Vector2.zero, Vector2.one)

		return {
			ContentSize = contentSize,
			WindowSize = windowSize,
			InnerBarSize = innerBarSize,
			BarVisible = visible,
			BarSize = size,
			BarPosition = position,
		}
	end

	local function revalidateScrollOffset()
		local regionData = getRegionData(props, contentSizeBinding:getValue(), windowSizeBinding:getValue())
		local currentOffset = scrollOffsetBinding:getValue()
		local maxOffset = regionData.Overflow:Max(Vector2.zero)
		maxOffset = maxOffset:Min(
			Vector2.new(
				if regionData.Visible.X then maxOffset.X else 0,
				if regionData.Visible.Y then maxOffset.Y else 0
			)
		)
		local newOffset = currentOffset:Min(maxOffset)
		if newOffset ~= currentOffset then
			setScrollOffset(newOffset)
		end
	end

	React.useEffect(
		revalidateScrollOffset,
		{
			props.ScrollingDirection,
			props.Layout,
			props.PaddingLeft,
			props.PaddingRight,
			props.PaddingBottom,
			props.PaddingTop,
		} :: { unknown }
	)

	local function bumpScroll(scrollVector: Vector2)
		local scrollData = getScrollData()
		local windowSize = scrollData.WindowSize
		local contentSize = scrollData.ContentSize
		local scrollOffset = scrollOffsetBinding:getValue()
		local scrollTarget = scrollOffset + scrollVector
		local scrollBounds = contentSize - windowSize
		scrollBounds = scrollBounds:Max(Vector2.zero)
		setScrollOffset(clampVector2(scrollTarget, Vector2.zero, scrollBounds))
	end

	local function handleMainInput(_, input: InputObject)
		if props.Disabled then
			return
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			local amount = SCROLL_WHEEL_SPEED * -input.Position.Z
			local scrollData = getScrollData()
			local shiftHeld = input:IsModifierKeyDown(Enum.ModifierKey.Shift)
			local scrollVector
			if shiftHeld then
				if scrollData.BarVisible.X then
					scrollVector = Vector2.new(amount, 0)
				end
			elseif scrollData.BarVisible.Y then
				scrollVector = Vector2.new(0, amount)
			elseif scrollData.BarVisible.X then
				scrollVector = Vector2.new(amount, 0)
			end
			if scrollVector then
				bumpScroll(scrollVector)
			end
		end
	end

	local scrollDataBinding = React.joinBindings({
		contentSizeBinding,
		windowSizeBinding,
		scrollOffsetBinding,
	}):map(getScrollData)

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	local layoutBase = table.clone(props.Layout or defaultLayout)
	local layoutProps: { [any]: any } = {}
	for key, val in layoutBase :: { [string]: any } do
		if key ~= "ClassName" then
			layoutProps[key] = val
		end
	end
	layoutProps[React.Change.AbsoluteContentSize] = function(rbx: UIListLayout | UIGridLayout)
		setContentSizeBinding(rbx.AbsoluteContentSize)
		revalidateScrollOffset()
	end

	--[[
	Children need to be able to use actual window size for their sizes.
	To facilitate this, the parent Window frame's size equals the clipping area.
	However, this causes the layout in e.g. layout mode Center to lay elements out
	... from the center of the Window, rather than the Canvas.
	We fix this by simply overriding the alignments when the bars are visible
	... since those properties make no difference in those cases.
	]]
	layoutProps.HorizontalAlignment = scrollDataBinding:map(function(data: ScrollData)
		return if data.BarVisible.X then Enum.HorizontalAlignment.Left else layoutBase.HorizontalAlignment
	end)
	layoutProps.VerticalAlignment = scrollDataBinding:map(function(data: ScrollData)
		return if data.BarVisible.Y then Enum.VerticalAlignment.Top else layoutBase.VerticalAlignment
	end)

	local mainSize = scrollDataBinding:map(function(data: ScrollData)
		local windowSize = data.WindowSize:Max(Vector2.zero)
		return UDim2.fromOffset(windowSize.X, windowSize.Y)
	end)

	return React.createElement("Frame", {
		-- sinks scroll input that would otherwise zoom the studio camera
		-- also prevents the drag-box appearing on lmb-drag
		Active = true,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		[React.Event.InputBegan] = handleMainInput,
		[React.Event.InputChanged] = handleMainInput,
		[React.Change.AbsoluteSize] = function(rbx: Frame)
			setWindowSizeBinding(rbx.AbsoluteSize)
			revalidateScrollOffset()
		end :: any,
	}, {
		Cover = if props.Disabled
			then React.createElement("Frame", {
				ZIndex = 2,
				Size = mainSize,
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				BackgroundTransparency = 0.25,
			})
			else nil,
		Clipping = React.createElement("Frame", {
			Size = mainSize,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			Window = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Position = scrollOffsetBinding:map(function(offset: Vector2)
					return UDim2.fromOffset(-offset.X, -offset.Y)
				end),
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingLeft = props.PaddingLeft,
					PaddingRight = props.PaddingRight,
					PaddingTop = props.PaddingTop,
					PaddingBottom = props.PaddingBottom,
				}),
				Layout = React.createElement(layoutBase.ClassName, layoutProps),
			}, props.children),
		}),
		VerticalScrollBar = React.createElement(ScrollBar, {
			Orientation = "Vertical" :: "Vertical", -- Luau
			ScrollData = scrollDataBinding,
			ScrollOffset = scrollOffsetBinding,
			SetScrollOffset = setScrollOffset,
			BumpScroll = bumpScroll,
			Disabled = props.Disabled,
		}),
		HorizontalScrollBar = React.createElement(ScrollBar, {
			Orientation = "Horizontal" :: "Horizontal", -- Luau
			ScrollData = scrollDataBinding,
			ScrollOffset = scrollOffsetBinding,
			SetScrollOffset = setScrollOffset,
			BumpScroll = bumpScroll,
			Disabled = props.Disabled,
		}),
	})
end

return ScrollFrame
