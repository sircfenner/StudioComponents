--[=[
	@class NumberSequencePicker

	An interface for modifying [NumberSequence](https://create.roblox.com/docs/reference/engine/datatypes/NumberSequence) values.
	This closely resembles the built-in NumberSequence picker for editing properties, with minor adjustments
	for improved readability.

	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/numbersequencepicker/dark.png) | ![Light](/StudioComponents/components/numbersequencepicker/light.png) |

	As this is a controlled component, you should pass a NumberSequence to the `Value` prop 
	representing the current value, and a callback to the `OnChanged` prop which gets run when the 
	user attempts to change the sequence using the interface. For example:

	```lua
	local function MyComponent()
		local sequence, setSequence = React.useState(NumberSequence.new(...))
		return React.createElement(StudioComponents.NumberSequencePicker, {
			Value = sequence,
			OnChanged = setSequence,
		})
	end
	```

	The default size of this component is exposed in [Constants.DefaultNumberSequencePickerSize].
	To keep all inputs accessible, it is recommended not to use a smaller size than this.
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../../CommonProps")
local Constants = require("../../Constants")
local PickerConstants = require("./Constants")

local Button = require("../Button")
local useTheme = require("../../Hooks/useTheme")

local AxisLabel = require("./AxisLabel")
local DashedLine = require("./DashedLine")
local FreeLine = require("./FreeLine")
local LabelledNumericInput = require("./LabelledNumericInput")
local SequenceNode = require("./SequenceNode")

local function clampVector2(v: Vector2, vmin: Vector2, vmax: Vector2)
	return Vector2.new(math.clamp(v.X, vmin.X, vmax.X), math.clamp(v.Y, vmin.Y, vmax.Y))
end

--[=[
	@within NumberSequencePicker
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Value NumberSequence
	@field OnChanged ((newValue: NumberSequence) -> ())?
]=]

type NumberSequencePickerProps = CommonProps.T & {
	Value: NumberSequence,
	OnChanged: ((newValue: NumberSequence) -> ())?,
}

local GRID_ROWS = 4
local GRID_COLS = 10

local ENVELOPE_TRANSPARENCY = PickerConstants.EnvelopeTransparency
local ENVELOPE_COLOR_STYLE = PickerConstants.EnvelopeColorStyle

local function identity(v)
	return v
end

local function NumberSequencePicker(props: NumberSequencePickerProps)
	local theme = useTheme()
	local sequence = props.Value

	local onChanged: (NumberSequence) -> () = props.OnChanged or function() end

	local hoveringIndex: number?, setHoveringIndex = React.useState(nil :: number?)
	local draggingIndex: number?, setDraggingIndex = React.useState(nil :: number?)

	React.useEffect(function()
		if props.Disabled then
			setHoveringIndex(nil)
			setDraggingIndex(nil)
		end
	end, { props.Disabled })

	local contentPos, setContentPos = React.useState(Vector2.zero)
	local contentSize, setContentSize = React.useState(Vector2.zero)

	local borders: { [string]: React.ReactNode } = {}
	for col = 0, GRID_COLS, 0.5 do
		local border = React.createElement(DashedLine, {
			Position = UDim2.fromOffset(math.round(col / GRID_COLS * contentSize.X), 0),
			Size = UDim2.new(0, 1, 1, 0),
			Direction = Enum.FillDirection.Vertical,
			Transparency = if col % 1 == 0 then 0 else 0.75,
			Disabled = props.Disabled,
		})
		borders[`BorderCol{col}`] = border
	end
	for row = 0, GRID_ROWS, 0.5 do
		local border = React.createElement(DashedLine, {
			Position = UDim2.fromOffset(0, math.round(row / GRID_ROWS * contentSize.Y)),
			Size = UDim2.new(1, 0, 0, 1),
			Direction = Enum.FillDirection.Horizontal,
			Transparency = if row % 1 == 0 then 0 else 0.75,
			Disabled = props.Disabled,
		})
		borders[`BorderRow{row}`] = border
	end

	local function onNodeDragged(index: number, position: Vector2)
		local offset = position - contentPos
		offset = clampVector2(offset / contentSize, Vector2.zero, Vector2.one)
		offset = Vector2.new(offset.X, 1 - offset.Y)

		local origin = sequence.Keypoints[index]
		local before = sequence.Keypoints[index - 1]
		local after = sequence.Keypoints[index + 1]

		local minTime = if index == #sequence.Keypoints then 1 elseif index == 1 then 0 else before.Time
		local maxTime = if index == 1 then 0 elseif index == #sequence.Keypoints then 1 else after.Time

		local newEnvelope = origin.Envelope
		if offset.Y + newEnvelope > 1 then
			newEnvelope = 1 - offset.Y
		end
		if offset.Y - newEnvelope < 0 then
			newEnvelope = offset.Y
		end

		local newKeypoint = NumberSequenceKeypoint.new(math.clamp(offset.X, minTime, maxTime), offset.Y, newEnvelope)
		local newKeypoints = table.clone(sequence.Keypoints)
		newKeypoints[index] = newKeypoint

		onChanged(NumberSequence.new(newKeypoints))
	end

	local function onEnvelopeDragged(index: number, y: number, top: boolean)
		local keypoint = sequence.Keypoints[index]
		local offset = (y - contentPos.Y) / contentSize.Y
		local value = 1 - keypoint.Value

		local newEnvelope
		local maxValue = math.min(value, 1 - value)
		if top then
			newEnvelope = math.clamp(value - offset, 0, maxValue)
		else
			newEnvelope = math.clamp(offset - value, 0, maxValue)
		end

		local newKeypoints = table.clone(sequence.Keypoints)
		newKeypoints[index] = NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value, newEnvelope)

		onChanged(NumberSequence.new(newKeypoints))
	end

	local points: { [string]: React.ReactNode } = {}
	for i, keypoint in sequence.Keypoints do
		points[`Point{i}`] = React.createElement(SequenceNode, {
			ContentSize = contentSize,
			Keypoint = keypoint,
			Active = hoveringIndex == i or draggingIndex == i,
			Disabled = props.Disabled,
			OnHovered = function()
				if draggingIndex == nil and hoveringIndex ~= i then
					setHoveringIndex(i)
				end
			end,
			OnNodeDragged = function(position)
				onNodeDragged(i, position)
			end,
			OnEnvelopeDragged = function(y, top)
				onEnvelopeDragged(i, y, top)
			end,
			OnDragBegan = function()
				setDraggingIndex(i)
			end,
			OnDragEnded = function()
				setDraggingIndex(nil)
			end,
		})
	end

	local lines: { [string]: React.ReactNode } = {}
	for i = 1, #sequence.Keypoints - 1 do
		local kp0 = sequence.Keypoints[i]
		local kp1 = sequence.Keypoints[i + 1]
		local p0 = Vector2.new(kp0.Time, 1 - kp0.Value)
		local p1 = Vector2.new(kp1.Time, 1 - kp1.Value)
		lines[`Line{i}`] = React.createElement(FreeLine, {
			Pos0 = p0 * contentSize,
			Pos1 = p1 * contentSize,
			Color = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
			ZIndex = 1,
			Disabled = props.Disabled,
		})
	end

	local envelopes: { [string]: React.ReactNode } = {}
	for i = 1, #sequence.Keypoints - 1 do
		local kp0 = sequence.Keypoints[i]
		local kp1 = sequence.Keypoints[i + 1]
		if kp0.Envelope == 0 and kp1.Envelope == 0 then
			continue
		end
		local p0 = Vector2.new(kp0.Time, 1 - kp0.Value)
		local p1 = Vector2.new(kp1.Time, 1 - kp1.Value)
		envelopes[`EnvelopeOver{i}`] = React.createElement(FreeLine, {
			Pos0 = contentSize * Vector2.new(p0.X, p0.Y - kp0.Envelope), -- NB: roblox enforces bound
			Pos1 = contentSize * Vector2.new(p1.X, p1.Y - kp1.Envelope),
			Color = theme:GetColor(ENVELOPE_COLOR_STYLE),
			Transparency = ENVELOPE_TRANSPARENCY,
			ZIndex = 1,
			Disabled = props.Disabled,
		})
		envelopes[`EnvelopeUnder{i}`] = React.createElement(FreeLine, {
			Pos0 = contentSize * Vector2.new(p0.X, p0.Y + kp0.Envelope),
			Pos1 = contentSize * Vector2.new(p1.X, p1.Y + kp1.Envelope),
			Color = theme:GetColor(ENVELOPE_COLOR_STYLE),
			Transparency = ENVELOPE_TRANSPARENCY,
			ZIndex = 1,
			Disabled = props.Disabled,
		})
	end

	local axisLabels: { [string]: React.ReactNode } = {}
	for row = 1, GRID_ROWS do
		axisLabels[`AxisLabelRow{row}`] = React.createElement(AxisLabel, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(0, -5, 1 - row / GRID_ROWS, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Value = row / GRID_ROWS,
			Disabled = props.Disabled,
		})
	end
	for col = 1, GRID_COLS do
		axisLabels[`AxisLabelCol{col}`] = React.createElement(AxisLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(col / GRID_COLS, 0, 1, 5),
			Value = col / GRID_COLS,
			Disabled = props.Disabled,
		})
	end
	axisLabels["AxisLabelZero"] = React.createElement(AxisLabel, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, -5, 1, 5),
		TextXAlignment = Enum.TextXAlignment.Right,
		Value = 0,
		Disabled = props.Disabled,
	})

	local function tryAddKeypoint(keypoint: NumberSequenceKeypoint)
		if #sequence.Keypoints == 20 then
			return
		end
		local newKeypoints = table.clone(sequence.Keypoints)
		for i = 1, #sequence.Keypoints do
			local kp0 = sequence.Keypoints[i]
			local kp1 = sequence.Keypoints[i + 1]
			if keypoint.Time >= kp0.Time and keypoint.Time <= kp1.Time then
				table.insert(newKeypoints, i + 1, keypoint)
				onChanged(NumberSequence.new(newKeypoints))
				setHoveringIndex(i + 1)
				break
			end
		end
	end

	local activeIndex = draggingIndex or hoveringIndex
	local activeKeypoint = if activeIndex then sequence.Keypoints[activeIndex] else nil

	local minTime, maxTime
	if activeKeypoint then
		local i = activeIndex :: number
		local before = sequence.Keypoints[i - 1]
		local after = sequence.Keypoints[i + 1]
		minTime = if not after then 1 elseif not before then 0 else before.Time
		maxTime = if not before then 0 elseif not after then 1 else after.Time
	end

	local minValue = 0
	local maxValue = 1

	local minEnvelope = 0
	local maxEnvelope
	if activeKeypoint then
		local current = activeKeypoint :: NumberSequenceKeypoint
		maxEnvelope = math.min(current.Value, 1 - current.Value)
	end

	local function updateKeypoint(keypointProps: {
		Time: number?,
		Value: number?,
		Envelope: number?,
	})
		local current = activeKeypoint :: NumberSequenceKeypoint
		local newKeypoints = table.clone(sequence.Keypoints)
		newKeypoints[activeIndex :: number] = NumberSequenceKeypoint.new(
			keypointProps.Time or current.Time,
			keypointProps.Value or current.Value,
			keypointProps.Envelope or current.Envelope
		)
		onChanged(NumberSequence.new(newKeypoints))
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or Constants.DefaultNumberSequencePickerSize,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, PickerConstants.EnvelopeHandleHeight + 1),
			PaddingRight = UDim.new(0, PickerConstants.EnvelopeHandleHeight + 1),
			PaddingTop = UDim.new(0, PickerConstants.EnvelopeHandleHeight + 1),
			PaddingBottom = UDim.new(0, 10),
		}),

		ContentArea = React.createElement("Frame", {
			Position = UDim2.fromOffset(22, 0), -- axis labels
			Size = UDim2.fromScale(1, 1)
				- UDim2.fromOffset(0, PickerConstants.EnvelopeHandleHeight + 4 + Constants.DefaultInputHeight)
				- UDim2.fromOffset(22, 10) -- axis labels
				- UDim2.fromOffset(1, 1), -- outer/lower border
			BackgroundTransparency = 1,
			[React.Change.AbsolutePosition] = function(rbx: Frame)
				setContentPos(rbx.AbsolutePosition)
			end,
			[React.Change.AbsoluteSize] = function(rbx: Frame)
				setContentSize(rbx.AbsoluteSize)
			end,
			[React.Event.InputBegan] = function(rbx: Frame, input: InputObject)
				if not draggingIndex and input.UserInputType == Enum.UserInputType.MouseButton1 then
					local offset = Vector2.new(input.Position.X, input.Position.Y) - rbx.AbsolutePosition
					offset = offset / rbx.AbsoluteSize
					offset = clampVector2(offset, Vector2.zero, Vector2.one)
					local newKeypoint = NumberSequenceKeypoint.new(offset.X, 1 - offset.Y)
					tryAddKeypoint(newKeypoint)
				end
			end :: () -> (),
		}, borders, points, lines, envelopes, axisLabels),

		ControlsArea = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, Constants.DefaultInputHeight),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 15),
			}),
			Time = React.createElement(LabelledNumericInput, {
				LayoutOrder = 1,
				Label = "Time",
				Min = minTime,
				Max = maxTime,
				Value = if activeKeypoint then activeKeypoint.Time else nil,
				Disabled = not activeIndex or activeIndex <= 1 or activeIndex >= #sequence.Keypoints,
				OnChanged = identity,
				OnSubmitted = function(newTime)
					updateKeypoint({ Time = math.clamp(newTime, minTime, maxTime) })
				end,
			}),
			Value = React.createElement(LabelledNumericInput, {
				LayoutOrder = 2,
				Label = "Value",
				Min = minValue,
				Max = maxValue,
				Value = if activeKeypoint then activeKeypoint.Value else nil,
				OnChanged = identity,
				OnSubmitted = function(newValue)
					updateKeypoint({ Value = math.clamp(newValue, minValue, maxValue) })
				end,
			}),
			Envelope = React.createElement(LabelledNumericInput, {
				LayoutOrder = 3,
				Label = "Envelope",
				Min = minEnvelope,
				Max = maxEnvelope,
				Value = if activeKeypoint then activeKeypoint.Envelope else nil,
				OnChanged = identity,
				OnSubmitted = function(newEnvelope)
					updateKeypoint({ Envelope = math.clamp(newEnvelope, minEnvelope, maxEnvelope) })
				end,
			}),
			Delete = React.createElement("Frame", {
				LayoutOrder = 4,
				Size = UDim2.new(0, 105, 1, 0),
				BackgroundTransparency = 1,
			}, {
				Button = React.createElement(Button, {
					Position = UDim2.fromOffset(0, 1),
					Size = UDim2.new(1, 0, 1, -2),
					Text = "Delete Keypoint",
					Disabled = activeKeypoint == nil or activeIndex <= 1 or activeIndex >= #sequence.Keypoints,
					OnActivated = function()
						if activeIndex then
							local newKeypoints = table.clone(sequence.Keypoints)
							table.remove(newKeypoints, activeIndex)
							onChanged(NumberSequence.new(newKeypoints))
						end
					end,
				}),
			}),
		}),
	})
end

return NumberSequencePicker
