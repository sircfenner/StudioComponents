local React = require("@pkg/@jsdotlua/react")

local NumberSequencePicker = require("../Components/NumberSequencePicker")
local createStory = require("./Helpers/createStory")

local function Story()
	local value, setValue = React.useState(NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 0.00),
		NumberSequenceKeypoint.new(0.4, 0.75, 0.10),
		NumberSequenceKeypoint.new(0.5, 0.45, 0.15),
		NumberSequenceKeypoint.new(0.8, 0.75),
		NumberSequenceKeypoint.new(1.0, 0.50),
	}))

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Picker = React.createElement(NumberSequencePicker, {
			Value = value,
			OnChanged = setValue,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		}),
	})
end

return createStory(Story)
