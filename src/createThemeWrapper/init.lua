--!strict
local RunService = game:GetService("RunService")
local IS_STUDIO = RunService:IsStudio()
local IS_RUNMODE = RunService:IsRunMode()

local ALLOWED_MODIFIERS = {
	Default = true,
	Selected = true,
	Pressed = true,
	Disabled = true,
	Hover = true,
}

local Types = require(script.types)
export type Wrapper = Types.Wrapper

local cache = setmetatable({}, { __mode = "k" })

local function createModifierWrapper(theme, modifier): Types.ModifierWrapper
	return setmetatable({}, {
		__index = function(_, style)
			-- Outside of studio, the enumeration doesn't exist.
			-- However, StudioTheme requires an enumeration to work. Strings error.
			if (IS_STUDIO and not IS_RUNMODE) and typeof(modifier) == "string" then
				modifier = (Enum.StudioStyleGuideModifier :: any)[modifier]
			end

			return theme:GetColor(style, modifier)
		end,
		__call = function(_, style)
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
			if ALLOWED_MODIFIERS[key] then
				return createModifierWrapper(theme, key)
			end

			error("Invalid modifier: " .. key)
		end,
	}) :: any

	return cache[theme]
end

return createWrapper
