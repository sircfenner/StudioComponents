local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Constants = require(script.Parent.Constants)
local withTheme = require(script.Parent.withTheme)
local joinDictionaries = require(script.Parent.joinDictionaries)

local dropdownConstants = {
	TextPaddingLeft = 5,
	TextPaddingRight = 3,
}

local dropdownDefaults = {
	RowHeightTop = 20,
	RowHeightItem = 15,
	MaxVisibleRows = 6,
}

--[[
todo:
- props.Disabled
- should it have a border?
- close when clicked outside (preferably compatible with AutomaticSize - no big frame)
- consider lifting open/closed state up (compatibility with mutually exclusive dropdowns)
- look into using Context for mutually exclusive dropdowns (needs design)
]]

local ScrollFrame = require(script.Parent.ScrollFrame)
local DropdownItem = require(script.DropdownItem)

local Dropdown = Roact.Component:extend("Dropdown")

function Dropdown:init()
	self:setState({
		Open = false,
		Hover = false,
	})
	self.onSelectedInputBegan = function(_rbx, input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		elseif t == Enum.UserInputType.MouseButton1 then
			self:setState({ Open = not self.state.Open })
		end
	end
	self.onSelectedInputEnded = function(_rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
	self.onSelectedItem = function(item)
		self:setState({ Open = false })
		self.props.OnSelected(item)
	end
end

function Dropdown:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local background = Enum.StudioStyleGuideColor.MainBackground
	if self.state.Open or self.state.Hover then
		background = Enum.StudioStyleGuideColor.InputFieldBackground
	end

	return withTheme(function(theme)
		local dropdownOptions = joinDictionaries(dropdownDefaults, {
			Width = self.props.Width,
			RowHeightTop = self.props.RowHeightTop,
			RowHeightItem = self.props.RowHeightItem,
			MaxVisibleRows = self.props.MaxVisibleRows,
		})

		local items = {}
		if self.state.Open then
			for i, item in ipairs(self.props.Items) do
				items[i] = Roact.createElement(DropdownItem, {
					Item = item,
					LayoutOrder = i,
					RowHeightItem = dropdownOptions.RowHeightItem,
					TextPaddingLeft = dropdownConstants.TextPaddingLeft - 1,
					TextPaddingRight = dropdownConstants.TextPaddingRight,
					OnSelected = self.onSelectedItem,
				})
			end
		end

		local rowPadding = 1
		local visibleItems = math.min(dropdownOptions.MaxVisibleRows, #items)
		local scrollHeight = visibleItems * dropdownOptions.RowHeightItem -- item heights
			+ (visibleItems - 1) * rowPadding -- row padding
			+ 2 -- top and bottom borders

		print(dropdownOptions.Width)

		return Roact.createElement("Frame", {
			Size = UDim2.new(dropdownOptions.Width.Scale, dropdownOptions.Width.Offset, 0, dropdownOptions.RowHeightTop),
			Position = self.props.Position,
			AnchorPoint = self.props.AnchorPoint,
			BackgroundTransparency = 1,
			[Roact.Event.InputBegan] = self.onSelectedInputBegan,
			[Roact.Event.InputEnded] = self.onSelectedInputEnded,
		}, {
			Selected = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = theme:GetColor(background, modifier),
				BorderMode = Enum.BorderMode.Inset,
				BorderSizePixel = 1,
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
				Text = self.props.Item,
				Font = Constants.Font,
				TextSize = Constants.TextSize,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, dropdownConstants.TextPaddingLeft),
					PaddingRight = UDim.new(0, dropdownConstants.TextPaddingRight),
				}),
			}),
			ArrowContainer = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, 18, 1, 0),
				BackgroundTransparency = 1,
			}, {
				Arrow = Roact.createElement("ImageLabel", {
					Image = "rbxassetid://7260137654",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(8, 4),
					BackgroundTransparency = 1,
					ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText, modifier),
				}),
			}),
			Drop = self.state.Open and Roact.createElement(ScrollFrame, {
				Position = UDim2.new(0, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, scrollHeight),
				Layout = {
					Padding = UDim.new(0, rowPadding),
				},
			}, items),
		})
	end)
end

return Dropdown
