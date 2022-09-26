local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local Dropdown = require(script.Parent.Dropdown)
--local ScrollFrame = require(script.Parent.ScrollFrame)

local words = string.split(
	"Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
	" "
)
table.insert(words, "Long final test dropdown option")

local Wrapper = Roact.Component:extend("Wrapper")

--[[
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
			Item = self.state.Item0,
			OnSelected = function(item)
				self:setState({ Item0 = item })
			end,
		}),

		Dropdown1 = Roact.createElement(Dropdown, {
			LayoutOrder = 1,
			Items = table.clone(words),
			Item = self.state.Item1,
			OnSelected = function(item)
				self:setState({ Item1 = item })
			end,
		}),

		Dropdown2 = Roact.createElement(Dropdown, {
			LayoutOrder = 2,
			Items = table.clone(words),
			Item = self.state.Item2,
			OnSelected = function(item)
				self:setState({ Item2 = item })
			end,
		}),

		Dropdown3 = Roact.createElement(Dropdown, {
			LayoutOrder = 3,
			Items = table.clone(words),
			Item = self.state.Item3,
			OnSelected = function(item)
				self:setState({ Item3 = item })
			end,
		}),
	})
end
--]]

--[[
local count = 20

function Wrapper:init()
	self:setState(table.create(count, words[1]))
end

function Wrapper:render()
	local items = table.create(count)
	for i = 1, count do
		items[i] = Roact.createElement(Dropdown, {
			LayoutOrder = i,
			Items = table.clone(words),
			Item = self.state[i],
			OnSelected = function(item)
				self:setState({ [i] = item })
			end,
		})
	end

	return Roact.createElement(ScrollFrame, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -200, 1, -200),
		Layout = {
			Padding = UDim.new(0, 5),
		},
	}, items)
end
]]

function Wrapper:init()
	self:setState({ Item = "Lorem" })
end

function Wrapper:render()
	return Roact.createElement(Dropdown, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Width = UDim.new(0, 200),
		Items = table.clone(words),
		Item = self.state.Item,
		MaxVisibleRows = 5,
		OnSelected = function(item)
			self:setState({ Item = item })
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
