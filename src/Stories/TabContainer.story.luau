local React = require("@pkg/@jsdotlua/react")

local TabContainer = require("../Components/TabContainer")
local createStory = require("./Helpers/createStory")

local function StoryItemContent(props: {
	BackgroundColor3: Color3,
})
	return React.createElement("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = props.BackgroundColor3,
	})
end

local function StoryItem(props: {
	LayoutOrder: number,
	Disabled: boolean?,
})
	local selected, setSelected = React.useState("First")

	return React.createElement(TabContainer, {
		Size = UDim2.new(1, -50, 0.5, -50),
		LayoutOrder = props.LayoutOrder,
		SelectedTab = selected,
		OnTabSelected = setSelected,
		Disabled = props.Disabled,
	}, {
		First = {
			LayoutOrder = 1,
			Content = React.createElement(StoryItemContent, {
				BackgroundColor3 = Color3.fromRGB(255, 0, 255),
			}),
		},
		Second = {
			LayoutOrder = 2,
			Content = React.createElement(StoryItemContent, {
				BackgroundColor3 = Color3.fromRGB(255, 255, 0),
			}),
		},
		Third = {
			LayoutOrder = 3,
			Content = React.createElement(StoryItemContent, {
				BackgroundColor3 = Color3.fromRGB(0, 255, 255),
			}),
			Disabled = true,
		},
	})
end

local function Story()
	return React.createElement(React.Fragment, {}, {
		Enabled = React.createElement(StoryItem, {
			LayoutOrder = 1,
		}),
		Disabled = React.createElement(StoryItem, {
			LayoutOrder = 2,
			Disabled = true,
		}),
	})
end

return createStory(Story)
