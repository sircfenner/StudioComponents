--[=[
	@class Button
	A basic button that supports text, an icon, or both. This should be used as a standalone button
	or as a secondary button alongside a [MainButton] for the primary action in a group of options.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/button/dark.png) | ![Light](/StudioComponents/components/button/light.png) |

	The `OnActivated` prop should be a callback which is run when the button is clicked.
	For example:
	
	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.Button, {
			Text = "Click Me",
			OnActivated = function()
				print("Button clicked!")
			end
		})
	end
	```

	The default size of buttons can be found in [Constants.DefaultButtonHeight]. To override this,
	there are two main options, which may be combined:
	1. Pass a `Size` prop.
	2. Pass an `AutomaticSize` prop.

	AutomaticSize is a simpler version of Roblox's built-in AutomaticSize system. Passing a value of
	`Enum.AutomaticSize.X` will override the button's width to fit the text and/or icon. Passing a
	value of `Enum.AutomaticSize.Y` will do the same but with the button's height. Passing
	`Enum.AutomaticSize.XY` will override both axes.
]=]

local React = require("@pkg/@jsdotlua/react")

local BaseButton = require("./Foundation/BaseButton")

--[=[
	@within Button
	@interface IconProps

	@field Image string
	@field Size Vector2
	@field Transparency number?
	@field Color Color3?
	@field UseThemeColor boolean?
	@field Alignment HorizontalAlignment?
	@field ResampleMode Enum.ResamplerMode?
	@field RectOffset Vector2?
	@field RectSize Vector2?

	The `Alignment` prop is used to configure which side of any text the icon 
	appears on.	Left-alignment is the default and center-alignment is not supported.

	When specifying icon color, at most one of `Color` and `UseThemeColor` should be specified.
]=]

--[=[
	@within Button
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field AutomaticSize AutomaticSize?
	@field OnActivated (() -> ())?
	@field Text string?
	@field Icon IconProps?
]=]

local function Button(props: BaseButton.BaseButtonConsumerProps)
	local merged = table.clone(props) :: BaseButton.BaseButtonProps
	merged.BackgroundColorStyle = Enum.StudioStyleGuideColor.Button
	merged.BorderColorStyle = Enum.StudioStyleGuideColor.ButtonBorder
	merged.TextColorStyle = Enum.StudioStyleGuideColor.ButtonText

	return React.createElement(BaseButton, merged)
end

return Button
