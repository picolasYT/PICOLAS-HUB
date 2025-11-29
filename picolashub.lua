-- ☆ PICOLAS HUB PRO V5 (FUSION ULTIMATE EDITION) ☆
-- MOV | VISUAL PRO | TELEPORT | SYSTEM | COMBAT | AIMBOT PRO (MOBILE)
-- Desarrollado por PICOLAS 🔥

if getgenv().PicolasHubV5 then return end
getgenv().PicolasHubV5 = true

------------------------------------------------
-- LIBRERÍAS / SERVICIOS
------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local UserSettings = UserSettings()

local MAX_DISTANCE = 40
local TARGET_SWITCH_DISTANCE = 1.5

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

------------------------------------------------
-- RESPAWN FIX
------------------------------------------------
local function restoreStates()
    task.wait(0.3)
    if fly and startFly then startFly() end
    if noclip and character then
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    restoreStates()
end)

------------------------------------------------
-- UI
------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "☆ PICOLAS HUB PRO V5 ☆",
    LoadingTitle = "PICOLAS HUB",
    LoadingSubtitle = "Cargando... Grxias por utilizar el script",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PicolasHub",
        FileName = "PicolasHubV5"
    }
})

local MovTab    = Window:CreateTab("🕊 MOV")
local VisTab    = Window:CreateTab("👁 VISUAL")
local TPTab     = Window:CreateTab("📍 TELEPORT")
local CombatTab = Window:CreateTab("🎯 COMBAT")
local SysTab    = Window:CreateTab("⚙ SYSTEM")

------------------------------------------------
-- VARIABLES MOV
------------------------------------------------
fly=false; noclip=false; sprint=false; freecam=false
flySpeed=60; freecamSpeed=2
local flyVel, flyGyro, keys={}, freecamConn

------------------------------------------------
-- VARIABLES COMBAT
------------------------------------------------
killAura=false; autoheal=false
killAuraRadius=15

------------------------------------------------
-- VARIABLES AIMBOT
------------------------------------------------
local aimbotEnabled=false
local aimbotMode="Normal"
local targetPart="Head"
local aimbotFOV=80
local circleRadius=150
local smoothSpeed=0.18
local autoShoot=false
local ignoreTeam=true
local mobileHeld=false
local currentTarget

------------------------------------------------
-- UTILS
------------------------------------------------
local function sameTeam(a,b)
    return a.Team and b.Team and a.Team==b.Team
end

local function getTargetPart(char)
    if targetPart=="Head" then return char:FindFirstChild("Head")
    elseif targetPart=="Torso" then return char:FindFirstChild("HumanoidRootPart")
    else
        local p=math.random(1,2)==1 and "Head" or "HumanoidRootPart"
        return char:FindFirstChild(p)
    end
end

------------------------------------------------
-- FLY
------------------------------------------------
function startFly()
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flyVel=Instance.new("BodyVelocity",hrp)
    flyVel.MaxForce=Vector3.new(9e9,9e9,9e9)
    flyGyro=Instance.new("BodyGyro",hrp)
    flyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
    flyGyro.P=10000
end

function stopFly()
    if flyVel then flyVel:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    flyVel=nil; flyGyro=nil
end

------------------------------------------------
-- FREECAM
------------------------------------------------
local function disableFreecam()
    freecam=false
    if freecamConn then freecamConn:Disconnect() end
    cam.CameraType=Enum.CameraType.Custom
end

local function enableFreecam()
    freecam=true
    cam.CameraType=Enum.CameraType.Scriptable
    local camCF=cam.CFrame
    local pos=camCF.Position
    keys={}

    UIS.InputBegan:Connect(function(i) keys[i.KeyCode]=true end)
    UIS.InputEnded:Connect(function(i) keys[i.KeyCode]=false end)

    freecamConn=RunService.RenderStepped:Connect(function()
        local dir=Vector3.new()
        if keys.W then dir+=camCF.LookVector end
        if keys.S then dir-=camCF.LookVector end
        if keys.A then dir-=camCF.RightVector end
        if keys.D then dir+=camCF.RightVector end
        if keys.E then dir+=Vector3.new(0,1,0) end
        if keys.Q then dir-=Vector3.new(0,1,0) end
        if dir.Magnitude>0 then pos+=dir.Unit*freecamSpeed end
        camCF=CFrame.new(pos,pos+camCF.LookVector)
        cam.CFrame=camCF
    end)
end

------------------------------------------------
-- ESP
------------------------------------------------
local espText,espBox,espHP,espDist,espHL=false,false,false,false,false
local espObjects={}
local espLines=false
local lineOrigin="Screen"

local function makeESP(plr)
    if plr==player then return end
    local d={}
    d.txt=Drawing.new("Text"); d.txt.Center=true; d.txt.Outline=true; d.txt.Size=16
    d.box=Drawing.new("Square"); d.box.Thickness=1
    d.hp=Drawing.new("Line"); d.hp.Thickness=2
    d.line=Drawing.new("Line"); d.line.Thickness=2
    d.line.Color=Color3.fromRGB(255,0,0)
    d.hl=Instance.new("Highlight"); d.hl.FillTransparency=.7; d.hl.Parent=plr
    espObjects[plr]=d
end

Players.PlayerAdded:Connect(makeESP)
for _,p in ipairs(Players:GetPlayers()) do makeESP(p) end

RunService.RenderStepped:Connect(function()
    for plr,d in pairs(espObjects) do
        local ch=plr.Character
        local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health>0 then
            local pos,on=cam:WorldToViewportPoint(hrp.Position)
            local dist=(cam.CFrame.Position-hrp.Position).Magnitude
            local size=math.clamp(1800/dist,28,260)

            d.txt.Visible=espText and on
            d.txt.Position=Vector2.new(pos.X,pos.Y-24)
            d.txt.Text=plr.Name..(espDist and (" | "..math.floor(dist)) or "")

            d.box.Visible=espBox and on
            d.box.Position=Vector2.new(pos.X-size/2,pos.Y-size)
            d.box.Size=Vector2.new(size,size*1.9)

            local hp=hum.Health/hum.MaxHealth
            d.hp.Visible=espHP and on
            d.hp.From=Vector2.new(pos.X-size/2-4,pos.Y)
            d.hp.To=Vector2.new(pos.X-size/2-4,pos.Y-(size*1.9*hp))

            d.hl.Enabled=espHL
            d.hl.Adornee=ch

            if espLines then
                local from
                if lineOrigin=="Screen" then
                    from=Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                elseif lineOrigin=="Bottom" then
                    from=Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                else
                    local myRoot=character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local p,_=cam:WorldToViewportPoint(myRoot.Position)
                        from=Vector2.new(p.X,p.Y)
                    end
                end
                d.line.From=from
                d.line.To=Vector2.new(pos.X,pos.Y)
                d.line.Visible=true
            else
                d.line.Visible=false
            end
        else
            d.txt.Visible=false; d.box.Visible=false; d.hp.Visible=false; d.line.Visible=false; d.hl.Enabled=false
        end
    end
end)

------------------------------------------------
-- AIMBOT — PRIORIZA DISTANCIA REAL
------------------------------------------------
local function getClosest()
    local myRoot=character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest,dist= nil,math.huge

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player and plr.Character then
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            local root=plr.Character:FindFirstChild("HumanoidRootPart")
            local part=getTargetPart(plr.Character)

            if hum and root and part and hum.Health>0 then
                if not(ignoreTeam and sameTeam(player,plr)) then
                    local d=(root.Position-myRoot.Position).Magnitude
                    if d<dist and d<=MAX_DISTANCE then
                        closest=plr; dist=d
                    end
                end
            end
        end
    end
    return closest
end

CombatTab:CreateToggle({Name="Botón Mobile",Callback=function(v)mobileHeld=v end})

local function isAiming()
    return UIS.MouseEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or mobileHeld
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then currentTarget=nil return end

    -- soltar si muere
    if currentTarget then
        local hum=currentTarget.Character and currentTarget.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then currentTarget=nil end
    end

    -- elegir mejor
    local newTarget=getClosest()
    if newTarget then
        if not currentTarget then
            currentTarget=newTarget
        else
            local my=character:FindFirstChild("HumanoidRootPart")
            local old=currentTarget.Character:FindFirstChild("HumanoidRootPart")
            local new=newTarget.Character:FindFirstChild("HumanoidRootPart")
            if my and old and new then
                local dOld=(old.Position-my.Position).Magnitude
                local dNew=(new.Position-my.Position).Magnitude
                if dNew + TARGET_SWITCH_DISTANCE < dOld then
                    currentTarget=newTarget
                end
            end
        end
    end

    if currentTarget and isAiming() then
        local part=getTargetPart(currentTarget.Character)
        if part then
            cam.CFrame=cam.CFrame:Lerp(
                CFrame.new(cam.CFrame.Position, part.Position),
                smoothSpeed
            )
            if autoShoot then
                pcall(function()
                    local tool=character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end)
            end
        end
    end
end)

------------------------------------------------
-- UI
------------------------------------------------
MovTab:CreateToggle({Name="Fly",Callback=function(v) fly=v if v then startFly() else stopFly() end end})
MovTab:CreateSlider({Name="Fly Speed",Range={20,200},CurrentValue=flySpeed,Callback=function(v) flySpeed=v end})
MovTab:CreateToggle({Name="Noclip",Callback=function(v) noclip=v end})
MovTab:CreateToggle({Name="Sprint",Callback=function(v) sprint=v end})
MovTab:CreateToggle({Name="Freecam",Callback=function(v) if v then enableFreecam() else disableFreecam() end end})
MovTab:CreateSlider({Name="Freecam Speed",Range={1,10},CurrentValue=freecamSpeed,Callback=function(v) freecamSpeed=v end})

VisTab:CreateToggle({Name="ESP Nombre",Callback=function(v) espText=v end})
VisTab:CreateToggle({Name="ESP Caja",Callback=function(v) espBox=v end})
VisTab:CreateToggle({Name="ESP Vida",Callback=function(v) espHP=v end})
VisTab:CreateToggle({Name="Distancia",Callback=function(v) espDist=v end})
VisTab:CreateToggle({Name="Wallhack",Callback=function(v) espHL=v end})
VisTab:CreateToggle({Name="ESP Lines",Callback=function(v) espLines=v end})
VisTab:CreateDropdown({Name="Origen líneas",Options={"Screen","Bottom","Player"},Callback=function(v) lineOrigin=v end})

CombatTab:CreateToggle({Name="Aimbot",Callback=function(v)aimbotEnabled=v end})
CombatTab:CreateDropdown({Name="Modo",Options={"Normal","360","Circle"},Callback=function(v)aimbotMode=v end})
CombatTab:CreateDropdown({Name="Objetivo",Options={"Head","Torso","Random"},Callback=function(v)targetPart=v end})
CombatTab:CreateToggle({Name="Ignorar Team",Callback=function(v)ignoreTeam=v end})
CombatTab:CreateToggle({Name="Auto Shoot",Callback=function(v)autoShoot=v end})
CombatTab:CreateSlider({Name="Smooth",Range={0.05,0.45},CurrentValue=smoothSpeed,Callback=function(v)smoothSpeed=v end})
CombatTab:CreateToggle({Name="Kill Aura",Callback=function(v)killAura=v end})
CombatTab:CreateToggle({Name="Auto Heal",Callback=function(v)autoheal=v end})

TPTab:CreateButton({Name="Guardar TP1",Callback=function()
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if hrp then _G.TP1=hrp.CFrame end
end})

TPTab:CreateButton({Name="Ir TP1",Callback=function()
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if _G.TP1 and hrp then hrp.CFrame=_G.TP1 end
end})

SysTab:CreateToggle({Name="Low Graphics",Callback=function(v)
    if v then
        Lighting.GlobalShadows=false
        Lighting.FogEnd=1e5
    end
end})

SysTab:CreateButton({Name="Rejoin",Callback=function()
    TeleportService:Teleport(game.PlaceId,player)
end})

------------------------------------------------
-- FINAL
------------------------------------------------
Rayfield:Notify({
    Title="PICOLAS HUB PRO V5",
    Content="CARGADO CORRECTAMENTE",
    Duration=5
})

pcall(function() Rayfield:LoadConfiguration() end)