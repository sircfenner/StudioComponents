local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Constants = require(script.Parent.Constants)
local Splitter = require(script.Parent.Splitter)

local PluginProvider = require(script.Parent.PluginProvider)
local Label = require(script.Parent.Label)

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		Alpha0 = 0.5,
		Alpha1 = 0.5,
		Alpha2 = 0.5,
	})
end

function Wrapper:render()
	return Roact.createElement(Splitter, {
		Alpha = self.state.Alpha0,
		OnAlphaChanged = function(newAlpha)
			self:setState({ Alpha0 = newAlpha })
		end,
		Orientation = Constants.SplitterOrientation.Vertical,
	}, {
		[1] = Roact.createElement(Label, {
			Size = UDim2.fromScale(1, 1),
			Text = "Side 1",
		}),
		[2] = Roact.createElement(Splitter, {
			Alpha = self.state.Alpha1,
			OnAlphaChanged = function(newAlpha)
				self:setState({ Alpha1 = newAlpha })
			end,
			Orientation = Constants.SplitterOrientation.Horizontal,
		}, {
			[1] = Roact.createElement(Splitter, {
				Alpha = self.state.Alpha2,
				OnAlphaChanged = function(newAlpha)
					self:setState({ Alpha2 = newAlpha })
				end,
				Orientation = Constants.SplitterOrientation.Vertical,
				Disabled = true,
			}, {
				[1] = Roact.createElement(Label, {
					Size = UDim2.fromScale(1, 1),
					Text = "Side 2(1)(1)",
				}),
				[2] = Roact.createElement(Label, {
					Size = UDim2.fromScale(1, 1),
					Text = "Side 2(1)(2)",
				}),
			}),
			[2] = Roact.createElement(Label, {
				Size = UDim2.fromScale(1, 1),
				Text = "Side 2(2)",
			}),
		}),
	})
end

return function(target)
	-- NB: hoarcekat does not provide a way to access its plugin instance
	-- selene: allow(undefined_variable)
	local plugin = PluginManager():CreatePlugin()
	local element = Roact.createElement(PluginProvider, {
		Plugin = plugin,
	}, {
		Main = Roact.createElement(Wrapper),
	})
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
