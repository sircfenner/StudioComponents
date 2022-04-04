local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local joinDictionaries = require(script.Parent.joinDictionaries)
local withTheme = require(script.Parent.withTheme)
local BaseButton = Roact.Component:extend("BaseButton")

local Constants = require(script.Parent.Constants)

BaseButton.defaultProps = {
	LayoutOrder = 0,
	Disabled = false,
	Selected = false,
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Text = "Button.defaultProps.Text",
	TextColorStyle = Enum.StudioStyleGuideColor.ButtonText,
	BackgroundColorStyle = Enum.StudioStyleGuideColor.Button,
	BorderColorStyle = Enum.StudioStyleGuideColor.ButtonBorder,
	OnActivated = function() end,
}

local propsToScrub = {
	Disabled = Roact.None,
	Selected = Roact.None,
	TextColorStyle = Roact.None,
	BackgroundColorStyle = Roact.None,
	BorderColorStyle = Roact.None,
	OnActivated = Roact.None,
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
			self:setState({
				Hover = false,
				Pressed = false,
			})
			self.props.OnActivated()
		end
	end
end

function BaseButton:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Selected
	elseif self.state.Pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end
	return withTheme(function(theme)
		local scrubbedProps = joinDictionaries(self.props, propsToScrub, {
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextColor3 = theme:GetColor(self.props.TextColorStyle, modifier),
			BackgroundColor3 = theme:GetColor(self.props.BackgroundColorStyle, modifier),
			BorderColor3 = theme:GetColor(self.props.BorderColorStyle, modifier),
			BorderMode = Enum.BorderMode.Inset,
			AutoButtonColor = false,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = self.onActivated,
		})

		return Roact.createElement("TextButton", scrubbedProps)
	end)
end

return BaseButton
