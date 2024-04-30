--[=[
	@class PluginProvider
	
	This component provides an interface to plugin apis for other components in the tree. It should
	be provided with a single `Plugin` prop that must point to `plugin` (your plugin's root instance).

	You do not have to use this component unless you want custom mouse icons via the [useMouseIcon] 
	hook. Right now, the only built-in component that relies on this is [Splitter]. Theming and all
	other functionality will work regardless of whether this component is used.

	You should only render one PluginProvider in your tree. Commonly, this is done at the top of
	the tree with the rest of your plugin as children/descendants.

	Example of usage:
	
	```lua
	local function MyComponent()
		return React.createElement(StudioComponents.PluginProvider, {
			Plugin = plugin,
		}, {
			MyExample = React.createElement(MyExample, ...)
		})
	end
	```
]=]

local HttpService = game:GetService("HttpService")

local React = require("@pkg/@jsdotlua/react")

local PluginContext = require("../Contexts/PluginContext")

type IconStackEntry = {
	id: string,
	icon: string,
}

--[=[
	@within PluginProvider
	@interface Props
	@tag Component Props

	@field Plugin Plugin
	@field children React.ReactNode
]=]

type PluginProviderProps = {
	Plugin: Plugin,
	children: React.ReactNode,
}

local function PluginProvider(props: PluginProviderProps)
	local plugin = props.Plugin
	local iconStack = React.useRef({}) :: { current: { IconStackEntry } }

	local function updateMouseIcon()
		local top = iconStack.current[#iconStack.current]
		plugin:GetMouse().Icon = if top then top.icon else ""
	end

	local function pushMouseIcon(icon)
		local id = HttpService:GenerateGUID(false)
		table.insert(iconStack.current, { id = id, icon = icon })
		updateMouseIcon()
		return id
	end

	local function popMouseIcon(id)
		for i = #iconStack.current, 1, -1 do
			local item = iconStack.current[i]
			if item.id == id then
				table.remove(iconStack.current, i)
			end
		end
		updateMouseIcon()
	end

	React.useEffect(function()
		return function()
			table.clear(iconStack.current)
			plugin:GetMouse().Icon = ""
		end
	end, {})

	return React.createElement(PluginContext.Provider, {
		value = {
			plugin = plugin,
			pushMouseIcon = pushMouseIcon,
			popMouseIcon = popMouseIcon,
		},
	}, props.children)
end

return PluginProvider
