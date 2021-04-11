local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local joinDictionaries = require(script.Parent.joinDictionaries)
local BaseButton = require(script.Parent.BaseButton)

local function MainButton(props)
	return Roact.createElement(
		BaseButton,
		joinDictionaries(props, {
			TextColorStyle = Enum.StudioStyleGuideColor.DialogMainButtonText,
			BackgroundColorStyle = Enum.StudioStyleGuideColor.DialogMainButton,
			BorderColorStyle = Enum.StudioStyleGuideColor.ButtonBorder,
		})
	)
end

return MainButton
