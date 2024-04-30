--[=[
	@within Dropdown
	@type DropdownItem string | DropdownItemDetail
]=]

export type DropdownItem = string | DropdownItemDetail

--[=[
	@within Dropdown
	@interface DropdownItemDetail

	@field Id string
	@field Text string
	@field Icon DropdownItemIcon?
]=]

export type DropdownItemDetail = {
	Id: string,
	Text: string,
	Icon: DropdownItemIcon?,
}

--[=[
	@within Dropdown
	@interface DropdownItemIcon

	@field Image string
	@field Size Vector2
	@field Transparency number?
	@field Color Color3?
	@field UseThemeColor boolean?
]=]

export type DropdownItemIcon = {
	Image: string,
	Size: Vector2,
	Transparency: number?,
	Color: Color3?,
	UseThemeColor: boolean?,
}

return {}
