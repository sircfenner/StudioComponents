--[=[
	@class Constants
	This module exposes values that are read from in various components.
	These can be used to, for example, match the appearance of custom components with components
	from this library.

	:::warning
	The table returned by this module is read-only. It is not a config.
	:::
]=]

local Constants = {}

--- @within Constants
--- @prop DefaultFont Font
--- The default font for text.
Constants.DefaultFont = Enum.Font.SourceSans

--- @within Constants
--- @prop DefaultTextSize number
--- The default size for text.
Constants.DefaultTextSize = 14

--- @within Constants
--- @prop DefaultButtonHeight number
--- The default height of buttons.
Constants.DefaultButtonHeight = 24

--- @within Constants
--- @prop DefaultToggleHeight number
--- The default height of toggles (Checkbox and RadioButton).
Constants.DefaultToggleHeight = 20

--- @within Constants
--- @prop DefaultInputHeight number
--- The default height of text and numeric inputs.
Constants.DefaultInputHeight = 22

--- @within Constants
--- @prop DefaultSliderHeight number
--- The default height of sliders.
Constants.DefaultSliderHeight = 22

--- @within Constants
--- @prop DefaultDropdownHeight number
--- The default height of the permanent section of dropdowns.
Constants.DefaultDropdownHeight = 20

--- @within Constants
--- @prop DefaultDropdownRowHeight number
--- The default height of rows in dropdown lists.
Constants.DefaultDropdownRowHeight = 16

--- @within Constants
--- @prop DefaultProgressBarHeight number
--- The default height of progress bars.
Constants.DefaultProgressBarHeight = 14

--- @within Constants
--- @prop DefaultColorPickerSize UDim2
--- The default window size of color pickers.
Constants.DefaultColorPickerSize = UDim2.fromOffset(260, 285)

--- @within Constants
--- @prop DefaultNumberSequencePickerSize UDim2
--- The default window size of number sequence pickers.
Constants.DefaultNumberSequencePickerSize = UDim2.fromOffset(425, 285)

return table.freeze(Constants)
