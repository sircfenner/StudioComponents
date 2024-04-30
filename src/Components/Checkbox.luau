--[=[
	@class Checkbox
	
	A box which can be checked or unchecked, usually used to toggle an option. Passing a value to
	the `Label` prop is the recommended way to indicate the purpose of a checkbox.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/checkbox/dark.png) | ![Light](/StudioComponents/components/checkbox/light.png) |

	As this is a controlled component, you should pass a value to the `Value` prop representing 
	whether the box is checked, and a callback value to the `OnChanged`	prop which gets run when 
	the user interacts with the checkbox. For example:

	```lua
	local function MyComponent()
		local selected, setSelected = React.useState(false)
		return React.createElement(StudioComponents.Checkbox, {
			Value = selected,
			OnChanged = setSelected,
		})
	end
	```

	The default height of a checkbox, including its label, can be found in [Constants.DefaultToggleHeight].
	The size of the whole checkbox can be overridden by passing a value to the `Size` prop.

	By default, the box and label are left-aligned within the parent frame. This can be overriden by 
	passing an [Enum.HorizontalAlignment] value to the `ContentAlignment` prop.

	By default, the box is placed to the left of the label. This can be overriden by passing either
	`Enum.HorizontalAlignment.Left` or `Enum.HorizontalAlignment.Right` to the
	`ButtonAlignment` prop.

	Checkboxes can also represent 'indeterminate' values, which indicates that it is neither
	checked nor unchecked. This can be achieved by passing `nil` to the `Value` prop.
	This might be used when a checkbox represents the combined state of two different options, one of
	which has a value of `true` and the other `false`.

	:::info
	The built-in Studio checkboxes were changed during this project's lifetime to be smaller and
	have a lower contrast ratio, especially in Dark theme. This component retains the old design
	as it is more accessible.
	:::
]=]

local React = require("@pkg/@jsdotlua/react")

local BaseLabelledToggle = require("./Foundation/BaseLabelledToggle")
local useTheme = require("../Hooks/useTheme")

local INDICATOR_IMAGE = "rbxassetid://14890059620"

--[=[
	@within Checkbox
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Value boolean?
	@field OnChanged (() -> ())?
	@field Label string?
	@field ContentAlignment HorizontalAlignment?
	@field ButtonAlignment HorizontalAlignment?
]=]

type CheckboxProps = BaseLabelledToggle.BaseLabelledToggleConsumerProps & {
	Value: boolean?,
}

local function Checkbox(props: CheckboxProps)
	local theme = useTheme()
	local mergedProps = table.clone(props) :: BaseLabelledToggle.BaseLabelledToggleProps

	function mergedProps.RenderButton(subProps: { Hovered: boolean })
		local mainModifier = Enum.StudioStyleGuideModifier.Default
		if props.Disabled then
			mainModifier = Enum.StudioStyleGuideModifier.Disabled
		elseif subProps.Hovered then
			mainModifier = Enum.StudioStyleGuideModifier.Hover
		end

		local backModifier = Enum.StudioStyleGuideModifier.Default
		if props.Disabled then
			backModifier = Enum.StudioStyleGuideModifier.Disabled
		elseif props.Value == true then
			backModifier = Enum.StudioStyleGuideModifier.Selected
		elseif subProps.Hovered then
			backModifier = Enum.StudioStyleGuideModifier.Hover
		end

		local rectOffset = Vector2.new(0, 0)
		if props.Value == nil then -- indeterminate
			local background = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
			local _, _, val = background:ToHSV()
			rectOffset = if val < 0.5 then Vector2.new(14, 0) else Vector2.new(28, 0)
		end

		local indicatorColor = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldIndicator, mainModifier)
		local indicatorTransparency = 0
		if props.Value == nil then
			indicatorColor = Color3.fromRGB(255, 255, 255)
			if props.Disabled then
				indicatorTransparency = 0.5
			end
		end

		return React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBackground, backModifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder, mainModifier),
			BorderMode = Enum.BorderMode.Inset,
			Size = UDim2.fromScale(1, 1),
		}, {
			Indicator = props.Value ~= false and React.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(14, 14),
				Image = INDICATOR_IMAGE,
				ImageColor3 = indicatorColor,
				ImageRectOffset = rectOffset,
				ImageRectSize = Vector2.new(14, 14),
				ImageTransparency = indicatorTransparency,
			}),
		})
	end

	return React.createElement(BaseLabelledToggle, mergedProps)
end

return Checkbox
