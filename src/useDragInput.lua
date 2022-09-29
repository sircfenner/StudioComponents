local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function useDragInput(hooks, callback)
	local hovered, setHovered = hooks.useState(false)
	local dragging, setDragging = hooks.useState(false)

	local globalConnection = hooks.useValue(nil)
	local function cleanup()
		if globalConnection.value then
			globalConnection.value:Disconnect()
		end
	end

	hooks.useEffect(function()
		return cleanup
	end, {})

	local onInputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
			local widget = rbx:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
			if widget ~= nil then
				globalConnection.value = RunService.RenderStepped:Connect(function()
					callback(widget:GetRelativeMousePosition())
				end)
			else
				globalConnection.value = UserInputService.InputChanged:Connect(function(globalInput)
					callback(Vector2.new(globalInput.Position.x, globalInput.Position.y))
				end)
			end
			setDragging(true)
		end
	end

	local onInputEnded = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- ended for mousemovement does not fire if mouse is moved and released quickly enough
			-- over another instance, so we manually check if there is still an active hover
			local offset = Vector2.new(input.Position.x, input.Position.y) - rbx.AbsolutePosition
			local bounds = rbx.AbsoluteSize
			if offset.x < 0 or offset.x > bounds.x or offset.y < 0 or offset.y > bounds.y then
				setHovered(false)
			end
			setDragging(false)
			cleanup()
		end
	end

	return {
		hovered = hovered,
		dragging = dragging,
		onInputBegan = onInputBegan,
		onInputEnded = onInputEnded,
	}
end

return useDragInput
