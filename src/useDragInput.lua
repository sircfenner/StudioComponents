local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function useDragInput(hooks, callback)
	local hovered, setHovered = hooks.useState(false)
	local active, setActive = hooks.useState(false)

	local globalConnection = hooks.useValue(nil)
	local function cleanup()
		if globalConnection.value then
			globalConnection.value:Disconnect()
		end
	end

	-- prevent stale values in callback
	local savedCallback = hooks.useValue(callback)
	hooks.useEffect(function()
		savedCallback.value = callback
	end, { callback })

	hooks.useEffect(function()
		return cleanup
	end, {})

	local function onInputBegan(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not active then
			local widget = rbx:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
			if widget ~= nil then
				globalConnection.value = RunService.RenderStepped:Connect(function()
					savedCallback.value(rbx, widget:GetRelativeMousePosition())
				end)
			else
				globalConnection.value = UserInputService.InputChanged:Connect(function(globalInput)
					savedCallback.value(rbx, Vector2.new(globalInput.Position.x, globalInput.Position.y))
				end)
			end
			setActive(true)
			savedCallback.value(rbx, Vector2.new(input.Position.x, input.Position.y))
		end
	end

	local function onInputEnded(rbx, input)
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
			setActive(false)
			cleanup()
		end
	end

	local function cancel()
		setHovered(false)
		setActive(false)
		cleanup()
	end

	return {
		hovered = hovered,
		active = active,
		onInputBegan = onInputBegan,
		onInputEnded = onInputEnded,
		cancel = cancel,
	}
end

return useDragInput
