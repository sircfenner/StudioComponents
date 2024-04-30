local React = require("@pkg/@jsdotlua/react")

local RadioButton = require("../Components/RadioButton")
local createStory = require("./Helpers/createStory")

local function Story()
	local value, setValue = React.useState(true)

	return React.createElement(React.Fragment, {}, {
		Enabled = React.createElement(RadioButton, {
			Label = "Enabled",
			Value = value,
			OnChanged = function()
				setValue(not value)
			end,
			LayoutOrder = 1,
		}),
		Disabled = React.createElement(RadioButton, {
			Label = "Disabled",
			Value = value,
			Disabled = true,
			LayoutOrder = 2,
		}),
	})
end

return createStory(Story)
