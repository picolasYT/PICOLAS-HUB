-- PICOLAS HUB DEV MODE (For YOUR game)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------------------------
-- CHARACTER
------------------------------------------------------------------
local character, humanoid
local function loadChar()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid  = character:WaitForChild("Humanoid")
end
loadChar()
player.CharacterAdded:Connect(loadChar)

------------------------------------------------------------------
-- WINDOW
------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "☆ PICOLAS HUB DEV ☆",
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
local MovTab = Window:CreateTab("🕊 MOV")
local VisTab = Window:CreateTab("👁 VIS")
local SysTab = Window:CreateTab("⚙ SYS")
local TPTab  = Window:CreateTab("📍 TP")

------------------------------------------------------------------
-- STATES
------------------------------------------------------------------
local fly, noclip = false, false
local godmode, autoheal, antiafk = false, false, false
local fullbright, nightvision, nofog = false, false, false
local esp, freecam = false, false
local flySpeed = 60
local staminaInfinite = false
local savedTP = {nil, nil}

------------------------------------------------------------------
-- HELPERS
------------------------------------------------------------------
local function notify(t,c)
    Rayfield:Notify({Title=t, Content=c, Duration=2.5})
end

------------------------------------------------------------------
-- MOV: FLY (camera direction)
------------------------------------------------------------------
local flyVel, flyGyro
local function startFly()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
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
-- MOV: NOCLIP
------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if noclip and character then
        for _,p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
end)

------------------------------------------------------------------
-- VIS: FULLBRIGHT / NIGHT
------------------------------------------------------------------
local default = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd
}
local function applyLighting()
    if fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = default.Brightness
        Lighting.ClockTime = default.ClockTime
    end
    if nightvision then
        Lighting.ClockTime = 0
        Lighting.Brightness = 2.5
    end
    if nofog then
        Lighting.FogEnd = 1e6
    else
        Lighting.FogEnd = default.FogEnd
    end
end

------------------------------------------------------------------
-- VIS: ESP DEV (players & NPCs)
------------------------------------------------------------------
local espFolder = Instance.new("Folder", player.PlayerGui)
espFolder.Name = "ESP_DEV"

local function clearESP() espFolder:ClearAllChildren() end

local function attachESP(char)
    local head = char:FindFirstChild("Head")
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not head or not hrp or not hum then return end

    local bill = Instance.new("BillboardGui", espFolder)
    bill.Adornee=head; bill.Size=UDim2.new(0,160,0,30); bill.AlwaysOnTop=true

    local txt = Instance.new("TextLabel", bill)
    txt.Size=UDim2.new(1,0,1,0); txt.BackgroundTransparency=1
    txt.Font=Enum.Font.GothamBold; txt.TextScaled=true
    txt.TextStrokeTransparency=0; txt.TextColor3=Color3.fromRGB(200,255,220)

    RunService.Heartbeat:Connect(function()
        if hum and hrp and character and character:FindFirstChild("HumanoidRootPart") then
            local d = math.floor((hrp.Position - character.HumanoidRootPart.Position).Magnitude)
            txt.Text = char.Name .. " | " .. math.floor(hum.Health) .. " HP | " .. d .. "m"
        end
    end)
end

local function enableESP()
    clearESP()
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then attachESP(p.Character) end end
    -- NPCs
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
            attachESP(m)
        end
    end
end

Players.PlayerAdded:Connect(function(p) if esp and p.Character then attachESP(p.Character) end end)
Players.PlayerRemoving:Connect(function(p) if esp then clearESP() enableESP() end end)

------------------------------------------------------------------
-- VIS: FREECAM (simple)
------------------------------------------------------------------
local Freecam = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("FreeCamera", 2) or Instance.new("ModuleScript"))
-- Fallback simple freecam:
local freecamConn
local function toggleFreecam(on)
    freecam = on
    if on then
        freecamConn = RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value+1, function()
            cam.CameraType = Enum.CameraType.Scriptable
            local cf = cam.CFrame
            local speed = 0.7
            if UIS:IsKeyDown(Enum.KeyCode.W) then cf = cf * CFrame.new(0,0,-speed) end
            if UIS:IsKeyDown(Enum.KeyCode.S) then cf = cf * CFrame.new(0,0,speed) end
            if UIS:IsKeyDown(Enum.KeyCode.A) then cf = cf * CFrame.new(-speed,0,0) end
            if UIS:IsKeyDown(Enum.KeyCode.D) then cf = cf * CFrame.new(speed,0,0) end
            cam.CFrame = cf
        end)
    else
        RunService:UnbindFromRenderStep("Freecam")
        cam.CameraType = Enum.CameraType.Custom
    end
end

------------------------------------------------------------------
-- SYS: GOD / AUTOHEAL
------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if godmode and humanoid then humanoid.Health = humanoid.MaxHealth end
    if autoheal and humanoid then humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 1) end
end)

------------------------------------------------------------------
-- SYS: ANTI-AFK
------------------------------------------------------------------
local afkConn
local function toggleAFK(v)
    antiafk=v
    if v then
        if afkConn then afkConn:Disconnect() end
        afkConn = player.Idled:Connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), cam.CFrame)
            task.wait(0.5)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), cam.CFrame)
        end)
    else
        if afkConn then afkConn:Disconnect(); afkConn=nil end
    end
end

------------------------------------------------------------------
-- TP MINI MENU (TP1 / TP2)
------------------------------------------------------------------
local TPMenu = Window:CreateTab("⚡ Config TP")
TPMenu:CreateButton({Name="Guardar TP1", Callback=function() savedTP[1]=character.HumanoidRootPart.Position; notify("TP","Guardado TP1") end})
TPMenu:CreateButton({Name="Ir a TP1",      Callback=function() if savedTP[1] then character.HumanoidRootPart.CFrame=CFrame.new(savedTP[1]) end end})
TPMenu:CreateButton({Name="Guardar TP2", Callback=function() savedTP[2]=character.HumanoidRootPart.Position; notify("TP","Guardado TP2") end})
TPMenu:CreateButton({Name="Ir a TP2",      Callback=function() if savedTP[2] then character.HumanoidRootPart.CFrame=CFrame.new(savedTP[2]) end end})
TPMenu:CreateButton({Name="Cerrar", Callback=function() notify("TP","Configurado") end})

------------------------------------------------------------------
-- UI BUILD
------------------------------------------------------------------
-- MOV
MovTab:CreateToggle({Name="Fly", Callback=function(v) fly=v; if v then startFly() else stopFly() end end})
MovTab:CreateSlider({Name="Fly Speed", Range={10,200}, CurrentValue=flySpeed, Callback=function(v) flySpeed=v end})
MovTab:CreateToggle({Name="Noclip", Callback=function(v) noclip=v end})
MovTab:CreateSlider({Name="WalkSpeed", Range={8,200}, CurrentValue=16, Callback=function(v) humanoid.WalkSpeed=v end})
MovTab:CreateSlider({Name="JumpPower", Range={20,300}, CurrentValue=humanoid.JumpPower, Callback=function(v) humanoid.JumpPower=v end})
MovTab:CreateToggle({Name="Infinite Stamina (if any)", Callback=function(v) staminaInfinite=v notify("Stamina","ON (si tu sistema existe)") end})
MovTab:CreateButton({Name="Reset Character", Callback=function() humanoid.Health = 0 end})

-- VIS
VisTab:CreateToggle({Name="ESP Dev (Players & NPC)", Callback=function(v) esp=v; if v then enableESP() else clearESP() end end})
VisTab:CreateToggle({Name="FullBright", Callback=function(v) fullbright=v; applyLighting() end})
VisTab:CreateToggle({Name="Night Vision", Callback=function(v) nightvision=v; applyLighting() end})
VisTab:CreateToggle({Name="FreeCam", Callback=function(v) toggleFreecam(v) end})
VisTab:CreateToggle({Name="No Fog", Callback=function(v) nofog=v; applyLighting() end})

-- TP (MAIN)
TPTab:CreateButton({Name="Configurar TP (abrir mini menú)", Callback=function() notify("TP","Abrí la pestaña 'Config TP'") end})
TPTab:CreateButton({Name="Zona de Pruebas", Callback=function()
    local sp = workspace:FindFirstChild("ZonaDePruebas") or workspace:FindFirstChild("TestZone")
    if sp and sp:IsA("BasePart") then character.HumanoidRootPart.CFrame = sp.CFrame end
end})
TPTab:CreateButton({Name="Spawn Principal", Callback=function()
    local sp = workspace:FindFirstChild("Spawn") or workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if sp then character.HumanoidRootPart.CFrame = sp.CFrame end
end})

-- SYS
SysTab:CreateToggle({Name="God Mode (DEV)", Callback=function(v) godmode=v end})
SysTab:CreateToggle({Name="Auto Heal", Callback=function(v) autoheal=v end})
SysTab:CreateToggle({Name="Anti-AFK", Callback=function(v) toggleAFK(v) end})
SysTab:CreateButton({Name="Desactivar TODO", Callback=function()
    fly=false; noclip=false; godmode=false; autoheal=false; antiafk=false
    fullbright=false; nightvision=false; nofog=false; esp=false; freecam=false
    stopFly(); clearESP(); toggleAFK(false); toggleFreecam(false); applyLighting()
    humanoid.WalkSpeed=16
    notify("SYS","Todo apagado")
end})
SysTab:CreateButton({Name="Guardar Config DEV", Callback=function() notify("SYS","Config guardada por Rayfield") end})

------------------------------------------------------------------
-- READY
------------------------------------------------------------------
notify("PICOLAS HUB DEV","Listo ✅")
