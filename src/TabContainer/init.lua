local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)
local TabButton = require(script.TabButton)

local TAB_HEIGHT = 30

local function TabContainer(props, hooks)
	local theme = useTheme(hooks)

	local tabs = {}
	local selectedTabIndex
	for i, tab in ipairs(props.Tabs) do
		local isSelectedTab = props.SelectedTab == tab.Name
		if isSelectedTab then
			selectedTabIndex = i
		end
		tabs[i] = Roact.createElement(TabButton, {
			Size = UDim2.fromScale(1 / #props.Tabs, 1),
			LayoutOrder = i,
			Text = tab.Name,
			Selected = isSelectedTab,
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
			BridgeToSelected = selectedTabIndex and Roact.createElement("Frame", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				BorderSizePixel = 0,
				-- We do not want to cover the leftmost border-size in-between the tabs. Hence, subtracting one pixel (which is the width of the border).
				-- However, on the very end, we want to cover that border since there's no tabs to divide against.
				Size = UDim2.new(1 / #props.Tabs, if selectedTabIndex == #props.Tabs then 0 else -1, 0, 1),
				Position = UDim2.new(1 / #props.Tabs * (selectedTabIndex - 1), 0, 1, 0),
			}),
			TabsContainer = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				Tabs = Roact.createFragment(tabs),
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}),
			}),
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
