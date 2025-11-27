-- PICOLAS HUB DEV MODE (For your own game)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------------------------
-- LOAD CHARACTER
------------------------------------------------------------------
local character, humanoid
local function loadChar()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid  = character:WaitForChild("Humanoid")
end
loadChar()
player.CharacterAdded:Connect(loadChar)

------------------------------------------------------------------
-- HUB WINDOW
------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "☆ PICOLAS HUB DEV MODE ☆",
   LoadingTitle = "PICOLAS HUB",
   LoadingSubtitle = "Development Edition",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PicolasHubDEV",
      FileName = "Settings"
   },
   Discord = {Enabled = false},
   KeySystem = false
})

------------------------------------------------------------------
-- TABS
------------------------------------------------------------------
local MovTab = Window:CreateTab("🕊 Movement")
local VisTab = Window:CreateTab("👁 Debug / Visual")
local SysTab = Window:CreateTab("⚙ System")
local TPTab  = Window:CreateTab("📍 Teleport")

------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------
local noclip = false
local fly = false
local esp = false
local godmode = false
local antiAFK = false

local flySpeed = 50
local savedTP = {nil,nil}

local flyVel, flyGyro
local jetFX

------------------------------------------------------------------
-- FLY BY CAMERA
------------------------------------------------------------------
local function startFly()
    if not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    flyVel = Instance.new("BodyVelocity", hrp)
    flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    flyVel.Velocity = Vector3.zero

    flyGyro = Instance.new("BodyGyro", hrp)
    flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    flyGyro.P = 10000
    flyGyro.CFrame = cam.CFrame
end

local function stopFly()
    if flyVel then flyVel:Destroy(); flyVel=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
end

RunService.Heartbeat:Connect(function()
    if fly and flyVel and flyGyro then
        flyVel.Velocity = cam.CFrame.LookVector * flySpeed
        flyGyro.CFrame = cam.CFrame
    end
end)

------------------------------------------------------------------
-- NOCLIP
------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if noclip and character then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
end)

------------------------------------------------------------------
-- GODMODE (DEV)
------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if godmode and humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
end)

------------------------------------------------------------------
-- ANTI AFK
------------------------------------------------------------------
local afkConn
local function enableAFK(v)
    if v then
        if afkConn then afkConn:Disconnect() end
        afkConn = player.Idled:Connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), cam.CFrame)
            task.wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), cam.CFrame)
        end)
    else
        if afkConn then afkConn:Disconnect(); afkConn=nil end
    end
end

------------------------------------------------------------------
-- ESP DEBUG (for NPCs / Players in your game)
------------------------------------------------------------------
local espFolder = Instance.new("Folder", player.PlayerGui)

local function clearESP()
    espFolder:ClearAllChildren()
end

local function attachESP(char)
    local head = char:FindFirstChild("Head")
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end

    local bill = Instance.new("BillboardGui", espFolder)
    bill.Adornee = head
    bill.Size = UDim2.new(0,140,0,24)
    bill.AlwaysOnTop=true

    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency=1
    txt.Font=Enum.Font.GothamBold
    txt.TextScaled=true
    txt.TextColor3 = Color3.fromRGB(0,255,160)
    txt.TextStrokeTransparency=0

    RunService.Heartbeat:Connect(function()
        if hrp and character and character:FindFirstChild("HumanoidRootPart") then
            local d = math.floor((hrp.Position - character.HumanoidRootPart.Position).Magnitude)
            txt.Text = char.Name.." ["..d.."m]"
        end
    end)
end

local function enableESP()
    clearESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p.Character then attachESP(p.Character) end
    end
end

------------------------------------------------------------------
-- JET FX
------------------------------------------------------------------
local function jetFXon(v)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    if v then
        jetFX = Instance.new("ParticleEmitter", character.HumanoidRootPart)
        jetFX.Texture = "rbxassetid://241594314"
        jetFX.Speed = NumberRange.new(15,20)
        jetFX.Rate = 60
    else
        if jetFX then jetFX:Destroy() jetFX=nil end
    end
end

------------------------------------------------------------------
-- TELEPORT MENU
------------------------------------------------------------------
TPTab:CreateButton({
    Name="Guardar TP1",
    Callback=function() savedTP[1]=character.HumanoidRootPart.Position end
})

TPTab:CreateButton({
    Name="Guardar TP2",
    Callback=function() savedTP[2]=character.HumanoidRootPart.Position end
})

TPTab:CreateButton({
    Name="Ir a TP1",
    Callback=function() if savedTP[1] then character.HumanoidRootPart.CFrame=CFrame.new(savedTP[1]) end end
})

TPTab:CreateButton({
    Name="Ir a TP2",
    Callback=function() if savedTP[2] then character.HumanoidRootPart.CFrame=CFrame.new(savedTP[2]) end end
})

------------------------------------------------------------------
-- HUD
------------------------------------------------------------------
local hud = Instance.new("TextLabel", player.PlayerGui)
hud.Position = UDim2.new(1,-200,0,20)
hud.Size = UDim2.new(0,180,0,90)
hud.BackgroundTransparency = 0.3
hud.BackgroundColor3 = Color3.fromRGB(10,10,10)
hud.TextColor3 = Color3.fromRGB(0,255,160)
hud.Text = "Fly: OFF\nESP: OFF\nGod: OFF"
hud.TextScaled = true
Instance.new("UICorner",hud)

RunService.Heartbeat:Connect(function()
    hud.Text = "Fly: "..(fly and "ON" or "OFF").."\nESP: "..(esp and "ON" or "OFF").."\nGod: "..(godmode and "ON" or "OFF")
end)

------------------------------------------------------------------
-- CONFIG CONTROLS
------------------------------------------------------------------
MovTab:CreateToggle({
    Name="Fly (Camera Direction)",
    Callback=function(v)
        fly=v
        if v then startFly(); jetFXon(true) else stopFly(); jetFXon(false) end
    end
})

MovTab:CreateSlider({
    Name="Fly Speed",
    Range={10,200},
    CurrentValue=flySpeed,
    Callback=function(v) flySpeed=v end
})

MovTab:CreateToggle({Name="Noclip",Callback=function(v) noclip=v end})

VisTab:CreateToggle({
    Name="ESP Debug",
    Callback=function(v)
        esp=v
        if v then enableESP() else clearESP() end
    end
})

SysTab:CreateToggle({
    Name="God Mode (DEV)",
    Callback=function(v) godmode=v end
})

SysTab:CreateToggle({
    Name="Anti-AFK",
    Callback=function(v) antiAFK=v enableAFK(v) end
})

------------------------------------------------------------------
-- NOTIFY
------------------------------------------------------------------
Rayfield:Notify({
    Title="PICOLAS HUB DEV MODE",
    Content="Loaded successfully ✅",
    Duration=4
})
