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

	-- cleanup on unmount
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
					callback(rbx, widget:GetRelativeMousePosition())
				end)
			else
				globalConnection.value = UserInputService.InputChanged:Connect(function(globalInput)
					callback(rbx, Vector2.new(globalInput.Position.x, globalInput.Position.y))
				end)
			end
			setDragging(true)
			callback(rbx, Vector2.new(input.Position.x, input.Position.y))
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

	local cancel = function()
		setHovered(false)
		setDragging(false)
		cleanup()
	end

	return {
		hovered = hovered,
		dragging = dragging,
		onInputBegan = onInputBegan,
		onInputEnded = onInputEnded,
		cancel = cancel,
	}
end

return useDragInput
