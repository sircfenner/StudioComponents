--[=[
	@class LoadingDots

	A basic animated loading indicator. This matches similar indicators used in various places 
	around Studio. This should be used for short processes where the user does not need to see
	information about how complete the loading is. For longer or more detailed loading processes, 
	consider using a [ProgressBar].
	
	| Dark | Light |
	| - | - |
	| ![Dark](/StudioComponents/components/loadingdots/dark.gif) | ![Light](/StudioComponents/components/loadingdots/light.gif) |

	Example of usage:

	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.LoadingDots, {})
	end
	```
]=]

local RunService = game:GetService("RunService")

local React = require("@pkg/@jsdotlua/react")

local CommonProps = require("../CommonProps")
local useTheme = require("../Hooks/useTheme")

--[=[
	@within LoadingDots
	@interface Props
	@tag Component Props

	@field ... CommonProps
]=]

type LoadingDotsProps = CommonProps.T

local function Dot(props: {
	LayoutOrder: number,
	Transparency: React.Binding<number>,
	Disabled: boolean?,
})
	local theme = useTheme()

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
		BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder),
		BackgroundTransparency = if props.Disabled then 0.75 else props.Transparency,
	})
end

local function LoadingDots(props: LoadingDotsProps)
	local clockBinding, setClockBinding = React.useBinding(os.clock())
	React.useEffect(function()
		local connection = RunService.Heartbeat:Connect(function()
			setClockBinding(os.clock())
		end)
		return function()
			return connection:Disconnect()
		end
	end, {})

	local alphaBinding = clockBinding:map(function(clock: number)
		return clock % 1
	end)

	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
		}),
		Dot0 = React.createElement(Dot, {
			LayoutOrder = 0,
			Transparency = alphaBinding,
			Disabled = props.Disabled,
		}),
		Dot1 = React.createElement(Dot, {
			LayoutOrder = 1,
			Transparency = alphaBinding:map(function(alpha: number)
				return (alpha - 0.2) % 1
			end),
			Disabled = props.Disabled,
		}),
		Dot2 = React.createElement(Dot, {
			LayoutOrder = 2,
			Transparency = alphaBinding:map(function(alpha: number)
				return (alpha - 0.4) % 1
			end),
			Disabled = props.Disabled,
		}),
	})
end

return LoadingDots
