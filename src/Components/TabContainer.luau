--[=[
	@class TabContainer

	A container that displays one content page at a time, where different pages can be selected
	via a set of tabs along the top. This is seen in some built-in plugins such as the Toolbox.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/tabcontainer/dark.png) | ![Light](/StudioComponents/components/tabcontainer/light.png) |

	This is a controlled component. The identifier of the selected tab should be passed to the
	`SelectedTab` prop, and a callback should be passed to the `OnTabSelected` prop which is run 
	when the user selects a tab from the tab controls along the top.

	The content rendered in each tab's main window should be passed to the `children` parameters in
	`createElement` in the [format](TabContainer#Tab) described below. The keys are used as tab names 
	in the tab controls along the top and should also correspond to the identifier in `SelectedTab` 
	and	the identifiers that `OnTabSelected` prop may be called with. For example:

	```lua
	local function MyComponent()
		local selectedTab, setSelectedTab = React.useState("Models")
		return React.createElement(TabContainer, {
			SelectedTab = selectedTab,
			OnTabSelected = setSelectedTab,
		}, {
			["Models"] = {
				LayoutOrder = 1,
				Content = React.createElement(...),
			},
			["Decals"] = {
				LayoutOrder = 2,
				Content = React.createElement(...),
			}
		})
	end
	```

	As well as disabling the entire component via the `Disabled` [CommonProp](CommonProps), individual
	tabs can be disabled and made unselectable by passing `Disabled` with a value of `true` inside
	the tab's entry in the `Tabs` prop table.

	:::info
	The various tab containers found in Studio are inconsistent with each other (for example, Toolbox
	and Terrain Editor use different sizes, colors, and highlights). This design of this component
	uses the common elements of those designs and has small tweaks to stay consistent with the wider
	design of Studio elements.
	:::
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local useTheme = require("../Hooks/useTheme")

local TAB_HEIGHT = 30

--[=[
	@within TabContainer
	@interface Tab

	@field LayoutOrder number
	@field Content React.ReactNode
	@field Disabled boolean?
]=]

type Tab = {
	Content: React.ReactNode,
	LayoutOrder: number,
	Disabled: boolean?,
}

--[=[
	@within TabContainer
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field SelectedTab string
	@field OnTabSelected ((name: string) -> ())?
	@field children { [string]: Tab }
]=]

type TabContainerProps = CommonProps.T & {
	SelectedTab: string,
	OnTabSelected: ((name: string) -> ())?,
	children: { [string]: Tab }?,
}

local function TabButton(props: {
	Size: UDim2,
	Text: string,
	LayoutOrder: number,
	Selected: boolean,
	OnActivated: () -> (),
	Disabled: boolean?,
})
	local theme = useTheme()

	local hovered, setHovered = React.useState(false)
	local pressed, setPressed = React.useState(false)

	local onInputBegan = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setPressed(true)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		end
	end

	local onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setPressed(false)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
	end

	local backgroundStyle = Enum.StudioStyleGuideColor.Button
	if props.Selected then
		backgroundStyle = Enum.StudioStyleGuideColor.MainBackground
	elseif pressed and not props.Disabled then
		backgroundStyle = Enum.StudioStyleGuideColor.ButtonBorder
	end

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local indicatorModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		indicatorModifier = Enum.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme:GetColor(backgroundStyle, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		Text = props.Text,
		Font = Enum.Font.SourceSans,
		TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 14,
		[React.Event.InputBegan] = onInputBegan,
		[React.Event.InputEnded] = onInputEnded,
		[React.Event.Activated] = function()
			if not props.Disabled then
				props.OnActivated()
			end
		end,
	}, {
		Indicator = props.Selected and React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton, indicatorModifier),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2),
		}),
		Under = props.Selected and React.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(backgroundStyle, modifier),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromScale(0, 1),
		}),
	})
end

local function TabContainer(props: TabContainerProps)
	local theme = useTheme()

	local children = props.children :: { [string]: Tab }
	local tabs: { [string]: React.ReactNode } = {}
	local count = 0
	for _ in children do
		count += 1
	end

	for name, tab in children do
		local isSelectedTab = props.SelectedTab == name
		tabs[name] = React.createElement(TabButton, {
			Size = UDim2.fromScale(1 / count, 1),
			LayoutOrder = tab.LayoutOrder,
			Text = name,
			Selected = isSelectedTab,
			Disabled = tab.Disabled == true or props.Disabled == true,
			OnActivated = function()
				if props.OnTabSelected then
					props.OnTabSelected(name)
				end
			end,
		})
	end

	local tab = children[props.SelectedTab]
	local content = if tab then tab.Content else nil

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
	}, {
		Top = React.createElement("Frame", {
			ZIndex = 2,
			Size = UDim2.new(1, 0, 0, TAB_HEIGHT),
			BackgroundTransparency = 1,
		}, {
			TabsContainer = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}),
			}, tabs),
		}),
		Content = React.createElement("Frame", {
			ZIndex = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, -TAB_HEIGHT - 1), -- extra px for outer border
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, content),
	})
end

return TabContainer
