local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local TabContainer = require(script.Parent.TabContainer)

local Label = require(script.Parent.Label)
local Button = require(script.Parent.Button)
local TextInput = require(script.Parent.TextInput)

local function Centered(props)
	return Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Child = Roact.oneChild(props[Roact.Children]),
	})
end

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		SelectedTab = "Label",
	})
end

function Wrapper:render()
	return Roact.createElement(TabContainer, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -100, 1, -150),
		Tabs = {
			{
				Name = "Label",
				Content = Roact.createElement(Centered, {}, {
					Label = Roact.createElement(Label, {
						Text = "Label",
					}),
				}),
			},
			{
				Name = "Button",
				Content = Roact.createElement(Centered, {}, {
					Button = Roact.createElement(Button, {
						Size = UDim2.fromOffset(100, 30),
						Text = "Button",
						OnActivated = function() end,
					}),
				}),
			},
			{
				Name = "TextInput",
				Content = Roact.createElement(Centered, {}, {
					TextInput = Roact.createElement(TextInput, {
						Size = UDim2.fromOffset(100, 21),
						OnChanged = function() end,
						PlaceholderText = "Placeholder",
					}),
				}),
			},
			{
				Name = "Disabled",
				Disabled = true,
			},
		},
		SelectedTab = self.state.SelectedTab,
		OnTabSelected = function(tab)
			self:setState({ SelectedTab = tab })
		end,
	})
end

return function(target)
	local element = Roact.createElement(Wrapper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
