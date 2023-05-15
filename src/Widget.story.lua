local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local PluginProvider = require(script.Parent.PluginProvider)
local Button = require(script.Parent.Button)
local Widget = require(script.Parent.Widget)

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		Enabled = false,
	})
end

function Wrapper:render()
	return Roact.createFragment({
		Button = Roact.createElement(Button, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(120, 30),
			Text = self.state.Enabled and "Close Widget" or "Open Widget",
			OnActivated = function()
				self:setState({ Enabled = not self.state.Enabled })
			end,
		}),
		Widget = self.state.Enabled and Roact.createElement(Widget, {
			Id = "_unique1012",
			OnClosed = function()
				self:setState({ Enabled = false })
			end,
		}),
	})
end

return function(target)
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
