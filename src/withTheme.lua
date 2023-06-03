local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local createThemeWrapper = require(script.Parent.createThemeWrapper)

local StudioThemeProvider = Roact.Component:extend("StudioThemeProvider")
local studioSettings = settings().Studio

function StudioThemeProvider:init()
	self:setState({ studioTheme = createThemeWrapper(studioSettings.Theme) })

	self._changed = studioSettings.ThemeChanged:Connect(function()
		self:setState({ studioTheme = createThemeWrapper(studioSettings.Theme) })
	end)
end

function StudioThemeProvider:willUnmount()
	self._changed:Disconnect()
end

function StudioThemeProvider:render()
	local render = Roact.oneChild(self.props[Roact.Children])

	return Roact.createElement(ThemeContext.Provider, {
		value = self.state.studioTheme,
	}, {
		Consumer = Roact.createElement(ThemeContext.Consumer, {
			render = render,
		}),
	})
end

local function withTheme(render: (theme: createThemeWrapper.Wrapper) -> any)
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			if theme then
				return render(theme)
			else
				return Roact.createElement(StudioThemeProvider, {}, {
					render = render,
				})
			end
		end,
	})
end

return withTheme
