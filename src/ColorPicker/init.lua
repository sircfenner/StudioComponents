local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local withTheme = require(script.Parent.withTheme)
local getDragInput = require(script.getDragInput)

local ColorPicker = Roact.Component:extend("ColorPicker")

ColorPicker.defaultProps = {
	Size = UDim2.fromOffset(250, 200),
}

local function generateHueKeypoints(value)
	local keypoints = {}

	for hue = 0, 6 do
		table.insert(keypoints, ColorSequenceKeypoint.new(hue / 6, Color3.fromHSV((6 - hue) / 6, 1, value)))
	end

	return ColorSequence.new(keypoints)
end

function ColorPicker:init()
	-- Color3 does not retain HSV data at all. For example:
	-- Color3.fromHSV(1, 0, 0):ToHSV() -> (0, 0, 0)
	-- or Color3.fromHSV(1, 1, 1):ToHSV() -> (0, 1, 1)
	-- Since information is lost leads to cases like:
	-- * value being zeroed causes the picker's position to snap a corner.
	-- * leading the picker to the right side (sat = zero) causes the picker to wrap around.
	-- * and more!

	-- Using self.state isn't possible since :willUpdate() cannot change state.
	self.hue, self.sat, self.val = self.props.Color:ToHSV()

	self.regionDrag = getDragInput(function(alpha)
		local newHue = 1 - alpha.x
		local newSat = 1 - alpha.y
		local newVal = self.val

		self.hue = newHue
		self.sat = newSat
		self.props.OnChange(Color3.fromHSV(newHue, newSat, newVal))
	end)
	self.barDrag = getDragInput(function(alpha)
		local newVal = 1 - alpha.y
		local newHue, newSat = self.hue, self.sat

		self.val = newVal
		self.props.OnChange(Color3.fromHSV(newHue, newSat, newVal))
	end)
end

function ColorPicker:willUnmount()
	self.regionDrag.cleanup()
	self.barDrag.cleanup()
end

function ColorPicker:willUpdate(nextProp, _nextState)
	-- This will always ensure we're never out of sync. Use a dead-simple check to see if our values don't match.
	if Color3.fromHSV(self.hue, self.sat, self.val) ~= nextProp.Color then
		self.hue, self.sat, self.val = nextProp.Color:ToHSV()
	end
end

function ColorPicker:render()
	local props = self.props
	local hue, sat, val = self.hue, self.sat, self.val
	local indicatorBackground = if val > 0.4 then Color3.new() else Color3.fromRGB(200, 200, 200)


	return withTheme(function(theme)
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
				[Roact.Event.InputBegan] = self.barDrag.began,
				[Roact.Event.InputChanged] = self.barDrag.changed,
				[Roact.Event.InputEnded] = self.barDrag.ended,
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
				[Roact.Event.InputBegan] = self.regionDrag.began,
				[Roact.Event.InputChanged] = self.regionDrag.changed,
				[Roact.Event.InputEnded] = self.regionDrag.ended,
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
					ZIndex = -1
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
	end)
end

return ColorPicker