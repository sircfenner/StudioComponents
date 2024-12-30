local React = require("@pkg/@jsdotlua/react")

local Button = require("../Components/Button")
local createStory = require("./Helpers/createStory")

local function StoryButton(props: {
	Text: string?,
	HasIcon: boolean?,
	Disabled: boolean?,
})
	return React.createElement(Button, {
		LayoutOrder = if props.Disabled then 2 else 1,
		Icon = props.HasIcon and {
			--Image = "rbxasset://studio_svg_textures/Shared/InsertableObjects/Dark/Standard/Part.png",
			Image = "rbxassetid://18786011824",
			Size = Vector2.new(16, 16),
			Alignment = Enum.HorizontalAlignment.Left,
			RectOffset = Vector2.new(1000, 0),
			RectSize = Vector2.new(16, 16),
		} :: any,
		Text = props.Text,
		OnActivated = if not props.Disabled then function() end else nil,
		Disabled = props.Disabled,
		AutomaticSize = Enum.AutomaticSize.XY,
	})
end

local function StoryItem(props: {
	LayoutOrder: number,
	Text: string?,
	HasIcon: boolean?,
	Disabled: boolean?,
})
	local height, setHeight = React.useBinding(0)

	return React.createElement("Frame", {
		Size = height:map(function(value)
			return UDim2.new(1, 0, 0, value)
		end),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			[React.Change.AbsoluteContentSize] = function(rbx)
				setHeight(rbx.AbsoluteContentSize.Y)
			end,
		}),
		Enabled = React.createElement(StoryButton, {
			Text = props.Text,
			HasIcon = props.HasIcon,
		}),
		Disabled = React.createElement(StoryButton, {
			Text = props.Text,
			HasIcon = props.HasIcon,
			Disabled = true,
		}),
	})
end

local function Story()
	return React.createElement(React.Fragment, {}, {
		Icon = React.createElement(StoryItem, {
			LayoutOrder = 1,
			HasIcon = true,
		}),
		Text = React.createElement(StoryItem, {
			LayoutOrder = 2,
			Text = "Example Text",
		}),
		TextLonger = React.createElement(StoryItem, {
			LayoutOrder = 3,
			Text = "Example Longer Text",
		}),
		TextMulti = React.createElement(StoryItem, {
			LayoutOrder = 4,
			Text = "Example Text\nover two lines",
		}),
		IconTextIcon = React.createElement(StoryItem, {
			LayoutOrder = 5,
			HasIcon = true,
			Text = "Example Text with Icon",
		}),
	})
end

return createStory(Story)
