--[=[
	@class Dropdown

	A togglable popup box containing a list of items to select a single item from. 

	Clicking the top section of a dropdown opens the list. Selecting an item, clicking anywhere else, 
	or pressing the Escape key will close the dropdown list. The list renders above all other UI
	elements under the same LayerCollector.

	| Dark | Light |
	| - | - |
	| ![Dark](/components/dropdown/dark.png) | ![Light](/components/dropdown/light.png) |

	By default, the dropdown list opens below the top section.  However, if there is not enough 
	space below, and there is more space above, the dropdown list will open upwards instead. 
	
	The height of the top row can also be customized by passing a `Size` prop. The default size of the 
	top row can be found in [Constants.DefaultDropdownHeight].

	The height of the dropdown list box is determined by the `RowHeight` and `MaxVisibleRows` props.
	The default height of a list row can be found in [Constants.DefaultDropdownRowHeight].

	Dropdowns manage their own open/closed state, but otherwise are controlled components.
	This means that you need to manage the current selected item by passing a value to 
	`SelectedItem` and a callback value to `OnItemSelected`. For example:

	```lua
	local function MyComponent()
		local selected, setSelected = React.useState("Red")
		local items = {	"Red", "Green", "Blue" }
		return React.createElement(StudioComponents.Dropdown, {
			Items = items,
			SelectedItem = selected,
			OnItemSelected = setSelected,
		})
	end
	```

	Dropdowns do not by themselves require a value to always be selected. To explicitly allow the 
	selected value to be cleared by the user, set the `ClearButton` prop to `true`. 
	Multiple selections are not supported.

	The list of items to select from can be specified either as strings or a [DropdownItemDetail] array.
	Using the detailed item format allows custom text and icons to be displayed, as seen below:

	```lua
	local function MyComponent()
		local items = {
			{
				Id = "item-1",
				Text = "First Item",
				Icon = {
					Image = "rbxassetid://...",
					...
				},
			},
			...
		}
		...
		return React.createElement(StudioComponents.Dropdown, {
			Items = items,
			SelectedItem = "item-1",
			...
		})
	end
	```

	When using the detailed item format, the value in `SelectedItem` and the values that
	`OnItemSelected` is called with correspond to the `Id` field of an item in the `Items` array.
]=]

local React = require("@pkg/@jsdotlua/react")
local ReactRoblox = require("@pkg/@jsdotlua/react-roblox")

local Constants = require("../../Constants")
local useTheme = require("../../Hooks/useTheme")

local CommonProps = require("../../CommonProps")
local ScrollFrame = require("../ScrollFrame")

local ClearButton = require("./ClearButton")
local DropdownItem = require("./DropdownItem")
local DropdownTypes = require("./Types")

local LEFT_TEXT_PAD = 5
local ARROW_WIDTH = 17
local CLEAR_BUTTON_WIDTH = 16
local DEFAULT_MAX_ROWS = 8
local DEFAULT_PLACEHOLDER_TEXT = "Select..."

local mouseClickInputs = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
}

type ButtonData = {
	Position: Vector2,
	Size: Vector2,
}

--[=[
	@within Dropdown
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Items { DropdownItem }
	@field OnItemSelected ((newItem: string?) -> ())?
	@field SelectedItem string?
	@field DefaultText string?
	@field RowHeight number?
	@field MaxVisibleRows number?
	@field ClearButton boolean?
]=]

type DropdownProps = CommonProps.T & {
	Items: { DropdownTypes.DropdownItem },
	OnItemSelected: ((newItem: string?) -> ())?,
	SelectedItem: string?,
	DefaultText: string?,
	RowHeight: number?,
	MaxVisibleRows: number?,
	ClearButton: boolean?,
}

local function Dropdown(props: DropdownProps)
	local theme = useTheme()

	local onItemSelected: (string?) -> () = props.OnItemSelected or function() end

	local opened, setOpened = React.useState(false)
	local hovered, setHovered = React.useState(false)

	local window: LayerCollector?, setWindow = React.useState(nil :: LayerCollector?)
	local buttonRef = React.useRef(nil :: Frame?)

	local buttonPosBinding, setButtonPosBinding = React.useBinding(Vector2.zero)
	local buttonSizeBinding, setButtonSizeBinding = React.useBinding(Vector2.zero)
	local buttonDataBinding = React.joinBindings({
		Position = buttonPosBinding,
		Size = buttonSizeBinding,
	}) :: React.Binding<ButtonData>

	React.useEffect(function()
		local button = buttonRef.current
		local connections = {}
		if button ~= nil then
			connections[1] = button:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				setButtonPosBinding(button.AbsolutePosition)
			end)
			setButtonPosBinding(button.AbsolutePosition)
			connections[2] = button:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				setButtonSizeBinding(button.AbsoluteSize)
			end)
			setButtonSizeBinding(button.AbsoluteSize)
			connections[4] = button.AncestryChanged:Connect(function()
				setWindow(button:FindFirstAncestorWhichIsA("LayerCollector"))
			end)
			setWindow(button:FindFirstAncestorWhichIsA("LayerCollector"))
		end
		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, {})

	React.useEffect(function()
		local connection
		if window ~= nil and window:IsA("PluginGui") then
			connection = window.WindowFocusReleased:Connect(function()
				setOpened(false)
			end)
		end
		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, { window })

	React.useEffect(function()
		if opened and props.Disabled then
			setOpened(false)
		end
	end, { props.Disabled, opened })

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local backgroundStyle = Enum.StudioStyleGuideColor.MainBackground
	if (hovered or opened) and not props.Disabled then
		backgroundStyle = Enum.StudioStyleGuideColor.InputFieldBackground
	end

	local rowHeight = props.RowHeight or Constants.DefaultDropdownRowHeight

	local overlay
	if window and opened and not props.Disabled then
		local items: { [string]: React.ReactNode } = {}
		for i, item in props.Items do
			local id, text, icon
			if type(item) == "string" then
				id = item
				text = item
			else
				id = item.Id
				text = item.Text
				icon = item.Icon
			end
			items[id] = React.createElement(DropdownItem, {
				LayoutOrder = i,
				Id = id,
				Text = text,
				Icon = icon,
				TextInset = LEFT_TEXT_PAD - 1,
				Height = rowHeight,
				Selected = id == props.SelectedItem,
				OnSelected = function(newItem)
					setOpened(false)
					onItemSelected(newItem)
				end,
			})
		end

		local maxVisibleRows = props.MaxVisibleRows or DEFAULT_MAX_ROWS
		local numVisibleRows = math.min(#props.Items, maxVisibleRows)
		local listHeight = numVisibleRows * rowHeight

		local dropDirection = "Down"
		local buttonDataNow = buttonDataBinding:getValue()
		local spaceBelow = window.AbsoluteSize.Y - (buttonDataNow.Position.Y + buttonDataNow.Size.Y)
		local spaceAbove = buttonDataNow.Position.Y
		if spaceBelow < listHeight and spaceAbove > spaceBelow then
			dropDirection = "Up"
		end

		local function onOverlayInputBegan(_, input: InputObject)
			if mouseClickInputs[input.UserInputType] then
				local buttonData = buttonDataBinding:getValue()
				local areaSize = Vector2.new(buttonData.Size.X, buttonData.Size.Y + listHeight)
				local areaPos = buttonData.Position
				if dropDirection == "Up" then
					areaPos -= Vector2.new(0, listHeight)
				end
				local offset = Vector2.new(input.Position.X, input.Position.Y) - areaPos
				if offset.X < 0 or offset.X > areaSize.X or offset.Y < 0 or offset.Y > areaSize.Y then
					-- only clicks outside the dropdown will close it
					-- this enables e.g. clicking dropdown list scrollbar buttons
					setOpened(false)
				end
			elseif input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					setOpened(false)
				end
			end
		end

		overlay = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			[React.Event.InputBegan] = onOverlayInputBegan,
		}, {
			List = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, if dropDirection == "Down" then 0 else 1),
				Position = buttonDataBinding:map(function(data: ButtonData)
					local px = math.round(data.Position.X)
					local py = math.round(data.Position.Y)
					if dropDirection == "Down" then
						py += math.round(data.Size.Y)
					end
					return UDim2.fromOffset(px, py)
				end),
				Size = buttonSizeBinding:map(function(size: Vector2)
					return UDim2.fromOffset(math.round(size.X), listHeight)
				end),
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			}, {
				Scroller = React.createElement(ScrollFrame, {
					Size = UDim2.fromScale(1, 1),
					Layout = {
						ClassName = "UIListLayout",
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
				}, items),
			}),
		})
	end

	local selectedText = props.DefaultText or DEFAULT_PLACEHOLDER_TEXT
	for _, item in props.Items do
		if type(item) == "string" then
			if item == props.SelectedItem then
				selectedText = item
				break
			end
		else
			if item.Id == props.SelectedItem then
				selectedText = item.Text
				break
			end
		end
	end

	local showClearButton = false
	if props.ClearButton and props.SelectedItem and props.Disabled ~= true then
		showClearButton = true
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.new(1, 0, 0, Constants.DefaultDropdownHeight),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundColor3 = theme:GetColor(backgroundStyle, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		[React.Event.InputBegan] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				if not props.Disabled then
					setOpened(not opened)
				end
			end
		end,
		[React.Event.InputEnded] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
		end,
		ref = buttonRef,
	}, {
		Overlay = window and overlay and ReactRoblox.createPortal(overlay, window),
		Label = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(5, 0),
			Size = UDim2.new(
				1,
				-LEFT_TEXT_PAD - ARROW_WIDTH - 2 - (if showClearButton then CLEAR_BUTTON_WIDTH + 2 else 0),
				1,
				-1
			),
			Text = selectedText,
			TextTransparency = if props.SelectedItem then 0 else 0.4,
			Font = Constants.DefaultFont,
			TextSize = Constants.DefaultTextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundTransparency = 1,
		}),
		ClearButton = showClearButton and React.createElement(ClearButton, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -ARROW_WIDTH - 2, 0, 0),
			Size = UDim2.new(0, CLEAR_BUTTON_WIDTH, 1, 0),
			OnActivated = function()
				onItemSelected(nil)
				setOpened(false)
			end,
		}),
		ArrowContainer = React.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, ARROW_WIDTH, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Arrow = React.createElement("ImageLabel", {
				Image = "rbxassetid://7260137654",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(8, 4),
				BackgroundTransparency = 1,
				ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText, modifier),
			}),
		}),
	})
end

return Dropdown
