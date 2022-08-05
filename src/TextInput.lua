local TextService = game:GetService("TextService")

local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local joinDictionaries = require(script.Parent.joinDictionaries)
local withTheme = require(script.Parent.withTheme)

local Constants = require(script.Parent.Constants)
local TextInput = Roact.Component:extend("TextInput")

local PLACEHOLDER_TEXT_COLOR = Color3.fromRGB(102, 102, 102) -- works for both themes
local TEXTBOX_PADDING = 5
local TOTAL_TEXTBOX_PADDING = TEXTBOX_PADDING * 2
local CLIP_PADDING = Vector2.new(2, 0)

local noop = function() end

TextInput.defaultProps = {
	Size = UDim2.new(1, 0, 0, 21),
	LayoutOrder = 0,
	Disabled = false,
	Text = "",
	PlaceholderText = "",
	ClearTextOnFocus = true,
	OnFocused = noop,
	OnFocusLost = noop,
	OnChanged = noop,
}

-- Important!
-- All operations work with bytes, not graphemes.
-- We're working with UTF-8 encoding as well.
-- To translate a valid byte index to a grapheme, find the grapheme with the matching first byte.
-- "l" 1st grapheme -> 1st byte
-- "lo" 2nd grapheme -> 2nd byte

local function getTextSize(text)
	return TextService:GetTextSize(text, Constants.TextSize, Constants.Font, Vector2.new(math.huge, math.huge))
end

local function getLastVisibleGrapheme(text, boundingSize)
	local lastByte = 1

	for currentByte, _codepoint in utf8.codes(text) do
		local currentSize = getTextSize(string.sub(text, 1, utf8.offset(text, currentByte)))

		if currentSize.X < boundingSize.X then
			lastByte = currentByte
		else
			break
		end
	end

	return lastByte
end

local function getLastGrapheme(text)
	if text == "" then
		error("Text is empty.")
	end

	return utf8.offset(text, -1)
end

local function getPreviousGrapheme(text, fromByte)
	if text == "" then
		error("Text is empty.")
	end

	local lastGrapheme = 1

	for startingByte, _endingByte in utf8.graphemes(text) do
		if startingByte == fromByte then
			return lastGrapheme
		end

		lastGrapheme = startingByte
	end

	error("Misaligned byte!")
end

local function getNextGrapheme(text, fromByte)
	if text == "" then
		error("Text is empty.")
	end

	local reachedFromByte = false

	for startingByte, _endingByte in utf8.graphemes(text) do
		if reachedFromByte then
			return startingByte
		end

		if startingByte == fromByte then
			reachedFromByte = true
		end
	end

	error("Misaligned byte!")
end

function TextInput:init()
	self:setState({
		Hover = false,
		Focused = false,
		FirstVisibleByte = 1,
	})

	self.textBoxRef = Roact.createRef()
	self.containerRef = Roact.createRef()

	self.onInputBegan = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end
	self.onInputEnded = function(_, inputObject)
		if self.props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
	self.onFocused = function()
		self:setState({ Focused = true })
		self.props.OnFocused()
	end
	self.onFocusLost = function(rbx, enterPressed, inputObject)
		self:setState({ Focused = false })
		self.props.OnFocusLost(rbx.Text, enterPressed, inputObject)
	end
	self.onChanged = function(rbx)
		-- No change is possible if the user isn't focused.
		if not self.state.Focused then
			return
		end

		-- Cursor can change first instead of the text.
		-- This is here to correct that desync.
		self:updateFirstVisibleByte()

		self.props.OnChanged(rbx.Text)
	end
end

function TextInput:getPositionOffset()
	local textBox = self.textBoxRef.current
	local text = if textBox == nil then self.props.Text else textBox.Text

	-- A special case where self.props.Text is empty. It makes no sense to try
	-- to calcuate the offset from an empty string.
	if text == "" then
		return 0
	end

	-- The first visible character is not hidden, it's the character before it that is.
	local trimTo = getPreviousGrapheme(text, self.state.FirstVisibleByte)

	-- If it's the first byte, then we're at the first character.
	-- As aformentioned, it's not hidden. So, we simply don't have any hidden text.
	local hiddenText = ""
	if trimTo > 1 then
		hiddenText = string.sub(text, 1, trimTo)
	end

	return -TextService:GetTextSize(hiddenText, Constants.TextSize, Constants.Font, Vector2.new(math.huge, math.huge)).X
end

function TextInput:updateFirstVisibleByte()
	-- If the text is in bound, we snap to the first visible byte.
	-- It'll lead to a off-by-one error otherwise.
	if self:textIsInBounds() then
		self:setState({ FirstVisibleByte = 1 })
		return
	end

	-- If we don't have the textbox, then best assume that the cursor will be at
	-- the first position.
	local textBox = self.textBoxRef.current
	if textBox == nil then
		self:setState({ FirstVisibleByte = 1 })
		return
	end

	local currentText = textBox.Text

	-- An empty string has no graphemes (zero bytes) in it. So, it makes no sense to try to find a offset for it.
	-- This is a special case.
	if currentText == "" then
		self:setState({ FirstVisibleByte = 1 })
		return
	end

	-- Impossible for the containerRef to be nil since textBoxRef isn't.
	local container = assert(self.containerRef.current, "Impossible")

	local boundingBox = container.AbsoluteSize - CLIP_PADDING
	local byteCursorAt = textBox.CursorPosition

	-- We're not focused, the cursor is nowhere.
	if byteCursorAt == -1 then
		self:setState({ FirstVisibleByte = 1 })
		return
	end

	-- The cursor could be placed after the last grapheme.
	-- |a|b|
	--     ^- 3rd index
	-- To us, that's pointing out of bounds, and has to be corrected.
	if byteCursorAt > #currentText then
		byteCursorAt = getLastGrapheme(currentText)
	end

	local firstVisibleByte = self.state.FirstVisibleByte

	-- It's possible for the text to change before the cursor changes correctly.
	if firstVisibleByte > #currentText then
		firstVisibleByte = getLastGrapheme(currentText)
	end

	-- Adding the firstVisibleByte because we effectively trimmed the string to it.
	-- We have to account for those missing characters.
	local lastVisibleByte = getLastVisibleGrapheme(string.sub(currentText, firstVisibleByte, -1), boundingBox)
		+ firstVisibleByte

	local newFirstVisibleByte = firstVisibleByte
	if byteCursorAt < firstVisibleByte then
		local graphemes = {}

		-- Since we're moving the window to the left, we want to iterate backwards.
		-- However, built-in utf8 library doesn't come with such niceties.
		for startingByte, _endingByte in utf8.graphemes(currentText, 1, firstVisibleByte) do
			table.insert(graphemes, startingByte)
		end

		for i = #graphemes, 1, -1 do
			local startingByte = graphemes[i]

			-- Either reached the last grapheme or we passed the cursor.
			if startingByte == 1 or newFirstVisibleByte < byteCursorAt then
				break
			end

			newFirstVisibleByte = getPreviousGrapheme(currentText, newFirstVisibleByte)
		end
	end

	if byteCursorAt > lastVisibleByte then
		for _startingByte, endingByte in utf8.graphemes(currentText, firstVisibleByte) do
			newFirstVisibleByte = getNextGrapheme(currentText, newFirstVisibleByte)

			local newLastVisibleByte = getLastVisibleGrapheme(
				string.sub(currentText, newFirstVisibleByte, -1),
				boundingBox
			) + newFirstVisibleByte

			-- Either reached the first grapheme or we passed the cursor.
			if #currentText == endingByte or newLastVisibleByte > byteCursorAt then
				break
			end
		end
	end

	self:setState({ FirstVisibleByte = newFirstVisibleByte })
	return
end

function TextInput:getPreviewText()
	local container = self.containerRef.current

	if container == nil then
		return self.props.Text
	end

	-- If the container exists, then the textBox does too.
	local currentText = self.textBoxRef.current.Text

	-- Makes no sense to try to figure out the preview of an empty string.
	if currentText == "" then
		return ""
	end

	local boundingBox = container.AbsoluteSize - CLIP_PADDING

	-- The ellipses provides more than enough padding to ensure no clipping occurs.
	local boundingBoxWithEllipses = container.AbsoluteSize - getTextSize("...")

	local lastByte = getLastVisibleGrapheme(currentText, boundingBox)
	local lastByteWithEllipses = getLastVisibleGrapheme(currentText, boundingBoxWithEllipses)

	-- If they're the same, then there's enough space for
	if lastByte == lastByteWithEllipses then
		return currentText
	else
		return currentText:sub(1, utf8.offset(currentText, lastByteWithEllipses)) .. "..."
	end
end

function TextInput:textIsInBounds()
	local container = self.containerRef.current

	-- It could be true or false, does not matter.
	if container == nil then
		return true
	end

	-- If the container exists, then the textBox does too.
	local currentText = self.textBoxRef.current.Text

	-- If the currentText is empty, then it definitively is in bounds.
	-- Plus, makes no sense to get the last grapheme of it.
	if currentText == "" then
		return true
	end

	local boundingBox = container.AbsoluteSize - CLIP_PADDING

	local lastByte = getLastVisibleGrapheme(currentText, boundingBox)
	return lastByte == getLastGrapheme(currentText)
end

function TextInput:didMount()
	-- Since self.containerRef.current will be nil on the first render, TextInput:getPreviewText() defaults to previewing the whole string.
	-- In reality, the string may need to be truncated, so it's ran again after the first render to correct that.

	-- It is deferred because the absolute size of the container updates on the next frame.
	-- But, deferring can lead to a narly edge-case where self.textBoxRef is nil in the deferred function.
	-- (insert the reason why here [please])
	local textBoxRef = self.textBoxRef

	task.defer(function()
		-- Don't get in the way of potential modifications.
		if not self.state.Focused then
			-- Not taking risks.
			if textBoxRef then
				if textBoxRef.current then
					textBoxRef.current.Text = self:getPreviewText()
				end
			end
		end
	end)
end

function TextInput.getDerivedStateFromProps(nextProp, lastState)
	-- Horrifying edge case where a user selects text from right to left, then deletes it.
	-- When the user deletes the selected text, it does not update the FirstVisibleByte. Consquently, the cursor suddenly points to nowhere.
	-- Leading to an error when we calculate position offset as we never expect FirstVisibleByte to point nowhere.

	-- lastState.FirstVisibleByte can be nil since getDerivedStateFromProps runs before init as well.
	local textLen = #nextProp.Text
	local firstVisibleByte = lastState.FirstVisibleByte or 1

	if textLen > 0 and textLen < firstVisibleByte then
		return {
			FirstVisibleByte = getLastGrapheme(nextProp.Text),
		}
	end

	return nil
end

function TextInput:render()
	local mainModifier = Enum.StudioStyleGuideModifier.Default
	local borderModifier = Enum.StudioStyleGuideModifier.Default

	if self.props.Disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
		borderModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.state.Focused then
		borderModifier = Enum.StudioStyleGuideModifier.Selected
	elseif self.state.Hover then
		borderModifier = Enum.StudioStyleGuideModifier.Hover
	end

	return withTheme(function(theme)
		local textFieldProps = {
			Size = UDim2.new(2, getTextSize(self.props.Text).X, 1, 0),
			Position = UDim2.fromOffset(if self.state.Focused then self:getPositionOffset() else 0, 0),
			Text = if self.state.Focused then self.props.Text else self:getPreviewText(),
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier),
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			[Roact.Ref] = self.textBoxRef,
		}

		return Roact.createElement("Frame", {
			Size = self.props.Size,
			Position = self.props.Position,
			BackgroundTransparency = 0,
			ClipsDescendants = true,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, borderModifier),
			BorderMode = Enum.BorderMode.Inset,
			LayoutOrder = self.props.LayoutOrder,
		}, {
			-- The container isn't clipped since the cursor might be hidden.
			Container = Roact.createElement("Frame", {
				Size = UDim2.new(1, -TOTAL_TEXTBOX_PADDING, 1, 0),
				Position = UDim2.new(0, TEXTBOX_PADDING, 0, 0),
				BackgroundTransparency = 1,
				[Roact.Ref] = self.containerRef,
			}, {
				TextBox = self.props.Disabled and Roact.createElement("TextLabel", textFieldProps)
					or Roact.createElement(
						"TextBox",
						joinDictionaries(textFieldProps, {
							PlaceholderText = self.props.PlaceholderText,
							PlaceholderColor3 = PLACEHOLDER_TEXT_COLOR,
							ClearTextOnFocus = self.props.ClearTextOnFocus,
							[Roact.Event.Focused] = self.onFocused,
							[Roact.Event.FocusLost] = self.onFocusLost,
							[Roact.Event.InputBegan] = self.onInputBegan,
							[Roact.Event.InputEnded] = self.onInputEnded,
							[Roact.Change.Text] = self.onChanged,
							[Roact.Change.CursorPosition] = function(_rbx)
								self:updateFirstVisibleByte()
							end,
						})
					),
			}),
		})
	end)
end

return TextInput
