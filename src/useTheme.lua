local ThemeContext = require(script.Parent.ThemeContext)
local studio = settings().Studio

local function useTheme(hooks)
	local theme = hooks.useContext(ThemeContext)
	local studioTheme, setStudioTheme = hooks.useState(studio.Theme)

	hooks.useEffect(function()
		if theme then return end
		local connection = studio.ThemeChanged:Connect(function()
			setStudioTheme(studio.Theme)
		end)
		return function()
			connection:Disconnect()
		end
	end, { theme, studioTheme })

	return theme or studioTheme
end

return useTheme
