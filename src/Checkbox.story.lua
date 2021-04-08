local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)

local Checkbox = require(script.Parent.Checkbox)

local Wrapper = Roact.Component:extend("CheckboxWrapper")
function Wrapper:init()
	self:setState({ Value = true })
end
function Wrapper:render()
	return Roact.createElement(Checkbox, {
		Value = self.state.Value,
		Disabled = false,
		Label = "Lorem ipsum dolor sit amet",
		Alignment = Checkbox.Alignment.Left,
		OnActivated = function()
			local was = self.state.Value
			if was == true then
				self:setState({ Value = false })
			elseif was == false then
				self:setState({ Value = Checkbox.Indeterminate })
			else
				self:setState({ Value = true })
			end
		end,
	})
end

return function(target)
	local element = Roact.createElement(Wrapper)
	local handle = Roact.mount(element, target)
	return function()
		Roact.unmount(handle)
	end
end
