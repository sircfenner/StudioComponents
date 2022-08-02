local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local StudioThemeProvider = Roact.Component:extend("StudioThemeProvider")
local studioSettings = settings().Studio

function StudioThemeProvider:init()
	local theme = self:GetContext(ThemeContext)
	self:setState({ studioTheme = studioSettings.Theme })

	if theme == nil then
		self._changed = studioSettings.ThemeChanged:Connect(function()
			self:setState({ studioTheme = studioSettings.Theme })
		end)
	end
end

function StudioThemeProvider:willUnmount()
	if self._changed then
		self._changed:Disconnect()
	end
end

function StudioThemeProvider:willUpdate()
	local theme = self:GetContext(ThemeContext)
	if theme and self._changed then
		self._changed:Disconnect()
		self._changed = nil
	elseif theme == nil then
		self._changed = studioSettings.ThemeChanged:Connect(function()
			self:setState({ studioTheme = studioSettings.Theme })
		end)

		task.defer(self.setState, self, { studioTheme = studioSettings.Theme })
	end
end

function StudioThemeProvider:render()
	local theme = self:GetContext(ThemeContext)
	local render = Roact.oneChild(self.props[Roact.Children])

	if theme then
		return render(theme)
	else
		return Roact.createElement(ThemeContext.Provider, {
			value = self.state.studioTheme,
		}, {
			Consumer = Roact.createElement(ThemeContext.Consumer, {
				render = render,
			}),
		})
	end
end

-- https://github.com/Kampfkarren/roact-hooks/blob/main/src/createUseContext.lua
function StudioThemeProvider:GetContext(targetContext)
	local contextValue = nil

	local fakeConsumer = setmetatable({
		props = {
			render = function(value)
				contextValue = value
			end,
		},
	}, {
		__index = self,
	})

	targetContext.Consumer.init(fakeConsumer)

	return contextValue
end

local function withTheme(render)
	return Roact.createElement(StudioThemeProvider, {}, {
		render = render,
	})
end

return withTheme
