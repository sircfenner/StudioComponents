local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)
local TabButton = require(script.TabButton)

local TAB_HEIGHT = 30

local function TabContainer(props, hooks)
	local theme = useTheme(hooks)

	local tabs = {}
	for i, tab in ipairs(props.Tabs) do
		tabs[i] = Roact.createElement(TabButton, {
			Size = UDim2.fromScale(1 / #props.Tabs, 1),
			LayoutOrder = i,
			Text = tab.Name,
			Selected = props.SelectedTab == tab.Name,
			Disabled = tab.Disabled,
			OnActivated = function()
				props.OnTabSelected(tab.Name)
			end,
		})
	end

	local page = nil
	for _, tab in ipairs(props.Tabs) do
		if tab.Name == props.SelectedTab then
			page = tab.Content
			break
		end
	end

	return Roact.createElement("Frame", {
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = props.ZIndex or 1,
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
	}, {
		Top = Roact.createElement("Frame", {
			ZIndex = 2,
			Size = UDim2.new(1, 0, 0, TAB_HEIGHT),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			Tabs = Roact.createFragment(tabs),
		}),
		Content = Roact.createElement("Frame", {
			ZIndex = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, -TAB_HEIGHT - 1), -- extra px for outer border
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			Page = page,
		}),
	})
end

return Hooks.new(Roact)(TabContainer)
