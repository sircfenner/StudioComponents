local React = require("@pkg/@jsdotlua/react")

local LoadingDots = require("../Components/LoadingDots")
local createStory = require("./Helpers/createStory")

local function Story()
	return React.createElement(LoadingDots, {})
end

return createStory(Story)
