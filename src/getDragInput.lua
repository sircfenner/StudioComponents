local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- UserInputService does not work inside widgets. So, we have to poll on every render step for whenever the mouse
-- moves on RenderStepped, ensuring we're not a frame late.
local function getDragInput(callback)
	local globalConnection
	local dragging = false

	local function clean()
		if globalConnection then
			globalConnection:Disconnect()
			globalConnection = nil
		end
	end

	local function began(rbx, input)
		if dragging or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		dragging = true

		local widget = rbx:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
		callback(rbx, Vector2.new(input.Position.x, input.Position.y))

		if widget ~= nil then
			local lastPosition = widget:GetRelativeMousePosition()

			globalConnection = RunService.RenderStepped:Connect(function()
				local newPosition = widget:GetRelativeMousePosition()
				if newPosition == lastPosition then
					return
				end

				callback(rbx, newPosition)
				lastPosition = newPosition
			end)
		else
			globalConnection = UserInputService.InputChanged:Connect(function(newInput)
				if newInput.UserInputType == Enum.UserInputType.MouseMovement then
					callback(rbx, Vector2.new(newInput.Position.x, newInput.Position.y))
				end
			end)
		end
	end

	local function ended(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			callback(rbx, Vector2.new(input.Position.x, input.Position.y))
			dragging = false
			clean()
		end
	end

	local function forceEnd()
		dragging = false
		clean()
	end

	return {
		began = began,
		ended = ended,
		forceEnd = forceEnd,
		clean = clean,
	}
end

return getDragInput
