--[=[
	@class TextInput

	A basic input field for entering any kind of text. This matches the appearance of the search
	boxes in the Explorer and Properties widgets, among other inputs in Studio.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/textinput/dark.png) | ![Light](/StudioComponents/components/textinput/light.png) |

	This is a controlled component, which means the current text should be passed in to the
	`Text` prop and a callback value to the `OnChanged` prop which gets run when the user attempts 
	types in the input field. For example:

	```lua
	local function MyComponent()
		local text, setText = React.useState("")
		return React.createElement(StudioComponents.TextInput, {
			Text = text,
			OnChanged = setText,
		})
	end
	```

	This allows complete control over the text displayed and keeps the source of truth in your own
	code. This is helpful for consistency and controlling the state from elsewhere in the tree. It
	also allows you to easily filter what can be typed into the text input. For example, to only
	permit entering lowercase letters:

	```lua
	local function MyComponent()
		local text, setText = React.useState("")
		return React.createElement(StudioComponents.TextInput, {
			Text = text,
			OnChanged = function(newText),
				local filteredText = string.gsub(newText, "[^a-z]", "")
				setText(filteredText)
			end,
		})
	end
	```

	By default, the height of this component is equal to the value in [Constants.DefaultInputHeight].
	While this can be overriden by props, in order to keep inputs accessible it is not recommended 
	to make the component any smaller than this.
]=]

local React = require("@pkg/@jsdotlua/react")

local BaseTextInput = require("./Foundation/BaseTextInput")
local Constants = require("../Constants")

--[=[
	@within TextInput
	@interface Props
	@tag Component Props

	@field ... CommonProps

	@field Text string
	@field OnChanged ((newText: string) -> ())?

	@field PlaceholderText string?
	@field ClearTextOnFocus boolean?
	@field OnFocused (() -> ())?
	@field OnFocusLost ((text: string, enterPressed: boolean, input: InputObject) -> ())?
]=]

type TextInputProps = BaseTextInput.BaseTextInputConsumerProps & {
	Text: string,
	OnChanged: ((newText: string) -> ())?,
}

local function TextInput(props: TextInputProps)
	return React.createElement(BaseTextInput, {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.new(1, 0, 0, Constants.DefaultInputHeight),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Disabled = props.Disabled,
		Text = props.Text,
		PlaceholderText = props.PlaceholderText,
		ClearTextOnFocus = props.ClearTextOnFocus,
		OnFocused = props.OnFocused,
		OnFocusLost = props.OnFocusLost,
		OnChanged = props.OnChanged or function() end,
	}, props.children)
end

return TextInput
