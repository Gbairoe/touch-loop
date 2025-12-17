local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local VirtualInputManager = game:GetService("VirtualInputManager")
local clickingEnabled = true

-- ================= FILA DE CLIQUES =================
local clickQueue = {}

task.spawn(function()
	while true do
		if clickingEnabled and #clickQueue > 0 then
			local ball = table.remove(clickQueue, 1)
			if ball and ball.Parent then
				local pos = ball.AbsolutePosition + ball.AbsoluteSize / 2
				VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
				VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
			end
		end
		task.wait(0.01) -- intervalo mínimo entre cliques
	end
end)

-- ================= PAINEL =================
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 220, 0, 120)
panel.Position = UDim2.new(0.05, 0, 0.6, 0)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.Active = true

Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

-- Arrastar painel (mobile)
do
	local dragging, dragStart, startPos
	panel.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = panel.Position
		end
	end)
	panel.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - dragStart
			panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	panel.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

local function newButton(text, y)
	local b = Instance.new("TextButton", panel)
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = UDim2.new(0, 10, 0, y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(55,55,55)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local addButton = newButton("➕ Adicionar bolinha", 10)
local toggleButton = newButton("⏸ DESLIGAR", 60)

-- ================= LOOP INDIVIDUAL =================
local function startBallLoop(ball)
	task.spawn(function()
		while ball.Parent do
			task.wait(ball.ClickDelay.Value)
			if clickingEnabled then
				table.insert(clickQueue, ball)
			end
		end
	end)
end

-- ================= CRIAR BOLINHA =================
addButton.MouseButton1Click:Connect(function()
	local ball = Instance.new("TextButton", gui)
	ball.Size = UDim2.new(0, 60, 0, 60)
	ball.Position = UDim2.new(0.5, -30, 0.5, -30)
	ball.BackgroundColor3 = Color3.fromRGB(255,80,80)
	ball.Text = ""
	ball.BorderSizePixel = 0
	ball.AutoButtonColor = false
	Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)

	-- Velocidade individual
	local delayValue = Instance.new("NumberValue", ball)
	delayValue.Name = "ClickDelay"
	delayValue.Value = 0.15

	startBallLoop(ball)

	-- Botão remover
	local removeBtn = Instance.new("TextButton", ball)
	removeBtn.Size = UDim2.new(0, 20, 0, 20)
	removeBtn.Position = UDim2.new(1, -18, 0, -2)
	removeBtn.Text = "✕"
	removeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
	removeBtn.TextColor3 = Color3.new(1,1,1)
	removeBtn.BorderSizePixel = 0
	Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(1,0)

	removeBtn.MouseButton1Click:Connect(function()
		ball:Destroy()
	end)

	-- Arrastar bolinha
	local dragging, dragStart, startPos
	ball.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = ball.Position
		end
	end)
	ball.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - dragStart
			ball.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	ball.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)

	-- Duplo toque = editar velocidade
	local lastTap = 0
	ball.MouseButton1Click:Connect(function()
		if tick() - lastTap < 0.35 then
			local box = Instance.new("TextBox", ball)
			box.Size = UDim2.new(1, 0, 1, 0)
			box.Text = tostring(delayValue.Value)
			box.BackgroundColor3 = Color3.fromRGB(0,0,0)
			box.TextColor3 = Color3.new(1,1,1)
			box.ClearTextOnFocus = false

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
