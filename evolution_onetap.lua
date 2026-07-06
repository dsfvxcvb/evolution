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
    Hitchance = 100,
    MaxDistance = 1500,

    ShowFOV = true,
    FOVRadius = 150,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVType = 'Circle',
    FOVTransparency = 0.65,
    FOVOutline = true,
    FOVOutlineColor = Color3.fromRGB(0, 0, 0),
    FOVOutlineThickness = 1,
    FOVGradient = true,
    FOVGradientTop = Color3.fromRGB(211, 211, 211),
    FOVGradientBottom = Color3.fromRGB(0, 0, 0),
    FOVGradientSpin = true,
    FOVGradientSpeed = 120,
    FOVOutlineGradient = true,
    FOVOutlineGradientTop = Color3.fromRGB(211, 211, 211),
    FOVOutlineGradientBottom = Color3.fromRGB(0, 0, 0),
    FOVOutlineGradientSpin = true,
    FOVOutlineGradientSpeed = 120,

    Fly = false,
    FlySpeed = 50,

    EspEnabled = false,
    EspBoxes = true,
    EspNames = true,
    EspHealth = true,
    EspDistance = true,
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

SilentAimBox:AddSlider('OT_Hitchance', {
    Text = 'Hitchance',
    Default = cfg.Hitchance,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(v) cfg.Hitchance = v end
})

SilentAimBox:AddSlider('OT_MaxDistance', {
    Text = 'Max Distance',
    Default = cfg.MaxDistance,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Callback = function(v) cfg.MaxDistance = v end
})

-- ============================================================
-- FOV CIRCLE UI
-- ============================================================
FovBox:AddToggle('OT_ShowFOV', {
    Text = 'Visible',
    Default = cfg.ShowFOV,
    Callback = function(v) cfg.ShowFOV = v end
})

FovBox:AddDropdown('OT_FOVType', {
    Text = 'Type',
    Default = cfg.FOVType,
    Values = {'Circle', 'Square', 'Dotted', 'Lined'},
    Callback = function(v) cfg.FOVType = v end
})

FovBox:AddSlider('OT_FOVRadius', {
    Text = 'Radius',
    Default = cfg.FOVRadius,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) cfg.FOVRadius = v end
})

FovBox:AddSlider('OT_FOVTransparency', {
    Text = 'Transparency',
    Default = cfg.FOVTransparency * 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v) cfg.FOVTransparency = v / 100 end
})

FovBox:AddLabel('Fill Color'):AddColorPicker('OT_FOVColor', {
    Title = 'Fill Color',
    Default = cfg.FOVColor,
    Callback = function(v) cfg.FOVColor = v end
})

FovBox:AddToggle('OT_FOVOutline', {
    Text = 'Outline',
    Default = cfg.FOVOutline,
    Callback = function(v) cfg.FOVOutline = v end
})

FovBox:AddSlider('OT_FOVOutlineThickness', {
    Text = 'Outline Thickness',
    Default = cfg.FOVOutlineThickness,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(v) cfg.FOVOutlineThickness = v end
})

FovBox:AddLabel('Outline Color'):AddColorPicker('OT_FOVOutlineColor', {
    Title = 'Outline Color',
    Default = cfg.FOVOutlineColor,
    Callback = function(v) cfg.FOVOutlineColor = v end
})

FovBox:AddToggle('OT_FOVGradient', {
    Text = 'Gradient',
    Default = cfg.FOVGradient,
    Callback = function(v) cfg.FOVGradient = v end
})

FovBox:AddLabel('Gradient Top'):AddColorPicker('OT_FOVGradientTop', {
    Title = 'Gradient Top',
    Default = cfg.FOVGradientTop,
    Callback = function(v) cfg.FOVGradientTop = v end
})

FovBox:AddLabel('Gradient Bottom'):AddColorPicker('OT_FOVGradientBottom', {
    Title = 'Gradient Bottom',
    Default = cfg.FOVGradientBottom,
    Callback = function(v) cfg.FOVGradientBottom = v end
})

FovBox:AddToggle('OT_FOVGradientSpin', {
    Text = 'Gradient Spin',
    Default = cfg.FOVGradientSpin,
    Callback = function(v) cfg.FOVGradientSpin = v end
})

FovBox:AddSlider('OT_FOVGradientSpeed', {
    Text = 'Gradient Spin Speed',
    Default = cfg.FOVGradientSpeed,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v) cfg.FOVGradientSpeed = v end
})

FovBox:AddToggle('OT_FOVOutlineGradient', {
    Text = 'Outline Gradient',
    Default = cfg.FOVOutlineGradient,
    Callback = function(v) cfg.FOVOutlineGradient = v end
})

FovBox:AddLabel('Outline Gradient Top'):AddColorPicker('OT_FOVOutlineGradientTop', {
    Title = 'Outline Gradient Top',
    Default = cfg.FOVOutlineGradientTop,
    Callback = function(v) cfg.FOVOutlineGradientTop = v end
})

FovBox:AddLabel('Outline Gradient Bottom'):AddColorPicker('OT_FOVOutlineGradientBottom', {
    Title = 'Outline Gradient Bottom',
    Default = cfg.FOVOutlineGradientBottom,
    Callback = function(v) cfg.FOVOutlineGradientBottom = v end
})

FovBox:AddToggle('OT_FOVOutlineGradientSpin', {
    Text = 'Outline Gradient Spin',
    Default = cfg.FOVOutlineGradientSpin,
    Callback = function(v) cfg.FOVOutlineGradientSpin = v end
})

FovBox:AddSlider('OT_FOVOutlineGradientSpeed', {
    Text = 'Outline Spin Speed',
    Default = cfg.FOVOutlineGradientSpeed,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v) cfg.FOVOutlineGradientSpeed = v end
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
-- FOV CIRCLE LOGIC (GUI based with gradient + spin)
-- ============================================================
local fovParent = Instance.new("ScreenGui")
fovParent.Name = "EvolutionFOV"
fovParent.Parent = cloneref(game:GetService("CoreGui"))
fovParent.ResetOnSpawn = false
fovParent.DisplayOrder = 9999

local fovFrame = nil
local rotatingGradients = {}

local function gradientColor(top, bottom)
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, top),
        ColorSequenceKeypoint.new(1, bottom)
    }
end

local function addRotatingGradient(gradient, speed)
    if gradient then
        table.insert(rotatingGradients, {gradient = gradient, speed = speed})
    end
end

local function clearRotatingGradients()
    rotatingGradients = {}
end

local function destroyFov()
    clearRotatingGradients()
    if fovFrame then
        pcall(function() fovFrame:Destroy() end)
        fovFrame = nil
    end
end

local function buildFov()
    destroyFov()
    if not cfg.ShowFOV then return end

    local radius = cfg.FOVRadius
    local fovType = cfg.FOVType

    fovFrame = Instance.new("Frame")
    fovFrame.Name = "FOV"
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovFrame.BackgroundTransparency = 1
    fovFrame.Visible = true
    fovFrame.Parent = fovParent

    if fovType == "Dotted" or fovType == "Lined" then
        for i = 1, 36 do
            local segment = Instance.new("Frame")
            segment.Size = UDim2.new(0, 5, 0, 5)
            segment.BackgroundColor3 = cfg.FOVColor
            segment.BackgroundTransparency = cfg.FOVTransparency
            segment.AnchorPoint = Vector2.new(0.5, 0.5)

            local angle = math.rad((i - 1) * (360 / 36))
            local x = math.cos(angle) * radius
            local y = math.sin(angle) * radius
            segment.Position = UDim2.new(0.5, x, 0.5, y)
            segment.Parent = fovFrame

            if fovType == "Dotted" then
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = segment
            elseif fovType == "Lined" then
                segment.Size = UDim2.new(0, 10, 0, 2)
                segment.Rotation = math.deg(angle)
            end

            local segOutline = nil
            if cfg.FOVOutline then
                segOutline = Instance.new("UIStroke")
                segOutline.Color = cfg.FOVOutlineColor
                segOutline.Transparency = 0
                segOutline.Thickness = cfg.FOVOutlineThickness
                segOutline.Parent = segment
            end

            if cfg.FOVOutlineGradient and segOutline then
                local grad = Instance.new("UIGradient")
                grad.Color = gradientColor(cfg.FOVOutlineGradientTop, cfg.FOVOutlineGradientBottom)
                grad.Rotation = 0
                grad.Parent = segOutline
                if cfg.FOVOutlineGradientSpin then
                    addRotatingGradient(grad, cfg.FOVOutlineGradientSpeed)
                end
            end

            if cfg.FOVGradient then
                local grad = Instance.new("UIGradient")
                grad.Color = gradientColor(cfg.FOVGradientTop, cfg.FOVGradientBottom)
                grad.Rotation = 0
                grad.Parent = segment
                if cfg.FOVGradientSpin then
                    addRotatingGradient(grad, cfg.FOVGradientSpeed)
                end
            end
        end
    else
        fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
        fovFrame.BackgroundColor3 = cfg.FOVColor
        fovFrame.BackgroundTransparency = cfg.FOVTransparency

        if fovType == "Circle" then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0.5, 0)
            corner.Parent = fovFrame
        end

        local outline = nil
        if cfg.FOVOutline then
            outline = Instance.new("UIStroke")
            outline.Color = cfg.FOVOutlineColor
            outline.Transparency = 0
            outline.Thickness = cfg.FOVOutlineThickness
            outline.Parent = fovFrame
        end

        if cfg.FOVOutlineGradient and outline then
            local grad = Instance.new("UIGradient")
            grad.Color = gradientColor(cfg.FOVOutlineGradientTop, cfg.FOVOutlineGradientBottom)
            grad.Rotation = 0
            grad.Parent = outline
            if cfg.FOVOutlineGradientSpin then
                addRotatingGradient(grad, cfg.FOVOutlineGradientSpeed)
            end
        end

        if cfg.FOVGradient then
            local grad = Instance.new("UIGradient")
            grad.Color = gradientColor(cfg.FOVGradientTop, cfg.FOVGradientBottom)
            grad.Rotation = 0
            grad.Parent = fovFrame
            if cfg.FOVGradientSpin then
                addRotatingGradient(grad, cfg.FOVGradientSpeed)
            end
        end
    end
end

buildFov()

local lastFovRebuild = tick()
RunService.RenderStepped:Connect(function()
    for _, data in ipairs(rotatingGradients) do
        local grad = data.gradient
        if grad then
            grad.Rotation = (tick() * data.speed) % 360
        end
    end

    -- rebuild on radius/type change (debounced a bit)
    if tick() - lastFovRebuild > 0.1 then
        lastFovRebuild = tick()
        if cfg.ShowFOV and (not fovFrame or fovFrame.Parent == nil) then
            buildFov()
        elseif not cfg.ShowFOV and fovFrame then
            destroyFov()
        end
    end
end)

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

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getPriorityPart(char)
    local roll = math.random(1, 100)
    if roll <= cfg.Hitchance then
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
