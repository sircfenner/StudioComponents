local TextService = game:GetService("TextService")

local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)

local defaultProps = {
	Label = "RadioButton.defaultProps.Label",
}

local HEIGHT = 16
local FONT = Enum.Font.SourceSans
local TEXT_SIZE = 14
local TEXT_PADDING = 5

local function RadioButton(props, hooks)
	local theme = useTheme(hooks)
	local hovered, setHovered = hooks.useState(false)

	local modifier = Enum.StudioStyleGuideModifier.Default
	if hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local secondaryColorStyle = Enum.StudioStyleGuideColor.DimmedText
	if props.Value == true then
		secondaryColorStyle = Enum.StudioStyleGuideColor.SubText
	end

	local textSize = TextService:GetTextSize(props.Label, TEXT_SIZE, FONT, Vector2.new(math.huge, math.huge))

	return Roact.createElement("TextButton", {
		Active = true,
		Text = "",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(textSize.X + HEIGHT + TEXT_PADDING, HEIGHT),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		[Roact.Event.InputBegan] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			end
		end,
		[Roact.Event.InputEnded] = function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
		end,
		[Roact.Event.Activated] = function()
			props.OnActivated()
		end,
	}, {
		Main = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(HEIGHT - 4, HEIGHT - 4),
			Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, modifier),
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = theme:GetColor(secondaryColorStyle, modifier),
				Thickness = 1,
			}),
			Inner = props.Value == true and Roact.createElement("Frame", {
				Size = UDim2.new(1, -4, 1, -4),
				Position = UDim2.fromOffset(2, 2),
				BackgroundColor3 = theme:GetColor(secondaryColorStyle, modifier),
				BorderSizePixel = 0,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),
			}),
		}),
		Label = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, textSize.X, 1, 0), -- !
			Position = UDim2.new(0, HEIGHT + TEXT_PADDING, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = props.Label,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Font = FONT,
			TextSize = TEXT_SIZE,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
		}),
		Children = Roact.createFragment(props[Roact.Children]),
	})
end

return Hooks.new(Roact)(RadioButton, {
	defaultProps = defaultProps,
})
