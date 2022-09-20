local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.withTheme)
local getDragInput = require(script.Parent.getDragInput)

local Slider = Roact.Component:extend("Slider")

local PADDING_BAR_SIDE = 3
local PADDING_REGION_TOP = 1
local PADDING_REGION_SIDE = 6

Slider.defaultProps = {
	Step = 0,
	Disabled = false,
	Background = function(props)
		local mainModifier = Enum.StudioStyleGuideModifier.Default
		if props.Disabled then
			mainModifier = Enum.StudioStyleGuideModifier.Disabled
		end

		return withTheme(function(theme)
			return Roact.createElement("Frame", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
			})
		end)
	end,
}

function Slider:init()
	self:setState({
		Hover = false,
		Dragging = false,
	})

	self.regionRef = Roact.createRef()

	self.sliderDrag = getDragInput(function(rbx, position)
		if self.props.Disabled then
			return
		end

		self:setState({ Dragging = true })

		local props = self.props
		local range = props.Max - props.Min
		local region = self.regionRef:getValue()
		local offset = position.X - region.AbsolutePosition.x
		local alpha = offset / region.AbsoluteSize.x

		local value = range * alpha
		if props.Step > 0 then
			value = math.round(value / props.Step) * props.Step
		end
		value = math.clamp(value, 0, range) + props.Min

		if value ~= props.Value then
			props.OnChange(value)
		end
	end)

	self.onHandleInputBegan = function(rbx, input)
		if self.props.Disabled then
			return
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end

	self.onHandleInputEnded = function(rbx, input)
		if self.props.Disabled then
			return
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
end

function Slider:willUnmount()
	self.sliderDrag.clean()
end

-- handles the case of a slider becoming disabled during a drag
-- see also getDerivedStateFromProps
function Slider:didUpdate()
	if self.props.Disabled then
		self.sliderDrag.forceEnd()
	end
end

function Slider.getDerivedStateFromProps(nextProps)
	if nextProps.Disabled then
		return {
			Hover = false,
			Dragging = false,
		}
	end

	return
end

function Slider:render()
	local props = self.props
	local range = props.Max - props.Min
	local alpha = (props.Value - props.Min) / range

	local handleModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		handleModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.state.Hover or self.state.Dragging then
		handleModifier = Enum.StudioStyleGuideModifier.Hover
	end

	return withTheme(function(theme)
		-- used to create a blended border color when slider is disabled
		local handleFill = theme:GetColor(Enum.StudioStyleGuideColor.Button, handleModifier)
		local handleBorder = theme:GetColor(Enum.StudioStyleGuideColor.Border, handleModifier)

		-- if we use a Frame here, the 2d studio selection rectangle will appear when dragging
		-- we could prevent that using Active = true, but that displays the Click cursor
		-- ... the best workaround is a TextButton with Active = false
		return Roact.createElement("TextButton", {
			Text = "",
			Active = false,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 22),
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			LayoutOrder = props.LayoutOrder,
			ZIndex = props.ZIndex,
			BackgroundTransparency = 1,
			[Roact.Event.InputBegan] = self.sliderDrag.began,
			[Roact.Event.InputEnded] = self.sliderDrag.ended,
		}, {
			BackgroundHolder = Roact.createElement("Frame", {
				ZIndex = 0,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				Background = Roact.createElement(self.props.Background, {
					Disabled = props.Disabled,
					Hover = self.state.Hover,
					Dragging = self.state.Dragging,
					Value = self.props.Value,
				}),
			}),
			Bar = Roact.createElement("Frame", {
				ZIndex = 1,
				Position = UDim2.fromOffset(PADDING_BAR_SIDE, 10),
				Size = UDim2.new(1, -PADDING_BAR_SIDE * 2, 0, 2),
				BorderSizePixel = 0,
				BackgroundTransparency = props.Disabled and 0.4 or 0,
				BackgroundColor3 = theme:GetColor(
					-- this looks odd but provides the correct colors for both themes
					Enum.StudioStyleGuideColor.TitlebarText,
					Enum.StudioStyleGuideModifier.Disabled
				),
			}),
			HandleRegion = Roact.createElement("Frame", {
				ZIndex = 2,
				Position = UDim2.fromOffset(PADDING_REGION_SIDE, PADDING_REGION_TOP),
				Size = UDim2.new(1, -PADDING_REGION_SIDE * 2, 1, -PADDING_REGION_TOP * 2),
				BackgroundTransparency = 1,
				[Roact.Ref] = self.regionRef,
			}, {
				Handle = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(alpha, 0),
					Size = UDim2.new(0, 10, 1, 0),
					BorderMode = Enum.BorderMode.Inset,
					BorderSizePixel = 1,
					BorderColor3 = handleBorder:Lerp(handleFill, props.Disabled and 0.5 or 0),
					BackgroundColor3 = handleFill,
					[Roact.Event.InputBegan] = self.onHandleInputBegan,
					[Roact.Event.InputEnded] = self.onHandleInputEnded,
				}),
			}),
		})
	end)
end

return Slider
