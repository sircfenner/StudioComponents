local React = require("@pkg/@jsdotlua/react")

local Label = require("../Components/Label")
local createStory = require("./Helpers/createStory")

local styles = {
	Enum.StudioStyleGuideColor.MainText,
	Enum.StudioStyleGuideColor.SubText,
	Enum.StudioStyleGuideColor.TitlebarText,
	Enum.StudioStyleGuideColor.BrightText,
	Enum.StudioStyleGuideColor.DimmedText,
	Enum.StudioStyleGuideColor.ButtonText,
	Enum.StudioStyleGuideColor.LinkText,
	Enum.StudioStyleGuideColor.WarningText,
	Enum.StudioStyleGuideColor.ErrorText,
	Enum.StudioStyleGuideColor.InfoText,
}

local function StoryItem(props: {
	TextColorStyle: Enum.StudioStyleGuideColor,
	LayoutOrder: number,
})
	return React.createElement("Frame", {
		Size = UDim2.new(0, 170, 0, 40),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
	}, {
		Enabled = React.createElement(Label, {
			Text = props.TextColorStyle.Name,
			TextColorStyle = props.TextColorStyle,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 20),
		}),
		Disabled = React.createElement(Label, {
			Text = `{props.TextColorStyle.Name} (Disabled)`,
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 20),
			TextColorStyle = props.TextColorStyle,
			TextXAlignment = Enum.TextXAlignment.Center,
			Disabled = true,
		}),
	})
end

local function Story()
	local items = {}
	for i, style in styles do
		items[i] = React.createElement(StoryItem, {
			TextColorStyle = style,
			LayoutOrder = i,
		})
	end
	return React.createElement(React.Fragment, {}, items)
end

return createStory(Story)
