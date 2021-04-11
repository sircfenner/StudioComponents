local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local VerticalExpandingList = require(script.Parent.VerticalExpandingList)

local CollapsibleSectionHeader = require(script.CollapsibleSectionHeader)
local VerticalCollapsibleSection = Roact.Component:extend("VerticalCollapsibleSection")

VerticalCollapsibleSection.defaultProps = {
	LayoutOrder = 0,
	ZIndex = 0,
	Collapsed = false,
	HeaderText = "VerticalCollapsibleSection.defaultProps.HeaderText",
	-- OnToggle must exist
}

function VerticalCollapsibleSection:init()
end

function VerticalCollapsibleSection:render()
	return Roact.createElement(VerticalExpandingList, {
		LayoutOrder = self.props.LayoutOrder,
		ZIndex = self.props.ZIndex,
		Padding = 1,
	}, {
		Header = Roact.createElement(CollapsibleSectionHeader, {
			Text = self.props.HeaderText,
			Collapsed = self.props.Collapsed,
			OnToggled = self.props.OnToggled,
		}),
		Content = not self.props.Collapsed and Roact.createElement(VerticalExpandingList, {
			LayoutOrder = 1,
			BorderSizePixel = 0,
		}, self.props[Roact.Children]),
	})
end

return VerticalCollapsibleSection
