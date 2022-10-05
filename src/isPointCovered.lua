local function inRange(a, point)
	local aSize = a.AbsoluteSize
	local aPosition = a.AbsolutePosition

	return point.X > aPosition.X
		and point.X < aPosition.X + aSize.X
		and point.Y > aPosition.Y
		and point.Y < aPosition.Y + aSize.Y
end

local function isPointCovered(target, mousePosition)
	local parent = target.Parent

	if parent == nil then
		return true
	end

	local siblings = parent:GetChildren()
	local indexImAt = table.find(siblings, target)

	local function helper(descendant)
		if not descendant:IsA("GuiObject") then
			return false
		end

		if not descendant.Visible then
			return false
		end

		if descendant.BackgroundTransparency == 1 then
			return false
		end

		if inRange(descendant, mousePosition) then
			return true
		end

		for _, possibleDescendant in descendant:GetChildren() do
			if helper(possibleDescendant) then
				return true
			end
		end

		return false
	end

	for possibleIndex, possible in parent:GetChildren() do
		if possible == target then
			continue
		end

		if not possible:IsA("GuiObject") then
			continue
		end

		if not possible.visible then
			continue
		end

		if possible.BackgroundTransparency == 1 then
			continue
		end

		if possible.ZIndex < target.ZIndex then
			continue
		end

		if inRange(possible, mousePosition) then
			if possible.ZIndex > target.ZIndex then
				return true
			else
				-- Roblox tiebreaks by whoever was last in the child list
				-- gets rendered last.
				if possibleIndex > indexImAt then
					return true
				end
			end
		end

		if not possible.ClipsDescendants then
			for _, possibleDescendant in possible:GetChildren() do
				if helper(possibleDescendant) then
					return true
				end
			end
		end
	end

	local root = target
	local beforeRoot

	while root.Parent and not root:IsA("LayerCollector") do
		beforeRoot = root
		root = root.Parent
	end

	local rootChildren = root:GetChildren()
	local beforeRootIndex = table.find(rootChildren, beforeRoot)

	for possibleIndex, possibleCoverer in root:GetChildren() do
		if possibleCoverer == beforeRoot then
			continue
		end

		if possibleCoverer.ZIndex < beforeRoot.ZIndex then
			continue
		end

		if possibleCoverer.ZIndex == beforeRoot.ZIndex then
			if possibleIndex < beforeRootIndex then
				continue
			end
		end

		if helper(possibleCoverer) then
			return true
		end
	end

	return false
end

return isPointCovered
