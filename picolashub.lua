---------------------------------------------------------------------
-- ☆彡 PICOLAS HUB NEON ULTRA ミ☆
-- GUI PRO + TABS + ESP FIXED + TP PANEL + MOBILE
---------------------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

---------------------------------------------------------------------
-- PERSONAJE
---------------------------------------------------------------------
local character, humanoid
local function loadChar()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
end
loadChar()
player.CharacterAdded:Connect(loadChar)

---------------------------------------------------------------------
-- GUI BASE
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "PicolasHubUltra"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999

---------------------------------------------------------------------
-- FRAME PRINCIPAL
---------------------------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = isMobile and UDim2.new(0,330,0,460) or UDim2.new(0,420,0,360)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(5,5,5)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,14)

-- DOBLE BORDE RGB
local stroke1 = Instance.new("UIStroke",frame)
stroke1.Thickness = 3
local stroke2 = Instance.new("UIStroke",frame)
stroke2.Thickness = 1
stroke2.Transparency = 0.5

---------------------------------------------------------------------
-- TITULO
---------------------------------------------------------------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-120,0,42)
title.Position = UDim2.new(0,10,0,6)
title.Text = "☆彡 PICOLAS HUB NEON ULTRA ミ☆"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1

---------------------------------------------------------------------
-- BOTONES HEADER
---------------------------------------------------------------------
local function headerBtn(txt,x)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0,36,0,36)
	b.Position = UDim2.new(1,-x,0,8)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(15,15,15)
	Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
	return b
end

local minBtn = headerBtn("-",90)
local closeBtn = headerBtn("X",45)

---------------------------------------------------------------------
-- BURBUJA
---------------------------------------------------------------------
local bubble = Instance.new("TextButton", gui)
bubble.Size = UDim2.new(0,46,0,46)
bubble.Position = UDim2.new(0.1,0,0.1,0)
bubble.Text = "⚡"
bubble.Visible = false
bubble.BackgroundColor3 = Color3.fromRGB(10,10,10)
bubble.Font = Enum.Font.GothamBold
bubble.TextScaled = true
bubble.Active=true
bubble.Draggable=true
bubble.ZIndex = 10
Instance.new("UICorner",bubble).CornerRadius = UDim.new(1,0)
local bubbleStroke = Instance.new("UIStroke",bubble)
bubbleStroke.Thickness = 3

---------------------------------------------------------------------
-- RGB ANIMACION
---------------------------------------------------------------------
local hue=0
RunService.Heartbeat:Connect(function()
	hue = (hue + 0.002) % 1
	local col = Color3.fromHSV(hue,1,1)
	stroke1.Color = col
	stroke2.Color = col
	title.TextColor3 = col
	bubbleStroke.Color = col
end)

---------------------------------------------------------------------
-- TABS
---------------------------------------------------------------------
local tabs = {}
local contents = {}

local function tabButton(name,x)
	local b = Instance.new("TextButton", frame)
	b.Text = name
	b.Size = UDim2.new(0,120,0,32)
	b.Position = UDim2.new(0,x,0,56)
	b.BackgroundColor3 = Color3.fromRGB(12,12,12)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
	return b
end

local movTab = tabButton("MOV",20)
local visTab = tabButton("VIS",150)
local sysTab = tabButton("SYS",280)

local function makeContent()
	local f = Instance.new("Frame", frame)
	f.Size = UDim2.new(1,-20,1,-120)
	f.Position = UDim2.new(0,10,0,100)
	f.BackgroundTransparency = 1
	f.Visible = false
	return f
end

contents.MOV = makeContent()
contents.VIS = makeContent()
contents.SYS = makeContent()

local function showTab(name)
	for k,v in pairs(contents) do
		v.Visible = (k == name)
	end
end

showTab("MOV")

movTab.MouseButton1Click:Connect(function() showTab("MOV") end)
visTab.MouseButton1Click:Connect(function() showTab("VIS") end)
sysTab.MouseButton1Click:Connect(function() showTab("SYS") end)

---------------------------------------------------------------------
-- FUNCION BTN
---------------------------------------------------------------------
local function mkBtn(parent,text,y)
	local b=Instance.new("TextButton",parent)
	b.Size=UDim2.new(1,-10,0,36)
	b.Position=UDim2.new(0,5,0,y)
	b.BackgroundColor3=Color3.fromRGB(12,12,12)
	b.TextColor3=Color3.fromRGB(255,255,255)
	b.Font=Enum.Font.GothamBold
	b.TextScaled=true
	b.Text=text
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	return b
end

---------------------------------------------------------------------
-- BOTONES MOV
---------------------------------------------------------------------
local noclipBtn = mkBtn(contents.MOV,"🚫 NOCLIP",10)
local flyBtn = mkBtn(contents.MOV,"🕊 FLY",56)
local carreraBtn = mkBtn(contents.MOV,"🏃 MODO CARRERA",102)
local speedBtn = mkBtn(contents.MOV,"⚡ SPEED +",148)
local tpMenuBtn = mkBtn(contents.MOV,"📍 TP MENU",194)

---------------------------------------------------------------------
-- BOTONES VIS
---------------------------------------------------------------------
local espBtn = mkBtn(contents.VIS,"👁 ESP NEON",10)
local invBtn = mkBtn(contents.VIS,"🕶 INVISIBLE",56)

---------------------------------------------------------------------
-- BOTONES SYS
---------------------------------------------------------------------
local offBtn = mkBtn(contents.SYS,"🔴 DESACTIVAR TODO",10)

---------------------------------------------------------------------
-- TP PANEL MODERNO
---------------------------------------------------------------------
local tpPanel = Instance.new("Frame", gui)
tpPanel.Size = UDim2.new(0,300,0,220)
tpPanel.Position = UDim2.new(0.35,0,0.35,0)
tpPanel.BackgroundColor3 = Color3.fromRGB(5,5,5)
tpPanel.Visible = false
tpPanel.Active = true
tpPanel.Draggable = true
Instance.new("UICorner",tpPanel).CornerRadius = UDim.new(0,12)
local tpStroke=Instance.new("UIStroke",tpPanel)
tpStroke.Thickness=2

local tpTitle=Instance.new("TextLabel",tpPanel)
tpTitle.Size=UDim2.new(1,0,0,40)
tpTitle.Text="📍 TELEPORT PANEL"
tpTitle.Font=Enum.Font.GothamBold
tpTitle.TextScaled=true
tpTitle.BackgroundTransparency=1

local saveTP=mkBtn(tpPanel,"GUARDAR POSICIÓN",60)
local goTP=mkBtn(tpPanel,"IR A POSICIÓN",105)
local closeTP=mkBtn(tpPanel,"CERRAR",150)

---------------------------------------------------------------------
-- RGB TP PANEL
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	local col = Color3.fromHSV(hue,1,1)
	tpStroke.Color = col
	tpTitle.TextColor3 = col
end)

---------------------------------------------------------------------
-- FUNCIONES
---------------------------------------------------------------------
local noclip=false
local fly=false
local carrera=false
local invis=false
local esp=false
local saved=nil
local flySpeed=60
local carreraSpeed=40
local bodyVel

---------------------------------------------------------------------
-- NOCLIP
---------------------------------------------------------------------
RunService.Stepped:Connect(function()
	if noclip and character then
		for _,p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide=false end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip=not noclip
	noclipBtn.BackgroundColor3=noclip and Color3.fromRGB(0,200,150) or Color3.fromRGB(12,12,12)
end)

---------------------------------------------------------------------
-- FLY
---------------------------------------------------------------------
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.BackgroundColor3=fly and Color3.fromRGB(0,200,150) or Color3.fromRGB(12,12,12)
	if fly then
		bodyVel=Instance.new("BodyVelocity",character.HumanoidRootPart)
		bodyVel.MaxForce=Vector3.new(1e6,1e6,1e6)
	else
		if bodyVel then bodyVel:Destroy() end
	end
end)

RunService.Heartbeat:Connect(function()
	if fly and bodyVel then
		bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
	end
end)

---------------------------------------------------------------------
-- CARRERA
---------------------------------------------------------------------
local platforms={}
local function newPlatform()
	if not carrera then return end
	local hrp = character.HumanoidRootPart
	local p = Instance.new("Part",workspace)
	p.Size=Vector3.new(6,1,6)
	p.Transparency=0.4
	p.Anchored=true
	p.Material=Enum.Material.Neon
	p.Color=Color3.fromRGB(0,255,255)
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

humanoid.Jumping:Connect(function(j)
	if j then newPlatform() end
end)

carreraBtn.MouseButton1Click:Connect(function()
	carrera=not carrera
	carreraBtn.BackgroundColor3=carrera and Color3.fromRGB(0,200,150) or Color3.fromRGB(12,12,12)
end)

---------------------------------------------------------------------
-- SPEED
---------------------------------------------------------------------
speedBtn.MouseButton1Click:Connect(function()
	flySpeed += 15
	carreraSpeed += 8
	speedBtn.Text = "⚡ SPEED "..flySpeed
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
	invBtn.BackgroundColor3=invis and Color3.fromRGB(0,200,150) or Color3.fromRGB(12,12,12)
	setInv(invis)
end)

---------------------------------------------------------------------
-- ESP FIXED NEON
---------------------------------------------------------------------
local espFolder = Instance.new("Folder", gui)

local function clearESP() espFolder:ClearAllChildren() end

local function createESP(plr)
	if plr==player then return end
	local function attach()
		if not plr.Character then return end
		local head = plr.Character:FindFirstChild("Head")
		local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
		if not head or not hrp then return end

		local bill = Instance.new("BillboardGui", espFolder)
		bill.Adornee = head
		bill.Name=plr.Name
		bill.Size = UDim2.new(0,160,0,35)
		bill.AlwaysOnTop = true

		local txt = Instance.new("TextLabel", bill)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.Font = Enum.Font.GothamBold
		txt.TextScaled = true
		txt.TextStrokeTransparency = 0

		RunService.Heartbeat:Connect(function()
			if plr.Character and player.Character then
				local d=math.floor((plr.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude)
				txt.Text=plr.Name.." ["..d.."m]"
				txt.TextColor3=Color3.fromHSV(hue,1,1)
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
	for _,p in pairs(Players:GetPlayers()) do
		createESP(p)
	end
end

espBtn.MouseButton1Click:Connect(function()
	esp=not esp
	espBtn.BackgroundColor3=esp and Color3.fromRGB(0,200,150) or Color3.fromRGB(12,12,12)
	if esp then enableESP() else clearESP() end
end)

Players.PlayerAdded:Connect(function(p)
	if esp then createESP(p) end
end)

---------------------------------------------------------------------
-- TP PANEL CONTROL
---------------------------------------------------------------------
tpMenuBtn.MouseButton1Click:Connect(function()
	tpPanel.Visible=true
end)

closeTP.MouseButton1Click:Connect(function()
	tpPanel.Visible=false
end)

saveTP.MouseButton1Click:Connect(function()
	saved = character.HumanoidRootPart.Position
end)

goTP.MouseButton1Click:Connect(function()
	if saved then
		character.HumanoidRootPart.CFrame = CFrame.new(saved)
	end
end)

---------------------------------------------------------------------
-- DESACTIVAR TODO
---------------------------------------------------------------------
local function disableAll()
	noclip=false fly=false carrera=false invis=false esp=false
	if bodyVel then bodyVel:Destroy() end
	clearESP()
	setInv(false)
	flySpeed=60
	speedBtn.Text="⚡ SPEED +"
	frame.Visible=true bubble.Visible=false
end

offBtn.MouseButton1Click:Connect(disableAll)

---------------------------------------------------------------------
-- MINIMIZAR
---------------------------------------------------------------------
minBtn.MouseButton1Click:Connect(function()
	frame.Visible=false
	bubble.Visible=true
end)

bubble.MouseButton1Click:Connect(function()
	frame.Visible=true
	bubble.Visible=false
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

---------------------------------------------------------------------
-- ANIM ENTRADA
---------------------------------------------------------------------
frame.Size=UDim2.new(0,0,0,0)
TweenService:Create(frame,TweenInfo.new(0.3,Enum.EasingStyle.Quint),
{Size=isMobile and UDim2.new(0,330,0,460) or UDim2.new(0,420,0,360)}):Play()