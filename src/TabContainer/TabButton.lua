local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.Parent.withTheme)

local TabButton = Roact.Component:extend("TabButton")

function TabButton:init()
	self:setState({ Hover = false, Pressed = false })
	self.onInputBegan = function(_, input)
		if self.props.Disabled then
			return
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = true })
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end
	self.onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = false })
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
end

function TabButton:render()
	local color = Enum.StudioStyleGuideColor.Button
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif self.state.Pressed then
		color = Enum.StudioStyleGuideColor.ButtonBorder
	elseif self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end
	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = theme:GetColor(color, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
			LayoutOrder = self.props.LayoutOrder,
			Size = self.props.Size,
			Text = self.props.Text,
			Font = Enum.Font.SourceSans,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextSize = 14,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = function()
				if not self.props.Disabled then
					self.props.OnActivated()
				end
			end,
		}, {
			Indicator = self.props.Selected and Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.fromRGB(0, 162, 255),
				BackgroundTransparency = self.props.Disabled and 0.8 or 0,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 2),
			}),
		})
	end)
end

return TabButton
