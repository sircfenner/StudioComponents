local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local StudioThemeProvider = Roact.Component:extend("StudioThemeProvider")
local studioSettings = settings().Studio

function StudioThemeProvider:init()
	self:setState({ theme = studioSettings.Theme })
	self._changed = studioSettings.ThemeChanged:Connect(function()
		self:setState({ theme = studioSettings.Theme })
	end)
end

function StudioThemeProvider:willUnmount()
	self._changed:Disconnect()
end

function StudioThemeProvider:render()
	local render = Roact.oneChild(self.props[Roact.Children])
	return render(self.state.theme)
end

local function withTheme(render)
	return Roact.createElement(StudioThemeProvider, {}, {
		render = render,
	})
end

return withTheme
