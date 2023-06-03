local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)

local defaultProps = {
	LayoutOrder = 0,
	Disabled = false,
	Selected = false,
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Image = "",
	BackgroundColorStyle = Enum.StudioStyleGuideColor.Button,
	BorderColorStyle = Enum.StudioStyleGuideColor.ButtonBorder,
	OnActivated = function() end,
}

local function ImageButton(props, hooks)
	local theme = useTheme(hooks)

	local hovered, setHovered = hooks.useState(false)
	local pressed, setPressed = hooks.useState(false)

	local onInputBegan = function(_, inputObject)
		if props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			setPressed(true)
		end
	end

	local onInputEnded = function(_, inputObject)
		if props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			setPressed(false)
		end
	end

	local onActivated = function()
		if not props.Disabled then
			setHovered(false)
			setPressed(false)
			props.OnActivated()
		end
	end

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Selected
	elseif pressed then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	return Roact.createElement("TextButton", {
		Text = "",
		Size = props.Size,
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		BackgroundColor3 = theme:GetColor(props.BackgroundColorStyle, modifier),
		BorderColor3 = theme:GetColor(props.BorderColorStyle, modifier),
		BorderMode = Enum.BorderMode.Inset,
		AutoButtonColor = false,

		[Roact.Event.InputBegan] = onInputBegan,
		[Roact.Event.InputEnded] = onInputEnded,
		[Roact.Event.Activated] = onActivated,
	}, {
		Image = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, props.Padding * -2, 1, props.Padding * -2),
			Position = UDim2.new(0, props.Padding, 0, props.Padding),
			Image = props.Image,
			BackgroundTransparency = 1,
		})
	})
end

return Hooks.new(Roact)(ImageButton, {
	defaultProps = defaultProps,
})
