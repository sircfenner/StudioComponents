local React = require("@pkg/@jsdotlua/react")

local Background = require("../Components/Background")
local createStory = require("./Helpers/createStory")

local function Story()
	return React.createElement(Background)
end

return createStory(Story)
