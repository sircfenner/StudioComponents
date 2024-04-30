local React = require("@pkg/@jsdotlua/react")

local ProgressBar = require("../Components/ProgressBar")
local createStory = require("./Helpers/createStory")

local HEIGHT = 14

local function StoryItem(props: {
	Value: number,
	Max: number?,
	Formatter: ((number, number) -> string)?,
	LayoutOrder: number,
})
	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, HEIGHT),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
	}, {
		Enabled = React.createElement(ProgressBar, {
			Value = props.Value,
			Max = props.Max,
			Formatter = props.Formatter,
			--Size = UDim2.new(0.5, -5, 1, 0),
			Size = UDim2.new(0, 225, 1, 0),
			Position = UDim2.fromOffset(20, 0),
		}),
		-- Disabled = React.createElement(ProgressBar, {
		-- 	Value = props.Value,
		-- 	Max = props.Max,
		-- 	Formatter = props.Formatter,
		-- 	AnchorPoint = Vector2.new(1, 0),
		-- 	Position = UDim2.fromScale(1, 0),
		-- 	Size = UDim2.new(0.5, -5, 1, 0),
		-- 	Disabled = true,
		-- }),
	})
end

local function Story()
	return React.createElement(React.Fragment, {}, {
		Zero = React.createElement(StoryItem, {
			Value = 0,
			LayoutOrder = 1,
		}),
		Fifty = React.createElement(StoryItem, {
			Value = 0.5,
			LayoutOrder = 1,
		}),
		Hundred = React.createElement(StoryItem, {
			Value = 1,
			LayoutOrder = 2,
		}),
		Custom = React.createElement(StoryItem, {
			Value = 5,
			Max = 14,
			LayoutOrder = 3,
			Formatter = function(value, max)
				return `loaded {value} / {max} assets`
			end,
		}),
	})
end

return createStory(Story)
