local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local TabContainer = require(script.Parent.TabContainer)

local function TempContent(props)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, -50, 1, -50),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = props.Color,
	})
end

local Wrapper = Roact.Component:extend("Wrapper")

function Wrapper:init()
	self:setState({
		SelectedTab = nil,
	})
end

function Wrapper:render()
	return Roact.createElement(TabContainer, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -100, 1, -150),
		Tabs = {
			{
				Name = "Red",
				Content = Roact.createElement(TempContent, { Color = Color3.fromRGB(255, 0, 0) }),
			},
			{
				Name = "Green",
				Content = Roact.createElement(TempContent, { Color = Color3.fromRGB(0, 255, 0) }),
			},
			{
				Name = "Blue",
				Content = Roact.createElement(TempContent, { Color = Color3.fromRGB(0, 0, 255) }),
			},
			{
				Name = "Yellow",
				Content = Roact.createElement(TempContent, { Color = Color3.fromRGB(255, 255, 0) }),
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
