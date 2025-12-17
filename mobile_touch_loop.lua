local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local VirtualInputManager = game:GetService("VirtualInputManager")
local clickingEnabled = true

-- ================= PAINEL ARRASTÁVEL =================
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 210, 0, 120)
panel.Position = UDim2.new(0.05, 0, 0.6, 0)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.Parent = gui
panel.Active = true

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0,12)

-- Arrastar painel (mobile)
do
	local dragging, dragStart, startPos
	panel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
		end
	end)
	panel.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	panel.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ================= BOTÕES DO PAINEL =================
local function newButton(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = UDim2.new(0, 10, 0, y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(55,55,55)
	b.TextColor3 = Color3.new(1,1,1)
	b.Parent = panel
	local c = Instance.new("UICorner", b)
	c.CornerRadius = UDim.new(0,8)
	return b
end

local addButton = newButton("➕ Adicionar bolinha", 10)
local toggleButton = newButton("⏸ DESLIGAR", 60)

-- ================= LOOP DE CLIQUE =================
local function startClick(ball)
	task.spawn(function()
		while ball.Parent do
			if clickingEnabled then
				local pos = ball.AbsolutePosition + ball.AbsoluteSize / 2
				VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
				VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
			end
			task.wait(ball.ClickDelay.Value)
		end
	end)
end

-- ================= CRIAR BOLINHA =================
addButton.MouseButton1Click:Connect(function()
	local ball = Instance.new("TextButton")
	ball.Size = UDim2.new(0, 60, 0, 60)
	ball.Position = UDim2.new(0.5, -30, 0.5, -30)
	ball.BackgroundColor3 = Color3.fromRGB(255,80,80)
	ball.Text = ""
	ball.Parent = gui
	ball.BorderSizePixel = 0
	ball.AutoButtonColor = false

	local corner = Instance.new("UICorner", ball)
	corner.CornerRadius = UDim.new(1,0)

	-- Velocidade individual
	local delayValue = Instance.new("NumberValue")
	delayValue.Name = "ClickDelay"
	delayValue.Value = 0.15
	delayValue.Parent = ball

	startClick(ball)

	-- ========== BOTÃO REMOVER ==========
	local removeBtn = Instance.new("TextButton")
	removeBtn.Size = UDim2.new(0, 20, 0, 20)
	removeBtn.Position = UDim2.new(1, -18, 0, -2)
	removeBtn.Text = "✕"
	removeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
	removeBtn.TextColor3 = Color3.new(1,1,1)
	removeBtn.BorderSizePixel = 0
	removeBtn.Parent = ball

	local rc = Instance.new("UICorner", removeBtn)
	rc.CornerRadius = UDim.new(1,0)

	removeBtn.MouseButton1Click:Connect(function()
		ball:Destroy()
	end)

	-- ========== ARRASTAR BOLINHA ==========
	local dragging, dragStart, startPos
	ball.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = ball.Position
		end
	end)
	ball.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			ball.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	ball.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- ========== DUPLO TOQUE = EDITAR VELOCIDADE ==========
	local lastTap = 0
	ball.MouseButton1Click:Connect(function()
		if tick() - lastTap < 0.35 then
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, 0, 1, 0)
			box.Text = tostring(delayValue.Value)
			box.BackgroundColor3 = Color3.fromRGB(0,0,0)
			box.TextColor3 = Color3.new(1,1,1)
			box.ClearTextOnFocus = false
			box.Parent = ball

			box.FocusLost:Connect(function()
				local v = tonumber(box.Text)
				if v and v > 0 then
					delayValue.Value = v
				end
				box:Destroy()
			end)
		end
		lastTap = tick()
	end)
end)

-- ================= LIGAR / DESLIGAR =================
toggleButton.MouseButton1Click:Connect(function()
	clickingEnabled = not clickingEnabled
	toggleButton.Text = clickingEnabled and "⏸ DESLIGAR" or "▶ LIGAR"
end)
