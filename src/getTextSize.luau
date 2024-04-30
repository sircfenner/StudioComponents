local TextService = game:GetService("TextService")

local Constants = require("./Constants")

local TEXT_SIZE = Constants.DefaultTextSize
local FONT = Constants.DefaultFont
local FRAME_SIZE = Vector2.one * math.huge

local function getTextSize(text: string)
	local size = TextService:GetTextSize(text, TEXT_SIZE, FONT, FRAME_SIZE)
	return Vector2.new(math.ceil(size.X), math.ceil(size.Y)) + Vector2.one
end

return getTextSize
