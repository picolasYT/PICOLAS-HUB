-- // 🧠 PICOLAS HUB PRO+ v3.1 Ultra by PicolasYT
-- GUI completa con Fly, Noclip, TP, ESP automático, Carrera, Velocidad persistente, Invisibilidad y Reset rápido.

if getgenv().PicolasHubLoaded then return end
getgenv().PicolasHubLoaded = true

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local tpSavePos = nil
local flying, noclip, carrera, invisible = false, false, false, false
local flyConn, noclipConn, carreraConn = nil, nil, nil
local originalCollide = {}
local speed = getgenv().LastSpeed or 60
local hubVisible = true

local function notify(msg)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title="Picolas Hub", Text=msg})
	end)
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	hrp = newChar:WaitForChild("HumanoidRootPart")
	flying, noclip, carrera, invisible = false, false, false, false
	if flyConn then flyConn:Disconnect() flyConn=nil end
	if noclipConn then noclipConn:Disconnect() noclipConn=nil end
	if carreraConn then carreraConn:Disconnect() carreraConn=nil end
	notify("♻️ Hub reiniciado tras respawn")
end)

----------------------------------------------------------
-- GUI Base
----------------------------------------------------------
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PicolasHub"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Size = UDim2.new(0,260,0,460)
main.Position = UDim2.new(0.5,-130,0.5,-230)
main.Active = true
main.Draggable = true
main.Visible = true

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
task.spawn(function()
	local h=0
	while task.wait(0.02) do
		h=(h+1)%360
		stroke.Color=Color3.fromHSV(h/360,1,1)
	end
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Text = "🧠 PICOLAS HUB PRO+"

local function makeButton(text, y, cb)
	local b=Instance.new("TextButton", main)
	b.Size=UDim2.new(1,-20,0,30)
	b.Position=UDim2.new(0,10,0,y)
	b.BackgroundColor3=Color3.fromRGB(45,45,45)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.Gotham
	b.TextSize=15
	b.Text=text
	b.MouseButton1Click:Connect(cb)
	return b
end

----------------------------------------------------------
-- Funciones
----------------------------------------------------------
local function setNoclip(on)
	if on then
		originalCollide={}
		for _,v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				originalCollide[v]=v.CanCollide
				v.CanCollide=false
			end
		end
		noclipConn=RS.Stepped:Connect(function()
			for _,v in ipairs(character:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide=false end
			end
		end)
		notify("🚫 Noclip ACTIVADO")
	else
		if noclipConn then noclipConn:Disconnect() end
		for p,coll in pairs(originalCollide) do if p then p.CanCollide=coll end end
		notify("✅ Noclip DESACTIVADO")
	end
end

local function setFly(on)
	if on then
		flyConn=RS.Heartbeat:Connect(function()
			if not hrp then return end
			local dir=humanoid.MoveDirection
			local cam=workspace.CurrentCamera
			local pitchY=cam.CFrame.LookVector.Y
			local mag=math.clamp(dir.Magnitude,0,1)
			local vertical=pitchY*mag
			local move=Vector3.new(dir.X,vertical,dir.Z)
			if move.Magnitude>0 then move=move.Unit else move=Vector3.zero end
			hrp.AssemblyLinearVelocity=move*speed
		end)
		humanoid.PlatformStand=true
		notify("🕊️ Fly ACTIVADO")
	else
		if flyConn then flyConn:Disconnect() end
		humanoid.PlatformStand=false
		hrp.AssemblyLinearVelocity=Vector3.zero
		notify("🕊️ Fly DESACTIVADO")
	end
end

----------------------------------------------------------
-- Botones
----------------------------------------------------------
makeButton("Noclip (toggle)", 42,function()
	noclip=not noclip
	setNoclip(noclip)
end)

makeButton("Fly (toggle)", 80,function()
	flying=not flying
	setFly(flying)
end)

makeButton("Guardar TP",118,function()
	tpSavePos=hrp.Position
	notify("📍 Posición guardada")
end)

makeButton("Ir al TP",156,function()
	if tpSavePos then
		hrp.CFrame=CFrame.new(tpSavePos)
		notify("⚡ Teletransportado")
	else
		notify("❌ No hay posición guardada")
	end
end)

----------------------------------------------------------
-- ESP Automático
----------------------------------------------------------
local function createESP(p)
	pcall(function()
		if p~=player and p.Character and p.Character:FindFirstChild("Head") then
			if not p.Character.Head:FindFirstChild("PicolasESP") then
				local gui=Instance.new("BillboardGui",p.Character.Head)
				gui.Name="PicolasESP"
				gui.Size=UDim2.new(0,100,0,25)
				gui.AlwaysOnTop=true
				local txt=Instance.new("TextLabel",gui)
				txt.Size=UDim2.new(1,0,1,0)
				txt.BackgroundTransparency=1
				txt.Font=Enum.Font.GothamBold
				txt.TextSize=14
				txt.TextColor3=Color3.new(1,1,1)
				txt.Text=p.Name
			end
		end
	end)
end

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() createESP(p) end)
end)

makeButton("👁️ Forzar ESP",194,function()
	for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
	notify("👁️ ESP aplicado")
end)

----------------------------------------------------------
-- Modo Carrera
----------------------------------------------------------
makeButton("Modo Carrera",232,function()
	carrera=not carrera
	if carrera then
		carreraConn=RS.Heartbeat:Connect(function()
			if not hrp then return end
			local p=Instance.new("Part")
			p.Anchored=true
			p.CanCollide=true
			p.Size=Vector3.new(5,0.3,5)
			p.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0))
			p.Material=Enum.Material.Neon
			p.Transparency=0.4
			p.Color=Color3.fromHSV(tick()%5/5,1,1)
			p.Parent=workspace
			game.Debris:AddItem(p,0.3)
			hrp.AssemblyLinearVelocity=hrp.AssemblyLinearVelocity+Vector3.new(0,0.3,0)
		end)
		notify("🏃‍♂️ Modo Carrera ACTIVADO")
	else
		if carreraConn then carreraConn:Disconnect() end
		notify("✅ Modo Carrera DESACTIVADO")
	end
end)

----------------------------------------------------------
-- Control de velocidad
----------------------------------------------------------
local speedLabel = Instance.new("TextLabel",main)
speedLabel.Size=UDim2.new(1,0,0,25)
speedLabel.Position=UDim2.new(0,0,0,270)
speedLabel.BackgroundTransparency=1
speedLabel.Font=Enum.Font.Gotham
speedLabel.TextColor3=Color3.new(1,1,1)
speedLabel.Text="⚡ Velocidad: "..speed

makeButton("Velocidad +",294,function()
	speed=math.clamp(speed+10,10,300)
	getgenv().LastSpeed=speed
	speedLabel.Text="⚡ Velocidad: "..speed
end)

makeButton("Velocidad -",328,function()
	speed=math.clamp(speed-10,10,300)
	getgenv().LastSpeed=speed
	speedLabel.Text="⚡ Velocidad: "..speed
end)

----------------------------------------------------------
-- Invisibilidad
----------------------------------------------------------
makeButton("Invisibilidad",362,function()
	invisible=not invisible
	for _,v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency=invisible and 1 or 0
		elseif v:IsA("Decal") then
			v.Transparency=invisible and 1 or 0
		end
	end
	notify(invisible and "🕶️ Invisibilidad ACTIVADA" or "🕶️ Invisibilidad DESACTIVADA")
end)

----------------------------------------------------------
-- Reset & Limpieza
----------------------------------------------------------
makeButton("🔁 Respawn",398,function()
	character:BreakJoints()
end)

makeButton("🔴 Desactivar TODO",434,function()
	if flying then setFly(false) flying=false end
	if noclip then setNoclip(false) noclip=false end
	if carrera then carreraConn:Disconnect() carrera=false end
	if invisible then
		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency=0 end
		end
		invisible=false
	end
	notify("🧹 Todos los modos desactivados")
end)

----------------------------------------------------------
-- Botón Flotante RGB
----------------------------------------------------------
local toggleBtn = Instance.new("TextButton",gui)
toggleBtn.Size=UDim2.new(0,50,0,50)
toggleBtn.Position=UDim2.new(0,20,1,-70)
toggleBtn.BackgroundColor3=Color3.fromHSV(0,1,1)
toggleBtn.Text="💡"
toggleBtn.TextSize=22
toggleBtn.TextColor3=Color3.new(1,1,1)
toggleBtn.Font=Enum.Font.GothamBold
local toggleStroke = Instance.new("UIStroke",toggleBtn)
toggleStroke.Thickness=3

task.spawn(function()
	local h=0
	while task.wait(0.03) do
		h=(h+2)%360
		local c=Color3.fromHSV(h/360,1,1)
		toggleBtn.BackgroundColor3=c
		toggleStroke.Color=c
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	hubVisible=not hubVisible
	main.Visible=hubVisible
end)