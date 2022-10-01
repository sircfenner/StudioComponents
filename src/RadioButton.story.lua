local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local RadioButton = require(script.Parent.RadioButton)
local ThemeContext = require(script.Parent.ThemeContext)
local Background = require(script.Parent.Background)

local themes = settings().Studio:GetAvailableThemes()

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		LightSelected = 1,
		DarkSelected = 2,
	})
end

function Wrapper:render()
	local count = 3

	local buttonsLight = {}
	for i = 1, count do
		buttonsLight[i] = Roact.createElement(RadioButton, {
			LayoutOrder = i,
			Value = self.state.LightSelected == i,
			Label = "Button" .. tostring(i),
			OnActivated = function()
				self:setState({ LightSelected = i })
			end,
		})
	end

	local buttonsDark = {}
	for i = 1, count do
		buttonsDark[i] = Roact.createElement(RadioButton, {
			LayoutOrder = i,
			Value = self.state.DarkSelected == i,
			Label = "Button" .. tostring(i),
			OnActivated = function()
				self:setState({ DarkSelected = i })
			end,
		})
	end

	return Roact.createFragment({
		Light = Roact.createElement(ThemeContext.Provider, {
			value = themes[1],
		}, {
			Background = Roact.createElement(Background, {
				Size = UDim2.fromScale(0.5, 1),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Buttons = Roact.createFragment(buttonsLight),
			}),
		}),
		Dark = Roact.createElement(ThemeContext.Provider, {
			value = themes[2],
		}, {
			Background = Roact.createElement(Background, {
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.5, 0),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Buttons = Roact.createFragment(buttonsDark),
			}),
		}),
	})
end

return function(target)
	local element = Roact.createElement(Wrapper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
