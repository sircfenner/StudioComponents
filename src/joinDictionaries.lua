local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)

local function joinDictionaries(...)
	local out = {}
	for i = 1, select("#", ...) do
		for key, val in pairs(select(i, ...)) do
			if val == Roact.None then
				out[key] = nil
			else
				out[key] = val
			end
		end
	end
	return out
end

return joinDictionaries
