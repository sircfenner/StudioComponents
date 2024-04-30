local React = require("@pkg/@jsdotlua/react")

local useTheme = require("../../Hooks/useTheme")

type ClearButtonProps = {
	Size: UDim2,
	Position: UDim2,
	AnchorPoint: Vector2,
	OnActivated: () -> (),
}

local function ClearButton(props: ClearButtonProps)
	local theme = useTheme()
	local hovered, setHovered = React.useState(false)

	return React.createElement("TextButton", {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Text = "",
		[React.Event.InputBegan] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(true)
			end
		end,
		[React.Event.InputEnded] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setHovered(false)
			end
		end,
		[React.Event.Activated] = function()
			props.OnActivated()
		end,
	}, {
		Icon = React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			Image = "rbxassetid://16969027907",
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
			ImageTransparency = if hovered then 0 else 0.6,
			BackgroundTransparency = 1,
		}),
	})
end

return ClearButton
