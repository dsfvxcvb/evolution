local library, themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/dsfvxcvb/evolution/main/library.lua"))()
print("[Atlanta] loaded library from github")

local dim2 = UDim2.new
local dim = UDim.new
local hex = Color3.fromHex
local rgb = Color3.fromRGB
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new 

-- documentation 
	-- Capture panels created by library:window so we can combine Style + Config later
	local originalPanel = library.panel
	local capturedPanels = {}
	library.panel = function(self, options)
		local panel = originalPanel(self, options)
		table.insert(capturedPanels, {panel = panel, options = options})
		return panel
	end

	local window = library:window({name = os.date('Atlanta |  - %b %d %Y'), size = dim2(0, 750, 0, 782)})

	-- Restore original panel constructor
	library.panel = originalPanel

	-- Identify the panels library:window created
	local mainPanel, stylePanel, configPanel, espPanel, playerlistPanel
	for _, entry in ipairs(capturedPanels) do
		local img = entry.options and entry.options.image
		if img == "rbxassetid://98823308062942" then
			mainPanel = entry.panel
		elseif img == "rbxassetid://115194686863276" then
			stylePanel = entry.panel
		elseif img == "rbxassetid://105199726008012" then
			configPanel = entry.panel
		elseif img == "rbxassetid://77684377836328" then
			espPanel = entry.panel
		elseif img == "rbxassetid://107070078834415" then
			playerlistPanel = entry.panel
		end
	end

	-- Combined Settings window (Style + Configuration as native-looking tabs)
	local settingsPanel = library:panel({
		name = "Settings", 
		anchor_point = Vector2.new(0, 0),
		size = dim2(0, 420, 0, 520),
		position = dim2(0, mainPanel.items.main_holder.AbsolutePosition.X + mainPanel.items.main_holder.AbsoluteSize.X + 2, 0, mainPanel.items.main_holder.AbsolutePosition.Y),
		image = "rbxassetid://115194686863276",
	})

	local settingsColumn = setmetatable(settingsPanel.items, library):column()

	-- Tab bar
	local tabBar = library:create("Frame", {
		Parent = settingsColumn.holder,
		Name = "",
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		Size = dim2(1, 0, 0, 21),
		BorderSizePixel = 0,
	})

	library:create("UIListLayout", {
		Parent = tabBar,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = dim(0, -3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	-- Content holders
	local styleHolder = library:create("ScrollingFrame", {
		Parent = settingsColumn.holder,
		Name = "",
		Size = dim2(1, 0, 1, -21),
		Position = dim2(0, 0, 0, 21),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = true,
	})

	library:create("UIListLayout", {
		Parent = styleHolder,
		Padding = dim(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local configHolder = library:create("ScrollingFrame", {
		Parent = settingsColumn.holder,
		Name = "",
		Size = dim2(1, 0, 1, -21),
		Position = dim2(0, 0, 0, 21),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	})

	library:create("UIListLayout", {
		Parent = configHolder,
		Padding = dim(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	-- Native-looking tab buttons (same structure as library:tab)
	local tabs = {}
	local function createTab(name, holder)
		local tab_holder = library:create("TextButton", {
			Parent = tabBar,
			FontFace = library.font,
			TextColor3 = themes.preset.text,
			BorderColor3 = rgb(0, 0, 0),
			Text = "",
			Name = "",
			BorderSizePixel = 0,
			Size = dim2(0, 0, 1, -1),
			ZIndex = 5,
			TextSize = 12,
			BackgroundColor3 = themes.preset.outline,
			AutoButtonColor = false,
		}) library:apply_theme(tab_holder, "outline", "BackgroundColor3")

		local inline = library:create("Frame", {
			Parent = tab_holder,
			Size = dim2(1, -2, 1, 0),
			Name = "",
			Position = dim2(0, 1, 0, 1),
			BorderColor3 = rgb(0, 0, 0),
			ZIndex = 5,
			BorderSizePixel = 0,
			BackgroundColor3 = themes.preset.inline,
		}) library:apply_theme(inline, "inline", "BackgroundColor3")

		local background = library:create("Frame", {
			Parent = inline,
			Size = dim2(1, -2, 1, -1),
			Name = "",
			Position = dim2(0, 1, 0, 1),
			BorderColor3 = rgb(0, 0, 0),
			ZIndex = 5,
			BorderSizePixel = 0,
			BackgroundColor3 = rgb(255, 255, 255),
		})

		local UIGradient = library:create("UIGradient", {
			Parent = background,
			Name = "",
			Rotation = 90,
			Color = rgbseq{rgbkey(0, rgb(41, 41, 55)), rgbkey(1, rgb(35, 35, 47))}
		}) library:apply_theme(UIGradient, "contrast", "Color")

		local text = library:create("TextLabel", {
			Parent = background,
			FontFace = library.font,
			TextColor3 = themes.preset.text,
			BorderColor3 = rgb(0, 0, 0),
			Text = name,
			Name = "",
			BackgroundTransparency = 1,
			Size = dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 12,
			ZIndex = 5,
			BackgroundColor3 = rgb(255, 255, 255),
		}) library:apply_theme(text, "accent", "TextColor3")

		return {button = tab_holder, gradient = UIGradient, text = text, holder = holder}
	end

	local styleTab = createTab("Style", styleHolder)
	local configTab = createTab("Configuration", configHolder)
	tabs = {styleTab, configTab}

	local function setTab(active)
		for _, t in ipairs(tabs) do
			local isActive = t == active
			t.button.Size = dim2(1, -2, 1, isActive and 0 or -1)
			t.gradient.Rotation = isActive and -90 or 90
			t.text.TextColor3 = isActive and themes.preset.accent or themes.preset.text
			t.holder.Visible = isActive
		end
	end

	styleTab.button.MouseButton1Click:Connect(function() setTab(styleTab) end)
	configTab.button.MouseButton1Click:Connect(function() setTab(configTab) end)
	setTab(styleTab)

	-- Move original Style/Configuration sections into the new tab holders
	local function moveSections(fromHolder, toHolder)
		local columnFrame = nil
		for _, child in ipairs(fromHolder:GetChildren()) do
			if child:IsA("Frame") then
				columnFrame = child
				break
			end
		end
		if columnFrame then
			for _, section in ipairs(columnFrame:GetChildren()) do
				if section:IsA("Frame") then
					section.Parent = toHolder
					-- Hide the section's own top accent line so it doesn't stack under the tab bar
					local inline = section:FindFirstChildOfClass("Frame")
					local bg = inline and inline:FindFirstChildOfClass("Frame")
					local accent = bg and bg:FindFirstChildOfClass("Frame")
					if accent and accent.Size.Y.Offset == 2 then
						accent.Visible = false
					end
				end
			end
		end
		local list = toHolder:FindFirstChildOfClass("UIListLayout")
		if list then
			list.VerticalFlex = Enum.UIFlexAlignment.Fill
		end
	end

	if stylePanel then
		moveSections(stylePanel.items.holder, styleHolder)
		stylePanel.items.sgui:Destroy()
	end
	if configPanel then
		moveSections(configPanel.items.holder, configHolder)
		configPanel.items.sgui:Destroy()
	end

	-- Top bar: remove only the old Style/Configuration icons
	local buttonsToRemove = {}
	if stylePanel then buttonsToRemove[stylePanel.items.button] = true end
	if configPanel then buttonsToRemove[configPanel.items.button] = true end
	for _, btn in ipairs(library.dock_holder:GetChildren()) do
		if btn:IsA("TextButton") and buttonsToRemove[btn] then
			btn:Destroy()
		end
	end

	-- Resize dock background to fit remaining buttons
	task.defer(function()
		local layout = library.dock_holder:FindFirstChildOfClass("UIListLayout")
		local outline = library.dock_holder.Parent.Parent.Parent
		if layout and outline then
			local width = layout.AbsoluteContentSize.X + 12
			outline.Size = UDim2.new(0, width, 0, 39)
		end
	end)

	-- Reliable Insert keybind for opening/closing menu
	local uis = game:GetService("UserInputService")
	local uiBindFlag = "SET ME A FLAG NOWWW!!!!"
	if library.config_flags[uiBindFlag] then
		library.config_flags[uiBindFlag]({mode = "toggle", active = false, key = "none"})
	end
	library:connection(uis.InputBegan, function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Insert then
			window.set_menu_visibility(not window.opened)
		end
	end)

	local Aiming = window:tab({name = "Aiming"})
	local Misc = window:tab({name = "Misc"})
	local Visuals = window:tab({name = "Visuals"})
	local Combat = window:tab({name = "Combat"})

	-- Aiming
		local column =  Aiming:column() 
			local selec, lock, assist  = column:multi_section({names = {"Selection", "Lock"}})
				selec:toggle({name = "Enabled", flag = "target_selected", tooltip = "Manages selection of the target (both lock and aim assist)"})
				:keybind({name = "Aiming", flag = "target_selected_bind"})
				selec:toggle({name = "Auto Select", flag = "auto_select", tooltip = "Selects targets for you. (Edit the delay slider if you want more fps.)"})
				selec:toggle({name = "Only Select Enemies", flag = "enemy_priority", tooltip = "Only targets users under the priority enemy (through the playerlist)"})
				selec:dropdown({name = "Origin", flag = "distance_priority", items = {"Mouse", "Distance"}, default = "Mouse", tooltip = "Selects targets based on the origin"})
				selec:slider({name = "Delay", min = 0, max = 1000, default = 40, interval = 1, suffix = "ms", flag = "target_selector_refresh_time", tooltip = "Used for optimizing the checks and target selection. Use for lower end pcs."})
				selec:toggle({name = "Wall Check", flag = "wall_check"})
				selec:toggle({name = "Knocked Check", flag = "knocked_check"})
				selec:toggle({name = "ForceField Check", flag = "forcefield_check"})
				selec:toggle({name = "Distance Check", flag = "distance_check", tooltip = "Checks if they are in the distance of the guns range"})
				lock:toggle({name = "Enabled", flag = "silent_aim"})
				:keybind({name = "Aim Key", flag = "silent_aim_bind"})
				lock:toggle({name = "Auto Shoot", flag = "auto_shoot"})
				lock:dropdown({name = "Aim Bone", flag = "silent_aim_bone", items = {"Head", "Torso", "HumanoidRootPart"}, default = "Head"})
				lock:slider({name = "FOV", flag = "silent_aim_fov", min = 0, max = 500, default = 150, interval = 1, suffix = " px"})
				lock:slider({name = "Smoothness", flag = "silent_aim_smooth", min = 1, max = 100, default = 15, interval = 1, suffix = "%"})
				lock:slider({name = "Max Distance", flag = "silent_aim_distance", min = 0, max = 1000, default = 500, interval = 5, suffix = " studs"})
				lock:toggle({name = "Team Check", flag = "silent_aim_teamcheck"})
				lock:toggle({name = "Visible Check", flag = "silent_aim_visiblecheck"})
				lock:toggle({name = "Invisible Bullets", flag = "invis_bullet", tooltip = "Makes your bullets invisible"})
				
		local column =  Aiming:column() 
			local vis, other  = column:multi_section({names = {"Visuals", "Other"}})
				other:toggle({name = "Look At", flag = "look_at"})
				other:toggle({name = "Spectate", flag = "spectate"})
				vis:toggle({name = "Tracer", flag = "snap_line"})
				:colorpicker({name = "Tracer Inline", flag = "snap_line_color", color = hex("#7D0DC3")})
				:colorpicker({flag = "Tracer Outline", color = hex("#000000")})
				vis:slider({name = "Thickness", min = 1, max = 5, default = 1, interval = 1, suffix = "°", flag = "target_snap_line_thickness"})
				vis:toggle({name = "Highlight", flag = "target_highlight"})
				:colorpicker({name = "Outline", flag = "target_highlight_settings", color = hex("#000000")})
				:colorpicker({name = "Fill", flag = "target_highlight_settings", color = hex("#000000")})  
				vis:toggle({name = "Field Of View", flag = "fov"})   
				:colorpicker({name = "1st Color (Gradient)", flag = "fov_1_settings", color = hex("#7D0DC3"), alpha = 0.5}) 
				:colorpicker({name = "2nd Color (Gradient)", flag = "fov_2_settings", color = hex("#7D0DC3"), alpha = 0.5}) 
				vis:toggle({name = "Outline", flag = "outline_fov"})  
				:colorpicker({name = "1st Color (Gradient)", flag = "outline_fov_settings_1", color = hex("#000000"), alpha = 1}) 
				:colorpicker({name = "2nd Color (Gradient)", flag = "outline_fov_settings_2", color = hex("#000000"), alpha = 1}) 
				vis:slider({name = "Radius", min = 0, max = 1000, default = 100, interval = 1, flag = "fov_radius"})
				vis:slider({name = "Thickness", min = 0, max = 5, default = 1, interval = 1, flag = "outline_thickness_fov"})
				vis:slider({name = "Custom Rotation", min = -180, max = 180, default = 0, interval = 1, flag = "custom_rotation_fov"})
				vis:toggle({name = "Spin", flag = "spin_fov"})
				vis:slider({name = "Rotation Speed", min = 0, max = 100, default = 100, interval = 1, flag = "spin_speed_fov"})
				library.config_flags["fov"](false)
			local vis, other  = column:multi_section({names = {"Visuals", "Other"}})
				other:toggle({name = "Look At", flag = "look_at"})
				other:toggle({name = "Spectate", flag = "spectate"})
				vis:toggle({name = "Tracer", flag = "snap_line"})
				:colorpicker({name = "Tracer Inline", flag = "snap_line_color", color = hex("#7D0DC3")})
				:colorpicker({flag = "Tracer Outline", color = hex("#000000")})
				vis:slider({name = "Thickness", min = 1, max = 5, default = 1, interval = 1, suffix = "°", flag = "target_snap_line_thickness"})
				vis:toggle({name = "Highlight", flag = "target_highlight"})
				:colorpicker({name = "Outline", flag = "target_highlight_settings", color = hex("#000000")})
				:colorpicker({name = "Fill", flag = "target_highlight_settings", color = hex("#000000")})  
				vis:toggle({name = "Field Of View", flag = "fov"})   
				:colorpicker({name = "1st Color (Gradient)", flag = "fov_1_settings", color = hex("#7D0DC3"), alpha = 0.5}) 
				:colorpicker({name = "2nd Color (Gradient)", flag = "fov_2_settings", color = hex("#7D0DC3"), alpha = 0.5}) 
				vis:toggle({name = "Outline", flag = "outline_fov"})  
				:colorpicker({name = "1st Color (Gradient)", flag = "outline_fov_settings_1", color = hex("#000000"), alpha = 1}) 
				:colorpicker({name = "2nd Color (Gradient)", flag = "outline_fov_settings_2", color = hex("#000000"), alpha = 1}) 
				vis:slider({name = "Radius", min = 0, max = 1000, default = 100, interval = 1, flag = "fov_radius"})
				vis:slider({name = "Thickness", min = 0, max = 5, default = 1, interval = 1, flag = "outline_thickness_fov"})
				vis:slider({name = "Custom Rotation", min = -180, max = 180, default = 0, interval = 1, flag = "custom_rotation_fov"})
				vis:toggle({name = "Spin", flag = "spin_fov"})
				vis:slider({name = "Rotation Speed", min = 0, max = 100, default = 100, interval = 1, flag = "spin_speed_fov"})
				library.config_flags["fov"](false)
	--


-- === COMBAT (ported hood features) ===
-- ============================================
-- COMBAT FEATURES PORTED FROM evolution_hood.lua
-- ============================================

do
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local UnreliableMainEvent = ReplicatedStorage:WaitForChild("UnreliableMainEvent", 5)
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 5)
getgenv().MainEvent = MainEvent
local newcclosure = newcclosure or function(f) return f end

local function Notify(title, text, duration)
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
	end)
end

-- External dependency stubs
if not getgenv().ForceHit then
	getgenv().ForceHit = {
		Enabled = false,
		MaxDistance = 250,
		WallCheck = true,
		ForceFieldCheck = true,
		DeathCheck = true,
		PrefireForceField = false,
		HitPart = "UpperTorso",
		LastShotTime = 0,
		_InternalOverride = false,
	}
end

if not getgenv().FH_Fire then
	getgenv().FH_Fire = function(target)
		if not target or not target.Character then return end
		local hitPartName = getgenv().ForceHit.HitPart or "Head"
		local part = target.Character:FindFirstChild(hitPartName) or target.Character:FindFirstChild("Head")
		if not part then return end
		local myChar = LocalPlayer.Character
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myHRP then return end

		local pellets = {}
		local offsets = {}
		for i = 1, 5 do
			pellets[i] = { Normal = part.Position, Instance = part, Position = part.Position }
			offsets[i] = { thePart = part, theOffset = Vector3.new(0, 0, 0) }
		end

		local args = {
			"Shoot",
			{
				pellets,
				offsets,
				myHRP.Position,
				myHRP.Position,
				workspace:GetServerTimeNow()
			}
		}
		pcall(function()
			MainEvent:FireServer(unpack(args))
		end)
		getgenv().ForceHit.LastShotTime = tick()
	end
end

if not getgenv().AnimGodmode then
	local animGodEnabled = false
	local animGodConn = nil
	getgenv().AnimGodmode = {
		IsEnabled = function() return animGodEnabled end,
		Set = function(value)
			animGodEnabled = value
			if animGodConn then
				animGodConn:Disconnect()
				animGodConn = nil
			end
			if value then
				local char = LocalPlayer.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.BreakJointsOnDeath = false
					end
				end
				animGodConn = LocalPlayer.CharacterAdded:Connect(function(character)
					task.wait(0.5)
					local hum = character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.BreakJointsOnDeath = false
						hum.HealthChanged:Connect(function(health)
							if health < hum.MaxHealth then
								hum.Health = hum.MaxHealth
							end
						end)
					end
				end)
			end
		end
	}
end

-- ============================================
-- CONFIG TABLES
-- ============================================
local Targeting = {
	Target = nil,
	Highlight = nil,
	LockedOn = false,
	HighlightEnabled = true,
	DotEnabled = false,
	TracerEnabled = true,
	TracerStartPosition = "Mouse",
	HighlightColor = Color3.fromRGB(27, 206, 203),
	DotColor = Color3.fromRGB(27, 206, 203),
	TracerColor = Color3.fromRGB(27, 206, 203),
	TargetAimbotPart = "HumanoidRootPart",
	AimbotMethod = "Index",
	TracerThickness = 2,
	TracerOutlineThickness = 4,
	WaitingForRespawn = false,
	PredictionEnabled = false,
	Prediction = 0.1433,
	JumpOffset = 0.5,
	AntiGroundShot = false,
	SpectateTarget = false,
	LookAtTarget = false,
}

local FOVCircleConfig = {
	Enabled = false,
	Radius = 150,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 1,
	Transparency = 0,
	Filled = false,
	FillColor = Color3.fromRGB(255, 255, 255),
	FillTransparency = 0.85,
	Outline = false,
	OutlineColor = Color3.fromRGB(0, 0, 0),
	OutlineThickness = 3,
	OutlineTransparency = 0.5,
	RainbowEnabled = false,
	RainbowHue = 0,
	DotCenter = false,
	DotColor = Color3.fromRGB(255, 255, 255),
	DotRadius = 3,
}

local AutoKill = {
	Enabled = false,
	Target = nil,
	Method = "Knife",
	AttachPosition = "Behind",
	LockedOn = false,
	CycleActive = false,
	KnifeExpander = {
		Enabled = true,
		Size = 20,
		Fill = true,
		FillColor = Color3.fromRGB(255, 0, 0),
		FillTransparency = 0.5,
		Outline = true,
		OutlineColor = Color3.fromRGB(255, 0, 0),
		OutlineTransparency = 0.5,
	},
	KnifeAura = false,
	AuraLockedTarget = nil,
	KnifeLoopConnection = nil,
	LastKnifeStab = 0,
	GunMethod = {
		PlatformColor = Color3.fromRGB(255, 0, 255),
		PlatformMaterial = Enum.Material.Neon,
		VoidPosition = Vector3.new(99999, 500, 99999),
		PlatformPart = nil,
		IsHiding = false,
		IsWaiting = false,
		IsKilling = false,
		LastTeleportTime = 0,
		TeleportCooldown = 0.1,
		StompRunning = false,
		StompTarget = nil,
		StompReturn = nil,
	},
	Targets = {},
	CurrentTargetIndex = 1,
	UI = nil,
	ForceHitWasEnabled = false,
	ForceHitOriginal = nil,
	StandConfig = {
		Enabled = false,
		OwnerName = "",
		OwnerPlayer = nil,
		Whitelist = {},
		StandNames = {},
		KillAuraMode = false,
		KnifeAuraMode = false,
	},
}

local ProtectPlayer = {
	Enabled = false,
	Method = "Gun",
	SelectedName = nil,
	StompShooter = false,
	SpectateShooter = false,
	Active = false,
	Shooter = nil,
	LastHealth = nil,
	BulletConnection = nil,
	LoopConnection = nil,
	BulletHistory = {},
	LastGlobalShooter = nil,
	LastGlobalShotTime = 0,
	RayThreshold = 10,
	BulletWindow = 1.5,
	GlobalShotWindow = 0.3,
	AttackCooldown = 0.25,
	LastAttackTime = 0,
	MaxShooterDistance = 200,
	StartCFrame = nil,
	StompRunning = false,
}

local hitsounds = {
	["Default"] = "rbxassetid://6565371338",
	["Rust Headshot"] = "rbxassetid://138750331387064",
	["Neverlose"] = "rbxassetid://110168723447153",
	["Bubble"] = "rbxassetid://6534947588",
	["Laser"] = "rbxassetid://7837461331",
	["Steve"] = "rbxassetid://4965083997",
	["Call of Duty"] = "rbxassetid://5952120301",
	["Bat"] = "rbxassetid://3333907347",
	["TF2 Critical"] = "rbxassetid://296102734",
	["Saber"] = "rbxassetid://8415678813",
	["Bameware"] = "rbxassetid://3124331820",
	["Money"] = "rbxassetid://13956013041",
	["Notif"] = "rbxassetid://6696469190",
	["Shutter"] = "rbxassetid://10066921516",
	["RIFK7"] = "rbxassetid://9102080552",
	["LazerBeam"] = "rbxassetid://130791043",
	["WindowsXPError"] = "rbxassetid://160715357",
	["TF2Hitsound"] = "rbxassetid://3455144981",
	["BowHit"] = "rbxassetid://1053296915",
	["Bow"] = "rbxassetid://3442683707",
	["OSU"] = "rbxassetid://7147454322",
	["OneNN"] = "rbxassetid://7349055654",
	["Rust"] = "rbxassetid://6565371338",
	["TF2Pan"] = "rbxassetid://3431749479",
	["Mario"] = "rbxassetid://5709456554",
	["Bell"] = "rbxassetid://6534947240",
	["Pick"] = "rbxassetid://1347140027",
	["Pop"] = "rbxassetid://198598793",
	["Sans"] = "rbxassetid://3188795283",
	["Fart"] = "rbxassetid://130833677",
	["Big"] = "rbxassetid://5332005053",
	["Vine"] = "rbxassetid://5332680810",
	["Bruh"] = "rbxassetid://4578740568",
	["Skeet"] = "rbxassetid://5633695679",
	["Fatality"] = "rbxassetid://6534947869",
	["Bonk"] = "rbxassetid://5766898159",
	["Minecraft"] = "rbxassetid://5869422451",
	["Gamesense"] = "rbxassetid://4817809188",
	["Bamboo"] = "rbxassetid://3769434519",
	["Crowbar"] = "rbxassetid://546410481",
	["Weeb"] = "rbxassetid://6442965016",
	["Beep"] = "rbxassetid://8177256015",
	["Bambi"] = "rbxassetid://8437203821",
	["Stone"] = "rbxassetid://3581383408",
	["Old Fatality"] = "rbxassetid://6607142036",
	["Click"] = "rbxassetid://8053704437",
	["Ding"] = "rbxassetid://7149516994",
	["Snow"] = "rbxassetid://6455527632",
	["Osu"] = "rbxassetid://7149255551",
	["TF2"] = "rbxassetid://2868331684",
	["Slime"] = "rbxassetid://6916371803",
	["Among Us"] = "rbxassetid://5700183626",
	["One"] = "rbxassetid://7380502345",
	["BulletDeflect"] = "rbxassetid://1657157666",
	["HoodCustoms"] = "rbxassetid://330595293",
	["UwU"] = "rbxassetid://8679659744",
	["Cod"] = "rbxassetid://160432334",
	["Blood SFX"] = "rbxassetid://8164951181",
	["Blood Burst"] = "rbxassetid://3781479909",
	["Blood Hit"] = "rbxassetid://429400881",
	["Fortnite Shield"] = "rbxassetid://140073271098075",
	["Fortnite Knocked"] = "rbxassetid://115413823879705",
}

local HitsoundConfig = {
	Enabled = true,
	SelectedSound = "Default",
	Volume = 1,
}

local function PlayHitsound()
	if not HitsoundConfig.Enabled then return end
	local soundId = hitsounds[HitsoundConfig.SelectedSound] or hitsounds["Default"]
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = HitsoundConfig.Volume * 2
	sound.Parent = SoundService
	sound:Play()
	task.spawn(function()
		task.wait(5)
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
end

-- ============================================
-- DRAWING OBJECTS
-- ============================================
local dot = Drawing.new("Circle")
dot.Radius = 10
dot.Thickness = 2
dot.Filled = false
dot.Visible = false

local tracerOutline = Drawing.new("Line")
tracerOutline.Visible = false
tracerOutline.Color = Color3.new(0, 0, 0)
tracerOutline.Thickness = 4
tracerOutline.Transparency = 0.8

local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Color = Color3.fromRGB(27, 206, 203)
tracer.Thickness = 2
tracer.Transparency = 1

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Radius = 150
fovCircle.Transparency = 1

local fovCircleFill = Drawing.new("Circle")
fovCircleFill.Visible = false
fovCircleFill.Thickness = 1
fovCircleFill.Color = Color3.fromRGB(255, 255, 255)
fovCircleFill.Filled = true
fovCircleFill.NumSides = 64
fovCircleFill.Radius = 150
fovCircleFill.Transparency = 0.85

local fovCircleOutline = Drawing.new("Circle")
fovCircleOutline.Visible = false
fovCircleOutline.Thickness = 3
fovCircleOutline.Color = Color3.fromRGB(0, 0, 0)
fovCircleOutline.Filled = false
fovCircleOutline.NumSides = 64
fovCircleOutline.Radius = 150
fovCircleOutline.Transparency = 0.5

local fovCenterDot = Drawing.new("Circle")
fovCenterDot.Visible = false
fovCenterDot.Filled = true
fovCenterDot.Radius = 3
fovCenterDot.Color = Color3.fromRGB(255, 255, 255)
fovCenterDot.Transparency = 1
fovCenterDot.NumSides = 32
fovCenterDot.Thickness = 1

local JumpOffsetValue = 0
local teleporting = false


-- ============================================
-- TARGET AIM FUNCTIONS
-- ============================================
local function IsValidTarget(Player)
	if not Player or Player == LocalPlayer then return false end
	local stillInGame = false
	for _, p in ipairs(Players:GetPlayers()) do
		if p == Player then stillInGame = true break end
	end
	if not stillInGame then return false end
	if not Player.Character then return false end
	local Root = Player.Character:FindFirstChild(Targeting.TargetAimbotPart)
	local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
	return Root ~= nil and Humanoid ~= nil and Humanoid.Health > 0
end

local function IsTargetDeadOrRespawning(Player)
	if not Player then return false end
	if not Player.Character then return true end
	local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
	return not Humanoid or Humanoid.Health <= 0
end

local function UpdateHighlight(Target)
	if Targeting.Highlight then
		Targeting.Highlight:Destroy()
		Targeting.Highlight = nil
	end
	if Target and Target.Character and Targeting.HighlightEnabled then
		local highlight = Instance.new("Highlight")
		highlight.Parent = CoreGui
		highlight.Adornee = Target.Character
		local fillEnabled = library.flags["hood_highlight_fill"]
		local outlineEnabled = library.flags["hood_highlight_outline"]
		local fillCol = library.flags["hood_highlight_fill_color"] and library.flags["hood_highlight_fill_color"].Color or Color3.fromRGB(27, 206, 203)
		local outlineCol = library.flags["hood_highlight_outline_color"] and library.flags["hood_highlight_outline_color"].Color or Color3.new(1,1,1)
		local fillT = library.flags["hood_highlight_fill_transparency"] or 0
		local outlineT = library.flags["hood_highlight_outline_transparency"] or 0
		if fillEnabled then
			highlight.FillColor = fillCol
			highlight.FillTransparency = fillT
		else
			highlight.FillTransparency = 1
		end
		if outlineEnabled then
			highlight.OutlineColor = outlineCol
			highlight.OutlineTransparency = outlineT
		else
			highlight.OutlineTransparency = 1
		end
		Targeting.Highlight = highlight
	end
end

local function ClearTarget()
	Targeting.Target = nil
	Targeting.WaitingForRespawn = false
	UpdateHighlight(nil)
	dot.Visible = false
	tracer.Visible = false
	tracerOutline.Visible = false
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.AutoRotate = true
	end
	if Targeting.SpectateTarget and library.flags["hood_spectate_target"] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
	end
end

local function GetClosestTarget()
	local Closest, MinDist = nil, math.huge
	local MousePos = UserInputService:GetMouseLocation()
	local useFOV = library.flags["hood_target_aim_use_fov"]
	local fovRadius = FOVCircleConfig.Radius
	for _, Player in ipairs(Players:GetPlayers()) do
		if IsValidTarget(Player) then
			local Root = Player.Character:FindFirstChild(Targeting.TargetAimbotPart)
			local pos, onScreen = Camera:WorldToViewportPoint(Root.Position)
			if onScreen then
				local screenPos2D = Vector2.new(pos.X, pos.Y)
				local mouseDist = (screenPos2D - Vector2.new(MousePos.X, MousePos.Y)).Magnitude
				if useFOV and mouseDist > fovRadius then continue end
				if mouseDist < MinDist then
					MinDist = mouseDist
					Closest = Player
				end
			end
		end
	end
	Targeting.Target = Closest
	Targeting.WaitingForRespawn = false
	UpdateHighlight(Closest)
end

local function ToggleLock()
	Targeting.LockedOn = not Targeting.LockedOn
	if Targeting.LockedOn then
		GetClosestTarget()
	else
		ClearTarget()
	end
end

local function toggleTargetAim(v)
	if not v then
		Targeting.LockedOn = false
		ClearTarget()
	end
end

local function onTargetKeybindPressed()
	if not library.flags["hood_target_aim_enabled"] then return end
	if Targeting.LockedOn and Targeting.Target then
		Targeting.LockedOn = false
		ClearTarget()
	else
		Targeting.LockedOn = true
		GetClosestTarget()
	end
end

local function setupRespawnHandling(player)
	if player and player ~= LocalPlayer then
		player.CharacterAdded:Connect(function(character)
			if player == Targeting.Target and Targeting.WaitingForRespawn and Targeting.LockedOn then
				task.wait(0.5)
				UpdateHighlight(player)
			end
		end)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	setupRespawnHandling(player)
end
Players.PlayerAdded:Connect(setupRespawnHandling)

Players.PlayerRemoving:Connect(function(player)
	if player == Targeting.Target then
		ClearTarget()
		Targeting.LockedOn = false
	end
end)

-- ============================================
-- AUTO STOMP
-- ============================================
getgenv().AutoStompState = {autostomp = false, running = false, ret = nil}
getgenv().AutoStompLoop = function()
	local state = getgenv().AutoStompState
	if not state.autostomp then state.running = false state.ret = nil return end
	if state.running then return end
	state.running = true
	task.spawn(function()
		while state.autostomp do
			local c = LocalPlayer.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildWhichIsA("Humanoid")
			if not c or not hrp or not hum then
				task.wait(0.1)
			else
				local target = Targeting.Target
				if target and target.Character and target ~= LocalPlayer then
					local tc = target.Character
					local b = tc:FindFirstChild("BodyEffects")
					local ko = b and b:FindFirstChild("K.O") and b["K.O"].Value
					local dead = b and b:FindFirstChild("Dead") and b["Dead"].Value
					if ko and not dead then
						local ut = tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("HumanoidRootPart")
						if ut then
							if not state.ret then state.ret = hrp.CFrame end
							local o = hrp.CFrame
							local originalCamOffset = hum.CameraOffset
							hum.Sit = false
							hum.PlatformStand = false
							local originalVel = hrp.AssemblyLinearVelocity
							hrp.CFrame = CFrame.new(ut.Position + Vector3.new(0, 3.5, 0))
							hum.CameraOffset = o.Position - hrp.Position
							RunService.RenderStepped:Wait()
							for i = 1, 5 do
								task.spawn(function()
									local me = getgenv().MainEvent
									if me then me:FireServer("Stomp") end
								end)
							end
							hum.CameraOffset = originalCamOffset
							hrp.CFrame = o
							hrp.AssemblyLinearVelocity = originalVel
						end
					end
				end
				if state.ret and hrp then
					while (hrp.Position - state.ret.Position).Magnitude > 5 do
						hrp.CFrame = state.ret
						task.wait()
					end
					state.ret = nil
				end
				local me = getgenv().MainEvent
				if me then pcall(function() me:FireServer("Stomp") end) end
				task.wait()
			end
		end
		state.running = false
	end)
end


do
-- ============================================
-- AUTO KILL FUNCTIONS
-- ============================================
function AutoKill.CreateUI()
	if AutoKill.UI then return AutoKill.UI end
	local gui = Instance.new("ScreenGui")
	gui.Name = "AutoKillStatusUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	pcall(function() gui.Parent = gethui() end)
	if not gui.Parent then gui.Parent = CoreGui end
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.48, 0)
	label.Size = UDim2.new(0, 400, 0, 26)
	label.BackgroundTransparency = 1
	label.TextTransparency = 0
	label.RichText = true
	label.Font = Enum.Font.Code
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Text = ""
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 1
	stroke.Transparency = 0.4
	stroke.Parent = label
	label.Parent = gui
	AutoKill.UI = {gui = gui, text = label}
	return AutoKill.UI
end

function AutoKill.UpdateUI(status, targetName)
	local ui = AutoKill.CreateUI()
	if not ui or not ui.text then return end
	local name = targetName or ""
	if status == "waiting" then
		ui.text.Text = '<font color="#4DA3FF">[evolution]</font> <font color="#FFFFFF">waiting for target..</font><font color="#FF6B6B"> (hiding)</font>'
	elseif status == "killing" then
		ui.text.Text = string.format('<font color="#4DA3FF">[evolution]</font> <font color="#FF4A4A">autokilling</font> <font color="#FFFFFF">"%s"</font>', name)
	elseif status == "stomping" then
		ui.text.Text = string.format('<font color="#4DA3FF">[evolution]</font> <font color="#FFA500">stomping</font> <font color="#FFFFFF">"%s"</font>', name)
	elseif status == "hiding" then
		ui.text.Text = '<font color="#4DA3FF">[evolution]</font> <font color="#9966FF">hiding</font> <font color="#FFFFFF">(avoiding danger)</font>'
	elseif status == "hiding_stomp" then
		ui.text.Text = string.format('<font color="#4DA3FF">[evolution]</font> <font color="#9966FF">hiding</font> <font color="#FFFFFF">after stomping</font> <font color="#FFA500">"%s"</font>', name)
	elseif status == "hiding_kill" then
		ui.text.Text = string.format('<font color="#4DA3FF">[evolution]</font> <font color="#9966FF">hiding</font> <font color="#FFFFFF">(forcefield detected on</font> <font color="#FF4A4A">"%s"</font><font color="#FFFFFF">)</font>', name)
	else
		ui.text.Text = ""
	end
end

function AutoKill.SetTargetList(list)
	AutoKill.Targets = list or {}
	AutoKill.CurrentTargetIndex = 1
	AutoKill.Target = AutoKill.GetNextValidTarget()
end

function AutoKill.GetNextValidTarget()
	local list = AutoKill.Targets
	local n = #list
	if n == 0 then return nil end
	local startIndex = AutoKill.CurrentTargetIndex
	if startIndex < 1 or startIndex > n then startIndex = 1 end
	for offset = 0, n - 1 do
		local idx = ((startIndex - 1 + offset) % n) + 1
		local name = list[idx]
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name == name and AutoKill.IsValidTarget(p) then
				AutoKill.CurrentTargetIndex = (idx % n) + 1
				return p
			end
		end
	end
	return nil
end

function AutoKill.AdvanceTarget()
	if AutoKill.Method == "Knife" and AutoKill.KnifeAura and not AutoKill.HasSelectedTargets() then
		AutoKill.Target = AutoKill.GetClosestTarget()
	else
		AutoKill.Target = AutoKill.GetNextValidTarget()
	end
	return AutoKill.Target
end

function AutoKill.HasSelectedTargets()
	return #AutoKill.Targets > 0
end

function AutoKill.GetAttachOffset()
	local posMode = AutoKill.AttachPosition
	if posMode == "Random" then
		local angle = math.random() * 2 * math.pi
		local dist = 4 + math.random() * 3
		local height = -1.5 + math.random() * 3
		return CFrame.new(math.cos(angle) * dist, height, math.sin(angle) * dist), true
	elseif posMode == "Inside" then
		return CFrame.new(0, 0, 0), false
	elseif posMode == "Left" then
		return CFrame.new(-4, 0, 0), true
	elseif posMode == "Right" then
		return CFrame.new(4, 0, 0), true
	elseif posMode == "Below" then
		return CFrame.new(0, -6, 0), true
	else
		return CFrame.new(0, 0, 4), true
	end
end

function AutoKill.IsValidPlayer(player)
	if not player or player == LocalPlayer then return false end
	for _, p in ipairs(Players:GetPlayers()) do
		if p == player then return true end
	end
	return false
end

function AutoKill.IsWhitelisted(player)
	if not player then return false end
	local list = AutoKill.StandConfig and AutoKill.StandConfig.Whitelist
	return list and list[player.Name:lower()] == true
end

function AutoKill.IsValidTarget(player)
	if not AutoKill.IsValidPlayer(player) then return false end
	if AutoKill.IsWhitelisted(player) then return false end
	local char = player.Character
	if not char then return false end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	return root ~= nil and hum ~= nil and hum.Health > 0
end

function AutoKill.GetTargetStatus(player)
	if not AutoKill.IsValidPlayer(player) then return "invalid" end
	local char = player.Character
	if not char then return "nochar" end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return "nochar" end
	if hum.Health <= 0 then return "dead" end
	local be = char:FindFirstChild("BodyEffects")
	if be then
		local dead = be:FindFirstChild("Dead")
		if dead and dead.Value == true then return "dead" end
		local ko = be:FindFirstChild("K.O")
		if ko and ko.Value == true then return "downed" end
	end
	return "alive"
end

function AutoKill.IsStandPlayer(player)
	if not player then return false end
	if player == LocalPlayer then return true end
	if player == (AutoKill.StandConfig and AutoKill.StandConfig.OwnerPlayer) then return true end
	local names = AutoKill.StandConfig and AutoKill.StandConfig.StandNames
	if names and names[player.Name:lower()] then return true end
	local char = player.Character
	if char and char:GetAttribute("IsStand") == true then return true end
	return false
end

function AutoKill.GetNearestEnemyToOwner()
	local owner = AutoKill.StandConfig and AutoKill.StandConfig.OwnerPlayer
	local originRoot = owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
	if not originRoot then
		originRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	end
	if not originRoot then return nil end
	local closest, minDist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player ~= owner and not AutoKill.IsStandPlayer(player) then
			if AutoKill.IsValidTarget(player) and AutoKill.GetTargetStatus(player) == "alive" then
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					local dist = (root.Position - originRoot.Position).Magnitude
					if dist < minDist then
						minDist = dist
						closest = player
					end
				end
			end
		end
	end
	return closest
end

function AutoKill.HasForceField(char)
	return char and char:FindFirstChildOfClass("ForceField") ~= nil
end

function AutoKill.TryEquipKnife()
	local char = LocalPlayer.Character
	if not char then return false end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end
	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and string.find(string.lower(tool.Name), "knife") then
			pcall(function() humanoid:EquipTool(tool) end)
			return char:FindFirstChild(tool.Name) ~= nil
		end
	end
	return false
end

function AutoKill.TryStab()
	local now = tick()
	if now - AutoKill.LastKnifeStab < 0.22 then return end
	AutoKill.LastKnifeStab = now
	local char = LocalPlayer.Character
	if not char then return end
	local knife = char:FindFirstChild("[Knife]")
	if not knife then
		AutoKill.TryEquipKnife()
		return
	end
	pcall(function() knife:Activate() end)
end

function AutoKill.OwnPart(part)
	if part and part:IsA("BasePart") then
		pcall(function() part:SetNetworkOwner(LocalPlayer) end)
	end
end

function AutoKill.CreateVoidPlatform()
	local GM = AutoKill.GunMethod
	if GM.PlatformPart and GM.PlatformPart.Parent then return end
	local part = Instance.new("Part")
	part.Name = "AutoKillVoidPlatform"
	part.Size = Vector3.new(100, 5, 100)
	part.Position = GM.VoidPosition
	part.Anchored = true
	part.CanCollide = true
	part.Transparency = 0.2
	part.Material = GM.PlatformMaterial
	part.Color = GM.PlatformColor
	part.Parent = workspace
	GM.PlatformPart = part
end

function AutoKill.RemoveVoidPlatform()
	local GM = AutoKill.GunMethod
	if GM.PlatformPart then
		GM.PlatformPart:Destroy()
		GM.PlatformPart = nil
	end
end

function AutoKill.HideCharacter()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	AutoKill.CreateVoidPlatform()
	local platformPos = AutoKill.GunMethod.VoidPosition + Vector3.new(0, 5, 0)
	root.CFrame = CFrame.new(platformPos)
	root.Velocity = Vector3.new(0, 0, 0)
	root.RotVelocity = Vector3.new(0, 0, 0)
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part:GetAttribute("AutoKill_OriginalLTM") == nil then
				part:SetAttribute("AutoKill_OriginalLTM", part.LocalTransparencyModifier)
			end
			part.LocalTransparencyModifier = 1
		end
	end
	AutoKill.GunMethod.IsHiding = true
end

function AutoKill.KeepHidden()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local platformPos = AutoKill.GunMethod.VoidPosition + Vector3.new(0, 5, 0)
	root.CFrame = CFrame.new(platformPos)
	root.Velocity = Vector3.new(0, 0, 0)
	root.RotVelocity = Vector3.new(0, 0, 0)
end

function AutoKill.UnhideCharacter()
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			local original = part:GetAttribute("AutoKill_OriginalLTM")
			if original ~= nil then
				part.LocalTransparencyModifier = original
				part:SetAttribute("AutoKill_OriginalLTM", nil)
			end
		end
	end
	AutoKill.GunMethod.IsHiding = false
end

function AutoKill.FastEquipDoubleBarrel()
	local char = LocalPlayer.Character
	if not char then return false end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end
	for _, item in pairs(char:GetChildren()) do
		if item:IsA("Tool") and item.Name == "[DoubleBarrel]" then return true end
	end
	for _, item in pairs(backpack:GetChildren()) do
		if item:IsA("Tool") and item.Name == "[DoubleBarrel]" then
			pcall(function() humanoid:EquipTool(item) end)
			return true
		end
	end
	return false
end

function AutoKill.GetDoubleBarrelAmmo()
	local char = LocalPlayer.Character
	if not char then return 0 end
	local tool = char:FindFirstChild("[DoubleBarrel]")
	if not tool then return 0 end
	local scriptObj = tool:FindFirstChild("Script")
	if scriptObj then
		local ammo = scriptObj:FindFirstChild("Ammo")
		if ammo and ammo:IsA("IntValue") then
			return ammo.Value
		end
	end
	return 0
end

function AutoKill.ReloadDoubleBarrel()
	local char = LocalPlayer.Character
	if not char then return end
	local tool = char:FindFirstChild("[DoubleBarrel]")
	if not tool then return end
	local be = char:FindFirstChild("BodyEffects")
	local reloading = be and be:FindFirstChild("Reloading_CLIENT")
	if reloading and reloading.Value then return end
	if reloading then reloading.Value = true end
	pcall(function()
		getgenv().MainEvent:FireServer("Reload", tool)
	end)
	task.delay(1.5, function()
		if reloading then reloading.Value = false end
	end)
end

function AutoKill.HideAndReloadDoubleBarrel()
	AutoKill.UpdateUI("hiding")
	AutoKill.HideCharacter()
	AutoKill.ReloadDoubleBarrel()
	local reloadStart = tick()
	while AutoKill.Enabled and AutoKill.Method == "Gun" do
		if not AutoKill.FastEquipDoubleBarrel() then
			task.wait(0.1)
			continue
		end
		if AutoKill.GetDoubleBarrelAmmo() > 0 then
			break
		end
		AutoKill.KeepHidden()
		if tick() - reloadStart > 2 then
			AutoKill.ReloadDoubleBarrel()
			reloadStart = tick()
		end
		task.wait(0.1)
	end
end

function AutoKill.TeleportBehindTarget(target)
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local targetChar = target.Character
	if not targetChar then return end
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end
	AutoKill.UnhideCharacter()
	local offset, lookAt = AutoKill.GetAttachOffset()
	if not lookAt then
		root.CFrame = targetRoot.CFrame
	else
		local attachCF = targetRoot.CFrame * offset
		root.CFrame = CFrame.lookAt(attachCF.Position, targetRoot.Position)
	end
	root.Velocity = Vector3.new(0, 0, 0)
end

function AutoKill.AutoStomp(target)
	local state = getgenv().AutoStompState
	if not state or state.running then return end
	AutoKill.GunMethod.StompRunning = true
	AutoKill.GunMethod.StompTarget = target
	local originalTarget = Targeting.Target
	Targeting.Target = target
	state.autostomp = true
	getgenv().AutoStompLoop()
	task.spawn(function()
		while state.running do
			if not AutoKill.Enabled or AutoKill.Target ~= target then
				state.autostomp = false
			end
			task.wait(0.05)
		end
		Targeting.Target = originalTarget
		AutoKill.GunMethod.StompRunning = false
		AutoKill.GunMethod.StompTarget = nil
	end)
end

function AutoKill.StopAutoStomp()
	local state = getgenv().AutoStompState
	if state then state.autostomp = false end
	AutoKill.GunMethod.StompRunning = false
	AutoKill.GunMethod.StompTarget = nil
end

function AutoKill.GetClosestTarget()
	local closest, minDist = nil, math.huge
	local mousePos = UserInputService:GetMouseLocation()
	for _, player in ipairs(Players:GetPlayers()) do
		if AutoKill.IsValidTarget(player) then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
				if dist < minDist then
					minDist = dist
					closest = player
				end
			end
		end
	end
	if closest then return closest end
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	for _, player in ipairs(Players:GetPlayers()) do
		if AutoKill.IsValidTarget(player) then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			local dist = (root.Position - myRoot.Position).Magnitude
			if dist < minDist then
				minDist = dist
				closest = player
			end
		end
	end
	return closest
end

function AutoKill.GetNearestTargetByDistance()
	local closest, minDist = nil, math.huge
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end
	for _, player in ipairs(Players:GetPlayers()) do
		if AutoKill.IsValidTarget(player) and AutoKill.GetTargetStatus(player) == "alive" then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			local dist = (root.Position - myRoot.Position).Magnitude
			if dist < minDist then
				minDist = dist
				closest = player
			end
		end
	end
	return closest
end

function AutoKill.KnifeAuraStep()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	AutoKill.UnhideCharacter()
	AutoKill.RemoveVoidPlatform()
	local owner = AutoKill.StandConfig and AutoKill.StandConfig.OwnerPlayer
	local function isBadTarget(p)
		return not p or p == LocalPlayer or p == owner or AutoKill.IsStandPlayer(p) or AutoKill.IsWhitelisted(p)
	end
	local target = AutoKill.Target
	if target and (isBadTarget(target) or not AutoKill.IsValidTarget(target) or AutoKill.GetTargetStatus(target) ~= "alive") then
		target = nil
	end
	if not target and AutoKill.HasSelectedTargets() then
		for _ = 1, #AutoKill.Targets do
			target = AutoKill.GetNextValidTarget()
			if target and not isBadTarget(target) then break end
			target = nil
		end
	end
	if not target then
		target = AutoKill.AuraLockedTarget
		if target and (isBadTarget(target) or not AutoKill.IsValidTarget(target) or AutoKill.GetTargetStatus(target) ~= "alive") then
			target = nil
			AutoKill.AuraLockedTarget = nil
		end
	end
	if not target and not AutoKill.HasSelectedTargets() then
		target = AutoKill.GetNearestEnemyToOwner()
		AutoKill.AuraLockedTarget = target
	end
	if not target then
		AutoKill.Target = nil
		AutoKill.UpdateUI("waiting")
		return
	end
	local targetChar = target.Character
	if not targetChar then return end
	AutoKill.Target = target
	AutoKill.UpdateUI("killing", target.DisplayName or target.Name)
	local knifeTool = char:FindFirstChild("[Knife]")
	if not knifeTool then
		AutoKill.TryEquipKnife()
		knifeTool = char:FindFirstChild("[Knife]")
	end
	if not knifeTool then return end
	local scriptObj = knifeTool:FindFirstChild("Script")
	if scriptObj then
		local can1 = scriptObj:FindFirstChild("CanHitPlayer")
		local can2 = scriptObj:FindFirstChild("CanHitPlayer2")
		if can1 then pcall(function() can1.Value = targetChar end) end
		if can2 then pcall(function() can2.Value = targetChar end) end
	end
	AutoKill.TryStab()
end

function AutoKill.KnifeAttackStep(target)
	if AutoKill.KnifeAura then
		AutoKill.KnifeAuraStep()
		return
	end
	if not target or not target.Character then return end
	local char = LocalPlayer.Character
	if not char then return end
	AutoKill.UnhideCharacter()
	AutoKill.RemoveVoidPlatform()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local targetChar = target.Character
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end
	AutoKill.OwnPart(root)
	AutoKill.OwnPart(targetRoot)
	local knifeTool = char:FindFirstChild("[Knife]")
	if not knifeTool then
		AutoKill.TryEquipKnife()
		knifeTool = char:FindFirstChild("[Knife]")
	end
	if knifeTool then
		local scriptObj = knifeTool:FindFirstChild("Script")
		if scriptObj then
			local can1 = scriptObj:FindFirstChild("CanHitPlayer")
			local can2 = scriptObj:FindFirstChild("CanHitPlayer2")
			if can1 then pcall(function() can1.Value = targetChar end) end
			if can2 then pcall(function() can2.Value = targetChar end) end
		end
	end
	pcall(function()
		sethiddenproperty(root, "PhysicsRepRootPart", targetRoot)
		local offset, lookAt = AutoKill.GetAttachOffset()
		local targetCF = targetRoot.CFrame
		if not lookAt then
			root.CFrame = targetCF
		else
			local attachCF = targetCF * offset
			root.CFrame = CFrame.lookAt(attachCF.Position, targetCF.Position)
		end
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
	AutoKill.TryStab()
end

function AutoKill.StartCombatCycle()
	if AutoKill.CycleActive then return end
	AutoKill.CycleActive = true
	if AutoKill.Method == "Gun" then
		if getgenv().ForceHit then
			AutoKill.ForceHitWasEnabled = getgenv().ForceHit.Enabled
			AutoKill.ForceHitOriginal = {
				MaxDistance = getgenv().ForceHit.MaxDistance,
				WallCheck = getgenv().ForceHit.WallCheck,
				ForceFieldCheck = getgenv().ForceHit.ForceFieldCheck,
				DeathCheck = getgenv().ForceHit.DeathCheck,
				PrefireForceField = getgenv().ForceHit.PrefireForceField,
				HitPart = getgenv().ForceHit.HitPart,
			}
			getgenv().ForceHit.Enabled = true
			getgenv().ForceHit.MaxDistance = 250
			getgenv().ForceHit.WallCheck = true
			getgenv().ForceHit.ForceFieldCheck = true
			getgenv().ForceHit.DeathCheck = true
			getgenv().ForceHit.PrefireForceField = false
			getgenv().ForceHit.HitPart = "UpperTorso"
		end
		AutoKill.CreateVoidPlatform()
	end
	task.spawn(function()
		if AutoKill.Method == "Knife" and AutoKill.KnifeAura then
			while AutoKill.Enabled do
				AutoKill.KnifeAuraStep()
				RunService.Heartbeat:Wait()
			end
			AutoKill.CycleActive = false
			AutoKill.GunMethod.IsWaiting = false
			AutoKill.GunMethod.IsKilling = false
			AutoKill.StopAutoStomp()
			AutoKill.UnhideCharacter()
			AutoKill.RemoveVoidPlatform()
			AutoKill.UpdateUI("off")
			return
		end
		while AutoKill.Enabled do
			local target = AutoKill.Target
			if not target or not AutoKill.IsValidTarget(target) then
				target = AutoKill.AdvanceTarget()
				if not target then
					AutoKill.GunMethod.IsWaiting = true
					AutoKill.GunMethod.IsKilling = false
					AutoKill.UpdateUI("waiting")
					AutoKill.HideCharacter()
					task.wait(0.1)
					continue
				end
			end
			local targetName = target.DisplayName or target.Name
			local status = AutoKill.GetTargetStatus(target)
			local targetChar = target.Character
			if targetChar and AutoKill.HasForceField(targetChar) then
				AutoKill.GunMethod.IsWaiting = true
				AutoKill.GunMethod.IsKilling = false
				AutoKill.UpdateUI("hiding_kill", targetName)
				AutoKill.HideCharacter()
				task.wait(0.1)
				AutoKill.KeepHidden()
				continue
			end
			if status == "downed" then
				if not AutoKill.GunMethod.StompRunning then
					AutoKill.UpdateUI("stomping", targetName)
					AutoKill.AutoStomp(target)
					AutoKill.GunMethod.IsWaiting = true
					AutoKill.GunMethod.IsKilling = false
				end
				if not AutoKill.GunMethod.IsHiding then
					AutoKill.UpdateUI("hiding_stomp", targetName)
					AutoKill.HideCharacter()
				end
				task.wait(0.1)
				AutoKill.KeepHidden()
			elseif status == "alive" then
				if AutoKill.GunMethod.IsHiding then
					AutoKill.UnhideCharacter()
					task.wait(0.05)
				end
				if AutoKill.GunMethod.StompRunning then
					AutoKill.StopAutoStomp()
				end
				if not AutoKill.GunMethod.IsKilling then
					AutoKill.GunMethod.IsWaiting = false
					AutoKill.GunMethod.IsKilling = true
					AutoKill.UpdateUI("killing", targetName)
					if AutoKill.Method == "Gun" then
						AutoKill.TeleportBehindTarget(target)
						AutoKill.GunMethod.LastTeleportTime = tick()
						AutoKill.FastEquipDoubleBarrel()
					else
						AutoKill.TryEquipKnife()
					end
				end
				if AutoKill.Method == "Gun" then
					if targetChar and AutoKill.HasForceField(targetChar) then
						AutoKill.UpdateUI("hiding_kill", targetName)
						AutoKill.HideCharacter()
						task.wait(0.1)
						AutoKill.KeepHidden()
						continue
					end
					if not AutoKill.FastEquipDoubleBarrel() then
						task.wait(0.1)
						AutoKill.FastEquipDoubleBarrel()
					end
					local ammo = AutoKill.GetDoubleBarrelAmmo()
					if ammo <= 0 then
						AutoKill.HideAndReloadDoubleBarrel()
						continue
					end
					local cooldown = 0.4
					if getgenv().FH_GetWeaponCooldown then
						cooldown = getgenv().FH_GetWeaponCooldown()
					end
					local timeSince = tick() - (getgenv().ForceHit.LastShotTime or 0)
					local canFire = timeSince >= cooldown
					if canFire then
						local currentTime = tick()
						if currentTime - AutoKill.GunMethod.LastTeleportTime > AutoKill.GunMethod.TeleportCooldown then
							AutoKill.TeleportBehindTarget(target)
							AutoKill.GunMethod.LastTeleportTime = currentTime
							task.wait(0.03)
						end
						local stillHasField = target.Character and AutoKill.HasForceField(target.Character)
						if not stillHasField then
							getgenv().FH_Fire(target)
						end
						local waitTime = cooldown - (tick() - (getgenv().ForceHit.LastShotTime or 0))
						if waitTime > 0.02 then
							task.wait(waitTime)
						else
							RunService.Heartbeat:Wait()
						end
					else
						RunService.Heartbeat:Wait()
					end
				else
					AutoKill.KnifeAttackStep(target)
					RunService.Heartbeat:Wait()
				end
			else
				AutoKill.GunMethod.IsWaiting = true
				AutoKill.GunMethod.IsKilling = false
				AutoKill.Target = nil
				task.wait(0.05)
			end
		end
		AutoKill.CycleActive = false
		AutoKill.GunMethod.IsWaiting = false
		AutoKill.GunMethod.IsKilling = false
		AutoKill.StopAutoStomp()
		AutoKill.UnhideCharacter()
		AutoKill.RemoveVoidPlatform()
		AutoKill.UpdateUI("off")
	end)
end

function AutoKill.StopCycle()
	AutoKill.LockedOn = false
	AutoKill.CycleActive = false
	AutoKill.AuraLockedTarget = nil
	AutoKill.GunMethod.IsWaiting = false
	AutoKill.GunMethod.IsKilling = false
	AutoKill.StopAutoStomp()
	AutoKill.UnhideCharacter()
	AutoKill.RemoveVoidPlatform()
	pcall(function()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			sethiddenproperty(root, "PhysicsRepRootPart", root)
		end
	end)
	if getgenv().ForceHit then
		local desired = library.flags["hood_use_forcehit"] or AutoKill.ForceHitWasEnabled or false
		getgenv().ForceHit.Enabled = desired
		if AutoKill.ForceHitOriginal then
			local orig = AutoKill.ForceHitOriginal
			getgenv().ForceHit.MaxDistance = orig.MaxDistance
			getgenv().ForceHit.WallCheck = orig.WallCheck
			getgenv().ForceHit.ForceFieldCheck = orig.ForceFieldCheck
			getgenv().ForceHit.DeathCheck = orig.DeathCheck
			getgenv().ForceHit.PrefireForceField = orig.PrefireForceField
			getgenv().ForceHit.HitPart = orig.HitPart
			AutoKill.ForceHitOriginal = nil
		end
	end
	AutoKill.UpdateUI("off")
end

function AutoKill.StartCycle()
	if not AutoKill.Enabled then return end
	if not AutoKill.Target then
		AutoKill.AdvanceTarget()
	end
	local isAura = (AutoKill.Method == "Knife" and AutoKill.KnifeAura)
	if not AutoKill.Target and not isAura then
		return
	end
	AutoKill.LockedOn = true
	AutoKill.StartCombatCycle()
end
end


do
-- ============================================
-- PROTECT PLAYER FUNCTIONS
-- ============================================
function ProtectPlayer.GetSelectedPlayer()
	local name = ProtectPlayer.SelectedName
	if not name then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name == name then return p end
	end
	return nil
end

function ProtectPlayer.IsValidTarget(player)
	if not player or player == LocalPlayer then return false end
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	return root ~= nil and hum ~= nil and hum.Health > 0
end

function ProtectPlayer.GetTargetStatus(player)
	if not player or not player.Character then return "nochar" end
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return "nochar" end
	if hum.Health <= 0 then return "dead" end
	local be = player.Character:FindFirstChild("BodyEffects")
	if be then
		local dead = be:FindFirstChild("Dead")
		if dead and dead.Value == true then return "dead" end
		local ko = be:FindFirstChild("K.O")
		if ko and ko.Value == true then return "downed" end
	end
	return "alive"
end

function ProtectPlayer.HasGunEquipped(player)
	local char = player.Character
	if not char then return false end
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Tool") then
			local name = child.Name
			if name == "[DoubleBarrel]" or name == "[Revolver]" or name == "[SMG]" or name == "[Shotgun]"
			or name == "[Silencer]" or name == "[TacticalShotgun]" or name == "[Flintlock]"
			or name == "[RPG]" or name == "[Glock]" or name == "[Uzi]" or name == "[Ak47]" then
				return true
			end
		end
	end
	return false
end

function ProtectPlayer.GetNearestEnemyAround(pos, ignorePlayer)
	local closestGun, minDistGun = nil, math.huge
	local closestAny, minDistAny = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p ~= ignorePlayer and ProtectPlayer.IsValidTarget(p) then
			local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local d = (root.Position - pos).Magnitude
				if d < minDistAny then
					minDistAny = d
					closestAny = p
				end
				if ProtectPlayer.HasGunEquipped(p) and d < minDistGun then
					minDistGun = d
					closestGun = p
				end
			end
		end
	end
	return closestGun or closestAny
end

function ProtectPlayer.IsAimingAt(enemy, selected, maxAngle)
	local eChar = enemy.Character
	local sChar = selected.Character
	if not eChar or not sChar then return false end
	local eRoot = eChar:FindFirstChild("HumanoidRootPart")
	local sRoot = sChar:FindFirstChild("HumanoidRootPart")
	if not eRoot or not sRoot then return false end
	local dir = (sRoot.Position - eRoot.Position).Unit
	local look = eRoot.CFrame.LookVector
	local dot = dir:Dot(look)
	local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
	return angle <= maxAngle
end

function ProtectPlayer.GetLikelyShooter(selected, pos)
	local now = tick()
	local maxDist = ProtectPlayer.MaxShooterDistance
	for i = #ProtectPlayer.BulletHistory, 1, -1 do
		local entry = ProtectPlayer.BulletHistory[i]
		if now - entry.Time > ProtectPlayer.BulletWindow then
			table.remove(ProtectPlayer.BulletHistory, i)
		elseif entry.Shooter ~= selected and ProtectPlayer.IsValidTarget(entry.Shooter) then
			return entry.Shooter
		end
	end
	local aimed = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p ~= selected and ProtectPlayer.IsValidTarget(p)
		and ProtectPlayer.HasGunEquipped(p) and ProtectPlayer.IsAimingAt(p, selected, 35) then
			local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if root and (root.Position - pos).Magnitude <= maxDist then
				table.insert(aimed, {Player = p, Dist = (root.Position - pos).Magnitude})
			end
		end
	end
	table.sort(aimed, function(a, b) return a.Dist < b.Dist end)
	if aimed[1] then return aimed[1].Player end
	return nil
end

function ProtectPlayer.TryEquip(toolName)
	local char = LocalPlayer.Character
	if not char then return false end
	local tool = char:FindFirstChild(toolName)
	if tool then return true end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end
	tool = backpack:FindFirstChild(toolName)
	if tool then
		tool.Parent = char
		return true
	end
	return false
end

function ProtectPlayer.GetAmmo()
	local char = LocalPlayer.Character
	if not char then return 0 end
	local tool = char:FindFirstChild("[DoubleBarrel]")
	if not tool then return 0 end
	local scriptObj = tool:FindFirstChild("Script")
	if not scriptObj then return 0 end
	local ammo = scriptObj:FindFirstChild("Ammo")
	local maxAmmo = scriptObj:FindFirstChild("MaxAmmo")
	if ammo and maxAmmo and ammo:IsA("IntValue") and maxAmmo:IsA("IntValue") then
		return ammo.Value
	end
	return 0
end

function ProtectPlayer.ReloadDoubleBarrel()
	local char = LocalPlayer.Character
	if not char then return end
	local tool = char:FindFirstChild("[DoubleBarrel]")
	if not tool then return end
	if MainEvent then
		pcall(function() MainEvent:FireServer("Reload", tool) end)
	end
end

function ProtectPlayer.Stomp()
	if MainEvent then
		pcall(function() MainEvent:FireServer("Stomp") end)
	end
end

function ProtectPlayer.TeleportTo(targetPlayer, offset)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end
	local cf = targetRoot.CFrame
	if offset then
		cf = cf * offset
	end
	root.CFrame = cf
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function ProtectPlayer.GunAttack(target)
	if not ProtectPlayer.TryEquip("[DoubleBarrel]") then return end
	local ammo = ProtectPlayer.GetAmmo()
	if ammo <= 0 then
		ProtectPlayer.ReloadDoubleBarrel()
		return
	end
	ProtectPlayer.TeleportTo(target, CFrame.new(0, 0, 2))
	RunService.Heartbeat:Wait()
	if getgenv().FH_Fire then
		local wasEnabled = getgenv().ForceHit and getgenv().ForceHit.Enabled
		if getgenv().ForceHit then
			getgenv().ForceHit.Enabled = true
		end
		pcall(function() getgenv().FH_Fire(target) end)
		if getgenv().ForceHit and wasEnabled ~= nil then
			getgenv().ForceHit.Enabled = library.flags["hood_use_forcehit"] or wasEnabled
		end
	else
		local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("[DoubleBarrel]")
		if tool then
			pcall(function() tool:Activate() end)
		end
	end
	ProtectPlayer.LastAttackTime = tick()
end

function ProtectPlayer.KnifeAttack(target)
	if not ProtectPlayer.TryEquip("[Knife]") then return end
	ProtectPlayer.TeleportTo(target, CFrame.new(0, 0, 1))
	RunService.Heartbeat:Wait()
	local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("[Knife]")
	if tool then
		local scriptObj = tool:FindFirstChild("Script")
		if scriptObj then
			local can1 = scriptObj:FindFirstChild("CanHitPlayer")
			local can2 = scriptObj:FindFirstChild("CanHitPlayer2")
			if can1 then pcall(function() can1.Value = target.Character end) end
			if can2 then pcall(function() can2.Value = target.Character end) end
		end
		pcall(function() tool:Activate() end)
	end
	ProtectPlayer.LastAttackTime = tick()
end

function ProtectPlayer.Attack(target)
	if ProtectPlayer.Method == "Gun" then
		ProtectPlayer.GunAttack(target)
	else
		ProtectPlayer.KnifeAttack(target)
	end
end

function ProtectPlayer.ReturnToStart()
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if ProtectPlayer.StartCFrame and myRoot and hum then
		myRoot.CFrame = ProtectPlayer.StartCFrame
		myRoot.AssemblyLinearVelocity = Vector3.zero
		myRoot.AssemblyAngularVelocity = Vector3.zero
		hum.Sit = false
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		ProtectPlayer.StartCFrame = nil
	end
end

function ProtectPlayer.SetSpectate(target)
	if not ProtectPlayer.SpectateShooter then return end
	if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
		Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
	elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

function ProtectPlayer.StartAutoStomp(target)
	local state = getgenv().AutoStompState
	if not state or state.running or ProtectPlayer.StompRunning then return end
	ProtectPlayer.StompRunning = true
	local originalTarget = Targeting.Target
	Targeting.Target = target
	state.autostomp = true
	getgenv().AutoStompLoop()
	task.spawn(function()
		while state.running do
			local stillDowned = false
			if target and target.Character then
				local b = target.Character:FindFirstChild("BodyEffects")
				local ko = b and b:FindFirstChild("K.O")
				local dead = b and b:FindFirstChild("Dead")
				if ko and ko.Value and (not dead or not dead.Value) then
					stillDowned = true
				end
			end
			if not ProtectPlayer.Enabled or not ProtectPlayer.StompRunning or not stillDowned then
				state.autostomp = false
			end
			task.wait(0.05)
		end
		Targeting.Target = originalTarget
		ProtectPlayer.StompRunning = false
	end)
end

function ProtectPlayer.StopAutoStomp()
	local state = getgenv().AutoStompState
	if state then state.autostomp = false end
	ProtectPlayer.StompRunning = false
end

function ProtectPlayer.Start()
	if ProtectPlayer.LoopConnection then return end
	ProtectPlayer.LoopConnection = RunService.Heartbeat:Connect(function()
		if not ProtectPlayer.Enabled then return end
		local selected = ProtectPlayer.GetSelectedPlayer()
		if not selected then return end
		if ProtectPlayer.Shooter and not ProtectPlayer.IsValidTarget(ProtectPlayer.Shooter) then
			local status = ProtectPlayer.GetTargetStatus(ProtectPlayer.Shooter)
			if status == "dead" or status == "nochar" then
				ProtectPlayer.SetSpectate(nil)
				ProtectPlayer.StopAutoStomp()
				ProtectPlayer.ReturnToStart()
				ProtectPlayer.Shooter = nil
				ProtectPlayer.Active = false
			end
		end
		if not ProtectPlayer.Shooter or not ProtectPlayer.IsValidTarget(ProtectPlayer.Shooter) then
			if selected.Character then
				local root = selected.Character:FindFirstChild("HumanoidRootPart")
				local hum = selected.Character:FindFirstChildOfClass("Humanoid")
				if root and hum then
					local health = hum.Health
					if ProtectPlayer.LastHealth and health < ProtectPlayer.LastHealth then
						ProtectPlayer.Shooter = ProtectPlayer.GetLikelyShooter(selected, root.Position)
					end
					ProtectPlayer.LastHealth = health
				end
			end
		end
		local shooterStatus = ProtectPlayer.Shooter and ProtectPlayer.GetTargetStatus(ProtectPlayer.Shooter) or "nochar"
		if shooterStatus ~= "nochar" then
			if not ProtectPlayer.StartCFrame then
				local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if myRoot then
					ProtectPlayer.StartCFrame = myRoot.CFrame
				end
			end
			if shooterStatus == "alive" then
				ProtectPlayer.Active = true
				ProtectPlayer.SetSpectate(ProtectPlayer.Shooter)
				if tick() - ProtectPlayer.LastAttackTime >= ProtectPlayer.AttackCooldown then
					ProtectPlayer.Attack(ProtectPlayer.Shooter)
				end
			elseif shooterStatus == "downed" and ProtectPlayer.StompShooter then
				ProtectPlayer.Active = true
				ProtectPlayer.SetSpectate(ProtectPlayer.Shooter)
				if not ProtectPlayer.StompRunning then
					ProtectPlayer.StartAutoStomp(ProtectPlayer.Shooter)
				end
			else
				ProtectPlayer.SetSpectate(nil)
				ProtectPlayer.StopAutoStomp()
				ProtectPlayer.ReturnToStart()
				ProtectPlayer.Shooter = nil
				ProtectPlayer.Active = false
			end
		else
			ProtectPlayer.Active = false
			if selected.Character then
				local hum = selected.Character:FindFirstChildOfClass("Humanoid")
				ProtectPlayer.LastHealth = hum and hum.Health or nil
			end
		end
	end)
	if UnreliableMainEvent and not ProtectPlayer.BulletConnection then
		local function PointSegmentDist(point, startPos, endPos)
			local segment = endPos - startPos
			local t = math.clamp((point - startPos):Dot(segment) / math.max(segment:Dot(segment), 1e-6), 0, 1)
			return (startPos + segment * t - point).Magnitude
		end
		local function ResolveShooter(arg)
			if typeof(arg) == "Instance" and arg:IsA("Player") then
				return arg
			elseif typeof(arg) == "string" then
				return Players:FindFirstChild(arg)
			elseif typeof(arg) == "table" then
				for _, v in pairs(arg) do
					local p = ResolveShooter(v)
					if p then return p end
				end
			end
			return nil
		end
		ProtectPlayer.BulletConnection = UnreliableMainEvent.OnClientEvent:Connect(function(...)
			if not ProtectPlayer.Enabled then return end
			local args = {...}
			if args[1] ~= "ReplicateBulletRay" then return end
			local positions = args[2]
			local shooter = ResolveShooter(args[3])
			if typeof(positions) ~= "table" or not shooter then return end
			if shooter == LocalPlayer then return end
			local startPos = positions[1]
			local endPos = positions[2]
			if typeof(startPos) ~= "Vector3" or typeof(endPos) ~= "Vector3" then return end
			ProtectPlayer.LastGlobalShooter = shooter
			ProtectPlayer.LastGlobalShotTime = tick()
			local selected = ProtectPlayer.GetSelectedPlayer()
			if not selected or not selected.Character then return end
			local closestDist = math.huge
			for _, part in ipairs(selected.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					local d = PointSegmentDist(part.Position, startPos, endPos)
					local radius = math.max(part.Size.X, part.Size.Y, part.Size.Z) / 2
					if d - radius < closestDist then
						closestDist = d - radius
					end
				end
			end
			if closestDist < ProtectPlayer.RayThreshold then
				ProtectPlayer.Shooter = shooter
				table.insert(ProtectPlayer.BulletHistory, {Shooter = shooter, Time = tick()})
				if #ProtectPlayer.BulletHistory > 20 then
					table.remove(ProtectPlayer.BulletHistory, 1)
				end
			end
		end)
	end
end

function ProtectPlayer.Stop()
	if ProtectPlayer.LoopConnection then
		ProtectPlayer.LoopConnection:Disconnect()
		ProtectPlayer.LoopConnection = nil
	end
	if ProtectPlayer.BulletConnection then
		ProtectPlayer.BulletConnection:Disconnect()
		ProtectPlayer.BulletConnection = nil
	end
	ProtectPlayer.Shooter = nil
	ProtectPlayer.Active = false
	ProtectPlayer.LastHealth = nil
	ProtectPlayer.BulletHistory = {}
	ProtectPlayer.LastGlobalShooter = nil
	ProtectPlayer.LastGlobalShotTime = 0
	ProtectPlayer.SetSpectate(nil)
	ProtectPlayer.StopAutoStomp()
	ProtectPlayer.ReturnToStart()
end
end


-- ============================================
do
-- ANTI-AIM (DESYNC)
-- ============================================
local desync_setback = Instance.new("Part")
desync_setback.Name = "Desync Setback"
desync_setback.Parent = workspace
desync_setback.Size = Vector3.new(2, 2, 1)
desync_setback.CanCollide = false
desync_setback.Anchored = true
desync_setback.Transparency = 1

local desync = {
	enabled = false,
	mode = "Void",
	teleportPosition = Vector3.new(0, 0, 0),
	old_position = nil,
	voidSpamActive = false,
	toggleEnabled = false
}

local Offsetposx = 10
local OffsetposY = 10
local Offsetposz = 10

local function resetCamera()
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end

local function toggleDesync(state)
	desync.enabled = state
	if desync.enabled then
		workspace.CurrentCamera.CameraSubject = desync_setback
		Notify("Notification", desync.mode .. "' Enabled", 2)
	else
		resetCamera()
		Notify("Notification", desync.mode .. "' Disabled", 2)
	end
end

RunService.Heartbeat:Connect(function()
	if desync.enabled and LocalPlayer.Character then
		local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			desync.old_position = rootPart.CFrame
			if desync.mode == "Destroy Cheaters" then
				desync.teleportPosition = Vector3.new(11223344556677889900, 1, 1)
			elseif desync.mode == "Underground" then
				desync.teleportPosition = rootPart.Position - Vector3.new(0, 9, 0)
			elseif desync.mode == "UnderGroundV2" then
				desync.teleportPosition = rootPart.Position - Vector3.new(0, 11, 0)
			elseif desync.mode == "Custom" then
				desync.teleportPosition = rootPart.Position - Vector3.new(Offsetposx, OffsetposY, Offsetposz)
			elseif desync.mode == "Void Spam" then
				desync.teleportPosition = math.random(1, 2) == 1 and desync.old_position.Position or Vector3.new(
					math.random(10000, 50000),
					math.random(10000, 50000),
					math.random(10000, 50000)
				)
			elseif desync.mode == "Void" then
				desync.teleportPosition = Vector3.new(
					rootPart.Position.X + math.random(-444444, 444444),
					rootPart.Position.Y + math.random(-444444, 444444),
					rootPart.Position.Z + math.random(-44444, 44444)
				)
			elseif desync.mode == "Anti Connection v1" then
				desync.teleportPosition = Vector3.new(
					rootPart.Position.X + math.random(-444444, 444444),
					rootPart.Position.Y + math.random(-444444, 444444),
					rootPart.Position.Z + math.random(-44444, 44444)
				)
			elseif desync.mode == "Raining" then
				desync.teleportPosition = Vector3.new(
					rootPart.Position.X + math.random(-10, 10),
					rootPart.Position.Y + math.random(2, 5),
					rootPart.Position.Z + math.random(-10, 10)
				)
			elseif desync.mode == "Teleport Maze" then
				desync.teleportPosition = Vector3.new(
					math.random(-100, 100),
					math.random(5, 50),
					math.random(-100, 100)
				)
			end
			local visualizer = workspace:FindFirstChild("DesyncVisualizer")
			if not visualizer then
				visualizer = Instance.new("Part")
				visualizer.Name = "DesyncVisualizer"
				visualizer.Size = Vector3.new(1, 1, 1)
				visualizer.Anchored = true
				visualizer.CanCollide = false
				visualizer.BrickColor = BrickColor.new("Bright blue")
				visualizer.Parent = workspace
			end
			visualizer.Position = desync.teleportPosition
			visualizer.Transparency = 1
			if desync.mode ~= "Rotation" then
				rootPart.CFrame = CFrame.new(desync.teleportPosition)
				workspace.CurrentCamera.CameraSubject = desync_setback
				RunService.RenderStepped:Wait()
				desync_setback.CFrame = desync.old_position * CFrame.new(0, rootPart.Size.Y / 2 + 0.5, 0)
				rootPart.CFrame = desync.old_position
			end
		end
	end
end)

-- ============================================
-- WALKABLE DESYNC + GODMODE
-- ============================================
local WalkableEnabled = false
local WalkableDelay = 800
local WalkableInterval = 6
local VProEn = true

function DesyncWalkable()
	task.spawn(function()
		while WalkableEnabled do
			task.wait()
			if LocalPlayer.Character then
				local loop = RunService.Heartbeat:Connect(function()
					pcall(function()
						sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", true)
					end)
					task.wait(WalkableDelay / 100000)
					pcall(function()
						sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", false)
					end)
				end)
				task.wait(WalkableInterval / 100)
				if loop then loop:Disconnect() end
			end
		end
	end)
end

local function toggleWalkableDesync(v)
	WalkableEnabled = v
	if WalkableEnabled then
		DesyncWalkable()
		Notify("Notification", "Walkable Desync: Enabled", 3)
	else
		Notify("Notification", "Walkable Desync: Disabled", 3)
	end
end

local function toggleGodmode(v)
	if getgenv().AnimGodmode then
		getgenv().AnimGodmode.Set(v)
	end
	if v then
		Notify("Notification", "Animation Godmode: Enabled", 3)
	else
		Notify("Notification", "Animation Godmode: Disabled", 3)
	end
end

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
	if key == "FallenPartsDestroyHeight" and VProEn then
		return -500000000000
	end
	return oldIndex(self, key)
end)
workspace.FallenPartsDestroyHeight = -500000000000

LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(1)
	if character:FindFirstChild("Humanoid") then
		character.Humanoid.BreakJointsOnDeath = false
		character.Humanoid.HealthChanged:Connect(function(health)
			if health <= 0 and character:FindFirstChild("HumanoidRootPart") then
				if character.HumanoidRootPart.Position.Y < -100 then
					character.Humanoid.Health = character.Humanoid.MaxHealth
				end
			end
		end)
	end
end)


-- ============================================
-- TARGET STRAFE
-- ============================================
local bodyClone
pcall(function()
	bodyClone = game:GetObjects("rbxassetid://8246626421")[1]
	if bodyClone then
		if bodyClone:FindFirstChild("Humanoid") then bodyClone.Humanoid:Destroy() end
		if bodyClone.Head and bodyClone.Head:FindFirstChild("Face") then bodyClone.Head.Face:Destroy() end
		bodyClone.Parent = workspace
		bodyClone.HumanoidRootPart.Velocity = Vector3.new()
		bodyClone.HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)
		bodyClone.HumanoidRootPart.Transparency = 1
		bodyClone.HumanoidRootPart.CanCollide = false
		for _, part in pairs(bodyClone:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Material = Enum.Material.Neon
			end
		end
	end
end)

local TargetStrafeConfig = {
	Enabled = false,
	Type = "Strafe",
	Speed = 5,
	Height = 0,
	Distance = 8,
	RandomRange = 10,
	BodyColor = Color3.fromRGB(127, 13, 195),
	Visualize = true,
	Indicator = false,
	IndicatorColor = Color3.fromRGB(193, 247, 255),
	IndicatorGlowColor = Color3.fromRGB(193, 247, 255),
	IndicatorBackgroundColor = Color3.fromRGB(15, 15, 15)
}

local Radians = 0
local saved_desync = nil
local hook_active = false
local old_index_strafe = nil

local indicatorCircle = Drawing.new("Circle")
indicatorCircle.Visible = false
indicatorCircle.Radius = 20
indicatorCircle.Thickness = 2
indicatorCircle.Filled = false
indicatorCircle.NumSides = 32

local function enableStrafeHook()
	if not hook_active and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		old_index_strafe = hookmetamethod(game, "__index", function(self, index)
			if not checkcaller()
			and TargetStrafeConfig.Enabled
			and saved_desync
			and index == "CFrame"
			and self == LocalPlayer.Character.HumanoidRootPart then
				return saved_desync
			end
			return old_index_strafe(self, index)
		end)
		hook_active = true
	end
end

local function disableStrafeHook()
	if hook_active then
		pcall(function()
			if old_index_strafe then
				hookmetamethod(game, "__index", old_index_strafe)
			end
		end)
		hook_active = false
		old_index_strafe = nil
	end
end

local function updateStrafeIndicator(worldPosition)
	if not TargetStrafeConfig.Indicator or not worldPosition then
		indicatorCircle.Visible = false
		return
	end
	local pos, onScreen = Camera:WorldToViewportPoint(worldPosition)
	if onScreen then
		indicatorCircle.Position = Vector2.new(pos.X, pos.Y)
		indicatorCircle.Color = TargetStrafeConfig.IndicatorColor
		indicatorCircle.Visible = true
	else
		indicatorCircle.Visible = false
	end
end

local function TargetStrafe(dt)
	local TargetPlayer = Targeting.Target
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		if TargetStrafeConfig.Enabled then
			enableStrafeHook()
			saved_desync = hrp.CFrame
			local Origin
			local targetHrp = TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if targetHrp then
				Origin = targetHrp
			else
				Origin = hrp
			end
			local randomRange = TargetStrafeConfig.RandomRange
			Radians += TargetStrafeConfig.Speed
			local calculatedPositions = {
				["Strafe"] = Origin.CFrame * CFrame.Angles(0, math.rad(Radians), 0) * CFrame.new(0, TargetStrafeConfig.Height, TargetStrafeConfig.Distance),
				["Roll"] = Origin.CFrame * CFrame.new(0, -4, 0) * CFrame.Angles(0, math.rad(math.random(1, 360)), math.rad(-180)),
				["Tween"] = (CFrame.new(Origin.Position) + Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180))),
				["Random"] = (CFrame.new(Origin.Position) + Vector3.new(math.random(-randomRange, randomRange), math.random(-randomRange, randomRange), math.random(-randomRange, randomRange))) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180))),
			}
			local PredictedPosition = calculatedPositions[TargetStrafeConfig.Type]
			if TargetStrafeConfig.Type == "Tween" then
				TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = PredictedPosition}):Play()
				task.wait(0.1)
			else
				hrp.CFrame = PredictedPosition
			end
			if TargetStrafeConfig.Visualize and bodyClone then
				bodyClone:SetPrimaryPartCFrame(PredictedPosition)
			end
			updateStrafeIndicator(PredictedPosition.Position)
			RunService.RenderStepped:Wait()
			hrp.CFrame = saved_desync
		else
			if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
			updateStrafeIndicator(nil)
			disableStrafeHook()
		end
	else
		if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
		updateStrafeIndicator(nil)
		disableStrafeHook()
	end
end

RunService.Heartbeat:Connect(TargetStrafe)

Players.PlayerRemoving:Connect(function(player)
	if player == LocalPlayer then
		if bodyClone then bodyClone:Destroy() end
		indicatorCircle:Remove()
		disableStrafeHook()
	end
end)
end


-- ============================================
-- TARGET UI
-- ============================================
local TargetUI = {
	Instance = nil,
	Enabled = false,
	Style = "Old",
	Position = "Free",
	UseGlow = true,
	BorderColor = Color3.fromRGB(27, 206, 203),
	GlowColor = Color3.fromRGB(27, 206, 203),
	HealthStart = Color3.fromRGB(0, 255, 0),
	HealthMid = Color3.fromRGB(255, 170, 0),
	HealthEnd = Color3.fromRGB(255, 0, 0),
	AmmoStart = Color3.fromRGB(255, 140, 0),
	AmmoMid = Color3.fromRGB(255, 85, 0),
	AmmoEnd = Color3.fromRGB(255, 0, 0),
}

local function makeGradient(startCol, midCol, endCol)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, startCol),
		ColorSequenceKeypoint.new(0.5, midCol),
		ColorSequenceKeypoint.new(1, endCol),
	})
end

local function getTargetAmmo(character)
	if not character then return 0, 0 end
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then return 0, 0 end
	local script = tool:FindFirstChild("Script")
	if not script then return 0, 0 end
	local ammo = script:FindFirstChild("Ammo")
	local maxAmmo = script:FindFirstChild("MaxAmmo")
	if ammo and maxAmmo and ammo:IsA("IntValue") and maxAmmo:IsA("IntValue") then
		return ammo.Value, maxAmmo.Value
	end
	return 0, 0
end

function TargetUI.Create()
	if TargetUI.Instance then TargetUI.Instance:Destroy() end
	local IndicatorUI = Instance.new("ScreenGui")
	IndicatorUI.Name = "HoodTargetUI"
	IndicatorUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() IndicatorUI.Parent = gethui() end)
	if not IndicatorUI.Parent then IndicatorUI.Parent = CoreGui end
	TargetUI.Instance = IndicatorUI

	local MainFrame = Instance.new("Frame")
	MainFrame.AnchorPoint = Vector2.new(0.5, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, 0, 1, -250)
	MainFrame.Size = UDim2.new(0, 322, 0, 120)
	MainFrame.Parent = IndicatorUI
	MainFrame.Active = true
	MainFrame.Draggable = true

	local OuterBorder = Instance.new("Frame")
	OuterBorder.BackgroundColor3 = TargetUI.BorderColor
	OuterBorder.BorderSizePixel = 0
	OuterBorder.Position = UDim2.new(0, 1, 0, 1)
	OuterBorder.Size = UDim2.new(1, -2, 1, -2)
	OuterBorder.Parent = MainFrame

	local InnerBorder = Instance.new("Frame")
	InnerBorder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	InnerBorder.BorderSizePixel = 0
	InnerBorder.Position = UDim2.new(0, 1, 0, 1)
	InnerBorder.Size = UDim2.new(1, -2, 1, -2)
	InnerBorder.Parent = OuterBorder

	local ContentFrame = Instance.new("Frame")
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.BorderSizePixel = 0
	ContentFrame.Position = UDim2.new(0, 1, 0, 2)
	ContentFrame.Size = UDim2.new(1, -2, 1, -4)
	ContentFrame.Parent = InnerBorder

	local PlayerIcon = Instance.new("ImageLabel")
	PlayerIcon.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"
	PlayerIcon.BackgroundTransparency = 1
	PlayerIcon.BorderSizePixel = 0
	PlayerIcon.Size = UDim2.new(0, 68, 0, 68)
	PlayerIcon.Position = UDim2.new(0, 4, 0, 4)
	PlayerIcon.Parent = ContentFrame

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Font = Enum.Font.SourceSans
	NameLabel.Text = "Player (@username)"
	NameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	NameLabel.TextSize = 14
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.BackgroundTransparency = 1
	NameLabel.BorderSizePixel = 0
	NameLabel.Position = UDim2.new(0, 78, 0, 4)
	NameLabel.Size = UDim2.new(1, -82, 0, 20)
	NameLabel.Parent = ContentFrame

	local DistanceLabel = Instance.new("TextLabel")
	DistanceLabel.Font = Enum.Font.SourceSans
	DistanceLabel.Text = "0 studs"
	DistanceLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	DistanceLabel.TextSize = 12
	DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	DistanceLabel.BackgroundTransparency = 1
	DistanceLabel.BorderSizePixel = 0
	DistanceLabel.Position = UDim2.new(0, 78, 0, 24)
	DistanceLabel.Size = UDim2.new(1, -82, 0, 18)
	DistanceLabel.Parent = ContentFrame

	local HealthFrame = Instance.new("Frame")
	HealthFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	HealthFrame.BorderSizePixel = 0
	HealthFrame.Position = UDim2.new(0, 78, 0, 48)
	HealthFrame.Size = UDim2.new(1, -82, 0, 14)
	HealthFrame.Parent = ContentFrame

	local HealthInner = Instance.new("Frame")
	HealthInner.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	HealthInner.BorderSizePixel = 0
	HealthInner.Position = UDim2.new(0, 1, 0, 1)
	HealthInner.Size = UDim2.new(1, -2, 1, -2)
	HealthInner.Parent = HealthFrame

	local HealthBarValue = Instance.new("Frame")
	HealthBarValue.BackgroundColor3 = Color3.fromRGB(45, 195, 45)
	HealthBarValue.BorderSizePixel = 0
	HealthBarValue.Size = UDim2.new(1, 0, 1, 0)
	HealthBarValue.Parent = HealthInner
	local HealthGradient = Instance.new("UIGradient")
	HealthGradient.Parent = HealthBarValue

	local HealthText = Instance.new("TextLabel")
	HealthText.Font = Enum.Font.SourceSans
	HealthText.Text = "100/100"
	HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	HealthText.TextSize = 12
	HealthText.BackgroundTransparency = 1
	HealthText.BorderSizePixel = 0
	HealthText.Size = UDim2.new(1, 0, 1, 0)
	HealthText.Parent = HealthInner

	local ArmorFrame = Instance.new("Frame")
	ArmorFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	ArmorFrame.BorderSizePixel = 0
	ArmorFrame.Position = UDim2.new(0, 78, 0, 66)
	ArmorFrame.Size = UDim2.new(1, -82, 0, 14)
	ArmorFrame.Parent = ContentFrame

	local ArmorInner = Instance.new("Frame")
	ArmorInner.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	ArmorInner.BorderSizePixel = 0
	ArmorInner.Position = UDim2.new(0, 1, 0, 1)
	ArmorInner.Size = UDim2.new(1, -2, 1, -2)
	ArmorInner.Parent = ArmorFrame

	local ArmorBarValue = Instance.new("Frame")
	ArmorBarValue.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
	ArmorBarValue.BorderSizePixel = 0
	ArmorBarValue.Size = UDim2.new(1, 0, 1, 0)
	ArmorBarValue.Parent = ArmorInner
	local ArmorGradient = Instance.new("UIGradient")
	ArmorGradient.Parent = ArmorBarValue

	local ArmorText = Instance.new("TextLabel")
	ArmorText.Font = Enum.Font.SourceSans
	ArmorText.Text = "0/0"
	ArmorText.TextColor3 = Color3.fromRGB(255, 255, 255)
	ArmorText.TextSize = 12
	ArmorText.BackgroundTransparency = 1
	ArmorText.BorderSizePixel = 0
	ArmorText.Size = UDim2.new(1, 0, 1, 0)
	ArmorText.Parent = ArmorInner

	local Glow = Instance.new("ImageLabel")
	Glow.BackgroundTransparency = 1
	Glow.Image = "rbxassetid://18245826428"
	Glow.ScaleType = Enum.ScaleType.Slice
	Glow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
	Glow.ImageColor3 = TargetUI.GlowColor
	Glow.ImageTransparency = 0.85
	Glow.Position = UDim2.new(0, -20, 0, -20)
	Glow.Size = UDim2.new(1, 40, 1, 40)
	Glow.ZIndex = MainFrame.ZIndex - 1
	Glow.Parent = MainFrame
	Glow.Visible = TargetUI.UseGlow

	if TargetUI.Style == "Modern" then
		for _, frame in ipairs({MainFrame, OuterBorder, InnerBorder, HealthFrame, HealthInner, ArmorFrame, ArmorInner, PlayerIcon}) do
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = frame
		end
	end

	local lastTarget = nil
	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not TargetUI.Instance or not TargetUI.Instance.Parent then
			connection:Disconnect()
			return
		end
		local targetPlayer = nil
		if Targeting.LockedOn and Targeting.Target then
			targetPlayer = Targeting.Target
		elseif AutoKill.Enabled and AutoKill.Target then
			targetPlayer = AutoKill.Target
		end
		if not targetPlayer or not targetPlayer.Character or not TargetUI.Enabled then
			IndicatorUI.Enabled = false
			return
		end
		IndicatorUI.Enabled = true
		local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			HealthBarValue.Size = UDim2.new(hp, 0, 1, 0)
			HealthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
			HealthGradient.Color = makeGradient(TargetUI.HealthStart, TargetUI.HealthMid, TargetUI.HealthEnd)
		end
		if targetPlayer ~= lastTarget then
			PlayerIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetPlayer.UserId .. "&w=420&h=420"
			NameLabel.Text = targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
			lastTarget = targetPlayer
		end
		local lpChar = LocalPlayer.Character
		local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if lpChar and lpChar:FindFirstChild("HumanoidRootPart") and targetHrp then
			DistanceLabel.Text = math.floor((lpChar.HumanoidRootPart.Position - targetHrp.Position).Magnitude) .. " studs"
		else
			DistanceLabel.Text = "N/A studs"
		end
		local ammoCurrent, ammoMax = getTargetAmmo(targetPlayer.Character)
		local ammoPercent = (ammoMax > 0) and math.clamp(ammoCurrent / ammoMax, 0, 1) or 0
		ArmorBarValue.Size = UDim2.new(ammoPercent, 0, 1, 0)
		ArmorText.Text = math.floor(ammoCurrent) .. "/" .. math.floor(ammoMax)
		ArmorGradient.Color = makeGradient(TargetUI.AmmoStart, TargetUI.AmmoMid, TargetUI.AmmoEnd)

		OuterBorder.BackgroundColor3 = TargetUI.BorderColor
		Glow.ImageColor3 = TargetUI.GlowColor
		Glow.Visible = TargetUI.UseGlow

		if TargetUI.Position == "Follow Target" then
			local head = targetPlayer.Character:FindFirstChild("Head")
			if head then
				local headTop = head.Position + head.CFrame.UpVector * (head.Size.Y * 0.5)
				local headRight = head.Position + head.CFrame.RightVector * (head.Size.X * 0.5)
				local topScreen, topOnScreen = Camera:WorldToViewportPoint(headTop)
				local rightScreen, rightOnScreen = Camera:WorldToViewportPoint(headRight)
				if topOnScreen and rightOnScreen then
					local absSize = MainFrame.AbsoluteSize
					local viewportSize = Camera.ViewportSize
					local paddingX, paddingY = 55, 55
					local posX = rightScreen.X + absSize.X * 0.5 + paddingX
					local posY = topScreen.Y - absSize.Y - paddingY
					posX = math.clamp(posX, absSize.X * 0.5, math.max(absSize.X * 0.5, viewportSize.X - absSize.X * 0.5))
					posY = math.clamp(posY, 0, math.max(0, viewportSize.Y - absSize.Y))
					MainFrame.Draggable = false
					MainFrame.Position = UDim2.new(0, posX, 0, posY)
				end
			end
		else
			MainFrame.Draggable = true
		end
	end)

	return IndicatorUI
end


-- ============================================
-- HITSOUND HEALTH TRACKING
-- ============================================
local PlayerHealths = {}
local lastTargetHealth = nil
local lastAutoKillHealth = nil

local function trackTargetHealth(target, isAutoKill)
	if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
		local humanoid = target.Character.Humanoid
		PlayerHealths[target] = humanoid.Health
		local connection
		connection = humanoid.HealthChanged:Connect(function(newHealth)
			local oldHealth = PlayerHealths[target] or newHealth
			local isCurrentTarget = false
			if isAutoKill then
				isCurrentTarget = (target == AutoKill.Target and AutoKill.Enabled)
			else
				isCurrentTarget = (target == Targeting.Target and Targeting.LockedOn)
			end
			if newHealth < oldHealth and isCurrentTarget then
				PlayHitsound()
			end
			PlayerHealths[target] = newHealth
		end)
	end
end

RunService.Heartbeat:Connect(function()
	if Targeting.Target ~= lastTargetHealth then
		if lastTargetHealth then PlayerHealths[lastTargetHealth] = nil end
		if Targeting.Target and Targeting.LockedOn then
			trackTargetHealth(Targeting.Target, false)
		end
		lastTargetHealth = Targeting.Target
	end
	if AutoKill.Target ~= lastAutoKillHealth then
		if lastAutoKillHealth then PlayerHealths[lastAutoKillHealth] = nil end
		if AutoKill.Target and AutoKill.Enabled then
			trackTargetHealth(AutoKill.Target, true)
		end
		lastAutoKillHealth = AutoKill.Target
	end
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerHealths[player] = nil
end)

-- ============================================
-- JUMP OFFSET LOOP
-- ============================================
task.spawn(function()
	while true do
		task.wait()
		if Targeting.AntiGroundShot and library.flags["hood_use_jump_offset"] and Targeting.Target and Targeting.Target.Character then
			local humanoid = Targeting.Target.Character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Jump and humanoid.FloorMaterial == Enum.Material.Air then
				JumpOffsetValue = library.flags["hood_jump_offset"] or Targeting.JumpOffset
			else
				JumpOffsetValue = 0
			end
		else
			JumpOffsetValue = 0
		end
	end
end)

-- ============================================
-- KNIFE HITBOX EXPANDER LOOP
-- ============================================
RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local knife = char:FindFirstChild("[Knife]") or LocalPlayer.Backpack:FindFirstChild("[Knife]")
	if not knife then return end
	local handle = knife:FindFirstChild("Handle")
	if not handle then return end
	local hitbox = handle:FindFirstChild("HITBOX_PART")
	if not hitbox then return end
	pcall(function()
		if AutoKill.KnifeExpander.Enabled then
			local sz = math.max(AutoKill.KnifeExpander.Size, 1)
			hitbox.Size = Vector3.new(sz, sz, sz)
			hitbox.CanCollide = false
			hitbox.Massless = true
			hitbox.Color = AutoKill.KnifeExpander.FillColor
			if AutoKill.KnifeExpander.Fill then
				hitbox.Transparency = math.clamp(AutoKill.KnifeExpander.FillTransparency, 0, 1)
				hitbox.Material = Enum.Material.Neon
			else
				hitbox.Transparency = 1
			end
		end
		local outline = hitbox:FindFirstChild("KnifeHitboxOutline")
		if outline and not outline:IsA("SelectionBox") then
			outline:Destroy()
			outline = nil
		end
		if AutoKill.KnifeExpander.Enabled and AutoKill.KnifeExpander.Outline then
			if not outline then
				outline = Instance.new("SelectionBox")
				outline.Name = "KnifeHitboxOutline"
				outline.Adornee = hitbox
				outline.LineThickness = 0.03
				outline.SurfaceTransparency = 1
				outline.Parent = hitbox
			end
			outline.Color3 = AutoKill.KnifeExpander.OutlineColor
			outline.Transparency = 1 - math.clamp(AutoKill.KnifeExpander.OutlineTransparency, 0, 1)
			outline.Visible = true
		elseif outline then
			outline.Visible = false
		end
	end)
end)


-- ============================================
-- MOUSE.HIT HOOK (Target Aim)
-- ============================================
local Mt = getrawmetatable(game)
setreadonly(Mt, false)
local OldIndex = Mt.__index
Mt.__index = function(Self, Index)
	if not checkcaller() and Self == Mouse and Index == "Hit" then
		local Target = Targeting.Target
		if getgenv().ForceHit and library.flags["hood_use_forcehit"] then
			if Target and Target.Character and IsValidTarget(Target) then
				local Part = Target.Character:FindFirstChild(Targeting.TargetAimbotPart)
				if Part then
					local Position = Part.Position
					if Targeting.PredictionEnabled and library.flags["hood_use_prediction"] then
						local predictionValue = library.flags["hood_prediction_value"] or Targeting.Prediction
						if type(predictionValue) == "string" then predictionValue = tonumber(predictionValue) end
						Position = Position + (Part.Velocity * predictionValue)
					end
					if not getgenv().ForceHit.Enabled then
						getgenv().ForceHit.Enabled = true
					end
					task.spawn(function()
						getgenv().FH_Fire(Target)
					end)
					return CFrame.new(Position)
				end
			end
		end
		if Targeting.AimbotMethod == "Index" and Targeting.LockedOn then
			if Target and Target.Character and IsValidTarget(Target) then
				local Part = Target.Character:FindFirstChild(Targeting.TargetAimbotPart)
				if Part then
					local Position = Part.Position
					if Targeting.PredictionEnabled and library.flags["hood_use_prediction"] then
						local predictionValue = library.flags["hood_prediction_value"] or Targeting.Prediction
						if type(predictionValue) == "string" then predictionValue = tonumber(predictionValue) end
						Position = Position + (Part.Velocity * predictionValue)
					end
					if Targeting.AntiGroundShot and library.flags["hood_use_jump_offset"] then
						Position = Position + Vector3.new(0, JumpOffsetValue, 0)
					end
					return CFrame.new(Position)
				end
			end
		end
	end
	return OldIndex(Self, Index)
end

-- ============================================
-- FORCEHIT SYNC LOOP
-- ============================================
task.spawn(function()
	while true do
		if getgenv().ForceHit and not getgenv().ForceHit._InternalOverride then
			local desired = library.flags["hood_use_forcehit"] or false
			if getgenv().ForceHit.Enabled ~= desired then
				getgenv().ForceHit.Enabled = desired
			end
		end
		task.wait(0.2)
	end
end)

-- ============================================
-- MAIN RENDER LOOP
-- ============================================
RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	local showFOV = FOVCircleConfig.Enabled
	if showFOV then
		FOVCircleConfig.RainbowHue = (FOVCircleConfig.RainbowHue + 0.005) % 1
		local displayColor = FOVCircleConfig.RainbowEnabled
			and Color3.fromHSV(FOVCircleConfig.RainbowHue, 1, 1)
			or FOVCircleConfig.Color
		if FOVCircleConfig.Outline then
			fovCircleOutline.Position = mousePos
			fovCircleOutline.Radius = FOVCircleConfig.Radius
			fovCircleOutline.Color = FOVCircleConfig.OutlineColor
			fovCircleOutline.Thickness = FOVCircleConfig.OutlineThickness
			fovCircleOutline.Transparency = 1 - FOVCircleConfig.OutlineTransparency
			fovCircleOutline.Visible = true
		else
			fovCircleOutline.Visible = false
		end
		if FOVCircleConfig.Filled then
			fovCircleFill.Position = mousePos
			fovCircleFill.Radius = FOVCircleConfig.Radius
			fovCircleFill.Color = FOVCircleConfig.FillColor
			fovCircleFill.Transparency = 1 - FOVCircleConfig.FillTransparency
			fovCircleFill.Visible = true
		else
			fovCircleFill.Visible = false
		end
		fovCircle.Position = mousePos
		fovCircle.Radius = FOVCircleConfig.Radius
		fovCircle.Color = displayColor
		fovCircle.Thickness = FOVCircleConfig.Thickness
		fovCircle.Transparency = 1 - FOVCircleConfig.Transparency
		fovCircle.Visible = true
		if FOVCircleConfig.DotCenter then
			fovCenterDot.Position = mousePos
			fovCenterDot.Radius = FOVCircleConfig.DotRadius
			fovCenterDot.Color = FOVCircleConfig.DotColor
			fovCenterDot.Visible = true
		else
			fovCenterDot.Visible = false
		end
	else
		fovCircle.Visible = false
		fovCircleFill.Visible = false
		fovCircleOutline.Visible = false
		fovCenterDot.Visible = false
	end

	if Targeting.LockedOn and Targeting.Target then
		if IsValidTarget(Targeting.Target) then
			Targeting.WaitingForRespawn = false
		elseif IsTargetDeadOrRespawning(Targeting.Target) then
			if not Targeting.WaitingForRespawn then
				Targeting.WaitingForRespawn = true
				if Targeting.Highlight then
					Targeting.Highlight:Destroy()
					Targeting.Highlight = nil
				end
			end
			dot.Visible = false
			tracer.Visible = false
			tracerOutline.Visible = false
			return
		else
			ClearTarget()
			Targeting.LockedOn = false
			return
		end
	elseif Targeting.LockedOn and not Targeting.Target then
		GetClosestTarget()
		return
	end

	local vizTarget = nil
	local vizPartName = Targeting.TargetAimbotPart
	if Targeting.LockedOn and Targeting.Target and IsValidTarget(Targeting.Target) and not Targeting.WaitingForRespawn then
		vizTarget = Targeting.Target
	elseif AutoKill.Enabled and AutoKill.Target and AutoKill.IsValidTarget(AutoKill.Target) then
		vizTarget = AutoKill.Target
	end

	if vizTarget and vizTarget.Character and Targeting.HighlightEnabled and library.flags["hood_highlight_enabled"] then
		if not Targeting.Highlight or Targeting.Highlight.Adornee ~= vizTarget.Character then
			UpdateHighlight(vizTarget)
		end
	elseif not vizTarget then
		if Targeting.Highlight then
			UpdateHighlight(nil)
		end
	end

	if vizTarget and vizTarget.Character then
		local targetPart = vizTarget.Character:FindFirstChild(vizPartName)
		if targetPart then
			if Targeting.DotEnabled and library.flags["hood_dot_enabled"] then
				local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					dot.Position = Vector2.new(screenPos.X, screenPos.Y)
					local dotCol = library.flags["hood_dot_color"] and library.flags["hood_dot_color"].Color or Targeting.DotColor
					dot.Color = dotCol
					dot.Visible = true
				else
					dot.Visible = false
				end
			else
				dot.Visible = false
			end

			if Targeting.TracerEnabled and library.flags["hood_tracer_enabled"] then
				local targetPos = targetPart.Position
				local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
				local viewportSize = Camera.ViewportSize
				local centerX, centerY = viewportSize.X / 2, viewportSize.Y / 2
				local tracerStartPos
				local startMode = library.flags["hood_tracer_start_position"] or Targeting.TracerStartPosition
				if startMode == "Mouse" then
					tracerStartPos = UserInputService:GetMouseLocation()
				elseif startMode == "Bottom" then
					tracerStartPos = Vector2.new(centerX, viewportSize.Y)
				elseif startMode == "Top" then
					tracerStartPos = Vector2.new(centerX, 0)
				elseif startMode == "HumanoidRootPart" then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local pos, startOnScreen = Camera:WorldToViewportPoint(hrp.Position)
						tracerStartPos = Vector2.new(pos.X, pos.Y)
					else
						tracerStartPos = UserInputService:GetMouseLocation()
					end
				else
					tracerStartPos = UserInputService:GetMouseLocation()
				end
				local tracerEndPos
				if onScreen then
					tracerEndPos = Vector2.new(screenPos.X, screenPos.Y)
				else
					local dirX = screenPos.X - centerX
					local dirY = screenPos.Y - centerY
					local magnitude = math.sqrt(dirX^2 + dirY^2)
					if magnitude > 0 then
						dirX = dirX / magnitude
						dirY = dirY / magnitude
						local edgeX = centerX + dirX * (viewportSize.X / 2 - 50)
						local edgeY = centerY + dirY * (viewportSize.Y / 2 - 50)
						tracerEndPos = Vector2.new(edgeX, edgeY)
					else
						tracerEndPos = Vector2.new(centerX, centerY)
					end
				end
				local tracerCol = library.flags["hood_tracer_color"] and library.flags["hood_tracer_color"].Color or Targeting.TracerColor
				local tracerThick = library.flags["hood_tracer_thickness"] or Targeting.TracerThickness
				local outlineThick = library.flags["hood_tracer_outline_thickness"] or Targeting.TracerOutlineThickness
				tracerOutline.From = tracerStartPos
				tracerOutline.To = tracerEndPos
				tracerOutline.Thickness = outlineThick
				tracerOutline.Visible = true
				tracer.From = tracerStartPos
				tracer.To = tracerEndPos
				tracer.Color = tracerCol
				tracer.Thickness = tracerThick
				tracer.Visible = true
			else
				tracer.Visible = false
				tracerOutline.Visible = false
			end
		else
			dot.Visible = false
			tracer.Visible = false
			tracerOutline.Visible = false
		end
	else
		dot.Visible = false
		tracer.Visible = false
		tracerOutline.Visible = false
	end

	if Targeting.SpectateTarget and library.flags["hood_spectate_target"] then
		local spectateTarget = nil
		if Targeting.LockedOn and Targeting.Target and Targeting.Target.Character and Targeting.Target.Character:FindFirstChild("Humanoid") then
			spectateTarget = Targeting.Target.Character.Humanoid
		elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			spectateTarget = LocalPlayer.Character.Humanoid
		end
		if spectateTarget and Camera.CameraSubject ~= spectateTarget then
			Camera.CameraSubject = spectateTarget
		end
	end

	if Targeting.LookAtTarget and library.flags["hood_look_at_target"] then
		local lookTarget = nil
		if Targeting.LockedOn and Targeting.Target and Targeting.Target.Character then
			local part = Targeting.Target.Character:FindFirstChild(Targeting.TargetAimbotPart)
			if part then lookTarget = part end
		end
		if lookTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = LocalPlayer.Character.HumanoidRootPart
			local myPos = hrp.Position
			local targetPos = Vector3.new(lookTarget.Position.X, myPos.Y, lookTarget.Position.Z)
			LocalPlayer.Character.Humanoid.AutoRotate = false
			hrp.CFrame = CFrame.new(myPos, targetPos)
		end
	else
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.AutoRotate = true
		end
	end
end)


-- ============================================
-- COMBAT UI
-- ============================================
do
local col1 = Combat:column()
local secTargetAim = col1:section({name = "Target Aim", toggle = false})

secTargetAim:toggle({name = "Target Aim", flag = "hood_target_aim_enabled", callback = function(v)
	toggleTargetAim(v)
end}):keybind({name = "Target Closest", flag = "hood_target_aim_bind", callback = function(active)
	if not library.flags["hood_target_aim_enabled"] then return end
	if active and not Targeting.LockedOn then
		Targeting.LockedOn = true
		GetClosestTarget()
	elseif not active and Targeting.LockedOn then
		Targeting.LockedOn = false
		ClearTarget()
	end
end})

secTargetAim:toggle({name = "Use Forcehit", flag = "hood_use_forcehit", callback = function(v)
	if getgenv().ForceHit then
		getgenv().ForceHit.Enabled = v
	end
end})

secTargetAim:toggle({name = "Auto Stomp", flag = "hood_auto_stomp", callback = function(v)
	local state = getgenv().AutoStompState
	if state then
		state.autostomp = v
		if state.autostomp then
			getgenv().AutoStompLoop()
		else
			state.running = false
			state.ret = nil
		end
	end
end})

secTargetAim:toggle({name = "Use FOV", flag = "hood_target_aim_use_fov"})
secTargetAim:toggle({name = "Use Prediction", flag = "hood_use_prediction", callback = function(v)
	Targeting.PredictionEnabled = v
end})

secTargetAim:textbox({name = "Prediction Value", flag = "hood_prediction_value", default = "0.1433", callback = function(v)
	local num = tonumber(v)
	if num then
		Targeting.Prediction = math.clamp(num, 0, 1)
	end
end})

secTargetAim:toggle({name = "Use Jump Offset", flag = "hood_use_jump_offset", callback = function(v)
	Targeting.AntiGroundShot = v
end})

secTargetAim:textbox({name = "Jump Offset", flag = "hood_jump_offset", default = "0.5", callback = function(v)
	local num = tonumber(v)
	if num then
		Targeting.JumpOffset = math.clamp(num, 0, 2)
	end
end})

secTargetAim:toggle({name = "Spectate Target", flag = "hood_spectate_target", callback = function(v)
	Targeting.SpectateTarget = v
	if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
	end
end})

secTargetAim:toggle({name = "Look At Target", flag = "hood_look_at_target", callback = function(v)
	Targeting.LookAtTarget = v
	if not v then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.AutoRotate = true
		end
	end
end})

local secProtect = col1:section({name = "Protect Player", toggle = false})
local protectDropdown

secProtect:toggle({name = "Use", flag = "hood_protect_player_enabled", callback = function(v)
	ProtectPlayer.Enabled = v
	if v then
		ProtectPlayer.Start()
	else
		ProtectPlayer.Stop()
	end
end})

secProtect:dropdown({name = "Mode", flag = "hood_protect_player_method", items = {"Gun", "Knife"}, default = "Gun", callback = function(v)
	ProtectPlayer.Method = v
end})

protectDropdown = secProtect:dropdown({name = "Player", flag = "hood_protect_player_target", items = {}, default = nil, callback = function(v)
	ProtectPlayer.SelectedName = v
	ProtectPlayer.LastHealth = nil
end})

secProtect:toggle({name = "Stomp Shooter", flag = "hood_protect_player_stomp", callback = function(v)
	ProtectPlayer.StompShooter = v
end})

secProtect:toggle({name = "Spectate Shooter", flag = "hood_protect_player_spectate", callback = function(v)
	ProtectPlayer.SpectateShooter = v
	if not v then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end
end})

local function UpdateProtectPlayerList()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(list, p.Name)
		end
	end
	if protectDropdown and protectDropdown.refresh_options then
		protectDropdown:refresh_options(list)
	end
	if not table.find(list, ProtectPlayer.SelectedName or "") then
		ProtectPlayer.SelectedName = nil
	end
end
Players.PlayerAdded:Connect(UpdateProtectPlayerList)
Players.PlayerRemoving:Connect(UpdateProtectPlayerList)
task.spawn(UpdateProtectPlayerList)

local secFOV = col1:section({name = "FOV Circle", toggle = false})
local fovToggle = secFOV:toggle({name = "Show FOV Circle", flag = "hood_fov_circle_enabled", callback = function(v)
	FOVCircleConfig.Enabled = v
	if not v then
		fovCircle.Visible = false
		fovCircleFill.Visible = false
		fovCircleOutline.Visible = false
		fovCenterDot.Visible = false
	end
end})
fovToggle:colorpicker({name = "FOV Color", flag = "hood_fov_circle_color", color = Color3.fromRGB(255,255,255), callback = function(col, a)
	FOVCircleConfig.Color = col
end})

secFOV:slider({name = "Radius", flag = "hood_fov_circle_radius", min = 10, max = 800, default = 150, interval = 1, suffix = " px", callback = function(v)
	FOVCircleConfig.Radius = v
end})
secFOV:slider({name = "Thickness", flag = "hood_fov_circle_thickness", min = 1, max = 10, default = 1, interval = 1, callback = function(v)
	FOVCircleConfig.Thickness = v
end})
secFOV:slider({name = "Transparency", flag = "hood_fov_circle_transparency", min = 0, max = 1, default = 0, interval = 0.01, callback = function(v)
	FOVCircleConfig.Transparency = v
end})

local fovFill = secFOV:toggle({name = "Fill", flag = "hood_fov_circle_fill", callback = function(v)
	FOVCircleConfig.Filled = v
end})
fovFill:colorpicker({name = "Fill Color", flag = "hood_fov_circle_fill_color", color = Color3.fromRGB(255,255,255), callback = function(col, a)
	FOVCircleConfig.FillColor = col
end})
secFOV:slider({name = "Fill Transparency", flag = "hood_fov_circle_fill_transparency", min = 0, max = 1, default = 0.85, interval = 0.01, callback = function(v)
	FOVCircleConfig.FillTransparency = v
end})

local fovOutline = secFOV:toggle({name = "Outline", flag = "hood_fov_circle_outline", callback = function(v)
	FOVCircleConfig.Outline = v
end})
fovOutline:colorpicker({name = "Outline Color", flag = "hood_fov_circle_outline_color", color = Color3.fromRGB(0,0,0), callback = function(col, a)
	FOVCircleConfig.OutlineColor = col
end})
secFOV:slider({name = "Outline Thickness", flag = "hood_fov_circle_outline_thickness", min = 1, max = 15, default = 3, interval = 1, callback = function(v)
	FOVCircleConfig.OutlineThickness = v
end})
secFOV:slider({name = "Outline Transparency", flag = "hood_fov_circle_outline_transparency", min = 0, max = 1, default = 0.5, interval = 0.01, callback = function(v)
	FOVCircleConfig.OutlineTransparency = v
end})

local col2 = Combat:column()

local secIndicators = col2:section({name = "Target Indicators", toggle = false})

secIndicators:toggle({name = "Highlight", flag = "hood_highlight_enabled", callback = function(v)
	Targeting.HighlightEnabled = v
	if not v and Targeting.Highlight then
		UpdateHighlight(nil)
	elseif v and (Targeting.Target or AutoKill.Target) then
		UpdateHighlight(Targeting.Target or AutoKill.Target)
	end
end})

local hlFill = secIndicators:toggle({name = "Highlight Fill", flag = "hood_highlight_fill"})
hlFill:colorpicker({name = "Fill Color", flag = "hood_highlight_fill_color", color = Color3.fromRGB(27, 206, 203), callback = function()
	if Targeting.Target or AutoKill.Target then UpdateHighlight(Targeting.Target or AutoKill.Target) end
end})
secIndicators:slider({name = "Fill Transparency", flag = "hood_highlight_fill_transparency", min = 0, max = 1, default = 0, interval = 0.01, callback = function()
	if Targeting.Target or AutoKill.Target then UpdateHighlight(Targeting.Target or AutoKill.Target) end
end})

local hlOutline = secIndicators:toggle({name = "Highlight Outline", flag = "hood_highlight_outline"})
hlOutline:colorpicker({name = "Outline Color", flag = "hood_highlight_outline_color", color = Color3.new(1,1,1), callback = function()
	if Targeting.Target or AutoKill.Target then UpdateHighlight(Targeting.Target or AutoKill.Target) end
end})
secIndicators:slider({name = "Outline Transparency", flag = "hood_highlight_outline_transparency", min = 0, max = 1, default = 0, interval = 0.01, callback = function()
	if Targeting.Target or AutoKill.Target then UpdateHighlight(Targeting.Target or AutoKill.Target) end
end})

secIndicators:toggle({name = "Target Dot", flag = "hood_dot_enabled", callback = function(v)
	Targeting.DotEnabled = v
	if not v then dot.Visible = false end
end})
local dotCol = secIndicators:colorpicker({name = "Dot Color", flag = "hood_dot_color", color = Color3.fromRGB(27,206,203), callback = function(col)
	Targeting.DotColor = col
end})

secIndicators:toggle({name = "Tracer", flag = "hood_tracer_enabled", callback = function(v)
	Targeting.TracerEnabled = v
	if not v then tracer.Visible = false tracerOutline.Visible = false end
end})
local tracerCol = secIndicators:colorpicker({name = "Tracer Color", flag = "hood_tracer_color", color = Color3.fromRGB(27,206,203), callback = function(col)
	Targeting.TracerColor = col
	tracer.Color = col
end})
secIndicators:slider({name = "Tracer Thickness", flag = "hood_tracer_thickness", min = 1, max = 10, default = 2, interval = 1, callback = function(v)
	Targeting.TracerThickness = v
end})
secIndicators:slider({name = "Outline Thickness", flag = "hood_tracer_outline_thickness", min = 1, max = 15, default = 4, interval = 1, callback = function(v)
	Targeting.TracerOutlineThickness = v
end})
secIndicators:dropdown({name = "Start Position", flag = "hood_tracer_start_position", items = {"Bottom", "HumanoidRootPart", "Top", "Mouse"}, default = "Mouse", callback = function(v)
	Targeting.TracerStartPosition = v
end})

local secTargetUI = col2:section({name = "Target UI", toggle = false})
secTargetUI:toggle({name = "Target UI", flag = "hood_target_ui_enabled", callback = function(v)
	TargetUI.Enabled = v
	if v then
		TargetUI.Create()
	else
		if TargetUI.Instance then
			TargetUI.Instance:Destroy()
			TargetUI.Instance = nil
		end
	end
end})
local tuiBorder = secTargetUI:colorpicker({name = "Border Color", flag = "hood_target_ui_border_color", color = Color3.fromRGB(27,206,203), callback = function(col)
	TargetUI.BorderColor = col
end})
secTargetUI:colorpicker({name = "Glow Color", flag = "hood_target_ui_glow_color", color = Color3.fromRGB(27,206,203), callback = function(col)
	TargetUI.GlowColor = col
end})
secTargetUI:toggle({name = "Use Glow", flag = "hood_target_ui_use_glow", callback = function(v)
	TargetUI.UseGlow = v
end})
secTargetUI:dropdown({name = "Style", flag = "hood_target_ui_style", items = {"Old", "Modern"}, default = "Old", callback = function(v)
	TargetUI.Style = v
	if TargetUI.Enabled then TargetUI.Create() end
end})
secTargetUI:dropdown({name = "Position", flag = "hood_target_ui_position", items = {"Free", "Follow Target"}, default = "Free", callback = function(v)
	TargetUI.Position = v
end})

secTargetUI:colorpicker({name = "Health Start", flag = "hood_target_ui_health_start", color = Color3.fromRGB(0,255,0), callback = function(col)
	TargetUI.HealthStart = col
end})
secTargetUI:colorpicker({name = "Health Mid", flag = "hood_target_ui_health_mid", color = Color3.fromRGB(255,170,0), callback = function(col)
	TargetUI.HealthMid = col
end})
secTargetUI:colorpicker({name = "Health End", flag = "hood_target_ui_health_end", color = Color3.fromRGB(255,0,0), callback = function(col)
	TargetUI.HealthEnd = col
end})
secTargetUI:colorpicker({name = "Ammo Start", flag = "hood_target_ui_ammo_start", color = Color3.fromRGB(255,140,0), callback = function(col)
	TargetUI.AmmoStart = col
end})
secTargetUI:colorpicker({name = "Ammo Mid", flag = "hood_target_ui_ammo_mid", color = Color3.fromRGB(255,85,0), callback = function(col)
	TargetUI.AmmoMid = col
end})
secTargetUI:colorpicker({name = "Ammo End", flag = "hood_target_ui_ammo_end", color = Color3.fromRGB(255,0,0), callback = function(col)
	TargetUI.AmmoEnd = col
end})


local col3 = Combat:column()

local secAutoKill = col3:section({name = "Auto Kill", toggle = false})

secAutoKill:toggle({name = "Auto Kill", flag = "hood_autokill_enabled", callback = function(v)
	AutoKill.Enabled = v
	if not v then
		AutoKill.Target = nil
		AutoKill.StopCycle()
	elseif AutoKill.Target or AutoKill.HasSelectedTargets() or (AutoKill.Method == "Knife" and AutoKill.KnifeAura) then
		AutoKill.StartCycle()
	end
end})

secAutoKill:dropdown({name = "Method", flag = "hood_autokill_method", items = {"Knife", "Gun"}, default = "Knife", callback = function(v)
	AutoKill.Method = v
	AutoKill.StopCycle()
	if AutoKill.Enabled and (AutoKill.Target or AutoKill.HasSelectedTargets() or (v == "Knife" and AutoKill.KnifeAura)) then
		AutoKill.StartCycle()
	end
end})

secAutoKill:toggle({name = "Knife Aura", flag = "hood_autokill_knife_aura", callback = function(v)
	AutoKill.KnifeAura = v
	AutoKill.AuraLockedTarget = nil
	if AutoKill.Enabled and AutoKill.Method == "Knife" then
		AutoKill.StopCycle()
		AutoKill.AdvanceTarget()
		AutoKill.StartCycle()
	end
end})

secAutoKill:dropdown({name = "Attach Position", flag = "hood_autokill_attach_position", items = {"Inside", "Behind", "Left", "Right", "Below", "Random"}, default = "Behind", callback = function(v)
	AutoKill.AttachPosition = v
end})

secAutoKill:textbox({name = "Manual Targets (comma names)", flag = "hood_autokill_targets", default = "", callback = function(v)
	AutoKill.StopCycle()
	local selected = {}
	if type(v) == "string" and v ~= "" then
		for name in v:gmatch("([^,]+)") do
			name = name:match("^%s*(.-)%s*$")
			if name ~= "" then
				table.insert(selected, name)
			end
		end
	end
	AutoKill.SetTargetList(selected)
	Notify("Auto Kill", #selected .. " target(s) selected", 2)
	if AutoKill.Enabled and AutoKill.Target then
		AutoKill.StartCycle()
	end
end})

local akPlatformToggle = secAutoKill:toggle({name = "Custom Platform", flag = "hood_autokill_custom_platform"})
akPlatformToggle:colorpicker({name = "Platform Color", flag = "hood_autokill_platform_color", color = Color3.fromRGB(255,0,255), callback = function(col)
	AutoKill.GunMethod.PlatformColor = col
	if AutoKill.GunMethod.PlatformPart then
		AutoKill.GunMethod.PlatformPart.Color = col
	end
end})

secAutoKill:dropdown({name = "Platform Material", flag = "hood_autokill_platform_material", items = {"Neon", "ForceField", "Glass", "SmoothPlastic", "Wood", "Metal", "Foil", "Granite", "Marble", "Fabric"}, default = "Neon", callback = function(v)
	AutoKill.GunMethod.PlatformMaterial = Enum.Material[v]
	if AutoKill.GunMethod.PlatformPart then
		AutoKill.GunMethod.PlatformPart.Material = Enum.Material[v]
	end
end})

local secKnife = col3:section({name = "Knife Hitbox", toggle = false})

secKnife:toggle({name = "Enabled", flag = "hood_knife_hitbox_enabled", callback = function(v)
	AutoKill.KnifeExpander.Enabled = v
end})

secKnife:slider({name = "Size", flag = "hood_knife_hitbox_size", min = 5, max = 200, default = 20, interval = 1, suffix = "", callback = function(v)
	AutoKill.KnifeExpander.Size = v
end})

local kfToggle = secKnife:toggle({name = "Fill", flag = "hood_knife_hitbox_fill", callback = function(v)
	AutoKill.KnifeExpander.Fill = v
end})
kfToggle:colorpicker({name = "Fill Color", flag = "hood_knife_hitbox_fill_color", color = Color3.fromRGB(255,0,0), callback = function(col)
	AutoKill.KnifeExpander.FillColor = col
end})
secKnife:slider({name = "Fill Transparency", flag = "hood_knife_hitbox_fill_transparency", min = 0, max = 1, default = 0.5, interval = 0.01, callback = function(v)
	AutoKill.KnifeExpander.FillTransparency = v
end})

local koToggle = secKnife:toggle({name = "Outline", flag = "hood_knife_hitbox_outline", callback = function(v)
	AutoKill.KnifeExpander.Outline = v
end})
koToggle:colorpicker({name = "Outline Color", flag = "hood_knife_hitbox_outline_color", color = Color3.fromRGB(255,0,0), callback = function(col)
	AutoKill.KnifeExpander.OutlineColor = col
end})
secKnife:slider({name = "Outline Transparency", flag = "hood_knife_hitbox_outline_transparency", min = 0, max = 1, default = 0.5, interval = 0.01, callback = function(v)
	AutoKill.KnifeExpander.OutlineTransparency = v
end})

local col4 = Combat:column()

local secAntiAim = col4:section({name = "Anti-Aim", toggle = false})

secAntiAim:toggle({name = "Desync", flag = "hood_desync_enabled", callback = function(v)
	desync.toggleEnabled = v
	if not v then
		toggleDesync(false)
	end
end}):keybind({name = "Desync Key", flag = "hood_desync_key", callback = function(active)
	if not desync.toggleEnabled or UserInputService:GetFocusedTextBox() then return end
	if active and not desync.enabled then
		toggleDesync(true)
	elseif not active and desync.enabled then
		toggleDesync(false)
	end
end})

secAntiAim:dropdown({name = "Desync Method", flag = "hood_desync_method", items = {"Destroy Cheaters", "Rotation", "Custom", "Underground", "Void Spam", "Raining", "Teleport Maze", "Void", "UnderGroundV2", "Anti Connection v1"}, default = "Void", callback = function(v)
	desync.mode = v
end})

secAntiAim:slider({name = "Custom Pos X", flag = "hood_desync_x", min = -30, max = 30, default = 10, interval = 1, callback = function(v)
	Offsetposx = v
end})
secAntiAim:slider({name = "Custom Pos Y", flag = "hood_desync_y", min = -30, max = 30, default = 10, interval = 1, callback = function(v)
	OffsetposY = v
end})
secAntiAim:slider({name = "Custom Pos Z", flag = "hood_desync_z", min = -30, max = 30, default = 10, interval = 1, callback = function(v)
	Offsetposz = v
end})

secAntiAim:toggle({name = "Walkable Desync", flag = "hood_walkable_desync_enabled", callback = function(v)
	toggleWalkableDesync(v)
end}):keybind({name = "Walkable Key", flag = "hood_walkable_desync_key", callback = function(active)
	if active and not WalkableEnabled then
		toggleWalkableDesync(true)
	elseif not active and WalkableEnabled then
		toggleWalkableDesync(false)
	end
end})

secAntiAim:slider({name = "Desync Delay", flag = "hood_walkable_delay", min = 100, max = 2000, default = 800, interval = 1, suffix = " ms", callback = function(v)
	WalkableDelay = v
end})
secAntiAim:slider({name = "Desync Interval", flag = "hood_walkable_interval", min = 1, max = 20, default = 6, interval = 1, callback = function(v)
	WalkableInterval = v
end})

secAntiAim:toggle({name = "Godmode", flag = "hood_godmode_enabled", callback = function(v)
	toggleGodmode(v)
end}):keybind({name = "Godmode Key", flag = "hood_godmode_key", callback = function(active)
	if not getgenv().AnimGodmode then return end
	local current = getgenv().AnimGodmode.IsEnabled()
	if active and not current then
		toggleGodmode(true)
	elseif not active and current then
		toggleGodmode(false)
	end
end})

local secStrafe = col4:section({name = "Target Strafe", toggle = false})

secStrafe:toggle({name = "Target Strafe", flag = "hood_target_strafe_enabled", callback = function(v)
	TargetStrafeConfig.Enabled = v
	if not v then
		if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
		disableStrafeHook()
	end
end}):keybind({name = "Strafe Key", flag = "hood_target_strafe_key", callback = function(active)
	if active and not TargetStrafeConfig.Enabled then
		TargetStrafeConfig.Enabled = true
	elseif not active and TargetStrafeConfig.Enabled then
		TargetStrafeConfig.Enabled = false
		if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
		disableStrafeHook()
	end
end})

secStrafe:dropdown({name = "Strafe Type", flag = "hood_strafe_type", items = {"Strafe", "Roll", "Tween", "Random"}, default = "Strafe", callback = function(v)
	TargetStrafeConfig.Type = v
end})
secStrafe:slider({name = "Speed", flag = "hood_strafe_speed", min = 1, max = 50, default = 5, interval = 1, callback = function(v)
	TargetStrafeConfig.Speed = v
end})
secStrafe:slider({name = "Height", flag = "hood_strafe_height", min = -20, max = 20, default = 0, interval = 1, callback = function(v)
	TargetStrafeConfig.Height = v
end})
secStrafe:slider({name = "Distance", flag = "hood_strafe_distance", min = 1, max = 50, default = 8, interval = 1, callback = function(v)
	TargetStrafeConfig.Distance = v
end})
secStrafe:slider({name = "Random Range", flag = "hood_strafe_random_range", min = 1, max = 50, default = 10, interval = 1, callback = function(v)
	TargetStrafeConfig.RandomRange = v
end})

local visBody = secStrafe:toggle({name = "Visualize Body", flag = "hood_strafe_visualize", callback = function(v)
	TargetStrafeConfig.Visualize = v
	if not v then
		if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
	end
end})
visBody:colorpicker({name = "Body Color", flag = "hood_strafe_body_color", color = Color3.fromRGB(127,13,195), callback = function(col)
	TargetStrafeConfig.BodyColor = col
	if bodyClone then
		for _, part in pairs(bodyClone:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Color = col
			end
		end
	end
end})

secStrafe:toggle({name = "Indicator", flag = "hood_strafe_indicator", callback = function(v)
	TargetStrafeConfig.Indicator = v
	if not v then indicatorCircle.Visible = false end
end})
secStrafe:colorpicker({name = "Indicator Color", flag = "hood_strafe_indicator_color", color = Color3.fromRGB(193,247,255), callback = function(col)
	TargetStrafeConfig.IndicatorColor = col
end})

local secHitsound = col4:section({name = "Hitsounds", toggle = false})

secHitsound:toggle({name = "Enable Hitsounds", flag = "hood_hitsound_enabled", callback = function(v)
	HitsoundConfig.Enabled = v
end})

local hitsoundItems = {}
for soundName, _ in pairs(hitsounds) do
	table.insert(hitsoundItems, soundName)
end
table.sort(hitsoundItems)

secHitsound:dropdown({name = "Sound", flag = "hood_hitsound_sound", items = hitsoundItems, default = "Default", callback = function(v)
	HitsoundConfig.SelectedSound = v
end})

secHitsound:slider({name = "Volume", flag = "hood_hitsound_volume", min = 0, max = 10, default = 5, interval = 1, callback = function(v)
	HitsoundConfig.Volume = v / 5
end})

secHitsound:button_holder({})
secHitsound:button({text = "Test Sound", callback = function()
	local soundId = hitsounds[HitsoundConfig.SelectedSound] or hitsounds["Default"]
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = HitsoundConfig.Volume
	sound.Parent = SoundService
	sound:Play()
	task.spawn(function()
		task.wait(5)
		if sound and sound.Parent then sound:Destroy() end
	end)
end})
end


end
-- === END COMBAT ===

	-- Visuals
		local esp;
		local function update_elements() if esp and esp.refresh_elements then esp.refresh_elements() end end 
		local column = Visuals:column()
		local section = column:section({name = "ESP", toggle = false})
		section:toggle({name = "Enabled", flag = "Enabled", callback = update_elements})
		section:toggle({name = "Local Player", flag = "Local_Player", callback = update_elements})
		section:toggle({name = "Names", flag = "Names", callback = update_elements}):colorpicker({flag = "Name_Color", callback = update_elements})
		local settings = section:toggle({name = "Boxes", flag = "Boxes", callback = update_elements})
		section:dropdown({name = "Box Type", flag = "Box_Type", items = {"Corner", "Full"}, default = "Corner", callback = update_elements})
		settings:colorpicker({name = "Box Color", flag = "Box_Color", callback = update_elements})
		local toggle = section:toggle({name = "Healthbar", flag = "Healthbar", callback = update_elements})
		toggle:colorpicker({name = "High HP Color", flag = "Health_High", callback = update_elements})
		toggle:colorpicker({name = "Low HP Color", flag = "Health_Low", callback = update_elements})
		section:toggle({name = "Distance", flag = "Distance", callback = update_elements})
		:colorpicker({name = "Distance Color", flag = "Distance_Color", callback = update_elements})
		section:toggle({name = "Weapon", flag = "Weapon", callback = update_elements})
		:colorpicker({name = "Weapon Color", flag = "Weapon_Color", callback = update_elements})
		local glow = section:toggle({name = "Glow", flag = "Glow", callback = update_elements})
		glow:colorpicker({name = "Glow Color", flag = "Glow_Color", callback = update_elements})
		local fill = section:toggle({name = "Fill", flag = "Fill", callback = update_elements})
		fill:colorpicker({name = "Fill Color", flag = "Fill_Color", callback = update_elements})
		section:slider({name = "Fill Transparency", flag = "Fill_Transparency", min = 0, max = 1, default = 0.7, interval = 0.01, callback = update_elements})
		local imgFill = section:toggle({name = "Image Fill", flag = "Image_Fill", callback = update_elements})
		imgFill:colorpicker({name = "Image Color", flag = "Image_Fill_Color", callback = update_elements})
		section:textbox({name = "Image URL", flag = "Image_Fill_URL", default = "rbxassetid://110204605000367", callback = update_elements})
		section:slider({name = "Image Transparency", flag = "Image_Fill_Transparency", min = 0, max = 1, default = 0.5, interval = 0.01, callback = update_elements})
		local skel = section:toggle({name = "Skeletons", flag = "Skeletons", callback = update_elements})
		skel:colorpicker({name = "Skeleton Color", flag = "Skeleton_Color", callback = update_elements})
		section:slider({name = "Skeleton Thickness", flag = "Skeleton_Thickness", min = 1, max = 5, default = 1, interval = 0.5, callback = update_elements})
		section:slider({name = "Skeleton Transparency", flag = "Skeleton_Transparency", min = 0, max = 1, default = 0, interval = 0.01, callback = update_elements})
		local headDot = section:toggle({name = "Head Dot", flag = "HeadDot", callback = update_elements})
		headDot:colorpicker({name = "Head Dot Color", flag = "HeadDot_Color", callback = update_elements})
		section:slider({name = "Head Dot Transparency", flag = "HeadDot_Transparency", min = 0, max = 1, default = 0, interval = 0.01, callback = update_elements})
		section:slider({name = "Head Dot Thickness", flag = "HeadDot_Thickness", min = 1, max = 5, default = 1, interval = 0.5, callback = update_elements})
		local chams = section:toggle({name = "Chams", flag = "Chams", callback = update_elements})
		chams:colorpicker({name = "Chams Color", flag = "Chams_Color", callback = update_elements})
		section:dropdown({name = "Chams Material", flag = "Chams_Material", items = {"ForceField", "Neon"}, default = "ForceField", callback = update_elements})
		section:slider({name = "Chams Transparency", flag = "Chams_Transparency", min = 0, max = 1, default = 0.5, interval = 0.01, callback = update_elements})
		section:slider({name = "Max Distance", flag = "Max_Distance", min = 0, max = 10000, default = 10000, interval = 100, suffix = " studs", callback = update_elements})
		esp = window.esp_section:esp_preview({})
		task.defer(function() if esp and esp.refresh_elements then esp.refresh_elements() end end)
		
		local worldColumn = Visuals:column()
		local worldSection = worldColumn:section({name = "World", toggle = false})

			-- Real in-game ESP

			local Players = game:GetService("Players")
			local RunService = game:GetService("RunService")
			local Workspace = game:GetService("Workspace")
			local Camera = Workspace.CurrentCamera
			local LocalPlayer = Players.LocalPlayer
			local espFlags = library.flags
			
			local espObjects = {}
			local espErrors = {}
			
			local espGlowGui = Instance.new("ScreenGui")
			espGlowGui.Name = ""
			espGlowGui.Enabled = true
			espGlowGui.ResetOnSpawn = false
			espGlowGui.DisplayOrder = -1
			espGlowGui.IgnoreGuiInset = true
			pcall(function()
				espGlowGui.ScreenInsets = Enum.ScreenInsets.None
			end)
			pcall(function()
				espGlowGui.Parent = gethui()
			end)
			if not espGlowGui.Parent then
				espGlowGui.Parent = game:GetService("CoreGui")
			end
			
			local function getBoundingBox(character)
				local ok, cf, size = pcall(function()
					return character:GetBoundingBox()
				end)
				if not ok or not cf then return nil end
			
				local half = size / 2
				local corners = {
					cf * CFrame.new( half.X,  half.Y,  half.Z),
					cf * CFrame.new( half.X,  half.Y, -half.Z),
					cf * CFrame.new( half.X, -half.Y,  half.Z),
					cf * CFrame.new( half.X, -half.Y, -half.Z),
					cf * CFrame.new(-half.X,  half.Y,  half.Z),
					cf * CFrame.new(-half.X,  half.Y, -half.Z),
					cf * CFrame.new(-half.X, -half.Y,  half.Z),
					cf * CFrame.new(-half.X, -half.Y, -half.Z),
				}
			
				local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
				local anyOnScreen = false
				for _, cornerCFrame in ipairs(corners) do
					local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(cornerCFrame.Position)
					if onScreen then
						anyOnScreen = true
					end
					minX = math.min(minX, pos.X)
					minY = math.min(minY, pos.Y)
					maxX = math.max(maxX, pos.X)
					maxY = math.max(maxY, pos.Y)
				end
			
				if not anyOnScreen then return nil end
				return {x = minX, y = minY, w = maxX - minX, h = maxY - minY}
			end
			
			local function createEsp(player)
				local drawings = {
					boxOutline = Drawing.new("Square"),
					box = Drawing.new("Square"),
					fillBox = Drawing.new("Square"),
					name = Drawing.new("Text"),
					distance = Drawing.new("Text"),
					weapon = Drawing.new("Text"),
					healthBarBg = Drawing.new("Square"),
					healthBar = Drawing.new("Square"),
					cornerLines = {},
					cornerOutlines = {},
					skeletonLines = {},
				}
			
				drawings.imageFillLabel = Instance.new("ImageLabel")
				drawings.imageFillLabel.Name = ""
				drawings.imageFillLabel.BackgroundTransparency = 1
				drawings.imageFillLabel.Image = ""
				drawings.imageFillLabel.ImageColor3 = Color3.new(1, 1, 1)
				drawings.imageFillLabel.ImageTransparency = 0.5
				drawings.imageFillLabel.ScaleType = Enum.ScaleType.Stretch
				drawings.imageFillLabel.ZIndex = 3
				drawings.imageFillLabel.Visible = false
				drawings.imageFillLabel.Position = UDim2.new(0, 0, 0, 0)
				drawings.imageFillLabel.Size = UDim2.new(0, 0, 0, 0)
				drawings.imageFillLabel.Parent = espGlowGui
				drawings.imageUrl = ""
			
				drawings.glowLabel = Instance.new("ImageLabel")
				drawings.glowLabel.Name = ""
				drawings.glowLabel.Image = "rbxassetid://110204605000367"
				drawings.glowLabel.ScaleType = Enum.ScaleType.Slice
				drawings.glowLabel.SliceCenter = Rect.new(21, 21, 79, 79)
				drawings.glowLabel.ImageColor3 = Color3.new(1, 1, 1)
				drawings.glowLabel.ImageTransparency = 0.65
				drawings.glowLabel.BackgroundTransparency = 1
				drawings.glowLabel.BorderSizePixel = 0
				drawings.glowLabel.Position = UDim2.new(0, 0, 0, 0)
				drawings.glowLabel.Size = UDim2.new(0, 0, 0, 0)
				drawings.glowLabel.Visible = false
				drawings.glowLabel.Parent = espGlowGui
			
				local glowGradient = Instance.new("UIGradient")
				glowGradient.Rotation = 90
				glowGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
				glowGradient.Transparency = NumberSequence.new(0)
				glowGradient.Parent = drawings.glowLabel
			
				local glowPadding = Instance.new("UIPadding")
				glowPadding.PaddingTop = UDim.new(0, 21)
				glowPadding.PaddingBottom = UDim.new(0, 20)
				glowPadding.PaddingLeft = UDim.new(0, 21)
				glowPadding.PaddingRight = UDim.new(0, 20)
				glowPadding.Parent = drawings.glowLabel
			
				for i = 1, 8 do
					local outline = Drawing.new("Line")
					outline.Thickness = 5
					outline.Color = Color3.new(0, 0, 0)
					outline.Visible = false
					outline.ZIndex = 4
					drawings.cornerOutlines[i] = outline
			
					local line = Drawing.new("Line")
					line.Thickness = 3
					line.Visible = false
					line.ZIndex = 5
					drawings.cornerLines[i] = line
				end
			
				for i = 1, 15 do
					local line = Drawing.new("Line")
					line.Thickness = 1
					line.Visible = false
					drawings.skeletonLines[i] = line
				end
			
				drawings.headDot = Drawing.new("Circle")
					drawings.headDot.Radius = 4
					drawings.headDot.Filled = false
					drawings.headDot.NumSides = 12
					drawings.headDot.Visible = false
		
				drawings.chamsHighlight = nil
					drawings.chamsAppliedTo = nil
		
				drawings.boxOutline.Thickness = 1
				drawings.boxOutline.Filled = false
				drawings.boxOutline.Visible = false
			
				drawings.box.Thickness = 1
				drawings.box.Filled = false
				drawings.box.Visible = false
			
				drawings.fillBox.Filled = true
				drawings.fillBox.Visible = false
				drawings.fillBox.Transparency = 0.3
				drawings.fillBox.ZIndex = 2
			
				for _, label in ipairs({drawings.name, drawings.distance, drawings.weapon}) do
					label.Size = 12
					label.Center = true
					label.Outline = true
					label.Visible = false
				end
			
				drawings.healthBarBg.Filled = true
				drawings.healthBarBg.Visible = false
				drawings.healthBar.Filled = true
				drawings.healthBar.Visible = false
			
				espObjects[player] = drawings
			end
			
			local function removeEsp(player)
				local drawings = espObjects[player]
				if not drawings then return end
				if drawings.chamsHighlight then
					drawings.chamsHighlight:Destroy()
					drawings.chamsHighlight = nil
				end
				drawings.chamsAppliedTo = nil
				for _, d in pairs(drawings) do
					if typeof(d) == "table" then
						for _, dd in ipairs(d) do
							pcall(function() dd:Remove() end)
						end
					elseif typeof(d) ~= "string" and typeof(d) ~= "boolean" and typeof(d) ~= "number" and d then
						if typeof(d) == "Instance" then
							if d.Parent then
								d:Destroy()
							end
						else
							pcall(function() d:Remove() end)
						end
					end
				end
				espObjects[player] = nil
			end
			
			local function getColor(flag)
				local data = espFlags[flag]
				if type(data) == "table" and data.Color then
					return data.Color
				end
				return Color3.new(1, 1, 1)
			end
			
			local function updateGlow(drawings, x, y, w, h, color, visible)
				if not visible or not drawings.glowLabel then
					if drawings.glowLabel then
						drawings.glowLabel.Visible = false
					end
					return
				end
				local pad = 21
				drawings.glowLabel.Position = UDim2.new(0, x - pad, 0, y - pad)
				drawings.glowLabel.Size = UDim2.new(0, w + pad * 2, 0, h + pad * 2)
				drawings.glowLabel.ImageColor3 = color
				drawings.glowLabel.Visible = true
			end
			
			local function updateFill(drawings, x, y, w, h, color, visible)
				if not visible then
					drawings.fillBox.Visible = false
					return
				end
				drawings.fillBox.Size = Vector2.new(w, h)
				drawings.fillBox.Position = Vector2.new(x, y)
				drawings.fillBox.Color = color
				drawings.fillBox.Transparency = espFlags["Fill_Transparency"] or 0.3
				drawings.fillBox.Visible = true
			end
			
			local function updateImageFill(drawings, x, y, w, h, visible)
				if not visible or not drawings.imageFillLabel then
					if drawings.imageFillLabel then
						drawings.imageFillLabel.Visible = false
					end
					return
				end
				local url = espFlags["Image_Fill_URL"] or ""
				if url ~= drawings.imageUrl then
					drawings.imageUrl = url
					drawings.imageFillLabel.Image = url
				end
				drawings.imageFillLabel.ImageColor3 = getColor("Image_Fill_Color")
				drawings.imageFillLabel.ImageTransparency = espFlags["Image_Fill_Transparency"] or 0.5
				drawings.imageFillLabel.Position = UDim2.new(0, x, 0, y)
				drawings.imageFillLabel.Size = UDim2.new(0, w, 0, h)
				drawings.imageFillLabel.Visible = true
			end
			
			local function updateCornerBox(drawings, x, y, w, h, color, visible)
				local function setLines(lines)
					if not visible then
						for _, line in ipairs(lines) do
							line.Visible = false
						end
						return
					end
					local hLen = math.min(w * 0.4, w * 0.5)
					local vLen = math.min(h * 0.25, h * 0.5)
					lines[1].From = Vector2.new(x, y); lines[1].To = Vector2.new(x + hLen, y)
					lines[2].From = Vector2.new(x, y); lines[2].To = Vector2.new(x, y + vLen)
					lines[3].From = Vector2.new(x + w, y); lines[3].To = Vector2.new(x + w - hLen, y)
					lines[4].From = Vector2.new(x + w, y); lines[4].To = Vector2.new(x + w, y + vLen)
					lines[5].From = Vector2.new(x, y + h); lines[5].To = Vector2.new(x + hLen, y + h)
					lines[6].From = Vector2.new(x, y + h); lines[6].To = Vector2.new(x, y + h - vLen)
					lines[7].From = Vector2.new(x + w, y + h); lines[7].To = Vector2.new(x + w - hLen, y + h)
					lines[8].From = Vector2.new(x + w, y + h); lines[8].To = Vector2.new(x + w, y + h - vLen)
					for _, line in ipairs(lines) do
						line.Visible = true
					end
				end
				setLines(drawings.cornerOutlines)
				setLines(drawings.cornerLines)
				if visible then
					for _, line in ipairs(drawings.cornerLines) do
						line.Color = color
					end
				end
			end
			
			local skeletonMap = {
				{first = {"Head"}, second = {"UpperTorso", "Torso"}},
				{first = {"UpperTorso", "Torso"}, second = {"LowerTorso"}},
				{first = {"UpperTorso", "Torso"}, second = {"LeftUpperArm", "Left Arm"}},
				{first = {"LeftUpperArm", "Left Arm"}, second = {"LeftLowerArm"}},
				{first = {"LeftLowerArm"}, second = {"LeftHand"}},
				{first = {"UpperTorso", "Torso"}, second = {"RightUpperArm", "Right Arm"}},
				{first = {"RightUpperArm", "Right Arm"}, second = {"RightLowerArm"}},
				{first = {"RightLowerArm"}, second = {"RightHand"}},
				{first = {"LowerTorso", "Torso"}, second = {"LeftUpperLeg", "Left Leg"}},
				{first = {"LeftUpperLeg", "Left Leg"}, second = {"LeftLowerLeg"}},
				{first = {"LeftLowerLeg"}, second = {"LeftFoot"}},
				{first = {"LowerTorso", "Torso"}, second = {"RightUpperLeg", "Right Leg"}},
				{first = {"RightUpperLeg", "Right Leg"}, second = {"RightLowerLeg"}},
				{first = {"RightLowerLeg"}, second = {"RightFoot"}},
			}
			
			local function findPart(character, ...)
				for _, name in ipairs({...}) do
					local part = character:FindFirstChild(name)
					if part then return part end
				end
				return nil
			end
			
			local function updateSkeleton(drawings, character, color, visible)
				if not visible then
					for _, line in ipairs(drawings.skeletonLines) do
						line.Visible = false
					end
					return
				end
				for i, pair in ipairs(skeletonMap) do
					local first = findPart(character, unpack(pair.first))
					local second = findPart(character, unpack(pair.second))
					local line = drawings.skeletonLines[i]
					if first and second then
						local p1, on1 = Workspace.CurrentCamera:WorldToViewportPoint(first.Position)
						local p2, on2 = Workspace.CurrentCamera:WorldToViewportPoint(second.Position)
						if on1 and on2 then
							line.From = Vector2.new(p1.X, p1.Y)
							line.To = Vector2.new(p2.X, p2.Y)
							line.Color = color
							line.Thickness = espFlags["Skeleton_Thickness"] or 1
							line.Transparency = espFlags["Skeleton_Transparency"] or 0
							line.Visible = true
						else
							line.Visible = false
						end
					else
						line.Visible = false
					end
				end
end
			
			local function updateHeadDot(drawings, character, color, visible)
				if not visible then
					drawings.headDot.Visible = false
					return
				end
				local head = character:FindFirstChild("Head")
				if not head then
					drawings.headDot.Visible = false
					return
				end
				local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
				if onScreen then
					drawings.headDot.Position = Vector2.new(pos.X, pos.Y)
					drawings.headDot.Thickness = espFlags["HeadDot_Thickness"] or 1
					drawings.headDot.Transparency = espFlags["HeadDot_Transparency"] or 0
					drawings.headDot.Color = color
					drawings.headDot.Visible = true
				else
					drawings.headDot.Visible = false
				end
			end

			local function ensureBloom()
				local Lighting = game:GetService("Lighting")
				for _, effect in pairs(Lighting:GetChildren()) do
					if effect:IsA("BloomEffect") and effect.Name == "NeonBloom" then
						return
					end
				end
				local bloom = Instance.new("BloomEffect")
				bloom.Name = "NeonBloom"
				bloom.Intensity = 1.5
				bloom.Size = 24
				bloom.Threshold = 0.85
				bloom.Parent = Lighting
			end
			pcall(ensureBloom)

			local function removeHairAndAccessories(character)
				local hair = character:FindFirstChild("Hair")
				if hair and hair:IsA("BasePart") then
					hair:Destroy()
				end
			end

			local function removeClothing(character)
				local shirt = character:FindFirstChild("Shirt")
				if shirt then shirt:Destroy() end
				local pants = character:FindFirstChild("Pants")
				if pants then pants:Destroy() end
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					for _, clothing in pairs(humanoid:GetChildren()) do
						if clothing:IsA("Clothing") then
							clothing:Destroy()
						end
					end
				end
				for _, part in pairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						for _, decal in pairs(part:GetChildren()) do
							if decal:IsA("Decal") or decal:IsA("Texture") then
								decal:Destroy()
							end
						end
					end
				end
			end

			local function applyCustomHead(character, color, material)
				local head = character:FindFirstChild("Head")
				if not head or not head:IsA("BasePart") then return end
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					local face = humanoid:FindFirstChild("Face")
					if face then face:Destroy() end
				end
				for _, child in pairs(head:GetChildren()) do
					if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
						child:Destroy()
					elseif child:IsA("SpecialMesh") or child:IsA("FileMesh") then
						child.TextureId = ""
					end
				end
				if head:IsA("MeshPart") then
					head.TextureID = ""
				end
				head.Material = material
				head.Color = color
				head.CastShadow = false
			end

			local function makePartCham(part, color, material)
				if not part or not part:IsA("BasePart") then return end
				if part.Name == "HumanoidRootPart" then return end
				part.Material = material
				part.Color = color
				part.CastShadow = false
				if part:IsA("MeshPart") then
					part.TextureID = ""
				end
				for _, child in pairs(part:GetChildren()) do
					if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
						child:Destroy()
					elseif child:IsA("SpecialMesh") or child:IsA("FileMesh") then
						child.TextureId = ""
					end
				end
			end

			local function applyChamsEffects(character, color, material)
				if not character then return end
				removeHairAndAccessories(character)
				removeClothing(character)
				pcall(function() applyCustomHead(character, color, material) end)
				for _, part in pairs(character:GetDescendants()) do
					makePartCham(part, color, material)
				end
			end

			local function clearChams(drawings)
				if drawings.chamsHighlight then
					drawings.chamsHighlight:Destroy()
					drawings.chamsHighlight = nil
					drawings.chamsAppliedTo = nil
					drawings.chamsLastApply = 0
				end
			end

			local function updateChams(drawings, character, color, visible, material)
				if not visible then
					if drawings.chamsHighlight then
						drawings.chamsHighlight.Enabled = false
					end
					return
				end
				if not drawings.chamsHighlight then
					drawings.chamsHighlight = Instance.new("Highlight")
					drawings.chamsHighlight.Name = ""
					drawings.chamsHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					drawings.chamsHighlight.Parent = espGlowGui
				end
				local transparency = espFlags["Chams_Transparency"] or 0
				drawings.chamsHighlight.Adornee = character
				drawings.chamsHighlight.FillColor = color
				drawings.chamsHighlight.OutlineColor = color
				drawings.chamsHighlight.FillTransparency = transparency
				drawings.chamsHighlight.OutlineTransparency = 0.1
				drawings.chamsHighlight.Enabled = true
				local mat = Enum.Material[material] or Enum.Material.Neon
				local now = tick()
				if drawings.chamsAppliedTo ~= character or (now - drawings.chamsLastApply) >= 1 then
					drawings.chamsAppliedTo = character
					drawings.chamsLastApply = now
					pcall(function() applyChamsEffects(character, color, mat) end)
				end
			end

			local function updateEsp(player)
				local drawings = espObjects[player]
				if not drawings then return end
			
				local function hideAll()
					for _, d in pairs(drawings) do
						if typeof(d) == "table" then
							for _, dd in ipairs(d) do
								pcall(function() dd.Visible = false end)
							end
						elseif typeof(d) ~= "string" and typeof(d) ~= "boolean" and d then
							pcall(function() d.Visible = false end)
						end
					end
					if drawings.chamsHighlight then
						drawings.chamsHighlight.Enabled = false
					end
				end
			
				if not espFlags["Enabled"] then
					hideAll()
					return
				end
			
				local character = player.Character
				local localCharacter = LocalPlayer.Character
				if not character or not localCharacter then
					hideAll()
					return
				end
			
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local localHrp = localCharacter:FindFirstChild("HumanoidRootPart")
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if not humanoid or not hrp or not localHrp then
					hideAll()
					return
				end

				if player == LocalPlayer and not espFlags["Local_Player"] then
					hideAll()
					return
				end

				local maxDistance = espFlags["Max_Distance"] or 10000
				if (hrp.Position - localHrp.Position).Magnitude > maxDistance then
					hideAll()
					return
				end
			
				if humanoid.Health <= 0 then
					hideAll()
					return
				end
			
				local bb = getBoundingBox(character)
				if not bb then
					hideAll()
					return
				end
			
				local x, y, w, h = bb.x, bb.y, bb.w, bb.h
				local boxColor = getColor("Box_Color")
				local isCorner = espFlags["Box_Type"] == "Corner"
			
				updateGlow(drawings, x, y, w, h, getColor("Glow_Color"), espFlags["Glow"])
				updateFill(drawings, x, y, w, h, getColor("Fill_Color"), espFlags["Fill"])
				updateImageFill(drawings, x, y, w, h, espFlags["Image_Fill"])
			
				if espFlags["Boxes"] then
					if isCorner then
						updateCornerBox(drawings, x, y, w, h, boxColor, true)
						drawings.boxOutline.Visible = false
						drawings.box.Visible = false
					else
						updateCornerBox(drawings, x, y, w, h, boxColor, false)
						drawings.boxOutline.Visible = true
						drawings.boxOutline.Size = Vector2.new(w + 2, h + 2)
						drawings.boxOutline.Position = Vector2.new(x - 1, y - 1)
						drawings.boxOutline.Color = Color3.new(0, 0, 0)
			
						drawings.box.Visible = true
						drawings.box.Size = Vector2.new(w, h)
						drawings.box.Position = Vector2.new(x, y)
						drawings.box.Color = boxColor
					end
				else
					updateCornerBox(drawings, x, y, w, h, boxColor, false)
					drawings.boxOutline.Visible = false
					drawings.box.Visible = false
				end
			
				if espFlags["Names"] then
					drawings.name.Visible = true
					drawings.name.Text = player.Name
					drawings.name.Position = Vector2.new(x + w / 2, y - 15)
					drawings.name.Color = getColor("Name_Color")
				else
					drawings.name.Visible = false
				end
			
				if espFlags["Distance"] then
					local dist = math.floor((hrp.Position - localHrp.Position).Magnitude)
					drawings.distance.Visible = true
					drawings.distance.Text = tostring(dist) .. " studs"
					drawings.distance.Position = Vector2.new(x + w / 2, y + h + 3)
					drawings.distance.Color = getColor("Distance_Color")
				else
					drawings.distance.Visible = false
				end
			
				if espFlags["Weapon"] then
					local tool = character:FindFirstChildOfClass("Tool")
					drawings.weapon.Visible = true
					drawings.weapon.Text = tool and tool.Name or "None"
					drawings.weapon.Position = Vector2.new(x + w / 2, y + h + (espFlags["Distance"] and 16 or 3))
					drawings.weapon.Color = getColor("Weapon_Color")
				else
					drawings.weapon.Visible = false
				end
			
				if espFlags["Healthbar"] then
					local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					local barW = 3
					drawings.healthBarBg.Visible = true
					drawings.healthBarBg.Size = Vector2.new(barW, h)
					drawings.healthBarBg.Position = Vector2.new(x - 7, y)
					drawings.healthBarBg.Color = Color3.new(0, 0, 0)
			
					drawings.healthBar.Visible = true
					drawings.healthBar.Size = Vector2.new(barW, h * hp)
					drawings.healthBar.Position = Vector2.new(x - 7, y + h * (1 - hp))
					local high = getColor("Health_High")
					local low = getColor("Health_Low")
					drawings.healthBar.Color = high:Lerp(low, 1 - hp)
				else
					drawings.healthBarBg.Visible = false
					drawings.healthBar.Visible = false
				end
			
				updateSkeleton(drawings, character, getColor("Skeleton_Color"), espFlags["Skeletons"])
				updateHeadDot(drawings, character, getColor("HeadDot_Color"), espFlags["HeadDot"])
				updateChams(drawings, character, getColor("Chams_Color"), espFlags["Chams"], espFlags["Chams_Material"] or "ForceField")
			end
			
			local function safeCreateEsp(player)
				local ok, err = pcall(createEsp, player)
				if not ok then
					warn("ESP create error for " .. tostring(player) .. ": " .. tostring(err))
				end
			end

			Players.PlayerAdded:Connect(safeCreateEsp)
			Players.PlayerRemoving:Connect(removeEsp)
			for _, player in ipairs(Players:GetPlayers()) do
				safeCreateEsp(player)
			end
			
			RunService.RenderStepped:Connect(function()
				local menuOpen = window.opened
				espGlowGui.Enabled = not menuOpen
				if menuOpen then
					for _, drawings in pairs(espObjects) do
						for _, d in pairs(drawings) do
							if typeof(d) == "table" then
								for _, dd in ipairs(d) do
									pcall(function() dd.Visible = false end)
								end
							elseif typeof(d) ~= "string" and typeof(d) ~= "boolean" and d then
								pcall(function() d.Visible = false end)
							end
						end
					end
					return
				end
				for player, _ in pairs(espObjects) do
					local ok, err = pcall(updateEsp, player)
					if not ok and not espErrors[player] then
						espErrors[player] = true
						warn("ESP error for " .. tostring(player) .. ": " .. tostring(err))
					end
				end
			end)
	-- 

	-- Soft Aim / Aimbot
		do
			local Players = game:GetService("Players")
			local RunService = game:GetService("RunService")
			local Workspace = game:GetService("Workspace")
			local Camera = Workspace.CurrentCamera
			local LocalPlayer = Players.LocalPlayer

			local function isKeyActive(bindFlag)
				local bind = library.flags[bindFlag]
				if not bind then return false end
				if bind.mode == "always" then return true end
				return bind.active == true
			end

			local function getAimBone(character)
				local boneName = library.flags["silent_aim_bone"] or "Head"
				return character:FindFirstChild(boneName)
			end

			local function isTeammate(player)
				if player == LocalPlayer then return true end
				if not LocalPlayer.Team or not player.Team then return false end
				return LocalPlayer.Team == player.Team
			end

			local function isVisible(targetPart)
				local origin = Camera.CFrame.Position
				local direction = targetPart.Position - origin
				local params = RaycastParams.new()
				params.FilterDescendantsInstances = {LocalPlayer.Character}
				params.FilterType = Enum.RaycastFilterType.Blacklist
				local result = Workspace:Raycast(origin, direction, params)
				if not result then return true end
				return result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
			end

			local function getTarget()
				local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
				local fov = library.flags["silent_aim_fov"] or 150
				local maxDist = library.flags["silent_aim_distance"] or 500
				local teamCheck = library.flags["silent_aim_teamcheck"]
				local visCheck = library.flags["silent_aim_visiblecheck"]
				local localChar = LocalPlayer.Character
				local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

				local closestBone, closestDist = nil, math.huge
				for _, player in ipairs(Players:GetPlayers()) do
					if player == LocalPlayer then continue end
					local character = player.Character
					if not character then continue end
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					local hrp = character:FindFirstChild("HumanoidRootPart")
					if not humanoid or not hrp then continue end
					if humanoid.Health <= 0 then continue end
					if teamCheck and isTeammate(player) then continue end

					local bone = getAimBone(character)
					if not bone or not bone:IsA("BasePart") then continue end

					if localHrp then
						local dist = (hrp.Position - localHrp.Position).Magnitude
						if dist > maxDist then continue end
					end

					if visCheck and not isVisible(bone) then continue end

					local pos, onScreen = Camera:WorldToViewportPoint(bone.Position)
					if not onScreen then continue end
					local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if screenDist <= fov and screenDist < closestDist then
						closestBone = bone
						closestDist = screenDist
					end
				end
				return closestBone
			end

			local function aimAt(bone)
				if not bone then return end
				local smooth = library.flags["silent_aim_smooth"] or 15
				local factor = math.clamp(smooth / 100, 0.01, 1)
				local targetCFrame = CFrame.new(Camera.CFrame.Position, bone.Position)
				Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, factor)
			end

			local lastAutoShoot = 0
			local function autoShoot()
				if not library.flags["auto_shoot"] then return end
				local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
				if not tool then return end
				local now = tick()
				if now - lastAutoShoot < 0.08 then return end
				lastAutoShoot = now
				pcall(function() tool:Activate() end)
			end

			RunService.RenderStepped:Connect(function()
				if not library.flags["silent_aim"] then return end
				if not isKeyActive("silent_aim_bind") then return end
				local target = getTarget()
				if target then
					aimAt(target)
					autoShoot()
				end
			end)
		end

	Aiming.open_tab() 
-- 

-- Initialisation stuff
library:config_list_update()

for index, value in themes.preset do 
	pcall(function()
		library:update_theme(index, value)
	end)
end

task.wait()

library.old_config = library:get_config()