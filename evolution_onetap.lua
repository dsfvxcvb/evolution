-- ============================================================
-- evolution | [FPS] One Tap
-- Only camera-snap silent aim; no bullet/packet manipulation.
-- ============================================================

local repo = 'https://raw.githubusercontent.com/dsfvxcvb/evolution/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
getgenv().Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local Workspace = cloneref(game:GetService("Workspace"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local SoundService = cloneref(game:GetService("SoundService"))
local Lighting = cloneref(game:GetService("Lighting"))
local TweenService = cloneref(game:GetService("TweenService"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- unload old
if typeof(Library) == "table" and typeof(Library.Unload) == "function" then
    pcall(function() Library:Unload() end)
end

local Window = Library:CreateWindow({
    Title = 'evolution',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- ============================================================
-- COMBAT
-- ============================================================
local SilentAimBox = Tabs.Combat:AddLeftGroupbox('Silent Aim')
local FovBox = Tabs.Combat:AddLeftGroupbox('FOV Circle')
local HitsoundBox = Tabs.Combat:AddRightGroupbox('Hitsounds')

getgenv().EvolutionOneTap = {
    Enabled = false,
    Triggerbot = false,
    ShowFOV = true,
    TeamCheck = false,
    FOVRadius = 300,
    MaxDistance = 1500,
    HeadHitchance = 100,
    BodyHitchance = 0,
    FOVColor = Color3.new(1, 1, 1),
    HitsoundEnabled = false,
    HitsoundId = "6565371338",
    HitsoundVolume = 1,
}
local cfg = getgenv().EvolutionOneTap

SilentAimBox:AddToggle('OT_SilentAim', {
    Text = 'Enabled',
    Default = cfg.Enabled,
    Callback = function(v) cfg.Enabled = v end
}):AddKeyPicker('OT_SilentAimKey', { Default = 'None', Mode = 'Toggle', Text = 'Silent Aim' })

SilentAimBox:AddToggle('OT_Triggerbot', {
    Text = 'Triggerbot',
    Default = cfg.Triggerbot,
    Callback = function(v) cfg.Triggerbot = v end
})

SilentAimBox:AddToggle('OT_TeamCheck', {
    Text = 'Team Check',
    Default = cfg.TeamCheck,
    Callback = function(v) cfg.TeamCheck = v end
})

SilentAimBox:AddSlider('OT_FOVRadius', {
    Text = 'FOV Radius',
    Default = cfg.FOVRadius,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) cfg.FOVRadius = v end
})

SilentAimBox:AddSlider('OT_MaxDistance', {
    Text = 'Max Distance',
    Default = cfg.MaxDistance,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Callback = function(v) cfg.MaxDistance = v end
})

SilentAimBox:AddSlider('OT_HeadChance', {
    Text = 'Head Hitchance',
    Default = cfg.HeadHitchance,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(v) cfg.HeadHitchance = v end
})

SilentAimBox:AddSlider('OT_BodyChance', {
    Text = 'Body Hitchance',
    Default = cfg.BodyHitchance,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(v) cfg.BodyHitchance = v end
})

FovBox:AddToggle('OT_ShowFOV', {
    Text = 'Visible',
    Default = cfg.ShowFOV,
    Callback = function(v) cfg.ShowFOV = v end
})

FovBox:AddSlider('OT_FOVRadius2', {
    Text = 'Radius',
    Default = cfg.FOVRadius,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) cfg.FOVRadius = v end
})

FovBox:AddLabel('Color'):AddColorPicker('OT_FOVColor', {
    Title = 'FOV Color',
    Default = cfg.FOVColor,
    Callback = function(v) cfg.FOVColor = v end
})

HitsoundBox:AddToggle('OT_HitsoundEnabled', {
    Text = 'Enabled',
    Default = cfg.HitsoundEnabled,
    Callback = function(v) cfg.HitsoundEnabled = v end
})

HitsoundBox:AddInput('OT_HitsoundId', {
    Text = 'Sound ID',
    Default = cfg.HitsoundId,
    Numeric = true,
    Finished = true,
    Callback = function(v) cfg.HitsoundId = v end
})

HitsoundBox:AddSlider('OT_HitsoundVolume', {
    Text = 'Volume',
    Default = cfg.HitsoundVolume * 10,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Callback = function(v) cfg.HitsoundVolume = v / 10 end
})

HitsoundBox:AddButton('Test Sound', function()
    local id = cfg.HitsoundId
    if not id or id == "" then id = "6565371338" end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = cfg.HitsoundVolume
    sound.Parent = SoundService
    sound:Play()
    task.delay(sound.TimeLength + 0.5, function() if sound then sound:Destroy() end end)
end)

-- WeaponClient
local WeaponClient
repeat
    local ok = pcall(function()
        WeaponClient = require(LocalPlayer.PlayerScripts.Start.Game.WeaponClient)
    end)
    if not ok then task.wait(0.2) end
until WeaponClient

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = cfg.FOVRadius
    fovCircle.Visible = cfg.ShowFOV
    fovCircle.Color = cfg.FOVColor
end)

-- Team check helper
local function getTeam(model)
    if not model then return nil end
    local plr = Players:GetPlayerFromCharacter(model)
    if plr then
        return plr.Team
    end
    local attr = model:GetAttribute("Team")
    if attr then return attr end
    return nil
end

local function isEnemy(model)
    if not cfg.TeamCheck then return true end
    local myTeam = LocalPlayer.Team
    local theirTeam = getTeam(model)
    if theirTeam == nil then return true end
    return theirTeam ~= myTeam
end

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getPriorityPart(char)
    local headChance = cfg.HeadHitchance
    local bodyChance = cfg.BodyHitchance
    if headChance == 0 and bodyChance == 0 then headChance = 100 end
    local total = headChance + bodyChance
    local roll = math.random(1, math.max(total, 1))
    if roll <= headChance then
        return char:FindFirstChild("Head") or char:FindFirstChild("Hitbox_Head")
    else
        return char:FindFirstChild("Torso") or char:FindFirstChild("Hitbox_Torso")
            or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso")
    end
end

local function getTarget()
    if not cfg.Enabled then return nil end
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHead = myChar:FindFirstChild("Head")
    if not myHead then return nil end

    local origin = myHead.Position
    local bestDist = math.huge
    local bestPart = nil

    for _, model in ipairs(CollectionService:GetTagged("Character")) do
        if model == myChar then continue end
        if not isAlive(model) then continue end
        if model:FindFirstChild("ForceField") then continue end
        if not isEnemy(model) then continue end

        local part = getPriorityPart(model)
        if not part then continue end

        local dist = (part.Position - origin).Magnitude
        if dist > cfg.MaxDistance then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude > cfg.FOVRadius then continue end

        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = {myChar, Camera, model}
        if Workspace:Raycast(origin, (part.Position - origin).Unit * dist, rp) then continue end

        if dist < bestDist then
            bestDist = dist
            bestPart = part
        end
    end

    return bestPart
end

local oldFire = nil
local function hookedFire(...)
    local target = getTarget()
    if not target then
        return oldFire(...)
    end

    local realCFrame = Camera.CFrame
    local myChar = LocalPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")

    if myHead then
        local dir = (target.Position - myHead.Position).Unit
        Camera.CFrame = CFrame.new(realCFrame.Position, realCFrame.Position + dir)
    else
        Camera.CFrame = CFrame.new(realCFrame.Position, target.Position)
    end

    task.defer(function()
        Camera.CFrame = realCFrame
    end)

    local success, err = pcall(oldFire, ...)
    if not success then
        Camera.CFrame = realCFrame
        error(err)
    end
end

if typeof(hookfunction) == "function" then
    oldFire = hookfunction(WeaponClient.fire, hookedFire)
else
    oldFire = WeaponClient.fire
    WeaponClient.fire = hookedFire
end

-- Triggerbot
local lastTrigger = 0
RunService.RenderStepped:Connect(function()
    if not cfg.Enabled or not cfg.Triggerbot then return end
    if tick() - lastTrigger < 0.35 then return end
    local target = getTarget()
    if not target then return end
    lastTrigger = tick()
    pcall(WeaponClient.fire)
end)

-- Hitsound
local function playHitsound()
    if not cfg.HitsoundEnabled then return end
    local id = cfg.HitsoundId
    if not id or id == "" then id = "6565371338" end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = cfg.HitsoundVolume
    sound.Parent = SoundService
    sound:Play()
    task.delay(3, function() if sound then sound:Destroy() end end)
end

-- ============================================================
-- VISUALS
-- ============================================================
local EspBox = Tabs.Visuals:AddLeftGroupbox('ESP')
local HitChamsBox = Tabs.Visuals:AddLeftGroupbox('Hit Chams')
local HitEffectsBox = Tabs.Visuals:AddLeftGroupbox('Hit Effects')
local HitLogsBox = Tabs.Visuals:AddLeftGroupbox('Hit Logs')
local DamageNumbersBox = Tabs.Visuals:AddLeftGroupbox('Damage Numbers')
local Hitmarker3DBox = Tabs.Visuals:AddLeftGroupbox('3D Hitmarker')
local CrosshairBox = Tabs.Visuals:AddRightGroupbox('Crosshair')
local WorldBox = Tabs.Visuals:AddRightGroupbox('World')
local WeatherBox = Tabs.Visuals:AddRightGroupbox('Weather')

-- ESP settings
getgenv().EvolutionESP = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    Tracers = false,
    TeamCheck = false,
    MaxDistance = 3000,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
}
local espCfg = getgenv().EvolutionESP

EspBox:AddToggle('OT_EspEnabled', {
    Text = 'Enabled',
    Default = espCfg.Enabled,
    Callback = function(v) espCfg.Enabled = v end
})

EspBox:AddToggle('OT_EspBoxes', { Text = 'Boxes', Default = espCfg.Boxes, Callback = function(v) espCfg.Boxes = v end })
EspBox:AddToggle('OT_EspNames', { Text = 'Names', Default = espCfg.Names, Callback = function(v) espCfg.Names = v end })
EspBox:AddToggle('OT_EspHealth', { Text = 'Health', Default = espCfg.Health, Callback = function(v) espCfg.Health = v end })
EspBox:AddToggle('OT_EspDistance', { Text = 'Distance', Default = espCfg.Distance, Callback = function(v) espCfg.Distance = v end })
EspBox:AddToggle('OT_EspTracers', { Text = 'Tracers', Default = espCfg.Tracers, Callback = function(v) espCfg.Tracers = v end })
EspBox:AddToggle('OT_EspTeamCheck', { Text = 'Team Check', Default = espCfg.TeamCheck, Callback = function(v) espCfg.TeamCheck = v end })
EspBox:AddSlider('OT_EspMaxDist', { Text = 'Max Distance', Default = espCfg.MaxDistance, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) espCfg.MaxDistance = v end })
EspBox:AddLabel('Box Color'):AddColorPicker('OT_EspBoxColor', { Title = 'Box Color', Default = espCfg.BoxColor, Callback = function(v) espCfg.BoxColor = v end })

-- Drawing ESP implementation for Models
local espDrawings = {}
local function getBoundingBox(model)
    local cf, size = model:GetBoundingBox()
    return cf, size
end

local function worldToScreen(pos)
    local p, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(p.X, p.Y), onScreen, p.Z
end

local function ensureEsp(model)
    if not espDrawings[model] then
        local t = {}
        t.Box = Drawing.new("Square")
        t.Box.Thickness = 1
        t.Box.Filled = false
        t.Box.Visible = false

        t.Name = Drawing.new("Text")
        t.Name.Size = 13
        t.Name.Center = true
        t.Name.Outline = true
        t.Name.Visible = false

        t.Health = Drawing.new("Text")
        t.Health.Size = 12
        t.Health.Center = true
        t.Health.Outline = true
        t.Health.Visible = false

        t.Distance = Drawing.new("Text")
        t.Distance.Size = 12
        t.Distance.Center = true
        t.Distance.Outline = true
        t.Distance.Visible = false

        t.Tracer = Drawing.new("Line")
        t.Tracer.Thickness = 1
        t.Tracer.Visible = false

        espDrawings[model] = t
    end
    return espDrawings[model]
end

local function removeEsp(model)
    local t = espDrawings[model]
    if t then
        for _, d in pairs(t) do
            pcall(function() d:Remove() end)
        end
        espDrawings[model] = nil
    end
end

local function updateEsp()
    if not espCfg.Enabled then
        for model, _ in pairs(espDrawings) do
            removeEsp(model)
        end
        return
    end

    local myChar = LocalPlayer.Character
    local myPos = myChar and (myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
        or myChar:FindFirstChild("Head") and myChar.Head.Position)

    local tagged = CollectionService:GetTagged("Character")
    local seen = {}
    for _, model in ipairs(tagged) do
        seen[model] = true
        if model == myChar then continue end
        if not isAlive(model) then
            removeEsp(model)
            continue
        end
        if espCfg.TeamCheck and not isEnemy(model) then
            removeEsp(model)
            continue
        end

        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("HumanoidRootPart")
            or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        if not root then
            removeEsp(model)
            continue
        end

        local dist = myPos and (root.Position - myPos).Magnitude or 0
        if dist > espCfg.MaxDistance then
            removeEsp(model)
            continue
        end

        local t = ensureEsp(model)
        local cf, size = getBoundingBox(model)
        local corners = {}
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    table.insert(corners, (cf * CFrame.new(size.X/2 * x, size.Y/2 * y, size.Z/2 * z)).Position)
                end
            end
        end

        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyOnScreen = false
        for _, corner in ipairs(corners) do
            local screen, onScreen = worldToScreen(corner)
            if onScreen then anyOnScreen = true end
            minX = math.min(minX, screen.X)
            minY = math.min(minY, screen.Y)
            maxX = math.max(maxX, screen.X)
            maxY = math.max(maxY, screen.Y)
        end

        if espCfg.Boxes and anyOnScreen then
            t.Box.Visible = true
            t.Box.Position = Vector2.new(minX, minY)
            t.Box.Size = Vector2.new(maxX - minX, maxY - minY)
            t.Box.Color = espCfg.BoxColor
        else
            t.Box.Visible = false
        end

        local hum = model:FindFirstChildOfClass("Humanoid")
        local top = Vector2.new((minX + maxX) / 2, minY)

        if espCfg.Names and anyOnScreen then
            local plr = Players:GetPlayerFromCharacter(model)
            local name = plr and plr.DisplayName or model.Name
            t.Name.Visible = true
            t.Name.Position = top - Vector2.new(0, 14)
            t.Name.Text = name
            t.Name.Color = espCfg.NameColor
        else
            t.Name.Visible = false
        end

        if espCfg.Health and hum and anyOnScreen then
            t.Health.Visible = true
            t.Health.Position = top - Vector2.new(0, 28)
            t.Health.Text = tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth))
            t.Health.Color = espCfg.HealthColor
        else
            t.Health.Visible = false
        end

        if espCfg.Distance and myPos and anyOnScreen then
            t.Distance.Visible = true
            t.Distance.Position = Vector2.new((minX + maxX) / 2, maxY + 2)
            t.Distance.Text = tostring(math.floor(dist)) .. "m"
            t.Distance.Color = Color3.fromRGB(255, 255, 255)
        else
            t.Distance.Visible = false
        end

        if espCfg.Tracers and anyOnScreen then
            t.Tracer.Visible = true
            t.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            t.Tracer.To = Vector2.new((minX + maxX) / 2, maxY)
            t.Tracer.Color = espCfg.TracerColor
        else
            t.Tracer.Visible = false
        end
    end

    for model, _ in pairs(espDrawings) do
        if not seen[model] then
            removeEsp(model)
        end
    end
end

RunService.RenderStepped:Connect(updateEsp)

-- Hit Chams
getgenv().EvolutionHitChams = {
    Enabled = false,
    Duration = 2,
    Color = Color3.fromRGB(255, 0, 0),
    Material = Enum.Material.Neon,
}
local hcCfg = getgenv().EvolutionHitChams

HitChamsBox:AddToggle('OT_HitChams', {
    Text = 'Enabled',
    Default = hcCfg.Enabled,
    Callback = function(v) hcCfg.Enabled = v end
})
HitChamsBox:AddSlider('OT_HitChamsDuration', { Text = 'Duration', Default = hcCfg.Duration, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) hcCfg.Duration = v end })
HitChamsBox:AddLabel('Color'):AddColorPicker('OT_HitChamsColor', { Title = 'Color', Default = hcCfg.Color, Callback = function(v) hcCfg.Color = v end })

local function applyHitChams(model)
    if not hcCfg.Enabled then return end
    if not model or not model:IsA("Model") then return end
    local clone = model:Clone()
    if not clone then return end
    clone.Name = "HitChams_" .. clone.Name
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.Material = hcCfg.Material
            part.Color = hcCfg.Color
            part.Transparency = 0.3
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part:Destroy()
        end
    end
    clone.Parent = Workspace
    task.delay(hcCfg.Duration, function()
        pcall(function() clone:Destroy() end)
    end)
end

-- Hit Effects
getgenv().EvolutionHitEffects = {
    Enabled = false,
    Type = "Nova",
}
local heCfg = getgenv().EvolutionHitEffects
HitEffectsBox:AddToggle('OT_HitEffects', { Text = 'Enabled', Default = heCfg.Enabled, Callback = function(v) heCfg.Enabled = v end })
HitEffectsBox:AddDropdown('OT_HitEffectType', { Text = 'Effect', Default = heCfg.Type, Values = {"Nova", "Spark", "Blood"}, Callback = function(v) heCfg.Type = v end })

local function spawnHitEffect(pos)
    if not heCfg.Enabled then return end
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Transparency = 1
    part.CFrame = CFrame.new(pos)
    part.Parent = Workspace
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://8708637750"
    emitter.Lifetime = NumberRange.new(0.2, 0.5)
    emitter.Rate = 0
    emitter.Speed = NumberRange.new(5, 15)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Size = NumberSequence.new(1, 0)
    emitter.Acceleration = Vector3.new(0, -20, 0)
    emitter.Parent = part
    emitter:Emit(10)
    task.delay(1, function() part:Destroy() end)
end

-- Hit Logs
getgenv().EvolutionHitLogs = { Enabled = false }
HitLogsBox:AddToggle('OT_HitLogs', { Text = 'Enabled', Default = getgenv().EvolutionHitLogs.Enabled, Callback = function(v) getgenv().EvolutionHitLogs.Enabled = v end })

local function logHit(targetName, damage)
    if not getgenv().EvolutionHitLogs.Enabled then return end
    print(string.format("[evolution] Hit %s for %s", tostring(targetName), tostring(damage)))
end

-- Damage Numbers
getgenv().EvolutionDamageNumbers = { Enabled = false }
DamageNumbersBox:AddToggle('OT_DamageNumbers', { Text = 'Enabled', Default = getgenv().EvolutionDamageNumbers.Enabled, Callback = function(v) getgenv().EvolutionDamageNumbers.Enabled = v end })

local function showDamageNumber(pos, amount)
    if not getgenv().EvolutionDamageNumbers.Enabled then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 60, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(amount)
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.CFrame = CFrame.new(pos)
    part.Parent = Workspace
    billboard.Adornee = part
    billboard.Parent = part
    TweenService:Create(billboard, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {StudsOffset = Vector3.new(0, 5, 0)}):Play()
    task.delay(0.8, function()
        pcall(function() part:Destroy() end)
    end)
end

-- 3D Hitmarker
getgenv().EvolutionHitmarker = { Enabled = false }
Hitmarker3DBox:AddToggle('OT_3DHitmarker', { Text = 'Enabled', Default = getgenv().EvolutionHitmarker.Enabled, Callback = function(v) getgenv().EvolutionHitmarker.Enabled = v end })

local function show3DHitmarker(pos)
    if not getgenv().EvolutionHitmarker.Enabled then return end
    for i = 1, 4 do
        local line = Instance.new("Part")
        line.Anchored = true
        line.CanCollide = false
        line.Size = Vector3.new(0.05, 0.4, 0.05)
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Material = Enum.Material.Neon
        line.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(i * 90), 0) * CFrame.new(0, 0, 0.4)
        line.Parent = Workspace
        task.delay(0.3, function() line:Destroy() end)
    end
end

-- Crosshair
getgenv().EvolutionCrosshair = {
    Enabled = false,
    Size = 12,
    Thickness = 1.5,
    Color = Color3.fromRGB(255, 255, 255),
    Gap = 4,
}
local crossCfg = getgenv().EvolutionCrosshair
CrosshairBox:AddToggle('OT_Crosshair', { Text = 'Enabled', Default = crossCfg.Enabled, Callback = function(v) crossCfg.Enabled = v end })
CrosshairBox:AddSlider('OT_CrosshairSize', { Text = 'Size', Default = crossCfg.Size, Min = 2, Max = 50, Rounding = 0, Callback = function(v) crossCfg.Size = v end })
CrosshairBox:AddSlider('OT_CrosshairGap', { Text = 'Gap', Default = crossCfg.Gap, Min = 0, Max = 30, Rounding = 0, Callback = function(v) crossCfg.Gap = v end })
CrosshairBox:AddSlider('OT_CrosshairThick', { Text = 'Thickness', Default = crossCfg.Thickness * 10, Min = 1, Max = 50, Rounding = 0, Callback = function(v) crossCfg.Thickness = v / 10 end })
CrosshairBox:AddLabel('Color'):AddColorPicker('OT_CrosshairColor', { Title = 'Color', Default = crossCfg.Color, Callback = function(v) crossCfg.Color = v end })

local crossLines = {}
for i = 1, 4 do
    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = crossCfg.Thickness
    line.Color = crossCfg.Color
    table.insert(crossLines, line)
end
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local gap = crossCfg.Gap
    local size = crossCfg.Size
    local positions = {
        {center - Vector2.new(0, gap), center - Vector2.new(0, gap + size)},
        {center + Vector2.new(0, gap), center + Vector2.new(0, gap + size)},
        {center - Vector2.new(gap, 0), center - Vector2.new(gap + size, 0)},
        {center + Vector2.new(gap, 0), center + Vector2.new(gap + size, 0)},
    }
    for i, line in ipairs(crossLines) do
        line.Visible = crossCfg.Enabled
        line.Thickness = crossCfg.Thickness
        line.Color = crossCfg.Color
        line.From = positions[i][1]
        line.To = positions[i][2]
    end
end)

-- World
getgenv().EvolutionWorld = {
    Enabled = false,
    Ambient = Color3.fromRGB(127, 127, 127),
    Brightness = 1,
    FogStart = 0,
    FogEnd = 100000,
    FogColor = Color3.fromRGB(192, 192, 192),
    TimeOfDay = "14:00:00",
    OverrideTime = false,
}
local worldCfg = getgenv().EvolutionWorld
local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor
local originalTime = Lighting.TimeOfDay

WorldBox:AddToggle('OT_WorldEnabled', {
    Text = 'Enabled',
    Default = worldCfg.Enabled,
    Callback = function(v)
        worldCfg.Enabled = v
        if not v then
            Lighting.Ambient = originalAmbient
            Lighting.Brightness = originalBrightness
            Lighting.FogStart = originalFogStart
            Lighting.FogEnd = originalFogEnd
            Lighting.FogColor = originalFogColor
            Lighting.TimeOfDay = originalTime
        end
    end
})
WorldBox:AddLabel('Ambient'):AddColorPicker('OT_WorldAmbient', { Title = 'Ambient', Default = worldCfg.Ambient, Callback = function(v) worldCfg.Ambient = v end })
WorldBox:AddSlider('OT_WorldBrightness', { Text = 'Brightness', Default = worldCfg.Brightness * 100, Min = 0, Max = 500, Rounding = 0, Callback = function(v) worldCfg.Brightness = v / 100 end })
WorldBox:AddSlider('OT_FogStart', { Text = 'Fog Start', Default = worldCfg.FogStart, Min = 0, Max = 10000, Rounding = 0, Callback = function(v) worldCfg.FogStart = v end })
WorldBox:AddSlider('OT_FogEnd', { Text = 'Fog End', Default = worldCfg.FogEnd, Min = 100, Max = 100000, Rounding = 0, Callback = function(v) worldCfg.FogEnd = v end })
WorldBox:AddLabel('Fog Color'):AddColorPicker('OT_FogColor', { Title = 'Fog Color', Default = worldCfg.FogColor, Callback = function(v) worldCfg.FogColor = v end })
WorldBox:AddToggle('OT_OverrideTime', { Text = 'Override Time', Default = worldCfg.OverrideTime, Callback = function(v) worldCfg.OverrideTime = v end })
WorldBox:AddInput('OT_TimeOfDay', { Text = 'Time of Day', Default = worldCfg.TimeOfDay, Finished = true, Callback = function(v) worldCfg.TimeOfDay = v end })

RunService.RenderStepped:Connect(function()
    if worldCfg.Enabled then
        Lighting.Ambient = worldCfg.Ambient
        Lighting.Brightness = worldCfg.Brightness
        Lighting.FogStart = worldCfg.FogStart
        Lighting.FogEnd = worldCfg.FogEnd
        Lighting.FogColor = worldCfg.FogColor
        if worldCfg.OverrideTime then
            Lighting.TimeOfDay = worldCfg.TimeOfDay
        end
    end
end)

-- Weather
getgenv().EvolutionWeather = { Enabled = false, Type = "Rain", Density = 100 }
local weatherCfg = getgenv().EvolutionWeather
local weatherFolder = nil

WeatherBox:AddToggle('OT_Weather', { Text = 'Enabled', Default = weatherCfg.Enabled, Callback = function(v) weatherCfg.Enabled = v end })
WeatherBox:AddDropdown('OT_WeatherType', { Text = 'Type', Default = weatherCfg.Type, Values = {"Rain", "Snow"}, Callback = function(v) weatherCfg.Type = v end })
WeatherBox:AddSlider('OT_WeatherDensity', { Text = 'Density', Default = weatherCfg.Density, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) weatherCfg.Density = v end })

local function clearWeather()
    if weatherFolder then
        pcall(function() weatherFolder:Destroy() end)
        weatherFolder = nil
    end
end

local function makeWeather()
    clearWeather()
    if not weatherCfg.Enabled then return end
    weatherFolder = Instance.new("Folder")
    weatherFolder.Name = "EvolutionWeather"
    weatherFolder.Parent = Workspace
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local center = root and root.Position or Camera.CFrame.Position
    for i = 1, weatherCfg.Density do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.1, 0.6, 0.1)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.3
        part.Color = weatherCfg.Type == "Snow" and Color3.fromRGB(240, 250, 255) or Color3.fromRGB(120, 140, 180)
        part.Material = Enum.Material.Glass
        part.CFrame = CFrame.new(center + Vector3.new(math.random(-100, 100), math.random(20, 80), math.random(-100, 100)))
        part.Parent = weatherFolder
    end
end

RunService.RenderStepped:Connect(function()
    if not weatherCfg.Enabled or not weatherFolder then
        clearWeather()
        return
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local center = root and root.Position or Camera.CFrame.Position
    local offset = 0
    if weatherCfg.Type == "Rain" then
        offset = -0.8
    elseif weatherCfg.Type == "Snow" then
        offset = -0.15
    end
    for _, part in ipairs(weatherFolder:GetChildren()) do
        part.CFrame = part.CFrame + Vector3.new(0, offset, 0)
        if part.Position.Y < center.Y - 10 then
            part.CFrame = CFrame.new(center.X + math.random(-100, 100), center.Y + math.random(20, 80), center.Z + math.random(-100, 100))
        end
    end
end)

task.spawn(function()
    while true do
        if weatherCfg.Enabled and (not weatherFolder or #weatherFolder:GetChildren() == 0) then
            makeWeather()
        elseif not weatherCfg.Enabled and weatherFolder then
            clearWeather()
        end
        task.wait(2)
    end
end)

-- ============================================================
-- HIT RESULTS (chams / effects / logs / numbers / marker / sound)
-- ============================================================
local packets = ReplicatedStorage:FindFirstChild("MainGamePackets")
if packets and typeof(packets) == "Instance" then
    local hitResult = packets:FindFirstChild("hitResult")
    if hitResult and hitResult:IsA("RemoteEvent") then
        hitResult.OnClientEvent:Connect(function(data)
            local target = data and (data.Target or data.target or data.Character or data.character)
            local damage = data and (data.Damage or data.damage or 0)
            local killed = data and (data.Killed or data.killed or data.Dead or data.dead)
            if target and target:IsA("Model") then
                applyHitChams(target)
                if killed or damage then
                    spawnHitEffect(target:GetPivot().Position)
                    show3DHitmarker(target:GetPivot().Position)
                end
            end
            if damage and damage > 0 then
                local pos = target and target:GetPivot().Position or Camera.CFrame.Position + Camera.CFrame.LookVector * 10
                showDamageNumber(pos, damage)
                logHit(target and target.Name or "?", damage)
            end
            if damage and damage > 0 then
                playHitsound()
            end
        end)
    end
end

-- ============================================================
-- MISC
-- ============================================================
local MovementBox = Tabs.Misc:AddLeftGroupbox('Movement')
getgenv().EvolutionMisc = { Fly = false, FlySpeed = 50, NoClip = false }
local miscCfg = getgenv().EvolutionMisc

MovementBox:AddToggle('OT_Fly', { Text = 'Fly', Default = miscCfg.Fly, Callback = function(v) miscCfg.Fly = v end })
MovementBox:AddSlider('OT_FlySpeed', { Text = 'Fly Speed', Default = miscCfg.FlySpeed, Min = 10, Max = 300, Rounding = 0, Callback = function(v) miscCfg.FlySpeed = v end })
MovementBox:AddToggle('OT_NoClip', { Text = 'NoClip', Default = miscCfg.NoClip, Callback = function(v) miscCfg.NoClip = v end })

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if miscCfg.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    if miscCfg.Fly then
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = dir.Unit * miscCfg.FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- ============================================================
-- UI SETTINGS
-- ============================================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor', 'ThemeManager' })
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

print('[evolution] One Tap module loaded')
