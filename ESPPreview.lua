local EspLibrary = getgenv().EspLibrary
local Table = EspLibrary and EspLibrary['Table']
local VisualsTab = getgenv().VisualsTab
local LocalPlayer = getgenv().LocalPlayer or game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local previewGui = Instance.new("ScreenGui")
previewGui.Name = "ESPPreview"
previewGui.ResetOnSpawn = false
previewGui.IgnoreGuiInset = true
previewGui.Enabled = false
previewGui.Parent = typeof(gethui) == "function" and gethui() or CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 320)
frame.Position = UDim2.fromOffset(100, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = previewGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 24)
title.Text = "ESP Preview"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.TextSize = 14
title.Parent = frame

local viewport = Instance.new("ViewportFrame")
viewport.Name = "Viewport"
viewport.Size = UDim2.new(1, -10, 1, -34)
viewport.Position = UDim2.new(0, 5, 0, 29)
viewport.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
viewport.BorderSizePixel = 0
viewport.Parent = frame

local cam = Instance.new("Camera")
cam.FieldOfView = 70
viewport.CurrentCamera = cam

local previewModel = nil
local previewParts = {}

local function clearModel()
    if previewModel then
        previewModel:Destroy()
        previewModel = nil
    end
    for i = #previewParts, 1, -1 do
        previewParts[i] = nil
    end
end

local function setupModel(char)
    clearModel()
    if not char then return end

    local ok, clone = pcall(function() return char:Clone() end)
    if not ok or not clone then return end

    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") or desc:IsA("Humanoid") then
            desc:Destroy()
        elseif desc:IsA("BasePart") then
            table.insert(previewParts, desc)
        end
    end

    local primary = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Torso") or clone:FindFirstChildOfClass("BasePart")
    if primary then
        clone.PrimaryPart = primary
    end

    clone.Parent = viewport
    previewModel = clone
end

cam.CFrame = CFrame.new(Vector3.new(5, 3, 5), Vector3.new(0, 1.5, 0))

RunService.RenderStepped:Connect(function()
    if previewModel and previewModel.PrimaryPart then
        local angle = tick() * 0.6
        previewModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, angle, 0))
    end
end)

local box = Instance.new("Frame")
box.Name = "Box"
box.BorderSizePixel = 0
box.BackgroundTransparency = 0.85
box.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
box.Visible = false
box.Parent = viewport

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 1
stroke.Parent = box

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "Name"
nameLabel.Text = LocalPlayer.DisplayName or LocalPlayer.Name
nameLabel.Font = Enum.Font.Code
nameLabel.TextSize = 12
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.fromOffset(120, 14)
nameLabel.Visible = false
nameLabel.Parent = viewport

local function updatePreview()
    if not Table then return end
    local espEnabled = Table['Enabled']
    local boxesEnabled = Table['Boxes'] and Table['Boxes']['Enabled']
    if not (espEnabled and boxesEnabled and previewModel and #previewParts > 0 and viewport.CurrentCamera) then
        box.Visible = false
        nameLabel.Visible = false
        return
    end

    local topColor = Table['Boxes']['Gradients'] and Table['Boxes']['Gradients']['Top'] or Color3.fromRGB(0, 255, 255)
    box.BackgroundColor3 = topColor
    stroke.Color = topColor
    nameLabel.TextColor3 = topColor

    local camObj = viewport.CurrentCamera
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyVisible = false

    for _, part in ipairs(previewParts) do
        local size = part.Size
        local cf = part.CFrame
        local sx, sy, sz = size.X / 2, size.Y / 2, size.Z / 2
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local corner = cf * CFrame.new(x * sx, y * sy, z * sz)
                    local pos, on = camObj:WorldToViewportPoint(corner.Position)
                    if on then
                        anyVisible = true
                        minX = math.min(minX, pos.X)
                        minY = math.min(minY, pos.Y)
                        maxX = math.max(maxX, pos.X)
                        maxY = math.max(maxY, pos.Y)
                    end
                end
            end
        end
    end

    if not anyVisible then
        box.Visible = false
        nameLabel.Visible = false
        return
    end

    box.Position = UDim2.fromOffset(minX, minY)
    box.Size = UDim2.fromOffset(math.max(maxX - minX, 2), math.max(maxY - minY, 2))
    box.Visible = true

    nameLabel.Position = UDim2.fromOffset(minX, minY - 16)
    nameLabel.Visible = true
end

RunService.RenderStepped:Connect(updatePreview)

LocalPlayer.CharacterAdded:Connect(setupModel)
if LocalPlayer.Character then
    setupModel(LocalPlayer.Character)
end

if VisualsTab and VisualsTab.Frame then
    local function onTabVisibility()
        previewGui.Enabled = VisualsTab.Frame.Visible
    end
    VisualsTab.Frame:GetPropertyChangedSignal("Visible"):Connect(onTabVisibility)
    onTabVisibility()
end

local dragging, dragStart, startPos = false, nil, nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
