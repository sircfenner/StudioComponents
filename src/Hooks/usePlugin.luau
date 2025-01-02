local React = require("@pkg/@jsdotlua/react")

local PluginContext = require("../Contexts/PluginContext")

local function usePlugin()
	local pluginContext = React.useContext(PluginContext)
	return pluginContext and pluginContext.plugin
end

return usePlugin
