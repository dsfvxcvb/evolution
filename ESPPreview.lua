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

local CornerLayout = {
	{UDim2.new(0, -1, 0, -1), UDim2.new(0.3, 0, 0, 1), Vector2.new(0, 0), 0},
	{UDim2.new(0, -1, 0, -1), UDim2.new(0, 1, 0.3, 0), Vector2.new(0, 0), 180},
	{UDim2.new(1, 1, 0, -1), UDim2.new(0.3, 0, 0, 1), Vector2.new(1, 0), 0},
	{UDim2.new(1, 1, 0, -1), UDim2.new(0, 1, 0.3, 0), Vector2.new(1, 0), 180},
	{UDim2.new(0, -1, 1, 1), UDim2.new(0.3, 0, 0, 1), Vector2.new(0, 1), 0},
	{UDim2.new(0, -1, 1, 1), UDim2.new(0, 1, 0.3, 0), Vector2.new(0, 1), -180},
	{UDim2.new(1, 1, 1, 1), UDim2.new(0.3, 0, 0, 1), Vector2.new(1, 1), 0},
	{UDim2.new(1, 1, 1, 1), UDim2.new(0, 1, 0.3, 0), Vector2.new(1, 1), -180},
}

local Objects = {}

local function newFrame(name, props)
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	for k, v in pairs(props or {}) do
		f[k] = v
	end
	return f
end

local function newText(name, props)
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Text = ""
	t.TextSize = 12
	t.BackgroundTransparency = 1
	t.BorderSizePixel = 0
	t.TextXAlignment = Enum.TextXAlignment.Center
	t.TextYAlignment = Enum.TextYAlignment.Center
	t.ZIndex = 5
	t.AutomaticSize = Enum.AutomaticSize.XY
	t.Size = UDim2.fromOffset(0, 0)
	for k, v in pairs(props or {}) do
		t[k] = v
	end
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Parent = t
	return t
end

local function newListLayout(props)
	local l = Instance.new("UIListLayout")
	for k, v in pairs(props or {}) do
		l[k] = v
	end
	return l
end

local function newPadding(props)
	local p = Instance.new("UIPadding")
	for k, v in pairs(props or {}) do
		p[k] = v
	end
	return p
end

local function newGradient(props)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	for k, v in pairs(props or {}) do
		g[k] = v
	end
	return g
end

local function getFontFace(libraryFont, fallbackEnum)
	if typeof(libraryFont) == "Font" then
		return libraryFont
	end
	if typeof(fallbackEnum) == "EnumItem" then
		local ok, face = pcall(function() return Font.fromEnum(fallbackEnum) end)
		if ok then return face end
	end
	return nil
end

local function createEspOverlay()
	local targetHolder = newFrame("TargetHolder", {
		Parent = viewport,
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 0),
	})
	Objects["TargetHolder"] = targetHolder

	local topHolder = newFrame("TopHolder", {
		Parent = targetHolder,
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, -2, 0, -5),
		Size = UDim2.new(1, 4, 0, 0),
	})
	Objects["TopHolder"] = topHolder

	local bottomHolder = newFrame("BottomHolder", {
		Parent = targetHolder,
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, -2, 1, 3),
		Size = UDim2.new(1, 4, 0, 0),
	})
	Objects["BottomHolder"] = bottomHolder

	local leftHolder = newFrame("LeftHolder", {
		Parent = targetHolder,
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, -5, 0, -2),
		Size = UDim2.new(0, 0, 1, 4),
	})
	Objects["LeftHolder"] = leftHolder

	local rightHolder = newFrame("RightHolder", {
		Parent = targetHolder,
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(1, 5, 0, -2),
		Size = UDim2.new(0, 0, 1, 4),
	})
	Objects["RightHolder"] = rightHolder

	local topTextHolder = newFrame("TopTextHolder", {
		Parent = topHolder,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})
	Objects["TopTextHolder"] = topTextHolder

	local bottomTextHolder = newFrame("BottomTextHolder", {
		Parent = bottomHolder,
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})
	Objects["BottomTextHolder"] = bottomTextHolder

	local leftTextHolder = newFrame("LeftTextHolder", {
		Parent = leftHolder,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(1, 0, 0, 0),
	})
	Objects["LeftTextHolder"] = leftTextHolder

	local rightTextHolder = newFrame("RightTextHolder", {
		Parent = rightHolder,
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(0, 0, 0, 0),
	})
	Objects["RightTextHolder"] = rightTextHolder

	newListLayout({
		Parent = topTextHolder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = bottomTextHolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, -1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = leftTextHolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = rightTextHolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = topHolder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = bottomHolder,
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = leftHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	newListLayout({
		Parent = rightHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	newPadding({ Parent = topTextHolder, PaddingBottom = UDim.new(0, 0) })
	newPadding({ Parent = bottomTextHolder, PaddingTop = UDim.new(0, -1) })
	newPadding({ Parent = leftTextHolder, PaddingTop = UDim.new(0, -3) })
	newPadding({ Parent = rightTextHolder, PaddingTop = UDim.new(0, -3) })
	newPadding({ Parent = leftHolder, PaddingRight = UDim.new(0, 1) })

	local boxGlow = Instance.new("ImageLabel")
	boxGlow.Name = "BoxGlow"
	boxGlow.Parent = targetHolder
	boxGlow.Image = "rbxassetid://110204605000367"
	boxGlow.ScaleType = Enum.ScaleType.Slice
	boxGlow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
	boxGlow.AutomaticSize = Enum.AutomaticSize.XY
	boxGlow.ImageTransparency = 0.65
	boxGlow.ResampleMode = Enum.ResamplerMode.Pixelated
	boxGlow.Visible = true
	boxGlow.BackgroundTransparency = 1
	boxGlow.Position = UDim2.new(0, -21, 0, -21)
	boxGlow.Size = UDim2.fromOffset(0, 0)
	boxGlow.BorderSizePixel = 0
	Objects["BoxGlow"] = boxGlow

	Objects["BoxGlowGradient"] = newGradient({
		Parent = boxGlow,
		Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
		Transparency = NumberSequence.new(0, 0),
	})

	newPadding({
		Parent = boxGlow,
		PaddingTop = UDim.new(0, 21),
		PaddingBottom = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 21),
		PaddingRight = UDim.new(0, 20),
	})

	local boxOutlineHolder = newFrame("BoxOutlineHolder", {
		Parent = boxGlow,
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 0),
	})
	Objects["BoxOutlineHolder"] = boxOutlineHolder

	local boxOutline = Instance.new("UIStroke")
	boxOutline.Name = "BoxOutline"
	boxOutline.Parent = boxOutlineHolder
	boxOutline.Thickness = 3
	boxOutline.LineJoinMode = Enum.LineJoinMode.Miter
	Objects["BoxOutline"] = boxOutline

	Objects["BoxOutlineGradient"] = newGradient({
		Parent = boxOutline,
		Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
		Transparency = NumberSequence.new(0, 0),
	})

	local boxInlineHolder = newFrame("BoxInlineHolder", {
		Parent = boxGlow,
		Visible = false,
		Position = UDim2.new(0, -1, 0, -1),
		Size = UDim2.fromOffset(0, 0),
	})
	Objects["BoxInlineHolder"] = boxInlineHolder

	local boxInline = Instance.new("UIStroke")
	boxInline.Name = "BoxInline"
	boxInline.Parent = boxInlineHolder
	boxInline.Color = Color3.fromRGB(255, 255, 255)
	boxInline.Thickness = 2
	boxInline.LineJoinMode = Enum.LineJoinMode.Miter
	Objects["BoxInline"] = boxInline

	Objects["BoxInlineGradient"] = newGradient({
		Parent = boxInline,
		Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 85, 255)),
		Transparency = NumberSequence.new(0, 0),
	})

	local boxFill = newFrame("BoxFill", {
		Parent = boxGlow,
		Visible = false,
		BackgroundTransparency = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 0),
	})
	Objects["BoxFill"] = boxFill

	Objects["BoxFillGradient"] = newGradient({
		Parent = boxFill,
		Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new(1, 1),
	})

	local cornerHolder = newFrame("CornerHolder", {
		Parent = boxGlow,
		Visible = false,
		Position = UDim2.new(0, -1, 0, -1),
		Size = UDim2.fromOffset(0, 0),
	})
	Objects["CornerHolder"] = cornerHolder

	for i = 1, 8 do
		local line = newFrame("Line_" .. i, {
			Parent = cornerHolder,
			Visible = false,
			BackgroundTransparency = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(0, 0),
		})
		Objects["Line_" .. i] = line
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
		stroke.Parent = line
	end

	local healthBarHolder = newFrame("HealthBarHolder", {
		Parent = targetHolder,
		ZIndex = 5,
		Visible = false,
		Position = UDim2.new(0, -5, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
	})
	Objects["HealthBarHolder"] = healthBarHolder

	local healthBarOutline = newFrame("HealthBarOutline", {
		Parent = healthBarHolder,
		ZIndex = 5,
		Visible = false,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = false,
	})
	Objects["HealthBarOutline"] = healthBarOutline

	local outlineStroke = Instance.new("UIStroke")
	outlineStroke.Thickness = 1
	outlineStroke.LineJoinMode = Enum.LineJoinMode.Miter
	outlineStroke.Parent = healthBarOutline

	local healthBar = newFrame("HealthBar", {
		Parent = healthBarOutline,
		ZIndex = 6,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = true,
	})
	Objects["HealthBar"] = healthBar

	Objects["HealthBarGradient"] = newGradient({
		Parent = healthBar,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Transparency = NumberSequence.new(0, 0),
	})

	local healthBarText = newText("HealthBarText", {
		Parent = healthBarOutline,
		FontFace = getFontFace(EspLibrary and EspLibrary.SmallestPixel, Enum.Font.SourceSans),
		TextSize = 9,
		ZIndex = 10,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, 0),
	})
	Objects["HealthBarText"] = healthBarText

	local targetName = newText("TargetName", {
		Parent = topTextHolder,
		FontFace = getFontFace(EspLibrary and EspLibrary.TahomaBold, Enum.Font.Code),
		TextSize = 12,
		LayoutOrder = 2,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Visible = false,
	})
	Objects["TargetName"] = targetName

	local distance = newText("Distance", {
		Parent = bottomTextHolder,
		FontFace = getFontFace(EspLibrary and EspLibrary.SmallestPixel, Enum.Font.SourceSans),
		TextSize = 9,
		LayoutOrder = 2,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Visible = false,
	})
	Objects["Distance"] = distance

	local walkFlag = newText("WalkFlag", {
		Parent = rightTextHolder,
		FontFace = getFontFace(EspLibrary and EspLibrary.SmallestPixel, Enum.Font.SourceSans),
		TextSize = 9,
		LayoutOrder = 1,
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Walking",
		Visible = false,
	})
	Objects["WalkFlag"] = walkFlag

	local jumpFlag = newText("JumpFlag", {
		Parent = rightTextHolder,
		FontFace = getFontFace(EspLibrary and EspLibrary.SmallestPixel, Enum.Font.SourceSans),
		TextSize = 9,
		LayoutOrder = 2,
		TextColor3 = Color3.fromRGB(144, 238, 144),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Jumping",
		Visible = false,
	})
	Objects["JumpFlag"] = jumpFlag

	local swimmingFlag = newText("SwimmingFlag", {
		Parent = rightTextHolder,
		FontFace = getFontFace(EspLibrary and EspLibrary.SmallestPixel, Enum.Font.SourceSans),
		TextSize = 9,
		LayoutOrder = 4,
		TextColor3 = Color3.fromRGB(0, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Swimming",
		Visible = false,
	})
	Objects["SwimmingFlag"] = swimmingFlag

	local weapon = newText("Weapon", {
		Parent = bottomTextHolder,
		FontFace = getFontFace(EspLibrary and EspLibrary.SmallestPixel, Enum.Font.SourceSans),
		TextSize = 9,
		LayoutOrder = 3,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "none",
		Visible = false,
	})
	Objects["Weapon"] = weapon
end

createEspOverlay()

local function getTable()
	return EspLibrary and EspLibrary["Table"]
end

local function getHealthData()
	local char = LocalPlayer.Character
	if not char then return 100, 100 end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return 100, 100 end
	return hum.Health, hum.MaxHealth
end

local function getWeaponName()
	local char = LocalPlayer.Character
	if not char then return "none" end
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") then
			return c.Name
		end
	end
	return "none"
end

local function setVisible(obj, visible)
	if obj and obj.Visible ~= visible then
		obj.Visible = visible
	end
end

local function updatePreview()
	local Table = getTable()
	if not Table or not previewModel or #previewParts == 0 or not viewport.CurrentCamera then
		setVisible(Objects["TargetHolder"], false)
		return
	end

	local espEnabled = Table["Enabled"]
	local boxesCfg = Table["Boxes"]
	if not (espEnabled and boxesCfg and boxesCfg["Enabled"]) then
		setVisible(Objects["TargetHolder"], false)
		return
	end

	local camObj = viewport.CurrentCamera
	local vpSize = viewport.AbsoluteSize
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyVisible = false

	for _, part in ipairs(previewParts) do
		if part:IsA("BasePart") and part.Transparency < 1 then
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
							local px = pos.X * vpSize.X
							local py = pos.Y * vpSize.Y
							if px < minX then minX = px end
							if py < minY then minY = py end
							if px > maxX then maxX = px end
							if py > maxY then maxY = py end
						end
					end
				end
			end
		end
	end

	if not anyVisible then
		setVisible(Objects["TargetHolder"], false)
		return
	end

	local bboxCfg = boxesCfg["Bounding Box"] or {}
	local padX = bboxCfg["BoxX"] or 0
	local padY = bboxCfg["BoxY"] or 0
	local W = math.max(math.floor((maxX - minX) + padX), 2)
	local H = math.max(math.floor((maxY - minY) + padY), 2)
	local X = math.floor(minX - (padX * 0.5))
	local Y = math.floor(minY - (padY * 0.5))

	local targetHolder = Objects["TargetHolder"]
	targetHolder.Position = UDim2.fromOffset(X, Y)
	targetHolder.Size = UDim2.fromOffset(W, H)
	setVisible(targetHolder, true)

	Objects["BoxGlow"].Size = UDim2.fromOffset(W, H)
	Objects["BoxOutlineHolder"].Size = UDim2.fromOffset(W, H)
	Objects["BoxInlineHolder"].Size = UDim2.fromOffset(W + 2, H + 2)
	Objects["BoxFill"].Size = UDim2.fromOffset(W, H)
	Objects["CornerHolder"].Size = UDim2.fromOffset(W + 2, H + 2)

	local minDim = math.min(W, H)
	Objects["BoxOutline"].Thickness = math.clamp(math.floor(minDim * 0.08 + 0.5), 1, 3)
	Objects["BoxInline"].Thickness = math.clamp(math.floor(minDim * 0.05 + 0.5), 1, 2)

	local gradTop = boxesCfg["Gradients"] and boxesCfg["Gradients"]["Top"] or Color3.fromRGB(0, 255, 255)
	local gradBot = boxesCfg["Gradients"] and boxesCfg["Gradients"]["Bot"] or Color3.fromRGB(0, 85, 255)

	local glowCfg = boxesCfg["Box Glow"]
	if glowCfg and glowCfg["Enabled"] then
		Objects["BoxGlow"].ImageTransparency = 0
		local glowTop = glowCfg["Top"] or gradTop
		local glowBot = glowCfg["Bot"] or gradBot
		Objects["BoxGlowGradient"].Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, glowTop),
			ColorSequenceKeypoint.new(1, glowBot),
		})
		local t1 = glowCfg["Transparency"] and glowCfg["Transparency"][1] or 0.75
		local t2 = glowCfg["Transparency"] and glowCfg["Transparency"][2] or 0.75
		Objects["BoxGlowGradient"].Transparency = NumberSequence.new(t1, t2)
	else
		Objects["BoxGlow"].ImageTransparency = 1
	end

	local boxType = boxesCfg["Type"]
	if boxType == "Corner" then
		setVisible(Objects["BoxOutlineHolder"], false)
		setVisible(Objects["BoxInlineHolder"], false)
		setVisible(Objects["BoxFill"], false)
		setVisible(Objects["CornerHolder"], true)
		for i = 1, 8 do
			local line = Objects["Line_" .. i]
			local layout = CornerLayout[i]
			line.Position = layout[1]
			line.Size = layout[2]
			line.AnchorPoint = layout[3]
			line.Rotation = layout[4]
			line.BackgroundColor3 = gradTop
			line.BackgroundTransparency = 0
			local stroke = line:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = gradTop
			end
			setVisible(line, true)
		end
	else
		setVisible(Objects["CornerHolder"], false)
		for i = 1, 8 do
			setVisible(Objects["Line_" .. i], false)
		end

		local outlineCfg = boxesCfg["Outline"]
		if outlineCfg and outlineCfg["Enabled"] then
			setVisible(Objects["BoxOutlineHolder"], true)
			local outlineColor = outlineCfg["Color"] or Color3.fromRGB(0, 0, 0)
			Objects["BoxOutlineGradient"].Color = ColorSequence.new(outlineColor, outlineColor)
		else
			setVisible(Objects["BoxOutlineHolder"], false)
		end

		setVisible(Objects["BoxInlineHolder"], true)
		Objects["BoxInlineGradient"].Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, gradTop),
			ColorSequenceKeypoint.new(1, gradBot),
		})

		local filledCfg = boxesCfg["Filled"]
		if filledCfg and filledCfg["Enabled"] then
			setVisible(Objects["BoxFill"], true)
			local fillTop = filledCfg["Top"] or gradTop
			local fillBot = filledCfg["Bot"] or gradBot
			Objects["BoxFillGradient"].Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, fillTop),
				ColorSequenceKeypoint.new(1, fillBot),
			})
			local ft1 = filledCfg["Transparency"] and filledCfg["Transparency"][1] or 1
			local ft2 = filledCfg["Transparency"] and filledCfg["Transparency"][2] or 0.65
			Objects["BoxFillGradient"].Transparency = NumberSequence.new(ft1, ft2)
		else
			setVisible(Objects["BoxFill"], false)
		end
	end

	local textsCfg = Table["Texts"]
	if textsCfg then
		local nameCfg = textsCfg["Name"]
		if nameCfg and nameCfg["Enabled"] then
			Objects["TargetName"].Text = LocalPlayer.DisplayName or LocalPlayer.Name
			Objects["TargetName"].TextColor3 = nameCfg["Color"] or gradTop
			setVisible(Objects["TargetName"], true)
		else
			setVisible(Objects["TargetName"], false)
		end

		local distCfg = textsCfg["Distance"]
		if distCfg and distCfg["Enabled"] then
			Objects["Distance"].Text = "0st"
			Objects["Distance"].TextColor3 = distCfg["Color"] or Color3.fromRGB(255, 255, 255)
			setVisible(Objects["Distance"], true)
		else
			setVisible(Objects["Distance"], false)
		end

		local weaponCfg = textsCfg["Weapon"]
		if weaponCfg and weaponCfg["Enabled"] then
			Objects["Weapon"].Text = getWeaponName()
			Objects["Weapon"].TextColor3 = weaponCfg["Color"] or Color3.fromRGB(255, 255, 255)
			setVisible(Objects["Weapon"], true)
		else
			setVisible(Objects["Weapon"], false)
		end
	else
		setVisible(Objects["TargetName"], false)
		setVisible(Objects["Distance"], false)
		setVisible(Objects["Weapon"], false)
	end

	local flagsCfg = Table["Flags"]
	if flagsCfg then
		local walkCfg = flagsCfg["Walking"]
		if walkCfg and walkCfg["Enabled"] then
			Objects["WalkFlag"].Text = walkCfg["Text"] or "Walking"
			Objects["WalkFlag"].TextColor3 = walkCfg["Color"] or Color3.fromRGB(255, 0, 0)
			setVisible(Objects["WalkFlag"], true)
		else
			setVisible(Objects["WalkFlag"], false)
		end

		local jumpCfg = flagsCfg["Jumping"]
		if jumpCfg and jumpCfg["Enabled"] then
			Objects["JumpFlag"].Text = jumpCfg["Text"] or "Jumping"
			Objects["JumpFlag"].TextColor3 = jumpCfg["Color"] or Color3.fromRGB(144, 238, 144)
			setVisible(Objects["JumpFlag"], true)
		else
			setVisible(Objects["JumpFlag"], false)
		end

		local swimCfg = flagsCfg["Swimming"]
		if swimCfg and swimCfg["Enabled"] then
			Objects["SwimmingFlag"].Text = swimCfg["Text"] or "Swimming"
			Objects["SwimmingFlag"].TextColor3 = swimCfg["Color"] or Color3.fromRGB(0, 255, 255)
			setVisible(Objects["SwimmingFlag"], true)
		else
			setVisible(Objects["SwimmingFlag"], false)
		end
	else
		setVisible(Objects["WalkFlag"], false)
		setVisible(Objects["JumpFlag"], false)
		setVisible(Objects["SwimmingFlag"], false)
	end

	local barsCfg = Table["Bars"]
	local healthCfg = barsCfg and barsCfg["Health Bar"]
	if healthCfg and healthCfg["Enabled"] then
		local health, maxHealth = getHealthData()
		local ratio = math.clamp(health / maxHealth, 0, 1)
		local position = healthCfg["Position"] or "Left"

		setVisible(Objects["HealthBarHolder"], true)
		setVisible(Objects["HealthBarOutline"], true)

		local layouts = {
			Left = {
				HolderPos = UDim2.new(0, -8, 0, 0),
				HolderSize = UDim2.new(0, 2, 1, 0),
				BarAnchor = Vector2.new(0, 1),
				BarPos = UDim2.new(0, 0, 1, 0),
				Rotation = 90,
			},
			Right = {
				HolderPos = UDim2.new(1, 6, 0, 0),
				HolderSize = UDim2.new(0, 2, 1, 0),
				BarAnchor = Vector2.new(0, 1),
				BarPos = UDim2.new(0, 0, 1, 0),
				Rotation = 90,
			},
			Bottom = {
				HolderPos = UDim2.new(0, 0, 1, 6),
				HolderSize = UDim2.new(1, 0, 0, 2),
				BarAnchor = Vector2.new(0, 0),
				BarPos = UDim2.new(0, 0, 0, 0),
				Rotation = 0,
			},
		}
		local layout = layouts[position] or layouts.Left
		Objects["HealthBarHolder"].Position = layout.HolderPos
		Objects["HealthBarHolder"].Size = layout.HolderSize
		Objects["HealthBar"].AnchorPoint = layout.BarAnchor
		Objects["HealthBar"].Position = layout.BarPos
		Objects["HealthBarGradient"].Rotation = layout.Rotation

		local fillSize = position == "Bottom" and UDim2.new(ratio, 0, 1, 0) or UDim2.new(1, 0, ratio, 0)
		Objects["HealthBar"].Size = fillSize

		local topCol = healthCfg["Top"] or Color3.fromRGB(0, 255, 0)
		local midCol = healthCfg["Mid"] or Color3.fromRGB(255, 170, 0)
		local botCol = healthCfg["Bot"] or Color3.fromRGB(255, 0, 0)
		Objects["HealthBarGradient"].Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, topCol),
			ColorSequenceKeypoint.new(0.5, midCol),
			ColorSequenceKeypoint.new(1, botCol),
		})

		local textCfg = healthCfg["Text"]
		if textCfg and textCfg["Enabled"] then
			Objects["HealthBarText"].TextColor3 = textCfg["Color"] or Color3.fromRGB(255, 255, 255)
			Objects["HealthBarText"].Text = tostring(math.floor(health))
			if position == "Bottom" then
				Objects["HealthBarText"].Position = UDim2.new(ratio, 0, 1, 4)
			elseif position == "Right" then
				Objects["HealthBarText"].Position = UDim2.new(1, 4, 1 - ratio, 0)
			else
				Objects["HealthBarText"].Position = UDim2.new(0, -4, 1 - ratio, 0)
			end
			setVisible(Objects["HealthBarText"], true)
		else
			setVisible(Objects["HealthBarText"], false)
		end
	else
		setVisible(Objects["HealthBarHolder"], false)
		setVisible(Objects["HealthBarOutline"], false)
		setVisible(Objects["HealthBarText"], false)
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
