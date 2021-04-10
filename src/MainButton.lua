local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local joinDictionaries = require(script.Parent.joinDictionaries)
local BaseButton = require(script.Parent.BaseButton)

local function MainButton(props)
	return Roact.createElement(
		BaseButton,
		joinDictionaries(props, {
			TextStyleColor = Enum.StudioStyleGuideColor.DialogMainButtonText,
			BackgroundStyleColor = Enum.StudioStyleGuideColor.DialogMainButton,
			BorderStyleColor = Enum.StudioStyleGuideColor.ButtonBorder,
		})
	)
end

return MainButton
