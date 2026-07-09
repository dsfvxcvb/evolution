-- ============================================================
-- evolution | DUELIST: PvP
-- Silent aim + bullet manipulation via workspace.Raycast hook.
-- ============================================================



local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local Lighting = cloneref(game:GetService("Lighting"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local Debris = cloneref(game:GetService("Debris"))
local TweenService = cloneref(game:GetService("TweenService"))

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
local duelistTargetScreen, duelistTargetMain, duelistTargetElements, duelistTargetHighlight, duelistTargetTracer, duelistTargetTracerOutline, lastDuelistTargetPlayer, currentTargetUIStyle
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
    pcall(function() RunService:UnbindFromRenderStep("EvolutionAimAssist") end)
    pcall(cleanupWeather)
    local rfOrigs = getgenv().EvolutionDuelistRapidFireOriginals
    if rfOrigs then
        for tool, orig in pairs(rfOrigs) do
            pcall(function()
                tool:SetAttribute("FireRate", orig.FireRate)
                tool:SetAttribute("Automatic", orig.Automatic)
                tool:SetAttribute("Recoil", orig.Recoil)
                tool:SetAttribute("Spread", orig.Spread)
            end)
        end
        table.clear(rfOrigs)
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
    RapidFire = false,
    NoRecoil = false,
    ShootInLobby = false,
    WallCheck = true,
    KOCheck = false,
    TargetShootEnabled = false,
    TeamCheck = true,
    Hitchance = 100,
    MaxDistance = 1000,
    HitPart = 'Head',

    AimAssistEnabled = false,
    AimAssistSmoothing = 0.1,
    AimAssistPrediction = 0.1,
    AimAssistHitPart = 'Head',
    AimAssistKey = Enum.KeyCode.Q,
    AimAssistUseFOV = true,
    AimAssistPauseOnTool = true,

    SkyboxChangerEnabled = false,
    SelectedSkybox = "Galaxy",

    LightingChangerEnabled = false,
    LightingTimeOfDay = Lighting.ClockTime,
    LightingBrightness = Lighting.Brightness,
    LightingAmbient = Lighting.Ambient,
    LightingOutdoorAmbient = Lighting.OutdoorAmbient,
    LightingColorCorrectionEnabled = false,
    LightingColorCorrectionTint = Color3.fromRGB(255, 255, 255),
    LightingColorCorrectionSaturation = 0,
    LightingColorCorrectionContrast = 0,
    LightingAtmosphereDensity = 0.32,
    LightingAtmosphereHaze = 2.03,
    LightingAtmosphereColor = Color3.fromRGB(198, 198, 198),

    WeatherEnabled = false,
    WeatherType = "rain",
    WeatherColor = Color3.fromRGB(255, 255, 255),
    WeatherRate = 100,

    TriggerbotEnabled = false,
    TriggerbotDelay = 0.05,
    TriggerbotCooldown = 0.2,
    TriggerbotTeamCheck = true,
    TriggerbotTargetOrb = false,

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
    EspTeamCheck = true,
    EspMaxDistance = 2000,
    EspTextSize = 13,

    EspBoxStyle = "Box",
    EspBoxColor = Color3.fromRGB(255, 255, 255),
    EspBoxOutline = true,
    EspBoxOutlineColor = Color3.fromRGB(0, 0, 0),
    EspBoxFilled = false,
    EspBoxFillTransparency = 0.5,
    EspBoxThickness = 1,

    EspSkeleton = false,
    EspSkeletonColor = Color3.fromRGB(255, 255, 255),
    EspSkeletonThickness = 1,

    EspHealthBar = true,
    EspHealthText = true,
    EspHealthColor = Color3.fromRGB(0, 255, 0),

    EspHeadDot = false,
    EspHeadDotColor = Color3.fromRGB(255, 255, 255),
    EspHeadDotSize = 4,

    EspSnaplines = false,
    EspSnaplineColor = Color3.fromRGB(255, 255, 255),
    EspSnaplineThickness = 1,

    EspNames = true,
    EspNameColor = Color3.fromRGB(255, 255, 255),
    EspDistance = true,
    EspDistanceColor = Color3.fromRGB(255, 255, 255),

    SkinChangerEnabled = false,
    AutoApplySkin = true,
    SelectedPistolSkinKey = nil,
    SelectedRifleSkinKey = nil,
    CardChangerEnabled = false,
    AutoApplyCard = true,
    SelectedCardKey = nil,

    BackpackChangerEnabled = false,
    SelectedBackpack = "Black",

    KillFXChangerEnabled = false,
    SelectedKillFX = "None",

    LocalBulletTracerEnabled = false,
    LocalBulletTracerColor = Color3.fromRGB(255, 0, 0),
    LocalBulletTracerLifetime = 1,
    LocalBulletTracerFadeOut = false,

    OtherBulletTracerEnabled = false,
    OtherBulletTracerColor = Color3.fromRGB(255, 0, 0),
    OtherBulletTracerLifetime = 1,
    OtherBulletTracerFadeOut = false,

    TargetUIColor = Color3.fromRGB(0, 170, 255),
    TargetUIGlowColor = Color3.fromRGB(0, 170, 255),
    TargetUIUseGlow = true,
    TargetUIStyle = "Old",
    TargetUIPosition = "Free",
    TargetHighlightEnabled = false,
    TargetHighlightFill = Color3.fromRGB(0, 170, 255),
    TargetHighlightOutline = Color3.fromRGB(255, 255, 255),
    TargetTracerEnabled = false,
    TargetTracerColor = Color3.fromRGB(0, 170, 255),
    TargetTracerOutlineColor = Color3.fromRGB(0, 0, 0),
    TargetTracerThickness = 2,
    TargetTracerOutlineThickness = 4,

    DuelBotEnabled = false,
    DuelBotMode = "Winner",
    DuelBotOpponent = "",
    DuelBotAutoKill = false,
    DuelBotWalkSpeed = 64,
    DuelBotTpWalk = 0,
}
local cfg = getgenv().EvolutionDuelist

-- Bullet tracer source tracking
local localTracerActiveUntil = 0

-- Aim assist lock state
local aimAssistLockedModel = nil
local aimAssistLockedPart = nil
local aimAssistCurrentCF = nil
local aimAssistLockOnce = false

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

pcall(function() Arcane:SetTheme("Ocean") end)

-- Pages
local Main = Window:Page({ Name = "Main", Icon = "home" })
local Settings = Window:Page({ Name = "Settings", Icon = "settings" })

-- Subpages
local Combat = Main:SubPage({ Name = "Combat", Icon = "swords" })
local Visuals = Main:SubPage({ Name = "Combat Visuals", Icon = "eye" })
local Cosmetic = Main:SubPage({ Name = "Cosmetic", Icon = "shirt" })
local ConfigSub = Settings:SubPage({ Name = "Configs", Icon = "save" })

-- Sections
local CombatLeft = Combat:Section({ Name = "Aimbot", Side = 1 })
local CombatChecks = Combat:Section({ Name = "Checks", Side = 1 })
local CombatAimAssist = Combat:Section({ Name = "Aim Assist", Side = 2 })
local CombatTriggerbot = Combat:Section({ Name = "Triggerbot", Side = 2 })
local CombatGunMods = Combat:Section({ Name = "Gun Mods", Side = 2 })

local VisualsLeft = Visuals:Section({ Name = "FOV Circle", Side = 1 })
local VisualsTargetUI = Visuals:Section({ Name = "Target UI", Side = 2 })
local VisualsHighlight = Visuals:Section({ Name = "Highlight", Side = 2 })
local VisualsTracer = Visuals:Section({ Name = "Tracer", Side = 2 })

local World = Main:SubPage({ Name = "World", Icon = "globe" })
local WorldLighting = World:Section({ Name = "Lighting", Side = 1 })
local WorldLeft = World:Section({ Name = "Skyboxes", Side = 1 })
local WorldRight = World:Section({ Name = "ESP", Side = 2 })

-- Build skybox list from the game's assets.
local SkyboxFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Skies")
local SkyboxOptions = {}
if SkyboxFolder then
    for _, sky in ipairs(SkyboxFolder:GetChildren()) do
        if sky:IsA("Sky") then
            table.insert(SkyboxOptions, sky.Name)
        end
    end
end
table.sort(SkyboxOptions)

WorldLighting:Toggle({
    Name = "Lighting Changer",
    Default = cfg.LightingChangerEnabled,
    Flag = "Duelist_LightingChangerEnabled",
    Callback = function(State) cfg.LightingChangerEnabled = State end
})

WorldLighting:Slider({
    Name = "Time of Day",
    Min = 0,
    Max = 24,
    Default = cfg.LightingTimeOfDay,
    Decimals = 0.01,
    Flag = "Duelist_LightingTimeOfDay",
    Callback = function(Value) cfg.LightingTimeOfDay = Value end
})

WorldLighting:Slider({
    Name = "Brightness",
    Min = 0,
    Max = 10,
    Default = cfg.LightingBrightness,
    Decimals = 0.01,
    Flag = "Duelist_LightingBrightness",
    Callback = function(Value) cfg.LightingBrightness = Value end
})

WorldLighting:Colorpicker({
    Name = "Ambient",
    Default = cfg.LightingAmbient,
    Flag = "Duelist_LightingAmbient",
    Callback = function(Value) cfg.LightingAmbient = Value end
})

WorldLighting:Colorpicker({
    Name = "Outdoor Ambient",
    Default = cfg.LightingOutdoorAmbient,
    Flag = "Duelist_LightingOutdoorAmbient",
    Callback = function(Value) cfg.LightingOutdoorAmbient = Value end
})

WorldLighting:Toggle({
    Name = "Color Correction",
    Default = cfg.LightingColorCorrectionEnabled,
    Flag = "Duelist_LightingColorCorrectionEnabled",
    Callback = function(State) cfg.LightingColorCorrectionEnabled = State end
})

WorldLighting:Colorpicker({
    Name = "CC Tint",
    Default = cfg.LightingColorCorrectionTint,
    Flag = "Duelist_LightingColorCorrectionTint",
    Callback = function(Value) cfg.LightingColorCorrectionTint = Value end
})

WorldLighting:Slider({
    Name = "CC Saturation",
    Min = -1,
    Max = 1,
    Default = cfg.LightingColorCorrectionSaturation,
    Decimals = 0.01,
    Flag = "Duelist_LightingColorCorrectionSaturation",
    Callback = function(Value) cfg.LightingColorCorrectionSaturation = Value end
})

WorldLighting:Slider({
    Name = "CC Contrast",
    Min = -1,
    Max = 1,
    Default = cfg.LightingColorCorrectionContrast,
    Decimals = 0.01,
    Flag = "Duelist_LightingColorCorrectionContrast",
    Callback = function(Value) cfg.LightingColorCorrectionContrast = Value end
})

WorldLighting:Slider({
    Name = "Atmosphere Density",
    Min = 0,
    Max = 1,
    Default = cfg.LightingAtmosphereDensity,
    Decimals = 0.01,
    Flag = "Duelist_LightingAtmosphereDensity",
    Callback = function(Value) cfg.LightingAtmosphereDensity = Value end
})

WorldLighting:Slider({
    Name = "Atmosphere Haze",
    Min = 0,
    Max = 10,
    Default = cfg.LightingAtmosphereHaze,
    Decimals = 0.01,
    Flag = "Duelist_LightingAtmosphereHaze",
    Callback = function(Value) cfg.LightingAtmosphereHaze = Value end
})

WorldLighting:Colorpicker({
    Name = "Atmosphere Color",
    Default = cfg.LightingAtmosphereColor,
    Flag = "Duelist_LightingAtmosphereColor",
    Callback = function(Value) cfg.LightingAtmosphereColor = Value end
})

WorldLeft:Toggle({
    Name = "Skybox Changer",
    Default = cfg.SkyboxChangerEnabled,
    Flag = "Duelist_SkyboxChangerEnabled",
    Callback = function(State) cfg.SkyboxChangerEnabled = State end
})

WorldLeft:Dropdown({
    Name = "Skybox",
    Items = SkyboxOptions,
    Default = cfg.SelectedSkybox,
    Flag = "Duelist_SelectedSkybox",
    Callback = function(Value) cfg.SelectedSkybox = Value end
})

local WorldWeather = World:Section({ Name = "Weather", Side = 1 })

WorldWeather:Toggle({
    Name = "Weather",
    Default = cfg.WeatherEnabled,
    Flag = "Duelist_WeatherEnabled",
    Callback = function(State) cfg.WeatherEnabled = State end
})

WorldWeather:Colorpicker({
    Name = "Weather Color",
    Default = cfg.WeatherColor,
    Flag = "Duelist_WeatherColor",
    Callback = function(Value) cfg.WeatherColor = Value end
})

WorldWeather:Dropdown({
    Name = "Weather Type",
    Items = {"light rain", "rain", "snow"},
    Default = cfg.WeatherType,
    Flag = "Duelist_WeatherType",
    Callback = function(Value) cfg.WeatherType = Value end
})

WorldWeather:Slider({
    Name = "Weather Rate",
    Min = 1,
    Max = 100,
    Default = cfg.WeatherRate,
    Decimals = 1,
    Flag = "Duelist_WeatherRate",
    Callback = function(Value) cfg.WeatherRate = math.floor(Value + 0.5) end
})

local PlayerLeft = Cosmetic:Section({ Name = "Gun Skins", Side = 1 })
local PlayerLocalTracers = Cosmetic:Section({ Name = "Local Bullet Tracers", Side = 1 })
local PlayerOtherTracers = Cosmetic:Section({ Name = "Other Bullet Tracers", Side = 1 })
local PlayerRight = Cosmetic:Section({ Name = "Player Card", Side = 2 })
local PlayerKillFX = Cosmetic:Section({ Name = "KillFX Changer", Side = 2 })
local PlayerBackpack = Cosmetic:Section({ Name = "Backpack Changer", Side = 2 })

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
    Name = "Orb Target",
    Default = cfg.TargetShootEnabled,
    Flag = "Duelist_TargetShoot",
    Callback = function(State) cfg.TargetShootEnabled = State end
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

-- Checks
CombatChecks:Toggle({
    Name = "Wall Check",
    Default = cfg.WallCheck,
    Flag = "Duelist_WallCheck",
    Callback = function(State) cfg.WallCheck = State end
})

CombatChecks:Toggle({
    Name = "KO Check",
    Default = cfg.KOCheck,
    Flag = "Duelist_KOCheck",
    Callback = function(State) cfg.KOCheck = State end
})

-- 1v1 Bot UI (wrapped in do/end to keep its locals out of the top-level register count)
do
    local DuelBotSection = Main:SubPage({ Name = "1v1 Bot", Icon = "users" }):Section({ Name = "Duel Bot", Side = 1 })
    local DuelBotOpponentDropdown = nil

    local function getDuelBotPlayerOptions()
        local options = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(options, plr.Name)
            end
        end
        table.sort(options)
        return options
    end

    local function refreshDuelBotOpponentDropdown()
        if not DuelBotOpponentDropdown then return end
        local options = getDuelBotPlayerOptions()
        pcall(function() DuelBotOpponentDropdown:SetItems(options) end)
        pcall(function() DuelBotOpponentDropdown:Refresh(options) end)
        if cfg.DuelBotOpponent ~= "" and not table.find(options, cfg.DuelBotOpponent) then
            cfg.DuelBotOpponent = ""
        end
    end

    DuelBotSection:Dropdown({
        Name = "Mode",
        Items = { "Winner", "Loser" },
        Default = cfg.DuelBotMode,
        Flag = "Duelist_DuelBotMode",
        Callback = function(Value) cfg.DuelBotMode = Value end
    })

    DuelBotOpponentDropdown = DuelBotSection:Dropdown({
        Name = "Opponent",
        Items = getDuelBotPlayerOptions(),
        Default = cfg.DuelBotOpponent,
        Flag = "Duelist_DuelBotOpponent",
        Callback = function(Value) cfg.DuelBotOpponent = Value end
    })

    DuelBotSection:Slider({
        Name = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = cfg.DuelBotWalkSpeed,
        Flag = "Duelist_DuelBotWalkSpeed",
        Callback = function(Value) cfg.DuelBotWalkSpeed = Value end
    })

    DuelBotSection:Slider({
        Name = "TP Walk Step",
        Min = 0,
        Max = 10,
        Default = cfg.DuelBotTpWalk,
        Flag = "Duelist_DuelBotTpWalk",
        Callback = function(Value) cfg.DuelBotTpWalk = Value end
    })

    DuelBotSection:Toggle({
        Name = "Auto Kill",
        Default = cfg.DuelBotAutoKill,
        Flag = "Duelist_DuelBotAutoKill",
        Callback = function(State) cfg.DuelBotAutoKill = State end
    })

    local DuelBotURL = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/duelist_1v1_bot.lua"

    local function applyDuelBotAutoKill()
        if not cfg.DuelBotAutoKill then return end
        cfg.SilentAimEnabled = true
        cfg.AutoFire = true
        cfg.WallCheck = false
        cfg.TeamCheck = false
        cfg.HitPart = "Head"
        cfg.Hitchance = 100
        cfg.MaxDistance = 5000
        cfg.RapidFire = true
    end

    DuelBotSection:Toggle({
        Name = "Enable Bot",
        Default = cfg.DuelBotEnabled,
        Flag = "Duelist_DuelBotEnabled",
        Callback = function(State)
            cfg.DuelBotEnabled = State
            if State then
                if cfg.DuelBotOpponent == "" then
                    cfg.DuelBotEnabled = false
                    print("[Evolution] Select an opponent before enabling the 1v1 bot.")
                    return
                end
                applyDuelBotAutoKill()
                getgenv().DuelBotMode = cfg.DuelBotMode
                getgenv().DuelBotOpponent = cfg.DuelBotOpponent
                getgenv().DuelBotWalkSpeed = cfg.DuelBotWalkSpeed
                getgenv().DuelBotTpWalk = cfg.DuelBotTpWalk
                getgenv().DuelBotAutoKill = cfg.DuelBotAutoKill
                getgenv().DuelBotEnabled = true
                getgenv().DuelBotStop = false
                task.spawn(function()
                    loadstring(game:HttpGet(DuelBotURL))()
                end)
            else
                getgenv().DuelBotEnabled = false
                getgenv().DuelBotStop = true
            end
        end
    })

    trackConnection(Players.PlayerAdded:Connect(refreshDuelBotOpponentDropdown))
    trackConnection(Players.PlayerRemoving:Connect(refreshDuelBotOpponentDropdown))
end

-- Aim Assist
local AimAssistToggle = CombatAimAssist:Toggle({
    Name = "Aim Assist",
    Default = cfg.AimAssistEnabled,
    Flag = "Duelist_AimAssist",
    Callback = function(State) cfg.AimAssistEnabled = State end
})

pcall(function()
    AimAssistToggle:Keybind({
        Name = "Aim Assist Key",
        Default = cfg.AimAssistKey or Enum.KeyCode.Q,
        Mode = "Toggle",
        Flag = "Duelist_AimAssistKey",
        Callback = function(Value)
            if typeof(Value) == "EnumItem" then
                cfg.AimAssistKey = Value
            end
        end
    })
end)

CombatAimAssist:Slider({
    Name = "Smoothing",
    Min = 0.01,
    Max = 1,
    Default = cfg.AimAssistSmoothing,
    Decimals = 0.01,
    Flag = "Duelist_AimAssistSmoothing",
    Callback = function(Value) cfg.AimAssistSmoothing = Value end
})

CombatAimAssist:Slider({
    Name = "Prediction",
    Min = 0,
    Max = 1,
    Default = cfg.AimAssistPrediction,
    Decimals = 0.01,
    Flag = "Duelist_AimAssistPrediction",
    Callback = function(Value) cfg.AimAssistPrediction = Value end
})

CombatAimAssist:Dropdown({
    Name = "Aim Part",
    Items = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = cfg.AimAssistHitPart,
    Flag = "Duelist_AimAssistHitPart",
    Callback = function(Value) cfg.AimAssistHitPart = Value end
})

CombatAimAssist:Toggle({
    Name = "Use FOV",
    Default = cfg.AimAssistUseFOV,
    Flag = "Duelist_AimAssistUseFOV",
    Callback = function(State) cfg.AimAssistUseFOV = State end
})

CombatAimAssist:Toggle({
    Name = "Pause on Gun",
    Default = cfg.AimAssistPauseOnTool,
    Flag = "Duelist_AimAssistPauseOnTool",
    Callback = function(State) cfg.AimAssistPauseOnTool = State end
})

-- Triggerbot
CombatTriggerbot:Toggle({
    Name = "Triggerbot",
    Default = cfg.TriggerbotEnabled,
    Flag = "Duelist_TriggerbotEnabled",
    Callback = function(State) cfg.TriggerbotEnabled = State end
})

CombatTriggerbot:Toggle({
    Name = "Team Check",
    Default = cfg.TriggerbotTeamCheck,
    Flag = "Duelist_TriggerbotTeamCheck",
    Callback = function(State) cfg.TriggerbotTeamCheck = State end
})

CombatTriggerbot:Toggle({
    Name = "Target Orb",
    Default = cfg.TriggerbotTargetOrb,
    Flag = "Duelist_TriggerbotTargetOrb",
    Callback = function(State) cfg.TriggerbotTargetOrb = State end
})

CombatTriggerbot:Slider({
    Name = "Delay",
    Min = 0,
    Max = 0.5,
    Default = cfg.TriggerbotDelay,
    Decimals = 0.01,
    Suffix = "s",
    Flag = "Duelist_TriggerbotDelay",
    Callback = function(Value) cfg.TriggerbotDelay = Value end
})

CombatTriggerbot:Slider({
    Name = "Cooldown",
    Min = 0,
    Max = 1,
    Default = cfg.TriggerbotCooldown,
    Decimals = 0.01,
    Suffix = "s",
    Flag = "Duelist_TriggerbotCooldown",
    Callback = function(Value) cfg.TriggerbotCooldown = Value end
})

-- Gun Mods
CombatGunMods:Toggle({
    Name = "Rapid Fire",
    Default = cfg.RapidFire,
    Flag = "Duelist_RapidFire",
    Callback = function(State) cfg.RapidFire = State end
})

CombatGunMods:Toggle({
    Name = "No Recoil",
    Default = cfg.NoRecoil,
    Flag = "Duelist_NoRecoil",
    Callback = function(State) cfg.NoRecoil = State end
})

CombatGunMods:Toggle({
    Name = "Shoot In Lobby",
    Default = cfg.ShootInLobby,
    Flag = "Duelist_ShootInLobby",
    Callback = function(State) cfg.ShootInLobby = State end
})

-- Target UI
local TargetUIToggle = VisualsTargetUI:Toggle({
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
    VisualsTargetUI:Colorpicker({
        Name = "UI Color",
        Default = cfg.TargetUIColor,
        Flag = "Duelist_TargetUIColor",
        Callback = function(Value) cfg.TargetUIColor = Value end
    })
end

local UseGlowToggle = VisualsTargetUI:Toggle({
    Name = "Use Glow",
    Default = cfg.TargetUIUseGlow,
    Flag = "Duelist_TargetUIUseGlow",
    Callback = function(State) cfg.TargetUIUseGlow = State end
})
local glowColorChained = pcall(function()
    UseGlowToggle:Colorpicker({
        Name = "",
        Default = cfg.TargetUIGlowColor,
        Flag = "Duelist_TargetUIGlowColor",
        Callback = function(Value) cfg.TargetUIGlowColor = Value end
    })
end)
if not glowColorChained then
    VisualsTargetUI:Colorpicker({
        Name = "Glow Color",
        Default = cfg.TargetUIGlowColor,
        Flag = "Duelist_TargetUIGlowColor",
        Callback = function(Value) cfg.TargetUIGlowColor = Value end
    })
end

VisualsTargetUI:Dropdown({
    Name = "Style",
    Items = { "Old", "Modern" },
    Default = cfg.TargetUIStyle,
    Flag = "Duelist_TargetUIStyle",
    Callback = function(Value)
        cfg.TargetUIStyle = Value
        if duelistTargetScreen then
            pcall(function() duelistTargetScreen:Destroy() end)
            duelistTargetScreen = nil
            duelistTargetMain = nil
            duelistTargetElements = {}
            currentTargetUIStyle = nil
            createTargetUI()
        end
    end
})

VisualsTargetUI:Dropdown({
    Name = "Position",
    Items = { "Free", "Follow Target" },
    Default = cfg.TargetUIPosition,
    Flag = "Duelist_TargetUIPosition",
    Callback = function(Value) cfg.TargetUIPosition = Value end
})

-- Highlight
local HighlightToggle = VisualsHighlight:Toggle({
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
    VisualsHighlight:Colorpicker({
        Name = "Fill Color",
        Default = cfg.TargetHighlightFill,
        Flag = "Duelist_TargetHighlightFill",
        Callback = function(Value) cfg.TargetHighlightFill = Value end
    })
    VisualsHighlight:Colorpicker({
        Name = "Outline Color",
        Default = cfg.TargetHighlightOutline,
        Flag = "Duelist_TargetHighlightOutline",
        Callback = function(Value) cfg.TargetHighlightOutline = Value end
    })
end

-- Tracer
local TracerToggle = VisualsTracer:Toggle({
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
    TracerToggle:Colorpicker({
        Name = "",
        Default = cfg.TargetTracerOutlineColor,
        Flag = "Duelist_TargetTracerOutlineColor",
        Callback = function(Value) cfg.TargetTracerOutlineColor = Value end
    })
end)
if not tracerColorChained then
    VisualsTracer:Colorpicker({
        Name = "Tracer Color",
        Default = cfg.TargetTracerColor,
        Flag = "Duelist_TargetTracerColor",
        Callback = function(Value) cfg.TargetTracerColor = Value end
    })
    VisualsTracer:Colorpicker({
        Name = "Outline Color",
        Default = cfg.TargetTracerOutlineColor,
        Flag = "Duelist_TargetTracerOutlineColor",
        Callback = function(Value) cfg.TargetTracerOutlineColor = Value end
    })
end

VisualsTracer:Slider({
    Name = "Thickness",
    Min = 1,
    Max = 10,
    Default = cfg.TargetTracerThickness,
    Flag = "Duelist_TargetTracerThickness",
    Callback = function(Value) cfg.TargetTracerThickness = Value end
})

VisualsTracer:Slider({
    Name = "Outline Thickness",
    Min = 1,
    Max = 15,
    Default = cfg.TargetTracerOutlineThickness,
    Flag = "Duelist_TargetTracerOutlineThickness",
    Callback = function(Value) cfg.TargetTracerOutlineThickness = Value end
})

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
WorldRight:Toggle({
    Name = "ESP",
    Default = cfg.EspEnabled,
    Flag = "Duelist_EspEnabled",
    Callback = function(State) cfg.EspEnabled = State end
})

WorldRight:Toggle({
    Name = "ESP Team Check",
    Default = cfg.EspTeamCheck,
    Flag = "Duelist_EspTeamCheck",
    Callback = function(State) cfg.EspTeamCheck = State end
})

WorldRight:Slider({
    Name = "Max Distance",
    Min = 100,
    Max = 10000,
    Default = cfg.EspMaxDistance,
    Flag = "Duelist_EspMaxDistance",
    Callback = function(Value) cfg.EspMaxDistance = Value end
})

WorldRight:Slider({
    Name = "Text Size",
    Min = 8,
    Max = 24,
    Default = cfg.EspTextSize,
    Flag = "Duelist_EspTextSize",
    Callback = function(Value) cfg.EspTextSize = Value end
})

WorldRight:Dropdown({
    Name = "Box Style",
    Items = {"Off", "Box", "Corner"},
    Default = cfg.EspBoxStyle,
    Flag = "Duelist_EspBoxStyle",
    Callback = function(Value) cfg.EspBoxStyle = Value end
})

WorldRight:Colorpicker({
    Name = "Box Color",
    Default = cfg.EspBoxColor,
    Flag = "Duelist_EspBoxColor",
    Callback = function(Value) cfg.EspBoxColor = Value end
})

WorldRight:Toggle({
    Name = "Box Outline",
    Default = cfg.EspBoxOutline,
    Flag = "Duelist_EspBoxOutline",
    Callback = function(State) cfg.EspBoxOutline = State end
})

WorldRight:Colorpicker({
    Name = "Box Outline Color",
    Default = cfg.EspBoxOutlineColor,
    Flag = "Duelist_EspBoxOutlineColor",
    Callback = function(Value) cfg.EspBoxOutlineColor = Value end
})

WorldRight:Toggle({
    Name = "Box Filled",
    Default = cfg.EspBoxFilled,
    Flag = "Duelist_EspBoxFilled",
    Callback = function(State) cfg.EspBoxFilled = State end
})

WorldRight:Slider({
    Name = "Box Thickness",
    Min = 1,
    Max = 5,
    Default = cfg.EspBoxThickness,
    Flag = "Duelist_EspBoxThickness",
    Callback = function(Value) cfg.EspBoxThickness = Value end
})

WorldRight:Toggle({
    Name = "Skeleton",
    Default = cfg.EspSkeleton,
    Flag = "Duelist_EspSkeleton",
    Callback = function(State) cfg.EspSkeleton = State end
})

WorldRight:Colorpicker({
    Name = "Skeleton Color",
    Default = cfg.EspSkeletonColor,
    Flag = "Duelist_EspSkeletonColor",
    Callback = function(Value) cfg.EspSkeletonColor = Value end
})

WorldRight:Slider({
    Name = "Skeleton Thickness",
    Min = 1,
    Max = 5,
    Default = cfg.EspSkeletonThickness,
    Flag = "Duelist_EspSkeletonThickness",
    Callback = function(Value) cfg.EspSkeletonThickness = Value end
})

WorldRight:Toggle({
    Name = "Health Bar",
    Default = cfg.EspHealthBar,
    Flag = "Duelist_EspHealthBar",
    Callback = function(State) cfg.EspHealthBar = State end
})

WorldRight:Toggle({
    Name = "Health Text",
    Default = cfg.EspHealthText,
    Flag = "Duelist_EspHealthText",
    Callback = function(State) cfg.EspHealthText = State end
})

WorldRight:Colorpicker({
    Name = "Health Color",
    Default = cfg.EspHealthColor,
    Flag = "Duelist_EspHealthColor",
    Callback = function(Value) cfg.EspHealthColor = Value end
})

WorldRight:Toggle({
    Name = "Head Dot",
    Default = cfg.EspHeadDot,
    Flag = "Duelist_EspHeadDot",
    Callback = function(State) cfg.EspHeadDot = State end
})

WorldRight:Colorpicker({
    Name = "Head Dot Color",
    Default = cfg.EspHeadDotColor,
    Flag = "Duelist_EspHeadDotColor",
    Callback = function(Value) cfg.EspHeadDotColor = Value end
})

WorldRight:Slider({
    Name = "Head Dot Size",
    Min = 1,
    Max = 15,
    Default = cfg.EspHeadDotSize,
    Flag = "Duelist_EspHeadDotSize",
    Callback = function(Value) cfg.EspHeadDotSize = Value end
})

WorldRight:Toggle({
    Name = "Snaplines",
    Default = cfg.EspSnaplines,
    Flag = "Duelist_EspSnaplines",
    Callback = function(State) cfg.EspSnaplines = State end
})

WorldRight:Colorpicker({
    Name = "Snapline Color",
    Default = cfg.EspSnaplineColor,
    Flag = "Duelist_EspSnaplineColor",
    Callback = function(Value) cfg.EspSnaplineColor = Value end
})

WorldRight:Slider({
    Name = "Snapline Thickness",
    Min = 1,
    Max = 5,
    Default = cfg.EspSnaplineThickness,
    Flag = "Duelist_EspSnaplineThickness",
    Callback = function(Value) cfg.EspSnaplineThickness = Value end
})

WorldRight:Toggle({
    Name = "Names",
    Default = cfg.EspNames,
    Flag = "Duelist_EspNames",
    Callback = function(State) cfg.EspNames = State end
})

WorldRight:Colorpicker({
    Name = "Name Color",
    Default = cfg.EspNameColor,
    Flag = "Duelist_EspNameColor",
    Callback = function(Value) cfg.EspNameColor = Value end
})

WorldRight:Toggle({
    Name = "Distance",
    Default = cfg.EspDistance,
    Flag = "Duelist_EspDistance",
    Callback = function(State) cfg.EspDistance = State end
})

WorldRight:Colorpicker({
    Name = "Distance Color",
    Default = cfg.EspDistanceColor,
    Flag = "Duelist_EspDistanceColor",
    Callback = function(Value) cfg.EspDistanceColor = Value end
})

-- Gun skins
PlayerLeft:Toggle({
    Name = "Skin Changer",
    Default = cfg.SkinChangerEnabled,
    Flag = "Duelist_SkinChangerEnabled",
    Callback = function(State)
        cfg.SkinChangerEnabled = State
        task.defer(function()
            if State then
                if typeof(applySelectedSkin) == "function" then applySelectedSkin() end
            else
                local fn = getEquippedGun
                if typeof(fn) ~= "function" then return end
                local tool = fn()
                if tool then
                    local old = tool:FindFirstChild("Skin")
                    if old then old:Destroy() end
                end
            end
        end)
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

-- Local Bullet Tracers
PlayerLocalTracers:Toggle({
    Name = "Local Tracers",
    Default = cfg.LocalBulletTracerEnabled,
    Flag = "Duelist_LocalBulletTracerEnabled",
    Callback = function(State) cfg.LocalBulletTracerEnabled = State end
})

PlayerLocalTracers:Toggle({
    Name = "Fade Out",
    Default = cfg.LocalBulletTracerFadeOut,
    Flag = "Duelist_LocalBulletTracerFadeOut",
    Callback = function(State) cfg.LocalBulletTracerFadeOut = State end
})

PlayerLocalTracers:Colorpicker({
    Name = "Tracer Color",
    Default = cfg.LocalBulletTracerColor,
    Flag = "Duelist_LocalBulletTracerColor",
    Callback = function(Value) cfg.LocalBulletTracerColor = Value end
})

PlayerLocalTracers:Slider({
    Name = "Tracer Lifetime",
    Min = 0.1,
    Max = 5,
    Default = cfg.LocalBulletTracerLifetime,
    Decimals = 0.1,
    Suffix = "s",
    Flag = "Duelist_LocalBulletTracerLifetime",
    Callback = function(Value) cfg.LocalBulletTracerLifetime = Value end
})

-- Other Bullet Tracers
PlayerOtherTracers:Toggle({
    Name = "Other Tracers",
    Default = cfg.OtherBulletTracerEnabled,
    Flag = "Duelist_OtherBulletTracerEnabled",
    Callback = function(State) cfg.OtherBulletTracerEnabled = State end
})

PlayerOtherTracers:Toggle({
    Name = "Fade Out",
    Default = cfg.OtherBulletTracerFadeOut,
    Flag = "Duelist_OtherBulletTracerFadeOut",
    Callback = function(State) cfg.OtherBulletTracerFadeOut = State end
})

PlayerOtherTracers:Colorpicker({
    Name = "Tracer Color",
    Default = cfg.OtherBulletTracerColor,
    Flag = "Duelist_OtherBulletTracerColor",
    Callback = function(Value) cfg.OtherBulletTracerColor = Value end
})

PlayerOtherTracers:Slider({
    Name = "Tracer Lifetime",
    Min = 0.1,
    Max = 5,
    Default = cfg.OtherBulletTracerLifetime,
    Decimals = 0.1,
    Suffix = "s",
    Flag = "Duelist_OtherBulletTracerLifetime",
    Callback = function(Value) cfg.OtherBulletTracerLifetime = Value end
})

-- Player Card
PlayerRight:Toggle({
    Name = "Card Changer",
    Default = cfg.CardChangerEnabled,
    Flag = "Duelist_CardChangerEnabled",
    Callback = function(State)
        cfg.CardChangerEnabled = State
        task.defer(function()
            if State and typeof(applySelectedCard) == "function" then applySelectedCard() end
        end)
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
        if typeof(applySelectedCard) == "function" then applySelectedCard(true) end
    end
})

-- KillFX list: all assets in the game, with owned GUIDs for official equip.
local KF = {
    Folder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("KillFX"),
    Options = {},
    NameToGuid = {},
    OriginalName = nil,
    OriginalGuid = nil,
    CurrentName = nil,
    Dropdown = nil,
}

local function getInventoryRemote()
    return ReplicatedStorage:WaitForChild("Events"):WaitForChild("HUD"):WaitForChild("Inventory")
end

local function getEquippedKillFX()
    local pd = LocalPlayer:FindFirstChild("PlayerData")
    local kf = pd and pd:FindFirstChild("Items") and pd.Items:FindFirstChild("KillFX")
    local equipped = kf and kf:FindFirstChild("Equipped")
    if equipped and equipped:IsA("StringValue") then
        return equipped
    end
    return nil
end

local function refreshKillFXList()
    local pd = LocalPlayer:FindFirstChild("PlayerData")
    local kf = pd and pd:FindFirstChild("Items") and pd.Items:FindFirstChild("KillFX")
    if not kf then return end
    local owned = kf:FindFirstChild("Owned")
    local equipped = kf:FindFirstChild("Equipped")

    table.clear(KF.Options)
    table.clear(KF.NameToGuid)

    if KF.Folder then
        for _, asset in ipairs(KF.Folder:GetChildren()) do
            if asset:IsA("ModuleScript") and asset.Name ~= "KillFX" then
                table.insert(KF.Options, asset.Name)
            end
        end
    end

    if owned then
        for _, item in ipairs(owned:GetChildren()) do
            local nameObj = item:FindFirstChild("ItemName")
            if nameObj and nameObj:IsA("StringValue") then
                local name = nameObj.Value
                if name and name ~= "" then
                    KF.NameToGuid[name] = item.Name
                end
            end
        end
    end

    table.sort(KF.Options)

    if equipped and equipped:IsA("StringValue") and KF.OriginalName == nil then
        KF.OriginalName = equipped.Value
        KF.OriginalGuid = KF.NameToGuid[KF.OriginalName]
        KF.CurrentName = KF.OriginalName

        if cfg.SelectedKillFX == "None" and KF.Dropdown then
            cfg.SelectedKillFX = KF.OriginalName
            pcall(function() KF.Dropdown:Set(KF.OriginalName) end)
        end
    end

    if KF.Dropdown then
        pcall(function() KF.Dropdown:SetItems(KF.Options) end)
        pcall(function() KF.Dropdown:Refresh(KF.Options) end)
    end
end

local function equipKillFXByName(name)
    if name == nil or name == "" then return end
    local equipped = getEquippedKillFX()
    if equipped then
        equipped.Value = name
    end
    local guid = KF.NameToGuid[name]
    if guid then
        getInventoryRemote():FireServer("Equip", "KillFX", guid)
    end
    KF.CurrentName = name
end

local function restoreOriginalKillFX()
    if not KF.OriginalName then return end
    local equipped = getEquippedKillFX()
    if equipped then
        equipped.Value = KF.OriginalName
    end
    if KF.OriginalGuid then
        getInventoryRemote():FireServer("Equip", "KillFX", KF.OriginalGuid)
    end
    KF.CurrentName = KF.OriginalName
end

PlayerKillFX:Toggle({
    Name = "KillFX Changer",
    Default = cfg.KillFXChangerEnabled,
    Flag = "Duelist_KillFXChangerEnabled",
    Callback = function(State)
        cfg.KillFXChangerEnabled = State
        if State then
            equipKillFXByName(cfg.SelectedKillFX)
        else
            restoreOriginalKillFX()
        end
    end
})

KF.Dropdown = PlayerKillFX:Dropdown({
    Name = "KillFX",
    Items = KF.Options,
    Default = cfg.SelectedKillFX,
    Flag = "Duelist_SelectedKillFX",
    Callback = function(Value)
        cfg.SelectedKillFX = Value
        if cfg.KillFXChangerEnabled then
            equipKillFXByName(Value)
        end
    end
})

task.defer(function()
    local pd = LocalPlayer:WaitForChild("PlayerData")
    pd:WaitForChild("Loaded")
    local kfItems = pd:WaitForChild("Items")
    kfItems:WaitForChild("KillFX")
    task.wait(0.2)
    refreshKillFXList()
    if cfg.KillFXChangerEnabled and cfg.SelectedKillFX then
        equipKillFXByName(cfg.SelectedKillFX)
    end
end)

-- Client-side visual override for KillFX (only the local player sees it).
local function isLocalKiller(killer)
    if killer == nil then return false end
    if killer == LocalPlayer then return true end
    local t = typeof(killer)
    if t == "Instance" then
        if killer:IsA("Player") then return killer == LocalPlayer end
        if killer:IsA("Model") then
            if killer == LocalPlayer.Character then return true end
            local p = Players:GetPlayerFromCharacter(killer)
            return p == LocalPlayer
        end
    elseif t == "number" then
        return killer == LocalPlayer.UserId
    elseif t == "string" then
        return killer == LocalPlayer.Name or killer == LocalPlayer.DisplayName
    end
    return false
end

local function hookKillFXVisual()
    if getgenv().EvolutionKillFXHooked then return end
    local ok, Weapons = pcall(function()
        return ReplicatedStorage:WaitForChild("Events"):WaitForChild("Weapons")
    end)
    if not ok or not Weapons then return end
    local ok2, cons = pcall(getconnections, Weapons.OnClientEvent)
    if not ok2 or not cons or #cons == 0 then return end
    for _, con in ipairs(cons) do
        local mt = getrawmetatable(con)
        if not mt then continue end
        local idx = mt.__index
        if typeof(idx) ~= "function" then continue end
        local orig = idx(con, "Function")
        if typeof(orig) ~= "function" then continue end
        idx(con, "Function", function(...)
            local args = {...}
            if args[1] == "KillFX" and cfg.KillFXChangerEnabled then
                if isLocalKiller(args[2]) then
                    print("[Evolution] KillFX override -> " .. tostring(cfg.SelectedKillFX) .. " (was " .. tostring(args[3]) .. ")")
                    args[3] = cfg.SelectedKillFX
                end
            end
            return orig(unpack(args))
        end)
    end
    getgenv().EvolutionKillFXHooked = true
end

task.defer(function()
    for i = 1, 20 do
        hookKillFXVisual()
        if getgenv().EvolutionKillFXHooked then break end
        task.wait(0.5)
    end
end)

-- Backpack list from game assets.
local BackpackFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Backpack")
local BackpackOptions = {}
local backpackNameSet = {}
if BackpackFolder then
    for _, acc in ipairs(BackpackFolder:GetChildren()) do
        if acc:IsA("Accessory") then
            table.insert(BackpackOptions, acc.Name)
            backpackNameSet[acc.Name] = true
        end
    end
end
table.sort(BackpackOptions)

PlayerBackpack:Toggle({
    Name = "Backpack Changer",
    Default = cfg.BackpackChangerEnabled,
    Flag = "Duelist_BackpackChangerEnabled",
    Callback = function(State) cfg.BackpackChangerEnabled = State end
})

PlayerBackpack:Dropdown({
    Name = "Backpack",
    Items = BackpackOptions,
    Default = cfg.SelectedBackpack,
    Flag = "Duelist_SelectedBackpack",
    Callback = function(Value) cfg.SelectedBackpack = Value end
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

local CharactersFolder
pcall(function()
    CharactersFolder = Workspace:WaitForChild("Characters", 10) or Workspace:FindFirstChild("Characters")
end)

local WeaponsRemote
pcall(function()
    WeaponsRemote = ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("Weapons", 10)
end)

local function isAlive(model)
    if not model then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isEnemy(model)
    if not cfg.TeamCheck then return true end
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == LocalPlayer then return false end
    if not plr.Team or not LocalPlayer.Team then return true end
    return plr.Team ~= LocalPlayer.Team
end

local function isEspEnemy(model)
    if not cfg.EspTeamCheck then return true end
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == LocalPlayer then return false end
    if not plr.Team or not LocalPlayer.Team then return true end
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

-- Reward TargetShoot orb that spawns over killed players' heads.
local function getTargetShoot()
    if not cfg.SilentAimEnabled then return nil end
    if not cfg.TargetShootEnabled then return nil end

    local targetShoots = Workspace:FindFirstChild("TargetShoots")
    if not targetShoots then return nil end

    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHead = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
    if not myHead then return nil end

    local origin = myHead.Position
    local bestDist = math.huge
    local bestPart = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, part in ipairs(targetShoots:GetChildren()) do
        if not part:IsA("BasePart") then continue end

        local dist = (part.Position - origin).Magnitude
        if dist > cfg.MaxDistance then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        if (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude > cfg.FOVRadius then continue end

        if cfg.WallCheck then
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            rp.FilterDescendantsInstances = {myChar, Camera, part}
            if Workspace:Raycast(origin, (part.Position - origin).Unit * dist, rp) then continue end
        end

        if dist < bestDist then
            bestDist = dist
            bestPart = part
        end
    end

    return bestPart
end

-- Prevents recursive raycast redirection while target selection runs.
local computingTarget = false

local function rawFindTarget(targetHitPart, useHitchance, useMouse)
    if not CharactersFolder then return nil end

    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHead = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
    if not myHead then return nil end

    local origin = myHead.Position
    local bestDist = math.huge
    local bestPart = nil
    local center
    if useMouse then
        center = UserInputService:GetMouseLocation()
    else
        center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    for _, model in ipairs(CharactersFolder:GetChildren()) do
        if model == myChar then continue end
        if not isAlive(model) then continue end
        if not isEnemy(model) then continue end
        if cfg.KOCheck then
            local ko = model:GetAttribute("KO") or model:GetAttribute("Knocked") or model:GetAttribute("Downed")
            if ko then continue end
        end

        local part
        if useHitchance then
            part = getPriorityPart(model)
        else
            part = model:FindFirstChild(targetHitPart) or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        end
        if not part then continue end

        local dist = (part.Position - origin).Magnitude
        if dist > cfg.MaxDistance then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        if cfg.AimAssistUseFOV or not useMouse then
            if (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude > cfg.FOVRadius then continue end
        end

        if cfg.WallCheck then
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            rp.FilterDescendantsInstances = {myChar, Camera, model}
            if Workspace:Raycast(origin, (part.Position - origin).Unit * dist, rp) then continue end
        end

        if dist < bestDist then
            bestDist = dist
            bestPart = part
        end
    end

    return bestPart
end

local function validateAimAssistTarget(model)
    if not (model and model.Parent) then return nil end
    if not isAlive(model) then return nil end
    if not isEnemy(model) then return nil end
    if cfg.KOCheck then
        local ko = model:GetAttribute("KO") or model:GetAttribute("Knocked") or model:GetAttribute("Downed")
        if ko then return nil end
    end

    local part = model:FindFirstChild(cfg.AimAssistHitPart) or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    if not part then return nil end

    local myChar = LocalPlayer.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return nil end

    local origin = myHead.Position
    local dist = (part.Position - origin).Magnitude
    if dist > cfg.MaxDistance then return nil end

    local center = UserInputService:GetMouseLocation()
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return nil end
    if cfg.AimAssistUseFOV then
        if (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude > cfg.FOVRadius then return nil end
    end

    if cfg.WallCheck then
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = {myChar, Camera, model}
        if Workspace:Raycast(origin, (part.Position - origin).Unit * dist, rp) then return nil end
    end

    return part
end

local function rawAimAssistTarget()
    if aimAssistLockedModel then
        local part = validateAimAssistTarget(aimAssistLockedModel)
        if part then
            aimAssistLockedPart = part
            return part
        end
        -- Lost the locked target; don't auto-switch until aim assist is toggled again.
        aimAssistLockedModel = nil
        aimAssistLockedPart = nil
        aimAssistCurrentCF = nil
        return nil
    end

    if aimAssistLockOnce then
        return aimAssistLockedPart
    end

    local part = rawFindTarget(cfg.AimAssistHitPart, false, true)
    if part then
        aimAssistLockedModel = part:FindFirstAncestorOfClass("Model")
        aimAssistLockedPart = part
        aimAssistLockOnce = true
        aimAssistCurrentCF = nil
    end
    return part
end

local function rawSilentAimTarget()
    return rawFindTarget(cfg.HitPart, true, false)
end

local function getAimAssistTarget()
    if computingTarget then return nil end
    computingTarget = true
    local ok, result = pcall(rawAimAssistTarget)
    computingTarget = false
    if ok then return result end
    return nil
end

local function getSilentAimTarget()
    if computingTarget then return nil end
    computingTarget = true
    local ok, result = pcall(rawSilentAimTarget)
    computingTarget = false
    if ok then return result end
    return nil
end

local function rawGetTarget()
    if not cfg.SilentAimEnabled then return nil end

    -- Reward TargetShoot takes priority when enabled.
    local shoot = cfg.TargetShootEnabled and getTargetShoot()
    if shoot then return shoot end

    return rawSilentAimTarget()
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
    local part = getAimAssistTarget()
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

    if cmd == "ReplicateTracer" or cmd == "Process" then
        localTracerActiveUntil = tick() + 0.25
    end

    if not cfg.SilentAimEnabled then
        return oldFireServer(self, cmd, ...)
    end

    if cmd == "Process" then
        local target = getTarget()
        if target then
            shotActiveUntil = tick() + 0.25
        end
    end

    return oldFireServer(self, cmd, ...)
end

if WeaponsRemote then
    if typeof(hookfunction) == "function" then
        oldFireServer = hookfunction(WeaponsRemote.FireServer, hookedFireServer)
    else
        oldFireServer = WeaponsRemote.FireServer
        WeaponsRemote.FireServer = hookedFireServer
    end
end

-- Remember hooks so a reload can restore them instead of stacking hooks.
getgenv().EvolutionDuelistHooks = {
    mt = mt,
    oldNamecall = oldNamecall,
    weaponsRemote = WeaponsRemote,
    oldFireServer = oldFireServer,
}

-- Direct castBullet / tryFire hooks (works in duels; no visible camera lock).
do
    local castBulletOriginal = nil
    local castBulletFunc = nil
    local tryFireOriginal = nil
    local tryFireFunc = nil
    local hookedFuncs = getgenv().EvolutionSilentAimCastHookedFuncs
    if not hookedFuncs then
        hookedFuncs = setmetatable({}, { __mode = "k" })
        getgenv().EvolutionSilentAimCastHookedFuncs = hookedFuncs
    end

    local function hookSilentAimFunction(name, wrapperMaker)
        local foundAny = false
        for _, obj in ipairs(getgc()) do
            if typeof(obj) == "function" then
                local info = debug.getinfo(obj)
                if info and info.name == name and not hookedFuncs[obj] then
                    local orig
                    local function callOrig(...)
                        return orig(...)
                    end
                    local wrapper = wrapperMaker(callOrig)
                    local ok, gotOrig = pcall(function()
                        return hookfunction(obj, wrapper)
                    end)
                    if ok and typeof(gotOrig) == "function" then
                        foundAny = true
                        orig = gotOrig
                        hookedFuncs[obj] = true
                        hookedFuncs[orig] = true
                        if name == "castBullet" then
                            castBulletOriginal = orig
                            castBulletFunc = obj
                        elseif name == "tryFire" then
                            tryFireOriginal = orig
                            tryFireFunc = obj
                        end
                    end
                end
            end
        end
        if foundAny then
            getgenv().EvolutionSilentAimCastHooked = true
            local hooks = getgenv().EvolutionDuelistHooks
            if hooks then
                hooks.castBulletFunc = castBulletFunc
                hooks.castBulletOriginal = castBulletOriginal
                hooks.tryFireFunc = tryFireFunc
                hooks.tryFireOriginal = tryFireOriginal
            end
        end
    end

    local function hookSilentAimCastBullet()
        hookSilentAimFunction("castBullet", function(callOrig)
            return function(p1, p2)
                if not cfg.SilentAimEnabled or computingTarget then
                    return callOrig(p1, p2)
                end
                local target = getTarget()
                if target and target.Parent then
                    local model = target:FindFirstAncestorOfClass("Model")
                    print("[Evolution SA] castBullet redirect ->", model and model.Name or target.Name)
                    local pos = target.Position
                    local normal = (Camera.CFrame.Position - pos).Unit
                    return {
                        Instance = target,
                        Position = pos,
                        Normal = normal,
                        Material = Enum.Material.Plastic,
                        Distance = (p2 - pos).Magnitude,
                    }
                end
                return callOrig(p1, p2)
            end
        end)
    end

    local function hookSilentAimTryFire()
        hookSilentAimFunction("tryFire", function(callOrig)
            return function(...)
                if cfg.SilentAimEnabled and not computingTarget then
                    local target = getTarget()
                    if target then
                        shotActiveUntil = tick() + 0.25
                        print("[Evolution SA] tryFire rotate ->", target.Name)
                    end
                end
                return callOrig(...)
            end
        end)
    end

    local function hookSilentAimAll()
        hookSilentAimCastBullet()
        hookSilentAimTryFire()
    end

    task.defer(function()
        for i = 1, 30 do
            hookSilentAimAll()
            if getgenv().EvolutionSilentAimCastHooked then break end
            task.wait(0.5)
        end
    end)

    trackConnection(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        hookSilentAimAll()
    end))
end

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
        local cooldown = cfg.RapidFire and 0.01 or 0.15
        if tick() - lastSemiTrigger >= cooldown then
            setShootBind(true)
            autoFireHeld = true
            lastSemiTrigger = tick()
            task.delay(cfg.RapidFire and 0.01 or 0.05, function()
                setShootBind(false)
                autoFireHeld = false
            end)
        end
    end
end))

-- Triggerbot
local lastTriggerbotFire = 0
local pendingTriggerbotTask = nil

local function getTriggerbotTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
    local origin = ray.Origin
    local direction = ray.Direction * 5000
    local myChar = LocalPlayer.Character
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {myChar}
    local result = Workspace:Raycast(origin, direction, rp)
    if not result then return nil end
    local hit = result.Instance
    if cfg.TriggerbotTargetOrb then
        local targetShoots = Workspace:FindFirstChild("TargetShoots")
        if targetShoots and hit and hit:IsDescendantOf(targetShoots) then
            return hit, targetShoots, hit
        end
    end
    local model = hit and hit:FindFirstAncestorOfClass("Model")
    if not model or model == myChar then return nil end
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == LocalPlayer then return nil end
    if cfg.TriggerbotTeamCheck and plr.Team == LocalPlayer.Team then return nil end
    return plr, model, hit
end

trackConnection(RunService.RenderStepped:Connect(function()
    if not cfg.TriggerbotEnabled then
        if pendingTriggerbotTask then
            pcall(task.cancel, pendingTriggerbotTask)
            pendingTriggerbotTask = nil
        end
        return
    end

    local target = getTriggerbotTarget()
    local tool = getEquippedGun()
    if not target or not tool then
        if pendingTriggerbotTask then
            pcall(task.cancel, pendingTriggerbotTask)
            pendingTriggerbotTask = nil
        end
        return
    end

    if pendingTriggerbotTask then return end
    if tick() - lastTriggerbotFire < cfg.TriggerbotCooldown then return end

    local mousePos = UserInputService:GetMouseLocation()
    pendingTriggerbotTask = task.delay(cfg.TriggerbotDelay, function()
        pendingTriggerbotTask = nil
        if not cfg.TriggerbotEnabled then return end
        if not getTriggerbotTarget() then return end
        if not getEquippedGun() then return end
        if tick() - lastTriggerbotFire < cfg.TriggerbotCooldown then return end

        local pos = UserInputService:GetMouseLocation()
        local x = math.floor(pos.X)
        local y = math.floor(pos.Y)
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game.CoreGui, 1)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game.CoreGui, 1)
        end)
        lastTriggerbotFire = tick()
    end)
end))

-- Shoot In Lobby (manual fire only)
-- The client blocks firing anywhere except duels unless LocalPlayer has CanShoot=true.
-- We spoof that attribute only while the user is manually pressing fire, so auto-fire
-- still obeys the normal lobby restriction.
local lobbyCanShootSet = false
local function setLobbyCanShoot(enabled)
    if enabled then
        if not LocalPlayer:GetAttribute("CanShoot") then
            LocalPlayer:SetAttribute("CanShoot", true)
            lobbyCanShootSet = true
        end
    elseif lobbyCanShootSet then
        LocalPlayer:SetAttribute("CanShoot", nil)
        lobbyCanShootSet = false
    end
end

local function inLobby()
    return LocalPlayer:GetAttribute("InDuels") ~= true
end

trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not cfg.ShootInLobby then return end
    if not inLobby() then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

    setLobbyCanShoot(true)
    if GameG and typeof(GameG.FireBind) == "function" then
        GameG:FireBind("Shoot", true, false)
    end
end))

trackConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not lobbyCanShootSet then return end

    if GameG and typeof(GameG.FireBind) == "function" then
        GameG:FireBind("Shoot", false, false)
    end
    setLobbyCanShoot(false)
end))

-- Gun Mods attribute spoofing (Rapid Fire + No Recoil)
local gunModOriginals = {}
local function restoreGunMods(tool)
    local orig = gunModOriginals[tool]
    if not orig then return end
    pcall(function()
        tool:SetAttribute("FireRate", orig.FireRate)
        tool:SetAttribute("Automatic", orig.Automatic)
        tool:SetAttribute("Recoil", orig.Recoil)
        tool:SetAttribute("Spread", orig.Spread)
    end)
    gunModOriginals[tool] = nil
end

trackConnection(RunService.Heartbeat:Connect(function()
    local active = cfg.RapidFire or cfg.NoRecoil
    if not active then
        for tool, _ in pairs(gunModOriginals) do
            restoreGunMods(tool)
        end
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not tool:HasTag("Gun") then return end

    if not gunModOriginals[tool] then
        gunModOriginals[tool] = {
            FireRate = tool:GetAttribute("FireRate"),
            Automatic = tool:GetAttribute("Automatic"),
            Recoil = tool:GetAttribute("Recoil"),
            Spread = tool:GetAttribute("Spread"),
        }
    end

    pcall(function()
        local orig = gunModOriginals[tool]
        tool:SetAttribute("FireRate", cfg.RapidFire and 9999 or orig.FireRate)
        tool:SetAttribute("Automatic", cfg.RapidFire and true or orig.Automatic)
        tool:SetAttribute("Recoil", cfg.NoRecoil and 0 or orig.Recoil)
        tool:SetAttribute("Spread", cfg.NoRecoil and 0 or orig.Spread)
    end)
end))

getgenv().EvolutionDuelistRapidFireOriginals = gunModOriginals

-- ============================================================
-- ESP LOGIC
-- ============================================================
local espDrawings = {}

local skeletonConnections = {
    {{"Head"}, {"UpperTorso", "Torso"}},
    {{"UpperTorso", "Torso"}, {"LowerTorso"}},
    {{"UpperTorso", "Torso"}, {"LeftUpperArm", "Left Arm"}},
    {{"LeftUpperArm", "Left Arm"}, {"LeftLowerArm"}},
    {{"LeftLowerArm"}, {"LeftHand"}},
    {{"UpperTorso", "Torso"}, {"RightUpperArm", "Right Arm"}},
    {{"RightUpperArm", "Right Arm"}, {"RightLowerArm"}},
    {{"RightLowerArm"}, {"RightHand"}},
    {{"LowerTorso"}, {"LeftUpperLeg", "Left Leg"}},
    {{"LeftUpperLeg", "Left Leg"}, {"LeftLowerLeg"}},
    {{"LeftLowerLeg"}, {"LeftFoot"}},
    {{"LowerTorso"}, {"RightUpperLeg", "Right Leg"}},
    {{"RightUpperLeg", "Right Leg"}, {"RightLowerLeg"}},
    {{"RightLowerLeg"}, {"RightFoot"}},
}

local function getCamera()
    return Workspace.CurrentCamera
end

local function findPart(model, names)
    for _, name in ipairs(names) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return nil
end

local function ensureEsp(model)
    if espDrawings[model] then return espDrawings[model] end
    local t = {}

    t.BoxOutline = Drawing.new("Square")
    t.BoxOutline.Filled = false
    t.BoxOutline.Visible = false

    t.Box = Drawing.new("Square")
    t.Box.Filled = false
    t.Box.Visible = false

    t.BoxFill = Drawing.new("Square")
    t.BoxFill.Filled = true
    t.BoxFill.Visible = false

    t.CornerLines = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        t.CornerLines[i] = line
    end

    t.HealthBarOutline = Drawing.new("Square")
    t.HealthBarOutline.Filled = false
    t.HealthBarOutline.Visible = false

    t.HealthBar = Drawing.new("Square")
    t.HealthBar.Filled = true
    t.HealthBar.Visible = false

    t.Name = Drawing.new("Text")
    t.Name.Center = true
    t.Name.Outline = true
    t.Name.Visible = false

    t.HealthText = Drawing.new("Text")
    t.HealthText.Center = true
    t.HealthText.Outline = true
    t.HealthText.Visible = false

    t.Distance = Drawing.new("Text")
    t.Distance.Center = true
    t.Distance.Outline = true
    t.Distance.Visible = false

    t.HeadDot = Drawing.new("Circle")
    t.HeadDot.Filled = true
    t.HeadDot.Visible = false

    t.Snapline = Drawing.new("Line")
    t.Snapline.Visible = false

    t.SkeletonLines = {}
    for i = 1, #skeletonConnections do
        local line = Drawing.new("Line")
        line.Visible = false
        t.SkeletonLines[i] = line
    end

    espDrawings[model] = t
    return t
end

local function removeEsp(model)
    local t = espDrawings[model]
    if not t then return end
    local objects = {
        t.BoxOutline, t.Box, t.BoxFill,
        t.HealthBarOutline, t.HealthBar,
        t.Name, t.HealthText, t.Distance,
        t.HeadDot, t.Snapline
    }
    for _, obj in ipairs(objects) do
        pcall(function() obj:Remove() end)
    end
    for _, line in ipairs(t.CornerLines) do
        pcall(function() line:Remove() end)
    end
    for _, line in ipairs(t.SkeletonLines) do
        pcall(function() line:Remove() end)
    end
    espDrawings[model] = nil
end

local function hideEspDrawings(t)
    local ok = pcall
    ok(function() t.BoxOutline.Visible = false end)
    ok(function() t.Box.Visible = false end)
    ok(function() t.BoxFill.Visible = false end)
    for _, line in ipairs(t.CornerLines) do ok(function() line.Visible = false end) end
    ok(function() t.HealthBarOutline.Visible = false end)
    ok(function() t.HealthBar.Visible = false end)
    ok(function() t.Name.Visible = false end)
    ok(function() t.HealthText.Visible = false end)
    ok(function() t.Distance.Visible = false end)
    ok(function() t.HeadDot.Visible = false end)
    ok(function() t.Snapline.Visible = false end)
    for _, line in ipairs(t.SkeletonLines) do ok(function() line.Visible = false end) end
end

local function getMenuRect()
    local rect = nil
    pcall(function()
        local function isMenuFrame(frame)
            if not frame:IsA("GuiObject") or not frame.Visible then return false end
            local size = frame.AbsoluteSize
            if size.X < 400 or size.Y < 400 then return false end
            for _, d in ipairs(frame:GetDescendants()) do
                if d:IsA("TextLabel") then
                    local txt = tostring(d.Text)
                    if string.find(txt, "Evolution") or string.find(txt, "Combat Visuals") then
                        return true
                    end
                end
            end
            return false
        end
        local hui = gethui and gethui()
        if hui then
            for _, sg in ipairs(hui:GetChildren()) do
                if sg:IsA("ScreenGui") and sg.Enabled then
                    for _, c in ipairs(sg:GetChildren()) do
                        if isMenuFrame(c) then
                            local pos = c.AbsolutePosition
                            local size = c.AbsoluteSize
                            rect = {X1 = pos.X, Y1 = pos.Y, X2 = pos.X + size.X, Y2 = pos.Y + size.Y}
                            return
                        end
                    end
                end
            end
        end
        local core = game:GetService("CoreGui")
        local cgSg = core:FindFirstChild("Evolution")
        if cgSg and cgSg:IsA("ScreenGui") and cgSg.Enabled then
            for _, c in ipairs(cgSg:GetChildren()) do
                if isMenuFrame(c) then
                    local pos = c.AbsolutePosition
                    local size = c.AbsoluteSize
                    rect = {X1 = pos.X, Y1 = pos.Y, X2 = pos.X + size.X, Y2 = pos.Y + size.Y}
                    return
                end
            end
        end
    end)
    return rect
end

local function getCharacterBounds(model)
    local cam = getCamera()
    if not cam then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local found = false
    local camPos = cam.CFrame.Position
    local scale = cam.ViewportSize.Y / (2 * math.tan(math.rad(cam.FieldOfView) / 2))
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local pos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                found = true
                local d = math.max((part.Position - camPos).Magnitude, 1)
                local radius = math.max(part.Size.X, part.Size.Y, part.Size.Z) * 0.6
                local px = radius / d * scale
                minX = math.min(minX, pos.X - px)
                maxX = math.max(maxX, pos.X + px)
                minY = math.min(minY, pos.Y - px)
                maxY = math.max(maxY, pos.Y + px)
            end
        end
    end
    if not found then return nil end
    local size = Vector2.new(maxX - minX, maxY - minY)
    if size.X < 10 then size = Vector2.new(10, size.Y) end
    if size.Y < 10 then size = Vector2.new(size.X, 10) end
    return Vector2.new(minX, minY), size
end

local function drawCorners(t, topLeft, size, color, thickness)
    local cornerLength = math.min(size.X, size.Y) * 0.25
    local lines = t.CornerLines
    local function setLine(idx, from, to)
        local line = lines[idx]
        line.Visible = true
        line.From = from
        line.To = to
        line.Color = color
        line.Thickness = thickness
    end

    local tl = topLeft
    local tr = topLeft + Vector2.new(size.X, 0)
    local bl = topLeft + Vector2.new(0, size.Y)
    local br = topLeft + size

    -- Top-left
    setLine(1, tl, tl + Vector2.new(cornerLength, 0))
    setLine(2, tl, tl + Vector2.new(0, cornerLength))
    -- Top-right
    setLine(3, tr, tr - Vector2.new(cornerLength, 0))
    setLine(4, tr, tr + Vector2.new(0, cornerLength))
    -- Bottom-left
    setLine(5, bl, bl + Vector2.new(cornerLength, 0))
    setLine(6, bl, bl - Vector2.new(0, cornerLength))
    -- Bottom-right
    setLine(7, br, br - Vector2.new(cornerLength, 0))
    setLine(8, br, br - Vector2.new(0, cornerLength))
end

local function getHealthColor(percent)
    return Color3.fromRGB(255 * (1 - percent), 255 * percent, 0)
end

trackConnection(RunService.RenderStepped:Connect(function()
    if not cfg.EspEnabled or not CharactersFolder then
        for model, _ in pairs(espDrawings) do removeEsp(model) end
        return
    end

    local menuRect = getMenuRect()
    local function boxOverlapsMenu(min, max)
        if not menuRect then return false end
        return not (max.X < menuRect.X1 or min.X > menuRect.X2 or max.Y < menuRect.Y1 or min.Y > menuRect.Y2)
    end

    local cam = getCamera()
    if not cam then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
    local myPos = myRoot and myRoot.Position
    local viewport = cam.ViewportSize

    local seen = {}
    for _, model in ipairs(CharactersFolder:GetChildren()) do
        seen[model] = true
        if model == myChar then continue end
        if not isAlive(model) then removeEsp(model); continue end
        if not isEspEnemy(model) then continue end

        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
        if not root then removeEsp(model); continue end

        local dist = myPos and (root.Position - myPos).Magnitude or 0
        if dist > cfg.EspMaxDistance then removeEsp(model); continue end

        local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
        if not onScreen then removeEsp(model); continue end

        local t = ensureEsp(model)
        local topLeft, boxSize = getCharacterBounds(model)
        if not topLeft then removeEsp(model); continue end
        local center = topLeft + boxSize / 2
        local bottomRight = topLeft + boxSize

        if boxOverlapsMenu(topLeft, bottomRight) then
            removeEsp(model)
            continue
        end

        local textSize = cfg.EspTextSize
        t.Name.Size = textSize
        t.HealthText.Size = textSize - 1
        t.Distance.Size = textSize - 1

        -- Box
        local boxStyle = cfg.EspBoxStyle
        if boxStyle == "Box" then
            for _, line in ipairs(t.CornerLines) do line.Visible = false end
            if cfg.EspBoxOutline then
                t.BoxOutline.Visible = true
                t.BoxOutline.Position = topLeft
                t.BoxOutline.Size = boxSize
                t.BoxOutline.Color = cfg.EspBoxOutlineColor
                t.BoxOutline.Thickness = cfg.EspBoxThickness + 2
            else
                t.BoxOutline.Visible = false
            end
            t.Box.Visible = true
            t.Box.Position = topLeft
            t.Box.Size = boxSize
            t.Box.Color = cfg.EspBoxColor
            t.Box.Thickness = cfg.EspBoxThickness
            if cfg.EspBoxFilled then
                t.BoxFill.Visible = true
                t.BoxFill.Position = topLeft
                t.BoxFill.Size = boxSize
                t.BoxFill.Color = cfg.EspBoxColor
                t.BoxFill.Transparency = cfg.EspBoxFillTransparency
            else
                t.BoxFill.Visible = false
            end
        elseif boxStyle == "Corner" then
            t.BoxOutline.Visible = false
            t.Box.Visible = false
            t.BoxFill.Visible = false
            drawCorners(t, topLeft, boxSize, cfg.EspBoxColor, cfg.EspBoxThickness)
        else
            t.BoxOutline.Visible = false
            t.Box.Visible = false
            t.BoxFill.Visible = false
            for _, line in ipairs(t.CornerLines) do line.Visible = false end
        end

        -- Health bar
        local hum = model:FindFirstChildOfClass("Humanoid")
        if cfg.EspHealthBar and hum then
            local barWidth = 4
            local barHeight = boxSize.Y
            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barPos = topLeft - Vector2.new(barWidth + 4, 0)

            t.HealthBarOutline.Visible = true
            t.HealthBarOutline.Position = barPos
            t.HealthBarOutline.Size = Vector2.new(barWidth, barHeight)
            t.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
            t.HealthBarOutline.Thickness = 1

            t.HealthBar.Visible = true
            t.HealthBar.Position = barPos + Vector2.new(0, barHeight * (1 - healthPercent))
            t.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            t.HealthBar.Color = cfg.EspHealthColor
        else
            t.HealthBarOutline.Visible = false
            t.HealthBar.Visible = false
        end

        if cfg.EspHealthText and hum then
            t.HealthText.Visible = true
            t.HealthText.Position = topLeft - Vector2.new(0, 26)
            t.HealthText.Text = math.floor(hum.Health) .. " HP"
            t.HealthText.Color = cfg.EspHealthColor
        else
            t.HealthText.Visible = false
        end

        -- Name / Distance
        if cfg.EspNames then
            local plr = Players:GetPlayerFromCharacter(model)
            t.Name.Visible = true
            t.Name.Position = topLeft - Vector2.new(0, 14)
            t.Name.Text = plr and plr.DisplayName or model.Name
            t.Name.Color = cfg.EspNameColor
        else
            t.Name.Visible = false
        end

        if cfg.EspDistance and myPos then
            t.Distance.Visible = true
            t.Distance.Position = Vector2.new(center.X, topLeft.Y + boxSize.Y + 2)
            t.Distance.Text = math.floor(dist) .. "m"
            t.Distance.Color = cfg.EspDistanceColor
        else
            t.Distance.Visible = false
        end

        -- Head dot
        local head = model:FindFirstChild("Head")
        if cfg.EspHeadDot and head then
            local headPos, headOnScreen = cam:WorldToViewportPoint(head.Position)
            if headOnScreen then
                t.HeadDot.Visible = true
                t.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                t.HeadDot.Radius = cfg.EspHeadDotSize
                t.HeadDot.Color = cfg.EspHeadDotColor
            else
                t.HeadDot.Visible = false
            end
        else
            t.HeadDot.Visible = false
        end

        -- Snapline
        if cfg.EspSnaplines then
            t.Snapline.Visible = true
            t.Snapline.From = Vector2.new(viewport.X / 2, viewport.Y)
            t.Snapline.To = Vector2.new(center.X, topLeft.Y + boxSize.Y)
            t.Snapline.Color = cfg.EspSnaplineColor
            t.Snapline.Thickness = cfg.EspSnaplineThickness
        else
            t.Snapline.Visible = false
        end

        -- Skeleton
        if cfg.EspSkeleton then
            for i, conn in ipairs(skeletonConnections) do
                local line = t.SkeletonLines[i]
                local partA = findPart(model, conn[1])
                local partB = findPart(model, conn[2])
                if partA and partB then
                    local posA, onA = cam:WorldToViewportPoint(partA.Position)
                    local posB, onB = cam:WorldToViewportPoint(partB.Position)
                    if onA and onB then
                        line.Visible = true
                        line.From = Vector2.new(posA.X, posA.Y)
                        line.To = Vector2.new(posB.X, posB.Y)
                        line.Color = cfg.EspSkeletonColor
                        line.Thickness = cfg.EspSkeletonThickness
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(t.SkeletonLines) do line.Visible = false end
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

local function isGunInstance(inst)
    if not (inst:IsA("Tool") or inst:IsA("Model")) then return false end
    local n = inst.Name:lower()
    local nameMatches = n:find("pistol") or n:find("carabine") or n:find("rifle")
    if not nameMatches then return false end
    if inst:IsA("Tool") then
        return inst:HasTag("Gun")
    end
    -- Holstered waist models have a Handle and no Tool tag.
    return inst:FindFirstChild("Handle") ~= nil
end

function applySkinToTool(tool)
    if not cfg.SkinChangerEnabled then return end
    if not isGunInstance(tool) then return end

    local isRifle = tool.Name:lower():find("carabine") or tool.Name:lower():find("rifle")
    local selectedKey = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
    local registry = isRifle and rifleSkinRegistry or pistolSkinRegistry
    local skinObj = selectedKey and registry[selectedKey]

    -- Strip every existing Skin model before applying/removing so old skins don't stack.
    for _, child in ipairs(tool:GetChildren()) do
        if child.Name == "Skin" and child:IsA("Model") then
            child:Destroy()
        end
    end

    if not skinObj or not skinObj:IsA("Model") then
        -- No skin selected for this weapon type; leave it clean so the server/owned skin shows.
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

        -- Align the whole skin rigidly so its GripPosition lands on the tool handle pivot.
        -- This mirrors the server's own skin weld: Weld.Part0=Handle, Weld.Part1=SkinHandle,
        -- C0=identity, C1=Skin.GripPosition.
        if skinGrip then
            local targetCF = toolHandle.CFrame
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
        mainWeld.C0 = CFrame.new()
        mainWeld.C1 = skinGrip and skinGrip.CFrame or CFrame.new()
        mainWeld.Parent = skinHandle
    end)
    if not ok then warn("[evolution] applySkinToTool error:", err) end
end

function applySelectedSkin()
    if not cfg.SkinChangerEnabled then return end
    local tool = getEquippedGun()
    if tool then
        applySkinToTool(tool)
    end
end

-- Hook a gun instance (Tool or waist Model) so the selected skin is applied the
-- instant it appears or the server tries to put its own skin back on.
local function hookGunInstance(gun)
    if not isGunInstance(gun) then return end
    if gun:GetAttribute("EvolutionGunHooked") then return end
    gun:SetAttribute("EvolutionGunHooked", true)

    -- Only Tools fire Equipped; waist Models are simply parented to the character.
    if gun:IsA("Tool") then
        trackConnection(gun.Equipped:Connect(function()
            if not cfg.SkinChangerEnabled then return end
            local isRifle = gun.Name:lower():find("carabine") or gun.Name:lower():find("rifle")
            local key = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
            local tag = key and ((isRifle and "Carabine" or "Pistol") .. " / " .. key) or nil

            -- Destroy any skin that isn't our selected one before the server skin can render.
            for _, child in ipairs(gun:GetChildren()) do
                if child.Name == "Skin" and child:IsA("Model") then
                    if key and child:GetAttribute("EvolutionSkinKey") == tag then
                        -- keep our custom skin
                    else
                        child:Destroy()
                    end
                end
            end

            if cfg.AutoApplySkin and key then
                applySkinToTool(gun)
            end
        end))
    end

    trackConnection(gun.ChildAdded:Connect(function(child)
        if child.Name ~= "Skin" then return end
        if not cfg.SkinChangerEnabled then return end
        local isRifle = gun.Name:lower():find("carabine") or gun.Name:lower():find("rifle")
        local key = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
        local tag = key and ((isRifle and "Carabine" or "Pistol") .. " / " .. key) or nil

        -- If the server adds its own skin (or no skin is selected), remove it immediately.
        -- The render-step loop will make sure our custom skin is applied if it's missing.
        if not key or child:GetAttribute("EvolutionSkinKey") ~= tag then
            child:Destroy()
        end
    end))
end

local function hookGunsIn(parent)
    for _, t in ipairs(parent:GetChildren()) do
        hookGunInstance(t)
    end
    trackConnection(parent.ChildAdded:Connect(hookGunInstance))
end

-- Clear hook markers so a re-execution updates connections on existing tools.
for _, parent in ipairs({LocalPlayer.Backpack, LocalPlayer.Character}) do
    if parent then
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA("Tool") then
                t:SetAttribute("EvolutionToolHooked", nil)
            end
        end
    end
end

-- Hook tools already in backpack/character and any future ones.
hookGunsIn(LocalPlayer.Backpack)
if LocalPlayer.Character then
    hookGunsIn(LocalPlayer.Character)
end
trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    hookGunsIn(char)
end))

local cardApplyInProgress = false
local defaultHeadMeshId, defaultHeadTextureId
local function cacheDefaultHead(char)
    local head = char and char:FindFirstChild("Head")
    -- Only cache from an unmodified (default) character so face preservation works correctly.
    if head and head:IsA("BasePart") and not char:GetAttribute("EvolutionCardKey") then
        if not defaultHeadMeshId then
            defaultHeadMeshId = head:IsA("MeshPart") and head.MeshId or ""
        end
        if not defaultHeadTextureId then
            defaultHeadTextureId = head:IsA("MeshPart") and head.TextureID or ""
        end
    end
end
if LocalPlayer.Character then
    cacheDefaultHead(LocalPlayer.Character)
end
trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    cacheDefaultHead(char)
end))

function applySelectedCard(force)
    if cardApplyInProgress then return end
    if not cfg.CardChangerEnabled then return end
    local cardObj = cfg.SelectedCardKey and cardRegistry[cfg.SelectedCardKey]
    if not cardObj or not cardObj:IsA("Model") then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if not force and char:GetAttribute("EvolutionCardKey") == cfg.SelectedCardKey then
        return
    end

    cardApplyInProgress = true
    task.defer(function()
        pcall(function()
            local standardParts = {
                Head = true, UpperTorso = true, LowerTorso = true,
                LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
                RightUpperArm = true, RightLowerArm = true, RightHand = true,
                LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
                RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
                HumanoidRootPart = true,
                Torso = true, LeftArm = true, LeftLeg = true, RightArm = true, RightLeg = true
            }

            -- Clean up previously applied card extras.
            for _, d in ipairs(char:GetDescendants()) do
                if d:GetAttribute("EvolutionCardExtra") then
                    pcall(function() d:Destroy() end)
                elseif d:IsA("Accessory") or d:IsA("Hat") then
                    pcall(function() hum:RemoveAccessory(d) end)
                    pcall(function() d:Destroy() end)
                elseif d:IsA("Attachment") and d:GetAttribute("EvolutionCardAtt") then
                    pcall(function() d:Destroy() end)
                end
            end

            -- 1) Body colors / clothing.
            local function copyClass(class)
                local from = cardObj:FindFirstChildOfClass(class)
                local existing = char:FindFirstChildOfClass(class)
                if existing then existing:Destroy() end
                if from then
                    local clone = from:Clone()
                    clone:SetAttribute("EvolutionCardExtra", true)
                    clone.Parent = char
                end
            end

            copyClass("BodyColors")
            copyClass("Shirt")
            copyClass("Pants")
            copyClass("ShirtGraphic")

            local function cardHeadChangesFace(cardHead)
                if not cardHead or not cardHead:IsA("BasePart") then return false end
                if cardHead:IsA("MeshPart") then
                    if cardHead.MeshId ~= "" and cardHead.MeshId ~= defaultHeadMeshId then
                        return true
                    end
                    if cardHead.TextureID ~= "" and cardHead.TextureID ~= defaultHeadTextureId then
                        return true
                    end
                end
                for _, d in ipairs(cardHead:GetDescendants()) do
                    if d:IsA("Decal") or d:IsA("FaceControls") or d:IsA("SpecialMesh") then
                        return true
                    end
                end
                return false
            end

            -- 2) Update standard body parts and copy their attachments / effects.
            for _, fromPart in ipairs(cardObj:GetDescendants()) do
                if fromPart:IsA("BasePart") then
                    local myPart = char:FindFirstChild(fromPart.Name)
                    if myPart and myPart:IsA("BasePart") and standardParts[fromPart.Name] then


                        local isHead = fromPart.Name == "Head"
                        local changesFace = isHead and cardHeadChangesFace(fromPart)

                        if fromPart:IsA("MeshPart") and myPart:IsA("MeshPart") then
                            if fromPart.MeshId ~= "" and (not isHead or changesFace) then
                                myPart.MeshId = fromPart.MeshId
                            end
                            if fromPart.TextureID ~= "" and (not isHead or changesFace) then
                                myPart.TextureID = fromPart.TextureID
                            end
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

                        -- Copy attachments, decals, particles, trails, lights, face controls, etc.
                        for _, child in ipairs(fromPart:GetChildren()) do
                            if child:IsA("Motor6D") or child:IsA("Weld") then
                                continue
                            end
                            if child:IsA("Attachment") then
                                -- Don't overwrite rig attachments; replace only mount/FX attachments.
                                local existing = myPart:FindFirstChild(child.Name)
                                if existing and existing:IsA("Attachment") then
                                    if child.Name:find("RigAttachment") then
                                        continue
                                    end
                                    existing:Destroy()
                                end
                                local clone = child:Clone()
                                clone:SetAttribute("EvolutionCardAtt", true)
                                clone.Parent = myPart
                            elseif child:IsA("BasePart") then
                                -- Extra meshpart welded to this body part (hair, horns, eye glow, etc.)
                                local clone = child:Clone()
                                clone.Anchored = false
                                clone.CanCollide = false
                                clone.Massless = true
                                clone:SetAttribute("EvolutionCardExtra", true)
                                for _, w in ipairs(clone:GetChildren()) do
                                    if w:IsA("Weld") or w:IsA("Motor6D") or w:IsA("ManualWeld") then
                                        w:Destroy()
                                    end
                                end
                                clone.Parent = myPart

                                local oldWeld = child:FindFirstChildWhichIsA("Weld") or child:FindFirstChildWhichIsA("Motor6D") or child:FindFirstChildWhichIsA("ManualWeld")
                                local weld = Instance.new("Weld")
                                weld.Part0 = myPart
                                weld.Part1 = clone
                                if oldWeld then
                                    weld.C0 = oldWeld.C0
                                    weld.C1 = oldWeld.C1
                                end
                                weld.Parent = clone
                            else
                                local existing = myPart:FindFirstChild(child.Name)
                                if existing and existing.ClassName == child.ClassName then
                                    existing:Destroy()
                                end
                                local clone = child:Clone()
                                clone:SetAttribute("EvolutionCardExtra", true)
                                clone.Parent = myPart
                            end
                        end
                    end
                end
            end

            -- 4) Clone all accessories (anywhere in the card) using a reliable manual weld.
            local function attachAccessory(acc)
                local handle = acc:FindFirstChild("Handle") or acc:FindFirstChildWhichIsA("BasePart")
                if not handle then return end

                -- Strip stale welds so AddAccessory / our manual weld can take over.
                for _, w in ipairs(handle:GetChildren()) do
                    if w:IsA("Weld") or w:IsA("Motor6D") or w:IsA("ManualWeld") then
                        w:Destroy()
                    end
                end
                handle.Anchored = false
                handle.CanCollide = false
                handle.Massless = true

                -- Use a handle attachment that has a matching mount on the character body.
                local candidates = {}
                for _, att in ipairs(handle:GetChildren()) do
                    if att:IsA("Attachment") then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part ~= handle and not part:IsDescendantOf(acc) then
                                local mount = part:FindFirstChild(att.Name)
                                if mount and mount:IsA("Attachment") then
                                    table.insert(candidates, {att = att, part = part, mount = mount})
                                    break
                                end
                            end
                        end
                    end
                end

                if #candidates > 0 then
                    local priority = {HatAttachment = 1, HairAttachment = 2, FaceFrontAttachment = 3, FaceCenterAttachment = 4, NeckAttachment = 5}
                    table.sort(candidates, function(a, b)
                        local pa = priority[a.att.Name] or 99
                        local pb = priority[b.att.Name] or 99
                        return pa < pb
                    end)
                    local c = candidates[1]
                    local weld = Instance.new("Weld")
                    weld.Name = "AccessoryWeld"
                    weld.Part0 = c.part
                    weld.Part1 = handle
                    weld.C0 = c.mount.CFrame
                    weld.C1 = c.att.CFrame
                    weld.Parent = handle
                    return
                end

                pcall(function() hum:AddAccessory(acc) end)
            end

            local accessorySet = {}
            for _, acc in ipairs(cardObj:GetDescendants()) do
                if acc:IsA("Accessory") or acc:IsA("Hat") then
                    accessorySet[acc] = true
                end
            end

            for acc in pairs(accessorySet) do
                local accHandle = acc:FindFirstChild("Handle") or acc:FindFirstChildWhichIsA("BasePart")
                if not accHandle then continue end

                local clone = acc:Clone()
                clone:SetAttribute("EvolutionCardExtra", true)
                for _, p in ipairs(clone:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Anchored = false
                        p.CanCollide = false
                        p.Massless = true
                    end
                end
                clone.Parent = char
                attachAccessory(clone)
            end

            -- 5) Clone extra parts, models/folders and any other top-level items.
            local function containsAccessory(obj)
                for _, d in ipairs(obj:GetDescendants()) do
                    if d:IsA("Accessory") or d:IsA("Hat") then return true end
                end
                return false
            end

            for _, child in ipairs(cardObj:GetChildren()) do
                if child:IsA("Humanoid") or child:IsA("Accessory") or child:IsA("Hat") then
                    continue
                elseif child:IsA("BasePart") and not standardParts[child.Name] then
                    -- Extra meshparts (custom hair, horns, eye glow, etc.) welded to a body part.
                    local clone = child:Clone()
                    clone.Anchored = false
                    clone.CanCollide = false
                    clone.Massless = true
                    clone:SetAttribute("EvolutionCardExtra", true)
                    for _, w in ipairs(clone:GetChildren()) do
                        if w:IsA("Weld") or w:IsA("Motor6D") or w:IsA("ManualWeld") then
                            w:Destroy()
                        end
                    end

                    local parentPart, c0, c1, externalIsPart0
                    for _, w in ipairs(cardObj:GetDescendants()) do
                        if w:IsA("Weld") or w:IsA("Motor6D") or w:IsA("ManualWeld") then
                            if w.Part0 == child and w.Part1 and standardParts[w.Part1.Name] then
                                parentPart = char:FindFirstChild(w.Part1.Name)
                                c0, c1 = w.C0, w.C1
                                externalIsPart0 = false
                                break
                            elseif w.Part1 == child and w.Part0 and standardParts[w.Part0.Name] then
                                parentPart = char:FindFirstChild(w.Part0.Name)
                                c0, c1 = w.C0, w.C1
                                externalIsPart0 = true
                                break
                            end
                        end
                    end

                    clone.Parent = parentPart or char
                    if parentPart and parentPart:IsA("BasePart") then
                        local weld = Instance.new("Weld")
                        if externalIsPart0 then
                            weld.Part0 = parentPart
                            weld.Part1 = clone
                            weld.C0 = c0
                            weld.C1 = c1
                        else
                            weld.Part0 = clone
                            weld.Part1 = parentPart
                            weld.C0 = c1
                            weld.C1 = c0
                        end
                        weld.Parent = clone
                    end
                elseif child:IsA("Model") or child:IsA("Folder") then
                    -- Skip folders that are just accessory containers or full rigs; they were already handled.
                    if containsAccessory(child) then
                        continue
                    end
                    local function containsStandardPart(obj)
                        for _, d in ipairs(obj:GetDescendants()) do
                            if d:IsA("BasePart") and standardParts[d.Name] then
                                return true
                            end
                        end
                        return false
                    end
                    if containsStandardPart(child) then
                        continue
                    end
                    local clone = child:Clone()
                    for _, d in ipairs(clone:GetDescendants()) do
                        if d:IsA("BasePart") then
                            d.Anchored = false
                            d.CanCollide = false
                            d.Massless = true
                        end
                        d:SetAttribute("EvolutionCardExtra", true)
                    end
                    clone:SetAttribute("EvolutionCardExtra", true)
                    clone.Parent = char
                elseif child.ClassName ~= "BodyColors" and child.ClassName ~= "Shirt" and child.ClassName ~= "Pants" and child.ClassName ~= "ShirtGraphic" and child.ClassName ~= "HumanoidDescription" and not child:IsA("BaseScript") and not child:IsA("BasePart") then
                    local clone = child:Clone()
                    clone:SetAttribute("EvolutionCardExtra", true)
                    clone.Parent = char
                end
            end

            -- 5) Face decals / face controls from the card head.
            local cardHead = cardObj:FindFirstChild("Head")
            local myHead = char:FindFirstChild("Head")
            if cardHead and myHead then
                if cardHeadChangesFace(cardHead) then
                    for _, d in ipairs(myHead:GetChildren()) do
                        if d:IsA("Decal") then d:Destroy() end
                    end
                    for _, d in ipairs(cardHead:GetDescendants()) do
                        if d:IsA("Decal") or d:IsA("FaceControls") then
                            local clone = d:Clone()
                            clone.Parent = myHead
                        end
                    end
                end
            end

            -- 6) Defensive cleanup: Roblox may re-apply default BodyColors / clothing
            -- after we clone them, and any leftover bare body-part clones would fling us.
            local function keepCloned(class)
                local kept = nil
                for _, c in ipairs(char:GetChildren()) do
                    if c.ClassName == class and c:GetAttribute("EvolutionCardExtra") then
                        kept = c
                        break
                    end
                end
                if kept then
                    for _, c in ipairs(char:GetChildren()) do
                        if c ~= kept and c.ClassName == class then
                            pcall(function() c:Destroy() end)
                        end
                    end
                end
            end
            keepCloned("BodyColors")
            keepCloned("Shirt")
            keepCloned("Pants")
            keepCloned("ShirtGraphic")

            for name in pairs(standardParts) do
                local real = nil
                for _, c in ipairs(char:GetChildren()) do
                    if c.Name == name and c:IsA("BasePart") then
                        if c:FindFirstChildWhichIsA("Motor6D") or c:FindFirstChildWhichIsA("AnimationConstraint") or c:FindFirstChild(name .. "RigAttachment") then
                            real = c
                            break
                        end
                    end
                end
                if real then
                    for _, c in ipairs(char:GetChildren()) do
                        if c ~= real and c.Name == name and c:IsA("BasePart") then
                            pcall(function() c:Destroy() end)
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
currentTargetUIStyle = nil
duelistTargetHighlight = nil
duelistTargetTracer = nil
duelistTargetTracerOutline = nil
lastDuelistTargetPlayer = nil

local function applyModernStyle()
    if not duelistTargetMain or not duelistTargetScreen then return end
    local main = duelistTargetMain
    local mainRadius = 12

    local function round(frame, radius)
        if not frame or not frame:IsA("GuiObject") then return end
        local corner = frame:FindFirstChildOfClass("UICorner")
        if not corner then
            corner = Instance.new("UICorner")
            corner.Parent = frame
        end
        corner.CornerRadius = UDim.new(0, radius)
    end

    -- Remove old image glow; modern uses rounded frame glow.
    if duelistTargetElements.Glow then
        pcall(function() duelistTargetElements.Glow:Destroy() end)
        duelistTargetElements.Glow = nil
    end

    -- Round every top-level frame in the ScreenGui.
    for _, sibling in ipairs(duelistTargetScreen:GetChildren()) do
        if sibling:IsA("Frame") then
            round(sibling, mainRadius)
            if sibling ~= main then
                sibling.ClipsDescendants = true
            end
        end
    end

    -- Move existing content into a clipping wrapper so square corners don't poke through.
    local Content = main:FindFirstChild("Content")
    if not Content then
        Content = Instance.new("Frame")
        Content.Name = "Content"
        Content.BackgroundTransparency = 1
        Content.Size = UDim2.new(1, 0, 1, 0)
        Content.Position = UDim2.new(0, 0, 0, 0)
        Content.ClipsDescendants = true
        Content.ZIndex = main.ZIndex
        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, mainRadius)
        contentCorner.Parent = Content
        for _, child in ipairs(main:GetChildren()) do
            if not child:IsA("UICorner") then
                child.Parent = Content
            end
        end
        Content.Parent = main
    end

    -- Modern glow: concentric rounded frames behind the panel.
    local glowColor = cfg.TargetUIGlowColor or cfg.TargetUIColor or Color3.fromRGB(27, 206, 203)
    local glowLayers = 8
    local glowMaxInset = 12
    local targetCombinedTransparency = 0.85
    local perLayerTransparency = targetCombinedTransparency ^ (1 / glowLayers)

    local GlowHolder = main:FindFirstChild("GlowHolder")
    if GlowHolder then
        pcall(function() GlowHolder:Destroy() end)
    end

    GlowHolder = Instance.new("Frame")
    GlowHolder.Name = "GlowHolder"
    GlowHolder.BackgroundTransparency = 1
    GlowHolder.Position = UDim2.new(0, 0, 0, 0)
    GlowHolder.Size = UDim2.new(1, 0, 1, 0)
    GlowHolder.ZIndex = main.ZIndex - 1
    GlowHolder.Parent = main
    GlowHolder.Visible = cfg.TargetUIUseGlow

    for i = 1, glowLayers do
        local t = i / glowLayers
        local inset = glowMaxInset * t
        local layer = Instance.new("Frame")
        layer.Name = "GlowLayer" .. i
        layer.BackgroundColor3 = glowColor
        layer.BackgroundTransparency = perLayerTransparency
        layer.BorderSizePixel = 0
        layer.Position = UDim2.new(0, -inset, 0, -inset)
        layer.Size = UDim2.new(1, inset * 2, 1, inset * 2)
        layer.ZIndex = GlowHolder.ZIndex - (glowLayers - i)
        layer.Parent = GlowHolder
        local layerCorner = Instance.new("UICorner")
        layerCorner.CornerRadius = UDim.new(0, mainRadius + inset)
        layerCorner.Parent = layer
    end

    duelistTargetElements.GlowHolder = GlowHolder

    -- Round descendants, keeping bar fills and the top accent sharp.
    local function roundDescendants(obj, depth)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Frame") then
                local name = child.Name
                if name ~= "HealthFill" and name ~= "AmmoFill" and name ~= "TopBar" then
                    round(child, math.max(2, mainRadius - depth))
                end
                roundDescendants(child, depth + 1)
            elseif child:IsA("ImageLabel") then
                round(child, 32)
            else
                roundDescendants(child, depth)
            end
        end
    end
    roundDescendants(Content, 1)
end

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
    Glow.ImageColor3 = cfg.TargetUIGlowColor
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
    HealthBarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 195, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 195, 45))
    }
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

    currentTargetUIStyle = cfg.TargetUIStyle
    if cfg.TargetUIStyle == "Modern" then
        applyModernStyle()
    end
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
        if not duelistTargetScreen or currentTargetUIStyle ~= cfg.TargetUIStyle then
            if duelistTargetScreen then
                pcall(function() duelistTargetScreen:Destroy() end)
            end
            duelistTargetScreen = nil
            duelistTargetMain = nil
            duelistTargetElements = {}
            currentTargetUIStyle = nil
            createTargetUI()
        end
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
            if cfg.TargetUIStyle == "Old" then
                if duelistTargetElements.Glow then
                    duelistTargetElements.Glow.ImageColor3 = cfg.TargetUIGlowColor
                    duelistTargetElements.Glow.Visible = cfg.TargetUIUseGlow
                end
            elseif cfg.TargetUIStyle == "Modern" then
                if duelistTargetElements.GlowHolder then
                    duelistTargetElements.GlowHolder.Visible = cfg.TargetUIUseGlow
                    for _, child in ipairs(duelistTargetElements.GlowHolder:GetChildren()) do
                        if child:IsA("Frame") then
                            child.BackgroundColor3 = cfg.TargetUIGlowColor
                        end
                    end
                end
            end

            if duelistTargetMain then
                if cfg.TargetUIPosition == "Follow Target" then
                    local head = targetInfo.Model:FindFirstChild("Head")
                    if head then
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            duelistTargetMain.Draggable = false
                            duelistTargetMain.Position = UDim2.new(0, pos.X + 180, 0, pos.Y - 50)
                        end
                    end
                else
                    duelistTargetMain.Draggable = true
                end
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
        duelistTargetTracerOutline.Color = cfg.TargetTracerOutlineColor
        duelistTargetTracerOutline.Thickness = cfg.TargetTracerOutlineThickness
        duelistTargetTracerOutline.Visible = true
        duelistTargetTracer.From = center
        duelistTargetTracer.To = endPos
        duelistTargetTracer.Color = cfg.TargetTracerColor
        duelistTargetTracer.Thickness = cfg.TargetTracerThickness
        duelistTargetTracer.Visible = true
    else
        if duelistTargetTracer then duelistTargetTracer.Visible = false end
        if duelistTargetTracerOutline then duelistTargetTracerOutline.Visible = false end
    end

end))

local function hasToolEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then return true end
    end
    return false
end

-- Aim Assist camlock (runs after the camera updates so it actually sticks)
local function runAimAssist()
    if not cfg.AimAssistEnabled then
        aimAssistLockedModel = nil
        aimAssistLockedPart = nil
        aimAssistCurrentCF = nil
        aimAssistLockOnce = false
        return
    end

    if cfg.AimAssistPauseOnTool and hasToolEquipped() then
        aimAssistLockedModel = nil
        aimAssistLockedPart = nil
        aimAssistCurrentCF = nil
        aimAssistLockOnce = false
        return
    end

    local targetInfo = getTargetPlayer()
    if not (targetInfo and targetInfo.Model and targetInfo.Model.Parent) then return end

    local aimPart = targetInfo.Model:FindFirstChild(cfg.AimAssistHitPart) or targetInfo.Part
    if not (aimPart and aimPart.Parent) then return end

    local velocity = Vector3.zero
    pcall(function()
        velocity = aimPart.AssemblyLinearVelocity or aimPart.Velocity or Vector3.zero
    end)

    local predictedPos = aimPart.Position + velocity * cfg.AimAssistPrediction
    local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
    local smoothing = math.clamp(cfg.AimAssistSmoothing, 0.01, 1)

    -- Keep our own desired camera CFrame so user mouse movement can't pull off target.
    -- The smoothing slider controls how fast the camera converges back to the aimpart.
    if not aimAssistCurrentCF then
        aimAssistCurrentCF = Camera.CFrame
    end
    aimAssistCurrentCF = aimAssistCurrentCF:Lerp(targetCF, smoothing)
    Camera.CFrame = aimAssistCurrentCF
end

pcall(function()
    RunService:UnbindFromRenderStep("EvolutionAimAssist")
end)
RunService:BindToRenderStep("EvolutionAimAssist", Enum.RenderPriority.Camera.Value + 1, runAimAssist)

-- Auto-apply cosmetics and force them back if the server resets them.
local lastSkinApply = 0
local lastCardApply = 0
trackConnection(RunService.RenderStepped:Connect(function()
    if cfg.SkinChangerEnabled and cfg.AutoApplySkin then
        -- Enforce skins on every gun the player owns, whether it's currently equipped
        -- or holstered on the waist/back. This way the custom skin shows up everywhere.
        for _, parent in ipairs({LocalPlayer.Character, LocalPlayer.Backpack}) do
            if not parent then continue end
            for _, tool in ipairs(parent:GetChildren()) do
                if not isGunInstance(tool) then continue end

                local isRifle = tool.Name:lower():find("carabine") or tool.Name:lower():find("rifle")
                local key = isRifle and cfg.SelectedRifleSkinKey or cfg.SelectedPistolSkinKey
                local tag = key and ((isRifle and "Carabine" or "Pistol") .. " / " .. key) or nil

                -- Purge wrong/stale skins every frame so the server-owned skin never overlaps.
                local hasCorrect = false
                for _, child in ipairs(tool:GetChildren()) do
                    if child.Name == "Skin" and child:IsA("Model") then
                        if key and child:GetAttribute("EvolutionSkinKey") == tag then
                            hasCorrect = true
                        else
                            child:Destroy()
                        end
                    end
                end

                local shouldApply = key and not hasCorrect
                local shouldRemoveAll = not key and hasCorrect
                if (shouldApply or shouldRemoveAll) and tick() - lastSkinApply >= 0.05 then
                    lastSkinApply = tick()
                    applySkinToTool(tool)
                end
            end
        end
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
    task.wait(0.2)
    if cfg.SkinChangerEnabled and cfg.AutoApplySkin then
        applySelectedSkin()
    end
    if cfg.CardChangerEnabled and cfg.AutoApplyCard and cfg.SelectedCardKey then
        applySelectedCard()
    end
end))

-- ============================================================
-- BACKPACK CHANGER
-- ============================================================
local originalBackpack = nil
local currentBackpackName = nil

local function findEquippedBackpack(char)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") and (backpackNameSet[child.Name] or child.Name == "EvolutionBackpack") then
            return child
        end
    end
    return nil
end

local function removeCustomBackpack(char)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") and child.Name == "EvolutionBackpack" then
            child:Destroy()
        end
    end
end

local function clearHandleWelds(handle)
    for _, child in ipairs(handle:GetChildren()) do
        if child:IsA("Weld") or child:IsA("ManualWeld") or child:IsA("AccessoryWeld") then
            child:Destroy()
        end
    end
end

local function weldBackpackAccessory(accessory, char)
    local handle = accessory:FindFirstChild("Handle")
    if not handle then return end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end

    local handleAttach
    for _, child in ipairs(handle:GetChildren()) do
        if child:IsA("Attachment") then
            handleAttach = child
            break
        end
    end
    local torsoAttach = handleAttach and torso:FindFirstChild(handleAttach.Name)
    if not handleAttach or not torsoAttach then return end

    clearHandleWelds(handle)
    handle.Anchored = false
    handle.CanCollide = false

    handle.CFrame = torsoAttach.WorldCFrame * handleAttach.CFrame:Inverse()
    local weld = Instance.new("Weld")
    weld.Name = "EvolutionBackpackWeld"
    weld.Part0 = torso
    weld.Part1 = handle
    weld.C0 = torso.CFrame:ToObjectSpace(handle.CFrame)
    weld.Parent = handle
end

local function applyBackpackChanger()
    if not cfg.BackpackChangerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if currentBackpackName == cfg.SelectedBackpack and char:FindFirstChild("EvolutionBackpack") then
        return
    end

    if originalBackpack == nil then
        local current = findEquippedBackpack(char)
        originalBackpack = current and current:Clone() or false
    end

    -- Remove any backpack currently on the character.
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") and (backpackNameSet[child.Name] or child.Name == "EvolutionBackpack") then
            child:Destroy()
        end
    end

    local selected = BackpackFolder and BackpackFolder:FindFirstChild(cfg.SelectedBackpack)
    if selected and selected:IsA("Accessory") and selected:FindFirstChild("Handle") then
        local clone = selected:Clone()
        clone.Name = "EvolutionBackpack"
        clone.Parent = char
        weldBackpackAccessory(clone, char)
        currentBackpackName = cfg.SelectedBackpack
    else
        currentBackpackName = nil
    end
end

local function restoreOriginalBackpack()
    local char = LocalPlayer.Character
    if not char then return end
    removeCustomBackpack(char)
    if originalBackpack and originalBackpack ~= false then
        local clone = originalBackpack:Clone()
        clone.Parent = char
        weldBackpackAccessory(clone, char)
    end
    originalBackpack = nil
    currentBackpackName = nil
end

trackConnection(RunService.Heartbeat:Connect(function()
    if cfg.BackpackChangerEnabled then
        applyBackpackChanger()
    elseif originalBackpack ~= nil or currentBackpackName ~= nil then
        restoreOriginalBackpack()
    end
end))

trackConnection(LocalPlayer.CharacterAdded:Connect(function()
    originalBackpack = nil
    currentBackpackName = nil
end))

-- ============================================================
-- BULLET TRACERS
-- ============================================================
local function isTracerPart(part)
    if not part or part.ClassName ~= "Part" then return false end
    return part:FindFirstChild("Start") and part:FindFirstChild("End") and part:FindFirstChild("Fire") and part:FindFirstChild("Smoke")
end

local function applyColorToTracerPart(part, color)
    part.Color = color
    local fire = part:FindFirstChild("Fire")
    local smoke = part:FindFirstChild("Smoke")
    if fire then
        fire.Color = ColorSequence.new(color)
        fire.LightEmission = 1
    end
    if smoke then
        smoke.Color = ColorSequence.new(color)
        smoke.LightEmission = 0.5
    end
end

local function fadeOutTracer(part, lifetime)
    local fire = part:FindFirstChild("Fire")
    local smoke = part:FindFirstChild("Smoke")
    local info = TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if smoke then
        pcall(function()
            TweenService:Create(smoke, info, { Width0 = 0, Width1 = 0 }):Play()
        end)
    end
    if fire then
        pcall(function()
            TweenService:Create(fire, info, { Width0 = 0, Width1 = 0 }):Play()
        end)
    end
end

local function applyTracerSettings(part, color, lifetime, fadeOut)
    applyColorToTracerPart(part, color)

    local target = part
    if lifetime ~= 1 then
        local clone = part:Clone()
        if clone then
            clone:SetAttribute("EvolutionTracerClone", true)
            applyColorToTracerPart(clone, color)
            clone.Parent = part.Parent
            target = clone
            Debris:AddItem(clone, lifetime)
            if lifetime < 1 then
                Debris:AddItem(part, lifetime)
            end
        end
    end

    if fadeOut then
        fadeOutTracer(target, lifetime)
    end
end

local function handleTracerPart(part)
    if not isTracerPart(part) then return end
    if part:GetAttribute("EvolutionTracerClone") or part:GetAttribute("EvolutionTracerHandled") then return end

    part:SetAttribute("EvolutionTracerHandled", true)

    local isLocal = tick() <= localTracerActiveUntil
    if isLocal and cfg.LocalBulletTracerEnabled then
        applyTracerSettings(part, cfg.LocalBulletTracerColor, cfg.LocalBulletTracerLifetime, cfg.LocalBulletTracerFadeOut)
    elseif not isLocal and cfg.OtherBulletTracerEnabled then
        applyTracerSettings(part, cfg.OtherBulletTracerColor, cfg.OtherBulletTracerLifetime, cfg.OtherBulletTracerFadeOut)
    end
end

local function hookTracerCache(cache)
    if not cache or cache:GetAttribute("EvolutionTracerHooked") then return end
    cache:SetAttribute("EvolutionTracerHooked", true)
    trackConnection(cache.ChildAdded:Connect(handleTracerPart))
    for _, child in ipairs(cache:GetChildren()) do
        handleTracerPart(child)
    end
end

local existingCache = Workspace:FindFirstChild("Cache")
if existingCache then
    hookTracerCache(existingCache)
end
trackConnection(Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Cache" and child:IsA("Folder") then
        hookTracerCache(child)
    end
end))

-- ============================================================
-- LIGHTING CHANGER
-- ============================================================
local lightingOriginal = nil
local lightingApplied = false
local evolutionColorCorrection = nil
local atmosphereOriginal = nil

local function getColorCorrection()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("ColorCorrectionEffect") then return child end
    end
    return nil
end

local function getAtmosphere()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Atmosphere") then return child end
    end
    return nil
end

local function captureLightingOriginal()
    if lightingOriginal then return end
    local cc = getColorCorrection()
    local atmo = getAtmosphere()
    lightingOriginal = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
    if cc then
        lightingOriginal.ColorCorrection = {
            Enabled = cc.Enabled,
            TintColor = cc.TintColor,
            Saturation = cc.Saturation,
            Contrast = cc.Contrast,
        }
    end
    if atmo then
        lightingOriginal.Atmosphere = {
            Density = atmo.Density,
            Haze = atmo.Haze,
            Color = atmo.Color,
        }
    end
end

local function applyLightingChanger()
    captureLightingOriginal()
    Lighting.ClockTime = cfg.LightingTimeOfDay
    Lighting.Brightness = cfg.LightingBrightness
    Lighting.Ambient = cfg.LightingAmbient
    Lighting.OutdoorAmbient = cfg.LightingOutdoorAmbient

    local cc = getColorCorrection()
    if not cc then
        if not evolutionColorCorrection or not evolutionColorCorrection.Parent then
            evolutionColorCorrection = Instance.new("ColorCorrectionEffect")
            evolutionColorCorrection.Name = "EvolutionColorCorrection"
            evolutionColorCorrection.Parent = Lighting
        end
        cc = evolutionColorCorrection
    end
    if cc then
        cc.Enabled = cfg.LightingColorCorrectionEnabled
        cc.TintColor = cfg.LightingColorCorrectionTint
        cc.Saturation = cfg.LightingColorCorrectionSaturation
        cc.Contrast = cfg.LightingColorCorrectionContrast
    end

    local atmo = getAtmosphere()
    if atmo then
        atmo.Density = cfg.LightingAtmosphereDensity
        atmo.Haze = cfg.LightingAtmosphereHaze
        atmo.Color = cfg.LightingAtmosphereColor
    end
    lightingApplied = true
end

local function restoreLightingOriginal()
    if not lightingOriginal then return end
    Lighting.ClockTime = lightingOriginal.ClockTime
    Lighting.Brightness = lightingOriginal.Brightness
    Lighting.Ambient = lightingOriginal.Ambient
    Lighting.OutdoorAmbient = lightingOriginal.OutdoorAmbient

    local cc = getColorCorrection()
    if cc then
        if lightingOriginal.ColorCorrection then
            cc.Enabled = lightingOriginal.ColorCorrection.Enabled
            cc.TintColor = lightingOriginal.ColorCorrection.TintColor
            cc.Saturation = lightingOriginal.ColorCorrection.Saturation
            cc.Contrast = lightingOriginal.ColorCorrection.Contrast
        elseif cc.Name == "EvolutionColorCorrection" then
            cc:Destroy()
        end
    end

    local atmo = getAtmosphere()
    if atmo and lightingOriginal.Atmosphere then
        atmo.Density = lightingOriginal.Atmosphere.Density
        atmo.Haze = lightingOriginal.Atmosphere.Haze
        atmo.Color = lightingOriginal.Atmosphere.Color
    end
    lightingApplied = false
end

trackConnection(RunService.RenderStepped:Connect(function()
    if cfg.LightingChangerEnabled then
        applyLightingChanger()
    elseif lightingApplied then
        restoreLightingOriginal()
    end
end))

-- ============================================================
-- WEATHER
-- ============================================================
local weatherPart = nil
local weatherParticle = nil
local weatherConnection = nil

local weatherTypes = {
    ["rain"] = {
        Speed = NumberRange.new(60, 60),
        LockedToPart = true,
        Rate = 600,
        Texture = "rbxassetid://1822883048",
        EmissionDirection = Enum.NormalId.Bottom,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, 0.7842668294906616),
            NumberSequenceKeypoint.new(0.75, 0.7842668294906616),
            NumberSequenceKeypoint.new(1, 1)
        },
        Lifetime = NumberRange.new(0.800000011920929, 0.800000011920929),
        LightEmission = 0.05000000074505806,
        LightInfluence = 0.8999999761581421,
        Orientation = Enum.ParticleOrientation.FacingCameraWorldUp,
        Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 10),
            NumberSequenceKeypoint.new(1, 10)
        }
    },
    ["snow"] = {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.7374999523162842),
            NumberSequenceKeypoint.new(0.973, 0.768750011920929),
            NumberSequenceKeypoint.new(1, 1)
        },
        Texture = "http://www.roblox.com/asset/?id=99851851",
        SpreadAngle = Vector2.new(50, 50),
        Speed = NumberRange.new(30, 30),
        LightEmission = 0.5,
        Rate = 1000,
        EmissionDirection = Enum.NormalId.Bottom,
        Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.33096909523010254),
            NumberSequenceKeypoint.new(0.551, 0.40189146995544434),
            NumberSequenceKeypoint.new(1, 0.33096909523010254)
        }
    },
    ["light rain"] = {
        LockedToPart = true,
        Rate = 500,
        Squash = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 3),
            NumberSequenceKeypoint.new(1, 3)
        },
        LightInfluence = 0.30000001192092896,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.435, 0),
            NumberSequenceKeypoint.new(1, 0)
        },
        Texture = "rbxasset://textures/particles/sparkles_main.dds",
        Speed = NumberRange.new(30, 50),
        Lifetime = NumberRange.new(9, 9),
        LightEmission = 0.5,
        Brightness = 2,
        EmissionDirection = Enum.NormalId.Bottom,
        Orientation = Enum.ParticleOrientation.FacingCameraWorldUp,
        Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.20000000298023224),
            NumberSequenceKeypoint.new(1, 0.20000000298023224)
        }
    }
}

local weatherOffset = Vector3.new(0, 20, 0)

local function cleanupWeather()
    if weatherPart then
        weatherPart:Destroy()
        weatherPart = nil
    end
    weatherParticle = nil
    if weatherConnection then
        weatherConnection:Disconnect()
        weatherConnection = nil
    end
end

local function applyWeatherConfig()
    if not cfg.WeatherEnabled then
        cleanupWeather()
        return
    end

    local data = weatherTypes[cfg.WeatherType]
    if not data then
        cleanupWeather()
        return
    end

    if not weatherPart or not weatherPart.Parent then
        cleanupWeather()
        weatherPart = Instance.new("Part")
        weatherPart.Size = Vector3.new(40, 40, 85)
        weatherPart.CanCollide = false
        weatherPart.Massless = true
        weatherPart.CastShadow = false
        weatherPart.Transparency = 1
        weatherPart.Anchored = true
        weatherPart.Name = "EvolutionWeatherPart"
        weatherPart.Parent = Workspace
    end

    if not weatherParticle or weatherParticle.Parent ~= weatherPart then
        if weatherParticle then weatherParticle:Destroy() end
        weatherParticle = Instance.new("ParticleEmitter")
        for prop, val in pairs(data) do
            weatherParticle[prop] = val
        end
        weatherParticle.Parent = weatherPart
    else
        -- Re-apply properties in case the type changed.
        for prop, val in pairs(data) do
            weatherParticle[prop] = val
        end
    end

    weatherParticle.Color = ColorSequence.new(cfg.WeatherColor)
    weatherParticle.Rate = cfg.WeatherRate * 10

    if not weatherConnection then
        weatherConnection = RunService.Heartbeat:Connect(function()
            local cam = Workspace.CurrentCamera
            if weatherPart and cam then
                weatherPart.CFrame = CFrame.new(cam.CFrame.Position) + weatherOffset
            end
        end)
    end
end

trackConnection(RunService.Heartbeat:Connect(function()
    applyWeatherConfig()
end))

-- ============================================================
-- SKYBOX CHANGER
-- ============================================================
local skyboxOriginal = nil
local skyboxCurrentName = nil

local function getCurrentLightingSky()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then return child end
    end
    return nil
end

local function clearLightingSkies()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
end

local function applySelectedSkybox()
    if not (SkyboxFolder and cfg.SkyboxChangerEnabled) then return end
    local selected = SkyboxFolder:FindFirstChild(cfg.SelectedSkybox)
    if not selected or not selected:IsA("Sky") then return end
    if skyboxCurrentName == selected.Name and getCurrentLightingSky() then return end

    if skyboxOriginal == nil then
        local current = getCurrentLightingSky()
        skyboxOriginal = current and current:Clone() or false
    end

    clearLightingSkies()
    local clone = selected:Clone()
    clone.Name = "EvolutionSkybox"
    clone.Parent = Lighting
    skyboxCurrentName = selected.Name
end

local function restoreOriginalSkybox()
    clearLightingSkies()
    if skyboxOriginal and skyboxOriginal ~= false then
        local clone = skyboxOriginal:Clone()
        clone.Parent = Lighting
    end
    skyboxCurrentName = nil
end

trackConnection(RunService.RenderStepped:Connect(function()
    if cfg.SkyboxChangerEnabled then
        applySelectedSkybox()
    else
        if skyboxCurrentName ~= nil then
            restoreOriginalSkybox()
        end
    end
end))

task.delay(2, function()
    refreshSkinList()
    refreshCardList()
end)

print('[evolution] Duelist module loaded')
