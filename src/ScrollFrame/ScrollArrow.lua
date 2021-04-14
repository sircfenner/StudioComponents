local Vendor = script.Parent.Parent.Parent
local Roact = require(Vendor.Roact)

local RunService = game:GetService("RunService")

local joinDictionaries = require(script.Parent.Parent.joinDictionaries)
local withTheme = require(script.Parent.Parent.withTheme)

local ScrollArrow = Roact.Component:extend("ScrollArrow")

local Constants = require(script.Parent.Parent.Constants)

local ARROW_IMAGE = "rbxassetid://6677623152"
local BAR_SIZE = Constants.ScrollBarSize

ScrollArrow.Direction = {
	Up = "Up",
	Down = "Down",
	Left = "Left",
	Right = "Right",
}

function ScrollArrow:init()
	self:setState({
		Hover = false,
		Pressed = false,
	})
	self.listenConnection = nil

	self.onInputBegan = function(_, inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = true })
			self.props.OnActivated()
			self:connect()
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end

	self.onInputEnded = function(_, inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setState({ Pressed = false })
			self:disconnect()
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
end

function ScrollArrow:willUnmount()
	self:disconnect()
end

function ScrollArrow:connect()
	self:disconnect()
	local nextAt = os.clock() + 0.35
	self.listenConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now >= nextAt then
			if self.state.Hover then
				self.props.OnActivated()
			end
			nextAt += 0.05
		end
	end)
end

function ScrollArrow:disconnect()
	if self.listenConnection then
		self.listenConnection:Disconnect()
		self.listenConnection = nil
	end
end

function ScrollArrow:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.state.Pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	end

	local anchor = Vector2.new(0, 0)
	local position = UDim2.fromScale(0, 0)
	local imageOffset = Vector2.new(0, 0)
	if self.props.Direction == ScrollArrow.Direction.Down then
		anchor = Vector2.new(0, 1)
		position = UDim2.fromScale(0, 1)
		imageOffset = Vector2.new(0, BAR_SIZE)
	elseif self.props.Direction == ScrollArrow.Direction.Left then
		imageOffset = Vector2.new(BAR_SIZE, 0)
	elseif self.props.Direction == ScrollArrow.Direction.Right then
		anchor = Vector2.new(1, 0)
		position = UDim2.fromScale(1, 0)
		imageOffset = Vector2.new(BAR_SIZE, BAR_SIZE)
	end

	return withTheme(function(theme)
		local baseProps = {
			AnchorPoint = anchor,
			Position = position,
			Size = UDim2.fromOffset(BAR_SIZE, BAR_SIZE),
			Image = ARROW_IMAGE,
			ImageRectSize = Vector2.new(BAR_SIZE, BAR_SIZE),
			ImageRectOffset = imageOffset,
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText, modifier),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		}
		return self.props.Disabled
			and Roact.createElement("ImageLabel", baseProps)
			or Roact.createElement(
				"ImageButton",
				joinDictionaries(baseProps, {
					AutoButtonColor = false,
					[Roact.Event.InputBegan] = self.onInputBegan,
					[Roact.Event.InputEnded] = self.onInputEnded,
				})
			)
	end)
end

return ScrollArrow
