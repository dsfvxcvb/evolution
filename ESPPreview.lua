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

local parent = CoreGui
if typeof(gethui) == "function" then
	local ok, hui = pcall(gethui)
	if ok and hui and not hui:IsA("LayerCollector") then
		parent = hui
	end
end
previewGui.Parent = parent

local frame = Instance.new("Frame")
frame.Name = "PreviewFrame"
frame.Size = UDim2.fromOffset(300, 360)
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

local function createGradientFrame(name, parentFrame, z)
	local f = Instance.new("Frame")
	f.Name = name
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Visible = false
	f.ZIndex = z or 1
	f.Parent = parentFrame

	local g = Instance.new("UIGradient")
	g.Name = "Gradient"
	g.Parent = f

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 2)
	c.Parent = f
	return f, g
end

local glowFrame, glowGradient = createGradientFrame("Glow", viewport, 5)
local boxFrame, boxGradient = createGradientFrame("BoxFill", viewport, 6)
local boxStroke = Instance.new("UIStroke")
boxStroke.Thickness = 1
boxStroke.Parent = boxFrame

local healthHolder = Instance.new("Frame")
healthHolder.Name = "HealthHolder"
healthHolder.BorderSizePixel = 0
healthHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
healthHolder.Visible = false
healthHolder.ZIndex = 6
healthHolder.Parent = viewport

local healthFill = Instance.new("Frame")
healthFill.Name = "HealthFill"
healthFill.BorderSizePixel = 0
healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
healthFill.Size = UDim2.new(1, 0, 1, 0)
healthFill.Position = UDim2.new(0, 0, 0, 0)
healthFill.ZIndex = 7
healthFill.Parent = healthHolder

local function createText(name)
	local lbl = Instance.new("TextLabel")
	lbl.Name = name
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.fromOffset(120, 14)
	lbl.Visible = false
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 8
	lbl.Parent = viewport
	return lbl
end

local nameLabel = createText("ESPName")
local distLabel = createText("ESPDistance")
local weaponLabel = createText("ESPWeapon")

local function getTable()
	return EspLibrary and EspLibrary["Table"]
end

local function lerpColor(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

local function getHealthPercent()
	local char = LocalPlayer.Character
	if not char then return 1 end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return 1 end
	return math.clamp(hum.Health / hum.MaxHealth, 0, 1)
end

local function getWeaponName()
	local char = LocalPlayer.Character
	if not char then return "" end
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") then
			return c.Name
		end
	end
	return "None"
end

local function updatePreview()
	local Table = getTable()
	if not Table then
		glowFrame.Visible = false
		boxFrame.Visible = false
		healthHolder.Visible = false
		nameLabel.Visible = false
		distLabel.Visible = false
		weaponLabel.Visible = false
		return
	end

	local espEnabled = Table["Enabled"]
	local boxes = Table["Boxes"]
	local boxesEnabled = boxes and boxes["Enabled"]
	if not (espEnabled and boxesEnabled and previewModel and #previewParts > 0 and viewport.CurrentCamera) then
		glowFrame.Visible = false
		boxFrame.Visible = false
		healthHolder.Visible = false
		nameLabel.Visible = false
		distLabel.Visible = false
		weaponLabel.Visible = false
		return
	end

	local camObj = viewport.CurrentCamera
	local vpSize = viewport.AbsoluteSize
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
						minX = math.min(minX, pos.X * vpSize.X)
						minY = math.min(minY, pos.Y * vpSize.Y)
						maxX = math.max(maxX, pos.X * vpSize.X)
						maxY = math.max(maxY, pos.Y * vpSize.Y)
					end
				end
			end
		end
	end

	if not anyVisible then
		glowFrame.Visible = false
		boxFrame.Visible = false
		healthHolder.Visible = false
		nameLabel.Visible = false
		distLabel.Visible = false
		weaponLabel.Visible = false
		return
	end

	local pad = 2
	local boxX = minX
	local boxY = minY
	local boxW = math.max(maxX - minX, 2)
	local boxH = math.max(maxY - minY, 2)

	local gradTop = boxes["Gradients"] and boxes["Gradients"]["Top"] or Color3.fromRGB(0, 255, 255)
	local gradBot = boxes["Gradients"] and boxes["Gradients"]["Bot"] or Color3.fromRGB(0, 85, 255)

	local boxCfg = boxes
	local glowCfg = boxCfg["Box Glow"]
	if glowCfg and glowCfg["Enabled"] then
		local glowTop = glowCfg["Top"] or gradTop
		local glowBot = glowCfg["Bot"] or gradBot
		local t1 = glowCfg["Transparency"] and glowCfg["Transparency"][1] or 0.75
		local t2 = glowCfg["Transparency"] and glowCfg["Transparency"][2] or 0.75
		glowGradient.Color = ColorSequence.new(glowTop, glowBot)
		glowGradient.Transparency = NumberSequence.new(t1, t2)
		glowFrame.Position = UDim2.fromOffset(boxX - pad - 4, boxY - pad - 4)
		glowFrame.Size = UDim2.fromOffset(boxW + (pad + 4) * 2, boxH + (pad + 4) * 2)
		glowFrame.Visible = true
	else
		glowFrame.Visible = false
	end

	local filledCfg = boxCfg["Filled"]
	if filledCfg and filledCfg["Enabled"] then
		local fillTop = filledCfg["Top"] or gradTop
		local fillBot = filledCfg["Bot"] or gradBot
		local t1 = filledCfg["Transparency"] and filledCfg["Transparency"][1] or 1
		local t2 = filledCfg["Transparency"] and filledCfg["Transparency"][2] or 0.65
		boxGradient.Color = ColorSequence.new(fillTop, fillBot)
		boxGradient.Transparency = NumberSequence.new(t1, t2)
		boxFrame.BackgroundTransparency = 0
	else
		boxGradient.Color = ColorSequence.new(gradTop, gradBot)
		boxGradient.Transparency = NumberSequence.new(1, 1)
		boxFrame.BackgroundTransparency = 1
	end

	local outlineCfg = boxCfg["Outline"]
	if outlineCfg and outlineCfg["Enabled"] then
		boxStroke.Color = outlineCfg["Color"] or Color3.fromRGB(0, 0, 0)
		boxStroke.Thickness = math.clamp(math.floor(math.min(boxW, boxH) * 0.08 + 0.5), 1, 3)
		boxStroke.Enabled = true
	else
		boxStroke.Enabled = false
	end

	boxFrame.Position = UDim2.fromOffset(boxX, boxY)
	boxFrame.Size = UDim2.fromOffset(boxW, boxH)
	boxFrame.Visible = true

	local textsCfg = Table["Texts"]
	local barX = boxX - 10
	local barW = 4
	local barH = boxH
	local hpCfg = Table["Bars"] and Table["Bars"]["Health Bar"]
	if hpCfg and hpCfg["Enabled"] then
		healthHolder.Position = UDim2.fromOffset(barX, boxY)
		healthHolder.Size = UDim2.fromOffset(barW, barH)
		healthHolder.Visible = true
		local hp = getHealthPercent()
		healthFill.Size = UDim2.new(1, 0, hp, 0)
		healthFill.Position = UDim2.new(0, 0, 1 - hp, 0)
		local top = hpCfg["Top"] or Color3.fromRGB(0, 255, 0)
		local mid = hpCfg["Mid"] or Color3.fromRGB(255, 170, 0)
		local bot = hpCfg["Bot"] or Color3.fromRGB(255, 0, 0)
		local col
		if hp > 0.5 then
			col = lerpColor(mid, top, (hp - 0.5) * 2)
		else
			col = lerpColor(bot, mid, hp * 2)
		end
		healthFill.BackgroundColor3 = col
	else
		healthHolder.Visible = false
	end

	if textsCfg then
		local nameCfg = textsCfg["Name"]
		if nameCfg and nameCfg["Enabled"] then
			nameLabel.Text = LocalPlayer.DisplayName or LocalPlayer.Name
			nameLabel.TextColor3 = nameCfg["Color"] or gradTop
			local tw = TextService:GetTextSize(nameLabel.Text, nameLabel.TextSize, nameLabel.Font, Vector2.new(999, 999)).X
			nameLabel.Size = UDim2.fromOffset(tw + 2, 14)
			nameLabel.Position = UDim2.fromOffset(boxX, boxY - 16)
			nameLabel.Visible = true
		else
			nameLabel.Visible = false
		end

		local distCfg = textsCfg["Distance"]
		if distCfg and distCfg["Enabled"] then
			distLabel.Text = "0st"
			distLabel.TextColor3 = distCfg["Color"] or Color3.fromRGB(255, 255, 255)
			local tw = TextService:GetTextSize(distLabel.Text, distLabel.TextSize, distLabel.Font, Vector2.new(999, 999)).X
			distLabel.Size = UDim2.fromOffset(tw + 2, 14)
			distLabel.Position = UDim2.fromOffset(boxX, boxY - 30)
			distLabel.Visible = true
		else
			distLabel.Visible = false
		end

		local wepCfg = textsCfg["Weapon"]
		if wepCfg and wepCfg["Enabled"] then
			weaponLabel.Text = getWeaponName()
			weaponLabel.TextColor3 = wepCfg["Color"] or Color3.fromRGB(255, 255, 255)
			local tw = TextService:GetTextSize(weaponLabel.Text, weaponLabel.TextSize, weaponLabel.Font, Vector2.new(999, 999)).X
			weaponLabel.Size = UDim2.fromOffset(tw + 2, 14)
			weaponLabel.Position = UDim2.fromOffset(boxX, boxY + boxH + 2)
			weaponLabel.Visible = true
		else
			weaponLabel.Visible = false
		end
	else
		nameLabel.Visible = false
		distLabel.Visible = false
		weaponLabel.Visible = false
	end
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
	if modern ~= lastModern then
		lastModern = modern
	end

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
