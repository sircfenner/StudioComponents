local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local Constants = require(script.Parent.Parent.Constants)
local withTheme = require(script.Parent.Parent.withTheme)

local DropdownItem = Roact.Component:extend("DropdownItem")

function DropdownItem:init()
	self:setState({ Hover = false })
	self.onInputBegan = function(_rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end
	self.onInputEnded = function(_rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
end

function DropdownItem:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			AutoButtonColor = false,
			LayoutOrder = self.props.LayoutOrder,
			Size = UDim2.new(1, 0, 0, self.props.RowHeightItem),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.EmulatorBar, modifier),
			BorderSizePixel = 0,
			Text = self.props.Item,
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = function()
				self.props.OnSelected(self.props.Item)
			end,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, self.props.TextPaddingLeft),
				PaddingRight = UDim.new(0, self.props.TextPaddingRight),
			}),
		})
	end)
end

return DropdownItem
