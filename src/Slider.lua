local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.withTheme)
local Slider = Roact.Component:extend("Slider")

local PADDING_BAR_SIDE = 3
local PADDING_REGION_TOP = 1
local PADDING_REGION_SIDE = 6

Slider.defaultProps = {
	Step = 0,
	Disabled = false,
}

function Slider:init()
	self:setState({
		Hover = false,
		Dragging = false,
	})

	self.globalConnection = nil
	self.regionRef = Roact.createRef()

	self.onActivationInput = function(position)
		local props = self.props
		local range = props.Max - props.Min
		local region = self.regionRef:getValue()
		local offset = position - region.AbsolutePosition.x
		local alpha = offset / region.AbsoluteSize.x

		local value = range * alpha
		if props.Step > 0 then
			value = math.round(value / props.Step) * props.Step
		end
		value = math.clamp(value, 0, range) + props.Min

		if value ~= props.Value then
			props.OnChange(value)
		end
	end

	self.onDragStart = function(rbx)
		-- globalConnection handles mouse drags anywhere, i.e. including outside the parent frame
		-- we have to split this into two different cases (1: in a widget, 2: in coregui)
		-- ... because userinputservice events do not fire in widgets, so we have to poll instead
		-- ... which is not ideal because there is a 1 frame delay
		local widget = rbx:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
		if widget ~= nil then
			self.globalConnection = RunService.Heartbeat:Connect(function()
				self.onActivationInput(widget:GetRelativeMousePosition().x)
			end)
		else
			self.globalConnection = UserInputService.InputChanged:Connect(function(newInput)
				if newInput.UserInputType == Enum.UserInputType.MouseMovement then
					self.onActivationInput(newInput.Position.x)
				end
			end)
		end
	end

	self.onHandleInputBegan = function(rbx, input)
		local t = input.UserInputType
		if self.props.Disabled then
			return
		elseif t == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		elseif t == Enum.UserInputType.MouseButton1 then
			if not self.state.Dragging then
				self.onDragStart(rbx)
				self:setState({ Dragging = true })
			end
		end
	end

	self.onHandleInputEnded = function(_rbx, input)
		local t = input.UserInputType
		if self.props.Disabled then
			return
		elseif t == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		elseif t == Enum.UserInputType.MouseButton1 then
			if self.state.Dragging then
				self.globalConnection:Disconnect()
				self.globalConnection = nil
				self:setState({ Dragging = false })
			end
		end
	end
end

function Slider:willUnmount()
	if self.globalConnection then
		self.globalConnection:Disconnect()
		self.globalConnection = nil
	end
end

-- handles the case of a slider becoming disabled during a drag
-- see also getDerivedStateFromProps
function Slider:didUpdate()
	if self.props.Disabled and self.globalConnection then
		self.globalConnection:Disconnect()
		self.globalConnection = nil
	end
end

function Slider.getDerivedStateFromProps(nextProps)
	if nextProps.Disabled then
		return {
			Hover = false,
			Dragging = false,
		}
	end
end

function Slider:render()
	local props = self.props
	local range = props.Max - props.Min
	local alpha = (props.Value - props.Min) / range

	local mainModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
	end

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
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
			[Roact.Event.InputBegan] = function(_, input)
				if props.Disabled then
					return
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					self.onActivationInput(input.Position.x)
				end
			end,
			[Roact.Event.InputChanged] = function(_, input)
				if props.Disabled then
					return
				elseif self.state.Dragging then
					-- this handles drag inputs that happen strictly over the parent frame
					-- this is advantageous in the widget-ancestor case as it prevents the delay
					-- ... resulting from the heartbeat poll for widget input position changing
					self.onActivationInput(input.Position.x)
				end
			end,
		}, {
			Bar = Roact.createElement("Frame", {
				ZIndex = 0,
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
				ZIndex = 1,
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
