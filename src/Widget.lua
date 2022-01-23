local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local plugin = script:FindFirstAncestorWhichIsA("Plugin")
local withTheme = require(script.Parent.withTheme)

local Widget = Roact.Component:extend("Widget")

Widget.defaultProps = {
	Title = "Widget.defaultProps.Title",
	Name = "Widget.defaultProps.Name",
	InitialDockState = Enum.InitialDockState.Float,
	FloatingWindowSize = Vector2.new(300, 200),
	MinimumWindowSize = Vector2.new(0, 0),
	OnClosed = function() end,
}

function Widget:init()
	local initProps = self.props

	local id = initProps.Id
	local info = DockWidgetPluginGuiInfo.new(
		initProps.InitialDockState,
		true, -- InitialEnabled (TODO)
		true, -- InitialEnabledShouldOverrideRestore (TODO)
		initProps.FloatingWindowSize.x,
		initProps.FloatingWindowSize.y,
		initProps.MinimumWindowSize.x,
		initProps.MinimumWindowSize.y
	)

	local widget = plugin:CreateDockWidgetPluginGui(id, info)
	widget.Name = initProps.Name
	widget.Title = initProps.Title
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	widget:BindToClose(function()
		widget.Enabled = false
		self.props.OnClosed()
	end)

	self.widget = widget
end

function Widget:willUnmount()
	self.widget:Destroy()
	self.widget = nil
end

function Widget:didUpdate(prevProps)
	local nextProps = self.props
	if prevProps.Title ~= nextProps.Title then
		self.widget.Title = nextProps.Title -- TODO: clean this up
	end
end

function Widget:render()
	return Roact.createElement(Roact.Portal, {
		target = self.widget,
	}, {
		Main = withTheme(function(theme)
			return Roact.createElement("Frame", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
			}, self.props[Roact.Children])
		end),
	})
end

return Widget
