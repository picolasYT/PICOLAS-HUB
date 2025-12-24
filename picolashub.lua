-- ☆ PICOLAS HUB PRO V5.1 (OPTIMIZED) ☆
-- Créditos: PICOLAS 🔥

if getgenv().PicolasHubV5 then return end
getgenv().PicolasHubV5 = true

------------------------------------------------
-- SERVICIOS
------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

------------------------------------------------
-- VARIABLES GLOBALES Y ESTADOS
------------------------------------------------
local fly, noclip, sprint, freecam = false, false, false, false
local flySpeed, freecamSpeed = 60, 2
local killAura, autoheal, killAuraRadius = false, false, 15

-- Aimbot Vars
local aimbotEnabled = false
local aimbotMode = "Normal" -- "Normal", "FOV"
local targetPart = "Head"
local aimbotFOV = 150
local smoothSpeed = 0.15
local autoShoot = false
local ignoreTeam = true
local mobileHeld = false
local currentTarget = nil

-- ESP Vars
local espSettings = {text = false, box = false, hp = false, dist = false, hl = false, lines = false}
local lineOrigin = "Bottom"
local espObjects = {}

------------------------------------------------
-- UTILS & CLEANUP
------------------------------------------------
local function clearESP()
    for i, d in pairs(espObjects) do
        pcall(function() d.txt:Remove() d.box:Remove() d.hp:Remove() d.line:Remove() end)
    end
    espObjects = {}
end

local function sameTeam(otherPlayer)
    if not ignoreTeam then return false end
    return player.Team ~= nil and otherPlayer.Team == player.Team
end

------------------------------------------------
-- FOV CIRCLE
------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

------------------------------------------------
-- AIMBOT LOGIC (CORREGIDO)
------------------------------------------------
local function getClosestToMouse()
    local target = nil
    local dist = math.huge
    local mousePos = UIS:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and not sameTeam(p) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local part = p.Character:FindFirstChild(targetPart == "Random" and "Head" or targetPart)
            
            if hum and hum.Health > 0 and part then
                local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if mag < dist and (not aimbotEnabled or mag < aimbotFOV) then
                        dist = mag
                        target = p
                    end
                end
            end
        end
    end
    return target
end

------------------------------------------------
-- ESP SYSTEM
------------------------------------------------
local function createESP(plr)
    if plr == player then return end
    local d = {
        txt = Drawing.new("Text"),
        box = Drawing.new("Square"),
        hp = Drawing.new("Line"),
        line = Drawing.new("Line"),
        hl = Instance.new("Highlight")
    }
    d.txt.Center = true; d.txt.Outline = true; d.txt.Size = 16
    d.box.Thickness = 1
    d.line.Thickness = 1
    d.hl.Parent = (plr.Character or nil)
    espObjects[plr] = d
end

Players.PlayerAdded:Connect(createESP)
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        pcall(function() espObjects[p].txt:Remove() espObjects[p].box:Remove() espObjects[p].hp:Remove() espObjects[p].line:Remove() end)
        espObjects[p] = nil
    end
end)

------------------------------------------------
-- UI WINDOW
------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "☆ PICOLAS HUB PRO V5.1 ☆",
    LoadingTitle = "PICOLAS HUB",
    ConfigurationSaving = {Enabled = true, FolderName = "PicolasHub"}
})

local MovTab = Window:CreateTab("🕊 MOV")
local VisTab = Window:CreateTab("👁 VISUAL")
local CombatTab = Window:CreateTab("🎯 COMBAT")
local SysTab = Window:CreateTab("⚙ SYSTEM")

------------------------------------------------
-- MOVIMIENTO (FLY CORREGIDO)
------------------------------------------------
local flyVel, flyGyro
local function toggleFly(v)
    fly = v
    if v then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flyVel = Instance.new("BodyVelocity", hrp)
        flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyGyro = Instance.new("BodyGyro", hrp)
        flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro.P = 5000
    else
        if flyVel then flyVel:Destroy() end
        if flyGyro then flyGyro:Destroy() end
    end
end

MovTab:CreateToggle({Name = "Fly", Callback = toggleFly})
MovTab:CreateSlider({Name = "Velocidad Vuelo", Range = {20, 300}, CurrentValue = 60, Callback = function(v) flySpeed = v end})
MovTab:CreateToggle({Name = "Noclip", Callback = function(v) noclip = v end})

------------------------------------------------
-- VISUALES
------------------------------------------------
VisTab:CreateToggle({Name = "ESP Nombres", Callback = function(v) espSettings.text = v end})
VisTab:CreateToggle({Name = "ESP Cajas", Callback = function(v) espSettings.box = v end})
VisTab:CreateToggle({Name = "ESP Líneas", Callback = function(v) espSettings.lines = v end})
VisTab:CreateDropdown({Name = "Origen Líneas", Options = {"Top", "Center", "Bottom"}, Callback = function(v) lineOrigin = v end})

------------------------------------------------
-- COMBATE
------------------------------------------------
CombatTab:CreateToggle({Name = "Aimbot Pro", Callback = function(v) aimbotEnabled = v end})
CombatTab:CreateToggle({Name = "Mostrar FOV", Callback = function(v) FOVCircle.Visible = v end})
CombatTab:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 150, Callback = function(v) aimbotFOV = v end})
CombatTab:CreateSlider({Name = "Suavizado (Smooth)", Range = {0.05, 0.5}, Increment = 0.01, CurrentValue = 0.15, Callback = function(v) smoothSpeed = v end})
CombatTab:CreateToggle({Name = "Ignorar Equipo", Callback = function(v) ignoreTeam = v end})
CombatTab:CreateToggle({Name = "Kill Aura", Callback = function(v) killAura = v end})

------------------------------------------------
-- BUCLE PRINCIPAL (RENDERSTEPPED)
------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Fly Movement Logic
    if fly and flyVel and flyGyro then
        local dir = Vector3.new(0, 0.1, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        
        flyVel.Velocity = dir.Unit * (dir.Magnitude > 0.1 and flySpeed or 0)
        flyGyro.CFrame = cam.CFrame
    end

    -- Noclip Logic
    if noclip and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Aimbot Logic
    if FOVCircle.Visible then
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = aimbotFOV
    end

    if aimbotEnabled and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or mobileHeld) then
        currentTarget = getClosestToMouse()
        if currentTarget and currentTarget.Character then
            local part = currentTarget.Character:FindFirstChild(targetPart == "Random" and "Head" or targetPart)
            if part then
                local targetCF = CFrame.new(cam.CFrame.Position, part.Position)
                cam.CFrame = cam.CFrame:Lerp(targetCF, smoothSpeed)
            end
        end
    end

    -- ESP Rendering
    for plr, d in pairs(espObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then
            local pos, on = cam:WorldToViewportPoint(hrp.Position)
            if on then
                local dist = (cam.CFrame.Position - hrp.Position).Magnitude
                local size = math.clamp(2000/dist, 10, 300)

                d.txt.Visible = espSettings.text
                d.txt.Position = Vector2.new(pos.X, pos.Y - size/2 - 20)
                d.txt.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"

                d.box.Visible = espSettings.box
                d.box.Size = Vector2.new(size, size * 1.5)
                d.box.Position = Vector2.new(pos.X - size/2, pos.Y - (size * 1.5)/2)

                d.line.Visible = espSettings.lines
                local from = (lineOrigin == "Bottom" and Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)) or 
                             (lineOrigin == "Top" and Vector2.new(cam.ViewportSize.X/2, 0)) or 
                             Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                d.line.From = from
                d.line.To = Vector2.new(pos.X, pos.Y)
            else
                d.txt.Visible = false; d.box.Visible = false; d.line.Visible = false
            end
        else
            d.txt.Visible = false; d.box.Visible = false; d.line.Visible = false
        end
    end
end)

------------------------------------------------
-- SYSTEM TAB
------------------------------------------------
SysTab:CreateButton({
    Name = "Destruir Script (Limpieza)",
    Callback = function()
        clearESP()
        FOVCircle:Remove()
        Rayfield:Destroy()
        getgenv().PicolasHubV5 = nil
    end
})

Rayfield:Notify({Title="PICOLAS HUB V5.1", Content="Cargado con éxito. Aimbot y Fly corregidos.", Duration=5})
