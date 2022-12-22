local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local TextInput = require(script.Parent.TextInput)
local Label = require(script.Parent.Label)

local function Helper(props, hooks)
	local parsingError, setParsingError = hooks.useState()
	local number, setNumber = hooks.useState(0)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		StatusText = Roact.createElement(Label, {
			Size = UDim2.new(1, 0, 0, 21),
			LayoutOrder = 0,
			Text = parsingError or "Valid number!",
			TextColorStyle = if parsingError then Enum.StudioStyleGuideColor.ErrorText else nil,
		}),
		Input = Roact.createElement(TextInput, {
			Value = number,
			ResetOnInvalid = true,
			PlaceholderText = "Enabled",
			LayoutOrder = 1,
			TryParsing = function(text)
				local value = tonumber(text)

				if value then
					return true, value
				else
					return false, "Invalid number!"
				end
			end,
			OnChangedInvalid = setParsingError,
			OnChanged = function(value)
				if parsingError then
					setParsingError(Roact.None)
				end

				setNumber(value)
			end,
		}),
	})
end

Helper = Hooks.new(Roact)(Helper)

return function(target)
	local element = Roact.createElement(Helper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
