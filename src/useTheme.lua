local ThemeContext = require(script.Parent.ThemeContext)
local createThemeWrapper = require(script.Parent.createThemeWrapper)

local studio = settings().Studio

local function useTheme(hooks)
	local theme = hooks.useContext(ThemeContext)
	local studioTheme, setStudioTheme = hooks.useState(createThemeWrapper(studio.Theme))

	hooks.useEffect(function()
		if theme then
			return
		end

		local connection = studio.ThemeChanged:Connect(function()
			setStudioTheme(createThemeWrapper(studio.Theme))
		end)

		return function()
			connection:Disconnect()
		end
	end, { theme })

	return (theme or studioTheme) :: createThemeWrapper.Wrapper
end

return useTheme
