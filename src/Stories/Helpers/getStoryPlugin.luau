--!nocheck
--!nolint UnknownGlobal

-- selene: allow(undefined_variable)
local plugin = PluginManager():CreatePlugin()

return function()
	return plugin
end
