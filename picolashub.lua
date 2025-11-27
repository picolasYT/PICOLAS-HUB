-- ☆ PICOLAS HUB PRO V2.5 (Rayfield Edition) ☆
-- Mov | Visual | Teleport | System | Combat | Aimbot
-- Pensado para tus propios juegos, no abuses en públicos.

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

local aimbotEnabled = false
local aimbotFOV     = 60
local aimbotOnTeam  = false -- si después querés hacer team check

local holdingAim = false -- si está apretado RMB

local flySpeed       = 60
local freecamSpeed   = 2
local killAuraRadius = 15

local TP1, TP2

local flyVel, flyGyro
local freecamConn, freecamInputBeginConn, freecamInputEndConn
local keys = {}

local lastHit = 0
local ADMIN_GROUP_ID = 0 -- si querés, poné tu groupId acá

------------------------------------------------
-- FLY
------------------------------------------------

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

local function disableFreecam()
    freecam = false
    if freecamConn then freecamConn:Disconnect() freecamConn = nil end
    if freecamInputBeginConn then freecamInputBeginConn:Disconnect() freecamInputBeginConn = nil end
    if freecamInputEndConn then freecamInputEndConn:Disconnect() freecamInputEndConn = nil end
    cam.CameraType = Enum.CameraType.Custom
end

local function enableFreecam()
    freecam = true
    cam.CameraType = Enum.CameraType.Scriptable

    local camCF = cam.CFrame
    local freecamPos = camCF.Position

    keys = {}

    freecamInputBeginConn = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then keys.W = true end
        if input.KeyCode == Enum.KeyCode.S then keys.S = true end
        if input.KeyCode == Enum.KeyCode.A then keys.A = true end
        if input.KeyCode == Enum.KeyCode.D then keys.D = true end
        if input.KeyCode == Enum.KeyCode.E then keys.E = true end
        if input.KeyCode == Enum.KeyCode.Q then keys.Q = true end
    end)

    freecamInputEndConn = UIS.InputEnded:Connect(function(input, gpe)
        if input.KeyCode == Enum.KeyCode.W then keys.W = false end
        if input.KeyCode == Enum.KeyCode.S then keys.S = false end
        if input.KeyCode == Enum.KeyCode.A then keys.A = false end
        if input.KeyCode == Enum.KeyCode.D then keys.D = false end
        if input.KeyCode == Enum.KeyCode.E then keys.E = false end
        if input.KeyCode == Enum.KeyCode.Q then keys.Q = false end
    end)

    freecamConn = RunService.RenderStepped:Connect(function(dt)
        if not freecam then return end
        local moveDir = Vector3.new()

        if keys.W then moveDir = moveDir + camCF.LookVector end
        if keys.S then moveDir = moveDir - camCF.LookVector end
        if keys.A then moveDir = moveDir - camCF.RightVector end
        if keys.D then moveDir = moveDir + camCF.RightVector end
        if keys.E then moveDir = moveDir + Vector3.new(0,1,0) end
        if keys.Q then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            freecamPos = freecamPos + moveDir * freecamSpeed
        end

        camCF = CFrame.new(freecamPos, freecamPos + camCF.LookVector)
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
-- ESP NOMBRES
------------------------------------------------

local espFolder = Instance.new("Folder")
espFolder.Name = "PicolasESP"
espFolder.Parent = player:WaitForChild("PlayerGui")

local function clearESP()
    espFolder:ClearAllChildren()
end

local function createESP(plr)
    if plr == player then return end
    local function attach()
        if not plr.Character then return end
        local head = plr.Character:FindFirstChild("Head")
        local hrp  = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
        if not head or not hrp or not hum then return end

        local bill = Instance.new("BillboardGui", espFolder)
        bill.Adornee = head
        bill.Size = UDim2.new(0,200,0,30)
        bill.AlwaysOnTop = true
        bill.Name = plr.Name

        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true
        txt.TextStrokeTransparency = 0
        txt.TextColor3 = Color3.fromRGB(255,255,255)

        RunService.Heartbeat:Connect(function()
            if plr.Character and hum and character and character:FindFirstChild("HumanoidRootPart") then
                local d  = math.floor((hrp.Position - character.HumanoidRootPart.Position).Magnitude)
                local hp = math.floor(hum.Health)
                txt.Text = plr.Name.." | "..hp.." HP | "..d.."m"
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
    for _,p in pairs(Players:GetPlayers()) do
        createESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if esp then createESP(p) end
end)

------------------------------------------------
-- ESP BOXES (Highlight)
------------------------------------------------

local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PicolasHighlightESP"
highlightFolder.Parent = player.PlayerGui

local function clearBoxESP()
    highlightFolder:ClearAllChildren()
end

local function createBoxESP(plr)
    if plr == player then return end
    local function attach()
        if not plr.Character then return end
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0
        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        hl.Adornee = plr.Character
        hl.Parent = highlightFolder
    end
    attach()
    plr.CharacterAdded:Connect(function()
        if boxESP then
            task.wait(1)
            attach()
        end
    end)
end

local function enableBoxESP()
    clearBoxESP()
    for _,p in pairs(Players:GetPlayers()) do
        createBoxESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if boxESP then createBoxESP(p) end
end)

------------------------------------------------
-- AIMBOT: helpers
------------------------------------------------

local function isSameTeam(plr1, plr2)
    if not plr1 or not plr2 then return false end
    if plr1.Team and plr2.Team then
        return plr1.Team == plr2.Team
    end
    return false
end

local function getClosestToCrosshair()
    local bestPlayer = nil
    local smallestAngle = nil

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                if not (aimbotOnTeam and isSameTeam(player, plr)) then
                    local headPos = head.Position
                    local dir = (headPos - cam.CFrame.Position).Unit
                    local dot = cam.CFrame.LookVector:Dot(dir)
                    dot = math.clamp(dot, -1, 1)
                    local angle = math.deg(math.acos(dot))
                    if angle <= (aimbotFOV / 2) then
                        if not smallestAngle or angle < smallestAngle then
                            smallestAngle = angle
                            bestPlayer = plr
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

-- Detectar si está presionado el botón derecho (RMB)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingAim = true
    end
end)

UIS.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingAim = false
    end
end)

------------------------------------------------
-- COMBOS: Heartbeat (fly / sprint / autoheal / kill aura)
------------------------------------------------

RunService.Heartbeat:Connect(function()
    if fly and flyVel and flyGyro then
        flyVel.Velocity = cam.CFrame.LookVector * flySpeed
        flyGyro.CFrame = cam.CFrame
    end

    if sprint and humanoid then
        humanoid.WalkSpeed = 80
    end

    if autoheal and humanoid and humanoid.Health < 60 then
        humanoid.Health = humanoid.MaxHealth
    end

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

            if closest and closest.Character then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                    lastHit = tick()
                end
            end
        end
    end
end)

------------------------------------------------
-- AIMBOT LOOP (RenderStepped para que se vea suave)
------------------------------------------------

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled or not holdingAim then return end
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local target = getClosestToCrosshair()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local camPos = cam.CFrame.Position
            cam.CFrame = CFrame.new(camPos, head.Position)
        end
    end
end)

------------------------------------------------
-- LIGHTING ORIGINAL
------------------------------------------------

local original = {
    Brightness = Lighting.Brightness,
    Clock      = Lighting.ClockTime,
    Fog        = Lighting.FogEnd
}

------------------------------------------------
-- MOV TAB
------------------------------------------------

MovTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(v)
        fly = v
        if v then startFly() else stopFly() end
    end
})

MovTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10,200},
    Increment = 5,
    CurrentValue = flySpeed,
    Flag = "FlySpeed",
    Callback = function(v) flySpeed = v end
})

MovTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v) noclip = v end
})

MovTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,200},
    Increment = 5,
    CurrentValue = humanoid.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(v) humanoid.WalkSpeed = v end
})

MovTab:CreateSlider({
    Name = "JumpPower",
    Range = {50,300},
    Increment = 10,
    CurrentValue = humanoid.JumpPower,
    Flag = "JumpPower",
    Callback = function(v) humanoid.JumpPower = v end
})

MovTab:CreateToggle({
    Name = "Auto Sprint",
    CurrentValue = false,
    Flag = "AutoSprint",
    Callback = function(v) sprint = v end
})

MovTab:CreateToggle({
    Name = "FreeCam",
    CurrentValue = false,
    Flag = "FreeCam",
    Callback = function(v)
        if v then enableFreecam() else disableFreecam() end
    end
})

MovTab:CreateSlider({
    Name = "FreeCam Speed",
    Range = {1,10},
    Increment = 1,
    CurrentValue = freecamSpeed,
    Flag = "FreeCamSpeed",
    Callback = function(v) freecamSpeed = v end
})

------------------------------------------------
-- VIS TAB
------------------------------------------------

VisTab:CreateToggle({
    Name = "ESP Players (Texto)",
    CurrentValue = false,
    Flag = "ESPText",
    Callback = function(v)
        esp = v
        if v then enableESP() else clearESP() end
    end
})

VisTab:CreateToggle({
    Name = "ESP Boxes (Highlight)",
    CurrentValue = false,
    Flag = "ESPBox",
    Callback = function(v)
        boxESP = v
        if v then enableBoxESP() else clearBoxESP() end
    end
})

VisTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "Invisible",
    Callback = function(v)
        invis = v
        setInvisible(v)
    end
})

VisTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(v)
        if v then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
        else
            Lighting.Brightness = original.Brightness
            Lighting.ClockTime = original.Clock
        end
    end
})

VisTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(v)
        if v then
            Lighting.FogEnd = 999999
        else
            Lighting.FogEnd = original.Fog
        end
    end
})

------------------------------------------------
-- TELEPORT TAB
------------------------------------------------

TPTab:CreateButton({
    Name = "Guardar TP1",
    Callback = function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            TP1 = character.HumanoidRootPart.CFrame
        end
    end
})

TPTab:CreateButton({
    Name = "Ir a TP1",
    Callback = function()
        if TP1 and character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = TP1
        end
    end
})

TPTab:CreateButton({
    Name = "Guardar TP2",
    Callback = function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            TP2 = character.HumanoidRootPart.CFrame
        end
    end
})

TPTab:CreateButton({
    Name = "Ir a TP2",
    Callback = function()
        if TP2 and character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = TP2
        end
    end
})

TPTab:CreateInput({
    Name = "TP a jugador",
    PlaceholderText = "Nombre exacto",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local target = Players:FindFirstChild(text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
        else
            Rayfield:Notify({
                Title = "TP",
                Content = "Jugador no encontrado",
                Duration = 3
            })
        end
    end
})

------------------------------------------------
-- COMBAT TAB (Kill Aura + Aimbot)
------------------------------------------------

CombatTab:CreateToggle({
    Name = "Kill Aura (Tool en mano)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v)
        killAura = v
    end
})

CombatTab:CreateSlider({
    Name = "Kill Aura Radio",
    Range = {5,50},
    Increment = 1,
    CurrentValue = killAuraRadius,
    Flag = "KillAuraRadius",
    Callback = function(v)
        killAuraRadius = v
    end
})

CombatTab:CreateToggle({
    Name = "Aimbot (mantener RMB)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(v)
        aimbotEnabled = v
    end
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {10,180},
    Increment = 5,
    CurrentValue = aimbotFOV,
    Flag = "AimbotFOV",
    Callback = function(v)
        aimbotFOV = v
    end
})

------------------------------------------------
-- SYSTEM TAB
------------------------------------------------

SysTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Flag = "AutoHeal",
    Callback = function(v) autoheal = v end
})

local antiAFKConn

SysTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(v)
        if v then
            if not antiAFKConn then
                antiAFKConn = player.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.new(), cam.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(), cam.CFrame)
                end)
            end
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end
})

SysTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})

SysTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
        end
    end
})

SysTab:CreateButton({
    Name = "Scan Admin (Simple)",
    Callback = function()
        local found = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local name = string.lower(p.Name.." "..(p.DisplayName or ""))
                local isAdminName = name:find("admin") or name:find("owner")
                local inGroup = false
                if ADMIN_GROUP_ID ~= 0 then
                    pcall(function()
                        if p:IsInGroup(ADMIN_GROUP_ID) then
                            inGroup = true
                        end
                    end)
                end
                if isAdminName or inGroup then
                    table.insert(found, p.Name)
                end
            end
        end

        if #found > 0 then
            Rayfield:Notify({
                Title = "Admin Detector",
                Content = "Posibles admins: "..table.concat(found, ", "),
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "Admin Detector",
                Content = "No se detectaron admins (scan simple).",
                Duration = 4
            })
        end
    end
})

SysTab:CreateButton({
    Name = "DESACTIVAR TODO",
    Callback = function()
        fly      = false
        noclip   = false
        invis    = false
        esp      = false
        boxESP   = false
        sprint   = false
        autoheal = false
        killAura = false
        aimbotEnabled = false
        holdingAim = false
        disableFreecam()

        stopFly()
        clearESP()
        clearBoxESP()
        setInvisible(false)

        Rayfield:Notify({
            Title = "PICOLAS HUB",
            Content = "Todo desactivado",
            Duration = 3
        })
    end
})

------------------------------------------------
-- NOTIFY + LOAD CONFIG
------------------------------------------------

Rayfield:Notify({
    Title = "PICOLAS HUB PRO V2.5",
    Content = "Script creado por PICOLAS 🤑",
    Duration = 4
})

pcall(function()
    Rayfield:LoadConfiguration()
end)