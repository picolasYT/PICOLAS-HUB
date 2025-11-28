-- ☆ PICOLAS HUB PRO V2.5 (Rayfield Edition) ☆
-- Mov | Visual | Teleport | System | Combat | Aimbot (Normal / 360 / Circle)
-- Uso exclusivo en tus juegos

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting        = game:GetService("Lighting")
local VirtualUser     = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local cam    = workspace.CurrentCamera

------------------------------------------------
-- GUI
------------------------------------------------

local Window = Rayfield:CreateWindow({
   Name = "☆ PICOLAS HUB PRO V2.5 ☆",
   LoadingTitle = "PICOLAS HUB",
   LoadingSubtitle = "Owner Edition",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PicolasHub",
      FileName  = "PicolasHubV2_5"
   },
   KeySystem = false
})

local MovTab    = Window:CreateTab("🕊 MOV", nil)
local VisTab    = Window:CreateTab("👁 VISUAL", nil)
local TPTab     = Window:CreateTab("📍 TELEPORT", nil)
local SysTab    = Window:CreateTab("⚙ SYSTEM", nil)
local CombatTab = Window:CreateTab("⚔ COMBAT", nil)

------------------------------------------------
-- PLAYER DATA
------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
end)

------------------------------------------------
-- VARIABLES
------------------------------------------------

local fly        = false
local noclip     = false
local invis      = false
local esp        = false
local boxESP     = false
local sprint     = false
local autoheal   = false
local killAura   = false
local freecam    = false

local aimbotEnabled      = false
local aimbotFOV          = 60
local aimbotCircleRadius = 150
local aimbotMode         = "Normal"
local aimbotOnTeam       = false

local holdingAim = false

local flySpeed       = 60
local freecamSpeed   = 2
local killAuraRadius = 15

local TP1, TP2
local lastHit = 0
local ADMIN_GROUP_ID = 0

------------------------------------------------
-- LIGHTING ORIGINAL
------------------------------------------------

local original = {
    Brightness = Lighting.Brightness,
    Clock      = Lighting.ClockTime,
    Fog        = Lighting.FogEnd
}

------------------------------------------------
-- AIMBOT CIRCLE VISUAL
------------------------------------------------

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Thickness = 2
circle.Transparency = 0.7
circle.Color = Color3.fromRGB(255,0,0)
circle.NumSides = 50
circle.Filled = false

RunService.RenderStepped:Connect(function()
    if aimbotMode == "Circle" and aimbotEnabled then
        local m = UIS:GetMouseLocation()
        circle.Position = Vector2.new(m.X, m.Y)
        circle.Radius = aimbotCircleRadius
        circle.Visible = true
    else
        circle.Visible = false
    end
end)

------------------------------------------------
-- FLY
------------------------------------------------

local flyVel, flyGyro

local function startFly()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyVel = Instance.new("BodyVelocity", hrp)
    flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)

    flyGyro = Instance.new("BodyGyro", hrp)
    flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    flyGyro.P = 10000
end

local function stopFly()
    if flyVel then flyVel:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    flyVel, flyGyro = nil, nil
end

------------------------------------------------
-- FREECAM
------------------------------------------------

local freecamConn = nil
local keys = {}

local function disableFreecam()
    freecam = false
    if freecamConn then freecamConn:Disconnect() freecamConn = nil end
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
-- INVISIBLE
------------------------------------------------

local function setInvisible(state)
    if not character then return end
    for _,v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = state and 1 or 0
        end
    end
end

------------------------------------------------
-- ESP TEXTO
------------------------------------------------

local espFolder = Instance.new("Folder")
espFolder.Name = "PicolasESP"
espFolder.Parent = player.PlayerGui

local function clearESP() espFolder:ClearAllChildren() end

local function createESP(plr)
    if plr == player then return end
    local function attach()
        if not plr.Character then return end
        local head = plr.Character:FindFirstChild("Head")
        local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
        local hrp  = plr.Character:FindFirstChild("HumanoidRootPart")
        if not head or not hum or not hrp then return end

        local bill = Instance.new("BillboardGui", espFolder)
        bill.Adornee = head
        bill.Size = UDim2.new(0,200,0,30)
        bill.AlwaysOnTop = true
        bill.Name = plr.Name

        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(255,255,255)
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true

        RunService.Heartbeat:Connect(function()
            if plr.Character and character and hum then
                local d = math.floor((hrp.Position - character.HumanoidRootPart.Position).Magnitude)
                txt.Text = plr.Name.." | "..math.floor(hum.Health).." HP | "..d.."m"
            end
        end)
    end

    attach()
    plr.CharacterAdded:Connect(function()
        if esp then task.wait(1) attach() end
    end)
end

local function enableESP()
    clearESP()
    for _,p in pairs(Players:GetPlayers()) do createESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    if esp then createESP(p) end
end)

------------------------------------------------
-- BOX ESP
------------------------------------------------

local highlightFolder = Instance.new("Folder", player.PlayerGui)
highlightFolder.Name = "PicolasBoxes"

local function clearBoxESP() highlightFolder:ClearAllChildren() end

local function createBoxESP(plr)
    if plr == player then return end
    local function attach()
        if not plr.Character then return end
        local hl = Instance.new("Highlight")
        hl.Adornee = plr.Character
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.fromRGB(255,0,0)
        hl.Parent = highlightFolder
    end
    attach()
    plr.CharacterAdded:Connect(function()
        if boxESP then task.wait(1) attach() end
    end)
end

local function enableBoxESP()
    clearBoxESP()
    for _,p in pairs(Players:GetPlayers()) do createBoxESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    if boxESP then createBoxESP(p) end
end)

------------------------------------------------
-- AIMBOT CORE
------------------------------------------------

local function isSameTeam(a,b)
    return a.Team and b.Team and a.Team == b.Team
end

local function getClosest()
    local best, smallest = nil, nil

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and head then
                if not (aimbotOnTeam and isSameTeam(player, plr)) then

                    local screenPos = cam:WorldToViewportPoint(head.Position)
                    local mouse = UIS:GetMouseLocation()
                    local dist2D = (Vector2.new(screenPos.X,screenPos.Y) - mouse).Magnitude
                    local dir = (head.Position - cam.CFrame.Position).Unit
                    local angle = math.deg(math.acos(cam.CFrame.LookVector:Dot(dir)))
                    local dist3D = (head.Position - cam.CFrame.Position).Magnitude

                    if aimbotMode == "Circle" and dist2D <= aimbotCircleRadius then
                        if not smallest or dist2D < smallest then smallest = dist2D best = plr end
                    elseif aimbotMode == "360" then
                        if not smallest or dist3D < smallest then smallest = dist3D best = plr end
                    elseif aimbotMode == "Normal" and angle <= (aimbotFOV/2) then
                        if not smallest or angle < smallest then smallest = angle best = plr end
                    end
                end
            end
        end
    end
    return best
end

UIS.InputBegan:Connect(function(i,gpe)
    if not gpe and i.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingAim = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingAim = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled or not holdingAim then return end
    local target = getClosest()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position)
        end
    end
end)

------------------------------------------------
-- COMBOS (Fly / Sprint / AutoHeal / KillAura)
------------------------------------------------

RunService.Heartbeat:Connect(function()
    if fly and flyVel and flyGyro then
        flyVel.Velocity = cam.CFrame.LookVector * flySpeed
        flyGyro.CFrame = cam.CFrame
    end

    if sprint and humanoid then humanoid.WalkSpeed = 80 end
    if autoheal and humanoid and humanoid.Health < 60 then humanoid.Health = humanoid.MaxHealth end

    if killAura and character and humanoid and humanoid.Health > 0 then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and (tick() - lastHit) > 0.3 then
            local closest, distMin
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local phrp= plr.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and phrp then
                        local d = (phrp.Position - hrp.Position).Magnitude
                        if d <= killAuraRadius and (not distMin or d < distMin) then
                            distMin = d
                            closest = plr
                        end
                    end
                end
            end
            if closest and character:FindFirstChildOfClass("Tool") then
                pcall(function() character:FindFirstChildOfClass("Tool"):Activate() end)
                lastHit = tick()
            end
        end
    end
end)

------------------------------------------------
-- UI CONTROLS
------------------------------------------------

-- MOV
MovTab:CreateToggle({Name="Fly",Callback=function(v) fly=v if v then startFly() else stopFly() end end})
MovTab:CreateSlider({Name="Fly Speed",Range={10,200},CurrentValue=flySpeed,Callback=function(v) flySpeed=v end})
MovTab:CreateToggle({Name="Noclip",Callback=function(v) noclip=v end})
MovTab:CreateSlider({Name="WalkSpeed",Range={16,200},CurrentValue=humanoid.WalkSpeed,Callback=function(v) humanoid.WalkSpeed=v end})
MovTab:CreateSlider({Name="JumpPower",Range={50,300},CurrentValue=humanoid.JumpPower,Callback=function(v) humanoid.JumpPower=v end})
MovTab:CreateToggle({Name="Auto Sprint",Callback=function(v) sprint=v end})
MovTab:CreateToggle({Name="FreeCam",Callback=function(v) if v then enableFreecam() else disableFreecam() end end})
MovTab:CreateSlider({Name="FreeCam Speed",Range={1,10},CurrentValue=freecamSpeed,Callback=function(v) freecamSpeed=v end})

-- VIS
VisTab:CreateToggle({Name="ESP Players (Texto)",Callback=function(v) esp=v if v then enableESP() else clearESP() end end})
VisTab:CreateToggle({Name="ESP Boxes (Highlight)",Callback=function(v) boxESP=v if v then enableBoxESP() else clearBoxESP() end end})
VisTab:CreateToggle({Name="Invisible",Callback=function(v) invis=v setInvisible(v) end})
VisTab:CreateToggle({Name="FullBright",Callback=function(v)
    if v then Lighting.Brightness=3 Lighting.ClockTime=14
    else Lighting.Brightness=original.Brightness Lighting.ClockTime=original.Clock end
end})
VisTab:CreateToggle({Name="No Fog",Callback=function(v)
    if v then Lighting.FogEnd=999999 else Lighting.FogEnd=original.Fog end
end})

-- TELEPORT
TPTab:CreateButton({Name="Guardar TP1",Callback=function() if character:FindFirstChild("HumanoidRootPart") then TP1=character.HumanoidRootPart.CFrame end end})
TPTab:CreateButton({Name="Ir a TP1",Callback=function() if TP1 and character:FindFirstChild("HumanoidRootPart") then character.HumanoidRootPart.CFrame=TP1 end end})
TPTab:CreateButton({Name="Guardar TP2",Callback=function() if character:FindFirstChild("HumanoidRootPart") then TP2=character.HumanoidRootPart.CFrame end end})
TPTab:CreateButton({Name="Ir a TP2",Callback=function() if TP2 and character:FindFirstChild("HumanoidRootPart") then character.HumanoidRootPart.CFrame=TP2 end end})
TPTab:CreateInput({Name="TP a jugador",PlaceholderText="Nombre exacto",Callback=function(t)
    local target=Players:FindFirstChild(t)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame=target.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
    else
        Rayfield:Notify({Title="TP",Content="Jugador no encontrado",Duration=3})
    end
end})

-- COMBAT
CombatTab:CreateToggle({Name="Kill Aura",Callback=function(v) killAura=v end})
CombatTab:CreateSlider({Name="Kill Aura Radio",Range={5,50},CurrentValue=killAuraRadius,Callback=function(v) killAuraRadius=v end})

CombatTab:CreateDropdown({
    Name="Aimbot Mode",
    Options={"Normal","360","Circle"},
    CurrentOption="Normal",
    Callback=function(v) aimbotMode=v end
})

CombatTab:CreateSlider({Name="Aimbot Circle Radius",Range={10,500},CurrentValue=aimbotCircleRadius,Callback=function(v) aimbotCircleRadius=v end})
CombatTab:CreateToggle({Name="Aimbot (mantener RMB)",Callback=function(v) aimbotEnabled=v end})
CombatTab:CreateSlider({Name="Aimbot FOV",Range={10,180},CurrentValue=aimbotFOV,Callback=function(v) aimbotFOV=v end})

-- SYSTEM
SysTab:CreateToggle({Name="Auto Heal",Callback=function(v) autoheal=v end})

local antiAFKConn
SysTab:CreateToggle({Name="Anti AFK",Callback=function(v)
    if v then
        if not antiAFKConn then
            antiAFKConn=player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(), cam.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(), cam.CFrame)
            end)
        end
    else
        if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn=nil end
    end
end})

SysTab:CreateButton({Name="Rejoin",Callback=function() TeleportService:Teleport(game.PlaceId, player) end})
SysTab:CreateButton({Name="Reset Character",Callback=function() if player.Character then player.Character:BreakJoints() end end})

SysTab:CreateButton({Name="Scan Admin (Simple)",Callback=function()
    local found={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player then
            local name=string.lower(p.Name.." "..(p.DisplayName or ""))
            local isAdmin=name:find("admin") or name:find("owner")
            local inGroup=false
            if ADMIN_GROUP_ID~=0 then pcall(function() if p:IsInGroup(ADMIN_GROUP_ID) then inGroup=true end end) end
            if isAdmin or inGroup then table.insert(found,p.Name) end
        end
    end
    if #found>0 then
        Rayfield:Notify({Title="Admin Detector",Content="Posibles admins: "..table.concat(found,", "),Duration=5})
    else
        Rayfield:Notify({Title="Admin Detector",Content="No se detectaron admins.",Duration=4})
    end
end})

SysTab:CreateButton({Name="DESACTIVAR TODO",Callback=function()
    fly=false noclip=false invis=false esp=false boxESP=false sprint=false autoheal=false killAura=false
    aimbotEnabled=false holdingAim=false disableFreecam()
    stopFly() clearESP() clearBoxESP() setInvisible(false)
    Rayfield:Notify({Title="PICOLAS HUB",Content="Todo desactivado",Duration=3})
end})

------------------------------------------------
-- NOTIFY + LOAD CONFIG
------------------------------------------------

Rayfield:Notify({Title="PICOLAS HUB PRO V2.5",Content="Script creado por PICOLAS 🤑",Duration=4})
pcall(function() Rayfield:LoadConfiguration() end)