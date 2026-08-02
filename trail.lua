-- Trail Addon for evolution
-- Run AFTER use_kimi.txt has loaded

if not getgenv().Tabs then
    warn("[Trail Addon] Tabs global not found")
    return
end

local VisualsTrail = getgenv().Tabs.Visuals:AddRightGroupbox("Trail")

local _trailAtt0, _trailAtt1, _trailMain, _trailGlow
local _trailWidth = 0.07
local _trailHeight = 0.2
local _trailLifetime = 1.2

local function _destroyTrail()
    if _trailMain then _trailMain:Destroy() _trailMain = nil end
    if _trailGlow then _trailGlow:Destroy() _trailGlow = nil end
    if _trailAtt0 then _trailAtt0:Destroy() _trailAtt0 = nil end
    if _trailAtt1 then _trailAtt1:Destroy() _trailAtt1 = nil end
end

local function _buildTrail(char)
    _destroyTrail()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    _trailAtt0 = Instance.new("Attachment")
    _trailAtt0.Position = Vector3.new(0, _trailHeight, 0)
    _trailAtt0.Parent = hrp

    _trailAtt1 = Instance.new("Attachment")
    _trailAtt1.Position = Vector3.new(0, -_trailHeight, 0)
    _trailAtt1.Parent = hrp

    local c1 = Options.TrailColorBeginning and Options.TrailColorBeginning.Value or Color3.fromRGB(0, 255, 255)
    local c2 = Options.TrailColorMiddle and Options.TrailColorMiddle.Value or Color3.fromRGB(0, 200, 255)
    local c3 = Options.TrailColorEnd and Options.TrailColorEnd.Value or Color3.fromRGB(0, 100, 255)

    _trailMain = Instance.new("Trail")
    _trailMain.Attachment0 = _trailAtt0
    _trailMain.Attachment1 = _trailAtt1
    _trailMain.Lifetime = _trailLifetime
    _trailMain.MinLength = 0
    _trailMain.FaceCamera = true
    _trailMain.LightEmission = 1
    _trailMain.LightInfluence = 0
    _trailMain.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(0.5, c2),
        ColorSequenceKeypoint.new(1, c3),
    })
    _trailMain.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, _trailWidth),
        NumberSequenceKeypoint.new(0.85, _trailWidth),
        NumberSequenceKeypoint.new(1, 0),
    })
    _trailMain.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    _trailMain.Parent = hrp

    _trailGlow = Instance.new("Trail")
    _trailGlow.Attachment0 = _trailAtt0
    _trailGlow.Attachment1 = _trailAtt1
    _trailGlow.Lifetime = _trailLifetime
    _trailGlow.MinLength = 0
    _trailGlow.FaceCamera = true
    _trailGlow.LightEmission = 1
    _trailGlow.LightInfluence = 0
    _trailGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(0.5, c2),
        ColorSequenceKeypoint.new(1, c3),
    })
    _trailGlow.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, _trailWidth * 4),
        NumberSequenceKeypoint.new(0.85, _trailWidth * 4),
        NumberSequenceKeypoint.new(1, 0),
    })
    _trailGlow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.85, 0.85),
        NumberSequenceKeypoint.new(1, 1),
    })
    _trailGlow.Parent = hrp
end

local function _refreshTrail()
    if not (Toggles.TrailUse and Toggles.TrailUse.Value) then return end
    local char = game:GetService("Players").LocalPlayer.Character
    if char then _buildTrail(char) end
end

local _trailCharConn
VisualsTrail:AddToggle('TrailUse', {
    Text = 'Use',
    Default = false,
    Callback = function(Value)
        if Value then
            local lp = game:GetService("Players").LocalPlayer
            if lp.Character then _buildTrail(lp.Character) end
            if _trailCharConn then _trailCharConn:Disconnect() end
            _trailCharConn = lp.CharacterAdded:Connect(function(newChar)
                task.wait(0.5)
                if Toggles.TrailUse and Toggles.TrailUse.Value then
                    _buildTrail(newChar)
                end
            end)
        else
            _destroyTrail()
            if _trailCharConn then _trailCharConn:Disconnect() _trailCharConn = nil end
        end
    end
}):AddColorPicker('TrailColorBeginning', {
    Title = 'Beginning',
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function() _refreshTrail() end
}):AddColorPicker('TrailColorMiddle', {
    Title = 'Middle',
    Default = Color3.fromRGB(0, 200, 255),
    Callback = function() _refreshTrail() end
}):AddColorPicker('TrailColorEnd', {
    Title = 'End',
    Default = Color3.fromRGB(0, 100, 255),
    Callback = function() _refreshTrail() end
})

VisualsTrail:AddSlider('TrailLifetime', {
    Text = 'Lifetime',
    Min = 0.1,
    Max = 5,
    Default = 1.2,
    Rounding = 1,
    Callback = function(Value)
        _trailLifetime = Value
        if _trailMain then _trailMain.Lifetime = Value end
        if _trailGlow then _trailGlow.Lifetime = Value end
    end
})

VisualsTrail:AddSlider('TrailWidth', {
    Text = 'Width',
    Min = 1,
    Max = 100,
    Default = 7,
    Rounding = 0,
    Callback = function(Value)
        _trailWidth = Value / 100
        if _trailMain then
            _trailMain.WidthScale = NumberSequence.new({
                NumberSequenceKeypoint.new(0, _trailWidth),
                NumberSequenceKeypoint.new(0.85, _trailWidth),
                NumberSequenceKeypoint.new(1, 0),
            })
        end
        if _trailGlow then
            _trailGlow.WidthScale = NumberSequence.new({
                NumberSequenceKeypoint.new(0, _trailWidth * 4),
                NumberSequenceKeypoint.new(0.85, _trailWidth * 4),
                NumberSequenceKeypoint.new(1, 0),
            })
        end
    end
})

VisualsTrail:AddSlider('TrailHeight', {
    Text = 'Height',
    Min = 1,
    Max = 100,
    Default = 20,
    Rounding = 0,
    Callback = function(Value)
        _trailHeight = Value / 100
        _refreshTrail()
    end
})

-- ===== INDICATOR OUTLINE =====
-- Inject UIStroke onto the indicator frame whenever it gets created
local function _injectStroke()
    local ui = Library and Library._targetUIInstance
    if not ui then return false end
    local mainFrame = ui:FindFirstChildOfClass("Frame")
    if not mainFrame then return false end
    -- remove existing stroke if any
    local existing = mainFrame:FindFirstChildOfClass("UIStroke")
    if existing then existing:Destroy() end
    local stroke = Instance.new("UIStroke")
    stroke.Color = getgenv().TargetUIGlowColor or getgenv().TargetUIBorderColor or Color3.fromRGB(27, 206, 203)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = mainFrame
    getgenv()._indicatorUIStroke = stroke
    -- hide the old OuterBorder so we dont get double outline
    if Library._targetUIOuterBorder then
        Library._targetUIOuterBorder.BackgroundTransparency = 1
    end
    return true
end

-- poll until indicator exists then inject
task.spawn(function()
    while true do
        task.wait(1)
        if Library and Library._targetUIInstance then
            _injectStroke()
            break
        end
    end
end)

-- also re-inject whenever the indicator is rebuilt (toggled off/on)
local _origTargetui = Library and Library.targetui
if Library and Library.targetui then
    Library.targetui = function(self, style)
        local result = _origTargetui(self, style)
        task.delay(0.3, _injectStroke)
        return result
    end
end

print("[Trail Addon] Loaded")
