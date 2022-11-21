local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)

local Constants = require(script.Parent.Constants)

local INDICATOR_IMAGE = "rbxassetid://6652838434"

local defaultProps = {
	LayoutOrder = 0,
	Disabled = false,
	Alignment = Constants.CheckboxAlignment.Left,
}

local function Checkbox(props, hooks)
	local theme = useTheme(hooks)
	local hovered, setHovered = hooks.useState(false)

	local onInputBegan = function(_, inputObject)
		if props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		end
	end

	local onInputEnded = function(_, inputObject)
		if props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
	end

	local onActivated = function()
		if not props.Disabled then
			props.OnActivated()
		end
	end

	local mainModifier = theme.Default
	if props.Disabled then
		mainModifier = theme.Disabled
	elseif hovered then
		mainModifier = theme.Hover
	end

	local backModifier = theme.Default
	if props.Disabled then
		backModifier = theme.Disabled
	elseif props.Value == true then
		backModifier = theme.Selected
	end

	local boxPositionX = 0
	local textPositionX = 1
	local textAlign = Enum.TextXAlignment.Left
	if props.Alignment == Constants.CheckboxAlignment.Right then
		boxPositionX = 1
		textPositionX = 0
		textAlign = Enum.TextXAlignment.Right
	end

	local rectOffset = Vector2.new(0, 0)
	if props.Value == Constants.CheckboxIndeterminate then
		if tostring(theme) == "Dark" then -- this is a hack
			rectOffset = Vector2.new(13, 0)
		else
			rectOffset = Vector2.new(26, 0)
		end
	end

	local indicatorColor = mainModifier("CheckedFieldIndicator")
	if props.Value == Constants.CheckboxIndeterminate then
		indicatorColor = Color3.fromRGB(255, 255, 255)
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 15),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		Button = Roact.createElement("TextButton", {
			Text = "",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			[Roact.Event.InputBegan] = onInputBegan,
			[Roact.Event.InputEnded] = onInputEnded,
			[Roact.Event.Activated] = onActivated,
		}),
		Box = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(boxPositionX, 0),
			Position = UDim2.fromScale(boxPositionX, 0),
			BackgroundColor3 = backModifier("CheckedFieldBackground"),
			BorderColor3 = mainModifier("CheckedFieldBorder"),
			BorderMode = Enum.BorderMode.Inset,
			Size = UDim2.fromOffset(15, 15),
		}, {
			Indicator = props.Value ~= false and Roact.createElement("ImageLabel", {
				Position = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(13, 13),
				Image = INDICATOR_IMAGE,
				ImageColor3 = indicatorColor,
				ImageRectOffset = rectOffset,
				ImageRectSize = Vector2.new(13, 13),
			}),
		}),
		Label = props.Label and Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(textPositionX, 0),
			Position = UDim2.fromScale(textPositionX, 0),
			Size = UDim2.new(1, -20, 1, 0),
			TextXAlignment = textAlign,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = props.Label,
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextColor3 = mainModifier("MainText"),
		}),
	})
end

return Hooks.new(Roact)(Checkbox, {
	defaultProps = defaultProps,
})
