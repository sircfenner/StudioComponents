--!strict
local RunService = game:GetService("RunService")
local IS_STUDIO = RunService:IsStudio()

local Types = require(script.types)
export type Wrapper = Types.Wrapper

local cache = setmetatable({}, { __mode = "k" })

local function createStyleWrapper(theme, style): Types.ColorStyleWrapper
	return setmetatable({}, {
		__index = function(_, modifier)
			-- Outside of studio, the enumeration doesn't exist.
			-- However, StudioTheme requires an enumeration to work. Strings error.
			if IS_STUDIO and typeof(modifier) == "string" then
				modifier = (Enum.StudioStyleGuideModifier :: any)[modifier]
			end

			return theme:GetColor(style, modifier)
		end,
		__call = function(_, modifier)
			return theme:GetColor(style, modifier)
		end,
	}) :: any
end

local function createWrapper(theme: any): Types.Wrapper
	if cache[theme] then
		return cache[theme]
	end

	cache[theme] = setmetatable({
		GetColor = function(self, colorStyle, modifierStyle)
			return theme:GetColor(colorStyle, modifierStyle)
		end,
	}, {
		__index = function(self, key)
			if theme:GetColor(key) then
				return createStyleWrapper(theme, key)
			end

			error("Invalid color: " .. key)
		end,
	}) :: any

	return cache[theme]
end

return createWrapper
