local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.withTheme)

local ScrollFrame = Roact.Component:extend("ScrollFrame")

local ScrollArrow = require(script.ScrollArrow)
local ScrollBar = require(script.ScrollBar)

local Constants = require(script.Parent.Constants)
local BAR_SIZE = Constants.ScrollBarWidth
local ARROW_BUMP_AMOUNT = 20

ScrollFrame.defaultProps = {
	LayoutOrder = 0,
	ZIndex = 0,
	Position = UDim2.fromScale(0, 0),
	Size = UDim2.fromScale(1, 1),
	AnchorPoint = Vector2.new(0, 0),
}

function ScrollFrame:init()
	self.scrollFrameRef = Roact.createRef()

	self.windowSize, self.setWindowSize = Roact.createBinding(Vector2.new())
	self.contentSize, self.setContentSize = Roact.createBinding(Vector2.new())
	self.canvasPosition, self.setCanvasPosition = Roact.createBinding(Vector2.new())

	self.barPosScale = Roact.joinBindings({
		windowSize = self.windowSize,
		contentSize = self.contentSize,
		canvasPosition = self.canvasPosition,
	}):map(function(data)
		local alpha = data.canvasPosition.y / (data.contentSize.y - data.windowSize.y - 2)
		if alpha ~= alpha then
			return 0
		end
		return math.clamp(alpha, 0, 1)
	end)

	local barSizeAlpha = Roact.joinBindings({
		windowSize = self.windowSize,
		contentSize = self.contentSize,
	}):map(function(data)
		local alpha = (data.windowSize.y - BAR_SIZE * 2 - 2)
			/ (data.contentSize.y - BAR_SIZE * 2)
		if alpha ~= alpha then
			return 0
		end
		return math.clamp(alpha, 0, 1)
	end)
	self.barSizeOffset = Roact.joinBindings({
		windowSize = self.windowSize,
		barSizeAlpha = barSizeAlpha,
	}):map(function(data)
		return math.max(33, data.barSizeAlpha * (data.windowSize.y - BAR_SIZE * 2))
	end)
	self.barVisible = barSizeAlpha:map(function(size)
		return size < 1
	end)
end

function ScrollFrame:render()
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			AnchorPoint = self.props.AnchorPoint,
			Size = self.props.Size,
			Position = self.props.Position,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderMode = Enum.BorderMode.Inset,
			LayoutOrder = self.props.LayoutOrder,
			ZIndex = self.props.ZIndex,
			[Roact.Change.AbsoluteSize] = function(rbx)
				self.setWindowSize(rbx.AbsoluteSize)
			end,
		}, {
			Clipping = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ClipsDescendants = true,
				ZIndex = 0,
			}, {
				ScrollFrame = Roact.createElement("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, BAR_SIZE),
					Size = UDim2.new(1, 0, 1, -BAR_SIZE * 2),
					ClipsDescendants = false,
					ScrollBarThickness = BAR_SIZE,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					CanvasSize = self.contentSize:map(function(size)
						return UDim2.fromOffset(0, size.y - BAR_SIZE * 2)
					end),
					[Roact.Change.CanvasPosition] = function(rbx)
						self.setCanvasPosition(rbx.CanvasPosition)
					end,
					[Roact.Ref] = self.scrollFrameRef,
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, -BAR_SIZE),
						PaddingBottom = UDim.new(0, -BAR_SIZE),
					}),
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						[Roact.Change.AbsoluteContentSize] = function(rbx)
							self.setContentSize(rbx.AbsoluteContentSize)
						end,
					}),
					Content = Roact.createFragment(self.props[Roact.Children]),
				}),
			}),
			Side = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, BAR_SIZE, 1, 0),
				BackgroundTransparency = 1,
				Visible = self.barVisible,
				ZIndex = 1,
			}, {
				BarBackground = Roact.createElement("Frame", {
					Position = UDim2.fromOffset(0, BAR_SIZE),
					Size = UDim2.new(1, 0, 1, -BAR_SIZE * 2),
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground),
					BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
				}, {
					Bar = Roact.createElement(ScrollBar, {
						Position = self.barPosScale:map(function(scale)
							return UDim2.fromScale(0, scale)
						end),
						AnchorPoint = self.barPosScale:map(function(scale)
							return Vector2.new(0, scale)
						end),
						Size = self.barSizeOffset:map(function(offset)
							return UDim2.new(1, 0, 0, offset)
						end),
					}),
				}),
				UpButton = Roact.createElement(ScrollArrow, {
					Direction = ScrollArrow.Direction.Up,
					OnActivated = function()
						local rbx = self.scrollFrameRef:getValue()
						rbx.CanvasPosition -= Vector2.new(0, ARROW_BUMP_AMOUNT)
					end,
				}),
				DownButton = Roact.createElement(ScrollArrow, {
					Direction = ScrollArrow.Direction.Down,
					OnActivated = function()
						local rbx = self.scrollFrameRef:getValue()
						rbx.CanvasPosition += Vector2.new(0, ARROW_BUMP_AMOUNT)
					end,
				}),
			}),
		})
	end)
end

return ScrollFrame
