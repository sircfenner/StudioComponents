--[=[
	@class ColorPicker
	An interface for selecting a color with a Hue / Saturation box and a Value slider.
	Individual RGB and HSV values can also be modified manually.

	| Dark | Light |
	| - | - |
	| ![Dark](/components/colorpicker/dark.png) | ![Light](/components/colorpicker/light.png) |

	This is a controlled component, which means the current color should be passed in to the
	`Color` prop and a callback value to the `OnChanged` prop which gets run when the user attempts 
	to change the color. For example:

	```lua
	local function MyComponent()
		local color, setColor = React.useState(Color3.fromHex("#008080"))
		return React.createElement(StudioComponents.ColorPicker, {
			Value = color,
			OnChanged = setColor,
		})
	end
	```
	
	The default size of this component is exposed in [Constants.DefaultColorPickerSize].
	To keep all inputs accessible, it is recommended not to use a smaller size than this.

	This component is not a modal or dialog box (this should be implemented separately).
]=]

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local Constants = require("../Constants")

local Label = require("./Label")
local NumericInput = require("./NumericInput")

local useMouseDrag = require("../Hooks/useMouseDrag")
local useTheme = require("../Hooks/useTheme")

local function clampVector2(v: Vector2, vmin: Vector2, vmax: Vector2)
	return Vector2.new(math.clamp(v.X, vmin.X, vmax.X), math.clamp(v.Y, vmin.Y, vmax.Y))
end

--[=[
	@within ColorPicker
	@interface Props
	@tag Component Props

	@field ... CommonProps
	@field Color Color3
	@field OnChanged ((newColor: Color3) -> ())?
]=]

type ColorPickerProps = CommonProps.T & {
	Color: Color3,
	OnChanged: ((newColor: Color3) -> ())?,
}

local SPLIT_Y = 76
local SPLIT_X = 50
local PADDING = 8

local function generateHueKeypoints(value: number)
	local keypoints = {}
	local regions = 6
	for hue = 0, regions do
		local offset = hue / regions
		local color = Color3.fromHSV((regions - hue) / regions, 1, value)
		table.insert(keypoints, ColorSequenceKeypoint.new(offset, color))
	end
	return ColorSequence.new(keypoints)
end

local noop = function() end

local function ValPicker(props: {
	HSV: { number },
	OnChanged: (hue: number, sat: number, val: number) -> (),
	Disabled: boolean?,
})
	local theme = useTheme()

	local hue, sat, val = unpack(props.HSV)
	local drag = useMouseDrag(function(rbx: GuiObject, input: InputObject)
		local mousePos = input.Position.Y
		local alpha = (mousePos - rbx.AbsolutePosition.Y) / rbx.AbsoluteSize.Y
		alpha = math.clamp(alpha, 0, 1)
		props.OnChanged(hue, sat, 1 - alpha)
	end, { hue, sat, val, props.OnChanged } :: { unknown })

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
		end
	end, { props.Disabled, drag.isActive() })

	local gradientTarget = Color3.fromHSV(hue, sat, 1)

	return React.createElement("TextButton", {
		Active = false,
		AutoButtonColor = false,
		Text = "",
		Size = UDim2.new(0, 14, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 0),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = if props.Disabled then 0.75 else 0,
		[React.Event.InputBegan] = if not props.Disabled then drag.onInputBegan else nil,
		[React.Event.InputChanged] = if not props.Disabled then drag.onInputChanged else nil,
		[React.Event.InputEnded] = if not props.Disabled then drag.onInputEnded else nil,
	}, {
		Gradient = React.createElement("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), gradientTarget),
			Rotation = 270,
		}),
		Arrow = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(5, 9),
			Position = UDim2.new(1, 1, 1 - val, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://7507468017",
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText),
			Visible = not props.Disabled,
		}),
		Cover = props.Disabled and React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BackgroundTransparency = 0.5,
			ZIndex = 2,
		}),
	})
end

local function HueSatPicker(props: {
	HSV: { number },
	OnChanged: (hue: number, sat: number, val: number) -> (),
	Disabled: boolean?,
})
	local theme = useTheme()

	local hue, sat, val = unpack(props.HSV)
	local bgVal = 220 / 255 -- used to just use val but was weird when val was low
	local indicatorBackground = if bgVal > 0.4 then Color3.new(0, 0, 0) else Color3.fromRGB(200, 200, 200)

	local drag = useMouseDrag(function(rbx: GuiObject, input: InputObject)
		local mousePos = Vector2.new(input.Position.X, input.Position.Y)
		local alpha = (mousePos - rbx.AbsolutePosition) / rbx.AbsoluteSize
		alpha = clampVector2(alpha, Vector2.zero, Vector2.one)
		props.OnChanged(1 - alpha.X, 1 - alpha.Y, val)
	end, { hue, sat, val, props.OnChanged } :: { unknown })

	React.useEffect(function()
		if props.Disabled and drag.isActive() then
			drag.cancel()
		end
	end, { props.Disabled, drag.isActive() })

	return React.createElement("TextButton", {
		Size = UDim2.new(1, -30, 1, 0),
		ClipsDescendants = true,
		AutoButtonColor = false,
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
		BackgroundTransparency = if props.Disabled then 0.75 else 0,
		Active = false,
		Text = "",
		[React.Event.InputBegan] = if not props.Disabled then drag.onInputBegan else nil,
		[React.Event.InputChanged] = if not props.Disabled then drag.onInputChanged else nil,
		[React.Event.InputEnded] = if not props.Disabled then drag.onInputEnded else nil,
	}, {
		Hue = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0,
		}, {
			Gradient = React.createElement("UIGradient", {
				Color = generateHueKeypoints(bgVal),
			}),
		}),
		Sat = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
		}, {
			Gradient = React.createElement("UIGradient", {
				Color = ColorSequence.new(Color3.fromHSV(1, 0, bgVal)),
				Transparency = NumberSequence.new(1, 0),
				Rotation = 90,
			}),
		}),
		Indicator = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1 - hue, 0, 1 - sat, 0),
			Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Visible = not props.Disabled,
		}, {
			Vertical = React.createElement("Frame", {
				Position = UDim2.fromOffset(9, 0),
				Size = UDim2.new(0, 2, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = indicatorBackground,
			}),
			Horizontal = React.createElement("Frame", {
				Position = UDim2.fromOffset(0, 9),
				Size = UDim2.new(1, 0, 0, 2),
				BorderSizePixel = 0,
				BackgroundColor3 = indicatorBackground,
			}),
		}),
		Cover = props.Disabled and React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BackgroundTransparency = 0.5,
			ZIndex = 3,
		}),
	})
end

local function ColorControl(props: {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Label: string,
	Value: number,
	Max: number,
	Callback: (n: number) -> (),
	Disabled: boolean?,
})
	local div = 28
	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = UDim2.new(0.5, -PADDING, 0, Constants.DefaultInputHeight),
		BackgroundTransparency = 1,
	}, {
		Label = React.createElement(Label, {
			Text = `{props.Label}:`,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, div, 1, 0),
			Disabled = props.Disabled,
		}),
		Input = React.createElement(NumericInput, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(1, -div - 5, 1, 0),
			Value = props.Value,
			Min = 0,
			Max = props.Max,
			OnValidChanged = props.Callback,
			Arrows = true,
			Disabled = props.Disabled,
		}),
	})
end

local function ColorControls(props: {
	HSV: { number },
	RGB: { number },
	OnChangedHSV: (hue: number, sat: number, val: number) -> (),
	OnChangedRGB: (red: number, green: number, blue: number) -> (),
	Disabled: boolean?,
})
	local hue, sat, val = unpack(props.HSV)
	local red, green, blue = unpack(props.RGB)

	return React.createElement("Frame", {
		Size = UDim2.new(1, -SPLIT_X - PADDING, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
	}, {
		Hue = React.createElement(ColorControl, {
			AnchorPoint = Vector2.new(0, 0),
			Label = "Hue",
			Value = math.round(hue * 360),
			Max = 360,
			Callback = function(newHue)
				props.OnChangedHSV(newHue / 360, sat, val)
			end,
			Disabled = props.Disabled,
		}),
		Sat = React.createElement(ColorControl, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Label = "Sat",
			Value = math.round(sat * 255),
			Max = 255,
			Callback = function(newSat)
				props.OnChangedHSV(hue, newSat / 255, val)
			end,
			Disabled = props.Disabled,
		}),
		Val = React.createElement(ColorControl, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Label = "Val",
			Value = math.round(val * 255),
			Max = 255,
			Callback = function(newVal)
				props.OnChangedHSV(hue, sat, newVal / 255)
			end,
			Disabled = props.Disabled,
		}),
		Red = React.createElement(ColorControl, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Label = "Red",
			Value = math.round(red * 255),
			Max = 255,
			Callback = function(newRed)
				props.OnChangedRGB(newRed / 255, green, blue)
			end,
			Disabled = props.Disabled,
		}),
		Green = React.createElement(ColorControl, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Label = "Green",
			Value = math.round(green * 255),
			Max = 255,
			Callback = function(newGreen)
				props.OnChangedRGB(red, newGreen / 255, blue)
			end,
			Disabled = props.Disabled,
		}),
		Blue = React.createElement(ColorControl, {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			Label = "Blue",
			Value = math.round(blue * 255),
			Max = 255,
			Callback = function(newBlue)
				props.OnChangedRGB(red, green, newBlue / 255)
			end,
			Disabled = props.Disabled,
		}),
	})
end

local function ColorPicker(props: ColorPickerProps)
	local theme = useTheme()
	local onChanged: (color: Color3) -> () = props.OnChanged or noop

	-- avoids information loss when converting hsv -> rgb -> hsv between renders
	local hsv, setHSV = React.useState({ props.Color:ToHSV() })
	React.useEffect(function()
		setHSV(function(oldHSV)
			if Color3.fromHSV(unpack(oldHSV)) ~= props.Color then
				return { props.Color:ToHSV() }
			end
			return oldHSV
		end)
	end, { props.Color })

	local pickerProps = {
		HSV = hsv,
		OnChanged = function(hue, sat, val)
			setHSV({ hue, sat, val })
			onChanged(Color3.fromHSV(hue, sat, val))
		end,
		Disabled = props.Disabled,
	}

	local modifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	end

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or Constants.DefaultColorPickerSize,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, modifier),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
		BorderMode = Enum.BorderMode.Inset,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, PADDING),
			PaddingRight = UDim.new(0, PADDING),
			PaddingTop = UDim.new(0, PADDING),
			PaddingBottom = UDim.new(0, PADDING),
		}),
		TopArea = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -SPLIT_Y - PADDING),
			BackgroundTransparency = 1,
		}, {
			ValPicker = React.createElement(ValPicker, pickerProps),
			HueSatPicker = React.createElement(HueSatPicker, pickerProps),
		}),
		BtmArea = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Size = UDim2.new(1, 0, 0, SPLIT_Y),
			Position = UDim2.fromScale(0, 1),
			BackgroundTransparency = 1,
		}, {
			Preview = React.createElement("Frame", {
				Size = UDim2.new(0, SPLIT_X, 1, 0),
				BackgroundTransparency = if props.Disabled then 0.75 else 0,
				BackgroundColor3 = props.Color,
				BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			}),
			Controls = React.createElement(ColorControls, {
				HSV = hsv,
				RGB = { props.Color.R, props.Color.G, props.Color.B },
				OnChangedHSV = pickerProps.OnChanged,
				OnChangedRGB = function(red, green, blue)
					onChanged(Color3.new(red, green, blue))
				end,
				Disabled = props.Disabled,
			}),
		}),
	})
end

return ColorPicker
