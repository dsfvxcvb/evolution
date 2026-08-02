-- Trail Addon for evolution
-- Relies on Tabs global set by use_kimi.txt

if not getgenv().Tabs then
    warn("[Trail Addon] Tabs global not found - make sure use_kimi.txt loaded first")
    return
end

local VisualsTrail = getgenv().Tabs.Visuals:AddRightGroupbox("Trail")

local _trailAtt0, _trailAtt1, _trailMain, _trailGlow

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
    _trailAtt0.Position = Vector3.new(0, 0.2, 0)
    _trailAtt0.Parent = hrp

    _trailAtt1 = Instance.new("Attachment")
    _trailAtt1.Position = Vector3.new(0, -0.2, 0)
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
        NumberSequenceKeypoint.new(0, 0.07),
        NumberSequenceKeypoint.new(0.85, 0.07),
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
        NumberSequenceKeypoint.new(0, 0.28),
        NumberSequenceKeypoint.new(0.85, 0.28),
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

VisualsTrail:AddDropdown('TrailStyle', {
    Text = 'Style',
    Values = {'Flame'},
    Default = 'Flame',
    Callback = function(Value) end
})

VisualsTrail:AddDropdown('TrailFlat', {
    Text = 'Flat',
    Values = {'Off', 'On'},
    Default = 'Off',
    Callback = function(Value) end
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

print("[Trail Addon] Loaded successfully")
