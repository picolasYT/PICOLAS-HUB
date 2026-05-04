-- ☆ PICOLAS HUB PRO V5 (FUSION ULTIMATE EDITION) ☆
-- MOV | VISUAL PRO | TELEPORT | SYSTEM | COMBAT (VERSIÓN SIMPLIFICADA)
-- Aimbot estilo key system | Sin killaura ni modos extra
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

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

------------------------------------------------
-- RESPAWN FIX
------------------------------------------------
local function restoreStates()
    task.wait(0.3)
    if fly then if startFly then startFly() end end
    if noclip and character then
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
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
    LoadingSubtitle = "El mejor script de ROBLOX está cargando...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PicolasHub",
        FileName = "PicolasHubV4"
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
local flyVel, flyGyro
local keys={}
local freecamConn

------------------------------------------------
-- NUEVAS VARIABLES COMBAT (solo aimbot)
------------------------------------------------
local AimbotEnabled = false
local Sensitivity = 0.2   -- suavizado
local AimPart = "Head"    -- fijo, como en el script de ejemplo

-- Función enemy check (sin toggle, por teams)
local function IsEnemy(targetPlayer)
    if targetPlayer == player then return false end
    if not player.Team or not targetPlayer.Team then return true end
    return targetPlayer.Team ~= player.Team
end

-- Obtiene el enemigo más cercano al mouse (por distancia en pantalla)
local function GetClosestEnemy()
    local closestDist = math.huge
    local closest = nil
    local mousePos = UIS:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsEnemy(plr) and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = plr.Character:FindFirstChild(AimPart)
            if hum and targetPart and hum.Health > 0 then
                local screenPoint, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distToMouse = (mousePos - screenVec).Magnitude
                    if distToMouse < closestDist then
                        closestDist = distToMouse
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

-- Loop del aimbot
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local part = target.Character[AimPart]
            local goal = CFrame.new(cam.CFrame.Position, part.Position)
            cam.CFrame = cam.CFrame:Lerp(goal, Sensitivity)
        end
    end
end)

------------------------------------------------
-- FLY (viejo)
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
        if keys[Enum.KeyCode.W] then dir+=camCF.LookVector end
        if keys[Enum.KeyCode.S] then dir-=camCF.LookVector end
        if keys[Enum.KeyCode.A] then dir-=camCF.RightVector end
        if keys[Enum.KeyCode.D] then dir+=camCF.RightVector end
        if keys[Enum.KeyCode.E] then dir+=Vector3.new(0,1,0) end
        if keys[Enum.KeyCode.Q] then dir-=Vector3.new(0,1,0) end
        if dir.Magnitude>0 then pos+=dir.Unit*freecamSpeed end
        camCF=CFrame.new(pos,pos+camCF.LookVector)
        cam.CFrame=camCF
    end)
end

------------------------------------------------
-- NOCLIP
------------------------------------------------
RunService.Stepped:Connect(function()
    if noclip and character then
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)

------------------------------------------------
-- LOW GRAPHICS
------------------------------------------------
local function setLowGraphics(state)
    if state then
        Lighting.GlobalShadows=false
        Lighting.FogEnd=1e5
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material=Enum.Material.SmoothPlastic
                v.Reflectance=0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency=1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled=false
            end
        end
        pcall(function()
            UserSettings.GameSettings.SavedQualityLevel=Enum.SavedQualitySetting.QualityLevel1
        end)
    else
        Rayfield:Notify({Title="Low-GFX",Content="Reiniciá para restaurar gráficos.",Duration=4})
    end
end

------------------------------------------------
-- STRIP PERSONAJE
------------------------------------------------
local function stripCharacter()
    for _,d in ipairs(character:GetDescendants()) do
        if d:IsA("Decal") or d:IsA("Texture") then d:Destroy() end
        if d:IsA("Accessory") then d:Destroy() end
        if d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then d:Destroy() end
        if d:IsA("ParticleEmitter") then d.Enabled=false end
    end
end

------------------------------------------------
-- ESP PRO (sin cambios)
------------------------------------------------
local espText,espBox,espHP,espDist,espHL=false,false,false,false,false
local espObjects={}
local espLines = false
local lineOrigin = "Screen"

local function clearESP()
    for _,d in pairs(espObjects) do
        for _,o in pairs(d) do pcall(function() o:Remove() end) end
    end
    espObjects={}
end

local function makeESP(plr)
    if plr==player then return end
    local d={}
    d.txt=Drawing.new("Text"); d.txt.Center=true; d.txt.Outline=true; d.txt.Size=16; d.txt.Visible=false
    d.box=Drawing.new("Square"); d.box.Thickness=1; d.box.Visible=false
    d.hp=Drawing.new("Line"); d.hp.Thickness=2; d.hp.Visible=false
    d.line = Drawing.new("Line")
    d.line.Thickness = 2
    d.line.Color = Color3.fromRGB(255,0,0)
    d.line.Visible = false
    d.hl=Instance.new("Highlight"); d.hl.Enabled=false; d.hl.FillTransparency=.7; d.hl.Parent=plr
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

            if espText then
                d.txt.Visible=on
                d.txt.Position=Vector2.new(pos.X,pos.Y-24)
                d.txt.Text=plr.Name..(espDist and string.format(" | %.0fm",dist) or "")
            else d.txt.Visible=false end

            if espBox then
                d.box.Visible=on
                d.box.Position=Vector2.new(pos.X-size/2,pos.Y-size)
                d.box.Size=Vector2.new(size,size*1.9)
                d.box.Color=Color3.fromRGB(255,0,0)
            else d.box.Visible=false end

            if espHP then
                local hp=hum.Health/hum.MaxHealth
                d.hp.Visible=on
                d.hp.From=Vector2.new(pos.X-size/2-4,pos.Y)
                d.hp.To=Vector2.new(pos.X-size/2-4,pos.Y-(size*1.9*hp))
                d.hp.Color=Color3.fromRGB(0,255,0)
            else d.hp.Visible=false end

            if espHL then
                d.hl.Enabled=true; d.hl.Adornee=ch; d.hl.FillColor=Color3.fromRGB(255,0,0)
            else d.hl.Enabled=false end

            if espLines then
                local from
                if lineOrigin == "Screen" then
                    from = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                elseif lineOrigin == "Bottom" then
                    from = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                else
                    local myRoot = character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local p,_ = cam:WorldToViewportPoint(myRoot.Position)
                        from = Vector2.new(p.X, p.Y)
                    end
                end
                if from then
                    d.line.From = from
                    d.line.To = Vector2.new(pos.X, pos.Y)
                    d.line.Visible = true
                end
            else
                d.line.Visible = false
            end
        else
            if d.txt then d.txt.Visible=false end
            if d.box then d.box.Visible=false end
            if d.hp then d.hp.Visible=false end
            if d.hl then d.hl.Enabled=false end
            if d.line then d.line.Visible=false end
        end
    end
end)

------------------------------------------------
-- MOVIMIENTOS (fly, sprint) sin killaura/autoheal
------------------------------------------------
RunService.Heartbeat:Connect(function()
    if fly and flyVel and flyGyro then
        flyVel.Velocity=cam.CFrame.LookVector*flySpeed
        flyGyro.CFrame=cam.CFrame
    end
    if sprint then humanoid.WalkSpeed=80 end
    -- Nota: autoheal y killaura han sido eliminados
end)

------------------------------------------------
-- UI CONTROLES (la pestaña COMBAT es NUEVA, simple)
------------------------------------------------
MovTab:CreateToggle({Name="Fly",Callback=function(v) fly=v if v then startFly() else stopFly() end end})
MovTab:CreateSlider({Name="Fly Speed",Range={20,200},CurrentValue=flySpeed,Callback=function(v) flySpeed=v end})
MovTab:CreateToggle({Name="Noclip",Callback=function(v) noclip=v end})
MovTab:CreateToggle({Name="Sprint",Callback=function(v) sprint=v end})
MovTab:CreateToggle({Name="Freecam",Callback=function(v) if v then enableFreecam() else disableFreecam() end end})
MovTab:CreateSlider({Name="Freecam Speed",Range={1,10},CurrentValue=freecamSpeed,Callback=function(v) freecamSpeed=v end})

VisTab:CreateToggle({Name="ESP Nombre",Callback=function(v)espText=v end})
VisTab:CreateToggle({Name="ESP Caja",Callback=function(v)espBox=v end})
VisTab:CreateToggle({Name="ESP Vida",Callback=function(v)espHP=v end})
VisTab:CreateToggle({Name="Distancia",Callback=function(v)espDist=v end})
VisTab:CreateToggle({Name="Wallhack",Callback=function(v)espHL=v end})
VisTab:CreateToggle({Name="ESP Lines",Callback=function(v) espLines=v end})
VisTab:CreateDropdown({Name="Origen de líneas",Options={"Screen","Bottom","Player"},Callback=function(v) lineOrigin=v end})

-- NUEVA PESTAÑA COMBAT (solamente aimbot + suavizado)
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v) AimbotEnabled = v end
})
CombatTab:CreateSlider({
    Name = "Suavizado",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = 0.2,
    Callback = function(v) Sensitivity = v end
})

TPTab:CreateButton({Name="Guardar TP1",Callback=function()
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if hrp then _G.TP1=hrp.CFrame end
end})
TPTab:CreateButton({Name="Ir TP1",Callback=function()
    local hrp=character:FindFirstChild("HumanoidRootPart")
    if _G.TP1 and hrp then hrp.CFrame=_G.TP1 end
end})

SysTab:CreateToggle({Name="Low Graphics EXTREMO",Callback=setLowGraphics})
SysTab:CreateButton({Name="Quitar cara/ropa/accesorios",Callback=stripCharacter})
SysTab:CreateButton({Name="Rejoin",Callback=function() TeleportService:Teleport(game.PlaceId,player) end})

------------------------------------------------
-- FINAL
------------------------------------------------
Rayfield:Notify({
    Title="PICOLAS HUB PRO V5",
    Content="Combate reemplazado por aimbot simple estilo key system | Sin killaura",
    Duration=6
})

pcall(function() Rayfield:LoadConfiguration() end)        return char:FindFirstChild(p)
    end
end

------------------------------------------------
-- FLY (VIEJO COMPLETO)
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
-- FREECAM COMPLETO (VIEJO)
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
        if keys[Enum.KeyCode.W] then dir+=camCF.LookVector end
        if keys[Enum.KeyCode.S] then dir-=camCF.LookVector end
        if keys[Enum.KeyCode.A] then dir-=camCF.RightVector end
        if keys[Enum.KeyCode.D] then dir+=camCF.RightVector end
        if keys[Enum.KeyCode.E] then dir+=Vector3.new(0,1,0) end
        if keys[Enum.KeyCode.Q] then dir-=Vector3.new(0,1,0) end
        if dir.Magnitude>0 then pos+=dir.Unit*freecamSpeed end
        camCF=CFrame.new(pos,pos+camCF.LookVector)
        cam.CFrame=camCF
    end)
end

------------------------------------------------
-- NOCLIP
------------------------------------------------
RunService.Stepped:Connect(function()
    if noclip and character then
        for _,v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)

------------------------------------------------
-- LOW GRAPHICS (NUEVO)
------------------------------------------------
local function setLowGraphics(state)
    if state then
        Lighting.GlobalShadows=false
        Lighting.FogEnd=1e5
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material=Enum.Material.SmoothPlastic
                v.Reflectance=0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency=1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled=false
            end
        end
        pcall(function()
            UserSettings.GameSettings.SavedQualityLevel=Enum.SavedQualitySetting.QualityLevel1
        end)
    else
        Rayfield:Notify({Title="Low-GFX",Content="Reiniciá para restaurar gráficos.",Duration=4})
    end
end

------------------------------------------------
-- STRIP PERSONAJE (NUEVO)
------------------------------------------------
local function stripCharacter()
    for _,d in ipairs(character:GetDescendants()) do
        if d:IsA("Decal") or d:IsA("Texture") then d:Destroy() end
        if d:IsA("Accessory") then d:Destroy() end
        if d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then d:Destroy() end
        if d:IsA("ParticleEmitter") then d.Enabled=false end
    end
end

------------------------------------------------
-- ESP PRO (NUEVO)
------------------------------------------------
local espText,espBox,espHP,espDist,espHL=false,false,false,false,false
local espObjects={}
local espLines = false
local lineOrigin = "Screen" -- "Screen", "Bottom", "Player"

local function clearESP()
    for _,d in pairs(espObjects) do
        for _,o in pairs(d) do pcall(function() o:Remove() end) end
    end
    espObjects={}
end

local function makeESP(plr)
    if plr==player then return end
    local d={}
    d.txt=Drawing.new("Text"); d.txt.Center=true; d.txt.Outline=true; d.txt.Size=16; d.txt.Visible=false
    d.box=Drawing.new("Square"); d.box.Thickness=1; d.box.Visible=false
    d.hp=Drawing.new("Line"); d.hp.Thickness=2; d.hp.Visible=false
    d.line = Drawing.new("Line")
d.line.Thickness = 2
d.line.Color = Color3.fromRGB(255,0,0)
d.line.Visible = false
    d.hl=Instance.new("Highlight"); d.hl.Enabled=false; d.hl.FillTransparency=.7; d.hl.Parent=plr
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

            if espText then
                d.txt.Visible=on
                d.txt.Position=Vector2.new(pos.X,pos.Y-24)
                d.txt.Text=plr.Name..(espDist and string.format(" | %.0fm",dist) or "")
            else d.txt.Visible=false end

            if espBox then
                d.box.Visible=on
                d.box.Position=Vector2.new(pos.X-size/2,pos.Y-size)
                d.box.Size=Vector2.new(size,size*1.9)
                d.box.Color=Color3.fromRGB(255,0,0)
            else d.box.Visible=false end

            if espHP then
                local hp=hum.Health/hum.MaxHealth
                d.hp.Visible=on
                d.hp.From=Vector2.new(pos.X-size/2-4,pos.Y)
                d.hp.To=Vector2.new(pos.X-size/2-4,pos.Y-(size*1.9*hp))
                d.hp.Color=Color3.fromRGB(0,255,0)
            else d.hp.Visible=false end

            if espHL then
                d.hl.Enabled=true; d.hl.Adornee=ch; d.hl.FillColor=Color3.fromRGB(255,0,0)
            else d.hl.Enabled=false end

            -- ✅ ESP LINE / TRACER
if espLines then
    local from

    if lineOrigin == "Screen" then
        from = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    elseif lineOrigin == "Bottom" then
        from = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
    else -- Player
        local myRoot = character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local p,_ = cam:WorldToViewportPoint(myRoot.Position)
            from = Vector2.new(p.X, p.Y)
        end
    end

    d.line.From = from
    d.line.To = Vector2.new(pos.X, pos.Y)
    d.line.Visible = true
else
    d.line.Visible = false
end

        else
            if d.txt then d.txt.Visible=false end
            if d.box then d.box.Visible=false end
            if d.hp then d.hp.Visible=false end
            if d.hl then d.hl.Enabled=false end
        end
    end
end)

------------------------------------------------
-- AIMBOT NUEVO
------------------------------------------------
local function getClosest()
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then

            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local enemyRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local part = getTargetPart(plr.Character)

            if hum and enemyRoot and part and hum.Health > 0 then

                -- ignorar teammates
                if ignoreTeam and sameTeam(player, plr) then
                    continue
                end

                -- distancia REAL
                local distance = (enemyRoot.Position - myRoot.Position).Magnitude

                -- respetar límite de rango
                if distance <= MAX_DISTANCE then

                    -- 🚫 NO APUNTAR DEMASIADO HACIA ABAJO
                    local dir = (part.Position - cam.CFrame.Position).Unit
                    local verticalAngle = math.deg(math.asin(dir.Y))

                    if verticalAngle < MAX_DOWN_ANGLE then
                        continue
                    end

                    -- quedarse con el MÁS CERCANO
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = plr
                    end

                end
            end
        end
    end

    return closestPlayer
end

CombatTab:CreateToggle({Name="Botón Mobile",Callback=function(v)mobileHeld=v end})
local function isAiming()
    if UIS.MouseEnabled then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        return mobileHeld
    end
end

local circle=Drawing.new("Circle")
circle.Thickness=2; circle.NumSides=60; circle.Filled=false
circle.Color=Color3.fromRGB(255,70,70); circle.Visible=false

RunService.RenderStepped:Connect(function()
    if aimbotMode=="Circle" and aimbotEnabled then
        local m=UIS:GetMouseLocation()
        circle.Position=m; circle.Radius=circleRadius; circle.Visible=true
    else
        circle.Visible=false
    end

    if not aimbotEnabled then currentTarget=nil; return end

    if (not currentTarget) or (not currentTarget.Character) or
       currentTarget.Character:FindFirstChildOfClass("Humanoid").Health<=0 then
        currentTarget=getClosest()
    end

    if currentTarget and isAiming() then
        local part=getTargetPart(currentTarget.Character)
        if part then
            local goal=CFrame.new(cam.CFrame.Position,part.Position)
            cam.CFrame=cam.CFrame:Lerp(goal,smoothSpeed)
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
-- COMBOS (VIEJOS)
------------------------------------------------
RunService.Heartbeat:Connect(function()
    if fly and flyVel and flyGyro then
        flyVel.Velocity=cam.CFrame.LookVector*flySpeed
        flyGyro.CFrame=cam.CFrame
    end
    if sprint then humanoid.WalkSpeed=80 end
    if autoheal and humanoid.Health<60 then humanoid.Health=humanoid.MaxHealth end
    if killAura then
        local hrp=character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=player and p.Character then
                    local h=p.Character:FindFirstChildOfClass("Humanoid")
                    local r=p.Character:FindFirstChild("HumanoidRootPart")
                    if h and r and h.Health>0 then
                        if (r.Position-hrp.Position).Magnitude<=killAuraRadius then
                            local tool=character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                        end
                    end
                end
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
MovTab:CreateToggle({Name="Sprint",Callback=function(v) sprint=v end})
MovTab:CreateToggle({Name="Freecam",Callback=function(v) if v then enableFreecam() else disableFreecam() end end})
MovTab:CreateSlider({Name="Freecam Speed",Range={1,10},CurrentValue=freecamSpeed,Callback=function(v) freecamSpeed=v end})

VisTab:CreateToggle({Name="ESP Nombre",Callback=function(v)espText=v end})
VisTab:CreateToggle({Name="ESP Caja",Callback=function(v)espBox=v end})
VisTab:CreateToggle({Name="ESP Vida",Callback=function(v)espHP=v end})
VisTab:CreateToggle({Name="Distancia",Callback=function(v)espDist=v end})
VisTab:CreateToggle({Name="Wallhack",Callback=function(v)espHL=v end})
VisTab:CreateToggle({
    Name="ESP Lines",
    Callback=function(v)
        espLines = v
    end
})

VisTab:CreateDropdown({
    Name="Origen de líneas",
    Options={"Screen","Bottom","Player"},
    Callback=function(v)
        lineOrigin = v
    end
})

CombatTab:CreateToggle({Name="Aimbot",Callback=function(v)aimbotEnabled=v end})
CombatTab:CreateDropdown({Name="Modo",Options={"Normal","360","Circle"},Callback=function(v)aimbotMode=v end})
CombatTab:CreateDropdown({Name="Objetivo",Options={"Head","Torso","Random"},Callback=function(v)targetPart=v end})
CombatTab:CreateToggle({Name="Ignorar Team",Callback=function(v)ignoreTeam=v end})
CombatTab:CreateToggle({Name="Auto Shoot",Callback=function(v)autoShoot=v end})
CombatTab:CreateSlider({Name="FOV",Range={20,180},CurrentValue=aimbotFOV,Callback=function(v)aimbotFOV=v end})
CombatTab:CreateSlider({Name="Circle Radius",Range={20,500},CurrentValue=circleRadius,Callback=function(v)circleRadius=v end})
CombatTab:CreateSlider({Name="Smooth",Range={0.05,0.45},Increment=0.01,CurrentValue=smoothSpeed,Callback=function(v)smoothSpeed=v end})
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

SysTab:CreateToggle({Name="Low Graphics EXTREMO",Callback=setLowGraphics})
SysTab:CreateButton({Name="Quitar cara/ropa/accesorios",Callback=stripCharacter})
SysTab:CreateButton({Name="Rejoin",Callback=function() TeleportService:Teleport(game.PlaceId,player) end})

------------------------------------------------
-- FINAL
------------------------------------------------
Rayfield:Notify({
    Title="PICOLAS HUB PRO V5",
    Content="FUSION COMPLETO ACTIVO — Todo integrado",
    Duration=6
})

pcall(function() Rayfield:LoadConfiguration() end)
