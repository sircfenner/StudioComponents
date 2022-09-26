local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local DropdownConstants = require(script.Constants)
local Constants = require(script.Parent.Constants)

local useTheme = require(script.Parent.useTheme)

--[[
todo:
- props.Disabled + becoming Disabled while open
- props for position/anchor/size
- should it have a border?
]]

local ScrollFrame = require(script.Parent.ScrollFrame)
local DropdownItem = require(script.DropdownItem)

local function Dropdown(props, hooks)
	local theme = useTheme(hooks)

	local open, setOpen = hooks.useState(false)
	local hovered, setHovered = hooks.useState(false)

	local rootRef = hooks.useValue(Roact.createRef())
	local rootPosition, setRootPosition = hooks.useBinding(Vector2.new())
	local rootSize, setRootSize = hooks.useBinding(Vector2.new())

	local onSelectedInputBegan = function(_, input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			setHovered(true)
		elseif t == Enum.UserInputType.MouseButton1 then
			setOpen(not open) -- what if disabled?
		end
	end

	local onSelectedInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
	end

	local onSelectedItem = function(item)
		setOpen(false)
		props.OnSelected(item)
	end

	local modifier = Enum.StudioStyleGuideModifier.Default
	if hovered then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end

	local background = Enum.StudioStyleGuideColor.MainBackground
	if open or hovered then
		background = Enum.StudioStyleGuideColor.InputFieldBackground
	end

	local items = {}
	if open then
		for i, item in ipairs(props.Items) do
			items[i] = Roact.createElement(DropdownItem, {
				Item = item,
				LayoutOrder = i,
				OnSelected = onSelectedItem,
			})
		end
	end

	local rowPadding = 1
	local visibleItems = math.min(DropdownConstants.MaxVisibleRows, #items)
	local scrollHeight = visibleItems * DropdownConstants.RowHeightItem -- item heights
		+ (visibleItems - 1) * rowPadding -- row padding
		+ 2 -- top and bottom borders

	local catcher = nil
	local function onCatcherInputBegan(_, input)
		local t = input.UserInputType
		if
			t == Enum.UserInputType.MouseButton1
			or t == Enum.UserInputType.MouseButton2
			or t == Enum.UserInputType.MouseButton3
		then
			local inst = rootRef.value:getValue()
			local p = Vector2.new(input.Position.x, input.Position.y)
			local min = inst.AbsolutePosition
			local max = min + inst.AbsoluteSize + Vector2.new(0, scrollHeight)
			if p.x < min.x or p.x > max.x or p.y < min.y or p.y > max.y then
				setOpen(false) -- only run if not clicking over the dropdown/options
			end
		elseif t == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				setOpen(false)
			end
		end
	end

	if open and rootRef.value then
		local inst = rootRef.value:getValue()
		local target = inst:FindFirstAncestorWhichIsA("LayerCollector")
		if target ~= nil then
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
						Position = rootPosition:map(function(pos)
							return UDim2.fromOffset(
								math.round(pos.x),
								math.ceil(pos.y - 1) + DropdownConstants.RowHeightTop
							)
						end),
						Size = rootSize:map(function(size)
							return UDim2.fromOffset(math.round(size.x), scrollHeight)
						end),
						Layout = {
							Padding = UDim.new(0, rowPadding),
						},
					}, items),
				}),
			})
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(100, DropdownConstants.RowHeightTop), -- prop (width - UDim?)
		Position = UDim2.fromScale(0.5, 0.5), -- prop
		AnchorPoint = Vector2.new(0.5, 0.5), -- prop
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		[Roact.Event.InputBegan] = onSelectedInputBegan,
		[Roact.Event.InputEnded] = onSelectedInputEnded,
		[Roact.Ref] = rootRef.value,
		[Roact.Change.AbsolutePosition] = function(rbx)
			setRootPosition(rbx.AbsolutePosition)
		end,
		[Roact.Change.AbsoluteSize] = function(rbx)
			setRootSize(rbx.AbsoluteSize)
		end,
	}, {
		Catch = catcher,
		Selected = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = theme:GetColor(background, modifier),
			BorderMode = Enum.BorderMode.Inset,
			BorderSizePixel = 1,
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
			Text = props.Item,
			Font = Constants.Font,
			TextSize = Constants.TextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, DropdownConstants.TextPaddingLeft - 1), -- border
				PaddingRight = UDim.new(0, DropdownConstants.TextPaddingRight),
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

return Hooks.new(Roact)(Dropdown)
