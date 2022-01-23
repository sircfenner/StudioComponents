local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.withTheme)
local Checkbox = Roact.Component:extend("Checkbox")

local Constants = require(script.Parent.Constants)

local INDICATOR_IMAGE = "rbxassetid://6652838434"

Checkbox.Indeterminate = "Indeterminate"
Checkbox.Alignment = {
	Left = "Left",
	Right = "Right",
}

Checkbox.defaultProps = {
	LayoutOrder = 0,
	Disabled = false,
	Alignment = Checkbox.Alignment.Left,
}

function Checkbox:init()
	self:setState({ Hover = false })
	self.onInputBegan = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end
	self.onInputEnded = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
	self.onActivated = function()
		if not self.props.Disabled then
			self.props.OnActivated()
		end
	end
end

function Checkbox:render()
	local mainModifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.state.Hover then
		mainModifier = Enum.StudioStyleGuideModifier.Hover
	end

	local backModifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		backModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.props.Value == true then
		backModifier = Enum.StudioStyleGuideModifier.Selected
	end

	local boxPositionX = 0
	local textPositionX = 1
	local textAlign = Enum.TextXAlignment.Left
	if self.props.Alignment == Checkbox.Alignment.Right then
		boxPositionX = 1
		textPositionX = 0
		textAlign = Enum.TextXAlignment.Right
	end

	return withTheme(function(theme)
		local rectOffset = Vector2.new(0, 0)
		if self.props.Value == Checkbox.Indeterminate then
			if tostring(theme) == "Dark" then -- this is a hack
				rectOffset = Vector2.new(13, 0)
			else
				rectOffset = Vector2.new(26, 0)
			end
		end

		local indicatorColor = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldIndicator, mainModifier)
		if self.props.Value == Checkbox.Indeterminate then
			indicatorColor = Color3.fromRGB(255, 255, 255)
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 15),
			BackgroundTransparency = 1,
			LayoutOrder = self.props.LayoutOrder,
		}, {
			Button = Roact.createElement("TextButton", {
				Text = "",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				[Roact.Event.InputBegan] = self.onInputBegan,
				[Roact.Event.InputEnded] = self.onInputEnded,
				[Roact.Event.Activated] = self.onActivated,
			}),
			Box = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(boxPositionX, 0),
				Position = UDim2.fromScale(boxPositionX, 0),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBackground, backModifier),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder, mainModifier),
				BorderMode = Enum.BorderMode.Inset,
				Size = UDim2.fromOffset(15, 15),
			}, {
				Indicator = self.props.Value ~= false and Roact.createElement("ImageLabel", {
					Position = UDim2.fromOffset(0, 0),
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(13, 13),
					Image = INDICATOR_IMAGE,
					ImageColor3 = indicatorColor,
					ImageRectOffset = rectOffset,
					ImageRectSize = Vector2.new(13, 13),
				}),
			}),
			Label = self.props.Label and Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(textPositionX, 0),
				Position = UDim2.fromScale(textPositionX, 0),
				Size = UDim2.new(1, -20, 1, 0),
				TextXAlignment = textAlign,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = self.props.Label,
				Font = Constants.Font,
				TextSize = Constants.TextSize,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier),
			}),
		})
	end)
end

return Checkbox
