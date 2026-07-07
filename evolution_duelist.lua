-- ============================================================
-- evolution | DUELIST: PvP
-- Silent aim + bullet manipulation via workspace.Raycast hook.
-- ============================================================



local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Cleanup any previous evolution_duelist instance (connections, old UI, etc.)
if getgenv().EvolutionDuelistCleanup then
    pcall(getgenv().EvolutionDuelistCleanup)
end
-- Fallback: older versions didn't know about the target UI ScreenGui.
for _, sg in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if sg:IsA("ScreenGui") and sg.Name == "EvolutionTargetUI" then
        pcall(function() sg:Destroy() end)
    end
end
local EvolutionConnections = {}
local EvolutionTasks = {}
local duelistTargetScreen, duelistTargetMain, duelistTargetElements, duelistTargetHighlight, duelistTargetTracer, duelistTargetTracerOutline, lastDuelistTargetPlayer
getgenv().EvolutionDuelistCleanup = function()
    for _, c in ipairs(EvolutionConnections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(EvolutionConnections)
    for _, t in ipairs(EvolutionTasks) do
        pcall(task.cancel, t)
    end
    table.clear(EvolutionTasks)
    if typeof(getgenv().EvolutionArcaneWindow) == "table" then
        pcall(function() getgenv().EvolutionArcaneWindow:Destroy() end)
    end
    if duelistTargetScreen then
        pcall(function() duelistTargetScreen:Destroy() end)
        duelistTargetScreen = nil
    end
    for _, sg in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if sg:IsA("ScreenGui") and (sg.Name == "Evolution" or sg.Name == "EvolutionTargetUI") then
            pcall(function() sg:Destroy() end)
        end
    end
    if duelistTargetHighlight then
        pcall(function() duelistTargetHighlight:Destroy() end)
        duelistTargetHighlight = nil
    end
    if duelistTargetTracer then
        pcall(function() duelistTargetTracer:Remove() end)
        duelistTargetTracer = nil
    end
    if duelistTargetTracerOutline then
        pcall(function() duelistTargetTracerOutline:Remove() end)
        duelistTargetTracerOutline = nil
    end
end
local function trackConnection(c)
    table.insert(EvolutionConnections, c)
    return c
end
local function trackTask(t)
    table.insert(EvolutionTasks, t)
    return t
end

-- ============================================================
-- CONFIG
-- ============================================================
getgenv().EvolutionDuelist = {
    SilentAimEnabled = false,
    AutoFire = false,
    TeamCheck = true,
    Hitchance = 100,
    MaxDistance = 1000,
    HitPart = 'Head',

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

    EspEnabled = false,
    EspBoxes = true,
    EspNames = true,
    EspHealth = true,
    EspDistance = true,
    EspMaxDistance = 2000,
    EspBoxColor = Color3.fromRGB(255, 255, 255),
    EspNameColor = Color3.fromRGB(255, 255, 255),
    EspHealthColor = Color3.fromRGB(0, 255, 0),
    EspDistanceColor = Color3.fromRGB(255, 255, 255),

    SkinChangerEnabled = false,
    AutoApplySkin = true,
    SelectedPistolSkinKey = nil,
    SelectedRifleSkinKey = nil,
    CardChangerEnabled = false,
    AutoApplyCard = true,
    SelectedCardKey = nil,

    TargetUIEnabled = false,
    TargetUIColor = Color3.fromRGB(27, 206, 203),
    TargetHighlightEnabled = false,
    TargetHighlightFill = Color3.fromRGB(27, 206, 203),
    TargetHighlightOutline = Color3.fromRGB(255, 255, 255),
    TargetTracerEnabled = false,
    TargetTracerColor = Color3.fromRGB(27, 206, 203),
}
local cfg = getgenv().EvolutionDuelist

-- ============================================================
-- ARCANE UI
-- ============================================================
local Arcane = loadstring(game:HttpGet("https://raw.githubusercontent.com/Da7mu/Ui-Collection/refs/heads/main/Arcane%20Ui/Library.lua"))()
getgenv().EvolutionArcaneWindow = Arcane

local Window = Arcane:Window({
    Name = "Evolution",
    User = LocalPlayer.Name,
    Logo = "137522241512688"
})

-- Pages
local Main = Window:Page({ Name = "Main", Icon = "home" })
local Settings = Window:Page({ Name = "Settings", Icon = "settings" })

-- Subpages
local Combat = Main:SubPage({ Name = "Combat", Icon = "swords" })
local Visuals = Main:SubPage({ Name = "Visuals", Icon = "eye" })
local Player = Main:SubPage({ Name = "Player", Icon = "user" })
local ConfigSub = Settings:SubPage({ Name = "Configs", Icon = "save" })

-- Sections
local CombatLeft = Combat:Section({ Name = "Aimbot", Side = 1 })
local CombatTargetUI = Combat:Section({ Name = "Target UI", Side = 2 })
local CombatHighlight = Combat:Section({ Name = "Highlight", Side = 2 })
local CombatTracer = Combat:Section({ Name = "Tracer", Side = 2 })

local VisualsLeft = Visuals:Section({ Name = "FOV Circle", Side = 1 })
local VisualsRight = Visuals:Section({ Name = "ESP", Side = 2 })

local PlayerLeft = Player:Section({ Name = "Gun Skins", Side = 1 })
local PlayerRight = Player:Section({ Name = "Player Card", Side = 2 })

-- Silent Aim
CombatLeft:Toggle({
    Name = "Silent Aim",
    Default = cfg.SilentAimEnabled,
    Flag = "Duelist_SilentAim",
    Callback = function(State) cfg.SilentAimEnabled = State end
})

CombatLeft:Toggle({
    Name = "Auto Fire",
    Default = cfg.AutoFire,
    Flag = "Duelist_AutoFire",
    Callback = function(State) cfg.AutoFire = State end
})

CombatLeft:Toggle({
    Name = "Team Check",
    Default = cfg.TeamCheck,
    Flag = "Duelist_TeamCheck",
    Callback = function(State) cfg.TeamCheck = State end
})

CombatLeft:Slider({
    Name = "Hitchance",
    Min = 0,
    Max = 100,
    Default = cfg.Hitchance,
    Suffix = "%",
    Flag = "Duelist_Hitchance",
    Callback = function(Value) cfg.Hitchance = Value end
})

CombatLeft:Slider({
    Name = "Max Distance",
    Min = 50,
    Max = 5000,
    Default = cfg.MaxDistance,
    Flag = "Duelist_MaxDistance",
    Callback = function(Value) cfg.MaxDistance = Value end
})

CombatLeft:Dropdown({
    Name = "Hit Part",
    Items = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = cfg.HitPart,
    Flag = "Duelist_HitPart",
    Callback = function(Value) cfg.HitPart = Value end
})

-- Target UI
local TargetUIToggle = CombatTargetUI:Toggle({
    Name = "Target UI",
    Default = cfg.TargetUIEnabled,
    Flag = "Duelist_TargetUI",
    Callback = function(State) cfg.TargetUIEnabled = State end
})
local targetUIColorChained = pcall(function()
    TargetUIToggle:Colorpicker({
        Name = "",
        Default = cfg.TargetUIColor,
        Flag = "Duelist_TargetUIColor",
        Callback = function(Value) cfg.TargetUIColor = Value end
    })
end)
if not targetUIColorChained then
    CombatTargetUI:Colorpicker({
        Name = "UI Color",
        Default = cfg.TargetUIColor,
        Flag = "Duelist_TargetUIColor",
        Callback = function(Value) cfg.TargetUIColor = Value end
    })
end

-- Highlight
local HighlightToggle = CombatHighlight:Toggle({
    Name = "Highlight",
    Default = cfg.TargetHighlightEnabled,
    Flag = "Duelist_TargetHighlight",
    Callback = function(State) cfg.TargetHighlightEnabled = State end
})
local highlightChained = pcall(function()
    HighlightToggle:Colorpicker({
        Name = "",
        Default = cfg.TargetHighlightFill,
        Flag = "Duelist_TargetHighlightFill",
        Callback = function(Value) cfg.TargetHighlightFill = Value end
    })
    HighlightToggle:Colorpicker({
        Name = "",
        Default = cfg.TargetHighlightOutline,
        Flag = "Duelist_TargetHighlightOutline",
        Callback = function(Value) cfg.TargetHighlightOutline = Value end
    })
end)
if not highlightChained then
    CombatHighlight:Colorpicker({
        Name = "Fill Color",
        Default = cfg.TargetHighlightFill,
        Flag = "Duelist_TargetHighlightFill",
        Callback = function(Value) cfg.TargetHighlightFill = Value end
    })
    CombatHighlight:Colorpicker({
        Name = "Outline Color",
        Default = cfg.TargetHighlightOutline,
        Flag = "Duelist_TargetHighlightOutline",
        Callback = function(Value) cfg.TargetHighlightOutline = Value end
    })
end

-- Tracer
local TracerToggle = CombatTracer:Toggle({
    Name = "Tracer",
    Default = cfg.TargetTracerEnabled,
    Flag = "Duelist_TargetTracer",
    Callback = function(State) cfg.TargetTracerEnabled = State end
})
local tracerColorChained = pcall(function()
    TracerToggle:Colorpicker({
        Name = "",
        Default = cfg.TargetTracerColor,
        Flag = "Duelist_TargetTracerColor",
        Callback = function(Value) cfg.TargetTracerColor = Value end
    })
end)
if not tracerColorChained then
    CombatTracer:Colorpicker({
        Name = "Tracer Color",
        Default = cfg.TargetTracerColor,
        Flag = "Duelist_TargetTracerColor",
        Callback = function(Value) cfg.TargetTracerColor = Value end
    })
end

-- FOV Circle
VisualsLeft:Toggle({
    Name = "FOV Circle",
    Default = cfg.ShowFOV,
    Flag = "Duelist_ShowFOV",
    Callback = function(State) cfg.ShowFOV = State end
})

VisualsLeft:Slider({
    Name = "Radius",
    Min = 10,
    Max = 1000,
    Default = cfg.FOVRadius,
    Flag = "Duelist_FOVRadius",
    Callback = function(Value) cfg.FOVRadius = Value end
})

VisualsLeft:Slider({
    Name = "Fill Transparency",
    Min = 0,
    Max = 100,
    Default = cfg.FOVFillTransparency * 100,
    Flag = "Duelist_FOVFillTransparency",
    Callback = function(Value) cfg.FOVFillTransparency = Value / 100 end
})

VisualsLeft:Toggle({
    Name = "Outline",
    Default = cfg.FOVOutline,
    Flag = "Duelist_FOVOutline",
    Callback = function(State) cfg.FOVOutline = State end
})

VisualsLeft:Slider({
    Name = "Outline Thickness",
    Min = 0,
    Max = 10,
    Default = cfg.FOVOutlineThickness,
    Flag = "Duelist_FOVOutlineThickness",
    Callback = function(Value) cfg.FOVOutlineThickness = Value end
})

local GradientToggle = VisualsLeft:Toggle({
    Name = "Gradient",
    Default = cfg.FOVGradient,
    Flag = "Duelist_FOVGradient",
    Callback = function(State) cfg.FOVGradient = State end
})

local gradientChained = pcall(function()
    GradientToggle:Colorpicker({
        Name = "",
        Default = cfg.FOVGradientTop,
        Flag = "Duelist_FOVGradientTop",
        Callback = function(Value) cfg.FOVGradientTop = Value end
    })
    GradientToggle:Colorpicker({
        Name = "",
        Default = cfg.FOVGradientBottom,
        Flag = "Duelist_FOVGradientBottom",
        Callback = function(Value) cfg.FOVGradientBottom = Value end
    })
end)

if not gradientChained then
    VisualsLeft:Colorpicker({
        Name = "Gradient Top",
        Default = cfg.FOVGradientTop,
        Flag = "Duelist_FOVGradientTop",
        Callback = function(Value) cfg.FOVGradientTop = Value end
    })
    VisualsLeft:Colorpicker({
        Name = "Gradient Bottom",
        Default = cfg.FOVGradientBottom,
        Flag = "Duelist_FOVGradientBottom",
        Callback = function(Value) cfg.FOVGradientBottom = Value end
    })
end

VisualsLeft:Toggle({
    Name = "Gradient Spin",
    Default = cfg.FOVGradientSpin,
    Flag = "Duelist_FOVGradientSpin",
    Callback = function(State) cfg.FOVGradientSpin = State end
})

VisualsLeft:Slider({
    Name = "Gradient Spin Speed",
    Min = 0,
    Max = 500,
    Default = cfg.FOVGradientSpeed,
    Flag = "Duelist_FOVGradientSpeed",
    Callback = function(Value) cfg.FOVGradientSpeed = Value end
})

-- ESP
VisualsRight:Toggle({
    Name = "ESP",
    Default = cfg.EspEnabled,
    Flag = "Duelist_EspEnabled",
    Callback = function(State) cfg.EspEnabled = State end
})

VisualsRight:Toggle({
    Name = "Boxes",
    Default = cfg.EspBoxes,
    Flag = "Duelist_EspBoxes",
    Callback = function(State) cfg.EspBoxes = State end
})

VisualsRight:Colorpicker({
    Name = "Box Color",
    Default = cfg.EspBoxColor,
    Flag = "Duelist_EspBoxColor",
    Callback = function(Value) cfg.EspBoxColor = Value end
})

VisualsRight:Toggle({
    Name = "Names",
    Default = cfg.EspNames,
    Flag = "Duelist_EspNames",
    Callback = function(State) cfg.EspNames = State end
})

VisualsRight:Colorpicker({
    Name = "Name Color",
    Default = cfg.EspNameColor,
    Flag = "Duelist_EspNameColor",
    Callback = function(Value) cfg.EspNameColor = Value end
})

VisualsRight:Toggle({
    Name = "Health",
    Default = cfg.EspHealth,
    Flag = "Duelist_EspHealth",
    Callback = function(State) cfg.EspHealth = State end
})

VisualsRight:Colorpicker({
    Name = "Health Color",
    Default = cfg.EspHealthColor,
    Flag = "Duelist_EspHealthColor",
    Callback = function(Value) cfg.EspHealthColor = Value end
})

VisualsRight:Toggle({
    Name = "Distance",
    Default = cfg.EspDistance,
    Flag = "Duelist_EspDistance",
    Callback = function(State) cfg.EspDistance = State end
})

VisualsRight:Colorpicker({
    Name = "Distance Color",
    Default = cfg.EspDistanceColor,
    Flag = "Duelist_EspDistanceColor",
    Callback = function(Value) cfg.EspDistanceColor = Value end
})

VisualsRight:Slider({
    Name = "Max Distance",
    Min = 100,
    Max = 10000,
    Default = cfg.EspMaxDistance,
    Flag = "Duelist_EspMaxDistance",
    Callback = function(Value) cfg.EspMaxDistance = Value end
})

-- Gun skins
PlayerLeft:Toggle({
    Name = "Skin Changer",
    Default = cfg.SkinChangerEnabled,
    Flag = "Duelist_SkinChangerEnabled",
    Callback = function(State)
        cfg.SkinChangerEnabled = State
        if State then
            applySelectedSkin()
        else
            local tool = getEquippedGun()
            if tool then
                local old = tool:FindFirstChild("Skin")
                if old then old:Destroy() end
            end
        end
    end
})

PlayerLeft:Toggle({
    Name = "Auto Apply On Equip",
    Default = cfg.AutoApplySkin,
    Flag = "Duelist_AutoApplySkin",
    Callback = function(State) cfg.AutoApplySkin = State end
})

local pistolSkinDebounce = nil
local PistolSkinDropdown = PlayerLeft:Dropdown({
    Name = "Pistol Skin",
    Items = { "None" },
    Default = "None",
    Flag = "Duelist_PistolSkin",
    Callback = function(Value)
        cfg.SelectedPistolSkinKey = (Value ~= "None" and Value or nil)
        if pistolSkinDebounce then pcall(task.cancel, pistolSkinDebounce) end
        pistolSkinDebounce = trackTask(task.delay(0.15, function()
            for i, t in ipairs(EvolutionTasks) do
                if t == pistolSkinDebounce then table.remove(EvolutionTasks, i) break end
            end
            pistolSkinDebounce = nil
            if not cfg.SkinChangerEnabled then return end
            if cfg.SelectedPistolSkinKey == (Value ~= "None" and Value or nil) then
                applySelectedSkin()
            end
        end))
    end
})

local rifleSkinDebounce = nil
local RifleSkinDropdown = PlayerLeft:Dropdown({
    Name = "Rifle Skin",
    Items = { "None" },
    Default = "None",
    Flag = "Duelist_RifleSkin",
    Callback = function(Value)
        cfg.SelectedRifleSkinKey = (Value ~= "None" and Value or nil)
        if rifleSkinDebounce then pcall(task.cancel, rifleSkinDebounce) end
        rifleSkinDebounce = trackTask(task.delay(0.15, function()
            for i, t in ipairs(EvolutionTasks) do
                if t == rifleSkinDebounce then table.remove(EvolutionTasks, i) break end
            end
            rifleSkinDebounce = nil
            if not cfg.SkinChangerEnabled then return end
            if cfg.SelectedRifleSkinKey == (Value ~= "None" and Value or nil) then
                applySelectedSkin()
            end
        end))
    end
})

PlayerLeft:Button({
    Name = "Refresh Skins",
    Callback = function()
        if typeof(refreshSkinList) == "function" then refreshSkinList() end
    end
})

PlayerLeft:Button({
    Name = "Apply Skin Now",
    Callback = function()
        if typeof(applySelectedSkin) == "function" then applySelectedSkin() end
    end
})

-- Player Card
PlayerRight:Toggle({
    Name = "Card Changer",
    Default = cfg.CardChangerEnabled,
    Flag = "Duelist_CardChangerEnabled",
    Callback = function(State)
        cfg.CardChangerEnabled = State
        if State then applySelectedCard() end
    end
})

PlayerRight:Toggle({
    Name = "Auto Apply",
    Default = cfg.AutoApplyCard,
    Flag = "Duelist_AutoApplyCard",
    Callback = function(State) cfg.AutoApplyCard = State end
})

local CardDropdown = PlayerRight:Dropdown({
    Name = "Player Card",
    Items = { "None" },
    Default = "None",
    Flag = "Duelist_PlayerCard",
    Callback = function(Value)
        cfg.SelectedCardKey = (Value ~= "None" and Value or nil)
        if cfg.CardChangerEnabled then applySelectedCard() end
    end
})

PlayerRight:Button({
    Name = "Refresh Cards",
    Callback = function()
        if typeof(refreshCardList) == "function" then refreshCardList() end
    end
})

PlayerRight:Button({
    Name = "Apply Card Now",
    Callback = function()
        if typeof(applySelectedCard) == "function" then applySelectedCard() end
    end
})

-- Configs
ConfigSub:Config()

-- Notification
Arcane:Notification({
    Name = "Evolution",
    Description = "Duelist module loaded — Right Ctrl to toggle.",
    Duration = 5,
    Icon = "check",
    Color = Color3.fromRGB(52, 255, 164)
})

-- Watermark
Window:Watermark({
    Title = "evolution | duelist"
})


-- ============================================================
-- FOV CIRCLE LOGIC
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

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = fovFrame

    fovOutline = Instance.new("UIStroke")
    fovOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    fovOutline.LineJoinMode = Enum.LineJoinMode.Round
    fovOutline.Parent = fovFrame

    fovGradient = Instance.new("UIGradient")
    fovGradient.Parent = fovFrame
end

trackConnection(RunService.RenderStepped:Connect(function()
    local shouldShow = cfg.SilentAimEnabled and cfg.ShowFOV
    if not shouldShow then
        if fovFrame then fovFrame.Visible = false end
        return
    end

    if not fovFrame or fovFrame.Parent == nil then createFov() end

    local center = Camera.ViewportSize / 2
    fovFrame.Visible = true
    fovFrame.Position = UDim2.new(0, center.X, 0, center.Y)
    fovFrame.Size = UDim2.new(0, cfg.FOVRadius * 2, 0, cfg.FOVRadius * 2)
    fovFrame.BackgroundColor3 = cfg.FOVColor
    fovFrame.BackgroundTransparency = cfg.FOVFillTransparency

    if fovOutline then
        fovOutline.Enabled = cfg.FOVOutline
        fovOutline.Color = cfg.FOVOutlineColor
        fovOutline.Thickness = cfg.FOVOutlineThickness
    end

    if fovGradient then
        if cfg.FOVGradient then
            fovGradient.Color = gradientColor(cfg.FOVGradientTop, cfg.FOVGradientBottom)
            if cfg.FOVGradientSpin then
                fovGradient.Rotation = (tick() * cfg.FOVGradientSpeed) % 360
            end
        else
            fovGradient.Color = gradientColor(cfg.FOVColor, cfg.FOVColor)
        end
    end
end))

-- ============================================================
-- SILENT AIM / BULLET MANIPULATION LOGIC
-- ============================================================

-- Clean up any hooks from a previous load so we don't double-hook.
local previousHooks = getgenv().EvolutionDuelistHooks
if previousHooks then
    if previousHooks.mt and previousHooks.oldNamecall then
        pcall(function()
            local setro = setreadonly or function(t, writable)
                if typeof(make_writable) == "function" then
                    if writable then make_writable(t) else make_readonly(t) end
                end
            end
            setro(previousHooks.mt, false)
            previousHooks.mt.__namecall = previousHooks.oldNamecall
            setro(previousHooks.mt, true)
        end)
    end
    if previousHooks.weaponsRemote and previousHooks.oldFireServer then
        pcall(function()
            if typeof(hookfunction) == "function" then
                hookfunction(previousHooks.weaponsRemote.FireServer, previousHooks.oldFireServer)
            else
                previousHooks.weaponsRemote.FireServer = previousHooks.oldFireServer
            end
        end)
    end
    getgenv().EvolutionDuelistHooks = nil
end

local CharactersFolder = Workspace:WaitForChild("Characters", 10) or Workspace:FindFirstChild("Characters")
local WeaponsRemote = ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("Weapons", 10)

local function isAlive(model)
    if not model then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isEnemy(model)
    if not cfg.TeamCheck then return true end
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr then return true end
    return plr.Team ~= LocalPlayer.Team
end

local function getPriorityPart(model)
    local roll = math.random(1, 100)
    if roll <= cfg.Hitchance then
        return model:FindFirstChild(cfg.HitPart) or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    else
        return model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    end
end

-- Prevents recursive raycast redirection while getTarget runs.
local computingTarget = false

local function rawGetTarget()
    if not cfg.SilentAimEnabled then return nil end
    if not CharactersFolder then return nil end

    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHead = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
    if not myHead then return nil end

    local origin = myHead.Position
    local bestDist = math.huge
    local bestPart = nil

    for _, model in ipairs(CharactersFolder:GetChildren()) do
        if model == myChar then continue end
        if not isAlive(model) then continue end
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

local function getTarget()
    if computingTarget then return nil end
    computingTarget = true
    local ok, result = pcall(rawGetTarget)
    computingTarget = false
    if ok then return result end
    return nil
end

local function getTargetPlayer()
    local part = getTarget()
    if not part then return nil end
    local model = part:FindFirstAncestorOfClass("Model")
    if not model or not isAlive(model) then return nil end
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == LocalPlayer then return nil end
    if not isEnemy(model) then return nil end
    return { Player = plr, Model = model, Part = part }
end

-- The game's bind system stores its functions in the real Roblox _G, not the executor _G.
local GameG = (typeof(getrenv) == "function" and getrenv()._G) or _G

-- Active while WeaponsClient is processing a shot (Process -> castBullet).
local shotActiveUntil = 0

-- Tries to identify a weapon raycast by its origin (muzzle or camera center).
local function isWeaponRaycastOrigin(origin)
    local char = LocalPlayer.Character
    if not char then return false end

    -- Camera-center ray (castBullet's first ray and getCrosshairTargetCharacter).
    if (origin - Camera.CFrame.Position).Magnitude < 0.01 then
        return true
    end

    -- Muzzle attachment / part on the equipped gun.
    for _, d in ipairs(char:GetDescendants()) do
        if d.Name == "Muzzle" then
            local pos = nil
            if d:IsA("Attachment") then
                pos = d.WorldPosition
            elseif d:IsA("BasePart") then
                pos = d.Position
            end
            if pos and (pos - origin).Magnitude < 0.01 then
                return true
            end
        end
    end

    return false
end

-- Hook workspace.Raycast via the game metatable so WeaponsClient's castBullet hits our target.
local mt = (typeof(getrawmetatable) == "function" and getrawmetatable(game)) or (debug and debug.getmetatable(game))
local oldNamecall
if mt then
    local setro = setreadonly or function(t, writable)
        if typeof(make_writable) == "function" then
            if writable then make_writable(t) else make_readonly(t) end
        end
    end

    oldNamecall = mt.__namecall
    setro(mt, false)

    local function namecallHook(...)
        local self, a1 = ...
        local method = getnamecallmethod()

        if method == "Raycast" and self:IsA("Workspace") and cfg.SilentAimEnabled and not computingTarget then
            if tick() <= shotActiveUntil then
                local origin = a1

                -- Don't redirect the per-frame CameraUpdate head-origin raycast.
                local myChar = LocalPlayer.Character
                local myHead = myChar and myChar:FindFirstChild("Head")
                if myHead and (origin - myHead.Position).Magnitude < 1.5 then
                    -- fall through to passthrough
                else
                    local isBullet = false

                    -- Primary: call came from the WeaponsClient module.
                    if typeof(getcallingscript) == "function" then
                        local calling = getcallingscript()
                        isBullet = calling and calling:IsA("ModuleScript") and calling.Name == "WeaponsClient"
                    end

                    if not isBullet then
                        local stack = debug.traceback("", 2)
                        isBullet = string.find(stack, "WeaponsClient", 1, true)
                            or string.find(stack, "castBullet", 1, true)
                            or string.find(stack, "firePellet", 1, true)
                    end

                    -- Fallback for carbine/rifle or any helper module that fires from muzzle/camera.
                    if not isBullet then
                        isBullet = isWeaponRaycastOrigin(origin)
                    end

                    if isBullet then
                        local target = getTarget()
                        if target then
                            local pos = target.Position
                            local normal = (origin - pos).Unit
                            return {
                                Instance = target,
                                Position = pos,
                                Normal = normal,
                                Material = Enum.Material.Plastic,
                                Distance = (origin - pos).Magnitude,
                            }
                        end
                    end
                end
            end
        end

        -- Bypass the old __namecall closure to avoid the "expects string" calling-convention error.
        local realMethod = self[method]
        if typeof(realMethod) == "function" then
            return realMethod(self, select(2, ...))
        end
        return oldNamecall(...)
    end

    mt.__namecall = (typeof(newcclosure) == "function" and newcclosure(namecallHook)) or namecallHook
    setro(mt, true)
end

-- Hook outgoing remotes so the tracer looks right and we know when a shot is fired.
local oldFireServer = nil
local function hookedFireServer(self, cmd, ...)
    if not (self:IsA("RemoteEvent") and self.Name == "Weapons" and self.Parent and self.Parent.Name == "Events") then
        return oldFireServer(self, cmd, ...)
    end

    if not cfg.SilentAimEnabled then
        return oldFireServer(self, cmd, ...)
    end

    if cmd == "Process" then
        local target = getTarget()
        if target then
            shotActiveUntil = tick() + 0.25
        end
    elseif cmd == "ReplicateTracer" then
        local style, startPos, _, hitInfo = ...
        local target = getTarget()
        if target then
            return oldFireServer(self, "ReplicateTracer", style, startPos, target.Position, {
                Instance = target,
                CFrame = target.CFrame,
                Damaged = true,
                BonusHit = false
            })
        end
    end

    return oldFireServer(self, cmd, ...)
end

if typeof(hookfunction) == "function" then
    oldFireServer = hookfunction(WeaponsRemote.FireServer, hookedFireServer)
else
    oldFireServer = WeaponsRemote.FireServer
    WeaponsRemote.FireServer = hookedFireServer
end

-- Remember hooks so a reload can restore them instead of stacking hooks.
getgenv().EvolutionDuelistHooks = {
    mt = mt,
    oldNamecall = oldNamecall,
    weaponsRemote = WeaponsRemote,
    oldFireServer = oldFireServer,
}

-- Auto Fire
local lastSemiTrigger = 0
local autoFireHeld = false

local function getEquippedGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t:HasTag("Gun") then
            return t
        end
    end
    return nil
end

local function isAutomaticGun(tool)
    if not tool then return false end
    local name = tool.Name:lower()
    if name:find("carabine") or name:find("carbine") or name:find("rifle") then
        return true
    end
    local attr = tool:GetAttribute("Automatic")
    return attr == true or attr == "true" or attr == 1
end

local function setShootBind(down)
    if not (GameG and typeof(GameG.FireBind) == "function") then return end
    pcall(function() GameG:FireBind("Shoot", down, false) end)
end

trackConnection(RunService.RenderStepped:Connect(function()
    local shouldFire = cfg.SilentAimEnabled and cfg.AutoFire
    local target = shouldFire and getTarget() or nil

    if not target then
        if autoFireHeld then
            setShootBind(false)
            autoFireHeld = false
        end
        return
    end

    local gun = getEquippedGun()
    if isAutomaticGun(gun) then
        -- Hold the bind so automatic weapons spray.
        if not autoFireHeld then
            setShootBind(true)
            autoFireHeld = true
        end
    else
        -- Tap for semi-auto (pistol).
        if tick() - lastSemiTrigger >= 0.15 then
            setShootBind(true)
            autoFireHeld = true
            lastSemiTrigger = tick()
            task.delay(0.05, function()
                setShootBind(false)
                autoFireHeld = false
            end)
        end
    end
end))

-- ============================================================
-- ESP LOGIC
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

trackConnection(RunService.RenderStepped:Connect(function()
    if not cfg.EspEnabled or not CharactersFolder then
        for model, _ in pairs(espDrawings) do removeEsp(model) end
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
    local myPos = myRoot and myRoot.Position

    local seen = {}
    for _, model in ipairs(CharactersFolder:GetChildren()) do
        seen[model] = true
        if model == myChar then continue end
        if not isAlive(model) then removeEsp(model); continue end
        if not isEnemy(model) then continue end

        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
        if not root then removeEsp(model); continue end

        local dist = myPos and (root.Position - myPos).Magnitude or 0
        if dist > cfg.EspMaxDistance then removeEsp(model); continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then removeEsp(model); continue end

        local t = ensureEsp(model)
        local center = Vector2.new(screenPos.X, screenPos.Y)
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
        if not seen[model] then removeEsp(model) end
    end
end))

-- ============================================================
-- COSMETICS LOGIC
-- ============================================================
local pistolSkinRegistry = {}
local rifleSkinRegistry = {}
local cardRegistry = {}

local function scanSkins()
    table.clear(pistolSkinRegistry)
    table.clear(rifleSkinRegistry)

    local function check(folder)
        if not folder then return end
        if folder.Name:lower() == "skins" then
            -- Assets.Skins uses category folders (Pistol, Carabine, etc.)
            for _, cat in ipairs(folder:GetChildren()) do
                if cat:IsA("Folder") then
                    local catName = cat.Name
                    local isPistol = catName:lower():find("pistol")
                    local isRifle = catName:lower():find("carabine") or catName:lower():find("rifle")
                    for _, skin in ipairs(cat:GetChildren()) do
                        if skin:IsA("Model") then
                            if isPistol then
                                pistolSkinRegistry[skin.Name] = skin
                            elseif isRifle then
                                rifleSkinRegistry[skin.Name] = skin
                            end
                        end
                    end
                end
            end
        end
    end

    local rs = ReplicatedStorage
    check(rs:FindFirstChild("Skins"))

    local assets = rs:FindFirstChild("Assets")
    if assets then
        for _, c in ipairs(assets:GetChildren()) do
            local n = c.Name:lower()
            if n:find("skin") or n:find("gun") then
                check(c)
            end
        end
    end
end

local function scanCards()
    local list = {}

    local function isCardModel(model)
        return model:IsA("Model") and (model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("BodyColors"))
    end

    local function addFolder(folder)
        for _, item in ipairs(folder:GetChildren()) do
            if isCardModel(item) then
                table.insert(list, {Key = item.Name, Object = item})
            end
        end
    end

    local rs = ReplicatedStorage
    for _, c in ipairs(rs:GetChildren()) do
        if c.Name:lower():find("card") then
            addFolder(c)
        end
    end

    local assets = rs:FindFirstChild("Assets")
    if assets then
        for _, c in ipairs(assets:GetChildren()) do
            if c.Name:lower():find("card") then
                addFolder(c)
            end
        end
    end

    return list
end

function refreshSkinList()
    scanSkins()

    local function buildValues(registry)
        local values = {'None'}
        for name, _ in pairs(registry) do
            table.insert(values, name)
        end
        table.sort(values, function(a, b) return a:lower() < b:lower() end)
        return values
    end

    local pistolValues = buildValues(pistolSkinRegistry)
    local rifleValues = buildValues(rifleSkinRegistry)

    if typeof(PistolSkinDropdown) == "table" then
        pcall(function() PistolSkinDropdown:SetItems(pistolValues) end)
        pcall(function() PistolSkinDropdown:Refresh(pistolValues) end)
    end
    if typeof(RifleSkinDropdown) == "table" then
        pcall(function() RifleSkinDropdown:SetItems(rifleValues) end)
        pcall(function() RifleSkinDropdown:Refresh(rifleValues) end)
    end

    if cfg.SelectedPistolSkinKey and not pistolSkinRegistry[cfg.SelectedPistolSkinKey] then
        cfg.SelectedPistolSkinKey = nil
    end
    if cfg.SelectedRifleSkinKey and not rifleSkinRegistry[cfg.SelectedRifleSkinKey] then
        cfg.SelectedRifleSkinKey = nil
    end
end

function refreshCardList()
    local cards = scanCards()
    cardRegistry = {}
    local values = {'None'}
    for _, c in ipairs(cards) do
        cardRegistry[c.Key] = c.Object
        table.insert(values, c.Key)
    end
    table.sort(values, function(a, b) return a:lower() < b:lower() end)
    if typeof(CardDropdown) == "table" then
        pcall(function() CardDropdown:SetItems(values) end)
        pcall(function() CardDropdown:Refresh(values) end)
    end
    if not cardRegistry[cfg.SelectedCardKey] then
        cfg.SelectedCardKey = nil
    end
end

function applySelectedSkin()
    if not cfg.SkinChangerEnabled then return end
    local tool = getEquippedGun()
    if not tool then return end

    local isRifle = tool.Name:lower():find("carabine") or tool.Name:lower():find("rifle")
    local selectedKey = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
    local registry = isRifle and rifleSkinRegistry or pistolSkinRegistry
    local skinObj = selectedKey and registry[selectedKey]

    if not skinObj or not skinObj:IsA("Model") then
        -- No skin selected for this weapon type; strip any applied skin so the server/owned skin shows.
        local oldSkin = tool:FindFirstChild("Skin")
        if oldSkin then oldSkin:Destroy() end
        return
    end

    -- Snapshot the requested skin so rapid dropdown changes don't apply stale skins.
    local requestedKey = selectedKey
    local requestedTag = (isRifle and "Carabine" or "Pistol") .. " / " .. selectedKey
    local ok, err = pcall(function()
        local currentKey = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
        if currentKey ~= requestedKey then return end

        local toolHandle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
        if not toolHandle then return end

        -- Remove any previously-applied skin first.
        local oldSkin = tool:FindFirstChild("Skin")
        if oldSkin then oldSkin:Destroy() end

        local newSkin = skinObj:Clone()
        newSkin.Name = "Skin"

        for _, d in ipairs(newSkin:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = false
                d.CanCollide = false
                d.Massless = true
            elseif d:IsA("LocalScript") or d:IsA("Script") then
                d:Destroy()
            end
        end

        local function pickHandle(skin, preferredName)
            if preferredName then
                local p = skin:FindFirstChild(preferredName)
                if p and p:IsA("BasePart") then return p end
            end
            local h1 = skin:FindFirstChild("Handle1")
            if h1 and h1:IsA("BasePart") then return h1 end
            local h = skin:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then return h end
            local largest, maxSize = nil, 0
            for _, part in ipairs(skin:GetDescendants()) do
                if part:IsA("BasePart") then
                    local sz = part.Size.Magnitude
                    if sz > maxSize then
                        maxSize = sz
                        largest = part
                    end
                end
            end
            return largest
        end

        -- Find the skin's authored grip attachment and its parent part.
        local toolGrip = toolHandle:FindFirstChild("GripPosition")
        local skinGrip, skinGripPart = nil, nil
        for _, a in ipairs(newSkin:GetDescendants()) do
            if a:IsA("Attachment") and a.Name == "GripPosition" and a.Parent:IsA("BasePart") then
                skinGrip = a
                skinGripPart = a.Parent
                break
            end
        end

        local skinHandle = skinGripPart or pickHandle(newSkin)
        if not skinHandle then
            newSkin:Destroy()
            return
        end

        -- Align the whole skin rigidly so its GripPosition matches the tool's GripPosition.
        -- The old server weld always flipped the skin 180° around Y, so apply that rotation
        -- relative to the grip; without it the gun is held backwards/sideways.
        if toolGrip and skinGrip then
            local targetCF = toolGrip.WorldCFrame * CFrame.Angles(0, math.pi, 0)
            local newHandleCF = targetCF * skinGrip.CFrame:Inverse()
            local transform = newHandleCF * skinHandle.CFrame:Inverse()
            for _, part in ipairs(newSkin:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CFrame = transform * part.CFrame
                end
            end
        else
            skinHandle.CFrame = toolHandle.CFrame
        end

        -- Mark the skin BEFORE parenting so ChildAdded hooks know it's ours.
        newSkin:SetAttribute("EvolutionSkinKey", requestedTag)
        newSkin.Parent = tool
        newSkin.PrimaryPart = skinHandle

        -- Preserve original internal welds if the skin uses them; otherwise weld loose parts.
        local hasInternalWeld = false
        for _, d in ipairs(newSkin:GetDescendants()) do
            if d:IsA("Weld") or d:IsA("Motor6D") or d:IsA("ManualWeld") then
                hasInternalWeld = true
                break
            end
        end

        if not hasInternalWeld then
            for _, part in ipairs(newSkin:GetDescendants()) do
                if part:IsA("BasePart") and part ~= skinHandle then
                    local weld = Instance.new("Weld")
                    weld.Part0 = skinHandle
                    weld.Part1 = part
                    weld.C0 = skinHandle.CFrame:Inverse() * part.CFrame
                    weld.Parent = skinHandle
                end
            end
        else
            for _, d in ipairs(newSkin:GetDescendants()) do
                if d:IsA("Weld") or d:IsA("Motor6D") or d:IsA("ManualWeld") then
                    if d.Part0 and not d.Part0:IsDescendantOf(newSkin) then
                        d.Part0 = skinHandle
                    end
                    if d.Part1 and not d.Part1:IsDescendantOf(newSkin) then
                        d.Part1 = skinHandle
                    end
                end
            end
        end

        local mainWeld = Instance.new("Weld")
        mainWeld.Part0 = toolHandle
        mainWeld.Part1 = skinHandle
        mainWeld.C0 = toolHandle.CFrame:Inverse() * skinHandle.CFrame
        mainWeld.C1 = CFrame.new()
        mainWeld.Parent = skinHandle
    end)
    if not ok then warn("[evolution] applySelectedSkin error:", err) end
end

-- Hook a tool so the selected skin is applied the instant it is equipped
-- or the instant the server tries to put its own skin back on.
local function hookTool(tool)
    if not tool:IsA("Tool") then return end
    if tool:GetAttribute("EvolutionToolHooked") then return end
    tool:SetAttribute("EvolutionToolHooked", true)

    trackConnection(tool.Equipped:Connect(function()
        if not cfg.SkinChangerEnabled then return end
        local isRifle = tool.Name:lower():find("carabine") or tool.Name:lower():find("rifle")
        local key = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
        if cfg.AutoApplySkin and key then
            applySelectedSkin()
        elseif not key then
            local old = tool:FindFirstChild("Skin")
            if old then old:Destroy() end
        end
    end))

    trackConnection(tool.ChildAdded:Connect(function(child)
        if child.Name ~= "Skin" then return end
        if not cfg.SkinChangerEnabled then return end
        local isRifle = tool.Name:lower():find("carabine") or tool.Name:lower():find("rifle")
        local key = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
        local tag = key and ((isRifle and "Carabine" or "Pistol") .. " / " .. key) or nil
        if cfg.AutoApplySkin and key and child:GetAttribute("EvolutionSkinKey") ~= tag then
            applySelectedSkin()
        elseif not key then
            child:Destroy()
        end
    end))
end

local function hookToolsIn(parent)
    for _, t in ipairs(parent:GetChildren()) do
        hookTool(t)
    end
    trackConnection(parent.ChildAdded:Connect(hookTool))
end

-- Hook tools already in backpack/character and any future ones.
hookToolsIn(LocalPlayer.Backpack)
if LocalPlayer.Character then
    hookToolsIn(LocalPlayer.Character)
end
trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    hookToolsIn(char)
end))

local cardApplyInProgress = false
function applySelectedCard()
    if cardApplyInProgress then return end
    if not cfg.CardChangerEnabled then return end
    local cardObj = cfg.SelectedCardKey and cardRegistry[cfg.SelectedCardKey]
    if not cardObj or not cardObj:IsA("Model") then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    cardApplyInProgress = true
    task.defer(function()
        pcall(function()
            -- 1) Body colors / clothing.
            local function copyClass(class)
                local from = cardObj:FindFirstChildOfClass(class)
                local existing = char:FindFirstChildOfClass(class)
                if existing then existing:Destroy() end
                if from then
                    local clone = from:Clone()
                    clone.Parent = char
                end
            end

            copyClass("BodyColors")
            copyClass("Shirt")
            copyClass("Pants")
            copyClass("ShirtGraphic")

            -- 2) Body part meshes / appearance.
            for _, fromPart in ipairs(cardObj:GetDescendants()) do
                if fromPart:IsA("BasePart") then
                    local myPart = char:FindFirstChild(fromPart.Name)
                    if myPart and myPart:IsA("BasePart") then
                        if fromPart:IsA("MeshPart") and myPart:IsA("MeshPart") then
                            if fromPart.MeshId ~= "" then myPart.MeshId = fromPart.MeshId end
                            if fromPart.TextureID ~= "" then myPart.TextureID = fromPart.TextureID end
                        elseif fromPart:FindFirstChildOfClass("SpecialMesh") and myPart:FindFirstChildOfClass("SpecialMesh") then
                            local fromMesh = fromPart:FindFirstChildOfClass("SpecialMesh")
                            local myMesh = myPart:FindFirstChildOfClass("SpecialMesh")
                            if fromMesh.MeshId ~= "" then myMesh.MeshId = fromMesh.MeshId end
                            if fromMesh.TextureId ~= "" then myMesh.TextureId = fromMesh.TextureId end
                            if fromMesh.MeshType then myMesh.MeshType = fromMesh.MeshType end
                        end
                        myPart.Color = fromPart.Color
                        myPart.Size = fromPart.Size
                        myPart.Transparency = fromPart.Transparency
                        myPart.Reflectance = fromPart.Reflectance
                        myPart.Material = fromPart.Material
                    end
                end
            end

            -- 3) Remove old accessories/hats and old evolution attachments.
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("Accessory") or part:IsA("Hat") then
                    pcall(function() hum:RemoveAccessory(part) end)
                    part:Destroy()
                elseif part:IsA("BasePart") then
                    for _, att in ipairs(part:GetChildren()) do
                        if att:IsA("Attachment") and att:GetAttribute("EvolutionCardAtt") then
                            att:Destroy()
                        end
                    end
                end
            end

            -- 4) Copy attachments first so accessories have their mount points.
            for _, fromPart in ipairs(cardObj:GetDescendants()) do
                if fromPart:IsA("BasePart") then
                    local myPart = char:FindFirstChild(fromPart.Name)
                    if myPart then
                        for _, att in ipairs(fromPart:GetChildren()) do
                            if att:IsA("Attachment") then
                                local clone = att:Clone()
                                clone:SetAttribute("EvolutionCardAtt", true)
                                clone.Parent = myPart
                            end
                        end
                    end
                end
            end

            -- 5) Add card accessories / hats.
            for _, acc in ipairs(cardObj:GetDescendants()) do
                if acc:IsA("Accessory") or acc:IsA("Hat") then
                    local clone = acc:Clone()
                    for _, p in ipairs(clone:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Anchored = false
                            p.CanCollide = false
                            p.Massless = true
                        elseif p:IsA("Weld") and p.Name == "AccessoryWeld" then
                            p:Destroy()
                        end
                    end
                    clone.Parent = char
                    pcall(function() hum:AddAccessory(clone) end)
                end
            end

            -- 6) Face decal.
            local cardHead = cardObj:FindFirstChild("Head")
            local myHead = char:FindFirstChild("Head")
            if cardHead and myHead then
                local hasCardFace = false
                for _, d in ipairs(cardHead:GetDescendants()) do
                    if d:IsA("Decal") then hasCardFace = true break end
                end
                if hasCardFace then
                    for _, d in ipairs(myHead:GetChildren()) do
                        if d:IsA("Decal") then d:Destroy() end
                    end
                    for _, d in ipairs(cardHead:GetDescendants()) do
                        if d:IsA("Decal") then
                            local clone = d:Clone()
                            clone.Parent = myHead
                        end
                    end
                end
            end

            char:SetAttribute("EvolutionCardKey", cfg.SelectedCardKey)
        end)
        cardApplyInProgress = false
    end)
end

-- ============================================================
-- TARGET INDICATOR LOGIC
-- ============================================================

local function getTargetAmmo(character)
    if not character then return 0, 0 end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return 0, 0 end
    local s = tool:FindFirstChild("Script")
    if not s then return 0, 0 end
    local ammo = s:FindFirstChild("Ammo")
    local maxAmmo = s:FindFirstChild("MaxAmmo")
    if ammo and maxAmmo and ammo:IsA("IntValue") and maxAmmo:IsA("IntValue") then
        return ammo.Value, maxAmmo.Value
    end
    return 0, 0
end

duelistTargetScreen = nil
duelistTargetMain = nil
duelistTargetElements = {}
duelistTargetHighlight = nil
duelistTargetTracer = nil
duelistTargetTracerOutline = nil
lastDuelistTargetPlayer = nil

local function createTargetUI()
    if duelistTargetScreen then return end

    local function makeGradient(startCol, midCol, endCol)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, startCol),
            ColorSequenceKeypoint.new(0.5, midCol),
            ColorSequenceKeypoint.new(1, endCol),
        })
    end

    duelistTargetScreen = Instance.new("ScreenGui")
    duelistTargetScreen.Name = "EvolutionTargetUI"
    duelistTargetScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    duelistTargetScreen.Parent = cloneref(game:GetService("CoreGui"))
    duelistTargetScreen.ResetOnSpawn = false
    duelistTargetScreen.DisplayOrder = 9998
    duelistTargetScreen.IgnoreGuiInset = true
    duelistTargetScreen.Enabled = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 1, -250)
    MainFrame.Size = UDim2.new(0, 322, 0, 147)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = duelistTargetScreen

    local MainUIScale = Instance.new("UIScale")
    MainUIScale.Scale = 1
    MainUIScale.Parent = MainFrame

    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.BackgroundTransparency = 1
    Glow.Image = "http://www.roblox.com/asset/?id=18245826428"
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
    Glow.ImageColor3 = cfg.TargetUIColor
    Glow.ImageTransparency = 0.85
    Glow.Position = UDim2.new(0, -20, 0, -20)
    Glow.Size = UDim2.new(1, 40, 1, 40)
    Glow.ZIndex = MainFrame.ZIndex - 1
    Glow.Parent = MainFrame

    local OuterBorder = Instance.new("Frame")
    OuterBorder.Name = "OuterBorder"
    OuterBorder.BackgroundColor3 = cfg.TargetUIColor
    OuterBorder.BorderSizePixel = 0
    OuterBorder.Position = UDim2.new(0, 1, 0, 1)
    OuterBorder.Size = UDim2.new(1, -2, 1, -2)
    OuterBorder.Parent = MainFrame

    local InnerBorder = Instance.new("Frame")
    InnerBorder.Name = "InnerBorder"
    InnerBorder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InnerBorder.BorderSizePixel = 0
    InnerBorder.Position = UDim2.new(0, 1, 0, 1)
    InnerBorder.Size = UDim2.new(1, -2, 1, -2)
    InnerBorder.Parent = OuterBorder

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 1, 0, 2)
    ContentFrame.Size = UDim2.new(1, -2, 1, -4)
    ContentFrame.Parent = InnerBorder

    local UIPadding_1 = Instance.new("UIPadding")
    UIPadding_1.PaddingLeft = UDim.new(0, 6)
    UIPadding_1.Parent = ContentFrame

    local Holder = Instance.new("Frame")
    Holder.Name = "Holder"
    Holder.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Holder.BorderSizePixel = 0
    Holder.Position = UDim2.new(0, -3, 0, 16)
    Holder.Size = UDim2.new(1, 0, 1, -18)
    Holder.Parent = ContentFrame

    local HolderInner1 = Instance.new("Frame")
    HolderInner1.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    HolderInner1.BorderSizePixel = 0
    HolderInner1.Position = UDim2.new(0, 1, 0, 1)
    HolderInner1.Size = UDim2.new(1, -2, 1, -2)
    HolderInner1.Parent = Holder

    local HolderInner2 = Instance.new("Frame")
    HolderInner2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HolderInner2.BorderSizePixel = 0
    HolderInner2.Position = UDim2.new(0, 1, 0, 1)
    HolderInner2.Size = UDim2.new(1, -2, 1, -2)
    HolderInner2.Parent = HolderInner1

    local UIPadding_2 = Instance.new("UIPadding")
    UIPadding_2.PaddingLeft = UDim.new(0, 4)
    UIPadding_2.PaddingTop = UDim.new(0, 4)
    UIPadding_2.Parent = HolderInner2

    local ContentArea = Instance.new("Frame")
    ContentArea.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    ContentArea.BorderSizePixel = 0
    ContentArea.Size = UDim2.new(1, -4, 1, -4)
    ContentArea.Parent = HolderInner2

    local ContentArea2 = Instance.new("Frame")
    ContentArea2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ContentArea2.BorderSizePixel = 0
    ContentArea2.Position = UDim2.new(0, 1, 0, 1)
    ContentArea2.Size = UDim2.new(1, -2, 1, -2)
    ContentArea2.Parent = ContentArea

    local ContentArea3 = Instance.new("Frame")
    ContentArea3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentArea3.BorderSizePixel = 0
    ContentArea3.Position = UDim2.new(0, 1, 0, 1)
    ContentArea3.Size = UDim2.new(1, -2, 1, -2)
    ContentArea3.Parent = ContentArea2

    local Gradient1 = Instance.new("UIGradient")
    Gradient1.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    Gradient1.Parent = ContentArea3

    local UIPadding_3 = Instance.new("UIPadding")
    UIPadding_3.PaddingBottom = UDim.new(0, 3)
    UIPadding_3.PaddingLeft = UDim.new(0, 4)
    UIPadding_3.PaddingRight = UDim.new(0, 3)
    UIPadding_3.PaddingTop = UDim.new(0, 4)
    UIPadding_3.Parent = ContentArea3

    local MainContent = Instance.new("Frame")
    MainContent.BackgroundTransparency = 1
    MainContent.BorderSizePixel = 0
    MainContent.Size = UDim2.new(1, 0, 1, 3)
    MainContent.Parent = ContentArea3

    local UIListLayout_1 = Instance.new("UIListLayout")
    UIListLayout_1.Padding = UDim.new(0, 4)
    UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_1.Parent = MainContent

    local UIPadding_4 = Instance.new("UIPadding")
    UIPadding_4.PaddingBottom = UDim.new(0, 4)
    UIPadding_4.Parent = MainContent

    local PlayerInfoContainer = Instance.new("Frame")
    PlayerInfoContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    PlayerInfoContainer.BorderSizePixel = 0
    PlayerInfoContainer.Size = UDim2.new(1, -1, 1, 0)
    PlayerInfoContainer.Parent = MainContent

    local PlayerInfoInner1 = Instance.new("Frame")
    PlayerInfoInner1.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    PlayerInfoInner1.BorderSizePixel = 0
    PlayerInfoInner1.Position = UDim2.new(0, 1, 0, 1)
    PlayerInfoInner1.Size = UDim2.new(1, -2, 1, -2)
    PlayerInfoInner1.Parent = PlayerInfoContainer

    local PlayerInfoInner2 = Instance.new("Frame")
    PlayerInfoInner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlayerInfoInner2.BorderSizePixel = 0
    PlayerInfoInner2.Position = UDim2.new(0, 1, 0, 1)
    PlayerInfoInner2.Size = UDim2.new(1, -2, 1, -2)
    PlayerInfoInner2.Parent = PlayerInfoInner1

    local Gradient2 = Instance.new("UIGradient")
    Gradient2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    Gradient2.Parent = PlayerInfoInner2

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = cfg.TargetUIColor
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    TopBar.Parent = PlayerInfoInner2

    local InfoHolder = Instance.new("Frame")
    InfoHolder.BackgroundTransparency = 1
    InfoHolder.BorderSizePixel = 0
    InfoHolder.Position = UDim2.new(0, 1, 0, 22)
    InfoHolder.Size = UDim2.new(1, -2, 1, -24)
    InfoHolder.Parent = PlayerInfoInner2

    local UIPadding_5 = Instance.new("UIPadding")
    UIPadding_5.PaddingBottom = UDim.new(0, 2)
    UIPadding_5.PaddingLeft = UDim.new(0, 3)
    UIPadding_5.PaddingRight = UDim.new(0, 3)
    UIPadding_5.PaddingTop = UDim.new(0, -1)
    UIPadding_5.Parent = InfoHolder

    local PlayerInfo = Instance.new("Frame")
    PlayerInfo.BackgroundTransparency = 1
    PlayerInfo.BorderSizePixel = 0
    PlayerInfo.Size = UDim2.new(1, 0, 1, 0)
    PlayerInfo.Parent = InfoHolder

    local IconFrame = Instance.new("Frame")
    IconFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    IconFrame.BorderSizePixel = 0
    IconFrame.Size = UDim2.new(0, 68, 1, 0)
    IconFrame.Parent = PlayerInfo

    local IconInner1 = Instance.new("Frame")
    IconInner1.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    IconInner1.BorderSizePixel = 0
    IconInner1.Position = UDim2.new(0, 1, 0, 1)
    IconInner1.Size = UDim2.new(1, -2, 1, -2)
    IconInner1.Parent = IconFrame

    local IconInner2 = Instance.new("Frame")
    IconInner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    IconInner2.BorderSizePixel = 0
    IconInner2.Position = UDim2.new(0, 1, 0, 1)
    IconInner2.Size = UDim2.new(1, -2, 1, -2)
    IconInner2.Parent = IconInner1

    local Gradient4 = Instance.new("UIGradient")
    Gradient4.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    Gradient4.Parent = IconInner2

    local PlayerIcon = Instance.new("ImageLabel")
    PlayerIcon.Name = "Avatar"
    PlayerIcon.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"
    PlayerIcon.BackgroundTransparency = 1
    PlayerIcon.BorderSizePixel = 0
    PlayerIcon.Size = UDim2.new(1, 0, 1, 0)
    PlayerIcon.Parent = IconInner2

    local HealthFrame = Instance.new("Frame")
    HealthFrame.AnchorPoint = Vector2.new(0, 1)
    HealthFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    HealthFrame.BorderSizePixel = 0
    HealthFrame.Position = UDim2.new(0, 72, 1, 0)
    HealthFrame.Size = UDim2.new(1, -72, 0, 14)
    HealthFrame.Parent = PlayerInfo

    local HealthInner1 = Instance.new("Frame")
    HealthInner1.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    HealthInner1.BorderSizePixel = 0
    HealthInner1.Position = UDim2.new(0, 1, 0, 1)
    HealthInner1.Size = UDim2.new(1, -2, 1, -2)
    HealthInner1.Parent = HealthFrame

    local HealthInner2 = Instance.new("Frame")
    HealthInner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HealthInner2.BorderSizePixel = 0
    HealthInner2.Position = UDim2.new(0, 1, 0, 1)
    HealthInner2.Size = UDim2.new(1, -2, 1, -2)
    HealthInner2.Parent = HealthInner1

    local Gradient5 = Instance.new("UIGradient")
    Gradient5.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    Gradient5.Parent = HealthInner2

    local HealthBarValue = Instance.new("Frame")
    HealthBarValue.Name = "HealthFill"
    HealthBarValue.BackgroundColor3 = Color3.fromRGB(45, 195, 45)
    HealthBarValue.BorderSizePixel = 0
    HealthBarValue.Size = UDim2.new(1, 0, 1, 0)
    HealthBarValue.Parent = HealthInner2

    local HealthBarGradient = Instance.new("UIGradient")
    HealthBarGradient.Rotation = 0
    HealthBarGradient.Color = makeGradient(
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 170, 0),
        Color3.fromRGB(255, 0, 0)
    )
    HealthBarGradient.Parent = HealthBarValue

    local HealthText = Instance.new("TextLabel")
    HealthText.Name = "HealthText"
    HealthText.Font = Enum.Font.SourceSans
    HealthText.Text = "100/100"
    HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthText.TextSize = 12
    HealthText.AnchorPoint = Vector2.new(0.5, 0.5)
    HealthText.BackgroundTransparency = 1
    HealthText.BorderSizePixel = 0
    HealthText.Position = UDim2.new(0.5, 0, 0.5, 0)
    HealthText.Size = UDim2.new(1, 0, 1, 0)
    HealthText.Parent = HealthInner2

    local InfoFrame = Instance.new("Frame")
    InfoFrame.BackgroundTransparency = 1
    InfoFrame.BorderSizePixel = 0
    InfoFrame.Position = UDim2.new(0.27, 0, 0.029, 0)
    InfoFrame.Size = UDim2.new(0, 198, 0, 31)
    InfoFrame.Parent = PlayerInfo

    local UIListLayout_2 = Instance.new("UIListLayout")
    UIListLayout_2.Padding = UDim.new(0, 2)
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.Parent = InfoFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "Name"
    NameLabel.Font = Enum.Font.SourceSans
    NameLabel.Text = "Player (@username)"
    NameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextYAlignment = Enum.TextYAlignment.Top
    NameLabel.BackgroundTransparency = 1
    NameLabel.BorderSizePixel = 0
    NameLabel.Size = UDim2.new(0.39, 0, 0.42, 0)
    NameLabel.Parent = InfoFrame

    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "Distance"
    DistanceLabel.Font = Enum.Font.SourceSans
    DistanceLabel.Text = "0 studs"
    DistanceLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    DistanceLabel.TextSize = 12
    DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    DistanceLabel.TextYAlignment = Enum.TextYAlignment.Top
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.BorderSizePixel = 0
    DistanceLabel.Size = UDim2.new(0.39, 0, 0.42, 0)
    DistanceLabel.Parent = InfoFrame

    local AmmoFrame = Instance.new("Frame")
    AmmoFrame.Name = "AmmoBack"
    AmmoFrame.AnchorPoint = Vector2.new(0, 1)
    AmmoFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    AmmoFrame.BorderSizePixel = 0
    AmmoFrame.Position = UDim2.new(0, 72, 0.794, 0)
    AmmoFrame.Size = UDim2.new(1, -72, 0, 14)
    AmmoFrame.Visible = false
    AmmoFrame.Parent = PlayerInfo

    local AmmoInner1 = Instance.new("Frame")
    AmmoInner1.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    AmmoInner1.BorderSizePixel = 0
    AmmoInner1.Position = UDim2.new(0, 1, 0, 1)
    AmmoInner1.Size = UDim2.new(1, -2, 1, -2)
    AmmoInner1.Parent = AmmoFrame

    local AmmoInner2 = Instance.new("Frame")
    AmmoInner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AmmoInner2.BorderSizePixel = 0
    AmmoInner2.Position = UDim2.new(0, 1, 0, 1)
    AmmoInner2.Size = UDim2.new(1, -2, 1, -2)
    AmmoInner2.Parent = AmmoInner1

    local Gradient6 = Instance.new("UIGradient")
    Gradient6.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }
    Gradient6.Parent = AmmoInner2

    local AmmoBarValue = Instance.new("Frame")
    AmmoBarValue.Name = "AmmoFill"
    AmmoBarValue.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    AmmoBarValue.BorderSizePixel = 0
    AmmoBarValue.Size = UDim2.new(1, 0, 1, 0)
    AmmoBarValue.Parent = AmmoInner2

    local AmmoBarGradient = Instance.new("UIGradient")
    AmmoBarGradient.Rotation = 0
    AmmoBarGradient.Color = makeGradient(
        Color3.fromRGB(255, 140, 0),
        Color3.fromRGB(255, 85, 0),
        Color3.fromRGB(255, 0, 0)
    )
    AmmoBarGradient.Parent = AmmoBarValue

    local AmmoText = Instance.new("TextLabel")
    AmmoText.Name = "AmmoText"
    AmmoText.Font = Enum.Font.SourceSans
    AmmoText.Text = "0/0"
    AmmoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    AmmoText.TextSize = 12
    AmmoText.AnchorPoint = Vector2.new(0.5, 0.5)
    AmmoText.BackgroundTransparency = 1
    AmmoText.BorderSizePixel = 0
    AmmoText.Position = UDim2.new(0.5, 0, 0.5, 0)
    AmmoText.Size = UDim2.new(1, 0, 1, 0)
    AmmoText.Parent = AmmoInner2

    local TopLabel1Parent = Instance.new("Frame")
    TopLabel1Parent.BackgroundTransparency = 1
    TopLabel1Parent.BorderSizePixel = 0
    TopLabel1Parent.Position = UDim2.new(0, 0, 0, 2)
    TopLabel1Parent.Size = UDim2.new(1, 0, 0, 20)
    TopLabel1Parent.Parent = PlayerInfoInner2

    local TopLabel1 = Instance.new("TextLabel")
    TopLabel1.Font = Enum.Font.SourceSans
    TopLabel1.Text = "Info"
    TopLabel1.TextColor3 = Color3.fromRGB(136, 136, 136)
    TopLabel1.TextSize = 12
    TopLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TopLabel1.BackgroundTransparency = 1
    TopLabel1.BorderSizePixel = 0
    TopLabel1.Size = UDim2.new(1, 0, 1, 0)
    TopLabel1.Parent = TopLabel1Parent

    local TopLabel2Parent = Instance.new("Frame")
    TopLabel2Parent.BackgroundTransparency = 1
    TopLabel2Parent.BorderSizePixel = 0
    TopLabel2Parent.Size = UDim2.new(1, -4, 0, 20)
    TopLabel2Parent.Parent = ContentFrame

    local TopLabel2 = Instance.new("TextLabel")
    TopLabel2.Font = Enum.Font.SourceSans
    TopLabel2.Text = "Indicator"
    TopLabel2.TextColor3 = Color3.fromRGB(180, 180, 180)
    TopLabel2.TextSize = 12
    TopLabel2.TextXAlignment = Enum.TextXAlignment.Left
    TopLabel2.BackgroundTransparency = 1
    TopLabel2.BorderSizePixel = 0
    TopLabel2.Size = UDim2.new(0.5, 0, 1, 0)
    TopLabel2.Parent = TopLabel2Parent

    duelistTargetMain = MainFrame
    duelistTargetElements = {
        Main = MainFrame,
        UIScale = MainUIScale,
        Glow = Glow,
        OuterBorder = OuterBorder,
        TopBar = TopBar,
        Avatar = PlayerIcon,
        Name = NameLabel,
        Distance = DistanceLabel,
        HealthFill = HealthBarValue,
        HealthText = HealthText,
        AmmoBack = AmmoFrame,
        AmmoFill = AmmoBarValue,
        AmmoText = AmmoText,
    }
end

local function updateTargetHighlight(targetInfo)
    if duelistTargetHighlight then
        pcall(function() duelistTargetHighlight:Destroy() end)
        duelistTargetHighlight = nil
    end
    if not cfg.TargetHighlightEnabled then return end
    if not targetInfo or not targetInfo.Model then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EvolutionTargetHighlight"
    highlight.Parent = cloneref(game:GetService("CoreGui"))
    highlight.Adornee = targetInfo.Model
    highlight.FillColor = cfg.TargetHighlightFill
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = cfg.TargetHighlightOutline
    highlight.OutlineTransparency = 0
    duelistTargetHighlight = highlight
end

local function ensureTargetTracer()
    if not duelistTargetTracer then
        duelistTargetTracer = Drawing.new("Line")
        duelistTargetTracer.Visible = false
        duelistTargetTracer.Thickness = 1.5
        duelistTargetTracer.Color = cfg.TargetTracerColor
        duelistTargetTracer.Transparency = 1
        duelistTargetTracer.ZIndex = 2

        duelistTargetTracerOutline = Drawing.new("Line")
        duelistTargetTracerOutline.Visible = false
        duelistTargetTracerOutline.Thickness = 3.5
        duelistTargetTracerOutline.Color = Color3.fromRGB(0, 0, 0)
        duelistTargetTracerOutline.Transparency = 1
        duelistTargetTracerOutline.ZIndex = 1
    end
end

trackConnection(RunService.RenderStepped:Connect(function()
    local targetInfo = getTargetPlayer()

    -- Target UI
    if cfg.TargetUIEnabled and targetInfo then
        createTargetUI()
        if duelistTargetScreen and duelistTargetElements.Avatar then
            duelistTargetScreen.Enabled = true

            if targetInfo.Player ~= lastDuelistTargetPlayer then
                duelistTargetElements.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetInfo.Player.UserId .. "&w=420&h=420"
                duelistTargetElements.Name.Text = targetInfo.Player.DisplayName .. " (@" .. targetInfo.Player.Name .. ")"
                lastDuelistTargetPlayer = targetInfo.Player
            end

            local hum = targetInfo.Model:FindFirstChildOfClass("Humanoid")
            if hum then
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                duelistTargetElements.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
                duelistTargetElements.HealthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            end

            local myChar = LocalPlayer.Character
            local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
            local targetRoot = targetInfo.Part
            if myRoot and targetRoot and targetRoot.Parent then
                local dist = (myRoot.Position - targetRoot.Position).Magnitude
                duelistTargetElements.Distance.Text = math.floor(dist) .. "m"
            else
                duelistTargetElements.Distance.Text = "N/A"
            end

            local ammo, maxAmmo = getTargetAmmo(targetInfo.Model)
            if maxAmmo > 0 then
                duelistTargetElements.AmmoBack.Visible = true
                local pct = math.clamp(ammo / maxAmmo, 0, 1)
                duelistTargetElements.AmmoFill.Size = UDim2.new(pct, 0, 1, 0)
                duelistTargetElements.AmmoText.Text = math.floor(ammo) .. "/" .. math.floor(maxAmmo)
            else
                duelistTargetElements.AmmoBack.Visible = false
            end

            if duelistTargetElements.OuterBorder then
                duelistTargetElements.OuterBorder.BackgroundColor3 = cfg.TargetUIColor
            end
            if duelistTargetElements.TopBar then
                duelistTargetElements.TopBar.BackgroundColor3 = cfg.TargetUIColor
            end
            if duelistTargetElements.Glow then
                duelistTargetElements.Glow.ImageColor3 = cfg.TargetUIColor
            end
        end
    else
        if duelistTargetScreen then duelistTargetScreen.Enabled = false end
        lastDuelistTargetPlayer = nil
    end

    -- Highlight
    if cfg.TargetHighlightEnabled and targetInfo then
        if not duelistTargetHighlight or duelistTargetHighlight.Adornee ~= targetInfo.Model then
            updateTargetHighlight(targetInfo)
        end
    else
        updateTargetHighlight(nil)
    end

    -- Tracer
    ensureTargetTracer()
    if cfg.TargetTracerEnabled and targetInfo and targetInfo.Part and targetInfo.Part.Parent then
        local targetPos = targetInfo.Part.Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        local viewportSize = Camera.ViewportSize
        local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        local endPos = Vector2.new(screenPos.X, screenPos.Y)
        if not onScreen then
            local dirX = screenPos.X - center.X
            local dirY = screenPos.Y - center.Y
            local mag = math.sqrt(dirX * dirX + dirY * dirY)
            if mag > 0 then
                dirX, dirY = dirX / mag, dirY / mag
                endPos = center + Vector2.new(dirX, dirY) * math.min(mag, math.min(viewportSize.X, viewportSize.Y) / 2 - 50)
            end
        end
        duelistTargetTracerOutline.From = center
        duelistTargetTracerOutline.To = endPos
        duelistTargetTracerOutline.Visible = true
        duelistTargetTracer.From = center
        duelistTargetTracer.To = endPos
        duelistTargetTracer.Color = cfg.TargetTracerColor
        duelistTargetTracer.Visible = true
    else
        if duelistTargetTracer then duelistTargetTracer.Visible = false end
        if duelistTargetTracerOutline then duelistTargetTracerOutline.Visible = false end
    end
end))

-- Auto-apply cosmetics and force them back if the server resets them.
local lastSkinTool = nil
local lastSkinApply = 0
local lastCardApply = 0
trackConnection(RunService.RenderStepped:Connect(function()
    if cfg.SkinChangerEnabled and cfg.AutoApplySkin then
        local tool = getEquippedGun()
        if tool then
            local skin = tool:FindFirstChild("Skin")
            local isRifle = tool.Name:lower():find("carabine") or tool.Name:lower():find("rifle")
            local key = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
            local tag = key and ((isRifle and "Carabine" or "Pistol") .. " / " .. key) or nil
            local wrongSkin = skin and skin:GetAttribute("EvolutionSkinKey") ~= tag
            local shouldApply = key and (not skin or wrongSkin)
            local shouldRemove = not key and skin
            if (shouldApply or shouldRemove) and tick() - lastSkinApply >= 0.05 then
                lastSkinApply = tick()
                applySelectedSkin()
            end
        end
        lastSkinTool = tool
    end

    if cfg.CardChangerEnabled and cfg.AutoApplyCard and cfg.SelectedCardKey then
        if tick() - lastCardApply >= 0.2 then
            lastCardApply = tick()
            local char = LocalPlayer.Character
            if not char or char:GetAttribute("EvolutionCardKey") ~= cfg.SelectedCardKey then
                applySelectedCard()
            end
        end
    end
end))

trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    lastSkinTool = nil
    task.wait(0.2)
    if cfg.SkinChangerEnabled and cfg.AutoApplySkin then
        applySelectedSkin()
    end
    if cfg.CardChangerEnabled and cfg.AutoApplyCard and cfg.SelectedCardKey then
        applySelectedCard()
    end
end))

task.delay(2, function()
    refreshSkinList()
    refreshCardList()
end)

print('[evolution] Duelist module loaded')
