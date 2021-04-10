local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local withTheme = require(script.Parent.withTheme)

local function joinDictionaries(...)
	local out = {}
	for i = 1, select("#", ...) do
		for key, val in pairs(select(i, ...)) do
			out[key] = val
		end
	end
	return out
end

local defaultProps = {
	LayoutOrder = 0,
	ZIndex = 0,
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Text = "Label.defaultProps.Text",
	Font = Enum.Font.SourceSans,
	TextSize = 14,
	BackgroundTransparency = 1,
	Disabled = false,
	StyleColor = Enum.StudioStyleGuideColor.MainText,
}

local function Label(props)
	return withTheme(function(theme)
		local joinedProps = joinDictionaries(defaultProps, props)
		local modifier = Enum.StudioStyleGuideModifier.Default
		if joinedProps.Disabled then
			modifier = Enum.StudioStyleGuideModifier.Disabled
		end
		joinedProps.TextColor3 = theme:GetColor(joinedProps.StyleColor, modifier)
		joinedProps.Disabled = nil
		joinedProps.StyleColor = nil
		return Roact.createElement("TextLabel", joinedProps)
	end)
end

return Label
