local function inRange(a, point)
	local aSize = a.AbsoluteSize
	local aPosition = a.AbsolutePosition

	return point.X > aPosition.X
		and point.X < aPosition.X + aSize.X
		and point.Y > aPosition.Y
		and point.Y < aPosition.Y + aSize.Y
end

local function buildAncestoryToTheFirst(class, from)
	local target = from:FindFirstAncestorWhichIsA(class)

	if not target then
		return nil
	end

	local ancestory = {}
	local temp = from

	while temp ~= target do
		table.insert(ancestory, 1, temp)
		temp = temp.Parent
	end
	table.insert(ancestory, 1, temp)

	return ancestory
end

local function isPointCovered(target, mousePosition)
	local root = target:FindFirstAncestorWhichIsA("LayerCollector")
	if not root then
		error("Not parented correctly.")
	end
	
	-- An important assumption made is that the LayerCollector has a sibling ZIndexBehavior.
	if root.ZIndexBehavior ~= Enum.ZIndexBehavior.Sibling then
		error("Only Sibling ZIndexBehavior is supported.")
	end

	-- Path from the root to our target.
	-- Needed to know which way our target is from the root.
	local ancestory = buildAncestoryToTheFirst("LayerCollector", target)

	local function helper(descendant)
		local imPlacedWhere = table.find(ancestory, descendant)
		local nextTowardsTarget = if imPlacedWhere then ancestory[imPlacedWhere + 1] else nil

		-- We're the target, we don't need to test ourselves.
		if imPlacedWhere and nextTowardsTarget == nil then
			return false
		end

		local myChildren = descendant:GetChildren()
		local nextTowardsTargetIndex = if nextTowardsTarget then table.find(myChildren, nextTowardsTarget) else nil

		for possibleIndex, possibleCoverer in myChildren do
			if possibleIndex == nextTowardsTargetIndex then
				continue
			end

			-- Non-gui objects can't cover.
			if not possibleCoverer:IsA("GuiObject") then
				continue
			end

			-- Visible being false hides all descendants.
			if not possibleCoverer.Visible then
				continue
			end

			if nextTowardsTarget then
				-- If the child towards the target is on top, then we continue on since it cannot be covered.
				if nextTowardsTarget.ZIndex > possibleCoverer.ZIndex then
					continue
				end

				-- Roblox solve tiebreakers by what order :GetChildren returns.
				-- If we're last, then we'll be the last to be drawn. Hence, on top.
				if possibleCoverer.ZIndex == nextTowardsTarget.ZIndex and nextTowardsTargetIndex > possibleIndex then
					continue
				end

				-- At this point, it's known that the possibleCoverer is on top.
				-- But, we don't know if it will cover for sure.

				-- Transparent means that the potential coverer can't cover.
				-- However, its desecendants can!
				if possibleCoverer.BackgroundTransparency == 1 then
					if helper(possibleCoverer) then
						return true
					end
				end
			end
	
			-- This path only happens if we could be covering the target.
			-- Now, we have to check if it covers.
			if inRange(possibleCoverer, mousePosition) then
				return true

				-- Even if it doesn't cover, not clipping means its descendants can.
			elseif possibleCoverer.ClipsDescendants == false then
				if helper(possibleCoverer) then
					return true
				end
			end
		end

		return false
	end

	return helper(root)
end

return isPointCovered
