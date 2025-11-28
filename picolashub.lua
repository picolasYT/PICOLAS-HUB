-- ☆ PICOLAS HUB PRO V3.5 (Fusion Edition) ☆
-- Mov | Visual | Teleport | System | Combat | Aimbot Pro (Normal / 360 / Circle / Smooth / AutoShoot)
-- Uso exclusivo en tus juegos - Edición combinada (V2.5 + V3)
-- Desarrollado por PICOLAS 🔥

if getgenv().PicolasHubV3_5 then return end
getgenv().PicolasHubV3_5 = true

------------------------------------------------
-- LIBRERÍAS Y SERVICIOS
------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------
-- GUI
------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "☆ PICOLAS HUB PRO V3.5 ☆",
   LoadingTitle = "PICOLAS HUB",
   LoadingSubtitle = "Fusion Edition",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PicolasHub",
      FileName  = "PicolasHubV3_5"
   },
   KeySystem = false
})

local MovTab = Window:CreateTab("🕊 MOV")
local VisTab = Window:CreateTab("👁 VISUAL")
local TPTab  = Window:CreateTab("📍 TELEPORT")
local CombatTab = Window:CreateTab("⚔ COMBAT")
local SysTab = Window:CreateTab("⚙ SYSTEM")

------------------------------------------------
-- VARIABLES
------------------------------------------------
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

------------------------------------------------
-- FIX RESPAWN AUTOMATICO
------------------------------------------------
local function restoreStates()
   task.wait(0.3)

   if fly then
      if startFly then startFly() end
   end

   if noclip and character then
      for _,v in pairs(character:GetDescendants()) do
         if v:IsA("BasePart") then
            v.CanCollide = false
         end
      end
   end
end

player.CharacterAdded:Connect(function(c)
   character = c
   humanoid = c:WaitForChild("Humanoid")
   restoreStates()
end)

-- MOV
local fly, noclip, sprint, freecam = false,false,false,false
local flySpeed, freecamSpeed = 60,2
local flyVel, flyGyro, freecamConn, keys

-- COMBAT
local killAura, autoheal = false,false
local killAuraRadius = 15

-- AIMBOT
local aimbotEnabled = false
local aimbotMode = "Normal"
local targetPart = "Head"
local aimbotFOV = 60
local aimbotCircleRadius = 150
local aimbotOnTeam = false
local smoothAim = true
local smoothSpeed = 0.15
local autoShoot = true

------------------------------------------------
-- FUNCIONES BÁSICAS
------------------------------------------------
local function isSameTeam(a,b)
   return a.Team and b.Team and a.Team == b.Team
end

local function getPart(char)
   if targetPart == "Head" then
      return char:FindFirstChild("Head")
   elseif targetPart == "Torso" then
      return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
   else
      local list = {"Head", "HumanoidRootPart", "Torso"}
      local pick = list[math.random(#list)]
      return char:FindFirstChild(pick)
   end
end

------------------------------------------------
-- FLY SYSTEM
------------------------------------------------
function startFly()
   local hrp = character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end
   flyVel = Instance.new("BodyVelocity", hrp)
   flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
   flyGyro = Instance.new("BodyGyro", hrp)
   flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
   flyGyro.P = 10000
end

function stopFly()
   if flyVel then flyVel:Destroy() end
   if flyGyro then flyGyro:Destroy() end
   flyVel,flyGyro=nil,nil
end

------------------------------------------------
-- FREECAM
------------------------------------------------
local function disableFreecam()
   freecam = false
   if freecamConn then freecamConn:Disconnect() freecamConn=nil end
   cam.CameraType = Enum.CameraType.Custom
end

local function enableFreecam()
   freecam = true
   cam.CameraType = Enum.CameraType.Scriptable
   local camCF = cam.CFrame
   local pos = camCF.Position
   keys = {}
   UIS.InputBegan:Connect(function(i) keys[i.KeyCode] = true end)
   UIS.InputEnded:Connect(function(i) keys[i.KeyCode] = false end)
   freecamConn = RunService.RenderStepped:Connect(function()
      local dir = Vector3.new()
      if keys[Enum.KeyCode.W] then dir += camCF.LookVector end
      if keys[Enum.KeyCode.S] then dir -= camCF.LookVector end
      if keys[Enum.KeyCode.A] then dir -= camCF.RightVector end
      if keys[Enum.KeyCode.D] then dir += camCF.RightVector end
      if keys[Enum.KeyCode.E] then dir += Vector3.new(0,1,0) end
      if keys[Enum.KeyCode.Q] then dir -= Vector3.new(0,1,0) end
      if dir.Magnitude > 0 then pos += dir.Unit * freecamSpeed end
      camCF = CFrame.new(pos, pos + camCF.LookVector)
      cam.CFrame = camCF
   end)
end

------------------------------------------------
-- NOCLIP
------------------------------------------------
RunService.Stepped:Connect(function()
   if noclip and character then
      for _,v in pairs(character:GetDescendants()) do
         if v:IsA("BasePart") then v.CanCollide = false end
      end
   end
end)

------------------------------------------------
-- CÍRCULO AIMBOT
------------------------------------------------
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 60
circle.Color = Color3.fromRGB(255,0,0)
circle.Transparency = 0.7
circle.Visible = false
circle.Filled = false

------------------------------------------------
-- TARGET SELECTION (ORIGINAL)
------------------------------------------------
local function getClosest()
   local best,closest=nil,math.huge
   local mouse = UIS:GetMouseLocation()
   for _,plr in pairs(Players:GetPlayers()) do
      if plr~=player and plr.Character then
         local hum = plr.Character:FindFirstChildOfClass("Humanoid")
         local part = getPart(plr.Character)
         if hum and hum.Health>0 and part then
            if not (aimbotOnTeam and isSameTeam(player,plr)) then
               local pos = cam:WorldToViewportPoint(part.Position)
               local dist2D = (Vector2.new(pos.X,pos.Y)-mouse).Magnitude
               local dist3D = (part.Position-cam.CFrame.Position).Magnitude
               local dir = (part.Position - cam.CFrame.Position).Unit
               local angle = math.deg(math.acos(cam.CFrame.LookVector:Dot(dir)))
               if aimbotMode=="Circle" and dist2D<=aimbotCircleRadius then
                  if dist2D<closest then best=part closest=dist2D end
               elseif aimbotMode=="360" then
                  if dist3D<closest then best=part closest=dist3D end
               elseif aimbotMode=="Normal" and angle<=(aimbotFOV/2) then
                  if angle<closest then best=part closest=angle end
               end
            end
         end
      end
   end
   return best
end

------------------------------------------------
-- AIMBOT LOOP (ORIGINAL)
------------------------------------------------
RunService.RenderStepped:Connect(function()
   if not aimbotEnabled then circle.Visible=false return end
   local mouse = UIS:GetMouseLocation()
   if aimbotMode=="Circle" then
      circle.Position = Vector2.new(mouse.X,mouse.Y)
      circle.Radius = aimbotCircleRadius
      circle.Visible = true
   else circle.Visible = false end
   local part = getClosest()
   if part then
      local targetCF = CFrame.new(cam.CFrame.Position,part.Position)
      if smoothAim then cam.CFrame = cam.CFrame:Lerp(targetCF,smoothSpeed)
      else cam.CFrame = targetCF end
      if autoShoot then pcall(function()
         local tool = character:FindFirstChildOfClass("Tool")
         if tool then tool:Activate() end
      end) end
   end
end)

------------------------------------------------
-- COMBOS
------------------------------------------------
RunService.Heartbeat:Connect(function()
   if fly and flyVel and flyGyro then
      flyVel.Velocity = cam.CFrame.LookVector * flySpeed
      flyGyro.CFrame = cam.CFrame
   end
   if sprint then humanoid.WalkSpeed = 80 end
   if autoheal and humanoid.Health < 60 then humanoid.Health = humanoid.MaxHealth end
   if killAura then
      local hrp = character:FindFirstChild("HumanoidRootPart")
      if hrp then
         for _,p in pairs(Players:GetPlayers()) do
            if p~=player and p.Character then
               local h = p.Character:FindFirstChildOfClass("Humanoid")
               local r = p.Character:FindFirstChild("HumanoidRootPart")
               if h and r and h.Health>0 then
                  if (r.Position - hrp.Position).Magnitude <= killAuraRadius then
                     local tool = character:FindFirstChildOfClass("Tool")
                     if tool then tool:Activate() end
                  end
               end
            end
         end
      end
   end
end)

------------------------------------------------
-- ESP SYSTEM (AGREGADO)
------------------------------------------------
local espTextEnabled = false
local espBoxEnabled = false
local espObjects = {}

local function clearESP()
   for _,v in pairs(espObjects) do
      if v.text then v.text:Remove() end
      if v.box then v.box:Remove() end
   end
   espObjects = {}
end

local function createESP(plr)
   if plr == player then return end
   espObjects[plr] = {}

   local txt = Drawing.new("Text")
   txt.Center = true
   txt.Outline = true
   txt.Size = 18
   txt.Color = Color3.fromRGB(255,255,255)
   txt.Visible = false

   local box = Drawing.new("Square")
   box.Thickness = 2
   box.Color = Color3.fromRGB(255,0,0)
   box.Filled = false
   box.Visible = false

   espObjects[plr].text = txt
   espObjects[plr].box = box
end

Players.PlayerAdded:Connect(createESP)
for _,p in pairs(Players:GetPlayers()) do createESP(p) end

RunService.RenderStepped:Connect(function()
   for plr,data in pairs(espObjects) do
      if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
         local pos,vis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)

         if espTextEnabled then
            data.text.Visible = vis
            data.text.Position = Vector2.new(pos.X,pos.Y - 30)
            data.text.Text = plr.Name
         else
            data.text.Visible = false
         end

         if espBoxEnabled then
            local dist = (cam.CFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            local size = math.clamp(2000/dist, 30, 300)
            data.box.Visible = vis
            data.box.Size = Vector2.new(size, size*2)
            data.box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
         else
            data.box.Visible = false
         end
      end
   end
end)

------------------------------------------------
-- UI CONTROLS
------------------------------------------------
MovTab:CreateToggle({Name="Fly",Callback=function(v) fly=v if v then startFly() else stopFly() end end})
MovTab:CreateSlider({Name="Fly Speed",Range={20,200},CurrentValue=flySpeed,Callback=function(v) flySpeed=v end})
MovTab:CreateToggle({Name="Noclip",Callback=function(v) noclip=v end})
MovTab:CreateToggle({Name="Auto Sprint",Callback=function(v) sprint=v end})
MovTab:CreateToggle({Name="FreeCam",Callback=function(v) if v then enableFreecam() else disableFreecam() end end})
MovTab:CreateSlider({Name="FreeCam Speed",Range={1,10},CurrentValue=freecamSpeed,Callback=function(v) freecamSpeed=v end})

CombatTab:CreateToggle({Name="Aimbot",Callback=function(v) aimbotEnabled=v end})
CombatTab:CreateDropdown({Name="Modo",Options={"Normal","360","Circle"},Callback=function(v) aimbotMode=v end})
CombatTab:CreateDropdown({Name="Zona de Apunte",Options={"Head","Torso","Random"},Callback=function(v) targetPart=v end})
CombatTab:CreateToggle({Name="No Atacar Team",Callback=function(v) aimbotOnTeam=v end})
CombatTab:CreateToggle({Name="Smooth Aim",Callback=function(v) smoothAim=v end})
CombatTab:CreateSlider({Name="Velocidad Aim",Range={0.05,0.4},Increment=0.01,CurrentValue=smoothSpeed,Callback=function(v) smoothSpeed=v end})
CombatTab:CreateToggle({Name="Auto Disparo",Callback=function(v) autoShoot=v end})
CombatTab:CreateSlider({Name="FOV",Range={10,180},CurrentValue=aimbotFOV,Callback=function(v) aimbotFOV=v end})
CombatTab:CreateSlider({Name="Radio Circle",Range={20,500},CurrentValue=aimbotCircleRadius,Callback=function(v) aimbotCircleRadius=v end})
CombatTab:CreateToggle({Name="Kill Aura",Callback=function(v) killAura=v end})
CombatTab:CreateToggle({Name="Auto Heal",Callback=function(v) autoheal=v end})

VisTab:CreateToggle({Name="ESP Nombres",Callback=function(v) espTextEnabled=v if not v then clearESP() end end})
VisTab:CreateToggle({Name="ESP Cuadro",Callback=function(v) espBoxEnabled=v if not v then clearESP() end end})

TPTab:CreateButton({Name="Guardar TP1",Callback=function() if character:FindFirstChild("HumanoidRootPart") then _G.TP1=character.HumanoidRootPart.CFrame end end})
TPTab:CreateButton({Name="Ir a TP1",Callback=function() if _G.TP1 then character.HumanoidRootPart.CFrame=_G.TP1 end end})

SysTab:CreateButton({Name="Rejoin",Callback=function() TeleportService:Teleport(game.PlaceId, player) end})

Rayfield:Notify({
   Title="PICOLAS HUB PRO V3.5",
   Content="ESP + Respawn Fix activos",
   Duration=5
})

pcall(function() Rayfield:LoadConfiguration() end)
