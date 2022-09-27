local Packages = script.Parent.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.Parent.useTheme)

local function TabButton(props, hooks)
	local theme = useTheme(hooks)
	local hovered, setHovered = hooks.useState(false)
	local pressed, setPressed = hooks.useState(false)

	local onInputBegan = function(_, input)
		if props.Disabled then
			return
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			setPressed(true)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		end
	end

	local onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setPressed(false)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
	end

	local color = Enum.StudioStyleGuideColor.Button
	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif pressed then
		color = Enum.StudioStyleGuideColor.ButtonBorder
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	return Roact.createElement("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme:GetColor(color, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		Text = props.Text,
		Font = Enum.Font.SourceSans,
		TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 14,
		[Roact.Event.InputBegan] = onInputBegan,
		[Roact.Event.InputEnded] = onInputEnded,
		[Roact.Event.Activated] = function()
			if not props.Disabled then
				props.OnActivated()
			end
		end,
	}, {
		Indicator = props.Selected and Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(0, 162, 255),
			BackgroundTransparency = props.Disabled and 0.8 or 0,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 2),
		}),
	})
end

return Hooks.new(Roact)(TabButton)
