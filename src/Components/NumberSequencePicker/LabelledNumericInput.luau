local React = require("@pkg/@jsdotlua/react")

local Label = require("../Label")
local NumericInput = require("../NumericInput")
local TextInput = require("../TextInput")

local getTextSize = require("../../getTextSize")

local PADDING = 5
local INPUT_WIDTH = 40

local function format(n: number)
	return string.format(`%.3f`, n)
end

local noop = function() end

local function LabelledNumericInput(props: {
	Label: string,
	Value: number?,
	Disabled: boolean?,
	OnChanged: (value: number) -> (),
	OnSubmitted: (value: number) -> (),
	LayoutOrder: number,
	Min: number?,
	Max: number?,
})
	local textWidth = getTextSize(props.Label).X

	local input: React.ReactNode
	if props.Value and not props.Disabled then
		local value = props.Value :: number
		input = React.createElement(NumericInput, {
			Value = value,
			Min = props.Min,
			Max = props.Max,
			Step = 0,
			FormatValue = format,
			OnValidChanged = props.OnChanged,
			OnSubmitted = props.OnSubmitted,
		})
	else
		input = React.createElement(TextInput, {
			Text = if props.Value then format(props.Value) else "",
			OnChanged = noop,
			Disabled = true,
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.new(0, textWidth + INPUT_WIDTH + PADDING, 1, 0),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		Label = React.createElement(Label, {
			Size = UDim2.new(0, textWidth, 1, 0),
			Text = props.Label,
			Disabled = props.Value == nil,
		}),
		Input = React.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, INPUT_WIDTH, 1, 0),
			BackgroundTransparency = 1,
		}, input),
	})
end

return LabelledNumericInput
