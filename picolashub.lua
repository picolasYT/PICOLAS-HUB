-- ☆ PICOLAS HUB PRO V3 (Mobile Edition) ☆
-- PRO AIMBOT + ANTI-DETECT + AUTOSHOOT + MULTI TARGET ZONES
-- USO EXCLUSIVO EN TUS JUEGOS

if getgenv().PicolasV3 then return end
getgenv().PicolasV3 = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------
-- GUI
------------------------------------------------

local Window = Rayfield:CreateWindow({
    Name = "☆ PICOLAS HUB PRO V3 ☆",
    LoadingTitle = "PICOLAS HUB",
    LoadingSubtitle = "Mobile Pro Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PicolasHub",
        FileName = "PicolasV3"
    },
    KeySystem = false
})

local MovTab = Window:CreateTab("🕊 MOV")
local VisTab = Window:CreateTab("👁 VISUAL")
local CombatTab = Window:CreateTab("⚔ COMBAT")
local SysTab = Window:CreateTab("⚙ SYSTEM")

------------------------------------------------
-- PLAYER
------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
end)

------------------------------------------------
-- VARIABLES
------------------------------------------------

local fly = false
local noclip = false
local sprint = false
local autoheal = false
local killAura = false

local flySpeed = 60
local killAuraRadius = 15

-- AIMBOT
local aimbotEnabled = false
local aimbotMode = "Normal"
local targetPart = "Head" -- Head / Torso / Random
local aimbotFOV = 60
local aimbotCircleRadius = 150
local aimbotOnTeam = false
local smoothAim = true
local smoothSpeed = 0.15
local autoShoot = true

------------------------------------------------
-- DRAWING CIRCLE
------------------------------------------------

pcall(function()
    Drawing = Drawing or {}
end)

local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 60
circle.Color = Color3.fromRGB(255,0,0)
circle.Transparency = 0.7
circle.Visible = false
circle.Filled = false

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
-- TEAM CHECK
------------------------------------------------
local function isSameTeam(a,b)
    return a.Team and b.Team and a.Team == b.Team
end

------------------------------------------------
-- TARGET SELECTOR
------------------------------------------------

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

local function getClosest()
    local best = nil
    local closest = math.huge
    local mouse = UIS:GetMouseLocation()

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = getPart(plr.Character)

            if hum and hum.Health > 0 and part then
                if not (aimbotOnTeam and isSameTeam(player, plr)) then

                    local pos, vis = cam:WorldToViewportPoint(part.Position)
                    local dist2D = (Vector2.new(pos.X,pos.Y) - mouse).Magnitude
                    local dist3D = (part.Position - cam.CFrame.Position).Magnitude
                    local dir = (part.Position - cam.CFrame.Position).Unit
                    local angle = math.deg(math.acos(cam.CFrame.LookVector:Dot(dir)))

                    if aimbotMode == "Circle" and dist2D <= aimbotCircleRadius then
                        if dist2D < closest then best = part closest = dist2D end
                    elseif aimbotMode == "360" then
                        if dist3D < closest then best = part closest = dist3D end
                    elseif aimbotMode == "Normal" and angle <= (aimbotFOV/2) then
                        if angle < closest then best = part closest = angle end
                    end
                end
            end
        end
    end

    return best
end

------------------------------------------------
-- AIMBOT LOOP
------------------------------------------------

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then
        circle.Visible = false
        return
    end

    local mouse = UIS:GetMouseLocation()

    if aimbotMode == "Circle" then
        circle.Position = Vector2.new(mouse.X, mouse.Y)
        circle.Radius = aimbotCircleRadius
        circle.Visible = true
    else
        circle.Visible = false
    end

    local part = getClosest()
    if part then
        local targetCF = CFrame.new(cam.CFrame.Position, part.Position)

        if smoothAim then
            cam.CFrame = cam.CFrame:Lerp(targetCF, smoothSpeed)
        else
            cam.CFrame = targetCF
        end

        if autoShoot then
            pcall(function()
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
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
                if p ~= player and p.Character then
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if h and r and h.Health > 0 then
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
-- NOCLIP
------------------------------------------------
RunService.Stepped:Connect(function()
    if noclip then
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
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

CombatTab:CreateToggle({Name="Aimbot",Callback=function(v) aimbotEnabled=v end})
CombatTab:CreateDropdown({Name="Modo Aimbot",Options={"Normal","360","Circle"},Callback=function(v) aimbotMode=v end})
CombatTab:CreateDropdown({Name="Zona de Apunte",Options={"Head","Torso","Random"},Callback=function(v) targetPart=v end})
CombatTab:CreateToggle({Name="No atacar teammates",Callback=function(v) aimbotOnTeam=v end})
CombatTab:CreateToggle({Name="Smooth Aim",Callback=function(v) smoothAim=v end})
CombatTab:CreateSlider({Name="Velocidad Aim",Range={0.05,0.4},Increment=0.01,CurrentValue=smoothSpeed,Callback=function(v) smoothSpeed=v end})
CombatTab:CreateToggle({Name="Auto Disparo",Callback=function(v) autoShoot=v end})
CombatTab:CreateSlider({Name="FOV",Range={10,180},CurrentValue=aimbotFOV,Callback=function(v) aimbotFOV=v end})
CombatTab:CreateSlider({Name="Radio Circle",Range={20,500},CurrentValue=aimbotCircleRadius,Callback=function(v) aimbotCircleRadius=v end})
CombatTab:CreateToggle({Name="Kill Aura",Callback=function(v) killAura=v end})
CombatTab:CreateToggle({Name="Auto Heal",Callback=function(v) autoheal=v end})

SysTab:CreateButton({Name="Rejoin",Callback=function() TeleportService:Teleport(game.PlaceId, player) end})

Rayfield:Notify({
    Title = "PICOLAS HUB PRO V3",
    Content = "Cargado correctamente",
    Duration = 5
})

pcall(function() Rayfield:LoadConfiguration() end)