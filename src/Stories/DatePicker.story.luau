local React = require("@pkg/@jsdotlua/react")

local DatePicker = require("../Components/DatePicker")
local Label = require("../Components/Label")
local createStory = require("./Helpers/createStory")

local function Story()
	local date, setDate = React.useState(DateTime.now())

	return React.createElement(React.Fragment, {}, {
		Picker = React.createElement(DatePicker, {
			Date = date,
			OnChanged = setDate,
			LayoutOrder = 1,
		}),
		Display = React.createElement(Label, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 20),
			Text = `Selected: {date:FormatUniversalTime("LL", "en-us")}`,
		}),
	})
end

return createStory(Story)
