local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--[[
1. onInputBegan
	setState({ Dragging = true })
	if widget then
		globalConnection = RunService.Heartbeat(() => onInput(widget.relativePosition))
	else
		globalConnection = InputService.InputChanged(() => onInput(input.Position))

2. onInputEnded
	setState({ Dragging = false })
	globalConnection:Disconnect()

3. onInputChanged
	if state.Dragging then
		onInput(input.Position)

guiObject.InputBegan(onInputBegan)
guiObject.InputEnded(onInputEnded)
guiObject.InputChanged(onInputChanged)

(3) is useful in the widget case because
- heartbeat is a frame late
- changed will fire on same frame at least while mouse is over the area
- so we only get frame-late input when mouse is outside the area
--]]

local function getDragInput(callback)
	local dragging = false
	local globalConnection = nil

	local function cleanup()
		if globalConnection then
			globalConnection:Disconnect()
			globalConnection = nil
		end
	end

	local function process(rbx, position)
		local offset = position - rbx.AbsolutePosition
		local alpha = offset / rbx.AbsoluteSize
		alpha = Vector2.new(math.clamp(alpha.x, 0, 1), math.clamp(alpha.y, 0, 1))
		callback(alpha)
	end

	local function began(rbx, input)
		if dragging or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragging = true
		process(rbx, Vector2.new(input.Position.x, input.Position.y))

		local widget = rbx:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
		if widget ~= nil then
			globalConnection = RunService.Heartbeat:Connect(function()
				process(rbx, widget:GetRelativeMousePosition())
			end)
		else
			globalConnection = UserInputService.InputChanged:Connect(function(newInput)
				if newInput.UserInputType == Enum.UserInputType.MouseMovement then
					process(rbx, Vector2.new(newInput.Position.x, newInput.Position.y))
				end
			end)
		end
	end

	local function ended(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			cleanup()
		end
	end

	local function changed(rbx, input)
		if dragging then
			process(rbx, Vector2.new(input.Position.x, input.Position.y))
		end
	end

	return {
		cleanup = cleanup,
		began = began,
		ended = ended,
		changed = changed,
	}
end

return getDragInput
