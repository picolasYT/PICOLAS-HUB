---------------------------------------------------------------------
--  ████  HUB AVANZADO COMPLETO - PARA TU PROPIO JUEGO DE ROBLOX  ████
--  Versión: GUI + Noclip + Fly + TP + ESP + Invisibilidad + RGB + más
--  Listo para copiar/pegar en StarterPlayerScripts
---------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local character
local humanoid

local function loadCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
end
loadCharacter()
player.CharacterAdded:Connect(loadCharacter)

---------------------------------------------------------------------
-- GUI PRINCIPAL
---------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "MegaHub"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 330)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Borde RGB animado
local rgbBorder = Instance.new("UIStroke")
rgbBorder.Thickness = 3
rgbBorder.Parent = frame

-- Animación RGB
local hue = 0
RunService.Heartbeat:Connect(function()
	hue = (hue + 0.002) % 1
	rgbBorder.Color = Color3.fromHSV(hue, 1, 1)
end)

-- Botón Cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextScaled = true
closeBtn.Parent = frame

-- Botón Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Text = "-"
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -80, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
minBtn.TextScaled = true
minBtn.Parent = frame

---------------------------------------------------------------------
-- BOTÓN FLOTANTE RGB CUANDO SE MINIMIZA
---------------------------------------------------------------------

local bubble = Instance.new("TextButton")
bubble.Text = "⚙"
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0.1, 0, 0.1, 0)
bubble.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bubble.Visible = false
bubble.Active = true
bubble.Draggable = true
bubble.TextScaled = true
bubble.Parent = gui

-- Borde RGB
local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Thickness = 3
bubbleStroke.Parent = bubble

RunService.Heartbeat:Connect(function()
	bubbleStroke.Color = Color3.fromHSV(hue, 1, 1)
end)

-- Minimizar / Restaurar
minBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	bubble.Visible = true
end)

bubble.MouseButton1Click:Connect(function()
	frame.Visible = true
	bubble.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

---------------------------------------------------------------------
-- BOTONES DE FUNCIONES
---------------------------------------------------------------------

local function createButton(text, position)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 160, 0, 40)
	btn.Position = position
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextScaled = true
	btn.Text = text
	btn.Parent = frame
	return btn
end

local noclipBtn = createButton("🚫 Noclip", UDim2.new(0, 20, 0, 60))
local flyBtn    = createButton("🕊️ Fly",    UDim2.new(0, 200, 0, 60))

local tpBtn     = createButton("📍 Guardar TP", UDim2.new(0, 20, 0, 110))
local tp2Btn    = createButton("📍 Teleport",   UDim2.new(0, 200, 0, 110))

local espBtn    = createButton("👁️ ESP Players", UDim2.new(0,20,0,160))
local carreraBtn= createButton("🏃‍♂️ Carrera",    UDim2.new(0,200,0,160))

local speedBtn  = createButton("⚡ Velocidad +", UDim2.new(0,20,0,210))
local invBtn    = createButton("🕶️ Invisibilidad", UDim2.new(0,200,0,210))

local offBtn    = createButton("🔴 Desactivar TODO", UDim2.new(0,20,0,260))
offBtn.Size = UDim2.new(0,340,0,40)

---------------------------------------------------------------------
-- VARIABLES DE FUNCIONES
---------------------------------------------------------------------

local noclipEnabled = false
local flyEnabled = false
local espEnabled = false
local carreraEnabled = false
local invisEnabled = false

local flySpeed = 50
local carreraSpeed = 40

local savedPosition = nil

---------------------------------------------------------------------
-- N O C L I P
---------------------------------------------------------------------

RunService.Stepped:Connect(function()
	if noclipEnabled and character then
		for _, p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)
end)

---------------------------------------------------------------------
-- F L Y  N A T U R A L
---------------------------------------------------------------------

local bodyVel

flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)

	if flyEnabled then
		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
		bodyVel.Parent = character.HumanoidRootPart
	else
		if bodyVel then bodyVel:Destroy() end
	end
end)

RunService.Heartbeat:Connect(function()
	if flyEnabled and bodyVel then
		local dir = workspace.CurrentCamera.CFrame.LookVector
		bodyVel.Velocity = dir * flySpeed
	end
end)

---------------------------------------------------------------------
-- T E L E P O R T S
---------------------------------------------------------------------

tpBtn.MouseButton1Click:Connect(function()
	if character then
		savedPosition = character.HumanoidRootPart.Position
		tpBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
	end
end)

tp2Btn.MouseButton1Click:Connect(function()
	if savedPosition and character then
		character.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
	end
end)

---------------------------------------------------------------------
-- E S P   P L A Y E R S
---------------------------------------------------------------------

local espFolder = Instance.new("Folder", gui)
espFolder.Name = "ESP"

local function createESP(plr)
	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.new(0,100,0,20)
	tag.AlwaysOnTop = true
	tag.Adornee = plr.Character:WaitForChild("Head")
	tag.Parent = espFolder

	local label = Instance.new("TextLabel")
	label.Text = plr.Name
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,0,0)
	label.TextScaled = true
	label.Parent = tag

	return tag
end

local function enableESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			createESP(plr)
		end
	end
end

local function disableESP()
	espFolder:ClearAllChildren()
end

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)

	if espEnabled then enableESP() else disableESP() end
end)

---------------------------------------------------------------------
-- M O D O   C A R R E R A  (plataformas fugaces)
---------------------------------------------------------------------

local platform

carreraBtn.MouseButton1Click:Connect(function()
	carreraEnabled = not carreraEnabled
	carreraBtn.BackgroundColor3 = carreraEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)

	if carreraEnabled then
		platform = Instance.new("Part")
		platform.Size = Vector3.new(6,1,6)
		platform.Color = Color3.fromRGB(120,170,255)
		platform.Transparency = 0.4
		platform.Anchored = true
		platform.CanCollide = true
		platform.Parent = workspace
	else
		if platform then platform:Destroy() end
	end
end)

RunService.Heartbeat:Connect(function()
	if carreraEnabled and platform and character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			platform.Position = hrp.Position - Vector3.new(0, humanoid.HipHeight + 2, 0)
		end
	end
end)

---------------------------------------------------------------------
-- I N V I S I B I L I D A D
---------------------------------------------------------------------

invBtn.MouseButton1Click:Connect(function()
	invisEnabled = not invisEnabled
	invBtn.BackgroundColor3 = invisEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(50,50,50)

	for _, p in ipairs(character:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Transparency = invisEnabled and 1 or 0
		end
	end
end)

---------------------------------------------------------------------
-- V E L O C I D A D
---------------------------------------------------------------------

speedBtn.MouseButton1Click:Connect(function()
	flySpeed = flySpeed + 10
	carreraSpeed = carreraSpeed + 10
	speedBtn.Text = "⚡ Velocidad: " .. flySpeed
end)

---------------------------------------------------------------------
-- D E S A C T I V A R   T O D O
---------------------------------------------------------------------

local function disableAll()
	noclipEnabled = false
	flyEnabled = false
	espEnabled = false
	carreraEnabled = false
	invisEnabled = false

	noclipBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	flyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	espBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	carreraBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	invBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)

	if bodyVel then bodyVel:Destroy() end
	disableESP()
	if platform then platform:Destroy() end

	for _, p in ipairs(character:GetDescendants()) do
		if p:IsA("BasePart") then p.Transparency = 0 end
	end
end

offBtn.MouseButton1Click:Connect(disableAll)

---------------------------------------------------------------------
-- AUTO-RESPAWN SAFE
---------------------------------------------------------------------

player.CharacterAdded:Connect(function()
	task.wait(1)
	disableAll()
	frame.Visible = true
	bubble.Visible = false
end)
