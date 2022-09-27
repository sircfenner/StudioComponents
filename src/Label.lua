local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)
local joinDictionaries = require(script.Parent.joinDictionaries)

local Constants = require(script.Parent.Constants)

local defaultProps = {
	LayoutOrder = 0,
	ZIndex = 0,
	Disabled = false,
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Text = "Label.defaultProps.Text",
	Font = Constants.Font,
	TextSize = Constants.TextSize,
	TextColorStyle = Enum.StudioStyleGuideColor.MainText,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	BorderMode = Enum.BorderMode.Inset,
	-- BackColorStyle?
	-- BorderColorStyle?
}

local function Label(props, hooks)
	local theme = useTheme(hooks)

	local joinedProps = joinDictionaries(defaultProps, props)
	local modifier = if joinedProps.Disabled then theme.Disabled else theme.Default
	joinedProps.TextColor3 = modifier(joinedProps.TextColorStyle)
	joinedProps.Disabled = nil
	joinedProps.TextColorStyle = nil

	return Roact.createElement("TextLabel", joinedProps)
end

return Hooks.new(Roact)(Label, {
	defaultProps = defaultProps,
})
