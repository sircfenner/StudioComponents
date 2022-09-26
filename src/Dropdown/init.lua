local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local Constants = require(script.Parent.Constants)
local useTheme = require(script.Parent.useTheme)

local ScrollFrame = require(script.Parent.ScrollFrame)
local DropdownItem = require(script.DropdownItem)

local TEXT_PADDING_LEFT = 5
local TEXT_PADDING_RIGHT = 3

local catchInputs = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
}

local defaultProps = {
	Width = UDim.new(1, 0),
	MaxVisibleRows = 6,
	RowHeightTop = 20,
	RowHeightItem = 15,
}

local function Dropdown(props, hooks)
	local theme = useTheme(hooks)

	local open, setOpen = hooks.useState(false)
	local hovered, setHovered = hooks.useState(false)

	local rootRef = hooks.useValue(Roact.createRef())

	local onSelectedInputBegan = function(_, input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			if not props.Disabled then
				setHovered(true)
			end
		elseif t == Enum.UserInputType.MouseButton1 then
			if not props.Disabled then
				setOpen(not open)
			end
		end
	end

	local onSelectedInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
	end

	local onSelectedItem = function(item)
		if not props.Disabled then
			setOpen(false)
			props.OnSelected(item)
		end
	end

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local background = Enum.StudioStyleGuideColor.MainBackground
	if open or hovered then
		background = Enum.StudioStyleGuideColor.InputFieldBackground
	end

	local items = {}
	if open and not props.Disabled then
		for i, item in ipairs(props.Items) do
			items[i] = Roact.createElement(DropdownItem, {
				Item = item,
				LayoutOrder = i,
				OnSelected = onSelectedItem,
				RowHeightItem = props.RowHeightItem,
				TextPaddingLeft = TEXT_PADDING_LEFT,
				TextPaddingRight = TEXT_PADDING_RIGHT,
			})
		end
	end

	local rowPadding = 1
	local visibleItems = math.min(props.MaxVisibleRows, #items)
	local scrollHeight = visibleItems * props.RowHeightItem -- item heights
		+ (visibleItems - 1) * rowPadding -- row padding
		+ 2 -- top and bottom borders

	local catcher = nil
	local function onCatcherInputBegan(_, input)
		local t = input.UserInputType
		if catchInputs[t] then
			local inst = rootRef.value:getValue()
			local off = Vector2.new(input.Position.x, input.Position.y) - inst.AbsolutePosition
			local max = inst.AbsoluteSize
			if off.x < 0 or off.x > max.x or off.y < 0 or off.y > max.y then
				setOpen(false) -- only run if not clicking over the dropdown top part
			end
		elseif t == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				setOpen(false)
			end
		end
	end

	if not props.Disabled and open and rootRef.value then
		local inst = rootRef.value:getValue()
		local target = inst:FindFirstAncestorWhichIsA("LayerCollector")

		if target ~= nil then
			local pos = inst.AbsolutePosition
			local size = inst.AbsoluteSize

			local spaceBelow = target.AbsoluteSize.y - size.y - pos.y
			local spaceAbove = pos.y

			-- render dropdown going upward if both are true:
			-- 1. not enough space below AND
			-- 2. more space above
			local anchor = Vector2.new(0, 0)
			local posy = math.ceil(pos.y) - 1 + props.RowHeightTop
			local buffer = 3 -- extra space required below
			if spaceBelow < scrollHeight + buffer and spaceAbove > spaceBelow then
				anchor = Vector2.new(0, 1)
				posy -= props.RowHeightTop
			end

			catcher = Roact.createElement(Roact.Portal, {
				target = target,
			}, {
				Frame = Roact.createElement("Frame", {
					ZIndex = 2 ^ 31 - 1,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					[Roact.Event.InputBegan] = onCatcherInputBegan,
				}, {
					-- rounding etc. here corrects for sub-pixel alignments
					Drop = open and Roact.createElement(ScrollFrame, {
						AnchorPoint = anchor,
						Position = UDim2.fromOffset(math.round(pos.x) - 1, posy),
						Size = UDim2.fromOffset(math.round(size.x) + 2, scrollHeight),
						Layout = {
							Padding = UDim.new(0, rowPadding),
						},
					}, items),
				}),
			})
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(props.Width, UDim.new(0, props.RowHeightTop)),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		[Roact.Event.InputBegan] = onSelectedInputBegan,
		[Roact.Event.InputEnded] = onSelectedInputEnded,
		[Roact.Ref] = rootRef.value,
		[Roact.Change.AbsolutePosition] = function()
			setOpen(false)
		end,
		[Roact.Change.AbsoluteSize] = function()
			setOpen(false)
		end,
	}, {
		Catch = catcher,
		Selected = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = theme:GetColor(background, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
			Text = props.Item,
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, TEXT_PADDING_LEFT),
				PaddingRight = UDim.new(0, TEXT_PADDING_RIGHT),
				PaddingBottom = UDim.new(0, 1),
			}),
		}),
		ArrowContainer = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 18, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Arrow = Roact.createElement("ImageLabel", {
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

return Hooks.new(Roact)(Dropdown, {
	defaultProps = defaultProps,
})
