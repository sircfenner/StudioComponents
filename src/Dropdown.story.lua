local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Dropdown = require(script.Parent.Dropdown)

local words = string.split(
	"Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
	" "
)
table.insert(words, "Long final test dropdown option")

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		Item0 = "Lorem",
		Item1 = "dolor",
		Item2 = "sit",
		Item3 = "amet",
	})
end

function Wrapper:render()
	return Roact.createFragment({
		Layout = Roact.createElement("UIGridLayout", {
			CellPadding = UDim2.new(0, 10, 0, 10),
			CellSize = UDim2.new(0.3, 0, 0, 20),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			FillDirectionMaxCells = 2,
		}),

		Dropdown0 = Roact.createElement(Dropdown, {
			LayoutOrder = 0,
			Items = table.clone(words),
			SelectedItem = self.state.Item0,
			OnItemSelected = function(item)
				self:setState({ Item0 = item })
			end,
		}),

		Dropdown1 = Roact.createElement(Dropdown, {
			LayoutOrder = 1,
			Items = table.clone(words),
			SelectedItem = self.state.Item1,
			OnItemSelected = function(item)
				self:setState({ Item1 = item })
			end,
		}),

		Dropdown2 = Roact.createElement(Dropdown, {
			LayoutOrder = 2,
			Items = table.clone(words),
			SelectedItem = self.state.Item2,
			OnItemSelected = function(item)
				self:setState({ Item2 = item })
			end,
		}),

		Dropdown3 = Roact.createElement(Dropdown, {
			LayoutOrder = 3,
			Items = table.clone(words),
			SelectedItem = self.state.Item3,
			OnItemSelected = function(item)
				self:setState({ Item3 = item })
			end,
			Disabled = true,
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
