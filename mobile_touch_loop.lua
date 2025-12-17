-- MOBILE TOUCH RECORDER + LOOP
-- Compatível com Roblox Mobile (Android / iOS exploits)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local points = {}
local looping = false
local delayBetweenTouches = 0.35

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function createButton(text, pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromScale(0.25, 0.07)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = gui
    b.Draggable = true
    b.Active = true
    return b
end

local btnRecord = createButton("📍 REGISTRAR", UDim2.fromScale(0.05, 0.75))
local btnPlay   = createButton("▶ PLAY",      UDim2.fromScale(0.37, 0.75))
local btnClear  = createButton("🧹 LIMPAR",    UDim2.fromScale(0.69, 0.75))

-- Registrar toque
btnRecord.MouseButton1Click:Connect(function()
    local pos = UserInputService:GetMouseLocation()
    table.insert(points, {x = pos.X, y = pos.Y})
    btnRecord.Text = "📍 SALVO ("..#points..")"
end)

-- Simular toque
local function tap(x, y)
    VirtualInputManager:SendTouchEvent(0, x, y, true)
    task.wait(0.05)
    VirtualInputManager:SendTouchEvent(0, x, y, false)
end

-- Loop
btnPlay.MouseButton1Click:Connect(function()
    looping = not looping
    btnPlay.Text = looping and "⏸ PAUSAR" or "▶ PLAY"

    task.spawn(function()
        while looping do
            for _, p in ipairs(points) do
                if not looping then break end
                tap(p.x, p.y)
                task.wait(delayBetweenTouches)
            end
        end
    end)
end)

-- Limpar
btnClear.MouseButton1Click:Connect(function()
    table.clear(points)
    btnRecord.Text = "📍 REGISTRAR"
end)

print("✔ Touch loop mobile carregado")
