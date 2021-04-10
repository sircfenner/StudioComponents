local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.withTheme)
local Button = Roact.Component:extend("Button")

Button.defaultProps = {
	LayoutOrder = 0,
	Disabled = false,
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Text = "Button.defaultProps.Text",
}

function Button:init()
	self:setState({
		Hover = false,
		Pressed = false,
	})
	self.onInputBegan = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = true })
		end
	end
	self.onInputEnded = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = false })
		end
	end
	self.onActivated = function()
		if not self.props.Disabled then
			self.props.OnActivated()
		end
	end
end

function Button:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.state.Pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end
	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			Size = self.props.Size,
			Position = self.props.Position,
			AnchorPoint = self.props.AnchorPoint,
			LayoutOrder = self.props.LayoutOrder,
			Text = self.props.Text,
			Font = Enum.Font.SourceSans,
			TextSize = 14,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText, modifier),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder, modifier),
			AutoButtonColor = false,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = self.onActivated,
		})
	end)
end

return Button
