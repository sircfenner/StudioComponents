local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.withTheme)
local BaseButton = Roact.Component:extend("BaseButton")

local Constants = require(script.Parent.Constants)

BaseButton.defaultProps = {
	LayoutOrder = 0,
	Disabled = false,
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Text = "Button.defaultProps.Text",
	TextStyleColor = Enum.StudioStyleGuideColor.ButtonText,
	BackgroundStyleColor = Enum.StudioStyleGuideColor.Button,
	BorderStyleColor = Enum.StudioStyleGuideColor.ButtonBorder,
}

function BaseButton:init()
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

function BaseButton:render()
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
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextColor3 = theme:GetColor(self.props.TextStyleColor, modifier),
			BackgroundColor3 = theme:GetColor(self.props.BackgroundStyleColor, modifier),
			BorderColor3 = theme:GetColor(self.props.BorderStyleColor, modifier),
			AutoButtonColor = false,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = self.onActivated,
		})
	end)
end

return BaseButton
