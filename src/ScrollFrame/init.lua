local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.withTheme)
local joinDictionaries = require(script.Parent.joinDictionaries)

local ScrollFrame = Roact.Component:extend("ScrollFrame")

local ScrollArrow = require(script.ScrollArrow)
local ScrollBarHandle = require(script.ScrollBarHandle)

local ScrollConstants = require(script.Constants)
local BAR_SIZE = ScrollConstants.ScrollBarSize
local SCROLL_STEP = ScrollConstants.ScrollStep

local defaultLayout = {
	ClassName = "UIListLayout",
	SortOrder = Enum.SortOrder.LayoutOrder,
}

ScrollFrame.defaultProps = {
	ScrollingDirection = Enum.ScrollingDirection.Y,
	BorderSizePixel = 1,
	LayoutOrder = 0,
	ZIndex = 0,
	Disabled = false,
	OnScrolled = function() end,
	Layout = defaultLayout,
}

local function maxVector(vec, limit)
	return Vector2.new(math.max(vec.x, limit.x), math.max(vec.y, limit.y))
end

local function clampVector(vec, min, max)
	return Vector2.new(math.clamp(vec.x, min.x, max.x), math.clamp(vec.y, min.y, max.y))
end

function ScrollFrame:init()
	self.scrollFrameRef = Roact.createRef()

	self.windowSize, self.setWindowSize = Roact.createBinding(Vector2.new(0, 0))
	self.contentSize, self.setContentSize = Roact.createBinding(Vector2.new(0, 0))

	local canvasPosition, setCanvasPosition = Roact.createBinding(Vector2.new(0, 0))
	self.canvasPosition = canvasPosition
	self.setCanvasPosition = function(pos)
		self.props.OnScrolled(pos)
		setCanvasPosition(pos)
	end

	self.barPosScale = Roact.joinBindings({
		windowSize = self.windowSize,
		contentSize = self.contentSize,
		canvasPosition = self.canvasPosition,
	}):map(function(data)
		local windowSize = self:getInnerSize()
		local region = data.contentSize - windowSize
		return Vector2.new(
			region.x > 0 and data.canvasPosition.x / region.x or 0,
			region.y > 0 and data.canvasPosition.y / region.y or 0
		)
	end)

	self.barSizeScale = Roact.joinBindings({
		windowSize = self.windowSize,
		contentSize = self.contentSize,
	}):map(function(data)
		local contentSize = data.contentSize
		local windowSize = self:getInnerSize()
		local region = contentSize - windowSize
		return Vector2.new(
			region.x > 0 and windowSize.x / contentSize.x or 0,
			region.y > 0 and windowSize.y / contentSize.y or 0
		)
	end)

	self.barVisible = self.barSizeScale:map(function(size)
		local direction = self.props.ScrollingDirection
		local hasX = direction ~= Enum.ScrollingDirection.Y
		local hasY = direction ~= Enum.ScrollingDirection.X
		return {
			x = hasX and size.x > 0 and size.x < 1,
			y = hasY and size.y > 0 and size.y < 1,
		}
	end)

	self.maybeScrollInput = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseWheel then
			local factor = -inputObject.Position.z
			local visible = self.barVisible:getValue()
			if visible.y then
				self:scroll(Vector2.new(0, factor))
			elseif visible.x then
				self:scroll(Vector2.new(factor, 0))
			end
		end
	end

	self.onDragBegan = function()
		self._dragBegin = self.canvasPosition:getValue()
	end

	self.onDragEnded = function()
		self._dragBegin = nil
	end

	self.onDragChanged = function(amount)
		local windowSize = self:getInnerSize()
		local contentSize = self.contentSize:getValue()
		local region = maxVector(contentSize - windowSize, Vector2.new(0, 0))
		local barAreaSize = windowSize - 2 * Vector2.new(BAR_SIZE, BAR_SIZE) -- buttons
		local alpha = amount / barAreaSize
		local pos = self._dragBegin + alpha * contentSize
		self.setCanvasPosition(clampVector(pos, Vector2.new(0, 0), region))
	end
end

function ScrollFrame:getInnerSize()
	local direction = self.props.ScrollingDirection
	local hasX = direction ~= Enum.ScrollingDirection.Y
	local hasY = direction ~= Enum.ScrollingDirection.X
	local windowSize = self.windowSize:getValue()
	local windowSizeWithBars = windowSize - Vector2.new(BAR_SIZE + 1, BAR_SIZE + 1)
	local contentSize = self.contentSize:getValue()
	local barVisible = {
		x = hasX and contentSize.x > windowSizeWithBars.x,
		y = hasY and contentSize.y > windowSizeWithBars.y,
	}
	local sizeX = windowSize.x - (barVisible.y and BAR_SIZE + 1 or 0) -- +1 for inner bar border
	local sizeY = windowSize.y - (barVisible.x and BAR_SIZE + 1 or 0) -- as above
	return maxVector(Vector2.new(sizeX, sizeY), Vector2.new(0, 0))
end

function ScrollFrame:scroll(dir)
	local contentSize = self.contentSize:getValue()
	local windowSize = self:getInnerSize()
	local max = maxVector(contentSize - windowSize, Vector2.new(0, 0))
	local current = self.canvasPosition:getValue()
	local amount = dir * SCROLL_STEP
	self.setCanvasPosition(clampVector(current + amount, Vector2.new(0, 0), max))
end

function ScrollFrame:refreshCanvasPosition()
	local contentSize = self.contentSize:getValue()
	local windowSize = self:getInnerSize()
	local max = maxVector(contentSize - windowSize, Vector2.new(0, 0))
	local current = self.canvasPosition:getValue()
	local target = clampVector(current, Vector2.new(0, 0), max)
	self.setCanvasPosition(target)
end

function ScrollFrame:didUpdate(prevProps)
	if prevProps.ScrollingDirection ~= self.props.ScrollingDirection then
		self:refreshCanvasPosition()
	end
end

function ScrollFrame:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	local layoutProps = joinDictionaries(defaultLayout, self.props.Layout)
	local layoutClass = layoutProps.ClassName
	layoutProps.ClassName = nil
	layoutProps[Roact.Change.AbsoluteContentSize] = function(rbx)
		self.setContentSize(rbx.AbsoluteContentSize)
		self:refreshCanvasPosition()
	end

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			LayoutOrder = self.props.LayoutOrder,
			ZIndex = self.props.ZIndex,
			AnchorPoint = self.props.AnchorPoint,
			Position = self.props.Position,
			Size = self.props.Size,
			BorderMode = Enum.BorderMode.Inset,
			BorderSizePixel = self.props.BorderSizePixel,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
			[Roact.Change.AbsoluteSize] = function(rbx)
				local border = self.props.BorderSizePixel * Vector2.new(2, 2) -- each border
				self.setWindowSize(rbx.AbsoluteSize - border)
				self:refreshCanvasPosition()
			end,
			[Roact.Event.InputBegan] = self.maybeScrollInput,
			[Roact.Event.InputChanged] = self.maybeScrollInput,
		}, {
			Cover = self.props.Disabled and Roact.createElement("Frame", {
				ZIndex = 1,
				Size = self.barVisible:map(function(visible)
					return UDim2.new(
						UDim.new(1, visible.y and -BAR_SIZE or 0),
						UDim.new(1, visible.x and -BAR_SIZE or 0)
					)
				end),
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				BackgroundTransparency = 0.25,
			}),
			Clipping = Roact.createElement("Frame", {
				ZIndex = 0,
				Size = self.barVisible:map(function(visible)
					return UDim2.new(
						UDim.new(1, visible.y and -BAR_SIZE or 0),
						UDim.new(1, visible.x and -BAR_SIZE or 0)
					)
				end),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
			}, {
				Holder = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Position = self.canvasPosition:map(function(pos)
						return UDim2.fromOffset(-pos.x, -pos.y)
					end),
				}, {
					Layout = Roact.createElement(layoutClass, layoutProps),
					Content = Roact.createFragment(self.props[Roact.Children]),
				}),
			}),
			BarVertical = Roact.createElement("Frame", {
				ZIndex = 2,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground, modifier),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
				BorderSizePixel = 1,
				Size = self.barVisible:map(function(visible)
					local shift = visible.x and (-BAR_SIZE - 1) or 0
					return UDim2.new(0, BAR_SIZE, 1, shift)
				end),
				Visible = self.barVisible:map(function(visible)
					return visible.y
				end),
			}, {
				UpArrow = Roact.createElement(ScrollArrow, {
					Disabled = self.props.Disabled,
					Direction = ScrollArrow.Direction.Up,
					OnActivated = function()
						self:scroll(Vector2.new(0, -0.25))
					end,
				}),
				DownArrow = Roact.createElement(ScrollArrow, {
					Disabled = self.props.Disabled,
					Direction = ScrollArrow.Direction.Down,
					OnActivated = function()
						self:scroll(Vector2.new(0, 0.25))
					end,
				}),
				BarBackground = Roact.createElement("Frame", {
					Position = UDim2.fromOffset(0, BAR_SIZE + 1),
					Size = UDim2.new(1, 0, 1, -BAR_SIZE * 2 - 2),
					BackgroundTransparency = 1,
				}, {
					Bar = Roact.createElement(ScrollBarHandle, {
						Disabled = self.props.Disabled,
						Position = self.barPosScale:map(function(scale)
							return UDim2.fromScale(0, scale.y)
						end),
						AnchorPoint = self.barPosScale:map(function(scale)
							return Vector2.new(0, scale.y)
						end),
						Size = self.barSizeScale:map(function(scale)
							return UDim2.fromScale(1, scale.y)
						end),
						OnDragBegan = self.onDragBegan,
						OnDragEnded = self.onDragEnded,
						OnDragChanged = function(amount)
							self.onDragChanged(amount * Vector2.new(0, 1))
						end,
					}),
				}),
			}),
			BarHorizontal = Roact.createElement("Frame", {
				ZIndex = 2,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground, modifier),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
				BorderSizePixel = 1,
				Size = self.barVisible:map(function(visible)
					local shift = visible.y and (-BAR_SIZE - 1) or 0
					return UDim2.new(1, shift, 0, BAR_SIZE)
				end),
				Visible = self.barVisible:map(function(visible)
					return visible.x
				end),
			}, {
				LeftArrow = Roact.createElement(ScrollArrow, {
					Disabled = self.props.Disabled,
					Direction = ScrollArrow.Direction.Left,
					OnActivated = function()
						self:scroll(Vector2.new(-0.25, 0))
					end,
				}),
				RightArrow = Roact.createElement(ScrollArrow, {
					Disabled = self.props.Disabled,
					Direction = ScrollArrow.Direction.Right,
					OnActivated = function()
						self:scroll(Vector2.new(0.25, 0))
					end,
				}),
				BarBackground = Roact.createElement("Frame", {
					Position = UDim2.fromOffset(BAR_SIZE + 1, 0),
					Size = UDim2.new(1, -BAR_SIZE * 2 - 2, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Bar = Roact.createElement(ScrollBarHandle, {
						Disabled = self.props.Disabled,
						Position = self.barPosScale:map(function(scale)
							return UDim2.fromScale(scale.x, 0)
						end),
						AnchorPoint = self.barPosScale:map(function(scale)
							return Vector2.new(scale.x, 0)
						end),
						Size = self.barSizeScale:map(function(scale)
							return UDim2.fromScale(scale.x, 1)
						end),
						OnDragBegan = self.onDragBegan,
						OnDragEnded = self.onDragEnded,
						OnDragChanged = function(amount)
							self.onDragChanged(amount * Vector2.new(1, 0))
						end,
					}),
				}),
			}),
		})
	end)
end

return ScrollFrame
