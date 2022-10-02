local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local Hooks = require(Packages.RoactHooks)

local usePlugin = require(script.Parent.usePlugin)
local useTheme = require(script.Parent.useTheme)

local defaultProps = {
	Title = "Widget.defaultProps.Title",
	Name = "Widget.defaultProps.Name",
	InitialDockState = Enum.InitialDockState.Float,
	InitialEnabledShouldOverrideRestore = true,
	InitialEnabled = true,
	FloatingWindowSize = Vector2.new(300, 200),
	MinimumWindowSize = Vector2.new(0, 0),
	OnClosed = function() end,
}

local function Widget(props, hooks)
	local widget, setWidget = hooks.useState()
	local plugin = usePlugin(hooks)
	local theme = useTheme(hooks)

	hooks.useEffect(function()
		if plugin == nil then
			return
		end

		local id = props.Id
		local info = DockWidgetPluginGuiInfo.new(
			props.InitialDockState,
			true, -- InitialEnabled (TODO)
			true, -- InitialEnabledShouldOverrideRestore (TODO)
			props.FloatingWindowSize.x,
			props.FloatingWindowSize.y,
			props.MinimumWindowSize.x,
			props.MinimumWindowSize.y
		)

		local newWidget = plugin.makeWidget(id, info)
		
		newWidget.Name = props.Name
		newWidget.Title = props.Title
		newWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		newWidget.Enabled = true

		newWidget:BindToClose(function()
			newWidget.Enabled = false
			props.OnClosed()
		end)

		setWidget(newWidget)

		return function()
			-- Destroying the widget actually works.
			newWidget:Destroy()
			setWidget(nil)
		end
	end, { plugin })

	hooks.useEffect(function()
		if widget then
			widget.Title = props.Title
			widget.Name = props.Name
		end
	end, { widget, props.Title, props.Name })

	-- Can't render if there's no widget to render to.
	if widget == nil then
		return
	end

	return Roact.createElement(Roact.Portal, {
		target = widget,
	}, {
		Main = Roact.createElement("Frame", {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, props[Roact.Children]),
	})
end

return Hooks.new(Roact)(Widget, {
	defaultProps = defaultProps,
})
