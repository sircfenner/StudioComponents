local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.Parent.withTheme)

local ScrollBarHandle = Roact.Component:extend("ScrollBarHandle")

function ScrollBarHandle:init()
	self:setState({
		Dragging = false,
		Hover = false,
	})
	self._dragBegin = nil
	self._connection = nil

	self.onInputBegan = function(_, inputObject)
		if self.props.Disabled then
			return
		end
		local t = inputObject.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		elseif t == Enum.UserInputType.MouseButton1 and not self.state.Dragging then
			self:setState({ Dragging = true })
			self._dragBegin = inputObject.Position
			self.props.OnDragBegan()
		end
	end

	self.onInputEnded = function(_, inputObject)
		if self.props.Disabled then
			return
		end
		local t = inputObject.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		elseif t == Enum.UserInputType.MouseButton1 and self.state.Dragging then
			self.props.OnDragEnded()
			self._dragBegin = nil
			self:setState({ Dragging = false })
			self:disconnect()
		end
	end

	self.onInputChanged = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif not self.state.Dragging or self._connection then
			return
		elseif inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local signal = inputObject:GetPropertyChangedSignal("Position")
		self._connection = signal:Connect(function()
			local diff = inputObject.Position - self._dragBegin
			self.props.OnDragChanged(Vector2.new(diff.x, diff.y))
		end)
	end
end

function ScrollBarHandle:disconnect()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

function ScrollBarHandle:willUnmount()
	self:disconnect()
end

function ScrollBarHandle:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.state.Dragging or self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	end
	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			AutoButtonColor = false,
			AnchorPoint = self.props.AnchorPoint,
			Position = self.props.Position,
			Size = self.props.Size,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			Text = "",
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputChanged] = self.onInputChanged,
			[Roact.Event.InputEnded] = self.onInputEnded,
		})
	end)
end

return ScrollBarHandle
