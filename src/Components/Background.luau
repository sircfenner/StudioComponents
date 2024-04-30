--[=[
	@class Background
	
	A borderless frame matching the default background color of Studio widgets.

	| Dark | Light |
	| - | - |
	| ![Dark](/components/background/dark.png) | ![Light](/components/background/light.png) |

	Any children passed will be parented to the frame, which makes it suitable for use as, 
	for example, the root component in a plugin Widget. For example:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.Background, {}, {
			MyChild = React.createElement(...),
		})
	end
	```
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local useTheme = require("../Hooks/useTheme")

--[=[
	@within Background
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field children React.ReactNode
]=]

type BackgroundProps = CommonProps.T & {
	children: React.ReactNode?,
}

local function Background(props: BackgroundProps)
	local theme = useTheme()
	return React.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
	}, props.children)
end

return Background
