local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local PluginProvider = require(script.Parent.PluginProvider)
local Panel = require(script.Parent.Panel)
local Label = require(script.Parent.Label)
local MainButton = require(script.Parent.MainButton)
local Background = require(script.Parent.Background)

local function Helper(_props, hooks)
	local opened, setOpened = hooks.useState(false)

	return Roact.createElement(Background, {}, {
		EnableButton = Roact.createElement(MainButton, {
			Text = if opened then "Close panel" else "Open panel",
			Size = UDim2.fromOffset(150, 25),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			OnActivated = function()
				setOpened(not opened)
			end,
		}),
		Panel = opened and Roact.createElement(Panel, {
			Title = "Message pop-up",
			MinimumWindowSize = Vector2.new(150, 50),
			InitalWindowSize = Vector2.new(150, 150),
			MaximumWindowSize = Vector2.new(250, 250),
			OnClosed = function()
				setOpened(false)
			end
		}, {
			Label = Roact.createElement(Label, {
				LayoutOrder = 0,
				Position = UDim2.new(0.5, -60, 0.5, -16),
				Size = UDim2.fromOffset(120, 32),
				Text = "Hello world!",
			}),
		}),
	})
end

Helper = Hooks.new(Roact)(Helper)

return function(target)
	local plugin = PluginManager():CreatePlugin()

	local element = Roact.createElement(PluginProvider, {
		Plugin = plugin,
	}, {
		Helper = Roact.createElement(Helper, {}),
	})

	local handle = Roact.mount(element, target)

	return function()
		Roact.unmount(handle)
	end
end
