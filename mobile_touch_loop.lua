local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local VirtualInputManager = game:GetService("VirtualInputManager")

local clickingEnabled = true
local clickDelay = 0.15
local balls = {}

-- Botão Adicionar
local addButton = Instance.new("TextButton")
addButton.Size = UDim2.new(0, 180, 0, 45)
addButton.Position = UDim2.new(0.05, 0, 0.75, 0)
addButton.Text = "➕ Adicionar bolinha"
addButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
addButton.TextColor3 = Color3.new(1,1,1)
addButton.Parent = gui

-- Botão Ligar / Desligar
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 45)
toggleButton.Position = UDim2.new(0.05, 0, 0.82, 0)
toggleButton.Text = "⏸ DESLIGAR"
toggleButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Parent = gui

-- Botão Velocidade
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 180, 0, 45)
speedButton.Position = UDim2.new(0.05, 0, 0.89, 0)
speedButton.Text = "⚡ Velocidade: NORMAL"
speedButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
speedButton.TextColor3 = Color3.new(1,1,1)
speedButton.Parent = gui

-- Loop de clique
local function clickLoop(ball)
	task.spawn(function()
		while ball.Parent do
			if clickingEnabled then
				local pos = ball.AbsolutePosition + (ball.AbsoluteSize / 2)
				VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
				VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
			end
			task.wait(clickDelay)
		end
	end)
end

-- Criar bolinha
addButton.MouseButton1Click:Connect(function()
	local ball = Instance.new("TextButton")
	ball.Size = UDim2.new(0, 60, 0, 60)
	ball.Position = UDim2.new(0.5, -30, 0.5, -30)
	ball.BackgroundColor3 = Color3.fromRGB(255,80,80)
	ball.Text = ""
	ball.Parent = gui
	ball.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = ball

	table.insert(balls, ball)
	clickLoop(ball)

	-- Arrastar (mobile)
	local dragging = false
	local dragStart, startPos

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
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	ball.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- REMOVER bolinha (toque longo)
	ball.MouseButton1Down:Connect(function()
		task.wait(0.4)
		if dragging == false then
			ball:Destroy()
		end
	end)
end)

-- Ligar / Desligar
toggleButton.MouseButton1Click:Connect(function()
	clickingEnabled = not clickingEnabled
	toggleButton.Text = clickingEnabled and "⏸ DESLIGAR" or "▶ LIGAR"
end)

-- Velocidade
local speedState = 2
speedButton.MouseButton1Click:Connect(function()
	speedState += 1
	if speedState > 3 then speedState = 1 end

	if speedState == 1 then
		clickDelay = 0.3
		speedButton.Text = "🐢 Velocidade: LENTA"
	elseif speedState == 2 then
		clickDelay = 0.15
		speedButton.Text = "⚡ Velocidade: NORMAL"
	elseif speedState == 3 then
		clickDelay = 0.05
		speedButton.Text = "🚀 Velocidade: RÁPIDA"
	end
end)
