-- ============================================================
-- evolution | [FPS] One Tap
-- Camera-snap silent aim + ESP + world. No bullet manipulation.
-- ============================================================

local repo = 'https://raw.githubusercontent.com/dsfvxcvb/evolution/main/'

if typeof(getgenv().Library) == "table" and typeof(getgenv().Library.Unload) == "function" then
    pcall(function() getgenv().Library:Unload() end)
end

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
local Lighting = cloneref(game:GetService("Lighting"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = 'evolution',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- ============================================================
-- MAIN TAB
-- ============================================================
local SilentAimBox = Tabs.Main:AddLeftGroupbox('Silent Aim')
local FovBox = Tabs.Main:AddLeftGroupbox('FOV Circle')
local MovementBox = Tabs.Main:AddLeftGroupbox('Movement')
local EspBox = Tabs.Main:AddRightGroupbox('ESP')
local WorldBox = Tabs.Main:AddRightGroupbox('World')

-- ============================================================
-- CONFIG
-- ============================================================
getgenv().EvolutionOneTap = {
    SilentAimEnabled = false,
    AutoFire = false,
    TeamCheck = false,
    MaxDistance = 1500,
    HeadHitchance = 100,
    BodyHitchance = 0,

    ShowFOV = true,
    FOVRadius = 300,
    FOVColor = Color3.new(1, 1, 1),

    Fly = false,
    FlySpeed = 50,

    EspEnabled = false,
    EspBoxes = true,
    EspNames = true,
    EspHealth = true,
    EspDistance = true,
    EspTeamCheck = false,
    EspMaxDistance = 3000,
    EspBoxColor = Color3.fromRGB(255, 255, 255),

    WorldEnabled = false,
    WorldAmbient = Color3.fromRGB(127, 127, 127),
    WorldBrightness = 1,
    WorldFogStart = 0,
    WorldFogEnd = 100000,
    WorldFogColor = Color3.fromRGB(192, 192, 192),
    WorldOverrideTime = false,
    WorldTimeOfDay = "14:00:00",
}
local cfg = getgenv().EvolutionOneTap

-- ============================================================
-- SILENT AIM UI
-- ============================================================
SilentAimBox:AddToggle('OT_SilentAim', {
    Text = 'Enabled',
    Default = cfg.SilentAimEnabled,
    Callback = function(v) cfg.SilentAimEnabled = v end
}):AddKeyPicker('OT_SilentAimKey', { Default = 'None', Mode = 'Toggle', Text = 'Silent Aim' })

SilentAimBox:AddToggle('OT_AutoFire', {
    Text = 'Auto Fire',
    Default = cfg.AutoFire,
    Callback = function(v) cfg.AutoFire = v end
})

SilentAimBox:AddToggle('OT_TeamCheck', {
    Text = 'Team Check',
    Default = cfg.TeamCheck,
    Callback = function(v) cfg.TeamCheck = v end
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

-- ============================================================
-- FOV CIRCLE UI
-- ============================================================
FovBox:AddToggle('OT_ShowFOV', {
    Text = 'Visible',
    Default = cfg.ShowFOV,
    Callback = function(v) cfg.ShowFOV = v end
})

FovBox:AddSlider('OT_FOVRadius', {
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

-- ============================================================
-- MOVEMENT UI
-- ============================================================
MovementBox:AddToggle('OT_Fly', {
    Text = 'Fly',
    Default = cfg.Fly,
    Callback = function(v) cfg.Fly = v end
})

MovementBox:AddSlider('OT_FlySpeed', {
    Text = 'Fly Speed',
    Default = cfg.FlySpeed,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(v) cfg.FlySpeed = v end
})

-- ============================================================
-- ESP UI
-- ============================================================
EspBox:AddToggle('OT_EspEnabled', {
    Text = 'Enabled',
    Default = cfg.EspEnabled,
    Callback = function(v) cfg.EspEnabled = v end
})

EspBox:AddToggle('OT_EspBoxes', {
    Text = 'Boxes',
    Default = cfg.EspBoxes,
    Callback = function(v) cfg.EspBoxes = v end
})

EspBox:AddToggle('OT_EspNames', {
    Text = 'Names',
    Default = cfg.EspNames,
    Callback = function(v) cfg.EspNames = v end
})

EspBox:AddToggle('OT_EspHealth', {
    Text = 'Health',
    Default = cfg.EspHealth,
    Callback = function(v) cfg.EspHealth = v end
})

EspBox:AddToggle('OT_EspDistance', {
    Text = 'Distance',
    Default = cfg.EspDistance,
    Callback = function(v) cfg.EspDistance = v end
})

EspBox:AddToggle('OT_EspTeamCheck', {
    Text = 'Team Check',
    Default = cfg.EspTeamCheck,
    Callback = function(v) cfg.EspTeamCheck = v end
})

EspBox:AddSlider('OT_EspMaxDist', {
    Text = 'Max Distance',
    Default = cfg.EspMaxDistance,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Callback = function(v) cfg.EspMaxDistance = v end
})

EspBox:AddLabel('Box Color'):AddColorPicker('OT_EspBoxColor', {
    Title = 'Box Color',
    Default = cfg.EspBoxColor,
    Callback = function(v) cfg.EspBoxColor = v end
})

-- ============================================================
-- WORLD UI
-- ============================================================
local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor
local originalTime = Lighting.TimeOfDay

WorldBox:AddToggle('OT_WorldEnabled', {
    Text = 'Enabled',
    Default = cfg.WorldEnabled,
    Callback = function(v)
        cfg.WorldEnabled = v
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

WorldBox:AddLabel('Ambient'):AddColorPicker('OT_WorldAmbient', {
    Title = 'Ambient',
    Default = cfg.WorldAmbient,
    Callback = function(v) cfg.WorldAmbient = v end
})

WorldBox:AddSlider('OT_WorldBrightness', {
    Text = 'Brightness',
    Default = cfg.WorldBrightness * 100,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v) cfg.WorldBrightness = v / 100 end
})

WorldBox:AddSlider('OT_FogStart', {
    Text = 'Fog Start',
    Default = cfg.WorldFogStart,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(v) cfg.WorldFogStart = v end
})

WorldBox:AddSlider('OT_FogEnd', {
    Text = 'Fog End',
    Default = cfg.WorldFogEnd,
    Min = 100,
    Max = 100000,
    Rounding = 0,
    Callback = function(v) cfg.WorldFogEnd = v end
})

WorldBox:AddLabel('Fog Color'):AddColorPicker('OT_WorldFogColor', {
    Title = 'Fog Color',
    Default = cfg.WorldFogColor,
    Callback = function(v) cfg.WorldFogColor = v end
})

WorldBox:AddToggle('OT_OverrideTime', {
    Text = 'Override Time',
    Default = cfg.WorldOverrideTime,
    Callback = function(v) cfg.WorldOverrideTime = v end
})

WorldBox:AddInput('OT_TimeOfDay', {
    Text = 'Time of Day',
    Default = cfg.WorldTimeOfDay,
    Finished = true,
    Callback = function(v) cfg.WorldTimeOfDay = v end
})

-- ============================================================
-- SILENT AIM LOGIC
-- ============================================================
local WeaponClient
repeat
    local ok = pcall(function()
        WeaponClient = require(LocalPlayer.PlayerScripts.Start.Game.WeaponClient)
    end)
    if not ok then task.wait(0.2) end
until WeaponClient

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

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTeam(model)
    local plr = Players:GetPlayerFromCharacter(model)
    if plr then return plr.Team end
    return model:GetAttribute("Team")
end

local function isEnemy(model)
    if not cfg.TeamCheck then return true end
    local theirTeam = getTeam(model)
    if theirTeam == nil then return true end
    return theirTeam ~= LocalPlayer.Team
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
    if not cfg.SilentAimEnabled then return nil end

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

-- Auto Fire
local lastTrigger = 0
RunService.RenderStepped:Connect(function()
    if not cfg.SilentAimEnabled or not cfg.AutoFire then return end
    if tick() - lastTrigger < 0.35 then return end

    local target = getTarget()
    if not target then return end

    lastTrigger = tick()
    pcall(WeaponClient.fire)
end)

-- ============================================================
-- ESP LOGIC (static 2D boxes)
-- ============================================================
local espDrawings = {}

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

RunService.RenderStepped:Connect(function()
    if not cfg.EspEnabled then
        for model, _ in pairs(espDrawings) do
            removeEsp(model)
        end
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
    local myPos = myRoot and myRoot.Position

    local tagged = CollectionService:GetTagged("Character")
    local seen = {}

    for _, model in ipairs(tagged) do
        seen[model] = true
        if model == myChar then continue end
        if not isAlive(model) then
            removeEsp(model)
            continue
        end
        if cfg.EspTeamCheck and not isEnemy(model) then
            removeEsp(model)
            continue
        end

        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
        if not root then
            removeEsp(model)
            continue
        end

        local dist = myPos and (root.Position - myPos).Magnitude or 0
        if dist > cfg.EspMaxDistance then
            removeEsp(model)
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            removeEsp(model)
            continue
        end

        local t = ensureEsp(model)
        local center = Vector2.new(screenPos.X, screenPos.Y)

        -- Static box size based on distance
        local baseHeight = math.clamp(2500 / math.max(dist, 1), 20, 200)
        local boxSize = Vector2.new(baseHeight * 0.55, baseHeight)
        local topLeft = center - boxSize / 2

        if cfg.EspBoxes then
            t.Box.Visible = true
            t.Box.Position = topLeft
            t.Box.Size = boxSize
            t.Box.Color = cfg.EspBoxColor
        else
            t.Box.Visible = false
        end

        if cfg.EspNames then
            local plr = Players:GetPlayerFromCharacter(model)
            t.Name.Visible = true
            t.Name.Position = topLeft - Vector2.new(0, 14)
            t.Name.Text = plr and plr.DisplayName or model.Name
            t.Name.Color = cfg.EspBoxColor
        else
            t.Name.Visible = false
        end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if cfg.EspHealth and hum then
            t.Health.Visible = true
            t.Health.Position = topLeft - Vector2.new(0, 28)
            t.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            t.Health.Color = Color3.fromRGB(0, 255, 0)
        else
            t.Health.Visible = false
        end

        if cfg.EspDistance and myPos then
            t.Distance.Visible = true
            t.Distance.Position = Vector2.new(center.X, topLeft.Y + boxSize.Y + 2)
            t.Distance.Text = math.floor(dist) .. "m"
            t.Distance.Color = Color3.fromRGB(255, 255, 255)
        else
            t.Distance.Visible = false
        end
    end

    for model, _ in pairs(espDrawings) do
        if not seen[model] then
            removeEsp(model)
        end
    end
end)

-- ============================================================
-- MOVEMENT LOGIC (fly only)
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if cfg.Fly then
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = dir.Unit * cfg.FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- ============================================================
-- WORLD LOGIC
-- ============================================================
RunService.RenderStepped:Connect(function()
    if cfg.WorldEnabled then
        Lighting.Ambient = cfg.WorldAmbient
        Lighting.Brightness = cfg.WorldBrightness
        Lighting.FogStart = cfg.WorldFogStart
        Lighting.FogEnd = cfg.WorldFogEnd
        Lighting.FogColor = cfg.WorldFogColor
        if cfg.WorldOverrideTime then
            Lighting.TimeOfDay = cfg.WorldTimeOfDay
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
