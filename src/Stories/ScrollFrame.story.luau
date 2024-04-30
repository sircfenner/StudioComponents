local React = require("@pkg/@jsdotlua/react")

local Constants = require("../Constants")
local ScrollFrame = require("../Components/ScrollFrame")
local createStory = require("./Helpers/createStory")

local numRows = 10
local numCols = 10

local size = Vector2.new(48, 32)

local function StoryRow(props: {
	Row: number,
})
	local children = {}
	for i = 1, numCols do
		children[i] = React.createElement("TextLabel", {
			LayoutOrder = i,
			Text = string.format("%i,%i", i - 1, props.Row - 1),
			Font = Constants.DefaultFont,
			TextSize = Constants.DefaultTextSize,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(0, size.X, 1, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromHSV((i + props.Row) % numCols / numCols, 0.6, 0.8),
		})
	end
	return React.createElement("Frame", {
		LayoutOrder = props.Row,
		Size = UDim2.fromOffset(numCols * size.X, size.Y),
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}, children)
end

local function StoryScroller(props: {
	Size: UDim2,
	LayoutOrder: number,
	Disabled: boolean?,
})
	local rows = {}
	for i = 1, numRows do
		rows[i] = React.createElement(StoryRow, { Row = i })
	end

	return React.createElement(ScrollFrame, {
		ScrollingDirection = Enum.ScrollingDirection.XY,
		Size = props.Size,
		Disabled = props.Disabled,
		Layout = {
			ClassName = "UIListLayout",
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	}, rows)
end

local function Story()
	return React.createElement(React.Fragment, {}, {
		Enabled = React.createElement(StoryScroller, {
			Size = UDim2.new(1, -10, 0, 220),
			LayoutOrder = 1,
		}),
		Disabled = React.createElement(StoryScroller, {
			Size = UDim2.new(1, -10, 0, 220),
			LayoutOrder = 2,
			Disabled = true,
		}),
	})
end

return createStory(Story)
