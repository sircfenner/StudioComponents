local TextService = game:GetService("TextService")

local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local Constants = require(script.Parent.Constants)
local useTheme = require(script.Parent.useTheme)

local defaultProps = {
	Label = "RadioButton.defaultProps.Label",
}

local HEIGHT = 16
local TEXT_PADDING = 5

local FONT = Constants.Font
local TEXT_SIZE = Constants.TextSize

local function RadioButton(props, hooks)
	local theme = useTheme(hooks)
	local hovered, setHovered = hooks.useState(false)

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif hovered then
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
			if not props.Disabled and input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			end
		end,
		[Roact.Event.InputEnded] = function(_, input)
			if not props.Disabled and input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
		end,
		[Roact.Event.Activated] = function()
			if not props.Disabled then
				props.OnActivated()
			end
		end,
	}, {
		Main = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(HEIGHT - 4, HEIGHT - 4),
			Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, modifier),
			BackgroundTransparency = props.Disabled and 0.65 or 0,
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = theme:GetColor(secondaryColorStyle, modifier),
				Thickness = 1,
				Transparency = props.Disabled and 0.65 or 0,
			}),
			Inner = props.Value == true and Roact.createElement("Frame", {
				Size = UDim2.new(1, -4, 1, -4),
				Position = UDim2.fromOffset(2, 2),
				BackgroundColor3 = theme:GetColor(secondaryColorStyle, modifier),
				BackgroundTransparency = props.Disabled and 0.65 or 0,
				BorderSizePixel = 0,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),
			}),
		}),
		Label = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, textSize.X, 1, 0),
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
