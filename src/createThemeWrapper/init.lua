--!strict
local RunService = game:GetService("RunService")
local IS_STUDIO = RunService:IsStudio()
local IS_RUNMODE = RunService:IsRunMode()

local Types = require(script.types)
export type Wrapper = Types.Wrapper

local function createIndexer(theme: StudioTheme, modifier): (color: Types.StudioStyleGuideColorStrings) -> Color3
	return function(color)
		-- Outside of studio, the enumeration doesn't exist.
		-- However, StudioTheme requires an enumeration to work. Strings error.
		if (IS_STUDIO and not IS_RUNMODE) and typeof(modifier) == "string" then
			modifier = (Enum.StudioStyleGuideModifier :: any)[modifier]
		end

		return theme:GetColor(color :: any, modifier)
	end
end

local function createWrapper(theme: StudioTheme): Types.Wrapper
	return {
		Default = createIndexer(theme, "Default"),
		Selected = createIndexer(theme, "Selected"),
		Pressed = createIndexer(theme, "Pressed"),
		Disabled = createIndexer(theme, "Disabled"),
		Hover = createIndexer(theme, "Hover"),
		GetColor = function(self, color, modifier)
			return theme:GetColor(color :: any, modifier :: any)
		end,
	}
end

return createWrapper
