---------------------------------------------------------------------
-- PICOLAS HUB ULTRA • DARK EDITION
-- Estilo negro/blanco premium + Pestañas + TP Panel moderno
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
player.CharacterAdded:Connect(function()
	loadChar()
	task.wait(1)
	if _G.PicolasDisableAll then _G.PicolasDisableAll() end
end)

---------------------------------------------------------------------
-- GUI BASE
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PicolasHubDark"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999

---------------------------------------------------------------------
-- FRAME PRINCIPAL
---------------------------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = isMobile and UDim2.new(0,330,0,470) or UDim2.new(0,420,0,380)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,22)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 1.8
stroke.Color = Color3.fromRGB(55,55,60)

---------------------------------------------------------------------
-- HEADER
---------------------------------------------------------------------
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,48)
header.BackgroundColor3 = Color3.fromRGB(30,30,32)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,16,0,0)
title.Text = "PICOLAS HUB ULTRA"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(240,240,240)
title.TextXAlignment = Left
title.TextScaled = true
title.BackgroundTransparency = 1

local function headerBtn(txt, x)
	local b = Instance.new("TextButton", header)
	b.Size = UDim2.new(0,32,0,32)
	b.Position = UDim2.new(1,-x,0.5,0)
	b.AnchorPoint = Vector2.new(0,0.5)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(42,42,44)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
	return b
end

local minBtn   = headerBtn("-", 78)
local closeBtn = headerBtn("X", 38)

---------------------------------------------------------------------
-- BURBUJA FLOTANTE
---------------------------------------------------------------------
local bubble = Instance.new("TextButton", gui)
bubble.Size = UDim2.new(0,46,0,46)
bubble.Position = UDim2.new(0.1,0,0.1,0)
bubble.Text = "⚙"
bubble.Visible = false
bubble.Active = true
bubble.Draggable = true
bubble.ZIndex = 10
bubble.BackgroundColor3 = Color3.fromRGB(30,30,32)
bubble.TextColor3 = Color3.fromRGB(240,240,240)
bubble.Font = Enum.Font.GothamBold
bubble.TextScaled = true
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1,0)
local bubbleStroke = Instance.new("UIStroke", bubble)
bubbleStroke.Thickness = 2
bubbleStroke.Color = Color3.fromRGB(70,70,75)

---------------------------------------------------------------------
-- TABS
---------------------------------------------------------------------
local function tabBtn(txt, x)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0,120,0,32)
	b.Position = UDim2.new(0,x,0,56)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(35,35,37)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local tabMOV = tabBtn("MOV", 18)
local tabVIS = tabBtn("VIS", 150)
local tabSYS = tabBtn("SYS", 282)

local function makeContent()
	local c = Instance.new("Frame", frame)
	c.Size = UDim2.new(1,-24,1,-112)
	c.Position = UDim2.new(0,12,0,96)
	c.BackgroundTransparency = 1
	c.Visible = false
	return c
end

local CONTENT = {
	MOV = makeContent(),
	VIS = makeContent(),
	SYS = makeContent(),
}

local function activateTab(name)
	for k,v in pairs(CONTENT) do
		v.Visible = (k == name)
	end
	local on = Color3.fromRGB(28,28,30)
	local off = Color3.fromRGB(35,35,37)
	tabMOV.BackgroundColor3 = (name=="MOV") and on or off
	tabVIS.BackgroundColor3 = (name=="VIS") and on or off
	tabSYS.BackgroundColor3 = (name=="SYS") and on or off
end

tabMOV.MouseButton1Click:Connect(function() activateTab("MOV") end)
tabVIS.MouseButton1Click:Connect(function() activateTab("VIS") end)
tabSYS.MouseButton1Click:Connect(function() activateTab("SYS") end)
activateTab("MOV")

---------------------------------------------------------------------
-- UI HELPERS
---------------------------------------------------------------------
local function card(parent, y)
	local c = Instance.new("Frame", parent)
	c.Size = UDim2.new(1,0,0,44)
	c.Position = UDim2.new(0,0,0,y)
	c.BackgroundColor3 = Color3.fromRGB(25,25,27)
	Instance.new("UICorner", c).CornerRadius = UDim.new(0,10)
	local s = Instance.new("UIStroke", c); s.Thickness = 1; s.Color = Color3.fromRGB(45,45,50)
	return c
end

local function label(parent, txt)
	local l = Instance.new("TextLabel", parent)
	l.Size = UDim2.new(1,-70,1,0)
	l.Position = UDim2.new(0,14,0,0)
	l.Text = txt
	l.Font = Enum.Font.Gotham
	l.TextColor3 = Color3.fromRGB(240,240,240)
	l.TextXAlignment = Left
	l.TextScaled = true
	l.BackgroundTransparency = 1
	return l
end

local function toggle(parent)
	local t = Instance.new("TextButton", parent)
	t.Size = UDim2.new(0,44,0,24)
	t.Position = UDim2.new(1,-58,0.5,0)
	t.AnchorPoint = Vector2.new(0,0.5)
	t.BackgroundColor3 = Color3.fromRGB(60,60,64)
	Instance.new("UICorner", t).CornerRadius = UDim.new(1,0)
	local knob = Instance.new("Frame", t)
	knob.Size = UDim2.new(0,20,0,20)
	knob.Position = UDim2.new(0,2,0.5,0)
	knob.AnchorPoint = Vector2.new(0,0.5)
	knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

	local state = false
	local function set(v)
		state = v
		TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Position = v and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0)
		}):Play()
		t.BackgroundColor3 = v and Color3.fromRGB(100,140,255) or Color3.fromRGB(60,60,64)
	end
	set(false)

	t.MouseButton1Click:Connect(function()
		set(not state)
		t:SetAttribute("On", state)
	end)

	return t
end

local function slider(parent, y, titleText, min, max, default, onChange)
	local cont = card(parent, y)
	local lbl = label(cont, titleText)
	lbl.Size = UDim2.new(1,-20,0.5,0)

	local bar = Instance.new("Frame", cont)
	bar.Size = UDim2.new(1,-28,0,8)
	bar.Position = UDim2.new(0,14,0.72,0)
	bar.BackgroundColor3 = Color3.fromRGB(45,45,48)
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new(0,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(120,150,255)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

	local valueLbl = Instance.new("TextLabel", cont)
	valueLbl.Size = UDim2.new(0,70,0.5,0)
	valueLbl.Position = UDim2.new(1,-80,0,0)
	valueLbl.TextXAlignment = Right
	valueLbl.Font = Enum.Font.Gotham
	valueLbl.TextColor3 = Color3.fromRGB(200,200,210)
	valueLbl.BackgroundTransparency = 1
	valueLbl.TextScaled = true

	local val = default
	local function setByAlpha(a)
		a = math.clamp(a, 0, 1)
		val = math.floor(min + (max-min)*a)
		fill.Size = UDim2.new(a,0,1,0)
		valueLbl.Text = tostring(val)
		if onChange then onChange(val) end
	end
	setByAlpha((default-min)/(max-min))

	local dragging = false
	bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
	bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local x = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			setByAlpha(x)
		end
	end)
end

---------------------------------------------------------------------
-- FUNCIONES JUEGO
---------------------------------------------------------------------
local noclip=false; local fly=false; local carrera=false; local invis=false; local esp=false
local flySpeed=60; local carreraSpeed=40; local bodyVel; local savedPos=nil

-- NOCLIP
RunService.Stepped:Connect(function()
	if noclip and character then
		for _,p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide=false end
		end
	end
end)

-- FLY
RunService.Heartbeat:Connect(function()
	if fly and bodyVel then
		bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
	end
end)

-- CARRERA (plataformas)
local platforms={}
local function newPlatform()
	if not carrera then return end
	local hrp = character.HumanoidRootPart
	local p = Instance.new("Part", workspace)
	p.Size=Vector3.new(6,1,6)
	p.Anchored=true; p.CanCollide=true
	p.Material=Enum.Material.SmoothPlastic
	p.Color=Color3.fromRGB(160,170,190)
	p.Transparency=0.4
	table.insert(platforms,p)
	task.spawn(function()
		while carrera and humanoid and humanoid.FloorMaterial==Enum.Material.Air do
			if hrp then p.Position = hrp.Position - Vector3.new(0,3,0) end
			task.wait()
		end
		task.wait(1.5)
		if p and p.Parent then p:Destroy() end
	end)
end
humanoid.Jumping:Connect(function(j) if j then newPlatform() end end)

-- INVIS
local function setInv(state)
	if not character then return end
	for _,p in pairs(character:GetDescendants()) do
		if p:IsA("BasePart") then p.LocalTransparencyModifier = state and 1 or 0 end
	end
end

-- ESP (robusto y simple)
local espFolder = Instance.new("Folder", gui)
local function clearESP() espFolder:ClearAllChildren() end
local function createESP(plr)
	if plr==player then return end
	local function attach()
		if not plr.Character then return end
		local head=plr.Character:FindFirstChild("Head"); local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
		if not head or not hrp then return end
		local bill=Instance.new("BillboardGui", espFolder); bill.Adornee=head; bill.Name=plr.Name
		bill.Size=UDim2.new(0,160,0,28); bill.AlwaysOnTop=true
		local txt=Instance.new("TextLabel", bill)
		txt.Size=UDim2.new(1,0,1,0); txt.BackgroundTransparency=1; txt.Font=Enum.Font.GothamBold
		txt.TextColor3=Color3.fromRGB(240,240,240); txt.TextStrokeTransparency=0; txt.TextScaled=true
		RunService.Heartbeat:Connect(function()
			if plr.Character and player.Character then
				local d = math.floor((plr.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude)
				txt.Text = plr.Name.." ["..d.."m]"
			end
		end)
	end
	attach()
	plr.CharacterAdded:Connect(function() if esp then task.wait(1); attach() end end)
end
local function enableESP()
	clearESP()
	for _,p in pairs(Players:GetPlayers()) do createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if esp then createESP(p) end end)

---------------------------------------------------------------------
-- CONSTRUIR CONTROLES
---------------------------------------------------------------------
-- MOV
do
	local c1 = card(CONTENT.MOV, 6); label(c1,"NOCLIP"); local t1=toggle(c1)
	t1:GetPropertyChangedSignal("On"):Connect(function()
		noclip = t1:GetAttribute("On")
	end)

	local c2 = card(CONTENT.MOV, 58); label(c2,"FLY"); local t2=toggle(c2)
	t2:GetPropertyChangedSignal("On"):Connect(function()
		fly = t2:GetAttribute("On")
		if fly then
			bodyVel = Instance.new("BodyVelocity", character.HumanoidRootPart)
			bodyVel.MaxForce = Vector3.new(1e6,1e6,1e6)
		else
			if bodyVel then bodyVel:Destroy(); bodyVel=nil end
		end
	end)

	local c3 = card(CONTENT.MOV, 110); label(c3,"MODO CARRERA"); local t3=toggle(c3)
	t3:GetPropertyChangedSignal("On"):Connect(function()
		carrera = t3:GetAttribute("On")
	end)

	slider(CONTENT.MOV, 164, "Velocidad Fly", 30, 150, flySpeed, function(v) flySpeed=v end)
	slider(CONTENT.MOV, 222, "Velocidad Carrera", 20, 120, carreraSpeed, function(v) carreraSpeed=v end)

	local tpBtn = card(CONTENT.MOV, 282); label(tpBtn,"TP PANEL")
	local go = Instance.new("TextButton", tpBtn)
	go.Size = UDim2.new(0,90,0,28); go.Position = UDim2.new(1,-106,0.5,0); go.AnchorPoint=Vector2.new(0,0.5)
	go.Text="ABRIR"; go.Font=Enum.Font.GothamBold; go.TextScaled=true
	go.BackgroundColor3=Color3.fromRGB(80,90,120); go.TextColor3=Color3.fromRGB(240,240,240)
	Instance.new("UICorner",go).CornerRadius=UDim.new(1,0)
	go.MouseButton1Click:Connect(function() _G.ShowTP(true) end)
end

-- VIS
do
	local c1 = card(CONTENT.VIS, 6); label(c1,"ESP"); local t1=toggle(c1)
	t1:GetPropertyChangedSignal("On"):Connect(function()
		esp = t1:GetAttribute("On")
		if esp then enableESP() else clearESP() end
	end)

	local c2 = card(CONTENT.VIS, 58); label(c2,"INVISIBILIDAD"); local t2=toggle(c2)
	t2:GetPropertyChangedSignal("On"):Connect(function()
		invis = t2:GetAttribute("On")
		setInv(invis)
	end)
end

-- SYS
do
	local c1 = card(CONTENT.SYS, 6); label(c1,"DESACTIVAR TODO")
	local b = Instance.new("TextButton", c1)
	b.Size = UDim2.new(0,90,0,28); b.Position = UDim2.new(1,-106,0.5,0); b.AnchorPoint=Vector2.new(0,0.5)
	b.Text="RESET"; b.Font=Enum.Font.GothamBold; b.TextScaled=true
	b.BackgroundColor3=Color3.fromRGB(120,60,60); b.TextColor3=Color3.fromRGB(255,240,240)
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	b.MouseButton1Click:Connect(function() if _G.PicolasDisableAll then _G.PicolasDisableAll() end end)
end

---------------------------------------------------------------------
-- TP PANEL
---------------------------------------------------------------------
local tpPanel = Instance.new("Frame", gui)
tpPanel.Size = UDim2.new(0,300,0,220)
tpPanel.Position = UDim2.new(0.35,0,0.35,0)
tpPanel.BackgroundColor3 = Color3.fromRGB(22,22,24)
tpPanel.Visible = false
tpPanel.Active = true
tpPanel.Draggable = true
Instance.new("UICorner",tpPanel).CornerRadius=UDim.new(0,14)
local tpStroke = Instance.new("UIStroke", tpPanel); tpStroke.Thickness=1.8; tpStroke.Color=Color3.fromRGB(55,55,60)

local tpt = Instance.new("TextLabel", tpPanel)
tpt.Size=UDim2.new(1,0,0,44); tpt.Text="TELEPORT PANEL"; tpt.Font=Enum.Font.GothamBold; tpt.TextScaled=true
tpt.TextColor3=Color3.fromRGB(240,240,240); tpt.BackgroundTransparency=1

local function tpBtn(y, txt, cb)
	local b = Instance.new("TextButton", tpPanel)
	b.Size = UDim2.new(1,-28,0,40); b.Position = UDim2.new(0,14,0,y)
	b.Text=txt; b.Font=Enum.Font.GothamBold; b.TextScaled=true
	b.BackgroundColor3=Color3.fromRGB(30,30,34); b.TextColor3=Color3.fromRGB(240,240,240)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
	if cb then b.MouseButton1Click:Connect(cb) end
	return b
end

tpBtn(60, "GUARDAR POSICIÓN", function()
	if character and character:FindFirstChild("HumanoidRootPart") then
		savedPos = character.HumanoidRootPart.Position
	end
end)

tpBtn(110,"IR A POSICIÓN", function()
	if savedPos and character then
		character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
	end
end)

tpBtn(160,"CERRAR", function() tpPanel.Visible = false end)

_G.ShowTP = function(v) tpPanel.Visible = v end

---------------------------------------------------------------------
-- RESET GLOBAL
---------------------------------------------------------------------
_G.PicolasDisableAll = function()
	noclip=false; fly=false; carrera=false; invis=false; esp=false
	if bodyVel then bodyVel:Destroy(); bodyVel=nil end
	clearESP(); setInv(false)
	flySpeed=60; carreraSpeed=40
	frame.Visible=true; bubble.Visible=false
end

---------------------------------------------------------------------
-- MIN / CLOSE
---------------------------------------------------------------------
minBtn.MouseButton1Click:Connect(function() frame.Visible=false; bubble.Visible=true end)
bubble.MouseButton1Click:Connect(function() frame.Visible=true; bubble.Visible=false end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

---------------------------------------------------------------------
-- ANIM ENTRADA
---------------------------------------------------------------------
frame.Size=UDim2.new(0,0,0,0)
TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
	Size = isMobile and UDim2.new(0,330,0,470) or UDim2.new(0,420,0,380)
}):Play()
