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
local CombatTarget = Combat:Section({ Name = "Target Indicator", Side = 1 })

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

-- Target Indicator
local TargetUIToggle = CombatTarget:Toggle({
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
    CombatTarget:Colorpicker({
        Name = "UI Color",
        Default = cfg.TargetUIColor,
        Flag = "Duelist_TargetUIColor",
        Callback = function(Value) cfg.TargetUIColor = Value end
    })
end

local HighlightToggle = CombatTarget:Toggle({
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
    CombatTarget:Colorpicker({
        Name = "Fill Color",
        Default = cfg.TargetHighlightFill,
        Flag = "Duelist_TargetHighlightFill",
        Callback = function(Value) cfg.TargetHighlightFill = Value end
    })
    CombatTarget:Colorpicker({
        Name = "Outline Color",
        Default = cfg.TargetHighlightOutline,
        Flag = "Duelist_TargetHighlightOutline",
        Callback = function(Value) cfg.TargetHighlightOutline = Value end
    })
end

local TracerToggle = CombatTarget:Toggle({
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
    CombatTarget:Colorpicker({
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

local duelistTargetScreen = nil
local duelistTargetMain = nil
local duelistTargetElements = {}
local duelistTargetHighlight = nil
local duelistTargetTracer = nil
local duelistTargetTracerOutline = nil
local lastDuelistTargetPlayer = nil

local function createTargetUI()
    if duelistTargetScreen then return end
    duelistTargetScreen = Instance.new("ScreenGui")
    duelistTargetScreen.Name = "EvolutionTargetUI"
    duelistTargetScreen.Parent = cloneref(game:GetService("CoreGui"))
    duelistTargetScreen.ResetOnSpawn = false
    duelistTargetScreen.DisplayOrder = 9998
    duelistTargetScreen.IgnoreGuiInset = true
    duelistTargetScreen.Enabled = false

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.5, 0, 1, -160)
    main.Size = UDim2.new(0, 300, 0, 120)
    main.Active = true
    main.Draggable = true
    main.Parent = duelistTargetScreen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Name = "Border"
    stroke.Color = cfg.TargetUIColor
    stroke.Thickness = 1
    stroke.Parent = main

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = cfg.TargetUIColor
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.Parent = main

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 8, 0, 11)
    content.Size = UDim2.new(1, -16, 1, -19)
    content.Parent = main

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    avatar.BorderSizePixel = 0
    avatar.Size = UDim2.new(0, 70, 1, 0)
    avatar.ScaleType = Enum.ScaleType.Fit
    avatar.Parent = content

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 4)
    avatarCorner.Parent = avatar

    local info = Instance.new("Frame")
    info.Name = "Info"
    info.BackgroundTransparency = 1
    info.Position = UDim2.new(0, 78, 0, 0)
    info.Size = UDim2.new(1, -78, 1, 0)
    info.Parent = content

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Font = Enum.Font.SourceSansSemibold
    nameLabel.Text = "Player (@player)"
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Parent = info

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.Font = Enum.Font.SourceSans
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    distLabel.TextSize = 12
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.BackgroundTransparency = 1
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Parent = info

    local healthBack = Instance.new("Frame")
    healthBack.Name = "HealthBack"
    healthBack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    healthBack.BorderSizePixel = 0
    healthBack.Position = UDim2.new(0, 0, 0, 42)
    healthBack.Size = UDim2.new(1, 0, 0, 16)
    healthBack.Parent = info

    local healthBackCorner = Instance.new("UICorner")
    healthBackCorner.CornerRadius = UDim.new(0, 3)
    healthBackCorner.Parent = healthBack

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    healthFill.BorderSizePixel = 0
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Parent = healthBack

    local healthFillCorner = Instance.new("UICorner")
    healthFillCorner.CornerRadius = UDim.new(0, 3)
    healthFillCorner.Parent = healthFill

    local healthGradient = Instance.new("UIGradient")
    healthGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    healthGradient.Parent = healthFill

    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Font = Enum.Font.SourceSans
    healthText.Text = "100/100"
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 11
    healthText.BackgroundTransparency = 1
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.Parent = healthBack

    local ammoBack = Instance.new("Frame")
    ammoBack.Name = "AmmoBack"
    ammoBack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ammoBack.BorderSizePixel = 0
    ammoBack.Position = UDim2.new(0, 0, 0, 62)
    ammoBack.Size = UDim2.new(1, 0, 0, 14)
    ammoBack.Visible = false
    ammoBack.Parent = info

    local ammoBackCorner = Instance.new("UICorner")
    ammoBackCorner.CornerRadius = UDim.new(0, 3)
    ammoBackCorner.Parent = ammoBack

    local ammoFill = Instance.new("Frame")
    ammoFill.Name = "AmmoFill"
    ammoFill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    ammoFill.BorderSizePixel = 0
    ammoFill.Size = UDim2.new(1, 0, 1, 0)
    ammoFill.Parent = ammoBack

    local ammoFillCorner = Instance.new("UICorner")
    ammoFillCorner.CornerRadius = UDim.new(0, 3)
    ammoFillCorner.Parent = ammoFill

    local ammoText = Instance.new("TextLabel")
    ammoText.Name = "AmmoText"
    ammoText.Font = Enum.Font.SourceSans
    ammoText.Text = "0/0"
    ammoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ammoText.TextSize = 11
    ammoText.BackgroundTransparency = 1
    ammoText.Size = UDim2.new(1, 0, 1, 0)
    ammoText.Parent = ammoBack

    duelistTargetMain = main
    duelistTargetElements = {
        Main = main,
        Border = stroke,
        TopBar = topBar,
        Avatar = avatar,
        Name = nameLabel,
        Distance = distLabel,
        HealthBack = healthBack,
        HealthFill = healthFill,
        HealthText = healthText,
        AmmoBack = ammoBack,
        AmmoFill = ammoFill,
        AmmoText = ammoText,
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

            duelistTargetElements.Border.Color = cfg.TargetUIColor
            duelistTargetElements.TopBar.BackgroundColor3 = cfg.TargetUIColor
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
