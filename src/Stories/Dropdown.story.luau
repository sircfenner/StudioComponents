local React = require("@pkg/@jsdotlua/react")

local Constants = require("../Constants")
local Dropdown = require("../Components/Dropdown")

local createStory = require("./Helpers/createStory")
local useTheme = require("../Hooks/useTheme")

local classNames = {
	"Part",
	"Script",
	"Player",
	"Folder",
	"Tool",
	"SpawnLocation",
	"MeshPart",
	"Model",
	"ClickDetector",
	"Decal",
	"ProximityPrompt",
	"SurfaceAppearance",
	"Texture",
	"Animation",
	"Accessory",
	"Humanoid",
}

-- hack to get themed class images
local function getClassImage(className: string, theme: StudioTheme)
	return `rbxasset://studio_svg_textures/Shared/InsertableObjects/{theme}/Standard/{className}.png`
end

local function StoryItem(props: {
	LayoutOrder: number,
	Disabled: boolean?,
})
	local theme = useTheme()

	local selectedClassName: string?, setSelectedClassName = React.useState(nil :: string?)
	local classes = {}
	for i, className in classNames do
		classes[i] = {
			Id = className,
			Text = className,
			Icon = {
				Image = getClassImage(className, theme),
				Size = Vector2.one * 16,
			},
		}
	end

	return React.createElement(Dropdown, {
		Size = UDim2.fromOffset(200, Constants.DefaultDropdownHeight),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Items = classes,
		SelectedItem = selectedClassName,
		OnItemSelected = function(newName: string?)
			setSelectedClassName(newName)
		end,
		DefaultText = "Select a Class...",
		MaxVisibleRows = 8,
		RowHeight = 24,
		ClearButton = true,
		Disabled = props.Disabled,
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
