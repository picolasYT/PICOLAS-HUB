-- 🧠 PICOLAS HUB PRO+ (Owner Edition) for YOUR GAME
-- Estética Premium + Utilidades + Combate Automático (solo para tu experiencia)
-- Colocar como LocalScript en StarterPlayerScripts

----------------------------------------------------------------
-- CONFIGURACIÓN
----------------------------------------------------------------
local PLACE_ID = game.PlaceId  -- ← si querés forzar rejoin a otro place, poné el id aquí
local AUTO_HIT_RADIUS = 10     -- distancia de golpe automático
local AUTO_HIT_COOLDOWN = 0.4  -- segundos entre golpes
local MAX_SPEED = 300

----------------------------------------------------------------
-- GUARDAS
----------------------------------------------------------------
if getgenv().PicolasHubLoaded then return end
getgenv().PicolasHubLoaded = true

----------------------------------------------------------------
-- SERVICIOS
----------------------------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

----------------------------------------------------------------
-- JUGADOR / PERSONAJE
----------------------------------------------------------------
local player = Players.LocalPlayer
local character, humanoid, hrp

local function RefreshCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
end
RefreshCharacter()
player.CharacterAdded:Connect(function()
	task.wait(1)
	RefreshCharacter()
end)

----------------------------------------------------------------
-- NOTIFY
----------------------------------------------------------------
local function notify(msg)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title="Picolas Hub", Text=msg})
	end)
end

----------------------------------------------------------------
-- ESTADOS
----------------------------------------------------------------
local flying, noclip, carrera, invisible, autoHit, espOn = false,false,false,false,false,true
local speed = getgenv().LastSpeed or 80
local tpSavePos
local lastHit = 0

----------------------------------------------------------------
-- GUI BASE
----------------------------------------------------------------
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PicolasHub"
gui.ResetOnSpawn = false

-- Blur Premium
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game:GetService("Lighting")

-- Sonidos
local function clickSound()
	local s = Instance.new("Sound", gui)
	s.SoundId = "rbxassetid://6895079853"
	s.Volume = 0.6
	s:Play()
	game.Debris:AddItem(s,2)
end

-- Partículas premium
local particle = Instance.new("ParticleEmitter")
particle.Rate = 1
particle.Speed = NumberRange.new(0)
particle.Lifetime = NumberRange.new(1)
particle.Texture = "rbxassetid://483447024"
particle.Parent = workspace.Terrain

-- Frame principal
local main = Instance.new("Frame", gui)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.Size = UDim2.new(0,280,0,520)
main.Position = UDim2.new(0.5,-140,0.5,-260)
main.Active = true
main.Draggable = true
main.Visible = true
main.ClipsDescendants = true

-- Stroke RGB
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2

task.spawn(function()
	local h=0
	while task.wait(0.02) do
		h=(h+1)%360
		stroke.Color=Color3.fromHSV(h/360,1,1)
	end
end)

-- Título animado
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,42)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Text = "🧠 PICOLAS HUB PRO+"
title.Position = UDim2.new(0,0,0,0)

local titleTween = TweenService:Create(title, TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut, -1, true), {TextColor3 = Color3.fromRGB(180,255,255)})
titleTween:Play()

-- Make Button
local function makeButton(text, y, cb)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,-20,0,32)
	b.Position = UDim2.new(0,10,0,y)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	b.AutoButtonColor = false
	b.MouseButton1Click:Connect(function()
		clickSound()
		cb()
	end)
	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(60,60,60)}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
	end)
	return b
end

----------------------------------------------------------------
-- ANIMACIÓN APERTURA / CIERRE
----------------------------------------------------------------
local hubVisible = true
local function tweenMenu(open)
	local goal = open and {Size = UDim2.new(0,280,0,520)} or {Size = UDim2.new(0,0,0,0)}
	local blurGoal = open and 10 or 0
	TweenService:Create(main,TweenInfo.new(0.35,Enum.EasingStyle.Quart),goal):Play()
	TweenService:Create(blur,TweenInfo.new(0.35),{Size=blurGoal}):Play()
end

----------------------------------------------------------------
-- FLY PRO
----------------------------------------------------------------
local bv, flyConn
local function setFly(on)
	if on then
		bv = Instance.new("BodyVelocity", hrp)
		bv.MaxForce = Vector3.new(1e9,1e9,1e9)
		flyConn = RS.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			local dir = humanoid.MoveDirection
			local move = (cam.CFrame.RightVector * dir.X + cam.CFrame.LookVector * dir.Z)
			bv.Velocity = move * speed
		end)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		notify("🕊️ Fly ON")
	else
		if flyConn then flyConn:Disconnect() end
		if bv then bv:Destroy() end
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
		notify("🕊️ Fly OFF")
	end
end

----------------------------------------------------------------
-- NOCLIP
----------------------------------------------------------------
local noclipConn
local function setNoclip(state)
	noclip = state
	if noclip then
		noclipConn = RS.Stepped:Connect(function()
			for _,v in ipairs(character:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		end)
		notify("🚫 Noclip ON")
	else
		if noclipConn then noclipConn:Disconnect() end
		for _,v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = true end
		end
		notify("✅ Noclip OFF")
	end
end

----------------------------------------------------------------
-- ESP + DETECTOR DE INVISIBLES
----------------------------------------------------------------
local function applyESP(p)
	if p == player then return end
	local function bind(char)
		local head = char:WaitForChild("Head",5)
		if not head then return end
		if head:FindFirstChild("PicolasESP") then return end

		local gui = Instance.new("BillboardGui", head)
		gui.Name = "PicolasESP"
		gui.Size = UDim2.new(0,130,0,36)
		gui.AlwaysOnTop = true

		local txt = Instance.new("TextLabel", gui)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.Font = Enum.Font.GothamBold
		txt.TextSize = 14
		txt.Text = p.Name

		RS.RenderStepped:Connect(function()
			if not hrp then return end
			local dist = (hrp.Position - head.Position).Magnitude
			if not espOn then gui.Enabled=false return else gui.Enabled=true end

			-- Colores por distancia
			if dist < 30 then txt.TextColor3 = Color3.fromRGB(255,40,40)
			elseif dist < 120 then txt.TextColor3 = Color3.fromRGB(255,180,40)
			else txt.TextColor3 = Color3.fromRGB(40,255,80) end

			-- Detector de "invisibles" (si tu juego los usa por transparencia)
			local invisibleDetected = true
			for _,v in ipairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.Transparency < 0.9 then
					invisibleDetected = false break
				end
			end
			if invisibleDetected then
				txt.Text = "👻 "..p.Name
			else
				txt.Text = p.Name
			end
		end)
	end
	if p.Character then bind(p.Character) end
	p.CharacterAdded:Connect(bind)
end

for _,p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

----------------------------------------------------------------
-- TELEPORT POR JUGADOR
----------------------------------------------------------------
local function openTPMenu()
	local menu = Instance.new("Frame", gui)
	menu.Size = UDim2.new(0,220,0,320)
	menu.Position = UDim2.new(0.5,-110,0.5,-160)
	menu.BackgroundColor3 = Color3.fromRGB(18,18,18)
	menu.Active = true
	menu.Draggable = true

	local close = Instance.new("TextButton",menu)
	close.Size = UDim2.new(1,0,0,30)
	close.Text = "❌ Cerrar"
	close.MouseButton1Click:Connect(function() menu:Destroy() end)

	local y = 36
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= player then
			local b = Instance.new("TextButton", menu)
			b.Size = UDim2.new(1,-10,0,28)
			b.Position = UDim2.new(0,5,0,y)
			b.BackgroundColor3 = Color3.fromRGB(40,40,40)
			b.TextColor3 = Color3.new(1,1,1)
			b.Text = pl.Name
			b.MouseButton1Click:Connect(function()
				if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
					hrp.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
					notify("⚡ TP a "..pl.Name)
				end
			end)
			y += 30
		end
	end
end

----------------------------------------------------------------
-- SPEED SLIDER
----------------------------------------------------------------
local speedLabel = Instance.new("TextLabel",main)
speedLabel.Size=UDim2.new(1,0,0,22)
speedLabel.Position=UDim2.new(0,0,0,260)
speedLabel.BackgroundTransparency=1
speedLabel.Font=Enum.Font.Gotham
speedLabel.TextColor3=Color3.new(1,1,1)
speedLabel.Text="⚡ Velocidad: "..speed

local slider = Instance.new("Frame", main)
slider.Position = UDim2.new(0,14,0,286)
slider.Size = UDim2.new(1,-28,0,10)
slider.BackgroundColor3 = Color3.fromRGB(80,80,80)

local handle = Instance.new("Frame", slider)
handle.Size = UDim2.new(0,12,1,0)
handle.BackgroundColor3 = Color3.fromRGB(255,80,80)
handle.Active = true
handle.Draggable = true

handle:GetPropertyChangedSignal("Position"):Connect(function()
	local scale = math.clamp(handle.Position.X.Scale,0,1)
	speed = math.clamp(math.floor(scale * MAX_SPEED),10,MAX_SPEED)
	getgenv().LastSpeed = speed
	speedLabel.Text = "⚡ Velocidad: "..speed
end)

----------------------------------------------------------------
-- PROXIMITY HIT (AUTO-MELEE)
----------------------------------------------------------------
RS.Heartbeat:Connect(function()
	if not autoHit or not hrp then return end
	if tick() - lastHit < AUTO_HIT_COOLDOWN then return end
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
			local d = (hrp.Position - pl.Character.HumanoidRootPart.Position).Magnitude
			if d <= AUTO_HIT_RADIUS then
				lastHit = tick()
				-- DISPARÁ AQUÍ TU REMOTEEVENT DE ATAQUE
				-- EJEMPLO:
				-- game.ReplicatedStorage.Remotes.MeleeHit:FireServer(pl.Character)
				notify("🥊 Hit -> "..pl.Name)
				break
			end
		end
	end
end)

----------------------------------------------------------------
-- QUICK BUTTONS
----------------------------------------------------------------
makeButton("🚫 Noclip (toggle)", 52, function()
	noclip = not noclip
	setNoclip(noclip)
end)

makeButton("🕊️ Fly (toggle)", 92, function()
	flying = not flying
	setFly(flying)
end)

makeButton("📍 Guardar TP", 132, function()
	tpSavePos = hrp.Position
	notify("Posición guardada")
end)

makeButton("⚡ Ir al TP", 172, function()
	if tpSavePos then hrp.CFrame = CFrame.new(tpSavePos) end
end)

makeButton("👤 TP por jugador", 212, openTPMenu)

makeButton("👁️ ESP (toggle)", 326, function()
	espOn = not espOn
	notify(espOn and "ESP ON" or "ESP OFF")
end)

makeButton("🥊 Auto Hit (toggle)", 366, function()
	autoHit = not autoHit
	notify(autoHit and "Auto Hit ON" or "Auto Hit OFF")
end)

makeButton("🔄 Rejoin", 406, function()
	notify("Reingresando...")
	TeleportService:Teleport(PLACE_ID, player)
end)

makeButton("🔁 Respawn", 446, function()
	character:BreakJoints()
end)

makeButton("🧹 Apagar TODO", 486, function()
	if flying then setFly(false) flying=false end
	if noclip then setNoclip(false) noclip=false end
	autoHit=false
	espOn=true
	notify("Todo desactivado")
end)

----------------------------------------------------------------
-- BOTÓN FLOTANTE
----------------------------------------------------------------
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0,52,0,52)
toggleBtn.Position = UDim2.new(0,18,1,-70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
toggleBtn.Text = "💡"
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold

toggleBtn.MouseButton1Click:Connect(function()
	hubVisible = not hubVisible
	tweenMenu(hubVisible)
end)

----------------------------------------------------------------
-- TECLAS RÁPIDAS
----------------------------------------------------------------
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.F then flying = not flying setFly(flying) end
	if i.KeyCode == Enum.KeyCode.N then noclip = not noclip setNoclip(noclip) end
end)

notify("✅ Picolas Hub cargado correctamente")
