local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.withTheme)
local Checkbox = Roact.Component:extend("Checkbox")

local INDICATOR_IMAGE = "rbxassetid://6652838434"

Checkbox.Indeterminate = "Indeterminate"

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
			Size = UDim2.new(1, 0, 0, 23),
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
			}),
			Button = Roact.createElement("TextButton", {
				Text = "",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				[Roact.Event.InputBegan] = self.onInputBegan,
				[Roact.Event.InputEnded] = self.onInputEnded,
				[Roact.Event.Activated] = self.onActivated,
			}),
			Box = Roact.createElement("ImageLabel", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBackground, backModifier),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder, mainModifier),
				Size = UDim2.fromOffset(13, 13),
				Image = INDICATOR_IMAGE,
				ImageColor3 = indicatorColor,
				ImageTransparency = self.props.Value == false and 1 or 0,
				ImageRectOffset = rectOffset,
				ImageRectSize = Vector2.new(13, 13),
			}),
			Label = self.props.Label and Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(19, -1),
				Size = UDim2.new(1, -19, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = self.props.Label,
				Font = Enum.Font.SourceSans,
				TextSize = 14,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier),
			}),
		})
	end)
end

return Checkbox
