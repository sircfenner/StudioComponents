local TextService = game:GetService("TextService")

local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local Constants = require(script.Parent.Constants)
local useTheme = require(script.Parent.useTheme)

local FONT = Constants.Font
local TEXT_SIZE = 14
local TEXT_PADDING_SIDES = 3
local TEXT_PADDING_TOP = 1
local TEXT_PADDING_BTM = 2

local OFFSET_RIGHT = 3
local OFFSET_DOWN = 18
local OFFSET_LEFT = 2
local OFFSET_UP = 2

local defaultProps = {
	Text = "Tooltip.defaultProps.Text",
	MaxWidth = 200,
	HoverDelay = 0.4,
}

-- TODO: do some kind of validation if the trigger has moved e.g. in a scroll frame?
-- TODO: disabled?

local function Shadow(props, hooks)
	local theme = useTheme(hooks)
	return Roact.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DropShadow),
		BackgroundTransparency = props.Transparency,
		BorderSizePixel = 0,
		Position = props.Position,
		Size = props.Size,
		ZIndex = 0,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, props.Radius),
		}),
		Children = Roact.createFragment(props[Roact.Children]),
	})
end
Shadow = Hooks.new(Roact)(Shadow)

local function Tooltip(props, hooks)
	local theme = useTheme(hooks)
	local dummyRef = hooks.useValue(Roact.createRef())

	local display, setDisplay = hooks.useState(false)
	local displayPos = hooks.useValue(nil)
	local displayThread = hooks.useValue(nil)

	local function cancel()
		if display == true then
			setDisplay(false)
		end
		if displayThread.value then
			task.cancel(displayThread.value)
			displayThread.value = nil
			displayPos.value = nil
		end
	end

	local function onInputBeganChanged(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			cancel()
			displayPos.value = Vector2.new(input.Position.x, input.Position.y)
			displayThread.value = task.delay(props.HoverDelay, function()
				setDisplay(true)
			end)
		end
	end

	local function onInputEnded(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			cancel()
		end
	end

	hooks.useEffect(function()
		if displayThread.value then
			task.cancel(displayThread.value)
		end
	end, {})

	local frameSize = Vector2.new(props.MaxWidth - TEXT_PADDING_SIDES * 2, math.huge)
	local textSize = TextService:GetTextSize(props.Text, TEXT_SIZE, FONT, frameSize)
	local fullSize = textSize + Vector2.new(TEXT_PADDING_SIDES * 2, TEXT_PADDING_BTM + TEXT_PADDING_TOP)
	local buffer = 3 -- extra space required around/above/below

	local target = nil
	local anchor = Vector2.new(0, 0)
	local offset = Vector2.new(OFFSET_RIGHT, OFFSET_DOWN)
	if display and dummyRef.value then
		local inst = dummyRef.value:getValue()
		if inst ~= nil then
			target = inst:FindFirstAncestorWhichIsA("LayerCollector")
			local mouse = displayPos.value
			if target ~= nil then
				local spaceRight = target.AbsoluteSize.x - mouse.x - OFFSET_RIGHT
				local spaceLeft = mouse.x - OFFSET_LEFT
				if spaceRight < fullSize.x + buffer and spaceLeft > spaceRight then
					anchor = Vector2.new(1, anchor.y)
					offset = Vector2.new(-OFFSET_LEFT, offset.y)
				end
				local spaceBelow = target.AbsoluteSize.y - mouse.y - OFFSET_DOWN
				local spaceAbove = mouse.y - OFFSET_UP
				if spaceBelow < fullSize.y + buffer and spaceAbove > spaceBelow then
					anchor = Vector2.new(anchor.x, 1)
					offset = Vector2.new(offset.x, -OFFSET_UP)
				end
			end
		end
	end

	local dropShadow = nil
	if target ~= nil then
		dropShadow = Roact.createElement(Shadow, {
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, 1, 1, 1),
			Radius = 5,
			Transparency = 0.96,
		}, {
			Shadow = Roact.createElement(Shadow, {
				Position = UDim2.fromOffset(1, 1),
				Size = UDim2.new(1, -2, 1, -2),
				Radius = 4,
				Transparency = 0.88,
			}, {
				Shadow = Roact.createElement(Shadow, {
					Position = UDim2.fromOffset(1, 1),
					Size = UDim2.new(1, -2, 1, -2),
					Radius = 3,
					Transparency = 0.80,
				}, {
					Shadow = Roact.createElement(Shadow, {
						Position = UDim2.fromOffset(1, 1),
						Size = UDim2.new(1, -2, 1, -2),
						Radius = 2,
						Transparency = 0.77,
					}),
				}),
			}),
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Roact.Ref] = dummyRef.value,
		[Roact.Event.InputBegan] = onInputBeganChanged,
		[Roact.Event.InputChanged] = onInputBeganChanged,
		[Roact.Event.InputEnded] = onInputEnded,
	}, {
		Portal = target and Roact.createElement(Roact.Portal, {
			target = target,
		}, {
			Tooltip = Roact.createElement("Frame", {
				ZIndex = Constants.ZIndex.Tooltip,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(fullSize.x, fullSize.y),
				AnchorPoint = anchor,
				Position = UDim2.fromOffset(displayPos.value.x + offset.x, displayPos.value.y + offset.y),
			}, {
				Label = Roact.createElement("TextLabel", {
					ZIndex = 1,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 0,
					Text = props.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Font = Enum.Font.SourceSans,
					TextSize = 14,
					TextWrapped = true,
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Tooltip),
					BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, TEXT_PADDING_SIDES),
						PaddingRight = UDim.new(0, TEXT_PADDING_SIDES),
						PaddingTop = UDim.new(0, TEXT_PADDING_TOP),
						PaddingBottom = UDim.new(0, TEXT_PADDING_BTM),
					}),
				}),
				Shadow = dropShadow,
			}),
		}),
	})
end

return Hooks.new(Roact)(Tooltip, {
	defaultProps = defaultProps,
})
