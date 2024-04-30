--[=[
	@class RadioButton

	An input element similar to a [Checkbox] which can either be selected or not selected.
	This should be used for an option in a mutually exclusive group of options (the user can
	only select one out of the group). This grouping behavior is not included and must be 
	implemented separately.

	| Dark | Light |
	| - | - |
	| ![Dark](/components/radiobutton/dark.png) | ![Light](/components/radiobutton/light.png) |

	The props and behavior for this component are the same as [Checkbox]. Importantly, this is
	also a controlled component, which means it does not manage its own selected state. A value
	must be passed to the `Value` prop and a callback should be passed to the `OnChanged` prop.
	For example:

	```lua
	local function MyComponent()
		local selected, setSelected = React.useState(false)
		return React.createElement(StudioComponents.RadioButton, {
			Value = selected,
			OnChanged = setSelected,
		})
	end
	```

	For more information about customizing this component via props, refer to the documentation
	for [Checkbox]. The default height for this component is found in [Constants.DefaultToggleHeight].
]=]

local React = require("@pkg/@jsdotlua/react")

local BaseLabelledToggle = require("./Foundation/BaseLabelledToggle")
local useTheme = require("../Hooks/useTheme")

local PADDING = 1
local INNER_PADDING = 3

--[=[
	@within RadioButton
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Value boolean?
	@field OnChanged (() -> ())?
	@field Label string?
	@field ContentAlignment HorizontalAlignment?
	@field ButtonAlignment HorizontalAlignment?
]=]

type RadioButtonProps = BaseLabelledToggle.BaseLabelledToggleConsumerProps & {
	Value: boolean,
}

local function RadioButton(props: RadioButtonProps)
	local theme = useTheme()
	local mergedProps = table.clone(props) :: BaseLabelledToggle.BaseLabelledToggleProps

	function mergedProps.RenderButton(subProps: { Hovered: boolean })
		local mainModifier = Enum.StudioStyleGuideModifier.Default
		if props.Disabled then
			mainModifier = Enum.StudioStyleGuideModifier.Disabled
		elseif subProps.Hovered then
			mainModifier = Enum.StudioStyleGuideModifier.Hover
		end

		return React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBackground, mainModifier),
			BackgroundTransparency = 0,
			Size = UDim2.new(1, -PADDING * 2, 1, -PADDING * 2),
			Position = UDim2.fromOffset(1, PADDING),
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
			Stroke = React.createElement("UIStroke", {
				Color = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder, mainModifier),
				Transparency = 0,
			}),
			Inner = if props.Value == true
				then React.createElement("Frame", {
					Size = UDim2.new(1, -INNER_PADDING * 2, 1, -INNER_PADDING * 2),
					Position = UDim2.fromOffset(INNER_PADDING, INNER_PADDING),
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton, mainModifier),
					BackgroundTransparency = 0.25,
				}, {
					Corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
				})
				else nil,
		})
	end

	return React.createElement(BaseLabelledToggle, mergedProps)
end

return RadioButton
