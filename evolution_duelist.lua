-- ============================================================
-- evolution | DUELIST: PvP
-- Silent aim + bullet manipulation via workspace.Raycast hook.
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
local Workspace = cloneref(game:GetService("Workspace"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))

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
    Cosmetics = Window:AddTab('Cosmetics'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local SilentAimBox = Tabs.Main:AddLeftGroupbox('Silent Aim')
local FovBox = Tabs.Main:AddRightGroupbox('FOV Circle')
local EspBox = Tabs.Main:AddRightGroupbox('ESP')
local SkinBox = Tabs.Cosmetics:AddLeftGroupbox('Gun Skin')
local CardBox = Tabs.Cosmetics:AddRightGroupbox('Player Card')

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
    SelectedSkinKey = nil,
    CardChangerEnabled = false,
    AutoApplyCard = true,
    SelectedCardKey = nil,
}
local cfg = getgenv().EvolutionDuelist

-- ============================================================
-- SILENT AIM UI
-- ============================================================
SilentAimBox:AddToggle('DT_SilentAim', {
    Text = 'Enabled',
    Default = cfg.SilentAimEnabled,
    Callback = function(v) cfg.SilentAimEnabled = v end
}):AddKeyPicker('DT_SilentAimKey', { Default = 'None', Mode = 'Toggle', Text = 'Silent Aim' })

SilentAimBox:AddToggle('DT_AutoFire', {
    Text = 'Auto Fire',
    Default = cfg.AutoFire,
    Callback = function(v) cfg.AutoFire = v end
})

SilentAimBox:AddToggle('DT_TeamCheck', {
    Text = 'Team Check',
    Default = cfg.TeamCheck,
    Callback = function(v) cfg.TeamCheck = v end
})

SilentAimBox:AddSlider('DT_Hitchance', {
    Text = 'Hitchance',
    Default = cfg.Hitchance,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(v) cfg.Hitchance = v end
})

SilentAimBox:AddSlider('DT_MaxDistance', {
    Text = 'Max Distance',
    Default = cfg.MaxDistance,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Callback = function(v) cfg.MaxDistance = v end
})

SilentAimBox:AddDropdown('DT_HitPart', {
    Text = 'Hit Part',
    Default = cfg.HitPart,
    Values = {'Head', 'UpperTorso', 'HumanoidRootPart'},
    Callback = function(v) cfg.HitPart = v end
})

-- ============================================================
-- FOV CIRCLE UI
-- ============================================================
local ShowFOVToggle = FovBox:AddToggle('DT_ShowFOV', {
    Text = 'Visible',
    Default = cfg.ShowFOV,
    Callback = function(v) cfg.ShowFOV = v end
})

ShowFOVToggle:AddColorPicker('DT_FOVColor', {
    Title = 'Fill Color',
    Default = cfg.FOVColor,
    Callback = function(v) cfg.FOVColor = v end
})

FovBox:AddSlider('DT_FOVRadius', {
    Text = 'Radius',
    Default = cfg.FOVRadius,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) cfg.FOVRadius = v end
})

FovBox:AddSlider('DT_FOVFillTransparency', {
    Text = 'Fill Transparency',
    Default = cfg.FOVFillTransparency * 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v) cfg.FOVFillTransparency = v / 100 end
})

local OutlineToggle = FovBox:AddToggle('DT_FOVOutline', {
    Text = 'Outline',
    Default = cfg.FOVOutline,
    Callback = function(v) cfg.FOVOutline = v end
})

OutlineToggle:AddColorPicker('DT_FOVOutlineColor', {
    Title = 'Outline Color',
    Default = cfg.FOVOutlineColor,
    Callback = function(v) cfg.FOVOutlineColor = v end
})

FovBox:AddSlider('DT_FOVOutlineThickness', {
    Text = 'Outline Thickness',
    Default = cfg.FOVOutlineThickness,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(v) cfg.FOVOutlineThickness = v end
})

local GradientToggle = FovBox:AddToggle('DT_FOVGradient', {
    Text = 'Gradient',
    Default = cfg.FOVGradient,
    Callback = function(v) cfg.FOVGradient = v end
})

GradientToggle:AddColorPicker('DT_FOVGradientTop', {
    Title = 'Gradient Top',
    Default = cfg.FOVGradientTop,
    Callback = function(v) cfg.FOVGradientTop = v end
})

GradientToggle:AddColorPicker('DT_FOVGradientBottom', {
    Title = 'Gradient Bottom',
    Default = cfg.FOVGradientBottom,
    Callback = function(v) cfg.FOVGradientBottom = v end
})

FovBox:AddToggle('DT_FOVGradientSpin', {
    Text = 'Gradient Spin',
    Default = cfg.FOVGradientSpin,
    Callback = function(v) cfg.FOVGradientSpin = v end
})

FovBox:AddSlider('DT_FOVGradientSpeed', {
    Text = 'Gradient Spin Speed',
    Default = cfg.FOVGradientSpeed,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v) cfg.FOVGradientSpeed = v end
})

-- ============================================================
-- ESP UI
-- ============================================================
EspBox:AddToggle('DT_EspEnabled', {
    Text = 'Enabled',
    Default = cfg.EspEnabled,
    Callback = function(v) cfg.EspEnabled = v end
})

local EspBoxesToggle = EspBox:AddToggle('DT_EspBoxes', {
    Text = 'Boxes',
    Default = cfg.EspBoxes,
    Callback = function(v) cfg.EspBoxes = v end
})

EspBoxesToggle:AddColorPicker('DT_EspBoxColor', {
    Title = 'Box Color',
    Default = cfg.EspBoxColor,
    Callback = function(v) cfg.EspBoxColor = v end
})

local EspNamesToggle = EspBox:AddToggle('DT_EspNames', {
    Text = 'Names',
    Default = cfg.EspNames,
    Callback = function(v) cfg.EspNames = v end
})

EspNamesToggle:AddColorPicker('DT_EspNameColor', {
    Title = 'Name Color',
    Default = cfg.EspNameColor,
    Callback = function(v) cfg.EspNameColor = v end
})

local EspHealthToggle = EspBox:AddToggle('DT_EspHealth', {
    Text = 'Health',
    Default = cfg.EspHealth,
    Callback = function(v) cfg.EspHealth = v end
})

EspHealthToggle:AddColorPicker('DT_EspHealthColor', {
    Title = 'Health Color',
    Default = cfg.EspHealthColor,
    Callback = function(v) cfg.EspHealthColor = v end
})

local EspDistanceToggle = EspBox:AddToggle('DT_EspDistance', {
    Text = 'Distance',
    Default = cfg.EspDistance,
    Callback = function(v) cfg.EspDistance = v end
})

EspDistanceToggle:AddColorPicker('DT_EspDistanceColor', {
    Title = 'Distance Color',
    Default = cfg.EspDistanceColor,
    Callback = function(v) cfg.EspDistanceColor = v end
})

EspBox:AddSlider('DT_EspMaxDist', {
    Text = 'Max Distance',
    Default = cfg.EspMaxDistance,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Callback = function(v) cfg.EspMaxDistance = v end
})

-- ============================================================
-- COSMETICS UI
-- ============================================================
SkinBox:AddToggle('DT_SkinChanger', {
    Text = 'Enabled',
    Default = cfg.SkinChangerEnabled,
    Callback = function(v) cfg.SkinChangerEnabled = v end
})

SkinBox:AddToggle('DT_AutoApplySkin', {
    Text = 'Auto Apply On Equip',
    Default = cfg.AutoApplySkin,
    Callback = function(v) cfg.AutoApplySkin = v end
})

local SkinDropdown = SkinBox:AddDropdown('DT_SelectedSkin', {
    Text = 'Skin',
    Default = cfg.SelectedSkinKey,
    Values = {},
    AllowNull = true,
    Callback = function(v) cfg.SelectedSkinKey = v end
})

SkinBox:AddButton('Refresh Skins', function()
    -- populated in logic section
    if typeof(refreshSkinList) == "function" then refreshSkinList() end
end)

SkinBox:AddButton('Apply Skin Now', function()
    if typeof(applySelectedSkin) == "function" then applySelectedSkin() end
end)

CardBox:AddToggle('DT_CardChanger', {
    Text = 'Enabled',
    Default = cfg.CardChangerEnabled,
    Callback = function(v) cfg.CardChangerEnabled = v end
})

CardBox:AddToggle('DT_AutoApplyCard', {
    Text = 'Auto Apply',
    Default = cfg.AutoApplyCard,
    Callback = function(v) cfg.AutoApplyCard = v end
})

local CardDropdown = CardBox:AddDropdown('DT_SelectedCard', {
    Text = 'Player Card',
    Default = cfg.SelectedCardKey,
    Values = {},
    AllowNull = true,
    Callback = function(v) cfg.SelectedCardKey = v end
})

CardBox:AddButton('Refresh Cards', function()
    if typeof(refreshCardList) == "function" then refreshCardList() end
end)

CardBox:AddButton('Apply Card Now', function()
    if typeof(applySelectedCard) == "function" then applySelectedCard() end
end)

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

RunService.RenderStepped:Connect(function()
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
end)

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

RunService.RenderStepped:Connect(function()
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
end)

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

RunService.RenderStepped:Connect(function()
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
end)

-- ============================================================
-- COSMETICS LOGIC
-- ============================================================
local skinRegistry = {}
local cardRegistry = {}

local function scanSkins()
    local list = {}
    local checked = {}

    local function addFolder(folder, prefix)
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Model") or item:IsA("Folder") then
                local key = (prefix and prefix .. " / " or "") .. item.Name
                table.insert(list, {Key = key, Object = item, Gun = prefix})
                if item:IsA("Folder") and #item:GetChildren() > 0 then
                    addFolder(item, key)
                end
            end
        end
    end

    local function check(folder)
        if not folder or checked[folder] then return end
        checked[folder] = true
        addFolder(folder, folder.Name)
    end

    local rs = ReplicatedStorage
    check(rs:FindFirstChild("Wraps"))
    check(rs:FindFirstChild("Skins"))

    local assets = rs:FindFirstChild("Assets")
    if assets then
        for _, c in ipairs(assets:GetChildren()) do
            local n = c.Name:lower()
            if n:find("wrap") or n:find("skin") or n:find("gun") then
                check(c)
            end
        end
    end

    return list
end

local function scanCards()
    local list = {}

    local function addFolder(folder)
        for _, item in ipairs(folder:GetChildren()) do
            table.insert(list, {Key = item.Name, Object = item})
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
    local skins = scanSkins()
    skinRegistry = {}
    local values = {}
    for _, s in ipairs(skins) do
        skinRegistry[s.Key] = s.Object
        table.insert(values, s.Key)
    end
    SkinDropdown:SetValues(values)
    if #values > 0 and not skinRegistry[cfg.SelectedSkinKey] then
        cfg.SelectedSkinKey = values[1]
        SkinDropdown:SetValue(values[1])
    end
end

function refreshCardList()
    local cards = scanCards()
    cardRegistry = {}
    local values = {}
    for _, c in ipairs(cards) do
        cardRegistry[c.Key] = c.Object
        table.insert(values, c.Key)
    end
    CardDropdown:SetValues(values)
    if #values > 0 and not cardRegistry[cfg.SelectedCardKey] then
        cfg.SelectedCardKey = values[1]
        CardDropdown:SetValue(values[1])
    end
end

function applySelectedSkin()
    if not cfg.SkinChangerEnabled then return end
    local skinObj = cfg.SelectedSkinKey and skinRegistry[cfg.SelectedSkinKey]
    if not skinObj then return end
    local tool = getEquippedGun()
    if not tool then return end

    -- Wait for the server skin to load, then overlay the selected skin and hide the original.
    task.delay(0.25, function()
        local currentTool = getEquippedGun()
        if currentTool ~= tool then return end

        -- Remove any previous overlay.
        local prev = currentTool:FindFirstChild("AppliedSkinOverlay")
        if prev then prev:Destroy() end

        local toolHandle = currentTool:FindFirstChild("Handle") or currentTool:FindFirstChildWhichIsA("BasePart")
        if not toolHandle then return end

        -- Hide the server-applied skin model so it doesn't overlap.
        local serverSkin = currentTool:FindFirstChild("Skin")
        if serverSkin then
            for _, d in ipairs(serverSkin:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = 1
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
                    d.Enabled = false
                end
            end
        end

        local overlay = skinObj:Clone()
        overlay.Name = "AppliedSkinOverlay"
        overlay.Parent = currentTool

        local skinHandle = overlay:FindFirstChild("Handle") or overlay:FindFirstChildWhichIsA("BasePart")
        if not skinHandle then
            overlay:Destroy()
            return
        end

        overlay.PrimaryPart = skinHandle
        skinHandle.CFrame = toolHandle.CFrame

        -- Weld overlay parts to its handle.
        for _, part in ipairs(overlay:GetDescendants()) do
            if part:IsA("BasePart") and part ~= skinHandle then
                local weld = Instance.new("Weld")
                weld.Part0 = skinHandle
                weld.Part1 = part
                weld.C0 = skinHandle.CFrame:Inverse() * part.CFrame
                weld.Parent = skinHandle
            end
        end

        -- Weld overlay handle to the tool handle.
        local mainWeld = Instance.new("Weld")
        mainWeld.Part0 = toolHandle
        mainWeld.Part1 = skinHandle
        mainWeld.C0 = CFrame.new()
        mainWeld.C1 = CFrame.new()
        mainWeld.Parent = skinHandle
    end)
end

function applySelectedCard()
    if not cfg.CardChangerEnabled then return end
    local cardObj = cfg.SelectedCardKey and cardRegistry[cfg.SelectedCardKey]
    if not cardObj then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local desc = nil

    if cardObj:IsA("HumanoidDescription") then
        desc = cardObj
    else
        -- Try to build a description from the card model.
        local hd = cardObj:FindFirstChildOfClass("HumanoidDescription")
        if hd then
            desc = hd
        else
            -- Some games require the model to be in Workspace for this API.
            pcall(function()
                desc = Players:GetHumanoidDescriptionFromCharacter(cardObj)
            end)
            if not desc then
                local clone = cardObj:Clone()
                pcall(function()
                    clone.Parent = Workspace
                    clone:MoveTo(Vector3.new(0, -5000, 0))
                    desc = Players:GetHumanoidDescriptionFromCharacter(clone)
                end)
                pcall(function() clone:Destroy() end)
            end
        end
    end

    if desc then
        pcall(function()
            hum:ApplyDescription(desc)
        end)
        return
    end

    -- Fallback: copy basic appearance objects and accessories manually.
    local function copyOrUpdate(className)
        local from = cardObj:FindFirstChildOfClass(className)
        if not from then return end
        local to = char:FindFirstChildOfClass(className)
        if to then
            to:Destroy()
        end
        local clone = from:Clone()
        clone.Parent = char
    end

    copyOrUpdate("BodyColors")
    copyOrUpdate("Shirt")
    copyOrUpdate("Pants")
    copyOrUpdate("ShirtGraphic")

    -- Remove old accessories using the humanoid when possible.
    for _, acc in ipairs(char:GetDescendants()) do
        if acc:IsA("Accessory") then
            pcall(function() hum:RemoveAccessory(acc) end)
            acc:Destroy()
        end
    end

    -- Add new accessories.
    for _, acc in ipairs(cardObj:GetDescendants()) do
        if acc:IsA("Accessory") then
            pcall(function()
                hum:AddAccessory(acc:Clone())
            end)
        end
    end

    -- Copy face decal from card's head to local head.
    local cardHead = cardObj:FindFirstChild("Head")
    local myHead = char:FindFirstChild("Head")
    if cardHead and myHead then
        local cardFace = cardHead:FindFirstChildOfClass("Decal")
        if cardFace then
            for _, d in ipairs(myHead:GetChildren()) do
                if d:IsA("Decal") then d:Destroy() end
            end
            local clone = cardFace:Clone()
            clone.Parent = myHead
        end
    end
end

-- Auto-apply cosmetics.
local lastSkinTool = nil
local lastAppliedCardKey = nil
RunService.RenderStepped:Connect(function()
    if cfg.SkinChangerEnabled and cfg.AutoApplySkin then
        local tool = getEquippedGun()
        if tool and tool ~= lastSkinTool then
            lastSkinTool = tool
            applySelectedSkin()
        end
    end
    if cfg.CardChangerEnabled and cfg.AutoApplyCard then
        if cfg.SelectedCardKey and cfg.SelectedCardKey ~= lastAppliedCardKey then
            lastAppliedCardKey = cfg.SelectedCardKey
            applySelectedCard()
        end
    end
end)

task.delay(2, function()
    refreshSkinList()
    refreshCardList()
end)

-- ============================================================
-- UI SETTINGS
-- ============================================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

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

print('[evolution] Duelist module loaded')
