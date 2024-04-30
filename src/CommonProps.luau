--[=[
	@class CommonProps
	@private

	The props listed here are accepted by every component except where explicitly noted.
	These props are accepted in addition to the props specified by components on their API pages.

	:::info
	This file is not exported and serves only to host an internal type and documentation.
	:::
]=]

--[=[
	@within CommonProps
	@interface CommonProps
	
	@field Disabled boolean?
	@field AnchorPoint Vector2?
	@field Position UDim2?
	@field Size UDim2?
	@field LayoutOrder number?
	@field ZIndex number?
]=]

export type T = {
	Disabled: boolean?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	LayoutOrder: number?,
	ZIndex: number?,
}

return {}
