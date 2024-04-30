--[=[
	@class DropShadowFrame

	A container frame equivalent in appearance to a [Background] with a 
	drop shadow in the lower right sides and corner.
	This matches the appearance of some built-in Roblox Studio elements such as tooltips.
	It is useful for providing contrast against a background.

	| Dark | Light |
	| - | - |
	| ![Dark](/components/dropshadowframe/dark.png) | ![Light](/components/dropshadowframe/light.png) |

	Any children passed will be parented to the container frame. For example:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.DropShadowFrame, {}, {
			MyLabel = React.createElement(StudioComponents.Label, ...),
			MyCheckbox = React.createElement(StudioComponents.Checkbox, ...),
		})
	end
	```
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local useTheme = require("../Hooks/useTheme")

local shadowData = {
	{
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, 1, 1, 1),
		Radius = 5,
		Transparency = 0.96,
	},
	{
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		Radius = 4,
		Transparency = 0.88,
	},
	{
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		Radius = 3,
		Transparency = 0.80,
	},
	{
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		Radius = 2,
		Transparency = 0.77,
	},
}

--[=[
	@within DropShadowFrame
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field children React.ReactNode
]=]

type DropShadowFrameProps = CommonProps.T & {
	children: React.ReactNode,
}

local function DropShadowFrame(props: DropShadowFrameProps)
	local theme = useTheme()

	local shadow
	for i = #shadowData, 1, -1 do
		local data = shadowData[i]
		shadow = React.createElement("Frame", {
			Position = data.Position,
			Size = data.Size,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DropShadow),
			BackgroundTransparency = data.Transparency,
			BorderSizePixel = 0,
			ZIndex = 0,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, data.Radius),
			}),
		}, shadow)
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
	}, {
		Shadow = not props.Disabled and shadow,
		Content = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			ZIndex = 1,
		}, props.children),
	})
end

return DropShadowFrame
