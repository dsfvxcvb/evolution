-- Trail + Indicator Outline Addon for evolution
-- Run AFTER use_kimi.txt has loaded

if not getgenv().Tabs then
    warn("[Addon] Tabs global not found")
    return
end

-- =============================================
-- TRAIL
-- =============================================
local VisualsTrail = getgenv().Tabs.Visuals:AddRightGroupbox("Trail")

local _trailAtt0, _trailAtt1, _trailMain, _trailGlow
local _trailWidth = 0.07
local _trailHeight = 0.2

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
    local lt = Options.TrailLifetime and Options.TrailLifetime.Value or 1.2

    _trailMain = Instance.new("Trail")
    _trailMain.Attachment0 = _trailAtt0
    _trailMain.Attachment1 = _trailAtt1
    _trailMain.Lifetime = lt
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
    _trailGlow.Lifetime = lt
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

VisualsTrail:AddDropdown('TrailWidth', {
    Text = 'Width',
    Values = {'Thin', 'Normal', 'Wide', 'Thick'},
    Default = 'Normal',
    Callback = function(Value)
        if Value == 'Thin' then _trailWidth = 0.03
        elseif Value == 'Normal' then _trailWidth = 0.07
        elseif Value == 'Wide' then _trailWidth = 0.15
        elseif Value == 'Thick' then _trailWidth = 0.28
        end
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

VisualsTrail:AddDropdown('TrailHeight', {
    Text = 'Height',
    Values = {'Short', 'Normal', 'Tall', 'Extra Tall'},
    Default = 'Normal',
    Callback = function(Value)
        if Value == 'Short' then _trailHeight = 0.1
        elseif Value == 'Normal' then _trailHeight = 0.2
        elseif Value == 'Tall' then _trailHeight = 0.4
        elseif Value == 'Extra Tall' then _trailHeight = 0.7
        end
        _refreshTrail()
    end
})

VisualsTrail:AddSlider('TrailLifetime', {
    Text = 'Lifetime',
    Min = 0.1,
    Max = 5,
    Default = 1.2,
    Rounding = 1,
    Callback = function(Value)
        if _trailMain then _trailMain.Lifetime = Value end
        if _trailGlow then _trailGlow.Lifetime = Value end
    end
})

-- =============================================
-- INDICATOR OUTLINE COLOR
-- Adds an "Outline Color" picker to the Combat
-- Target Indicators section and wires it to a
-- UIStroke on the indicator frame
-- =============================================
local _indicatorStroke = nil

local function _applyOutlineColor(color)
    getgenv().TargetUIBorderColor = color
    getgenv().TargetUIGlowColor = color
    -- update the live OuterBorder if indicator is already open
    if Library and Library._targetUIOuterBorder then
        Library._targetUIOuterBorder.BackgroundColor3 = color
    end
    if Library and Library._targetUITopBar then
        Library._targetUITopBar.BackgroundColor3 = color
    end
    if Library and Library._targetUIGlow then
        if Library._targetUIGlow.ImageColor3 ~= nil then
            Library._targetUIGlow.ImageColor3 = color
        else
            -- modern style glow holder (frames)
            for _, child in ipairs(Library._targetUIGlow:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundColor3 = color
                end
            end
        end
    end
    if _indicatorStroke then
        _indicatorStroke.Color = color
    end
end

-- inject UIStroke once indicator is created
task.spawn(function()
    -- wait for the indicator to be built (it's created when targetui() is called)
    local timeout = tick() + 15
    repeat task.wait(0.5) until (Library and Library._targetUIInstance) or tick() > timeout

    local ui = Library and Library._targetUIInstance
    if not ui then return end

    local mainFrame = ui:FindFirstChildOfClass("Frame")
    if not mainFrame then return end

    -- add UIStroke for clean outline
    _indicatorStroke = Instance.new("UIStroke")
    _indicatorStroke.Color = getgenv().TargetUIBorderColor or Color3.fromRGB(27, 206, 203)
    _indicatorStroke.Thickness = 1.5
    _indicatorStroke.Transparency = 0
    _indicatorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    _indicatorStroke.Parent = mainFrame

    -- hide old OuterBorder (replaced by UIStroke)
    if Library._targetUIOuterBorder then
        Library._targetUIOuterBorder.BackgroundTransparency = 1
    end
end)

-- Add Outline Color picker to Combat > Target Indicators
local CombatTargetIndicators = getgenv().Tabs and getgenv().Tabs.Combat
if CombatTargetIndicators then
    -- AddRightGroupbox so it appears on the right side of Combat tab
    local OutlineGroup = getgenv().Tabs.Combat:AddRightGroupbox("Indicator Outline")
    OutlineGroup:AddLabel("Outline Color"):AddColorPicker('IndicatorOutlineColor', {
        Title = 'Outline Color',
        Default = Color3.fromRGB(27, 206, 203),
        Callback = function(Value)
            _applyOutlineColor(Value)
        end
    })
end

print("[Addon] Trail + Indicator Outline loaded")
