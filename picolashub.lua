-- PICOLAS HUB - RAYFIELD EDITION

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

local Window = Rayfield:CreateWindow({
   Name = "☆ PICOLAS HUB ☆",
   LoadingTitle = "PICOLAS HUB",
   LoadingSubtitle = "Dark Edition",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "PicolasHub"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

---------------------------------------------------------------------
-- TABS
---------------------------------------------------------------------

local MovTab = Window:CreateTab("🕊 Mov", nil)
local VisTab = Window:CreateTab("👁 Visual", nil)
local SysTab = Window:CreateTab("⚙ System", nil)
local TPTab  = Window:CreateTab("📍 Teleport", nil)

---------------------------------------------------------------------
-- VARIABLES
---------------------------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
end)

local noclip = false
local fly = false
local esp = false
local invis = false

local flySpeed = 60
local savedPos

local flyVel, flyGyro

---------------------------------------------------------------------
-- FLY PRO (CAMERA CONTROLLED)
---------------------------------------------------------------------

local function startFly()
    if not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    flyVel = Instance.new("BodyVelocity")
    flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    flyVel.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    flyGyro.P = 10000
    flyGyro.CFrame = cam.CFrame
    flyGyro.Parent = hrp
end

local function stopFly()
    if flyVel then flyVel:Destroy() flyVel = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
end

RunService.Heartbeat:Connect(function()
    if fly and flyVel and flyGyro then
        flyVel.Velocity = cam.CFrame.LookVector * flySpeed
        flyGyro.CFrame = cam.CFrame
    end
end)

---------------------------------------------------------------------
-- NOCLIP
---------------------------------------------------------------------

RunService.Stepped:Connect(function()
    if noclip and character then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

---------------------------------------------------------------------
-- INVIS
---------------------------------------------------------------------

local function setInvisible(state)
    for _,p in pairs(character:GetDescendants()) do
        if p:IsA("BasePart") then
            p.LocalTransparencyModifier = state and 1 or 0
        end
    end
end

---------------------------------------------------------------------
-- ESP SIMPLE
---------------------------------------------------------------------

local espFolder = Instance.new("Folder", player.PlayerGui)

local function clearESP()
    espFolder:ClearAllChildren()
end

local function createESP(plr)
    if plr == player then return end
    local function attach()
        if not plr.Character then return end
        local head = plr.Character:FindFirstChild("Head")
        local hrp  = plr.Character:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then return end

        local bill = Instance.new("BillboardGui", espFolder)
        bill.Adornee = head
        bill.Size = UDim2.new(0,150,0,25)
        bill.AlwaysOnTop = true
        bill.Name = plr.Name

        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true
        txt.TextColor3 = Color3.fromRGB(255,255,255)
        txt.TextStrokeTransparency = 0

        RunService.Heartbeat:Connect(function()
            if plr.Character and player.Character then
                local d = math.floor((plr.Character.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).Magnitude)
                txt.Text = plr.Name.." ["..d.."m]"
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

---------------------------------------------------------------------
-- MOV TAB
---------------------------------------------------------------------

MovTab:CreateToggle({
    Name = "Fly (Camera Direction)",
    CurrentValue = false,
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
    Callback = function(v)
        flySpeed = v
    end
})

MovTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
    end
})

---------------------------------------------------------------------
-- VIS TAB
---------------------------------------------------------------------

VisTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Callback = function(v)
        esp = v
        if v then enableESP() else clearESP() end
    end
})

VisTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Callback = function(v)
        invis = v
        setInvisible(v)
    end
})

---------------------------------------------------------------------
-- TP TAB
---------------------------------------------------------------------

TPTab:CreateButton({
    Name = "Guardar posición",
    Callback = function()
        savedPos = character.HumanoidRootPart.Position
        Rayfield:Notify({
            Title="TP",
            Content="Posición guardada",
            Duration=2
        })
    end
})

TPTab:CreateButton({
    Name = "Ir a posición",
    Callback = function()
        if savedPos then
            character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
        end
    end
})

---------------------------------------------------------------------
-- SYSTEM
---------------------------------------------------------------------

SysTab:CreateButton({
    Name = "Desactivar TODO",
    Callback = function()
        noclip=false fly=false esp=false invis=false
        stopFly()
        clearESP()
        setInvisible(false)
    end
})

Rayfield:Notify({
   Title = "PICOLAS HUB",
   Content = "Listo para usar",
   Duration = 4
})
