--[=[
	@class useMouseIcon
	
	A hook used internally by components for setting and clearing custom mouse icons. To use this
	hook, you need to also render a single [PluginProvider] somewhere higher up in the tree.

	To set the mouse icon, use the `setIcon` function and pass an asset url. All components under
	the PluginProvider that use this hook share an icon stack; the most recent component to call
	`setIcon` will have its icon set as the final mouse icon. Calling `setIcon` twice without
	clearing it in between will override the previous icon set by this component.
	
	Calling `clearIcon` removes the icon set by this component from the stack, which may mean the 
	mouse icon falls back to the next icon on the stack set by another component. Ensure you call
	`clearIcon` on unmount otherwise your icon may never get unset. For example:
	
	```lua
	local function MyComponent()
		local mouseIconApi = useMouseIcon()

		React.useEffect(function() -- clear icon on unmount
			return function()
				mouseIconApi.clearIcon()
			end
		end, {})

		return React.createElement(SomeComponent, {
			OnHoverStart = function()
				mouseIconApi.setIcon(...) -- some icon for hover
			end,
			OnHoverEnd = function()
				mouseIconApi.clearIcon()
			end
		})
	end
	```
]=]

--[=[
	@within useMouseIcon
	@interface mouseIconApi

	@field setIcon (icon: string) -> ()
	@field getIcon () -> string?
	@field clearIcon () -> ()
]=]

local React = require("@pkg/@jsdotlua/react")

local PluginContext = require("../Contexts/PluginContext")
local useFreshCallback = require("../Hooks/useFreshCallback")

local function useMouseIcon()
	local plugin = React.useContext(PluginContext)

	local lastIconId: string?, setLastIconId = React.useState(nil :: string?)
	local lastIconAssetUrl: string?, setLastIconAssetUrl = React.useState(nil :: string?)

	local function getIcon(): string?
		return lastIconAssetUrl
	end

	local function setIcon(assetUrl: string)
		if plugin ~= nil and assetUrl ~= lastIconAssetUrl then
			if lastIconId ~= nil then
				plugin.popMouseIcon(lastIconId)
			end
			local newId = plugin.pushMouseIcon(assetUrl)
			setLastIconId(newId)
			setLastIconAssetUrl(assetUrl)
		end
	end

	local clearIcon = useFreshCallback(function()
		if plugin ~= nil and lastIconId ~= nil then
			plugin.popMouseIcon(lastIconId)
			setLastIconId(nil)
			setLastIconAssetUrl(nil)
		end
	end, { lastIconId })

	React.useEffect(function()
		return clearIcon
	end, {})

	return {
		getIcon = getIcon,
		setIcon = setIcon,
		clearIcon = clearIcon,
	}
end

return useMouseIcon
