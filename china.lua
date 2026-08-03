-- China Hat Addon for evolution
-- Run AFTER use_kimi.txt has loaded

if not getgenv().Tabs then
    warn("[China Hat] Tabs global not found")
    return
end

local VisualsChinaHat = getgenv().Tabs.Visuals:AddRightGroupbox('China Hat')

local _hatEnabled = false
local _hatColor1 = Color3.fromRGB(160, 185, 220)
local _hatColor2 = Color3.fromRGB(90, 120, 180)
local _hatTransparency = 0.35
local _hatHeight = 1.8
local _hatWidth = 1.4

local BRIM_SEGMENTS = 48
local RIB_COUNT = 18
local _brimSegments = 48
local _ribCount = 18
local HEAD_Y_OFFSET = 0

local _fillTris = {}
local _brimLines = {}
local _glowLines = {}
local _ribLines = {}
local _tipDot = nil
local _hatConn = nil

local function _destroyHat()
    for _, t in ipairs(_fillTris) do pcall(function() t:Remove() end) end
    for _, l in ipairs(_brimLines) do pcall(function() l:Remove() end) end
    for _, l in ipairs(_glowLines) do pcall(function() l:Remove() end) end
    for _, l in ipairs(_ribLines) do pcall(function() l:Remove() end) end
    if _tipDot then pcall(function() _tipDot:Remove() end) end
    _fillTris = {} _brimLines = {} _glowLines = {} _ribLines = {} _tipDot = nil
    if _hatConn then _hatConn:Disconnect() _hatConn = nil end
end

local function _buildHat()
    _destroyHat()

    BRIM_SEGMENTS = _brimSegments
    RIB_COUNT = _ribCount
    for i = 1, BRIM_SEGMENTS do
        local t = Drawing.new("Triangle")
        t.Color = _hatColor1
        t.Filled = true
        t.Transparency = _hatTransparency
        t.ZIndex = 1
        t.Visible = false
        table.insert(_fillTris, t)
    end
    for i = 1, BRIM_SEGMENTS do
        local l = Drawing.new("Line")
        l.Color = _hatColor1
        l.Transparency = 1
        l.Thickness = 1.5
        l.ZIndex = 3
        l.Visible = false
        table.insert(_brimLines, l)
    end
    for i = 1, BRIM_SEGMENTS do
        local l = Drawing.new("Line")
        l.Color = _hatColor2
        l.Transparency = 0.3
        l.Thickness = 5
        l.ZIndex = 0
        l.Visible = false
        table.insert(_glowLines, l)
    end
    for i = 1, RIB_COUNT do
        local l = Drawing.new("Line")
        l.Color = _hatColor1
        l.Transparency = 0.6
        l.Thickness = 1
        l.ZIndex = 2
        l.Visible = false
        table.insert(_ribLines, l)
    end
    _tipDot = Drawing.new("Circle")
    _tipDot.Filled = true
    _tipDot.Color = _hatColor1
    _tipDot.Transparency = 0.7
    _tipDot.NumSides = 12
    _tipDot.Radius = 1.5
    _tipDot.ZIndex = 4
    _tipDot.Visible = false

    local cam = workspace.CurrentCamera
    local lp = game:GetService("Players").LocalPlayer

    local function setAllVisible(v)
        for _, t in ipairs(_fillTris) do t.Visible = v end
        for _, l in ipairs(_brimLines) do l.Visible = v end
        for _, l in ipairs(_glowLines) do l.Visible = v end
        for _, l in ipairs(_ribLines) do l.Visible = v end
        if _tipDot then _tipDot.Visible = v end
    end

    _hatConn = game:GetService("RunService").RenderStepped:Connect(function()
        if not _hatEnabled then setAllVisible(false) return end
        local char = lp.Character
        local head = char and char:FindFirstChild("Head")
        if not head then setAllVisible(false) return end

        local headTop = head.CFrame.Position + Vector3.new(0, head.Size.Y/2 + HEAD_Y_OFFSET, 0)
        local hatCF = CFrame.new(headTop)

        local brimPoints = {}
        for i = 1, BRIM_SEGMENTS do
            local angle = (i / BRIM_SEGMENTS) * math.pi * 2
            local world = hatCF:PointToWorldSpace(Vector3.new(math.cos(angle)*_hatWidth, 0, math.sin(angle)*_hatWidth))
            local sp, onScreen = cam:WorldToViewportPoint(world)
            table.insert(brimPoints, {screen = Vector2.new(sp.X, sp.Y), z = sp.Z, onScreen = onScreen})
        end

        local tipWorld = hatCF:PointToWorldSpace(Vector3.new(0, _hatHeight, 0))
        local tsp, tipOnScreen = cam:WorldToViewportPoint(tipWorld)
        local tipZ = tsp.Z
        local tipScreen = Vector2.new(tsp.X, tsp.Y)
        if tipZ <= 0 then setAllVisible(false) return end

        for i = 1, BRIM_SEGMENTS do
            local a = brimPoints[i]
            local b = brimPoints[(i % BRIM_SEGMENTS) + 1]
            local show = a.z > 0 and b.z > 0
            _fillTris[i].PointA = tipScreen
            _fillTris[i].PointB = a.screen
            _fillTris[i].PointC = b.screen
            _fillTris[i].Color = _hatColor1
            _fillTris[i].Transparency = _hatTransparency
            _fillTris[i].Visible = show
            _brimLines[i].From = a.screen
            _brimLines[i].To = b.screen
            _brimLines[i].Color = _hatColor1
            _brimLines[i].Visible = show
            _glowLines[i].From = a.screen
            _glowLines[i].To = b.screen
            _glowLines[i].Color = _hatColor2
            _glowLines[i].Visible = show
        end

        for i = 1, RIB_COUNT do
            local angle = (i / RIB_COUNT) * math.pi * 2
            local world = hatCF:PointToWorldSpace(Vector3.new(math.cos(angle)*_hatWidth, 0, math.sin(angle)*_hatWidth))
            local sp = cam:WorldToViewportPoint(world)
            local screen = Vector2.new(sp.X, sp.Y)
            local z = sp.Z
            local ribDir = (world - cam.CFrame.Position).Unit
            local dot = ribDir:Dot(cam.CFrame.LookVector)
            _ribLines[i].From = tipScreen
            _ribLines[i].To = screen
            _ribLines[i].Color = _hatColor1
            _ribLines[i].Transparency = math.clamp(0.4 + dot * 0.3, 0.35, 0.8)
            _ribLines[i].Visible = z > 0 and tipZ > 0
        end

        _tipDot.Position = tipScreen
        _tipDot.Color = _hatColor1
        _tipDot.Visible = true
    end)
end

VisualsChinaHat:AddToggle('ChinaHatUse', {
    Text = 'Use',
    Default = false,
    Callback = function(Value)
        _hatEnabled = Value
        if Value then _buildHat() else _destroyHat() end
    end
}):AddColorPicker('ChinaHatColor1', {
    Title = 'Hat Color',
    Default = Color3.fromRGB(160, 185, 220),
    Callback = function(Value) _hatColor1 = Value end
}):AddColorPicker('ChinaHatColor2', {
    Title = 'Glow Color',
    Default = Color3.fromRGB(90, 120, 180),
    Callback = function(Value) _hatColor2 = Value end
})

VisualsChinaHat:AddSlider('ChinaHatTransparency', {
    Text = 'Transparency',
    Min = 0,
    Max = 100,
    Default = 35,
    Rounding = 0,
    Callback = function(Value) _hatTransparency = Value / 100 end
})

VisualsChinaHat:AddSlider('ChinaHatHeight', {
    Text = 'Height',
    Min = 1,
    Max = 100,
    Default = 18,
    Rounding = 0,
    Callback = function(Value) _hatHeight = Value / 10 end
})

VisualsChinaHat:AddSlider('ChinaHatWidth', {
    Text = 'Width',
    Min = 1,
    Max = 100,
    Default = 14,
    Rounding = 0,
    Callback = function(Value) _hatWidth = Value / 10 end
})

VisualsChinaHat:AddSlider('ChinaHatSides', {
    Text = 'Sides',
    Min = 3,
    Max = 64,
    Default = 48,
    Rounding = 0,
    Callback = function(Value)
        _brimSegments = Value
        _ribCount = Value
        if _hatEnabled then _buildHat() end
    end
})

print("[China Hat] Loaded")
print("sinister equal")
