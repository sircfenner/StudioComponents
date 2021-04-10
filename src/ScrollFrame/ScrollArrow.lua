local Vendor = script.Parent.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.Parent.withTheme)

local ScrollArrow = Roact.Component:extend("ScrollArrow")

local Constants = require(script.Parent.Parent.Constants)

local ARROW_IMAGE = "rbxassetid://6663404312"
local BAR_SIZE = Constants.ScrollBarWidth

ScrollArrow.Direction = {
	Up = "Up",
	Down = "Down",
}

function ScrollArrow:init()
	self:setState({ Pressed = false })
	self.onInputBegan = function(_, inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = true })
			self.props.OnActivated()
		end
	end
	self.onInputEnded = function(_, inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = false })
		end
	end
end

function ScrollArrow:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.state.Pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	end

	local anchor = Vector2.new(0, 0)
	local position = UDim2.fromScale(0, 0)
	local imageOffset = Vector2.new(0, 0)
	if self.props.Direction == ScrollArrow.Direction.Down then
		anchor = Vector2.new(0, 1)
		position = UDim2.fromScale(0, 1)
		imageOffset = Vector2.new(0, BAR_SIZE)
	end

	return withTheme(function(theme)
		return Roact.createElement("ImageButton", {
			AutoButtonColor = false,
			AnchorPoint = anchor,
			Position = position,
			Size = UDim2.fromOffset(BAR_SIZE, BAR_SIZE),
			Image = ARROW_IMAGE,
			ImageRectSize = Vector2.new(BAR_SIZE, BAR_SIZE),
			ImageRectOffset = imageOffset,
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
		})
	end)
end

return ScrollArrow
