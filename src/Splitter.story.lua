local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Constants = require(script.Parent.Constants)

local Splitter = require(script.Parent.Splitter)
local PluginProvider = require(script.Parent.PluginProvider)

local Label = require(script.Parent.Label)
local ScrollFrame = require(script.Parent.ScrollFrame)
local Dropdown = require(script.Parent.Dropdown)

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		Alpha0 = 0.5,
		Alpha1 = 0.5,
		Alpha2 = 0.5,
	})
end

function Wrapper:render()
	local scrollContents = {}
	for i = 1, 20 do
		scrollContents[i] = Roact.createElement(Label, {
			Size = UDim2.new(1, 0, 0, 20),
			Text = "Item " .. i,
			LayoutOrder = i,
		})
	end

	return Roact.createElement(Splitter, {
		Alpha = self.state.Alpha0,
		OnAlphaChanged = function(newAlpha)
			self:setState({ Alpha0 = newAlpha })
		end,
		Orientation = Constants.SplitterOrientation.Vertical,
	}, {
		[1] = Roact.createElement(ScrollFrame, {
			Size = UDim2.fromScale(1, 1),
		}, scrollContents),
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
			[2] = Roact.createElement(Dropdown, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Width = UDim.new(0.4, 50),
				SelectedItem = "Test",
				Items = { "Test", "Example", "Placeholder", "Dummy", "Sample" },
				OnItemSelected = function() end,
			}),
		}),
	})
end

return function(target)
	-- hoarcekat does not provide a way to access its plugin instance
	-- this is a little hacky but acceptable since it's purely for the story
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
