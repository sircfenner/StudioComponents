local React = require("@pkg/@jsdotlua/react")

export type PluginContext = {
	plugin: Plugin,
	pushMouseIcon: (icon: string) -> string,
	popMouseIcon: (id: string) -> (),
}

return React.createContext(nil :: PluginContext?)
