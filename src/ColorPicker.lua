local Packages = script.Parent.Parent

local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local useTheme = require(script.Parent.useTheme)
local useDragInput = require(script.Parent.useDragInput)

local function generateHueKeypoints(value)
	local keypoints = {}
	for hue = 0, 6 do
		table.insert(keypoints, ColorSequenceKeypoint.new(hue / 6, Color3.fromHSV((6 - hue) / 6, 1, value)))
	end
	return ColorSequence.new(keypoints)
end

local defaultProps = {
	Size = UDim2.fromOffset(250, 200),
}

local function ColorPicker(props, hooks)
	local theme = useTheme(hooks)

	-- Color3 does not retain HSV data at all. For example:
	-- Color3.fromHSV(1, 0, 0):ToHSV() -> (0, 0, 0)
	-- or Color3.fromHSV(1, 1, 1):ToHSV() -> (0, 1, 1)
	-- Since information is lost leads to cases like:
	-- * value being zeroed causes the picker's position to snap a corner.
	-- * leading the picker to the right side (sat = zero) causes the picker to wrap around.
	-- * and more!

	-- Using self.state isn't possible since :willUpdate() cannot change state.
	local hsv = hooks.useValue({ props.Color:ToHSV() })

	-- This will always ensure we're never out of sync.
	-- Use a dead-simple check to see if our values don't match.
	if Color3.fromHSV(unpack(hsv.value)) ~= props.Color then
		hsv.value = { props.Color:ToHSV() }
	end

	local regionDrag = useDragInput(hooks, function(region, position)
		local alpha = (position - region.AbsolutePosition) / region.AbsoluteSize
		local newHue = math.clamp(1 - alpha.x, 0, 1)
		local newSat = math.clamp(1 - alpha.y, 0, 1)
		local newVal = hsv.value[3]
		hsv.value[1] = newHue
		hsv.value[2] = newSat
		props.OnChange(Color3.fromHSV(newHue, newSat, newVal))
	end)

	local barDrag = useDragInput(hooks, function(bar, position)
		local alpha = (position - bar.AbsolutePosition) / bar.AbsoluteSize

		local newHue = hsv.value[1]
		local newSat = hsv.value[2]
		local newVal = math.clamp(1 - alpha.y, 0, 1)
		hsv.value[3] = newVal

		props.OnChange(Color3.fromHSV(newHue, newSat, newVal))
	end)

	local hue, sat, val = unpack(hsv.value)
	local indicatorBackground = if val > 0.4 then Color3.new() else Color3.fromRGB(200, 200, 200)

	return Roact.createElement("Frame", {
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = 1,
	}, {
		-- using TextButton prevents the studio drag-selection box appearing
		Slider = Roact.createElement("TextButton", {
			Active = false,
			AutoButtonColor = false,
			Text = "",
			Size = UDim2.new(0, 14, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -6, 0, 0),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.InputBegan] = barDrag.onInputBegan,
			[Roact.Event.InputEnded] = barDrag.onInputEnded,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(hue, sat, 1)),
				Rotation = 270,
			}),
			Arrow = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(5, 9),
				Position = UDim2.new(1, 1, 1 - val, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://7507468017",
				ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText),
			}),
		}),
		-- see above re: TextButton for why ImageButton is used here
		Region = Roact.createElement("ImageButton", {
			Active = false,
			AutoButtonColor = false,
			Size = UDim2.new(1, -30, 1, 0),
			Image = "",
			ClipsDescendants = true,
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			[Roact.Event.InputBegan] = regionDrag.onInputBegan,
			[Roact.Event.InputEnded] = regionDrag.onInputEnded,
		}, {
			Indicator = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(1 - hue, 0, 1 - sat, 0),
				Size = UDim2.fromOffset(20, 20),
				BackgroundTransparency = 1,
			}, {
				Vertical = Roact.createElement("Frame", {
					Position = UDim2.fromOffset(9, 0),
					Size = UDim2.new(0, 2, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = indicatorBackground,
				}),
				Horizontal = Roact.createElement("Frame", {
					Position = UDim2.fromOffset(0, 9),
					Size = UDim2.new(1, 0, 0, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = indicatorBackground,
				}),
			}),
			HueGradient = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -1,
			}, {
				Gradient = Roact.createElement("UIGradient", {
					Color = generateHueKeypoints(val),
				}),
			}),
			SaturationGradient = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 0,
			}, {
				Gradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromHSV(1, 0, val)),
					Transparency = NumberSequence.new(1, 0),
					Rotation = 90,
				}),
			}),
		}),
	})
end

return Hooks.new(Roact)(ColorPicker, {
	defaultProps = defaultProps,
})
