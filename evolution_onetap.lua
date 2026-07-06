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
local AutoKillBox = Tabs.Main:AddRightGroupbox('AutoKill')
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

    AutoKillEnabled = false,
    AutoKillMethod = 'Sniper',

    ShowFOV = true,
    FOVRadius = 150,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVFillTransparency = 0.65,
    FOVOutline = true,
    FOVOutlineColor = Color3.fromRGB(0, 0, 0),
    FOVOutlineThickness = 1,
    FOVGradient = true,
    FOVGradientTop = Color3.fromRGB(211, 211, 211),
    FOVGradientBottom = Color3.fromRGB(0, 0, 0),
    FOVGradientSpin = true,
    FOVGradientSpeed = 120,

    Fly = false,
    FlySpeed = 50,

    EspEnabled = false,
    EspBoxes = true,
    EspNames = true,
    EspHealth = true,
    EspDistance = true,
    EspMaxDistance = 3000,
    EspBoxColor = Color3.fromRGB(255, 255, 255),
    EspNameColor = Color3.fromRGB(255, 255, 255),
    EspHealthColor = Color3.fromRGB(0, 255, 0),
    EspDistanceColor = Color3.fromRGB(255, 255, 255),

    WorldEnabled = false,
    WorldAmbient = Color3.fromRGB(127, 127, 127),
    WorldBrightness = 1,
    WorldFogStart = 0,
    WorldFogEnd = 100000,
    WorldFogColor = Color3.fromRGB(192, 192, 192),
    WorldOverrideTime = false,
    WorldTime = 14,

    MenuGlow = true,
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
-- AUTOKILL UI
-- ============================================================
AutoKillBox:AddToggle('OT_AutoKillUse', {
    Text = 'Use',
    Default = cfg.AutoKillEnabled,
    Callback = function(v) cfg.AutoKillEnabled = v end
})

AutoKillBox:AddDropdown('OT_AutoKillMethod', {
    Text = 'Method',
    Default = cfg.AutoKillMethod,
    Values = {'Sniper', 'Pistol'},
    Callback = function(v) cfg.AutoKillMethod = v end
})

-- ============================================================
-- FOV CIRCLE UI
-- ============================================================
local ShowFOVToggle = FovBox:AddToggle('OT_ShowFOV', {
    Text = 'Visible',
    Default = cfg.ShowFOV,
    Callback = function(v) cfg.ShowFOV = v end
})

ShowFOVToggle:AddColorPicker('OT_FOVColor', {
    Title = 'Fill Color',
    Default = cfg.FOVColor,
    Callback = function(v) cfg.FOVColor = v end
})

FovBox:AddSlider('OT_FOVRadius', {
    Text = 'Radius',
    Default = cfg.FOVRadius,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) cfg.FOVRadius = v end
})

FovBox:AddSlider('OT_FOVFillTransparency', {
    Text = 'Fill Transparency',
    Default = cfg.FOVFillTransparency * 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v) cfg.FOVFillTransparency = v / 100 end
})

local OutlineToggle = FovBox:AddToggle('OT_FOVOutline', {
    Text = 'Outline',
    Default = cfg.FOVOutline,
    Callback = function(v) cfg.FOVOutline = v end
})

OutlineToggle:AddColorPicker('OT_FOVOutlineColor', {
    Title = 'Outline Color',
    Default = cfg.FOVOutlineColor,
    Callback = function(v) cfg.FOVOutlineColor = v end
})

FovBox:AddSlider('OT_FOVOutlineThickness', {
    Text = 'Outline Thickness',
    Default = cfg.FOVOutlineThickness,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(v) cfg.FOVOutlineThickness = v end
})

local GradientToggle = FovBox:AddToggle('OT_FOVGradient', {
    Text = 'Gradient',
    Default = cfg.FOVGradient,
    Callback = function(v) cfg.FOVGradient = v end
})

GradientToggle:AddColorPicker('OT_FOVGradientTop', {
    Title = 'Gradient Top',
    Default = cfg.FOVGradientTop,
    Callback = function(v) cfg.FOVGradientTop = v end
})

GradientToggle:AddColorPicker('OT_FOVGradientBottom', {
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

local EspBoxesToggle = EspBox:AddToggle('OT_EspBoxes', {
    Text = 'Boxes',
    Default = cfg.EspBoxes,
    Callback = function(v) cfg.EspBoxes = v end
})

EspBoxesToggle:AddColorPicker('OT_EspBoxColor', {
    Title = 'Box Color',
    Default = cfg.EspBoxColor,
    Callback = function(v) cfg.EspBoxColor = v end
})

local EspNamesToggle = EspBox:AddToggle('OT_EspNames', {
    Text = 'Names',
    Default = cfg.EspNames,
    Callback = function(v) cfg.EspNames = v end
})

EspNamesToggle:AddColorPicker('OT_EspNameColor', {
    Title = 'Name Color',
    Default = cfg.EspNameColor,
    Callback = function(v) cfg.EspNameColor = v end
})

local EspHealthToggle = EspBox:AddToggle('OT_EspHealth', {
    Text = 'Health',
    Default = cfg.EspHealth,
    Callback = function(v) cfg.EspHealth = v end
})

EspHealthToggle:AddColorPicker('OT_EspHealthColor', {
    Title = 'Health Color',
    Default = cfg.EspHealthColor,
    Callback = function(v) cfg.EspHealthColor = v end
})

local EspDistanceToggle = EspBox:AddToggle('OT_EspDistance', {
    Text = 'Distance',
    Default = cfg.EspDistance,
    Callback = function(v) cfg.EspDistance = v end
})

EspDistanceToggle:AddColorPicker('OT_EspDistanceColor', {
    Title = 'Distance Color',
    Default = cfg.EspDistanceColor,
    Callback = function(v) cfg.EspDistanceColor = v end
})

EspBox:AddSlider('OT_EspMaxDist', {
    Text = 'Max Distance',
    Default = cfg.EspMaxDistance,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Callback = function(v) cfg.EspMaxDistance = v end
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

WorldBox:AddSlider('OT_WorldTime', {
    Text = 'Time of Day',
    Default = cfg.WorldTime * 100,
    Min = 0,
    Max = 2400,
    Rounding = 0,
    Callback = function(v) cfg.WorldTime = v / 100 end
})

-- ============================================================
-- FOV CIRCLE LOGIC (GUI based with gradient + spin)
-- ============================================================
local fovParent = Instance.new("ScreenGui")
fovParent.Name = "EvolutionFOV"
fovParent.Parent = cloneref(game:GetService("CoreGui"))
fovParent.ResetOnSpawn = false
fovParent.DisplayOrder = 9999
fovParent.IgnoreGuiInset = true

local fovFrame = nil
local fovOutline = nil
local fovGradient = nil
local fovCorner = nil

local function gradientColor(top, bottom)
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, top),
        ColorSequenceKeypoint.new(1, bottom)
    }
end

local function createFov()
    if fovFrame then return end

    fovFrame = Instance.new("Frame")
    fovFrame.Name = "FOV"
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.BorderSizePixel = 0
    fovFrame.ZIndex = 1
    fovFrame.Parent = fovParent

    fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(0.5, 0)
    fovCorner.Parent = fovFrame

    fovOutline = Instance.new("UIStroke")
    fovOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    fovOutline.LineJoinMode = Enum.LineJoinMode.Round
    fovOutline.Parent = fovFrame

    fovGradient = Instance.new("UIGradient")
    fovGradient.Parent = fovFrame
end

local function destroyFov()
    if fovFrame then
        pcall(function() fovFrame:Destroy() end)
        fovFrame = nil
        fovOutline = nil
        fovGradient = nil
        fovCorner = nil
    end
end

createFov()

RunService.RenderStepped:Connect(function()
    if not cfg.AutoKillEnabled then
        currentAutoKillTarget = nil
        lastAutoKillTarget = nil
        hasFiredAtCurrent = false
        unhideAutoKillTarget()
        return
    end

    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 or not myChar:GetAttribute("deployed") then
        unhideAutoKillTarget()
        return
    end

    if currentAutoKillTarget then
        if not currentAutoKillTarget.Parent or not isAlive(currentAutoKillTarget) or hasShield(currentAutoKillTarget) then
            currentAutoKillTarget = nil
            hasFiredAtCurrent = false
        end
    end

    if not currentAutoKillTarget then
        currentAutoKillTarget = getAutoKillTarget()
        lastAutoKillTarget = currentAutoKillTarget
        hasFiredAtCurrent = false
    end

    local target = currentAutoKillTarget
    if not target then
        unhideAutoKillTarget()
        return
    end

    if target ~= lastAutoKillTarget then
        unhideAutoKillTarget()
        lastAutoKillTarget = target
        hasFiredAtCurrent = false
    end

    local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target.PrimaryPart
    if not targetRoot then
        currentAutoKillTarget = nil
        return
    end

    targetRoot.CFrame = myHRP.CFrame * CFrame.new(0, 0, -6.5)

    setAutoKillWeapon()

    if not hasFiredAtCurrent then
        hasFiredAtCurrent = true
        local firedTarget = target
        task.delay(0.12, function()
            if not cfg.AutoKillEnabled or currentAutoKillTarget ~= firedTarget then return end
            local tRoot = firedTarget:FindFirstChild("HumanoidRootPart") or firedTarget:FindFirstChild("Head") or firedTarget.PrimaryPart
            if tRoot then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
            end
            pcall(function()
                if WeaponClient.fire then
                    WeaponClient.fire()
                end
            end)
        end)
    end

    hideAutoKillTarget(target)
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
        if model == currentAutoKillTarget then
            removeEsp(model)
            continue
        end
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
            t.Name.Color = cfg.EspNameColor
        else
            t.Name.Visible = false
        end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if cfg.EspHealth and hum then
            t.Health.Visible = true
            t.Health.Position = topLeft - Vector2.new(0, 28)
            t.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            t.Health.Color = cfg.EspHealthColor
        else
            t.Health.Visible = false
        end

        if cfg.EspDistance and myPos then
            t.Distance.Visible = true
            t.Distance.Position = Vector2.new(center.X, topLeft.Y + boxSize.Y + 2)
            t.Distance.Text = math.floor(dist) .. "m"
            t.Distance.Color = cfg.EspDistanceColor
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
            local totalMinutes = math.floor(cfg.WorldTime * 60)
            local hours = math.floor(totalMinutes / 60) % 24
            local minutes = totalMinutes % 60
            Lighting.TimeOfDay = string.format("%02d:%02d:00", hours, minutes)
        end
    end
end)

-- ============================================================
-- UI SETTINGS
-- ============================================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle('OT_MenuGlow', {
    Text = 'Menu Glow',
    Default = cfg.MenuGlow,
    Callback = function(v) cfg.MenuGlow = v end
})

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor', 'ThemeManager' })
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

-- ============================================================
-- MENU GLOW
-- ============================================================
local glowFrame = nil
RunService.RenderStepped:Connect(function()
    if not cfg.MenuGlow then
        if glowFrame then glowFrame.Visible = false end
        return
    end

    local outer = Library.ScreenGui:FindFirstChild("Outer")
    if not outer then
        if glowFrame then glowFrame.Visible = false end
        return
    end

    if not glowFrame then
        glowFrame = Instance.new("Frame")
        glowFrame.Name = "MenuGlow"
        glowFrame.BorderSizePixel = 0
        glowFrame.BackgroundColor3 = Library.AccentColor
        glowFrame.BackgroundTransparency = 0.85
        glowFrame.ZIndex = 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = glowFrame
        glowFrame.Parent = Library.ScreenGui
    end

    glowFrame.Visible = true
    local pad = 8
    glowFrame.Position = UDim2.new(0, outer.AbsolutePosition.X - pad, 0, outer.AbsolutePosition.Y - pad)
    glowFrame.Size = UDim2.new(0, outer.AbsoluteSize.X + pad * 2, 0, outer.AbsoluteSize.Y + pad * 2)
end)

print('[evolution] One Tap module loaded')
