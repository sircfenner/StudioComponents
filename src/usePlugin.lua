local PluginContext = require(script.Parent.PluginContext)

local function usePlugin(hooks)
	return hooks.useContext(PluginContext)
end

return usePlugin
