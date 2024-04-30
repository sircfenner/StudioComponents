local React = require("@pkg/@jsdotlua/react")

local Constants = require("../Constants")
local NumericInput = require("../Components/NumericInput")
local createStory = require("./Helpers/createStory")

local function StoryItem(props: {
	LayoutOrder: number,
	Arrows: boolean?,
	Slider: boolean?,
})
	local value, setValue = React.useState(5)

	local min = 0
	local max = 10
	local step = 0.25

	local function format(n: number)
		return string.format("%.2f", n)
	end

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(0, 150, 0, Constants.DefaultInputHeight * 2 + 10),
		BackgroundTransparency = 1,
	}, {
		Enabled = React.createElement(NumericInput, {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, Constants.DefaultInputHeight),
			Value = value,
			Min = min,
			Max = max,
			Step = step,
			ClearTextOnFocus = false,
			OnValidChanged = setValue,
			FormatValue = format,
			Arrows = props.Arrows,
			Slider = props.Slider,
		}),
		Disabled = React.createElement(NumericInput, {
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, Constants.DefaultInputHeight),
			Position = UDim2.fromOffset(0, Constants.DefaultInputHeight + 5),
			Value = value,
			Min = min,
			Max = max,
			Step = step,
			ClearTextOnFocus = false,
			OnValidChanged = function() end,
			FormatValue = format,
			Arrows = props.Arrows,
			Slider = props.Slider,
			Disabled = true,
		}),
	})
end

local function Story()
	return React.createElement(React.Fragment, {}, {
		Regular = React.createElement(StoryItem, {
			LayoutOrder = 1,
		}),
		Arrows = React.createElement(StoryItem, {
			LayoutOrder = 2,
			Arrows = true,
		}),
		Slider = React.createElement(StoryItem, {
			LayoutOrder = 3,
			Slider = true,
		}),
		Both = React.createElement(StoryItem, {
			LayoutOrder = 4,
			Arrows = true,
			Slider = true,
		}),
	})
end

return createStory(Story)
