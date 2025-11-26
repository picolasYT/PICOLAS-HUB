---------------------------------------------------------------------
-- ☆彡 PICOLAS HUB NEON ミ☆
-- GUI COMPLETO (NEON MOBILE + ESP FIXED + FX PRO)
---------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "PicolasHubNeon"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.Parent = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- DETECTAR CELULAR
---------------------------------------------------------------------
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

---------------------------------------------------------------------
-- FRAME PRINCIPAL
---------------------------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = isMobile and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 380, 0, 330)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(5,5,5)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
frame.ZIndex = 5

-- ESQUINAS
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- SOMBRA
local shadow = Instance.new("Frame", gui)
shadow.Size = frame.Size + UDim2.fromOffset(6,6)
shadow.Position = frame.Position + UDim2.fromOffset(3,3)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.4
shadow.ZIndex = 4

---------------------------------------------------------------------
-- RGB STROKES
---------------------------------------------------------------------
local stroke1 = Instance.new("UIStroke", frame)
stroke1.Thickness = 3

local stroke2 = Instance.new("UIStroke", frame)
stroke2.Thickness = 1
stroke2.Transparency = 0.4

---------------------------------------------------------------------
-- TITULO
---------------------------------------------------------------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-100,0,40)
title.Position = UDim2.new(0,10,0,5)
title.Text = "☆彡 PICOLAS HUB NEON ミ☆"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.ZIndex = 6

---------------------------------------------------------------------
-- BOTONES MINIMIZAR / CERRAR
---------------------------------------------------------------------
local function headerBtn(txt,x)
	local b = Instance.new("TextButton", frame)
	b.Text = txt
	b.Size = UDim2.new(0,35,0,35)
	b.Position = UDim2.new(1,-x,0,5)
	b.BackgroundColor3 = Color3.fromRGB(20,20,20)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.ZIndex = 6
	Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
	return b
end

local minBtn = headerBtn("-",85)
local closeBtn = headerBtn("X",45)

---------------------------------------------------------------------
-- BURBUJA FLOTANTE RGB
---------------------------------------------------------------------
local bubble = Instance.new("TextButton", gui)
bubble.Size = UDim2.new(0,44,0,44)
bubble.Position = UDim2.new(0.1,0,0.1,0)
bubble.Text = "⚡"
bubble.Visible = false
bubble.Active = true
bubble.Draggable = true
bubble.Font = Enum.Font.GothamBold
bubble.TextScaled = true
bubble.ZIndex = 20
bubble.BackgroundColor3 = Color3.fromRGB(10,10,10)
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1,0)
local bubbleStroke = Instance.new("UIStroke", bubble)
bubbleStroke.Thickness = 3

---------------------------------------------------------------------
-- ANIMACION RGB
---------------------------------------------------------------------
local hue = 0
RunService.Heartbeat:Connect(function()
	hue = (hue + 0.0015) % 1
	local col = Color3.fromHSV(hue,1,1)
	stroke1.Color = col
	stroke2.Color = col
	bubbleStroke.Color = col
	title.TextColor3 = col
end)

---------------------------------------------------------------------
-- FUNCION PARA CREAR BOTONES NEON
---------------------------------------------------------------------
local function createBtn(txt,pos)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0,150,0,42)
	b.Position = pos
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(15,15,15)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.ZIndex = 6
	local c = Instance.new("UICorner", b)
	c.CornerRadius = UDim.new(0,8)
	return b
end

---------------------------------------------------------------------
-- POSICIONADO
---------------------------------------------------------------------
local y = 55
local spacing = 50

local function nextY()
	local v = y
	y = y + spacing
	return v
end

local noclipBtn  = createBtn("🚫 NOCLIP",        UDim2.new(0,20,0,nextY()))
local flyBtn     = createBtn("🕊 FLY",           UDim2.new(0,200,0,y-spacing))
local tpBtn      = createBtn("📍 SAVE TP",       UDim2.new(0,20,0,nextY()))
local tp2Btn     = createBtn("📍 TELEPORT",      UDim2.new(0,200,0,y-spacing))
local espBtn     = createBtn("👁 ESP NEON",      UDim2.new(0,20,0,nextY()))
local carreraBtn = createBtn("🏃 CARRERA",       UDim2.new(0,200,0,y-spacing))
local speedBtn   = createBtn("⚡ SPEED",         UDim2.new(0,20,0,nextY()))
local invBtn     = createBtn("🕶 INVISIBLE",     UDim2.new(0,200,0,y-spacing))
local offBtn     = createBtn("🔴 DISABLE ALL",    UDim2.new(0,20,0,nextY()))
offBtn.Size = UDim2.new(0,330,0,42)

---------------------------------------------------------------------
-- VARIABLES
---------------------------------------------------------------------
local noclip=false
local fly=false
local esp=false
local carrera=false
local invis=false
local saved=nil

local flySpeed=60
local carreraSpeed=40

local bodyVel

local player = Players.LocalPlayer
local character,humanoid

local function getChar()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
end
getChar()
player.CharacterAdded:Connect(getChar)

---------------------------------------------------------------------
-- NOCLIP
---------------------------------------------------------------------
RunService.Stepped:Connect(function()
	if noclip and character then
		for _,p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide=false
			end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip=not noclip
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0,200,150) or Color3.fromRGB(15,15,15)
end)

---------------------------------------------------------------------
-- FLY
---------------------------------------------------------------------
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.BackgroundColor3 = fly and Color3.fromRGB(0,200,150) or Color3.fromRGB(15,15,15)

	if fly then
		bodyVel = Instance.new("BodyVelocity", character.HumanoidRootPart)
		bodyVel.MaxForce = Vector3.new(1e6,1e6,1e6)
	else
		if bodyVel then bodyVel:Destroy() bodyVel=nil end
	end
end)

RunService.Heartbeat:Connect(function()
	if fly and bodyVel then
		local cam = workspace.CurrentCamera
		bodyVel.Velocity = cam.CFrame.LookVector * flySpeed
	end
end)

---------------------------------------------------------------------
-- TP
---------------------------------------------------------------------
tpBtn.MouseButton1Click:Connect(function()
	saved = character.HumanoidRootPart.Position
end)

tp2Btn.MouseButton1Click:Connect(function()
	if saved then character.HumanoidRootPart.CFrame = CFrame.new(saved) end
end)

---------------------------------------------------------------------
-- ESP NEON FIXED
---------------------------------------------------------------------
local espFolder = Instance.new("Folder", gui)

local function clearESP()
	espFolder:ClearAllChildren()
end

local function createESP(plr)
	if plr==player then return end

	local function attach()
		if not plr.Character then return end
		local head = plr.Character:FindFirstChild("Head")
		local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
		if not head or not hrp then return end

		local bill = Instance.new("BillboardGui", espFolder)
		bill.Adornee = head
		bill.Size = UDim2.new(0,160,0,35)
		bill.AlwaysOnTop = true
		bill.Name = plr.Name

		local txt = Instance.new("TextLabel", bill)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.TextScaled = true
		txt.Font = Enum.Font.GothamBold
		txt.TextStrokeTransparency = 0

		RunService.Heartbeat:Connect(function()
			if plr.Character and player.Character then
				local d = math.floor((plr.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude)
				txt.Text = plr.Name.." ["..d.."m]"
				txt.TextColor3 = Color3.fromHSV((tick()%5)/5,1,1)
			end
		end)
	end

	attach()
	plr.CharacterAdded:Connect(function()
		task.wait(1)
		if esp then attach() end
	end)
end

local function enableESP()
	clearESP()
	for _,plr in pairs(Players:GetPlayers()) do
		createESP(plr)
	end
end

espBtn.MouseButton1Click:Connect(function()
	esp = not esp
	espBtn.BackgroundColor3 = esp and Color3.fromRGB(0,200,150) or Color3.fromRGB(15,15,15)
	if esp then enableESP() else clearESP() end
end)

Players.PlayerAdded:Connect(function(p)
	if esp then createESP(p) end
end)

---------------------------------------------------------------------
-- MODO CARRERA
---------------------------------------------------------------------
local platforms = {}

local function newPlatform()
	if not carrera then return end
	local hrp = character.HumanoidRootPart

	local p = Instance.new("Part", workspace)
	p.Size = Vector3.new(6,1,6)
	p.Anchored=true
	p.CanCollide=true
	p.Material=Enum.Material.Neon
	p.Color=Color3.fromRGB(0,255,255)
	p.Transparency=0.4
	table.insert(platforms,p)

	task.spawn(function()
		while carrera and humanoid.FloorMaterial==Enum.Material.Air do
			p.Position = hrp.Position - Vector3.new(0,3,0)
			task.wait()
		end
		task.wait(2)
		p:Destroy()
	end)
end

carreraBtn.MouseButton1Click:Connect(function()
	carrera = not carrera
	carreraBtn.BackgroundColor3 = carrera and Color3.fromRGB(0,200,150) or Color3.fromRGB(15,15,15)
end)

humanoid.Jumping:Connect(function(j)
	if j then newPlatform() end
end)

---------------------------------------------------------------------
-- INVIS
---------------------------------------------------------------------
local function setInv(state)
	for _,p in pairs(character:GetDescendants()) do
		if p:IsA("BasePart") then
			p.LocalTransparencyModifier = state and 1 or 0
		end
	end
end

invBtn.MouseButton1Click:Connect(function()
	invis=not invis
	invBtn.BackgroundColor3 = invis and Color3.fromRGB(0,200,150) or Color3.fromRGB(15,15,15)
	setInv(invis)
end)

---------------------------------------------------------------------
-- SPEED
---------------------------------------------------------------------
speedBtn.MouseButton1Click:Connect(function()
	flySpeed+=15
	carreraSpeed+=10
	speedBtn.Text="⚡ SPEED "..flySpeed
end)

---------------------------------------------------------------------
-- DESACTIVAR TODO
---------------------------------------------------------------------
local function disableAll()
	noclip=false
	fly=false
	esp=false
	carrera=false
	invis=false

	if bodyVel then bodyVel:Destroy() end
	clearESP()
	setInv(false)
	flySpeed=60
	speedBtn.Text="⚡ SPEED 60"
	frame.Visible=true
	bubble.Visible=false
end

offBtn.MouseButton1Click:Connect(disableAll)

---------------------------------------------------------------------
-- MINIMIZAR + CERRAR
---------------------------------------------------------------------
minBtn.MouseButton1Click:Connect(function()
	frame.Visible=false
	shadow.Visible=false
	bubble.Visible=true
end)

bubble.MouseButton1Click:Connect(function()
	frame.Visible=true
	shadow.Visible=true
	bubble.Visible=false
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

---------------------------------------------------------------------
-- RESPWAN SAFE
---------------------------------------------------------------------
player.CharacterAdded:Connect(function()
	task.wait(1)
	disableAll()
end)

---------------------------------------------------------------------
-- ANIMACIÓN DE ENTRADA
---------------------------------------------------------------------
frame.Size = UDim2.new(0,0,0,0)
TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
	Size = isMobile and UDim2.new(0,320,0,420) or UDim2.new(0,380,0,330)
}):Play()