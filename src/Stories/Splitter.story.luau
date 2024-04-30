local React = require("@pkg/@jsdotlua/react")

local Label = require("../Components/Label")
local Splitter = require("../Components/Splitter")
local createStory = require("./Helpers/createStory")
local useTheme = require("../Hooks/useTheme")

local function StoryItem(props: {
	Size: UDim2,
	LayoutOrder: number,
	Disabled: boolean?,
})
	local theme = useTheme()

	local alpha0, setAlpha0 = React.useState(0.5)
	local alpha1, setAlpha1 = React.useState(0.5)

	local postText = if props.Disabled then "\n(Disabled)" else ""

	return React.createElement("Frame", {
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		BorderMode = Enum.BorderMode.Inset,
	}, {
		Splitter = React.createElement(Splitter, {
			Alpha = alpha0,
			OnChanged = setAlpha0,
			FillDirection = Enum.FillDirection.Vertical,
			Disabled = props.Disabled,
		}, {
			Side0 = React.createElement(Label, {
				Text = "Top" .. postText,
				Disabled = props.Disabled,
			}),
			Side1 = React.createElement(Splitter, {
				Alpha = alpha1,
				OnChanged = setAlpha1,
				FillDirection = Enum.FillDirection.Horizontal,
				Disabled = props.Disabled,
			}, {
				Side0 = React.createElement(Label, {
					Text = "Bottom Left" .. postText,
					Disabled = props.Disabled,
				}),
				Side1 = React.createElement(Label, {
					Text = "Bottom Right" .. postText,
					Disabled = props.Disabled,
				}),
			}),
		}),
	})
end

local function Story()
	return React.createElement(React.Fragment, {}, {
		Enabled = React.createElement(StoryItem, {
			Size = UDim2.new(1, 0, 0.5, -5),
			LayoutOrder = 1,
		}),
		Disabled = React.createElement(StoryItem, {
			Size = UDim2.new(1, 0, 0.5, -5),
			LayoutOrder = 2,
			Disabled = true,
		}),
	})
end

return createStory(Story)
