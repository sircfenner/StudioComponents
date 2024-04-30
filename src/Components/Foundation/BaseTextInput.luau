local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../../CommonProps")
local Constants = require("../../Constants")

local getTextSize = require("../../getTextSize")
local useTheme = require("../../Hooks/useTheme")

local PLACEHOLDER_TEXT_COLOR = Color3.fromRGB(102, 102, 102)
local EDGE_PADDING_PX = 5
local DEFAULT_HEIGHT = Constants.DefaultInputHeight

local TEXT_SIZE = Constants.DefaultTextSize
local FONT = Constants.DefaultFont

local function joinDictionaries(dict0, dict1)
	local joined = table.clone(dict0)
	for k, v in dict1 do
		joined[k] = v
	end
	return joined
end

export type BaseTextInputConsumerProps = CommonProps.T & {
	PlaceholderText: string?,
	ClearTextOnFocus: boolean?,
	OnFocused: (() -> ())?,
	OnFocusLost: ((text: string, enterPressed: boolean, input: InputObject) -> ())?,
	children: React.ReactNode,
}

export type BaseTextInputProps = BaseTextInputConsumerProps & {
	Text: string,
	OnChanged: (newText: string) -> (),
	RightPaddingExtra: number?,
}

local function BaseTextInput(props: BaseTextInputProps)
	local theme = useTheme()
	local hovered, setHovered = React.useState(false)
	local focused, setFocused = React.useState(false)
	local disabled = props.Disabled == true

	local predictNextCursor = React.useRef(-1) :: { current: number }
	local lastCursor = React.useRef(-1) :: { current: number }

	local mainModifier = Enum.StudioStyleGuideModifier.Default
	local borderModifier = Enum.StudioStyleGuideModifier.Default
	if disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
		borderModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif focused then
		borderModifier = Enum.StudioStyleGuideModifier.Selected
	elseif hovered then
		borderModifier = Enum.StudioStyleGuideModifier.Hover
	end

	local cursor, setCursor = React.useState(-1)
	local containerSize, setContainerSize = React.useState(Vector2.zero)
	local innerOffset = React.useRef(0) :: { current: number }

	local fullTextWidth = getTextSize(props.Text).X
	local textFieldSize = UDim2.fromScale(1, 1)

	if not disabled then
		local min = EDGE_PADDING_PX
		local max = containerSize.X - EDGE_PADDING_PX
		local textUpToCursor = string.sub(props.Text, 1, cursor - 1)
		local offset = getTextSize(textUpToCursor).X + EDGE_PADDING_PX
		local innerArea = max - min
		local fullOffset = offset + innerOffset.current
		if fullTextWidth <= innerArea or not focused then
			innerOffset.current = 0
		else
			if fullOffset < min then
				innerOffset.current += min - fullOffset
			elseif fullOffset > max then
				innerOffset.current -= fullOffset - max
			end
			innerOffset.current = math.max(innerOffset.current, innerArea - fullTextWidth)
		end
	else
		innerOffset.current = 0
	end

	if focused then
		local textFieldWidth = math.max(containerSize.X, fullTextWidth + EDGE_PADDING_PX * 2)
		textFieldSize = UDim2.new(0, textFieldWidth, 1, 0)
	end

	local textFieldProps = {
		Size = textFieldSize,
		Position = UDim2.fromOffset(innerOffset.current, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = props.Text,
		TextSize = TEXT_SIZE,
		TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = if focused then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd,
		[React.Event.InputBegan] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			end
		end,
		[React.Event.InputEnded] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
		end,
		children = {
			Padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, EDGE_PADDING_PX),
				PaddingRight = UDim.new(0, EDGE_PADDING_PX),
			}),
		},
	}

	local textField
	if disabled then
		textField = React.createElement("TextLabel", textFieldProps)
	else
		textField = React.createElement(
			"TextBox",
			joinDictionaries(textFieldProps, {
				PlaceholderText = props.PlaceholderText,
				PlaceholderColor3 = PLACEHOLDER_TEXT_COLOR,
				ClearTextOnFocus = props.ClearTextOnFocus,
				MultiLine = false,
				[React.Change.CursorPosition] = function(rbx: TextBox)
					-- cursor position changed fires before text changed, so we defer it until after;
					-- this enables us to use the pre-text-changed cursor position to revert to
					task.defer(function()
						lastCursor.current = rbx.CursorPosition
					end)
					setCursor(rbx.CursorPosition)
				end,
				[React.Change.Text] = function(rbx: TextBox)
					local newText = rbx.Text
					if newText ~= props.Text then
						predictNextCursor.current = rbx.CursorPosition
						rbx.Text = props.Text
						rbx.CursorPosition = math.max(1, lastCursor.current)
						props.OnChanged((string.gsub(newText, "[\n\r]", "")))
					elseif focused then
						rbx.CursorPosition = math.max(1, predictNextCursor.current)
					end
				end,
				[React.Event.Focused] = function()
					setFocused(true)
					if props.OnFocused then
						props.OnFocused()
					end
				end,
				[React.Event.FocusLost] = function(rbx: TextBox, enterPressed: boolean, input: InputObject)
					setFocused(false)
					if props.OnFocusLost then
						props.OnFocusLost(rbx.Text, enterPressed, input)
					end
				end :: () -> (),
			})
		)
	end

	local rightPaddingExtra = props.RightPaddingExtra or 0

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.new(1, 0, 0, DEFAULT_HEIGHT),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, borderModifier),
		BorderMode = Enum.BorderMode.Inset,
		[React.Change.AbsoluteSize] = function(rbx: Frame)
			setContainerSize(rbx.AbsoluteSize - Vector2.new(rightPaddingExtra, 0))
		end,
	}, {
		Clipping = React.createElement("Frame", {
			Size = UDim2.new(1, -rightPaddingExtra, 1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 0,
		}, {
			TextField = textField,
		}),
	}, props.children)
end

return BaseTextInput
