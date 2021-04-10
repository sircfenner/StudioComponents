local function joinDictionaries(...)
	local out = {}
	for i = 1, select("#", ...) do
		for key, val in pairs(select(i, ...)) do
			out[key] = val
		end
	end
	return out
end

return joinDictionaries
