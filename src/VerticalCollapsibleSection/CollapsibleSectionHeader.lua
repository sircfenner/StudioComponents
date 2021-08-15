local Vendor = script.Parent.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.Parent.withTheme)

local Label = require(script.Parent.Parent.Label)
local CollapsibleSectionHeader = Roact.Component:extend("CollapsibleSectionHeader")

local Constants = require(script.Parent.Parent.Constants)
local HEADER_HEIGHT = 24

function CollapsibleSectionHeader:init()
	self:setState({ Hover = false })
	self.onInputBegan = function(_, inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self.props.OnToggled()
		end
	end
	self.onInputEnded = function(_, inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
end

function CollapsibleSectionHeader:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Active = true,
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.HeaderSection, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 7, 0.5, 0),
				Size = UDim2.fromOffset(10, 10),
				Image = "rbxassetid://5607705156",
				ImageColor3 = Color3.fromRGB(170, 170, 170),
				ImageRectOffset = Vector2.new(self.props.Collapsed and 0 or 10, 0),
				ImageRectSize = Vector2.new(10, 10),
				BackgroundTransparency = 1,
			}),
			Label = Roact.createElement(Label, {
				TextColorStyle = Enum.StudioStyleGuideColor.BrightText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Constants.FontBold,
				Text = self.props.Text,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 24),
				}),
			}),
		})
	end)
end

return CollapsibleSectionHeader
