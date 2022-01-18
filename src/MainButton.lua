local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local joinDictionaries = require(script.Parent.joinDictionaries)
local BaseButton = require(script.Parent.BaseButton)

local function MainButton(props)
	return Roact.createElement(
		BaseButton,
		joinDictionaries({
			TextColorStyle = Enum.StudioStyleGuideColor.DialogMainButtonText,
			BackgroundColorStyle = Enum.StudioStyleGuideColor.DialogMainButton,
			BorderColorStyle = Enum.StudioStyleGuideColor.ButtonBorder,
		}, props)
	)
end

return MainButton
