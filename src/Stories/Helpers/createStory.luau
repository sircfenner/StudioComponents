local React = require("@pkg/@jsdotlua/react")
local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

local PluginProvider = require("../../Components/PluginProvider")
local ScrollFrame = require("../../Components/ScrollFrame")
local ThemeContext = require("../../Contexts/ThemeContext")
local getStoryPlugin = require("./getStoryPlugin")

local themes = settings().Studio:GetAvailableThemes()
themes[1], themes[2] = themes[2], themes[1]

local function StoryTheme(props: {
	Theme: StudioTheme,
	Size: UDim2,
	LayoutOrder: number,
} & {
	children: React.ReactNode,
})
	return React.createElement("Frame", {
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		BackgroundColor3 = props.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		Provider = React.createElement(ThemeContext.Provider, {
			value = props.Theme,
		}, {
			Inner = React.createElement(ScrollFrame, {
				Layout = {
					ClassName = "UIListLayout",
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 10),
				},
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}, props.children),
		}),
	})
end

local function createStory(component: React.FC<any>)
	return function(target: Frame)
		local items: { React.ReactNode } = {}
		local order = 0
		local function getOrder()
			order += 1
			return order
		end
		for i, theme in themes do
			local widthOffset = if #themes > 2 and i == #themes then -1 else 0
			if i == 1 and #themes > 1 then
				widthOffset -= 1
			end
			table.insert(
				items,
				React.createElement(StoryTheme, {
					Theme = theme,
					Size = UDim2.new(1 / #themes, widthOffset, 1, 0),
					LayoutOrder = getOrder(),
				}, React.createElement(component))
			)
			-- invisible divider to prevent scrollframe edges overlapping as
			-- they have default borders (outside, not inset)
			if i < #themes then
				table.insert(
					items,
					React.createElement("Frame", {
						Size = UDim2.new(0, 2, 1, 0),
						BackgroundTransparency = 1,
						LayoutOrder = getOrder(),
					})
				)
			end
		end

		local element = React.createElement(PluginProvider, {
			Plugin = getStoryPlugin(),
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			Padding = React.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 45), -- tray buttons
			}),
		}, items)

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		local portal = ReactRoblox.createPortal(element, target)
		root:render(portal)
		return function()
			root:unmount()
		end
	end
end

return createStory
