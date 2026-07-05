local EspLibrary = getgenv().EspLibrary
local VisualsTab = getgenv().VisualsTab
local Library = getgenv().Library
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local function getColor(name, fallback)
	if Library and typeof(Library) == "table" and Library[name] then
		return Library[name]
	end
	return fallback
end

local MainColor = getColor("MainColor", Color3.fromRGB(28, 28, 28))
local BackgroundColor = getColor("BackgroundColor", Color3.fromRGB(20, 20, 20))
local AccentColor = getColor("AccentColor", Color3.fromRGB(0, 85, 255))
local OutlineColor = getColor("OutlineColor", Color3.fromRGB(50, 50, 50))
local FontColor = getColor("FontColor", Color3.new(1, 1, 1))

local previewGui = Instance.new("ScreenGui")
previewGui.Name = "ESPPreview"
previewGui.ResetOnSpawn = false
previewGui.IgnoreGuiInset = true
previewGui.Enabled = false
previewGui.Parent = typeof(gethui) == "function" and gethui() or CoreGui

local frame = Instance.new("Frame")
frame.Name = "PreviewFrame"
frame.Size = UDim2.fromOffset(280, 340)
frame.Position = UDim2.fromOffset(100, 100)
frame.BackgroundColor3 = MainColor
frame.BorderSizePixel = 0
frame.Parent = previewGui

local frameStroke = Instance.new("UIStroke")
frameStroke.Name = "FrameStroke"
frameStroke.Color = OutlineColor
frameStroke.Thickness = 1
frameStroke.Parent = frame

local frameCorner = Instance.new("UICorner")
frameCorner.Name = "ModernUICorner"
frameCorner.CornerRadius = UDim.new(0, 6)
frameCorner.Parent = frame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 26)
topBar.BackgroundColor3 = MainColor
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topBarStroke = Instance.new("UIStroke")
topBarStroke.Name = "TopBarStroke"
topBarStroke.Color = OutlineColor
topBarStroke.Thickness = 1
topBarStroke.Parent = topBar

local accentLine = Instance.new("Frame")
accentLine.Name = "AccentLine"
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = AccentColor
accentLine.BorderSizePixel = 0
accentLine.Parent = topBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.Text = "ESP Preview"
title.TextColor3 = FontColor
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local viewport = Instance.new("ViewportFrame")
viewport.Name = "Viewport"
viewport.Size = UDim2.new(1, -10, 1, -36)
viewport.Position = UDim2.new(0, 5, 0, 31)
viewport.BackgroundColor3 = BackgroundColor
viewport.BorderSizePixel = 0
viewport.Parent = frame

local viewportStroke = Instance.new("UIStroke")
viewportStroke.Name = "ViewportStroke"
viewportStroke.Color = OutlineColor
viewportStroke.Thickness = 1
viewportStroke.Parent = viewport

viewport.Ambient = Color3.new(1, 1, 1)
viewport.LightColor = Color3.new(1, 1, 1)
viewport.LightDirection = Vector3.new(1, 1, -1)

local cam = Instance.new("Camera")
cam.FieldOfView = 70
viewport.CurrentCamera = cam

local previewModel = nil
local previewParts = {}
local modelYaw = 0
local modelPitch = 0

local function clearModel()
	if previewModel then
		previewModel:Destroy()
		previewModel = nil
	end
	for i = #previewParts, 1, -1 do
		previewParts[i] = nil
	end
end

local function flattenModel(model)
	local result = {}
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			table.insert(result, desc)
		end
	end
	return result
end

local function setupModel(char)
	clearModel()
	if not char then return end

	local ok, archivable = pcall(function() return char.Archivable end)
	if ok and not archivable then
		pcall(function() char.Archivable = true end)
	end

	local ok2, clone = pcall(function() return char:Clone() end)
	if not ok2 or not clone then return end

	for _, desc in ipairs(clone:GetDescendants()) do
		if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") or desc:IsA("Humanoid") then
			desc:Destroy()
		end
	end

	local parts = flattenModel(clone)
	if #parts == 0 then
		clone:Destroy()
		return
	end

	for _, part in ipairs(parts) do
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.Velocity = Vector3.zero
		part.RotVelocity = Vector3.zero
	end

	local primary = clone:FindFirstChild("HumanoidRootPart")
		or clone:FindFirstChild("Torso")
		or clone:FindFirstChild("UpperTorso")
		or clone:FindFirstChildOfClass("BasePart")
	clone.PrimaryPart = primary

	clone:PivotTo(CFrame.new(0, 0, 0))
	clone.Parent = viewport
	previewModel = clone
	previewParts = parts

	local minPos, maxPos = Vector3.zero, Vector3.zero
	local first = true
	for _, part in ipairs(parts) do
		local cf = part.CFrame
		local hs = part.Size * 0.5
		for _, corner in ipairs({
			cf * CFrame.new(hs.X, hs.Y, hs.Z),
			cf * CFrame.new(hs.X, hs.Y, -hs.Z),
			cf * CFrame.new(hs.X, -hs.Y, hs.Z),
			cf * CFrame.new(hs.X, -hs.Y, -hs.Z),
			cf * CFrame.new(-hs.X, hs.Y, hs.Z),
			cf * CFrame.new(-hs.X, hs.Y, -hs.Z),
			cf * CFrame.new(-hs.X, -hs.Y, hs.Z),
			cf * CFrame.new(-hs.X, -hs.Y, -hs.Z),
		}) do
			local pos = corner.Position
			if first then
				minPos, maxPos = pos, pos
				first = false
			else
				minPos = Vector3.new(math.min(minPos.X, pos.X), math.min(minPos.Y, pos.Y), math.min(minPos.Z, pos.Z))
				maxPos = Vector3.new(math.max(maxPos.X, pos.X), math.max(maxPos.Y, pos.Y), math.max(maxPos.Z, pos.Z))
			end
		end
	end

	local center = (minPos + maxPos) * 0.5
	local size = maxPos - minPos
	local maxDim = math.max(size.X, size.Y)
	local distance = (maxDim / (2 * math.tan(math.rad(cam.FieldOfView) * 0.5))) * 1.25 + size.Z * 0.5
	cam.CFrame = CFrame.new(center + Vector3.new(0, 0, distance), center)
end

RunService.RenderStepped:Connect(function()
	if previewModel and previewModel.PrimaryPart then
		previewModel:PivotTo(CFrame.Angles(modelPitch, modelYaw, 0))
	end
end)

local box = Instance.new("Frame")
box.Name = "ESPBox"
box.BorderSizePixel = 0
box.BackgroundTransparency = 0.8
box.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
box.Visible = false
box.ZIndex = 10
box.Parent = viewport

local boxStroke = Instance.new("UIStroke")
boxStroke.Color = Color3.fromRGB(0, 255, 255)
boxStroke.Thickness = 1
boxStroke.Parent = box

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "ESPName"
nameLabel.Text = LocalPlayer.DisplayName or LocalPlayer.Name
nameLabel.Font = Enum.Font.Code
nameLabel.TextSize = 12
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.fromOffset(120, 14)
nameLabel.Visible = false
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.ZIndex = 10
nameLabel.Parent = viewport

local function getTable()
	return EspLibrary and EspLibrary["Table"]
end

local function updatePreview()
	local Table = getTable()
	if not Table then
		box.Visible = false
		nameLabel.Visible = false
		return
	end

	local espEnabled = Table["Enabled"]
	local boxes = Table["Boxes"]
	local boxesEnabled = boxes and boxes["Enabled"]
	if not (espEnabled and boxesEnabled and previewModel and #previewParts > 0 and viewport.CurrentCamera) then
		box.Visible = false
		nameLabel.Visible = false
		return
	end

	local topColor = boxes["Gradients"] and boxes["Gradients"]["Top"] or Color3.fromRGB(0, 255, 255)
	box.BackgroundColor3 = topColor
	boxStroke.Color = topColor
	nameLabel.TextColor3 = topColor

	local camObj = viewport.CurrentCamera
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyVisible = false

	for _, part in ipairs(previewParts) do
		local size = part.Size
		local cf = part.CFrame
		local sx, sy, sz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
		for x = -1, 1, 2 do
			for y = -1, 1, 2 do
				for z = -1, 1, 2 do
					local corner = cf * CFrame.new(x * sx, y * sy, z * sz)
					local pos, on = camObj:WorldToViewportPoint(corner.Position)
					if on and pos.Z > 0 then
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

	local width = math.max(maxX - minX, 2)
	local height = math.max(maxY - minY, 2)
	box.Position = UDim2.fromOffset(minX, minY)
	box.Size = UDim2.fromOffset(width, height)
	box.Visible = true

	local nameWidth = TextService:GetTextSize(nameLabel.Text, nameLabel.TextSize, nameLabel.Font, Vector2.new(999, 999)).X
	nameLabel.Size = UDim2.fromOffset(nameWidth + 2, 14)
	nameLabel.Position = UDim2.fromOffset(minX, minY - 16)
	nameLabel.Visible = true
end

RunService.RenderStepped:Connect(updatePreview)

LocalPlayer.CharacterAdded:Connect(setupModel)
if LocalPlayer.Character then
	setupModel(LocalPlayer.Character)
end

if Library and typeof(Library.AddToRegistry) == "function" then
	pcall(function()
		Library:AddToRegistry(frame, { BackgroundColor3 = "MainColor"; BorderColor3 = "OutlineColor"; })
		Library:AddToRegistry(frameStroke, { Color = "OutlineColor"; })
		Library:AddToRegistry(topBar, { BackgroundColor3 = "MainColor"; })
		Library:AddToRegistry(topBarStroke, { Color = "OutlineColor"; })
		Library:AddToRegistry(accentLine, { BackgroundColor3 = "AccentColor"; })
		Library:AddToRegistry(title, { TextColor3 = "FontColor"; })
		Library:AddToRegistry(viewport, { BackgroundColor3 = "BackgroundColor"; })
		Library:AddToRegistry(viewportStroke, { Color = "OutlineColor"; })
	end)
end

if VisualsTab and VisualsTab.Frame then
	local function onTabVisibility()
		previewGui.Enabled = VisualsTab.Frame.Visible
	end
	VisualsTab.Frame:GetPropertyChangedSignal("Visible"):Connect(onTabVisibility)
	onTabVisibility()
else
	previewGui.Enabled = true
end

local dragging, dragStart, startPos = false, nil, nil
topBar.InputBegan:Connect(function(input)
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

local rotating, rotateStart = false, nil
viewport.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		rotating = true
		rotateStart = input.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if rotating and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - rotateStart
		rotateStart = input.Position
		modelYaw = modelYaw - delta.X * 0.01
		modelPitch = math.clamp(modelPitch - delta.Y * 0.01, -math.rad(80), math.rad(80))
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		rotating = false
	end
end)

local lastModern = nil
local function syncModern()
	local modern = Library and Library.Modern
	if modern == lastModern then return end
	lastModern = modern

	local cornerRadius = modern and (Library.ModernCornerRadius or 8) or 6
	frameCorner.CornerRadius = UDim.new(0, cornerRadius)

	local glow = frame:FindFirstChild("ModernGlow")
	if modern then
		if not glow then
			glow = Instance.new("UIStroke")
			glow.Name = "ModernGlow"
			glow.Thickness = 1.5
			glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			glow.LineJoinMode = Enum.LineJoinMode.Round
			glow.Parent = frame
		end
		glow.Color = getColor("AccentColor", AccentColor)
	elseif glow then
		glow:Destroy()
	end
end
RunService.RenderStepped:Connect(syncModern)
