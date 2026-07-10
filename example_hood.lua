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

	-- === MISC UI (ported from evolution_hood.lua) ===
	do
		getgenv().HoodMisc = getgenv().HoodMisc or {}
		local HM = getgenv().HoodMisc
		HM.UpdateEmote = HM.UpdateEmote or function() end
		HM.UpdateAnimatedTools = HM.UpdateAnimatedTools or function() end
		HM.RefreshSkins = HM.RefreshSkins or function() end
		HM.ApplyBeamColors = HM.ApplyBeamColors or function() end
		HM.ApplyShootSounds = HM.ApplyShootSounds or function() end
		HM.StartStand = HM.StartStand or function() end
		HM.StopStand = HM.StopStand or function() end
		HM.StopEmote = HM.StopEmote or function() end

		local miscColumn1 = Misc:column()
		local movement = miscColumn1:section({name = "Movement"})
		movement:toggle({name = "CFrame Speed", flag = "hood_misc_cframe_speed_enabled"})
			:keybind({name = "CFrame Speed Bind", flag = "hood_misc_cframe_speed_bind"})
		movement:slider({name = "CFrame Speed", flag = "hood_misc_cframe_speed", min = 1, max = 200, default = 10, interval = 1})
		movement:toggle({name = "Jump Power", flag = "hood_misc_jump_power_enabled"})
		movement:slider({name = "Jump Power", flag = "hood_misc_jump_power", min = 50, max = 500, default = 50, interval = 1})
		movement:toggle({name = "Flight", flag = "hood_misc_flight_enabled"})
			:keybind({name = "Flight Bind", flag = "hood_misc_flight_bind"})
		movement:slider({name = "Fly Speed", flag = "hood_misc_fly_speed", min = 10, max = 5000, default = 50, interval = 1})
		movement:toggle({name = "Spin Bot", flag = "hood_misc_spin_bot_enabled"})
		movement:slider({name = "Spin Speed", flag = "hood_misc_spin_bot_speed", min = 1, max = 100, default = 50, interval = 1})
		movement:toggle({name = "Infinite Jump", flag = "hood_misc_infinite_jump_enabled"})

		local cosmetics = miscColumn1:section({name = "Cosmetics"})
		local skins, shoot = cosmetics:multi_section({names = {"Skins", "Shoot Sounds"}})

		local allGunSkinNames = {"None", "Candy Cane", "Gingerbread", "Snowflake", "Ghost", "Ascension", "Nightmare", "Kirumi", "Void Dragon", "Hell Hound", "Lovestruck", "Adurite", "Hallows", "Heartbringer", "Arctic", "Lightbringer", "Deathbringer", "Hell Dragon", "Kitty", "Shiryus Breath", "Poseidon", "Amethyst", "Arsenic", "Volcanic Ashes", "Floral", "Binary", "Voxel", "Hello Kitty", "Radiation", "Void", "Hexagram", "Strawberry Shortcake", "Black Ice", "Crimson Fangs", "Green Tint", "Ember", "Cupid", "Beta"}
		local knifeSkinNames = {"None", "Beta", "Bitcoin", "Fishbone", "Nightblade"}
		local beamOptions = {"Red", "Blue", "Green", "Orange", "Lightning", "Beta", "Hallows", "Kitty", "Kirumi", "Rainbow"}
		local soundOptions = {"Mp40", "G36C", "M249", "Sniper", "Fortnite Pump", "DoubleBarrel"}

		skins:toggle({name = "Skin Changer", flag = "hood_misc_skin_changer_enabled", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "Revolver Skin", flag = "hood_misc_revolver_skin", items = allGunSkinNames, default = "Candy Cane", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "Double Barrel Skin", flag = "hood_misc_doublebarrel_skin", items = allGunSkinNames, default = "Candy Cane", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "Shotgun Skin", flag = "hood_misc_shotgun_skin", items = allGunSkinNames, default = "Ascension", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "Tactical Shotgun Skin", flag = "hood_misc_tactical_shotgun_skin", items = allGunSkinNames, default = "Ascension", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "SMG Skin", flag = "hood_misc_smg_skin", items = allGunSkinNames, default = "Candy Cane", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "Knife Skin", flag = "hood_misc_knife_skin", items = knifeSkinNames, default = "Fishbone", callback = function(v) HM.RefreshSkins() end})
		skins:dropdown({name = "Beam", flag = "hood_misc_beam", items = beamOptions, default = "Green", callback = function(v) HM.ApplyBeamColors() end})

		shoot:toggle({name = "Shoot Sounds", flag = "hood_misc_shoot_sounds_enabled", callback = function(v) HM.ApplyShootSounds() end})
		shoot:slider({name = "Volume", flag = "hood_misc_shoot_sounds_volume", min = 0, max = 100, default = 50, interval = 1})
		shoot:dropdown({name = "Double Barrel", flag = "hood_misc_shootsound_doublebarrel", items = soundOptions, default = "Mp40", callback = function(v) HM.ApplyShootSounds() end})
		shoot:dropdown({name = "Revolver", flag = "hood_misc_shootsound_revolver", items = soundOptions, default = "Mp40", callback = function(v) HM.ApplyShootSounds() end})
		shoot:dropdown({name = "SMG", flag = "hood_misc_shootsound_smg", items = soundOptions, default = "Mp40", callback = function(v) HM.ApplyShootSounds() end})
		shoot:dropdown({name = "Shotgun", flag = "hood_misc_shootsound_shotgun", items = soundOptions, default = "Mp40", callback = function(v) HM.ApplyShootSounds() end})
		shoot:dropdown({name = "Silencer", flag = "hood_misc_shootsound_silencer", items = soundOptions, default = "Mp40", callback = function(v) HM.ApplyShootSounds() end})
		shoot:dropdown({name = "Tactical Shotgun", flag = "hood_misc_shootsound_tacticalshotgun", items = soundOptions, default = "Mp40", callback = function(v) HM.ApplyShootSounds() end})

		local animation = miscColumn1:section({name = "Animation Player"})
		animation:toggle({name = "Play Emote", flag = "hood_misc_animation_enabled", callback = function(v) HM.UpdateEmote() end})
		animation:toggle({name = "Loop", flag = "hood_misc_animation_loop", callback = function(v) HM.UpdateEmote() end})
		local emoteAnimations = {"Ice Spice", "Crip Walk", "Slow-Mo BackFlip", "Shuffle", "Coffin", "Cat", "Happier Jump", "Bouncy Twirl", "V Pose", "Moonwalk", "Silly Dance", "Shuffling", "Hula Dance", "Gangnam Style", "Macarena"}
		animation:dropdown({name = "Emote", flag = "hood_misc_animation_emote", items = emoteAnimations, default = "Ice Spice", callback = function(v) HM.UpdateEmote() end})
		animation:slider({name = "Speed", flag = "hood_misc_animation_speed", min = 0.1, max = 3, default = 1, interval = 0.1, callback = function(v) HM.UpdateEmote() end})
		animation:textbox({name = "Custom Animation ID", flag = "hood_misc_animation_custom_id", placeholder = "rbxassetid://... or just numbers", callback = function(v) HM.UpdateEmote() end})
		animation:button({name = "Stop Emote", callback = function() HM.StopEmote() end})

		local animatedTools = miscColumn1:section({name = "Animated Tools"})
		local animModes = {"character spin", "sine spin", "random", "jitter", "spin"}
		animatedTools:toggle({name = "Animated Tools", flag = "hood_misc_animated_tools_enabled", callback = function(v) HM.UpdateAnimatedTools() end})
		animatedTools:dropdown({name = "Horizontal", flag = "hood_misc_animated_tools_horizontal", items = animModes, default = "sine spin", callback = function(v) HM.UpdateAnimatedTools() end})
		animatedTools:slider({name = "Horizontal Speed", flag = "hood_misc_animated_tools_horizontal_speed", min = 0, max = 100, default = 10, interval = 1})
		animatedTools:dropdown({name = "Vertical", flag = "hood_misc_animated_tools_vertical", items = animModes, default = "sine spin", callback = function(v) HM.UpdateAnimatedTools() end})
		animatedTools:slider({name = "Vertical Speed", flag = "hood_misc_animated_tools_vertical_speed", min = 0, max = 100, default = 10, interval = 1})

		local miscColumn2 = Misc:column()
		local food = miscColumn2:section({name = "Food"})
		food:toggle({name = "Auto Buy Food", flag = "hood_misc_auto_buy_food"})
		food:toggle({name = "Auto Eat", flag = "hood_misc_auto_eat"})
		food:slider({name = "Eat Below %", flag = "hood_misc_eat_health", min = 1, max = 100, default = 50, interval = 1})
		food:dropdown({name = "Food Items", flag = "hood_misc_food_items", items = {"[Burger]", "[Taco]", "[Pizza]", "[Chicken]", "[Candy Basket]"}, multi = true, default = {"[Burger]", "[Taco]"}})

		local other = miscColumn2:section({name = "Other"})
		other:toggle({name = "Auto Reload", flag = "hood_misc_auto_reload"})
		other:toggle({name = "Force Reset", flag = "hood_misc_force_reset"})
		other:toggle({name = "Chat Spy", flag = "hood_misc_chat_spy"})

		local usestand = miscColumn2:section({name = "Use Stand"})
		usestand:toggle({name = "Use Stand", flag = "hood_misc_usestand_enabled", callback = function(v) if v then HM.StartStand() else HM.StopStand() end end})
		usestand:textbox({name = "Owner / Main Account", flag = "hood_misc_usestand_owner", placeholder = "Username"})
		usestand:textbox({name = "Whitelist (comma names)", flag = "hood_misc_usestand_whitelist", placeholder = "name1,name2"})
		usestand:label({name = "Commands:"})
		usestand:label({name = ".godmode - toggle anim godmode"})
		usestand:label({name = ".ak <user> - auto kill target"})
		usestand:label({name = ".method knife / .method gun"})
		usestand:label({name = ".formation follow/circle/surround"})
		usestand:label({name = ".knifeaura - circle owner & stab near"})
		usestand:label({name = ".killaura - circle owner & DB closest"})
		usestand:label({name = ".orbit - spin around owner"})
		usestand:label({name = ".stands name1,name2 - stand list"})
		usestand:label({name = ".whitelist name1,name2 - never target"})
		usestand:label({name = ".unwhitelist name1,name2"})
		usestand:label({name = ".vanish - hide on void platform"})
		usestand:label({name = ".unvanish - leave void platform"})
		usestand:label({name = ".bring <user> - bring player to owner"})
		usestand:label({name = ".stop - stop auto kill / aura"})
	end

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


local desync = {
	enabled = false,
	mode = "Void",
	teleportPosition = Vector3.new(0, 0, 0),
	old_position = nil,
	voidSpamActive = false,
	toggleEnabled = false,
	Offsetposx = 10,
	OffsetposY = 10,
	Offsetposz = 10,
	WalkableEnabled = false,
	WalkableDelay = 800,
	WalkableInterval = 6
}

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

local bodyClone
local indicatorCircle = Drawing.new("Circle")
indicatorCircle.Visible = false
indicatorCircle.Radius = 20
indicatorCircle.Thickness = 2
indicatorCircle.Filled = false
indicatorCircle.NumSides = 32

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

local function resetCamera()
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end

desync.toggleDesync = function(state)
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
				desync.teleportPosition = rootPart.Position - Vector3.new(desync.Offsetposx, desync.OffsetposY, desync.Offsetposz)
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
local VProEn = true

function DesyncWalkable()
	task.spawn(function()
		while desync.WalkableEnabled do
			task.wait()
			if LocalPlayer.Character then
				local loop = RunService.Heartbeat:Connect(function()
					pcall(function()
						sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", true)
					end)
					task.wait(desync.WalkableDelay / 100000)
					pcall(function()
						sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", false)
					end)
				end)
				task.wait(desync.WalkableInterval / 100)
				if loop then loop:Disconnect() end
			end
		end
	end)
end

desync.toggleWalkableDesync = function(v)
	desync.WalkableEnabled = v
	if desync.WalkableEnabled then
		DesyncWalkable()
		Notify("Notification", "Walkable Desync: Enabled", 3)
	else
		Notify("Notification", "Walkable Desync: Disabled", 3)
	end
end

desync.toggleGodmode = function(v)
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

local Radians = 0
local saved_desync = nil
local hook_active = false
local old_index_strafe = nil

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
TargetStrafeConfig.disableStrafeHook = disableStrafeHook

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
				local damage = oldHealth - newHealth
				PlayHitsound()
				if getgenv().FlashHitVignette then getgenv().FlashHitVignette() end
				if getgenv().HitChams then getgenv().HitChams(target) end
				if getgenv().HitEffects then getgenv().HitEffects(target) end
				if getgenv().HitLogs then getgenv().HitLogs(target, damage) end
				local hitPos = nil
				if target.Character then
					local head = target.Character:FindFirstChild("Head")
					local torso = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso") or target.Character:FindFirstChild("HumanoidRootPart")
					local part = head and head:IsA("BasePart") and head or torso
					if part then
						local center = part.Position
						if part == torso then
							center = center + Vector3.new(0, part.Size.Y * 0.4, 0)
						end
						local function horizontalRight(p)
							local look = p.CFrame.LookVector
							local flat = Vector3.new(look.X, 0, look.Z)
							if flat.Magnitude < 0.001 then
								flat = Vector3.new(0, 0, 1)
							else
								flat = flat.Unit
							end
							return CFrame.lookAt(p.Position, p.Position + flat).RightVector
						end
						local right = horizontalRight(part)
						local w = math.max(part.Size.X, part.Size.Z) * 0.5
						local h = part.Size.Y * 0.35
						local spots = {
							center,
							center + right * w,
							center - right * w,
							center + Vector3.new(0, h, 0)
						}
						local jitter = Vector3.new(math.random() * 0.5 - 0.25, math.random() * 0.5 - 0.25, math.random() * 0.5 - 0.25)
						hitPos = spots[math.random(1, #spots)] + jitter
					end
				end
				if hitPos then
					if getgenv().ShowDamageNumber then getgenv().ShowDamageNumber(target, damage, hitPos) end
					if getgenv().ShowHitmarker then getgenv().ShowHitmarker(hitPos) end
					local headPos = target.Character and target.Character:FindFirstChild("Head")
					if getgenv().Show3DHitmarker then getgenv().Show3DHitmarker(headPos and headPos:IsA("BasePart") and headPos.Position or hitPos, newHealth <= 0) end
				end
				if newHealth <= 0 and hitPos and getgenv().ShowKillMarker then getgenv().ShowKillMarker(hitPos) end
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
		desync.toggleDesync(false)
	end
end}):keybind({name = "Desync Key", flag = "hood_desync_key", callback = function(active)
	if not desync.toggleEnabled or UserInputService:GetFocusedTextBox() then return end
	if active and not desync.enabled then
		desync.toggleDesync(true)
	elseif not active and desync.enabled then
		desync.toggleDesync(false)
	end
end})

secAntiAim:dropdown({name = "Desync Method", flag = "hood_desync_method", items = {"Destroy Cheaters", "Rotation", "Custom", "Underground", "Void Spam", "Raining", "Teleport Maze", "Void", "UnderGroundV2", "Anti Connection v1"}, default = "Void", callback = function(v)
	desync.mode = v
end})

secAntiAim:slider({name = "Custom Pos X", flag = "hood_desync_x", min = -30, max = 30, default = 10, interval = 1, callback = function(v)
	desync.Offsetposx = v
end})
secAntiAim:slider({name = "Custom Pos Y", flag = "hood_desync_y", min = -30, max = 30, default = 10, interval = 1, callback = function(v)
	desync.OffsetposY = v
end})
secAntiAim:slider({name = "Custom Pos Z", flag = "hood_desync_z", min = -30, max = 30, default = 10, interval = 1, callback = function(v)
	desync.Offsetposz = v
end})

secAntiAim:toggle({name = "Walkable Desync", flag = "hood_walkable_desync_enabled", callback = function(v)
	desync.toggleWalkableDesync(v)
end}):keybind({name = "Walkable Key", flag = "hood_walkable_desync_key", callback = function(active)
	if active and not desync.WalkableEnabled then
		desync.toggleWalkableDesync(true)
	elseif not active and desync.WalkableEnabled then
		desync.toggleWalkableDesync(false)
	end
end})

secAntiAim:slider({name = "Desync Delay", flag = "hood_walkable_delay", min = 100, max = 2000, default = 800, interval = 1, suffix = " ms", callback = function(v)
	desync.WalkableDelay = v
end})
secAntiAim:slider({name = "Desync Interval", flag = "hood_walkable_interval", min = 1, max = 20, default = 6, interval = 1, callback = function(v)
	desync.WalkableInterval = v
end})

secAntiAim:toggle({name = "Godmode", flag = "hood_godmode_enabled", callback = function(v)
	desync.toggleGodmode(v)
end}):keybind({name = "Godmode Key", flag = "hood_godmode_key", callback = function(active)
	if not getgenv().AnimGodmode then return end
	local current = getgenv().AnimGodmode.IsEnabled()
	if active and not current then
		desync.toggleGodmode(true)
	elseif not active and current then
		desync.toggleGodmode(false)
	end
end})

local secStrafe = col4:section({name = "Target Strafe", toggle = false})

secStrafe:toggle({name = "Target Strafe", flag = "hood_target_strafe_enabled", callback = function(v)
	TargetStrafeConfig.Enabled = v
	if not v then
		if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
		TargetStrafeConfig.disableStrafeHook()
	end
end}):keybind({name = "Strafe Key", flag = "hood_target_strafe_key", callback = function(active)
	if active and not TargetStrafeConfig.Enabled then
		TargetStrafeConfig.Enabled = true
	elseif not active and TargetStrafeConfig.Enabled then
		TargetStrafeConfig.Enabled = false
		if bodyClone then bodyClone:SetPrimaryPartCFrame(CFrame.new(9999,9999,9999)) end
		TargetStrafeConfig.disableStrafeHook()
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
		local worldSection, weatherSection = worldColumn:multi_section({names = {"World", "Weather"}})
		
		worldSection:toggle({name = "Custom Fog", flag = "hood_visuals_fog_enabled", callback = function() end})
		:colorpicker({name = "Fog Color", flag = "hood_visuals_fog_color", color = Color3.fromRGB(192, 192, 192)})
		worldSection:slider({name = "Fog Start", flag = "hood_visuals_fog_start", min = 0, max = 10000, default = 0, interval = 1, suffix = ""})
		worldSection:slider({name = "Fog End", flag = "hood_visuals_fog_end", min = 100, max = 100000, default = 100000, interval = 1, suffix = ""})
		worldSection:toggle({name = "Custom Ambient", flag = "hood_visuals_ambient_enabled", callback = function() end})
		:colorpicker({name = "Ambient Color", flag = "hood_visuals_ambient_color", color = Color3.fromRGB(70, 70, 70)})
		worldSection:toggle({name = "Custom Outdoor Ambient", flag = "hood_visuals_outdoor_ambient_enabled", callback = function() end})
		:colorpicker({name = "Outdoor Ambient", flag = "hood_visuals_outdoor_ambient_color", color = Color3.fromRGB(140, 140, 140)})
		worldSection:toggle({name = "Custom Time", flag = "hood_visuals_time_enabled", callback = function() end})
		worldSection:slider({name = "Time of Day", flag = "hood_visuals_time_of_day", min = 0, max = 24, default = 14, interval = 0.1, suffix = ""})
		worldSection:toggle({name = "Bloom", flag = "hood_visuals_bloom_enabled", callback = function() end})
		worldSection:slider({name = "Bloom Intensity", flag = "hood_visuals_bloom_intensity", min = 0, max = 5, default = 0.75, interval = 0.01, suffix = ""})
		worldSection:slider({name = "Bloom Size", flag = "hood_visuals_bloom_size", min = 1, max = 56, default = 24, interval = 1, suffix = ""})
		worldSection:slider({name = "Bloom Threshold", flag = "hood_visuals_bloom_threshold", min = 0, max = 2, default = 1, interval = 0.1, suffix = ""})
		worldSection:toggle({name = "Color Correction", flag = "hood_visuals_color_correction_enabled", callback = function() end})
		:colorpicker({name = "Tint Color", flag = "hood_visuals_cc_tint_color", color = Color3.fromRGB(255, 255, 255)})
		worldSection:slider({name = "CC Brightness", flag = "hood_visuals_cc_brightness", min = -1, max = 1, default = 0, interval = 0.01, suffix = ""})
		worldSection:slider({name = "CC Contrast", flag = "hood_visuals_cc_contrast", min = -1, max = 1, default = 0, interval = 0.01, suffix = ""})
		worldSection:slider({name = "CC Saturation", flag = "hood_visuals_cc_saturation", min = -1, max = 1, default = 0, interval = 0.01, suffix = ""})
		worldSection:toggle({name = "Skybox", flag = "hood_visuals_skybox_enabled", callback = function() end})
		worldSection:dropdown({name = "Sky", flag = "hood_visuals_skybox_choice", items = {"black storm", "blue space", "realistic", "stormy", "pink"}, default = "black storm"})
		
		weatherSection:toggle({name = "Weather", flag = "hood_visuals_weather_enabled", callback = function() end})
		:colorpicker({name = "Weather Color", flag = "hood_visuals_weather_color", color = Color3.fromRGB(255, 255, 255)})
		weatherSection:dropdown({name = "Weather Type", flag = "hood_visuals_weather_type", items = {"light rain", "rain", "snow"}, default = "rain"})
		weatherSection:slider({name = "Weather Rate", flag = "hood_visuals_weather_rate", min = 1, max = 100, default = 100, interval = 1, suffix = ""})
		weatherSection:toggle({name = "Background Noise", flag = "hood_visuals_weather_sounds_enabled", callback = function() end})
		weatherSection:dropdown({name = "Noises", flag = "hood_visuals_weather_noise", items = {"Rain 1", "Rain 2", "Light Rain", "Thunder", "windy winter", "thunderstorm", "night", "day"}, default = "Rain 1"})
		weatherSection:slider({name = "Sound Volume", flag = "hood_visuals_weather_volume", min = 0, max = 1, default = 0.5, interval = 0.01, suffix = ""})
		
		local hitColumn = worldColumn
		local hitChamsSection, hitmarkerSection = hitColumn:multi_section({names = {"Hit Chams", "3D Hitmarker"}})
		hitChamsSection:toggle({name = "Hit Chams", flag = "hood_visuals_hit_chams_enabled", callback = function() end})
		:colorpicker({name = "Hit Chams Color", flag = "hood_visuals_hit_chams_color", color = Color3.fromRGB(0, 255, 255)})
		hitChamsSection:slider({name = "Duration", flag = "hood_visuals_hit_chams_duration", min = 0.1, max = 10, default = 0.5, interval = 0.1, suffix = "s"})
		hitChamsSection:slider({name = "Transparency", flag = "hood_visuals_hit_chams_transparency", min = 0, max = 1, default = 0.3, interval = 0.1, suffix = ""})
		hitChamsSection:toggle({name = "Fade Out", flag = "hood_visuals_hit_chams_fade_out", callback = function() end})
		hitChamsSection:dropdown({name = "Material", flag = "hood_visuals_hit_chams_material", items = {"Neon", "ForceField", "Glass", "SmoothPlastic", "Metal"}, default = "Neon"})
		
		hitmarkerSection:toggle({name = "3D Hitmarker", flag = "hood_visuals_3d_hitmarker_enabled", callback = function() end})
		:colorpicker({name = "Color", flag = "hood_visuals_3d_hitmarker_color", color = Color3.fromRGB(255, 255, 255)})
		:colorpicker({name = "Outline", flag = "hood_visuals_3d_hitmarker_outline_color", color = Color3.fromRGB(0, 0, 0)})
		hitmarkerSection:colorpicker({name = "Lethal Color", flag = "hood_visuals_3d_hitmarker_lethal_color", color = Color3.fromRGB(255, 0, 0)})
		hitmarkerSection:slider({name = "Thickness", flag = "hood_visuals_3d_hitmarker_thickness", min = 1, max = 10, default = 1, interval = 1, suffix = ""})
		hitmarkerSection:slider({name = "Outline Thickness", flag = "hood_visuals_3d_hitmarker_outline_thickness", min = 1, max = 15, default = 3, interval = 1, suffix = ""})
		hitmarkerSection:slider({name = "Size", flag = "hood_visuals_3d_hitmarker_size", min = 4, max = 40, default = 10, interval = 1, suffix = ""})
		hitmarkerSection:slider({name = "Lifetime", flag = "hood_visuals_3d_hitmarker_lifetime", min = 0.1, max = 3, default = 0.5, interval = 0.1, suffix = "s"})
		
		local effectsColumn = Visuals:column()
		local hitEffectsSection, damageNumbersSection = effectsColumn:multi_section({names = {"Hit Effects", "Damage Numbers"}})
		hitEffectsSection:toggle({name = "Hit Effects", flag = "hood_visuals_hit_effects_enabled", callback = function() end})
		:colorpicker({name = "Hit Effect Color", flag = "hood_visuals_hit_effects_color", color = Color3.fromRGB(255, 255, 255)})
		hitEffectsSection:slider({name = "Effect Duration", flag = "hood_visuals_hit_effects_duration", min = 0.1, max = 3, default = 0.1, interval = 0.1, suffix = "s"})
		hitEffectsSection:dropdown({name = "Hit Effect Type", flag = "hood_visuals_hit_effects_type", items = {"Nova", "Crescent Slash", "Coom", "Cosmic Explosion", "Slash", "Atomic Slash", "Particles"}, default = "Nova"})
		hitEffectsSection:toggle({name = "Fade Out", flag = "hood_visuals_hit_effects_fade_out", callback = function() end})
		
		damageNumbersSection:toggle({name = "Damage Numbers", flag = "hood_visuals_damage_numbers_enabled", callback = function() end})
		:colorpicker({name = "Damage Number Color", flag = "hood_visuals_damage_numbers_color", color = Color3.fromRGB(255, 255, 255)})
		damageNumbersSection:dropdown({name = "Preset", flag = "hood_visuals_damage_numbers_preset", items = {"Default", "Hoodcustoms"}, default = "Default", callback = function(v)
			if getgenv().HoodVisualsApplyDamageNumberPreset then getgenv().HoodVisualsApplyDamageNumberPreset(v) end
		end})
		damageNumbersSection:toggle({name = "Use Native Template", flag = "hood_visuals_damage_numbers_use_template", callback = function() end})
		damageNumbersSection:toggle({name = "Fade Out", flag = "hood_visuals_damage_numbers_fade_out", callback = function() end})
		damageNumbersSection:toggle({name = "Fly Out", flag = "hood_visuals_damage_numbers_fly_out", callback = function() end})
		damageNumbersSection:toggle({name = "Outline", flag = "hood_visuals_damage_numbers_outline", callback = function() end})
		damageNumbersSection:slider({name = "Lifetime", flag = "hood_visuals_damage_numbers_lifetime", min = 0.2, max = 3, default = 1.1, interval = 0.1, suffix = "s"})
		
		local logsColumn = effectsColumn
		local hitLogsSection, hitVignetteSection = logsColumn:multi_section({names = {"Hit Logs", "Hit Vignette"}})
		hitLogsSection:toggle({name = "Hit Logs", flag = "hood_visuals_hit_logs_enabled", callback = function() end})
		hitLogsSection:slider({name = "Notification Time", flag = "hood_visuals_hit_logs_time", min = 1, max = 10, default = 3, interval = 1, suffix = "s"})
		
		hitVignetteSection:toggle({name = "Use", flag = "hood_visuals_hit_vignette_enabled", callback = function() end})
		:colorpicker({name = "Vignette Color", flag = "hood_visuals_hit_vignette_color", color = Color3.fromRGB(180, 0, 0)})
		hitVignetteSection:slider({name = "Strength", flag = "hood_visuals_hit_vignette_strength", min = 0.1, max = 1, default = 0.35, interval = 0.01, suffix = ""})
		hitVignetteSection:slider({name = "Lifetime", flag = "hood_visuals_hit_vignette_lifetime", min = 0.05, max = 2, default = 0.12, interval = 0.01, suffix = "s"})
		
		local tracersColumn = Visuals:column()
		local tracersSection, crosshairSection = tracersColumn:multi_section({names = {"Forcehit Tracers", "Crosshair"}})
		tracersSection:toggle({name = "Use", flag = "hood_visuals_forcehit_tracers_enabled", callback = function() end})
		:colorpicker({name = "Start Color", flag = "hood_visuals_forcehit_tracers_color", color = Color3.fromRGB(255, 50, 50)})
		:colorpicker({name = "End Color", flag = "hood_visuals_forcehit_tracers_end_color", color = Color3.fromRGB(255, 50, 50)})
		tracersSection:toggle({name = "Fade Out", flag = "hood_visuals_forcehit_tracers_fade_out", callback = function() end})
		tracersSection:toggle({name = "Use Gradient", flag = "hood_visuals_forcehit_tracers_gradient", callback = function() end})
		tracersSection:toggle({name = "Use Spread", flag = "hood_visuals_forcehit_tracers_spread", callback = function() end})
		tracersSection:slider({name = "Lifetime", flag = "hood_visuals_forcehit_tracers_lifetime", min = 0.1, max = 5, default = 0.8, interval = 0.1, suffix = "s"})
		tracersSection:dropdown({name = "Tracer Texture", flag = "hood_visuals_forcehit_tracers_texture", items = {"Default", "Hoodcustoms", "laser", "light", "flow", "Drawing"}, default = "Hoodcustoms"})
		
		crosshairSection:toggle({name = "Crosshair", flag = "hood_visuals_crosshair_enabled", callback = function() end})
		:colorpicker({name = "Crosshair Color", flag = "hood_visuals_crosshair_color", color = Color3.fromRGB(255, 255, 255)})
		crosshairSection:toggle({name = "Follow Target", flag = "hood_visuals_crosshair_follow_target", callback = function() end})
		crosshairSection:toggle({name = "Remove Default Crosshair", flag = "hood_visuals_remove_default_crosshair", callback = function() end})
		crosshairSection:slider({name = "Crosshair Size", flag = "hood_visuals_crosshair_size", min = 5, max = 30, default = 10, interval = 1, suffix = ""})
		crosshairSection:slider({name = "Crosshair Gap", flag = "hood_visuals_crosshair_gap", min = 0, max = 20, default = 5, interval = 1, suffix = ""})
		crosshairSection:slider({name = "Crosshair Thickness", flag = "hood_visuals_crosshair_thickness", min = 1, max = 8, default = 2, interval = 1, suffix = ""})
		crosshairSection:slider({name = "Outline Thickness", flag = "hood_visuals_crosshair_outline_thickness", min = 1, max = 12, default = 4, interval = 1, suffix = ""})
		crosshairSection:toggle({name = "Rotation Animation", flag = "hood_visuals_crosshair_rotation", callback = function() end})
		crosshairSection:slider({name = "Rotation Speed", flag = "hood_visuals_crosshair_rotation_speed", min = 0.1, max = 5, default = 1, interval = 0.1, suffix = ""})
		
		local clientColumn = tracersColumn
		local clientSection, gunMaterialSection = clientColumn:multi_section({names = {"Client", "Gun Material"}})
		clientSection:toggle({name = "Modify Body", flag = "hood_visuals_modify_body_enabled", callback = function(v)
			if getgenv().HoodVisualsApplyBody then getgenv().HoodVisualsApplyBody(v) end
		end})
		:colorpicker({name = "Body Color", flag = "hood_visuals_modify_body_color", color = Color3.fromRGB(57, 255, 150)})
		clientSection:dropdown({name = "Material", flag = "hood_visuals_modify_body_material", items = {"Neon", "ForceField"}, default = "Neon"})
		clientSection:toggle({name = "Korblox", flag = "hood_visuals_korblox_enabled", callback = function(v)
			if getgenv().HoodVisualsApplyKorblox then getgenv().HoodVisualsApplyKorblox(v) end
		end})
		clientSection:toggle({name = "Headless", flag = "hood_visuals_headless_enabled", callback = function(v)
			if getgenv().HoodVisualsApplyHeadless then getgenv().HoodVisualsApplyHeadless(v) end
		end})
		clientSection:toggle({name = "Particle Aura", flag = "hood_visuals_particle_aura_enabled", callback = function(v)
			if getgenv().HoodVisualsApplyParticleAura then getgenv().HoodVisualsApplyParticleAura(v) end
		end})
		:colorpicker({name = "Aura Color", flag = "hood_visuals_particle_aura_color", color = Color3.fromRGB(133, 220, 255)})
		clientSection:dropdown({name = "Aura Type", flag = "hood_visuals_particle_aura_type", items = {"starlight", "heavenly", "ribbon", "sakura", "angel", "wind", "flow", "star"}, default = "angel"})
		clientSection:toggle({name = "Avatar Morph", flag = "hood_visuals_avatar_morph_enabled", callback = function(v)
			if getgenv().HoodVisualsApplyAvatarMorph then getgenv().HoodVisualsApplyAvatarMorph(v) end
		end})
		clientSection:textbox({name = "ID / Username", flag = "hood_visuals_avatar_morph_user", default = "5042596195", callback = function(v)
			if getgenv().HoodVisualsSetAvatarMorphUser then getgenv().HoodVisualsSetAvatarMorphUser(v) end
		end})
		clientSection:toggle({name = "Add Accessories", flag = "hood_visuals_avatar_morph_add_enabled", callback = function(v)
			if getgenv().HoodVisualsSetAddAccessory then getgenv().HoodVisualsSetAddAccessory(v) end
		end})
		clientSection:textbox({name = "Accessory ID", flag = "hood_visuals_avatar_morph_accessory_id", default = "", callback = function(v)
			if getgenv().HoodVisualsAddAccessory then getgenv().HoodVisualsAddAccessory(v) end
		end})
		local avatarMorphAccessoriesDropdown = clientSection:dropdown({name = "Current Accessories", flag = "hood_visuals_avatar_morph_accessories", items = {" "}, default = " ", callback = function(v)
			if not v or v == " " then return end
			local character = LocalPlayer.Character
			if not character then return end
			local accessory = character:FindFirstChild(v)
			if accessory and accessory:IsA("Accessory") then
				accessory:Destroy()
				if getgenv().HoodVisualsRefreshAvatarMorphDropdown then getgenv().HoodVisualsRefreshAvatarMorphDropdown(character) end
			end
		end})
		getgenv().HoodAvatarMorphAccessoriesDropdown = avatarMorphAccessoriesDropdown
		
		gunMaterialSection:toggle({name = "Gun Material", flag = "hood_visuals_gun_material_enabled", callback = function(v)
			if getgenv().HoodVisualsUpdateGunMaterial then getgenv().HoodVisualsUpdateGunMaterial() end
		end})
		:colorpicker({name = "Gun Color", flag = "hood_visuals_gun_material_color", color = Color3.fromRGB(255, 0, 0)})
		gunMaterialSection:dropdown({name = "Material Type", flag = "hood_visuals_gun_material_type", items = {"Neon", "ForceField"}, default = "Neon"})
		
		local miscColumn = Visuals:column()
		local aspectSection, motionBlurSection = miscColumn:multi_section({names = {"Aspect Ratio", "Motion Blur"}})
		aspectSection:toggle({name = "Modify", flag = "hood_visuals_aspect_ratio_enabled", callback = function() end})
		aspectSection:slider({name = "X Axis", flag = "hood_visuals_aspect_ratio_x", min = 0.1, max = 1.22, default = 1.0, interval = 0.01, suffix = ""})
		aspectSection:slider({name = "Y Axis", flag = "hood_visuals_aspect_ratio_y", min = 0.1, max = 1.3, default = 1.0, interval = 0.01, suffix = ""})
		aspectSection:slider({name = "Z Axis", flag = "hood_visuals_aspect_ratio_z", min = 0.1, max = 1.34, default = 1.0, interval = 0.01, suffix = ""})
		
		motionBlurSection:toggle({name = "Motion Blur", flag = "hood_visuals_motion_blur_enabled", callback = function() end})
		motionBlurSection:slider({name = "Strength", flag = "hood_visuals_motion_blur_strength", min = 0, max = 64, default = 12, interval = 1, suffix = ""})
		motionBlurSection:slider({name = "Speed Threshold", flag = "hood_visuals_motion_blur_threshold", min = 0, max = 200, default = 30, interval = 1, suffix = ""})


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

-- ============================================
-- PORTED VISUAL FEATURES LOGIC
-- ============================================

do
	local UserInputService = game:GetService("UserInputService")
	local lastShotTime = 0
	local damageWindow = 1.0
	getgenv().hood_visuals_last_shot_time = lastShotTime

	local function onPlayerShoot()
		lastShotTime = tick()
		getgenv().hood_visuals_last_shot_time = lastShotTime
	end
	getgenv().hood_visuals_on_player_shoot = onPlayerShoot

	local function setupShootDetection()
		local function handleCharacterTools(character)
			character.ChildAdded:Connect(function(child)
				if child:IsA("Tool") then
					child.Activated:Connect(onPlayerShoot)
				end
			end)
			for _, child in pairs(character:GetChildren()) do
				if child:IsA("Tool") then
					child.Activated:Connect(onPlayerShoot)
				end
			end
		end
		if LocalPlayer.Character then
			handleCharacterTools(LocalPlayer.Character)
		end
		LocalPlayer.CharacterAdded:Connect(handleCharacterTools)
	end
	setupShootDetection()
end

-- 3D Hitmarker
do
	local lastD3HitmarkerTime = {}
	local function Show3DHitmarker(worldPos, isLethal)
		local enabled = library.flags["hood_visuals_3d_hitmarker_enabled"]
		if not enabled or not worldPos then return end
		local currentTime = tick()
		if lastD3HitmarkerTime[1] and (currentTime - lastD3HitmarkerTime[1]) < 0.05 then return end
		lastD3HitmarkerTime[1] = currentTime
		local cam = Camera
		local size = library.flags["hood_visuals_3d_hitmarker_size"] or 10
		local thickness = library.flags["hood_visuals_3d_hitmarker_thickness"] or 1
		local outlineThickness = library.flags["hood_visuals_3d_hitmarker_outline_thickness"] or (thickness + 2)
		local lethalColor = library.flags["hood_visuals_3d_hitmarker_lethal_color"] and library.flags["hood_visuals_3d_hitmarker_lethal_color"].Color or Color3.fromRGB(255, 0, 0)
		local normalColor = library.flags["hood_visuals_3d_hitmarker_color"] and library.flags["hood_visuals_3d_hitmarker_color"].Color or Color3.fromRGB(255, 255, 255)
		local color = isLethal and lethalColor or normalColor
		local outlineColor = library.flags["hood_visuals_3d_hitmarker_outline_color"] and library.flags["hood_visuals_3d_hitmarker_outline_color"].Color or Color3.fromRGB(0, 0, 0)
		local lifetime = library.flags["hood_visuals_3d_hitmarker_lifetime"] or 0.5
		local lines = {}
		local outlines = {}
		for i = 1, 4 do
			lines[i] = Drawing.new("Line")
			lines[i].Thickness = thickness
			lines[i].Color = color
			lines[i].Transparency = 1
			lines[i].Visible = true
			outlines[i] = Drawing.new("Line")
			outlines[i].Thickness = outlineThickness
			outlines[i].Color = outlineColor
			outlines[i].Transparency = 1
			outlines[i].Visible = true
		end
		local elapsed = 0
		local conn
		conn = RunService.RenderStepped:Connect(function(dt)
			elapsed = elapsed + dt
			local pos, onScreen = cam:WorldToViewportPoint(worldPos)
			if onScreen then
				local px, py = pos.X, pos.Y
				for i = 1, 4 do
					lines[i].Visible = true
					outlines[i].Visible = true
				end
				local s = size
				lines[1].From = Vector2.new(px - s, py - s)
				lines[1].To = Vector2.new(px - s/2, py - s/2)
				lines[2].From = Vector2.new(px + s, py - s)
				lines[2].To = Vector2.new(px + s/2, py - s/2)
				lines[3].From = Vector2.new(px - s, py + s)
				lines[3].To = Vector2.new(px - s/2, py + s/2)
				lines[4].From = Vector2.new(px + s, py + s)
				lines[4].To = Vector2.new(px + s/2, py + s/2)
				for i = 1, 4 do
					local dir = lines[i].To - lines[i].From
					if dir.Magnitude > 0 then
						local offset = dir.Unit
						outlines[i].From = lines[i].From - offset
						outlines[i].To = lines[i].To + offset
					else
						outlines[i].From = lines[i].From
						outlines[i].To = lines[i].To
					end
				end
				if elapsed > lifetime then
					local fade = math.clamp((elapsed - lifetime) / 0.3, 0, 1)
					for i = 1, 4 do
						lines[i].Transparency = 1 - fade
						outlines[i].Transparency = 1 - fade
					end
					if fade >= 1 then
						conn:Disconnect()
						for i = 1, 4 do
							lines[i]:Destroy()
							outlines[i]:Destroy()
						end
					end
				end
			else
				for i = 1, 4 do
					lines[i].Visible = false
					outlines[i].Visible = false
				end
			end
		end)
	end
	getgenv().Show3DHitmarker = Show3DHitmarker
end

-- Hit Chams
do
	local lastHitChamsTime = {}
	local HitChamsFolder = Instance.new("Folder")
	HitChamsFolder.Name = "HoodHitChamsFolder"
	HitChamsFolder.Parent = Workspace
	getgenv().HoodHitChamsFolder = HitChamsFolder

	local function HitChams(Player)
		local enabled = library.flags["hood_visuals_hit_chams_enabled"]
		if not enabled then return end
		local currentTime = tick()
		if lastHitChamsTime[Player] and (currentTime - lastHitChamsTime[Player]) < 0.05 then return end
		lastHitChamsTime[Player] = currentTime
		if not (Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then return end
		Player.Character.Archivable = true
		local Cloned = Player.Character:Clone()
		Cloned.Name = "HitChams_Clone_" .. Player.Name
		local humanoid = Cloned:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid:Destroy() end
		local hrp = Cloned:FindFirstChild("HumanoidRootPart")
		if hrp then hrp:Destroy() end
		for _, tool in ipairs(Cloned:GetDescendants()) do
			if tool:IsA("Tool") or tool:IsA("HopperBin") then tool:Destroy() end
		end
		local color = library.flags["hood_visuals_hit_chams_color"] and library.flags["hood_visuals_hit_chams_color"].Color or Color3.fromRGB(0, 255, 255)
		local transparency = library.flags["hood_visuals_hit_chams_transparency"] or 0.3
		local materialName = library.flags["hood_visuals_hit_chams_material"] or "Neon"
		local material = Enum.Material[materialName] or Enum.Material.Neon
		for _, desc in ipairs(Cloned:GetDescendants()) do
			if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
				desc:Destroy()
			elseif desc:IsA("Motor6D") or desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("JointInstance") then
				desc:Destroy()
			elseif desc:IsA("BasePart") then
				desc.CanCollide = false
				desc.Anchored = true
				desc.Transparency = transparency
				desc.Material = material
				desc.Color = color
				desc.TopSurface = Enum.SurfaceType.Smooth
				desc.BottomSurface = Enum.SurfaceType.Smooth
				if desc:IsA("MeshPart") then desc.TextureID = "" end
				for _, meshChild in ipairs(desc:GetChildren()) do
					if meshChild:IsA("SpecialMesh") or meshChild:IsA("FileMesh") then
						meshChild.TextureId = ""
					end
				end
			elseif desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("SurfaceAppearance") then
				desc:Destroy()
			elseif desc:IsA("Shirt") or desc:IsA("Pants") or desc:IsA("CharacterMesh") then
				desc:Destroy()
			end
		end
		for _, item in ipairs(Cloned:GetChildren()) do
			if not (item:IsA("BasePart") or item:IsA("Accessory")) then item:Destroy() end
		end
		for _, part in ipairs(Cloned:GetDescendants()) do
			if part:IsA("BasePart") then
				local parent = part.Parent
				if parent ~= Cloned and not (parent and parent:IsA("Accessory")) then
					part:Destroy()
				end
			end
		end
		Cloned.Parent = HitChamsFolder
		local duration = library.flags["hood_visuals_hit_chams_duration"] or 0.5
		local fadeOut = library.flags["hood_visuals_hit_chams_fade_out"]
		task.delay(duration, function()
			if Cloned and Cloned.Parent then
				if fadeOut then
					for _, part in ipairs(Cloned:GetDescendants()) do
						if part:IsA("BasePart") then
							TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
						end
					end
					task.delay(0.3, function()
						if Cloned and Cloned.Parent then Cloned:Destroy() end
					end)
				else
					Cloned:Destroy()
				end
			end
		end)
	end
	getgenv().HitChams = HitChams
end

-- Hit Effects
do
	local HitEffectModule = {
		Locals = {
			Type = {
				["Nova"] = nil,
				["Crescent Slash"] = nil,
				["Coom"] = nil,
				["Cosmic Explosion"] = nil,
				["Slash"] = nil,
				["Atomic Slash"] = nil,
			},
		},
		Functions = {},
		Settings = {HitEffect = {Color = Color3.fromRGB(255, 255, 255)}}
	}
	local lastHitEffectsTime = {}

	do
		local Insane = Instance.new("Part")
		Insane.Parent = ReplicatedStorage
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "Attachment"
		Attachment.Parent = Insane
		HitEffectModule.Locals.Type["Crescent Slash"] = Attachment
		local function makeParticle(props)
			local p = Instance.new("ParticleEmitter")
			for k, v in pairs(props) do
				pcall(function() p[k] = v end)
			end
			p.Parent = Attachment
			return p
		end
		makeParticle({Name = "Glow", Lifetime = NumberRange.new(0.16, 0.16), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1421725, 0.6182796), NumberSequenceKeypoint.new(1, 1)}), Color = ColorSequence.new(Color3.fromRGB(91, 177, 252)), Speed = NumberRange.new(0, 0), Brightness = 5, Size = NumberSequence.new(9.1873131, 16.5032349), Enabled = false, ZOffset = -0.0565939, Rate = 50, Texture = "rbxassetid://8708637750"})
		makeParticle({Name = "Gradient1", Lifetime = NumberRange.new(0.3, 0.3), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.3), NumberSequenceKeypoint.new(1, 1)}), Color = ColorSequence.new(Color3.fromRGB(115, 201, 255)), Speed = NumberRange.new(0, 0), Brightness = 6, Size = NumberSequence.new(0, 11.6261358), Enabled = false, ZOffset = 0.9187313, Rate = 50, Texture = "rbxassetid://8196169974"})
		makeParticle({Name = "Shards", Lifetime = NumberRange.new(0.19, 0.7), SpreadAngle = Vector2.new(-90, 90), Color = ColorSequence.new(Color3.fromRGB(108, 184, 255)), Drag = 10, VelocitySpread = -90, Squash = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5705521, 0.4125001), NumberSequenceKeypoint.new(1, -0.9375)}), Speed = NumberRange.new(97.7530136, 146.9970093), Brightness = 4, Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.284774, 1.2389833, 0.1534118), NumberSequenceKeypoint.new(1, 0)}), Enabled = false, Acceleration = Vector3.new(0, -56.961341857910156, 0), ZOffset = 0.5705321, Rate = 50, Texture = "rbxassetid://8030734851", Rotation = NumberRange.new(90, 90), Orientation = Enum.ParticleOrientation.VelocityParallel})
		makeParticle({Name = "Specs", Lifetime = NumberRange.new(0.33, 1.4), SpreadAngle = Vector2.new(360, -1000), Color = ColorSequence.new(Color3.fromRGB(98, 174, 255)), Drag = 10, VelocitySpread = 360, Speed = NumberRange.new(36.7492523, 146.9970093), Brightness = 7, Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.200774, 2.0311937, 0.4363973), NumberSequenceKeypoint.new(1, 0)}), Enabled = false, Acceleration = Vector3.new(0, 36.74925231933594, 0), Rate = 50, Texture = "rbxassetid://8030760338", EmissionDirection = Enum.NormalId.Right})
		Insane.Parent = workspace
	end

	do
		local part = Instance.new("Part")
		part.Parent = ReplicatedStorage
		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment"
		attachment.Parent = part
		HitEffectModule.Locals.Type["Particles"] = attachment
		part.Parent = workspace
	end

	do
		local Part = Instance.new("Part")
		Part.Parent = ReplicatedStorage
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "Attachment"
		Attachment.Parent = Part
		HitEffectModule.Locals.Type["Cosmic Explosion"] = Attachment
		local function makeParticle(props)
			local p = Instance.new("ParticleEmitter")
			for k, v in pairs(props) do
				pcall(function() p[k] = v end)
			end
			p.Parent = Attachment
			return p
		end
		makeParticle({Name = "Glow", Lifetime = NumberRange.new(0.16, 0.16), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1421725, 0.6182796), NumberSequenceKeypoint.new(1, 1)}), Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Speed = NumberRange.new(0, 0), Brightness = 5, Size = NumberSequence.new(9.1873131, 16.5032349), Enabled = false, ZOffset = -0.0565939, Rate = 50, Texture = "rbxassetid://8708637750"})
		makeParticle({Name = "Effect", Lifetime = NumberRange.new(0.4, 0.7), FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4, SpreadAngle = Vector2.new(360, -360), LockedToPart = true, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1070999, 0.19375), NumberSequenceKeypoint.new(0.7761194, 0.88125), NumberSequenceKeypoint.new(1, 1)}), LightEmission = 1, Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Drag = 1, VelocitySpread = 360, Speed = NumberRange.new(0.0036749, 0.0036749), Brightness = 2.0999999, Size = NumberSequence.new(6.9680691, 9.9213123), Enabled = false, ZOffset = 0.4777403, Rate = 50, Texture = "rbxassetid://9484012464", RotSpeed = NumberRange.new(-150, -150), FlipbookMode = Enum.ParticleFlipbookMode.OneShot, Rotation = NumberRange.new(50, 50), Orientation = Enum.ParticleOrientation.VelocityPerpendicular})
		makeParticle({Name = "Gradient1", Lifetime = NumberRange.new(0.3, 0.3), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.3), NumberSequenceKeypoint.new(1, 1)}), Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Speed = NumberRange.new(0, 0), Brightness = 6, Size = NumberSequence.new(0, 11.6261358), Enabled = false, ZOffset = 0.9187313, Rate = 50, Texture = "rbxassetid://8196169974"})
		makeParticle({Name = "Shards", Lifetime = NumberRange.new(0.19, 0.7), SpreadAngle = Vector2.new(-90, 90), Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Drag = 10, VelocitySpread = -90, Squash = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5705521, 0.4125001), NumberSequenceKeypoint.new(1, -0.9375)}), Speed = NumberRange.new(97.7530136, 146.9970093), Brightness = 4, Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.284774, 1.2389833, 0.1534118), NumberSequenceKeypoint.new(1, 0)}), Enabled = false, Acceleration = Vector3.new(0, -56.961341857910156, 0), ZOffset = 0.5705321, Rate = 50, Texture = "rbxassetid://8030734851", Rotation = NumberRange.new(90, 90), Orientation = Enum.ParticleOrientation.VelocityParallel})
		makeParticle({Name = "Crescents", Lifetime = NumberRange.new(0.19, 0.38), SpreadAngle = Vector2.new(-360, 360), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1932907, 0), NumberSequenceKeypoint.new(0.778754, 0), NumberSequenceKeypoint.new(1, 1)}), LightEmission = 10, Color = ColorSequence.new(Color3.fromRGB(160, 96, 255)), VelocitySpread = -360, Speed = NumberRange.new(0.0826858, 0.0826858), Brightness = 4, Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616), NumberSequenceKeypoint.new(1, 11.477972, 1.860431)}), Enabled = false, ZOffset = 0.4542207, Rate = 50, Texture = "rbxassetid://12509373457", RotSpeed = NumberRange.new(800, 1000), Rotation = NumberRange.new(-360, 360), Orientation = Enum.ParticleOrientation.VelocityPerpendicular})
		Part.Parent = workspace
	end

	do
		local Part = Instance.new("Part")
		Part.Parent = ReplicatedStorage
		local Attachment = Instance.new("Attachment")
		Attachment.Parent = Part
		HitEffectModule.Locals.Type["Coom"] = Attachment
		local Foam = Instance.new("ParticleEmitter")
		Foam.Name = "Foam"
		Foam.LightInfluence = 0.5
		Foam.Lifetime = NumberRange.new(1, 1)
		Foam.SpreadAngle = Vector2.new(360, -360)
		Foam.VelocitySpread = 360
		Foam.Squash = NumberSequence.new(1)
		Foam.Speed = NumberRange.new(20, 20)
		Foam.Brightness = 2.5
		Foam.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.1016692, 0.6508875, 0.6508875), NumberSequenceKeypoint.new(0.6494689, 1.4201183, 0.4127519), NumberSequenceKeypoint.new(1, 0)})
		Foam.Enabled = false
		Foam.Acceleration = Vector3.new(0, -66.04029846191406, 0)
		Foam.Rate = 100
		Foam.Texture = "rbxassetid://8297030850"
		Foam.Rotation = NumberRange.new(-90, -90)
		Foam.Orientation = Enum.ParticleOrientation.VelocityParallel
		Foam.Parent = Attachment
		Part.Parent = workspace
	end

	do
		local Part = Instance.new("Part")
		Part.Parent = ReplicatedStorage
		local Attachment = Instance.new("Attachment")
		Attachment.Parent = Part
		HitEffectModule.Locals.Type["Slash"] = Attachment
		local Crescents = Instance.new("ParticleEmitter")
		Crescents.Name = "Crescents"
		Crescents.Lifetime = NumberRange.new(0.19, 0.38)
		Crescents.SpreadAngle = Vector2.new(-360, 360)
		Crescents.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1932907, 0), NumberSequenceKeypoint.new(0.778754, 0), NumberSequenceKeypoint.new(1, 1)})
		Crescents.LightEmission = 10
		Crescents.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 96, 255)), ColorSequenceKeypoint.new(0.3160622, Color3.fromRGB(160, 96, 255)), ColorSequenceKeypoint.new(0.5146805, Color3.fromRGB(154, 82, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 96, 255))})
		Crescents.VelocitySpread = -360
		Crescents.Speed = NumberRange.new(0.0826858, 0.0826858)
		Crescents.Brightness = 4
		Crescents.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616), NumberSequenceKeypoint.new(1, 11.477972, 1.860431)})
		Crescents.Enabled = false
		Crescents.ZOffset = 0.4542207
		Crescents.Rate = 50
		Crescents.Texture = "rbxassetid://12509373457"
		Crescents.RotSpeed = NumberRange.new(800, 1000)
		Crescents.Rotation = NumberRange.new(-360, 360)
		Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		Crescents.Parent = Attachment
		Part.Parent = workspace
	end

	do
		local Part = Instance.new("Part")
		Part.Parent = ReplicatedStorage
		local Attachment = Instance.new("Attachment")
		Attachment.Parent = Part
		HitEffectModule.Locals.Type["Atomic Slash"] = Attachment
		local function makeParticle(props)
			local p = Instance.new("ParticleEmitter")
			for k, v in pairs(props) do
				pcall(function() p[k] = v end)
			end
			p.Parent = Attachment
			return p
		end
		makeParticle({Name = "Crescents", Lifetime = NumberRange.new(0.19, 0.38), SpreadAngle = Vector2.new(-360, 360), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1932907, 0), NumberSequenceKeypoint.new(0.778754, 0), NumberSequenceKeypoint.new(1, 1)}), LightEmission = 10, Color = ColorSequence.new(Color3.fromRGB(160, 96, 255)), VelocitySpread = -360, Speed = NumberRange.new(0.0826858, 0.0826858), Brightness = 4, Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616), NumberSequenceKeypoint.new(1, 11.477972, 1.860431)}), Enabled = false, ZOffset = 0.4542207, Rate = 50, Texture = "rbxassetid://12509373457", RotSpeed = NumberRange.new(800, 1000), Rotation = NumberRange.new(-360, 360), Orientation = Enum.ParticleOrientation.VelocityPerpendicular})
		makeParticle({Name = "Glow", Lifetime = NumberRange.new(0.16, 0.16), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1421725, 0.6182796), NumberSequenceKeypoint.new(1, 1)}), Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Speed = NumberRange.new(0, 0), Brightness = 5, Size = NumberSequence.new(9.1873131, 16.5032349), Enabled = false, ZOffset = -0.0565939, Rate = 50, Texture = "rbxassetid://8708637750"})
		makeParticle({Name = "Effect", Lifetime = NumberRange.new(0.4, 0.7), FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4, SpreadAngle = Vector2.new(360, -360), LockedToPart = true, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1070999, 0.19375), NumberSequenceKeypoint.new(0.7761194, 0.88125), NumberSequenceKeypoint.new(1, 1)}), LightEmission = 1, Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Drag = 1, VelocitySpread = 360, Speed = NumberRange.new(0.0036749, 0.0036749), Brightness = 2.0999999, Size = NumberSequence.new(6.9680691, 9.9213123), Enabled = false, ZOffset = 0.4777403, Rate = 50, Texture = "rbxassetid://9484012464", RotSpeed = NumberRange.new(-150, -150), FlipbookMode = Enum.ParticleFlipbookMode.OneShot, Rotation = NumberRange.new(50, 50), Orientation = Enum.ParticleOrientation.VelocityPerpendicular})
		makeParticle({Name = "Gradient1", Lifetime = NumberRange.new(0.3, 0.3), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.3), NumberSequenceKeypoint.new(1, 1)}), Color = ColorSequence.new(Color3.fromRGB(173, 82, 252)), Speed = NumberRange.new(0, 0), Brightness = 6, Size = NumberSequence.new(0, 11.6261358), Enabled = false, ZOffset = 0.9187313, Rate = 50, Texture = "rbxassetid://8196169974"})
		makeParticle({Name = "Shards", Lifetime = NumberRange.new(0.19, 0.7), SpreadAngle = Vector2.new(-90, 90), Color = ColorSequence.new(Color3.fromRGB(179, 145, 253)), Drag = 10, VelocitySpread = -90, Squash = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5705521, 0.4125001), NumberSequenceKeypoint.new(1, -0.9375)}), Speed = NumberRange.new(97.7530136, 146.9970093), Brightness = 4, Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.284774, 1.2389833, 0.1534118), NumberSequenceKeypoint.new(1, 0)}), Enabled = false, Acceleration = Vector3.new(0, -56.961341857910156, 0), ZOffset = 0.5705321, Rate = 50, Texture = "rbxassetid://8030734851", Rotation = NumberRange.new(90, 90), Orientation = Enum.ParticleOrientation.VelocityParallel})
		Part.Parent = workspace
	end

	do
		local part = Instance.new("Part")
		part.Parent = ReplicatedStorage
		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment"
		attachment.Parent = part
		HitEffectModule.Locals.Type["Nova"] = attachment
		local function createParticleEmitter(acceleration)
			local emitter = Instance.new("ParticleEmitter")
			emitter.Name = "ParticleEmitter"
			emitter.Acceleration = acceleration
			emitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.495, HitEffectModule.Settings.HitEffect.Color),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			})
			emitter.Lifetime = NumberRange.new(0.5, 0.5)
			emitter.LightEmission = 1
			emitter.LockedToPart = true
			emitter.Rate = 1
			emitter.Rotation = NumberRange.new(0, 360)
			emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 10), NumberSequenceKeypoint.new(1, 1)})
			emitter.Speed = NumberRange.new(0, 0)
			emitter.Texture = "rbxassetid://1084991215"
			emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.534, 0.25), NumberSequenceKeypoint.new(1, 0.5), NumberSequenceKeypoint.new(1, 0)})
			emitter.ZOffset = 1
			emitter.Parent = attachment
			return emitter
		end
		createParticleEmitter(Vector3.new(0, 0, 1))
		local perpendicularEmitter = createParticleEmitter(Vector3.new(0, 1, -0.001))
		perpendicularEmitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		part.Parent = workspace
	end

	local function HitEffects(Player)
		local enabled = library.flags["hood_visuals_hit_effects_enabled"]
		if not enabled then return end
		local currentTime = tick()
		if lastHitEffectsTime[Player] and (currentTime - lastHitEffectsTime[Player]) < 0.05 then return end
		lastHitEffectsTime[Player] = currentTime
		if not (Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then return end
		local effectType = library.flags["hood_visuals_hit_effects_type"] or "Nova"
		local color = library.flags["hood_visuals_hit_effects_color"] and library.flags["hood_visuals_hit_effects_color"].Color or Color3.fromRGB(255, 255, 255)
		local duration = library.flags["hood_visuals_hit_effects_duration"] or 0.1
		local fadeOut = library.flags["hood_visuals_hit_effects_fade_out"]
		if effectType == "Particles" then
			local TS = game:GetService("TweenService")
			local DOT_COUNT = 20
			local folder = Instance.new("Folder", workspace)
			folder.Name = "HitDotsTemp"
			local head = Player.Character:FindFirstChild("Head")
			local spawnPos = (head and head.Position or Player.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0))
			for i = 1, DOT_COUNT do
				task.delay((i - 1) * 0.05, function()
					local p = Instance.new("Part")
					p.Shape = Enum.PartType.Ball
					local sz = math.random(5, 12) * 0.01
					p.Size = Vector3.new(sz, sz, sz)
					p.Material = Enum.Material.Neon
					p.Color = color
					p.CastShadow = false
					p.CanCollide = false
					p.Anchored = true
					p.Parent = folder
					local spread = 2.2
					p.Position = spawnPos + Vector3.new((math.random() - 0.5) * 2 * spread, 0.8 + math.random(0, 8) * 0.1, (math.random() - 0.5) * 2 * spread)
					local targetPos = p.Position + Vector3.new((math.random() - 0.5) * 2, math.random(5, 12), (math.random() - 0.5) * 2)
					local riseDuration = math.random(25, 45) * 0.1
					TS:Create(p, TweenInfo.new(riseDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
					task.delay(riseDuration * 0.4, function()
						if not p or not p.Parent then return end
						local fade = TS:Create(p, TweenInfo.new(riseDuration * 0.6, Enum.EasingStyle.Linear), {Transparency = 1})
						fade:Play()
						fade.Completed:Connect(function()
							if p and p.Parent then p:Destroy() end
						end)
					end)
				end)
			end
			task.delay(duration, function()
				if folder and folder.Parent then folder:Destroy() end
			end)
			return
		end
		local effectTemplate = HitEffectModule.Locals.Type[effectType]
		if not effectTemplate then return end
		local hrp = Player.Character.HumanoidRootPart
		local effectAttachment = effectTemplate:Clone()
		effectAttachment.Parent = hrp
		for _, emitter in pairs(effectAttachment:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = ColorSequence.new(color)
				emitter:Emit(50)
			end
		end
		task.delay(duration, function()
			if effectAttachment and effectAttachment.Parent then
				if fadeOut then
					for _, emitter in pairs(effectAttachment:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then emitter.Enabled = false end
					end
					task.delay(0.5, function()
						if effectAttachment and effectAttachment.Parent then effectAttachment:Destroy() end
					end)
				else
					effectAttachment:Destroy()
				end
			end
		end)
	end
	getgenv().HitEffects = HitEffects
end

-- Damage Numbers, Hitmarker, Killmarker
do
	local function GetIndicatorGui()
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if not pg then return nil end
		local gui = pg:FindFirstChild("HoodVisuals_Indicators")
		if not gui then
			gui = Instance.new("ScreenGui")
			gui.Name = "HoodVisuals_Indicators"
			gui.ResetOnSpawn = false
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = pg
		end
		return gui
	end

	local DamageNumberSettings = {
		Enabled = false,
		Color = Color3.fromRGB(255, 255, 255),
		OutlineColor = Color3.fromRGB(0, 0, 0),
		Preset = "Default",
		UseTemplate = true,
		FadeOut = true,
		FlyOut = true,
		Outline = true,
		SplitDigits = true,
		Lifetime = 1.1,
		FontFace = Font.new("rbxasset://fonts/families/DenkOne.json", Enum.FontWeight.Bold),
	}

	local function ApplyDamageNumberPreset(name)
		if name == "Hoodcustoms" then
			DamageNumberSettings.Color = Color3.fromRGB(255, 255, 255)
			DamageNumberSettings.OutlineColor = Color3.fromRGB(0, 0, 0)
			DamageNumberSettings.UseTemplate = true
			DamageNumberSettings.FadeOut = true
			DamageNumberSettings.FlyOut = true
			DamageNumberSettings.Outline = true
			DamageNumberSettings.SplitDigits = true
			DamageNumberSettings.Lifetime = 1.1
			DamageNumberSettings.FontFace = Font.new("rbxasset://fonts/families/DenkOne.json", Enum.FontWeight.Bold)
		else
			DamageNumberSettings.Color = Color3.fromRGB(255, 255, 255)
			DamageNumberSettings.OutlineColor = Color3.fromRGB(0, 0, 0)
			DamageNumberSettings.UseTemplate = false
			DamageNumberSettings.FadeOut = true
			DamageNumberSettings.FlyOut = true
			DamageNumberSettings.Outline = true
			DamageNumberSettings.SplitDigits = false
			DamageNumberSettings.Lifetime = 1.0
			DamageNumberSettings.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
		end
		DamageNumberSettings.Preset = name
	end
	getgenv().HoodVisualsApplyDamageNumberPreset = ApplyDamageNumberPreset

	local lastDamageNumberTime = {}
	local HitmarkerSettings = {Enabled = false, Color = Color3.fromRGB(255, 255, 255), Lifetime = 0.5, Size = 100}
	local KillMarkerSettings = {Enabled = false, Lifetime = 3}
	local lastHitmarkerTime = {}
	local lastKillMarkerTime = {}

	local function BuildCustomDamageIndicator()
		local ind = Instance.new("Frame")
		ind.Size = UDim2.new(0.04, 0, 0.035, 0)
		ind.BackgroundTransparency = 1
		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1.1428571428571428
		aspect.Parent = ind
		local function makeLabel(name, position)
			local lbl = Instance.new("TextLabel")
			lbl.Name = name
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.Position = position
			lbl.BackgroundTransparency = 1
			lbl.TextScaled = true
			lbl.Text = ""
			lbl.TextColor3 = DamageNumberSettings.Color
			lbl.FontFace = DamageNumberSettings.FontFace
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.TextYAlignment = Enum.TextYAlignment.Center
			lbl.TextStrokeTransparency = 1
			if DamageNumberSettings.Outline then
				local stroke = Instance.new("UIStroke")
				stroke.Thickness = 1.6
				stroke.Transparency = 0.5
				stroke.Color = DamageNumberSettings.OutlineColor
				stroke.Parent = lbl
			end
			lbl.Parent = ind
			return lbl
		end
		makeLabel("Left", UDim2.new(0.125, 0, 0, 0))
		makeLabel("Right", UDim2.new(0.375, 0, 0, 0))
		return ind
	end

	local function ShowDamageNumber(player, damage, worldPos)
		local enabled = library.flags["hood_visuals_damage_numbers_enabled"]
		if not enabled or not player or not worldPos then return end
		local currentTime = tick()
		if lastDamageNumberTime[player] and (currentTime - lastDamageNumberTime[player]) < 0.05 then return end
		lastDamageNumberTime[player] = currentTime
		local gui = GetIndicatorGui()
		if not gui then return end
		local preset = library.flags["hood_visuals_damage_numbers_preset"] or "Default"
		if DamageNumberSettings.Preset ~= preset then ApplyDamageNumberPreset(preset) end
		DamageNumberSettings.Color = library.flags["hood_visuals_damage_numbers_color"] and library.flags["hood_visuals_damage_numbers_color"].Color or DamageNumberSettings.Color
		DamageNumberSettings.UseTemplate = library.flags["hood_visuals_damage_numbers_use_template"] ~= false
		DamageNumberSettings.FadeOut = library.flags["hood_visuals_damage_numbers_fade_out"] ~= false
		DamageNumberSettings.FlyOut = library.flags["hood_visuals_damage_numbers_fly_out"] ~= false
		DamageNumberSettings.Outline = library.flags["hood_visuals_damage_numbers_outline"] ~= false
		DamageNumberSettings.Lifetime = library.flags["hood_visuals_damage_numbers_lifetime"] or 1.1
		local template = ReplicatedStorage:FindFirstChild("DamageIndicator")
		local indicator
		if template and DamageNumberSettings.UseTemplate then
			indicator = template:Clone()
			local left = indicator:FindFirstChild("Left")
			local right = indicator:FindFirstChild("Right")
			if left then
				left.TextColor3 = DamageNumberSettings.Color
				left.FontFace = DamageNumberSettings.FontFace
				if left:FindFirstChild("UIStroke") then
					left.UIStroke.Color = DamageNumberSettings.OutlineColor
					left.UIStroke.Transparency = DamageNumberSettings.Outline and 0.5 or 1
				end
			end
			if right then
				right.TextColor3 = DamageNumberSettings.Color
				right.FontFace = DamageNumberSettings.FontFace
				if right:FindFirstChild("UIStroke") then
					right.UIStroke.Color = DamageNumberSettings.OutlineColor
					right.UIStroke.Transparency = DamageNumberSettings.Outline and 0.5 or 1
				end
			end
		else
			indicator = BuildCustomDamageIndicator()
		end
		game.Debris:AddItem(indicator, DamageNumberSettings.Lifetime + 0.5)
		local text = tostring(math.floor(damage + 0.5))
		local digits = {}
		for i = 1, #text do table.insert(digits, text:sub(i, i)) end
		local leftLabel = indicator:FindFirstChild("Left")
		local rightLabel = indicator:FindFirstChild("Right")
		if #text > 2 then
			if leftLabel then leftLabel.Text = ""; leftLabel.Visible = false end
			if rightLabel then rightLabel.Text = text; rightLabel.Size = UDim2.new(1, 0, 1, 0); rightLabel.Position = UDim2.new(0, 0, 0, 0); rightLabel.Visible = true end
		elseif DamageNumberSettings.SplitDigits then
			if leftLabel then leftLabel.Text = digits[1] or ""; leftLabel.Visible = true end
			if rightLabel then rightLabel.Text = digits[2] or ""; rightLabel.Size = UDim2.new(0.5, 0, 1, 0); rightLabel.Position = UDim2.new(0.375, 0, 0, 0); rightLabel.Visible = true end
		else
			if leftLabel then leftLabel.Text = ""; leftLabel.Visible = false end
			if rightLabel then rightLabel.Text = text; rightLabel.Size = UDim2.new(1, 0, 1, 0); rightLabel.Position = UDim2.new(0, 0, 0, 0); rightLabel.Visible = true end
		end
		indicator.Parent = gui
		task.spawn(function()
			indicator.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(indicator, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Size = UDim2.new(0.035, 0, 0.035, 0)}):Play()
			task.wait(0.175)
			TweenService:Create(indicator, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Size = UDim2.new(0.03, 0, 0.025, 0)}):Play()
			if DamageNumberSettings.FadeOut then
				task.delay(math.max(0.05, DamageNumberSettings.Lifetime - 0.2), function()
					if not indicator:IsDescendantOf(gui) then return end
					local tw = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
					if leftLabel then
						TweenService:Create(leftLabel, tw, {TextTransparency = 1}):Play()
						if leftLabel:FindFirstChild("UIStroke") then TweenService:Create(leftLabel.UIStroke, tw, {Transparency = 1}):Play() end
					end
					if rightLabel then
						TweenService:Create(rightLabel, tw, {TextTransparency = 1}):Play()
						if rightLabel:FindFirstChild("UIStroke") then TweenService:Create(rightLabel.UIStroke, tw, {Transparency = 1}):Play() end
					end
				end)
			end
			if DamageNumberSettings.FlyOut and leftLabel and rightLabel then
				local lStart = UDim2.new(0.125, 0, 0, 0)
				local lControl = UDim2.new(-0.425, 0, 0.2, 0)
				local lEnd = UDim2.new(-0.475, 0, 4, 0)
				local rStart = UDim2.new(0.375, 0, 0, 0)
				local rControl = UDim2.new(0.925, 0, 0.2, 0)
				local rEnd = UDim2.new(0.975, 0, 4, 0)
				local function quadBezier(t, p0, p1, p2)
					local a = p0:Lerp(p1, t)
					local b = p1:Lerp(p2, t)
					return a:Lerp(b, t)
				end
				for i = 0, 1, 0.035 do
					if not indicator:IsDescendantOf(gui) then break end
					local val = TweenService:GetValue(i, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
					leftLabel.Position = quadBezier(val, lStart, lControl, lEnd)
					rightLabel.Position = quadBezier(val, rStart, rControl, rEnd)
					if val < 0.25 then
						leftLabel.Rotation = val * -1
						rightLabel.Rotation = val
					else
						leftLabel.Rotation = leftLabel.Rotation - 10
						rightLabel.Rotation = rightLabel.Rotation + 10
					end
					task.wait(1 / 60)
				end
			end
		end)
		indicator.AnchorPoint = Vector2.new(0.5, 0.5)
		task.spawn(function()
			while indicator and indicator:IsDescendantOf(gui) do
				local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
				local x, y = pos.X, pos.Y
				if not onScreen then
					local abs = indicator.AbsoluteSize
					local vs = Camera.ViewportSize
					x = math.clamp(x, abs.X / 2, vs.X - abs.X / 2)
					y = math.clamp(y, abs.Y / 2, vs.Y - abs.Y / 2)
				end
				indicator.Position = UDim2.new(0, x, 0, y)
				RunService.RenderStepped:Wait()
			end
		end)
	end
	getgenv().ShowDamageNumber = ShowDamageNumber

	local function ShowHitmarker(worldPos)
		if not HitmarkerSettings.Enabled or not worldPos then return end
		local currentTime = tick()
		if lastHitmarkerTime[1] and (currentTime - lastHitmarkerTime[1]) < 0.05 then return end
		lastHitmarkerTime[1] = currentTime
		local gui = GetIndicatorGui()
		if not gui then return end
		local template = ReplicatedStorage:FindFirstChild("DMGIndicator")
		local indicator
		if template then
			indicator = template:Clone()
			indicator.ImageColor3 = HitmarkerSettings.Color
		else
			indicator = Instance.new("ImageLabel")
			indicator.Image = "rbxassetid://14101461906"
			indicator.ImageColor3 = HitmarkerSettings.Color
			indicator.BackgroundTransparency = 1
			Instance.new("UIAspectRatioConstraint", indicator)
		end
		local size = HitmarkerSettings.Size
		indicator.Size = UDim2.new(0, size, 0, size)
		indicator.Position = UDim2.new(0.5, -size / 2, 0.5, -size / 2)
		indicator.ImageTransparency = 0
		indicator.Parent = gui
		game.Debris:AddItem(indicator, HitmarkerSettings.Lifetime + 0.1)
		local camCF = Camera.CFrame
		local dir = (worldPos - camCF.Position)
		local angle = math.deg(math.atan2(dir.Z, dir.X) - math.atan2(camCF.LookVector.Z, camCF.LookVector.X))
		indicator.Rotation = angle + 90
		TweenService:Create(indicator, TweenInfo.new(HitmarkerSettings.Lifetime, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
	end
	getgenv().ShowHitmarker = ShowHitmarker

	local function ShowKillMarker(worldPos)
		if not KillMarkerSettings.Enabled or not worldPos then return end
		local currentTime = tick()
		if lastKillMarkerTime[1] and (currentTime - lastKillMarkerTime[1]) < 0.2 then return end
		lastKillMarkerTime[1] = currentTime
		local gui = GetIndicatorGui()
		if not gui then return end
		local template = ReplicatedStorage:FindFirstChild("KillIndicator")
		local indicator
		if template then
			indicator = template:Clone()
		else
			indicator = Instance.new("Frame")
			indicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			indicator.BackgroundTransparency = 0.5
			Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
			local img = Instance.new("ImageLabel")
			img.Name = "ImageLabel"
			img.Size = UDim2.new(0, 0, 0, 0)
			img.Position = UDim2.new(0.5, 0, 0.5, 0)
			img.AnchorPoint = Vector2.new(0.5, 0.5)
			img.BackgroundTransparency = 1
			img.Image = "rbxassetid://14385347210"
			img.Parent = indicator
			Instance.new("UIAspectRatioConstraint", indicator)
		end
		indicator.Size = UDim2.new(0, 0, 0, 0)
		indicator.Parent = gui
		game.Debris:AddItem(indicator, KillMarkerSettings.Lifetime + 0.5)
		TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = UDim2.new(0.017, 0, 0.031, 0)}):Play()
		local img = indicator:FindFirstChild("ImageLabel")
		if img then
			TweenService:Create(img, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0.667, 0, 0.673, 0)}):Play()
			task.delay(KillMarkerSettings.Lifetime - 0.5, function()
				if not indicator:IsDescendantOf(gui) then return end
				TweenService:Create(img, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
			end)
		end
		task.delay(KillMarkerSettings.Lifetime - 0.5, function()
			if not indicator:IsDescendantOf(gui) then return end
			TweenService:Create(indicator, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
		end)
		task.spawn(function()
			while indicator and indicator:IsDescendantOf(gui) do
				local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
				local abs = indicator.AbsoluteSize
				local x = pos.X - (abs.X / 2)
				local y = pos.Y - (abs.Y / 2)
				if not onScreen then
					local vs = Camera.ViewportSize
					x = math.clamp(x, 0, vs.X - abs.X)
					y = math.clamp(y, 0, vs.Y - abs.Y)
				end
				indicator.Position = UDim2.new(0, x, 0, y)
				RunService.RenderStepped:Wait()
			end
		end)
	end
	getgenv().ShowKillMarker = ShowKillMarker

	local function HitLogs(Player, damage)
		local enabled = library.flags["hood_visuals_hit_logs_enabled"]
		if not enabled then return end
		local currentTime = tick()
		local lastHitLogTime = getgenv().hood_visuals_last_hit_log_time or {}
		getgenv().hood_visuals_last_hit_log_time = lastHitLogTime
		if lastHitLogTime[Player] and (currentTime - lastHitLogTime[Player]) < 0.05 then return end
		local timeSinceShot = currentTime - (getgenv().hood_visuals_last_shot_time or 0)
		if timeSinceShot > 1.0 or timeSinceShot < 0 then return end
		local hasWeapon = false
		if LocalPlayer.Character then
			local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
			hasWeapon = tool ~= nil
		end
		if not hasWeapon then return end
		lastHitLogTime[Player] = currentTime
		if Player then
			local targetName = Player.DisplayName or Player.Name
			local notifTime = library.flags["hood_visuals_hit_logs_time"] or 3
			pcall(function()
				game.StarterGui:SetCore("SendNotification", {Title = "Notification", Text = "Hit " .. targetName .. " for " .. math.floor(damage) .. " damage", Duration = notifTime})
			end)
		end
	end
	getgenv().HitLogs = HitLogs
end

-- Hit Vignette
do
	local HitVignetteSettings = {
		Enabled = false,
		Color = Color3.fromRGB(180, 0, 0),
		Strength = 0.35,
		Lifetime = 0.12,
	}
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("HoodHitVignetteGui")
	if old then old:Destroy() end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HoodHitVignetteGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	local vignette = Instance.new("Frame")
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundTransparency = 1
	vignette.BorderSizePixel = 0
	vignette.ZIndex = 10
	vignette.Parent = screenGui
	local function makeEdge(size, pos, gradRotation, flip)
		local frame = Instance.new("Frame")
		frame.Size = size
		frame.Position = pos
		frame.BackgroundColor3 = HitVignetteSettings.Color
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ZIndex = 10
		frame.Parent = vignette
		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new(HitVignetteSettings.Color, HitVignetteSettings.Color)
		if flip then
			grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.3)})
		else
			grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
		end
		grad.Rotation = gradRotation
		grad.Parent = frame
		return frame, grad
	end
	local top, topGrad = makeEdge(UDim2.new(1, 0, 0.28, 0), UDim2.new(0,0,0,0), 90, false)
	local bottom, bottomGrad = makeEdge(UDim2.new(1, 0, 0.28, 0), UDim2.new(0,0,0.72,0), 90, true)
	local left, leftGrad = makeEdge(UDim2.new(0.21, 0, 1, 0), UDim2.new(0,0,0,0), 0, false)
	local right, rightGrad = makeEdge(UDim2.new(0.21, 0, 1, 0), UDim2.new(0.79,0,0,0), 0, true)
	local edges = {top, bottom, left, right}
	local grads = {topGrad, bottomGrad, leftGrad, rightGrad}
	local function updateVignetteColor()
		local c = HitVignetteSettings.Color
		for _, frame in ipairs(edges) do frame.BackgroundColor3 = c end
		for _, grad in ipairs(grads) do grad.Color = ColorSequence.new(c, c) end
	end
	local function flashVignette()
		HitVignetteSettings.Enabled = library.flags["hood_visuals_hit_vignette_enabled"]
		HitVignetteSettings.Color = library.flags["hood_visuals_hit_vignette_color"] and library.flags["hood_visuals_hit_vignette_color"].Color or Color3.fromRGB(180, 0, 0)
		updateVignetteColor()
		if not HitVignetteSettings.Enabled then return end
		local strength = math.clamp(library.flags["hood_visuals_hit_vignette_strength"] or 0.35, 0.05, 1)
		local lifetime = math.clamp(library.flags["hood_visuals_hit_vignette_lifetime"] or 0.12, 0.05, 2)
		for _, f in ipairs(edges) do
			TweenService:Create(f, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1 - strength}):Play()
		end
		task.delay(lifetime, function()
			for _, f in ipairs(edges) do
				TweenService:Create(f, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
			end
		end)
	end
	getgenv().FlashHitVignette = flashVignette
end

-- Forcehit Tracers
do
	if not getgenv().FH_TracerConfig then
		getgenv().FH_TracerConfig = {
			Enabled = true,
			Color = Color3.fromRGB(255, 50, 50),
			EndColor = Color3.fromRGB(255, 50, 50),
			FadeOut = true,
			UseGradient = false,
			UseSpread = true,
			Lifetime = 0.8,
			TextureName = "Hoodcustoms",
			Texture = "rbxassetid://130791043",
			Mode = "Beam",
		}
	end
	local TracerFolder = Instance.new("Folder")
	TracerFolder.Name = "HoodForceHitTracers"
	TracerFolder.Parent = workspace
	local function FadeOutBeam(beam, partA, partB, lifetime)
		local start = tick()
		while tick() - start < lifetime do
			local t = (tick() - start) / lifetime
			beam.Transparency = NumberSequence.new(t, t)
			task.wait(0.05)
		end
		partA:Destroy()
		partB:Destroy()
		beam:Destroy()
	end
	local function DrawBeamTracer(startPos, endPos, cfg)
		local children = TracerFolder:GetChildren()
		if #children > 30 then
			for i = 1, #children - 30 do children[i]:Destroy() end
		end
		local partA = Instance.new("Part")
		partA.Anchored = true
		partA.CanCollide = false
		partA.Transparency = 1
		partA.Size = Vector3.new(0.1, 0.1, 0.1)
		partA.CFrame = CFrame.new(startPos)
		partA.Parent = TracerFolder
		local partB = Instance.new("Part")
		partB.Anchored = true
		partB.CanCollide = false
		partB.Transparency = 1
		partB.Size = Vector3.new(0.1, 0.1, 0.1)
		partB.CFrame = CFrame.new(endPos)
		partB.Parent = TracerFolder
		local attA = Instance.new("Attachment")
		attA.Parent = partA
		local attB = Instance.new("Attachment")
		attB.Parent = partB
		local beam = Instance.new("Beam")
		beam.Attachment0 = attA
		beam.Attachment1 = attB
		local startColor = cfg.Color or Color3.fromRGB(255, 50, 50)
		local endColor = cfg.UseGradient and (cfg.EndColor or startColor) or startColor
		beam.Color = ColorSequence.new(startColor, endColor)
		beam.Texture = cfg.Texture or "rbxassetid://130791043"
		beam.TextureMode = Enum.TextureMode.Wrap
		beam.TextureLength = 5
		beam.Width0 = 0.5
		beam.Width1 = 0.5
		beam.FaceCamera = true
		beam.LightEmission = 1
		beam.LightInfluence = 0
		local t0 = cfg.UseGradient and 0 or 0
		local t1 = cfg.UseGradient and 1 or 0
		beam.Transparency = NumberSequence.new(t0, t1)
		beam.Parent = TracerFolder
		if cfg.FadeOut then
			task.spawn(FadeOutBeam, beam, partA, partB, cfg.Lifetime or 2)
		else
			task.delay(cfg.Lifetime or 2, function()
				partA:Destroy()
				partB:Destroy()
				beam:Destroy()
			end)
		end
	end
	local function DrawLineTracer(startPos, endPos, cfg)
		local line = Drawing.new("Line")
		line.Color = cfg.Color or Color3.fromRGB(255, 50, 50)
		line.Thickness = 1
		line.Transparency = 1
		line.Visible = true
		local cam = Camera
		local vSize = cam.ViewportSize
		local cx, cy = vSize.X / 2, vSize.Y / 2
		local function getScreen(p)
			local pos, on = cam:WorldToViewportPoint(p)
			if pos.Z < 0 then
				pos = Vector3.new(math.clamp(cx + (cx - pos.X), 0, vSize.X), math.clamp(cy + (cy - pos.Y), 0, vSize.Y), pos.Z)
			end
			return Vector2.new(pos.X, pos.Y), on or pos.Z > 0
		end
		local elapsed = 0
		local conn
		conn = RunService.RenderStepped:Connect(function(dt)
			elapsed = elapsed + dt
			local s, onS = getScreen(startPos)
			local e, onE = getScreen(endPos)
			if onS or onE then
				line.Visible = true
				line.From = s
				line.To = e
				if elapsed > (cfg.Lifetime or 0.8) then
					local fade = math.clamp((elapsed - (cfg.Lifetime or 0.8)) / 0.3, 0, 1)
					line.Transparency = 1 - fade
					if fade >= 1 then
						conn:Disconnect()
						line:Destroy()
					end
				end
			else
				line.Visible = false
			end
		end)
	end
	local function DrawTracer(startPos, endPos)
		local cfg = getgenv().FH_TracerConfig
		if not cfg or not cfg.Enabled then return end
		if (startPos - endPos).Magnitude < 0.1 then return end
		if cfg.Mode == "Drawing" then
			DrawLineTracer(startPos, endPos, cfg)
		else
			DrawBeamTracer(startPos, endPos, cfg)
		end
	end
	getgenv().HoodVisualsDrawTracer = DrawTracer

	local BulletRayConnection = nil
	local function ProcessBulletRay(beam)
		if beam.Name ~= "BULLET_RAYS" or not beam:IsA("Beam") then return end
		if beam:GetAttribute("OwnerCharacter") ~= LocalPlayer.Name then return end
		local cfg = getgenv().FH_TracerConfig
		if not cfg or not cfg.Enabled then return end
		local att0 = beam.Attachment0
		local att1 = beam.Attachment1
		if not att0 or not att1 then return end
		local startPos = att0.WorldPosition
		local endPos = att1.WorldPosition
		if (startPos - endPos).Magnitude < 0.1 then return end
		task.defer(function() beam:Destroy() end)
		DrawTracer(startPos, endPos)
	end
	local function DestroyDefaultBulletRays()
		local cfg = getgenv().FH_TracerConfig
		if not cfg or not cfg.Enabled then return end
		for _, desc in ipairs(workspace:GetDescendants()) do
			if desc.Name == "BULLET_RAYS" then pcall(function() desc:Destroy() end) end
		end
	end
	local function HookBulletRays()
		if BulletRayConnection then BulletRayConnection:Disconnect() BulletRayConnection = nil end
		BulletRayConnection = workspace.DescendantAdded:Connect(function(child)
			if child.Name == "BULLET_RAYS" and child:IsA("Beam") then ProcessBulletRay(child) end
		end)
	end
	DestroyDefaultBulletRays()
	HookBulletRays()

	RunService.Heartbeat:Connect(function()
		local cfg = getgenv().FH_TracerConfig
		cfg.Enabled = library.flags["hood_visuals_forcehit_tracers_enabled"] ~= false
		local color = library.flags["hood_visuals_forcehit_tracers_color"] and library.flags["hood_visuals_forcehit_tracers_color"].Color
		if color then cfg.Color = color end
		local endColor = library.flags["hood_visuals_forcehit_tracers_end_color"] and library.flags["hood_visuals_forcehit_tracers_end_color"].Color
		if endColor then cfg.EndColor = endColor end
		cfg.FadeOut = library.flags["hood_visuals_forcehit_tracers_fade_out"] ~= false
		cfg.UseGradient = library.flags["hood_visuals_forcehit_tracers_gradient"] == true
		cfg.UseSpread = library.flags["hood_visuals_forcehit_tracers_spread"] ~= false
		cfg.Lifetime = library.flags["hood_visuals_forcehit_tracers_lifetime"] or 0.8
		local textureName = library.flags["hood_visuals_forcehit_tracers_texture"] or "Hoodcustoms"
		if cfg.TextureName ~= textureName then
			cfg.TextureName = textureName
			if textureName == "Drawing" then
				cfg.Mode = "Drawing"
			else
				cfg.Mode = "Beam"
				local textureMap = {["Default"] = "rbxassetid://130791043", ["Hoodcustoms"] = "rbxassetid://130791043", ["laser"] = "rbxassetid://12781800668", ["light"] = "rbxassetid://2382169232", ["flow"] = "rbxassetid://12788927812"}
				cfg.Texture = textureMap[textureName] or textureMap["Default"]
			end
		end
	end)
end

-- World & Weather
do
	local Lighting = game:GetService("Lighting")
	local WorldSettings = {
		FogEnabled = false,
		FogColor = Color3.fromRGB(192, 192, 192),
		FogStart = 0,
		FogEnd = 100000,
		AmbientEnabled = false,
		Ambient = Color3.fromRGB(70, 70, 70),
		OutdoorAmbientEnabled = false,
		OutdoorAmbient = Color3.fromRGB(140, 140, 140),
		TimeEnabled = false,
		TimeValue = 14,
		BloomEnabled = false,
		BloomIntensity = 0.75,
		BloomSize = 24,
		BloomThreshold = 1,
		ColorCorrectionEnabled = false,
		CCBrightness = 0,
		CCContrast = 0,
		CCSaturation = 0,
		CCTintColor = Color3.fromRGB(255, 255, 255),
		SkyboxEnabled = false,
		SkyboxChoice = "black storm",
		WeatherEnabled = false,
		WeatherType = "rain",
		WeatherColor = Color3.fromRGB(255, 255, 255),
		WeatherRate = 100,
		WeatherSoundEnabled = true,
		WeatherSound = "Rain 1",
		WeatherVolume = 0.5,
	}
	local OriginalLighting = {
		FogColor = Lighting.FogColor,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
	}
	local bloomEffect = nil
	local colorCorrectionEffect = nil
	local function getOrCreateEffect(className, name)
		local existing = Lighting:FindFirstChild(name)
		if existing then return existing end
		local effect = Instance.new(className)
		effect.Name = name
		effect.Parent = Lighting
		return effect
	end

	local skyboxOriginal = nil
	local skyboxes = {
		["black storm"] = {SkyboxLf = "rbxassetid://15502507918", SkyboxUp = "rbxassetid://15502511911", SkyboxRt = "rbxassetid://15502509398", SkyboxFt = "rbxassetid://15502510289", SkyboxDn = "rbxassetid://15502508460", SkyboxBk = "rbxassetid://15502511288"},
		["blue space"] = {SkyboxLf = "rbxassetid://15536114370", SkyboxUp = "rbxassetid://15536117282", SkyboxRt = "rbxassetid://15536118762", SkyboxFt = "rbxassetid://15536116141", SkyboxDn = "rbxassetid://15536112543", SkyboxBk = "rbxassetid://15536110634"},
		["realistic"] = {SkyboxUp = "rbxassetid://653719321", SkyboxDn = "rbxassetid://653718790", SkyboxLf = "rbxassetid://653719190", SkyboxFt = "rbxassetid://653719067", SkyboxRt = "rbxassetid://653718931", SkyboxBk = "rbxassetid://653719502"},
		["stormy"] = {SkyboxUp = "http://www.roblox.com/asset/?id=18703232671", SkyboxBk = "http://www.roblox.com/asset/?id=18703245834", SkyboxLf = "http://www.roblox.com/asset/?id=18703237556", SkyboxDn = "http://www.roblox.com/asset/?id=18703243349", SkyboxFt = "http://www.roblox.com/asset/?id=18703240532", SkyboxRt = "http://www.roblox.com/asset/?id=18703235430"},
		["pink"] = {SkyboxUp = "rbxassetid://12216108877", SkyboxLf = "rbxassetid://12216110170", SkyboxRt = "rbxassetid://12216110471", SkyboxFt = "rbxassetid://12216109489", SkyboxBk = "rbxassetid://12216109205", SkyboxDn = "rbxassetid://12216109875"},
	}
	local function getSky()
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if not sky then
			sky = Instance.new("Sky")
			sky.Name = "CustomSky"
			sky.Parent = Lighting
		end
		return sky
	end
	local function applySkybox(name)
		local sky = getSky()
		if not skyboxOriginal then
			skyboxOriginal = {SkyboxBk = sky.SkyboxBk, SkyboxDn = sky.SkyboxDn, SkyboxFt = sky.SkyboxFt, SkyboxLf = sky.SkyboxLf, SkyboxRt = sky.SkyboxRt, SkyboxUp = sky.SkyboxUp}
		end
		if name == "default" or not WorldSettings.SkyboxEnabled then
			for prop, id in pairs(skyboxOriginal) do sky[prop] = id end
			return
		end
		local ids = skyboxes[name]
		if not ids then return end
		sky.SkyboxBk = ids.SkyboxBk or sky.SkyboxBk
		sky.SkyboxDn = ids.SkyboxDn or sky.SkyboxDn
		sky.SkyboxFt = ids.SkyboxFt or sky.SkyboxFt
		sky.SkyboxLf = ids.SkyboxLf or sky.SkyboxLf
		sky.SkyboxRt = ids.SkyboxRt or sky.SkyboxRt
		sky.SkyboxUp = ids.SkyboxUp or sky.SkyboxUp
	end

	local weatherPart = nil
	local weatherParticle = nil
	local weatherConnection = nil
	local weatherSound = nil
	local weatherTypes = {
		["rain"] = {Speed = NumberRange.new(60, 60), LockedToPart = true, Rate = 600, Texture = "rbxassetid://1822883048", EmissionDirection = Enum.NormalId.Bottom, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.7842668294906616), NumberSequenceKeypoint.new(0.75, 0.7842668294906616), NumberSequenceKeypoint.new(1, 1)}, Lifetime = NumberRange.new(0.800000011920929, 0.800000011920929), LightEmission = 0.05000000074505806, LightInfluence = 0.8999999761581421, Orientation = Enum.ParticleOrientation.FacingCameraWorldUp, Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 10)}},
		["snow"] = {Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.7374999523162842), NumberSequenceKeypoint.new(0.973, 0.768750011920929), NumberSequenceKeypoint.new(1, 1)}, Texture = "http://www.roblox.com/asset/?id=99851851", SpreadAngle = Vector2.new(50, 50), Speed = NumberRange.new(30, 30), LightEmission = 0.5, Rate = 1000, EmissionDirection = Enum.NormalId.Bottom, Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.33096909523010254), NumberSequenceKeypoint.new(0.551, 0.40189146995544434), NumberSequenceKeypoint.new(1, 0.33096909523010254)}},
		["light rain"] = {LockedToPart = true, Rate = 500, Squash = NumberSequence.new{NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 3)}, LightInfluence = 0.30000001192092896, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.435, 0), NumberSequenceKeypoint.new(1, 0)}, Texture = "rbxasset://textures/particles/sparkles_main.dds", Speed = NumberRange.new(30, 50), Lifetime = NumberRange.new(9, 9), LightEmission = 0.5, Brightness = 2, EmissionDirection = Enum.NormalId.Bottom, Orientation = Enum.ParticleOrientation.FacingCameraWorldUp, Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.20000000298023224), NumberSequenceKeypoint.new(1, 0.20000000298023224)}},
	}
	local weatherSounds = {
		["Rain 1"] = "rbxassetid://1516791621", ["Rain 2"] = "rbxassetid://138911277964858", ["Light Rain"] = "rbxassetid://18862087062",
		["Thunder"] = "rbxassetid://88290426489497", ["windy winter"] = "rbxassetid://6046340391", ["thunderstorm"] = "rbxassetid://4305545740",
		["night"] = "rbxassetid://179507208", ["day"] = "rbxassetid://6189453706",
	}
	local weatherOffset = Vector3.new(0, 20, 0)
	local function updateWeatherSound()
		if weatherSound then weatherSound:Destroy() weatherSound = nil end
		if not WorldSettings.WeatherEnabled then return end
		if not WorldSettings.WeatherSoundEnabled then return end
		if not weatherPart then return end
		local soundId = weatherSounds[WorldSettings.WeatherSound]
		if not soundId then return end
		weatherSound = Instance.new("Sound")
		weatherSound.Name = "WeatherAmbient"
		weatherSound.SoundId = soundId
		weatherSound.Looped = true
		weatherSound.Volume = WorldSettings.WeatherVolume
		weatherSound.Parent = weatherPart
		weatherSound:Play()
	end
	local function rebuildWeather()
		if weatherPart then weatherPart:Destroy() weatherPart = nil weatherParticle = nil end
		if weatherConnection then weatherConnection:Disconnect() weatherConnection = nil end
		if weatherSound then weatherSound:Destroy() weatherSound = nil end
		if not WorldSettings.WeatherEnabled then return end
		weatherPart = Instance.new("Part")
		weatherPart.Size = Vector3.new(40, 40, 85)
		weatherPart.CanCollide = false
		weatherPart.Massless = true
		weatherPart.CastShadow = false
		weatherPart.Transparency = 1
		weatherPart.Anchored = true
		weatherPart.Name = "WeatherPart"
		weatherPart.Parent = workspace
		local data = weatherTypes[WorldSettings.WeatherType]
		weatherParticle = Instance.new("ParticleEmitter")
		for prop, val in pairs(data) do weatherParticle[prop] = val end
		weatherParticle.Color = ColorSequence.new(WorldSettings.WeatherColor)
		weatherParticle.Rate = WorldSettings.WeatherRate * 10
		weatherParticle.Parent = weatherPart
		weatherConnection = RunService.Heartbeat:Connect(function()
			if weatherPart and Camera then weatherPart.CFrame = CFrame.new(Camera.CFrame.Position) + weatherOffset end
		end)
		updateWeatherSound()
	end

	RunService.Heartbeat:Connect(function()
		WorldSettings.FogEnabled = library.flags["hood_visuals_fog_enabled"] == true
		WorldSettings.FogColor = library.flags["hood_visuals_fog_color"] and library.flags["hood_visuals_fog_color"].Color or WorldSettings.FogColor
		WorldSettings.FogStart = library.flags["hood_visuals_fog_start"] or 0
		WorldSettings.FogEnd = library.flags["hood_visuals_fog_end"] or 100000
		WorldSettings.AmbientEnabled = library.flags["hood_visuals_ambient_enabled"] == true
		WorldSettings.Ambient = library.flags["hood_visuals_ambient_color"] and library.flags["hood_visuals_ambient_color"].Color or WorldSettings.Ambient
		WorldSettings.OutdoorAmbientEnabled = library.flags["hood_visuals_outdoor_ambient_enabled"] == true
		WorldSettings.OutdoorAmbient = library.flags["hood_visuals_outdoor_ambient_color"] and library.flags["hood_visuals_outdoor_ambient_color"].Color or WorldSettings.OutdoorAmbient
		WorldSettings.TimeEnabled = library.flags["hood_visuals_time_enabled"] == true
		WorldSettings.TimeValue = library.flags["hood_visuals_time_of_day"] or 14
		WorldSettings.BloomEnabled = library.flags["hood_visuals_bloom_enabled"] == true
		WorldSettings.BloomIntensity = library.flags["hood_visuals_bloom_intensity"] or 0.75
		WorldSettings.BloomSize = library.flags["hood_visuals_bloom_size"] or 24
		WorldSettings.BloomThreshold = library.flags["hood_visuals_bloom_threshold"] or 1
		WorldSettings.ColorCorrectionEnabled = library.flags["hood_visuals_color_correction_enabled"] == true
		WorldSettings.CCBrightness = library.flags["hood_visuals_cc_brightness"] or 0
		WorldSettings.CCContrast = library.flags["hood_visuals_cc_contrast"] or 0
		WorldSettings.CCSaturation = library.flags["hood_visuals_cc_saturation"] or 0
		WorldSettings.CCTintColor = library.flags["hood_visuals_cc_tint_color"] and library.flags["hood_visuals_cc_tint_color"].Color or WorldSettings.CCTintColor
		WorldSettings.SkyboxEnabled = library.flags["hood_visuals_skybox_enabled"] == true
		WorldSettings.SkyboxChoice = library.flags["hood_visuals_skybox_choice"] or "black storm"

		if WorldSettings.FogEnabled then
			Lighting.FogColor = WorldSettings.FogColor
			Lighting.FogStart = WorldSettings.FogStart
			Lighting.FogEnd = WorldSettings.FogEnd
		else
			Lighting.FogColor = OriginalLighting.FogColor
			Lighting.FogStart = OriginalLighting.FogStart
			Lighting.FogEnd = OriginalLighting.FogEnd
		end
		if WorldSettings.AmbientEnabled then
			Lighting.Ambient = WorldSettings.Ambient
		else
			Lighting.Ambient = OriginalLighting.Ambient
		end
		if WorldSettings.OutdoorAmbientEnabled then
			Lighting.OutdoorAmbient = WorldSettings.OutdoorAmbient
		else
			Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
		end
		if WorldSettings.TimeEnabled then
			Lighting.ClockTime = WorldSettings.TimeValue
		else
			Lighting.ClockTime = OriginalLighting.ClockTime
		end
		if WorldSettings.BloomEnabled then
			bloomEffect = getOrCreateEffect("BloomEffect", "HoodCustomBloom")
			bloomEffect.Intensity = WorldSettings.BloomIntensity
			bloomEffect.Size = WorldSettings.BloomSize
			bloomEffect.Threshold = WorldSettings.BloomThreshold
			bloomEffect.Enabled = true
		elseif bloomEffect then
			bloomEffect.Enabled = false
		end
		if WorldSettings.ColorCorrectionEnabled then
			colorCorrectionEffect = getOrCreateEffect("ColorCorrectionEffect", "HoodCustomColorCorrection")
			colorCorrectionEffect.Brightness = WorldSettings.CCBrightness
			colorCorrectionEffect.Contrast = WorldSettings.CCContrast
			colorCorrectionEffect.Saturation = WorldSettings.CCSaturation
			colorCorrectionEffect.TintColor = WorldSettings.CCTintColor
			colorCorrectionEffect.Enabled = true
		elseif colorCorrectionEffect then
			colorCorrectionEffect.Enabled = false
		end
		applySkybox(WorldSettings.SkyboxEnabled and WorldSettings.SkyboxChoice or "default")

		local weatherEnabled = library.flags["hood_visuals_weather_enabled"] == true
		local weatherType = library.flags["hood_visuals_weather_type"] or "rain"
		local weatherColor = library.flags["hood_visuals_weather_color"] and library.flags["hood_visuals_weather_color"].Color or Color3.fromRGB(255, 255, 255)
		local weatherRate = library.flags["hood_visuals_weather_rate"] or 100
		local weatherSoundEnabled = library.flags["hood_visuals_weather_sounds_enabled"] ~= false
		local weatherSound = library.flags["hood_visuals_weather_noise"] or "Rain 1"
		local weatherVolume = library.flags["hood_visuals_weather_volume"] or 0.5
		local needsRebuild = weatherEnabled ~= WorldSettings.WeatherEnabled or weatherType ~= WorldSettings.WeatherType
		WorldSettings.WeatherEnabled = weatherEnabled
		WorldSettings.WeatherType = weatherType
		WorldSettings.WeatherColor = weatherColor
		WorldSettings.WeatherRate = weatherRate
		WorldSettings.WeatherSoundEnabled = weatherSoundEnabled
		WorldSettings.WeatherSound = weatherSound
		WorldSettings.WeatherVolume = weatherVolume
		if needsRebuild then
			rebuildWeather()
		elseif weatherParticle then
			weatherParticle.Color = ColorSequence.new(weatherColor)
			weatherParticle.Rate = weatherRate * 10
			if weatherSound then weatherSound.Volume = weatherVolume end
		end
	end)
end

-- Crosshair
do
	local UserInputService = game:GetService("UserInputService")
	local Crosshair = {
		Enabled = false,
		FollowTarget = false,
		Size = 10,
		Gap = 5,
		Thickness = 2,
		OutlineThickness = 4,
		Color = Color3.fromRGB(255, 255, 255),
		RotationEnabled = false,
		RotationSpeed = 1,
		CurrentRotation = 0,
	}
	local crosshairLines = {}
	local crosshairOutlines = {}
	for i = 1, 4 do
		local outline = Drawing.new("Line")
		outline.Visible = false
		outline.Color = Color3.new(0, 0, 0)
		outline.Thickness = 4
		outline.Transparency = 0.8
		crosshairOutlines[i] = outline
		local line = Drawing.new("Line")
		line.Visible = false
		line.Color = Color3.fromRGB(255, 255, 255)
		line.Thickness = 2
		line.Transparency = 1
		crosshairLines[i] = line
	end

	local defaultGuiTarget = nil
	local function onRemoveDefaultCrosshair()
		local enabled = library.flags["hood_visuals_remove_default_crosshair"]
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if not pg then return end
		local crosshairGui = pg:FindFirstChild("Crosshair")
		if crosshairGui then
			if enabled then
				if crosshairGui.Enabled then defaultGuiTarget = crosshairGui end
				crosshairGui.Enabled = false
			elseif defaultGuiTarget == crosshairGui then
				crosshairGui.Enabled = true
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		Crosshair.Enabled = library.flags["hood_visuals_crosshair_enabled"] == true
		Crosshair.FollowTarget = library.flags["hood_visuals_crosshair_follow_target"] == true
		Crosshair.Size = library.flags["hood_visuals_crosshair_size"] or 10
		Crosshair.Gap = library.flags["hood_visuals_crosshair_gap"] or 5
		Crosshair.Thickness = library.flags["hood_visuals_crosshair_thickness"] or 2
		Crosshair.OutlineThickness = library.flags["hood_visuals_crosshair_outline_thickness"] or 4
		Crosshair.Color = library.flags["hood_visuals_crosshair_color"] and library.flags["hood_visuals_crosshair_color"].Color or Color3.fromRGB(255, 255, 255)
		Crosshair.RotationEnabled = library.flags["hood_visuals_crosshair_rotation"] == true
		Crosshair.RotationSpeed = library.flags["hood_visuals_crosshair_rotation_speed"] or 1

		local centerPos
		if Crosshair.FollowTarget then
			local followTarget = Targeting.Target
			local followPart = Targeting.TargetAimbotPart or "HumanoidRootPart"
			if followTarget and followTarget.Character then
				local targetPart = followTarget.Character:FindFirstChild(followPart)
				if targetPart then
					local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
					if onScreen then centerPos = Vector2.new(screenPos.X, screenPos.Y) else centerPos = UserInputService:GetMouseLocation() end
				else
					centerPos = UserInputService:GetMouseLocation()
				end
			else
				centerPos = UserInputService:GetMouseLocation()
			end
		else
			centerPos = UserInputService:GetMouseLocation()
		end

		if Crosshair.RotationEnabled then
			Crosshair.CurrentRotation = Crosshair.CurrentRotation + Crosshair.RotationSpeed * 0.1
			if Crosshair.CurrentRotation > math.pi * 2 then Crosshair.CurrentRotation = 0 end
		else
			Crosshair.CurrentRotation = 0
		end

		if Crosshair.Enabled then
			local size = Crosshair.Size
			local gap = Crosshair.Gap
			local rotation = Crosshair.CurrentRotation
			local positions = {
				{from = Vector2.new(centerPos.X + math.sin(rotation) * gap, centerPos.Y - math.cos(rotation) * gap), to = Vector2.new(centerPos.X + math.sin(rotation) * (gap + size), centerPos.Y - math.cos(rotation) * (gap + size))},
				{from = Vector2.new(centerPos.X + math.cos(rotation) * gap, centerPos.Y + math.sin(rotation) * gap), to = Vector2.new(centerPos.X + math.cos(rotation) * (gap + size), centerPos.Y + math.sin(rotation) * (gap + size))},
				{from = Vector2.new(centerPos.X - math.sin(rotation) * gap, centerPos.Y + math.cos(rotation) * gap), to = Vector2.new(centerPos.X - math.sin(rotation) * (gap + size), centerPos.Y + math.cos(rotation) * (gap + size))},
				{from = Vector2.new(centerPos.X - math.cos(rotation) * gap, centerPos.Y - math.sin(rotation) * gap), to = Vector2.new(centerPos.X - math.cos(rotation) * (gap + size), centerPos.Y - math.sin(rotation) * (gap + size))},
			}
			for i = 1, 4 do
				crosshairOutlines[i].From = positions[i].from
				crosshairOutlines[i].To = positions[i].to
				crosshairOutlines[i].Thickness = Crosshair.OutlineThickness
				crosshairOutlines[i].Visible = true
				crosshairLines[i].From = positions[i].from
				crosshairLines[i].To = positions[i].to
				crosshairLines[i].Color = Crosshair.Color
				crosshairLines[i].Thickness = Crosshair.Thickness
				crosshairLines[i].Visible = true
			end
		else
			for i = 1, 4 do
				crosshairLines[i].Visible = false
				crosshairOutlines[i].Visible = false
			end
		end
		onRemoveDefaultCrosshair()
	end)
end

-- Client Visuals
do
	-- Modify Body
	do
		local ClientBody = {
			Enabled = false,
			Material = "Neon",
			Color = Color3.fromRGB(57, 255, 150),
			Originals = {},
			ClothingClones = {},
			DecalClones = {},
			CharConnections = {},
			CurrentChar = nil,
		}
		local CLOTHING_NAMES = {"Shirt", "Pants", "ShirtGraphic"}
		local function disconnectCharConnections()
			for _, c in ipairs(ClientBody.CharConnections) do pcall(function() c:Disconnect() end) end
			table.clear(ClientBody.CharConnections)
		end
		local function saveOriginalData(part)
			if ClientBody.Originals[part] then return end
			local data = {Material = part.Material, Color = part.Color}
			local ok1, texID = pcall(function() return part.TextureID end)
			if ok1 and texID then data.TextureID = texID end
			local tex = part:FindFirstChildOfClass("Texture")
			if tex and tex.Texture then data.Texture = tex.Texture end
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("SpecialMesh") then
					local ok2, meshTex = pcall(function() return child.TextureId end)
					if ok2 and meshTex then data.SpecialMeshTexture = meshTex end
					break
				end
			end
			ClientBody.Originals[part] = data
		end
		local function applyPart(part)
			if not (part:IsA("BasePart") or part:IsA("MeshPart")) then return end
			saveOriginalData(part)
			pcall(function() part.TextureID = "" end)
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("SpecialMesh") then pcall(function() child.TextureId = "" end) end
			end
			part.Material = Enum.Material[ClientBody.Material]
			part.Color = ClientBody.Color
		end
		local function forceHead(head)
			if not (head:IsA("BasePart") or head:IsA("MeshPart")) then return end
			for _, name in ipairs({"FaceControls", "HeadWrapTarget"}) do
				local fc = head:FindFirstChild(name)
				if fc then fc:Destroy() end
			end
			for _, child in ipairs(head:GetChildren()) do
				if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
					local clone = child:Clone()
					if clone then ClientBody.DecalClones[child] = {Clone = clone, Parent = head} end
					child:Destroy()
				end
			end
			pcall(function() head.TextureID = "" end)
			for _, child in ipairs(head:GetChildren()) do
				if child:IsA("SpecialMesh") then pcall(function() child.TextureId = "" end) end
			end
			head.Material = Enum.Material[ClientBody.Material]
			head.Color = ClientBody.Color
		end
		local function restoreCharacter(char)
			if not char then return end
			disconnectCharConnections()
			for name, clone in pairs(ClientBody.ClothingClones) do
				if clone and not clone.Parent then pcall(function() clone.Parent = char end) end
			end
			table.clear(ClientBody.ClothingClones)
			for _, info in pairs(ClientBody.DecalClones) do
				local clone = info.Clone
				if clone and not clone.Parent then pcall(function() clone.Parent = info.Parent end) end
			end
			table.clear(ClientBody.DecalClones)
			for part, data in pairs(ClientBody.Originals) do
				if part and part.Parent then
					pcall(function()
						part.Material = data.Material
						part.Color = data.Color
						if data.TextureID then part.TextureID = data.TextureID else part.TextureID = "" end
					end)
					if data.Texture then
						local tex = part:FindFirstChildOfClass("Texture")
						if tex then pcall(function() tex.Texture = data.Texture end) end
					end
					if data.SpecialMeshTexture then
						for _, child in ipairs(part:GetChildren()) do
							if child:IsA("SpecialMesh") then
								pcall(function() child.TextureId = data.SpecialMeshTexture end)
								break
							end
						end
					end
				end
			end
			table.clear(ClientBody.Originals)
			if ClientBody.CurrentChar == char then ClientBody.CurrentChar = nil end
		end
		local function cleanAndApply(char)
			if not char then return end
			disconnectCharConnections()
			restoreCharacter(ClientBody.CurrentChar)
			ClientBody.CurrentChar = char
			for _, name in ipairs(CLOTHING_NAMES) do
				local item = char:FindFirstChild(name)
				if item then
					local clone = item:Clone()
					if clone then ClientBody.ClothingClones[name] = clone end
					item:Destroy()
				end
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("MeshPart") then
					saveOriginalData(part)
					for _, child in ipairs(part:GetChildren()) do
						if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
							local clone = child:Clone()
							if clone then ClientBody.DecalClones[child] = {Clone = clone, Parent = part} end
							child:Destroy()
						end
					end
				end
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("MeshPart") then pcall(function() part.TextureID = "" end)
				elseif part:IsA("SpecialMesh") then pcall(function() part.TextureId = "" end) end
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part.Name == "Head" then forceHead(part) end
			end
			for _, part in ipairs(char:GetDescendants()) do applyPart(part) end
			table.insert(ClientBody.CharConnections, char.DescendantAdded:Connect(function(desc)
				if desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("SurfaceAppearance") then
					local clone = desc:Clone()
					if clone then ClientBody.DecalClones[desc] = {Clone = clone, Parent = desc.Parent} end
					desc:Destroy()
					return
				end
				if desc:IsA("Shirt") or desc:IsA("Pants") or desc:IsA("ShirtGraphic") then
					local clone = desc:Clone()
					if clone then ClientBody.ClothingClones[desc.Name] = clone end
					desc:Destroy()
					return
				end
				if desc.Name == "Head" then forceHead(desc) end
				applyPart(desc)
			end))
			table.insert(ClientBody.CharConnections, RunService.RenderStepped:Connect(function()
				if not ClientBody.Enabled then return end
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") or part:IsA("MeshPart") then
						if part.Name == "Head" then forceHead(part) else part.Material = Enum.Material[ClientBody.Material]; part.Color = ClientBody.Color end
					end
				end
			end))
		end
		local function updateBodyMaterial()
			if not ClientBody.Enabled or not ClientBody.CurrentChar then return end
			local char = ClientBody.CurrentChar
			ClientBody.Material = library.flags["hood_visuals_modify_body_material"] or "Neon"
			ClientBody.Color = library.flags["hood_visuals_modify_body_color"] and library.flags["hood_visuals_modify_body_color"].Color or Color3.fromRGB(57, 255, 150)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("MeshPart") then
					if part.Name == "Head" then forceHead(part) else part.Material = Enum.Material[ClientBody.Material]; part.Color = ClientBody.Color end
				end
			end
		end
		getgenv().HoodVisualsApplyBody = function(enabled)
			ClientBody.Enabled = enabled
			if enabled then
				if LocalPlayer.Character then
					ClientBody.Material = library.flags["hood_visuals_modify_body_material"] or "Neon"
					ClientBody.Color = library.flags["hood_visuals_modify_body_color"] and library.flags["hood_visuals_modify_body_color"].Color or Color3.fromRGB(57, 255, 150)
					cleanAndApply(LocalPlayer.Character)
				end
			else
				restoreCharacter(ClientBody.CurrentChar)
			end
		end
		LocalPlayer.CharacterAdded:Connect(function(char)
			if ClientBody.Enabled then
				task.wait(0.3)
				cleanAndApply(char)
			end
		end)
		LocalPlayer.CharacterRemoving:Connect(function(char)
			if char == ClientBody.CurrentChar then restoreCharacter(char) end
		end)
		RunService.Heartbeat:Connect(updateBodyMaterial)
	end

	-- Korblox
	do
		local KorbloxVisual = {Enabled = false, Mesh = "https://assetdelivery.roblox.com/v1/asset/?id=9598310133", Texture = "https://www.roblox.com/asset/?id=902843398", Originals = {}, CharConnection = nil}
		local function restoreKorblox(char)
			if not char then return end
			if KorbloxVisual.CharConnection then pcall(function() KorbloxVisual.CharConnection:Disconnect() end) KorbloxVisual.CharConnection = nil end
			local rightFoot = char:FindFirstChild("RightFoot")
			local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
			local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
			if rightFoot and KorbloxVisual.Originals[rightFoot] then rightFoot.Transparency = KorbloxVisual.Originals[rightFoot] end
			if rightLowerLeg and KorbloxVisual.Originals[rightLowerLeg] then
				rightLowerLeg.Transparency = KorbloxVisual.Originals[rightLowerLeg].Transparency
				rightLowerLeg.MeshId = KorbloxVisual.Originals[rightLowerLeg].MeshId
				rightLowerLeg.TextureID = KorbloxVisual.Originals[rightLowerLeg].TextureID
			end
			if rightUpperLeg and KorbloxVisual.Originals[rightUpperLeg] then
				rightUpperLeg.Transparency = KorbloxVisual.Originals[rightUpperLeg].Transparency
				rightUpperLeg.MeshId = KorbloxVisual.Originals[rightUpperLeg].MeshId
				rightUpperLeg.TextureID = KorbloxVisual.Originals[rightUpperLeg].TextureID
			end
			table.clear(KorbloxVisual.Originals)
		end
		local function applyKorblox(char)
			if not char then return end
			restoreKorblox(char)
			local rightFoot = char:FindFirstChild("RightFoot")
			local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
			local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
			if rightFoot then KorbloxVisual.Originals[rightFoot] = rightFoot.Transparency; rightFoot.Transparency = 1 end
			if rightLowerLeg then KorbloxVisual.Originals[rightLowerLeg] = {Transparency = rightLowerLeg.Transparency, MeshId = rightLowerLeg.MeshId, TextureID = rightLowerLeg.TextureID}; rightLowerLeg.Transparency = 1 end
			if rightUpperLeg then
				KorbloxVisual.Originals[rightUpperLeg] = {Transparency = rightUpperLeg.Transparency, MeshId = rightUpperLeg.MeshId, TextureID = rightUpperLeg.TextureID}
				rightUpperLeg.Transparency = 0
				rightUpperLeg.MeshId = KorbloxVisual.Mesh
				rightUpperLeg.TextureID = KorbloxVisual.Texture
			end
			KorbloxVisual.CharConnection = char.ChildAdded:Connect(function(child)
				if not KorbloxVisual.Enabled then return end
				if child.Name == "RightFoot" or child.Name == "RightLowerLeg" or child.Name == "RightUpperLeg" then
					task.wait(0.1)
					applyKorblox(char)
				end
			end)
		end
		getgenv().HoodVisualsApplyKorblox = function(enabled)
			KorbloxVisual.Enabled = enabled
			if enabled then
				if LocalPlayer.Character then applyKorblox(LocalPlayer.Character) end
			else
				restoreKorblox(LocalPlayer.Character)
			end
		end
		LocalPlayer.CharacterAdded:Connect(function(char)
			if KorbloxVisual.Enabled then task.wait(0.3); applyKorblox(char) end
		end)
	end

	-- Headless
	do
		local HeadlessVisual = {Enabled = false, OriginalTransparency = nil, CharConnection = nil}
		local function restoreHeadless(char)
			if not char then return end
			if HeadlessVisual.CharConnection then pcall(function() HeadlessVisual.CharConnection:Disconnect() end) HeadlessVisual.CharConnection = nil end
			local head = char:FindFirstChild("Head")
			if head and HeadlessVisual.OriginalTransparency ~= nil then head.Transparency = HeadlessVisual.OriginalTransparency end
			HeadlessVisual.OriginalTransparency = nil
		end
		local function applyHeadless(char)
			if not char then return end
			restoreHeadless(char)
			local head = char:FindFirstChild("Head")
			if head then
				HeadlessVisual.OriginalTransparency = head.Transparency
				head.Transparency = 1
				for _, child in ipairs(head:GetChildren()) do
					if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 1 end
				end
			end
			HeadlessVisual.CharConnection = char.ChildAdded:Connect(function(child)
				if not HeadlessVisual.Enabled then return end
				if child.Name == "Head" then task.wait(0.1); applyHeadless(char) end
			end)
		end
		getgenv().HoodVisualsApplyHeadless = function(enabled)
			HeadlessVisual.Enabled = enabled
			if enabled then
				if LocalPlayer.Character then applyHeadless(LocalPlayer.Character) end
			else
				restoreHeadless(LocalPlayer.Character)
			end
		end
		LocalPlayer.CharacterAdded:Connect(function(char)
			if HeadlessVisual.Enabled then task.wait(0.3); applyHeadless(char) end
		end)
	end

	-- Particle Aura
	do
		local ParticleAura = {Enabled = false, Selected = "angel", Color = Color3.fromRGB(133, 220, 255), ActiveParticles = {}}
		local particleIds = {["starlight"] = "rbxassetid://134645216613107", ["heavenly"] = "rbxassetid://139300897520961", ["ribbon"] = "rbxassetid://132069507632161", ["sakura"] = "rbxassetid://81755778619404", ["angel"] = "rbxassetid://97658130917593", ["wind"] = "rbxassetid://80694081850877", ["flow"] = "rbxassetid://119913533725648", ["star"] = "rbxassetid://73754563740680"}
		local function clearParticles()
			for i = #ParticleAura.ActiveParticles, 1, -1 do
				local p = ParticleAura.ActiveParticles[i]
				if p and p.Parent then p:Destroy() end
				table.remove(ParticleAura.ActiveParticles, i)
			end
		end
		local function colorParticles(root)
			local colorSeq = ColorSequence.new(ParticleAura.Color)
			for _, desc in ipairs(root:GetDescendants()) do
				if desc:IsA("PointLight") then desc.Color = ParticleAura.Color
				elseif desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") then desc.Color = colorSeq end
			end
		end
		local function applyParticleAura(char)
			if not char then return end
			clearParticles()
			ParticleAura.Selected = library.flags["hood_visuals_particle_aura_type"] or "angel"
			ParticleAura.Color = library.flags["hood_visuals_particle_aura_color"] and library.flags["hood_visuals_particle_aura_color"].Color or Color3.fromRGB(133, 220, 255)
			local auraId = particleIds[ParticleAura.Selected]
			if not auraId then return end
			local success, objects = pcall(function() return game:GetObjects(auraId) end)
			if not success or not objects or not objects[1] then return end
			local auraModel = objects[1]
			colorParticles(auraModel)
			for _, auraPart in ipairs(auraModel:GetChildren()) do
				if auraPart:IsA("BasePart") then
					local target = char:FindFirstChild(auraPart.Name)
					if target then
						for _, child in ipairs(auraPart:GetChildren()) do
							local clone = child:Clone()
							if clone then
								clone.Name = "VisualAuraParticle"
								clone.Parent = target
								table.insert(ParticleAura.ActiveParticles, clone)
							end
						end
					end
				end
			end
			auraModel:Destroy()
		end
		getgenv().HoodVisualsApplyParticleAura = function(enabled)
			ParticleAura.Enabled = enabled
			if enabled then
				if LocalPlayer.Character then applyParticleAura(LocalPlayer.Character) end
			else
				clearParticles()
			end
		end
		LocalPlayer.CharacterAdded:Connect(function(char)
			if ParticleAura.Enabled then task.wait(0.5); applyParticleAura(char) end
		end)
		RunService.Heartbeat:Connect(function()
			if ParticleAura.Enabled and #ParticleAura.ActiveParticles > 0 then
				local color = library.flags["hood_visuals_particle_aura_color"] and library.flags["hood_visuals_particle_aura_color"].Color or ParticleAura.Color
				if color ~= ParticleAura.Color then
					ParticleAura.Color = color
					for _, p in ipairs(ParticleAura.ActiveParticles) do
						if p and p.Parent then
							if p:IsA("PointLight") then p.Color = color
							elseif p:IsA("ParticleEmitter") or p:IsA("Beam") or p:IsA("Trail") then p.Color = ColorSequence.new(color) end
						end
					end
				end
			end
		end)
	end

	-- Avatar Morph
	do
		local AvatarMorph = {Enabled = false, UserId = 5042596195, Originals = nil}
		local AvatarMorphAddEnabled = false
		local addAccessoryDebounce = 0
		local function clearLocalAccessories(character)
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") then item:Destroy() end
			end
		end
		local function getAllAccessories(model)
			local list = {}
			for _, desc in ipairs(model:GetDescendants()) do if desc:IsA("Accessory") then table.insert(list, desc) end end
			return list
		end
		local function cleanAccessory(accessory)
			for _, desc in ipairs(accessory:GetDescendants()) do
				if desc:IsA("Weld") or desc:IsA("ManualWeld") or desc:IsA("Motor6D") then desc:Destroy() end
			end
		end
		local function attachAccessory(character, accessory)
			local handle = accessory:FindFirstChild("Handle")
			if not handle or not handle:IsA("BasePart") then return end
			handle.Anchored = false
			handle.CanCollide = false
			handle.Massless = true
			cleanAccessory(accessory)
			local attachment = handle:FindFirstChildOfClass("Attachment")
			if not attachment then accessory.Parent = character; return end
			local targetAttachment = character:FindFirstChild(attachment.Name, true)
			if not targetAttachment or not targetAttachment:IsA("Attachment") then accessory.Parent = character; return end
			local targetPart = targetAttachment.Parent
			if not targetPart or not targetPart:IsA("BasePart") then accessory.Parent = character; return end
			local weld = Instance.new("Weld")
			weld.Name = "AccessoryWeld"
			weld.Part0 = handle
			weld.Part1 = targetPart
			weld.C0 = attachment.CFrame
			weld.C1 = targetAttachment.CFrame
			weld.Parent = handle
			handle.CFrame = targetPart.CFrame * targetAttachment.CFrame * attachment.CFrame:Inverse()
			accessory.Parent = character
		end
		local function saveOriginalAvatar(character)
			if not character then return end
			local data = {accessories = {}, clothes = {}, sizes = {}}
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Accessory") then table.insert(data.accessories, item:Clone())
				elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") then table.insert(data.clothes, item:Clone()) end
			end
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("MeshPart") then data.sizes[part.Name] = part.Size end
			end
			AvatarMorph.Originals = data
		end
		local function restoreOriginalAvatar(character)
			if not character or not AvatarMorph.Originals then return end
			clearLocalAccessories(character)
			for _, acc in ipairs(AvatarMorph.Originals.accessories) do
				local clone = acc:Clone()
				if clone then attachAccessory(character, clone) end
			end
			for _, item in ipairs(AvatarMorph.Originals.clothes) do
				local clone = item:Clone()
				if clone then clone.Parent = character end
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then pcall(function() humanoid:BuildRigFromAttachments() end) end
			for name, size in pairs(AvatarMorph.Originals.sizes) do
				local part = character:FindFirstChild(name)
				if part and part:IsA("MeshPart") then part.Size = size end
			end
		end
		local function applyAvatarMorph(userId)
			local character = LocalPlayer.Character
			if not character then return end
			local success, model = pcall(function() return Players:CreateHumanoidModelFromUserId(userId) end)
			if not success or not model then return end
			clearLocalAccessories(character)
			for _, accessory in ipairs(getAllAccessories(model)) do
				local clone = accessory:Clone()
				if clone then attachAccessory(character, clone) end
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then pcall(function() humanoid:BuildRigFromAttachments() end) end
			for _, item in ipairs(model:GetChildren()) do
				if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") then
					local clone = item:Clone()
					clone.Parent = character
				elseif item:IsA("MeshPart") and character:FindFirstChild(item.Name) then
					character[item.Name].Size = item.Size
				end
			end
			model:Destroy()
		end
		local function resolveUserId(input)
			local num = tonumber(input)
			if num then return num end
			local ok, userId = pcall(function() return Players:GetUserIdFromNameAsync(input) end)
			if ok and userId then return userId end
			return nil
		end
		local function refreshAccessoryDropdown(character)
			if not character then return end
			local list = {}
			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("Accessory") and child.Name ~= "Accessory" then table.insert(list, child.Name) end
			end
			if #list == 0 then list = {" "} end
			local dropdown = getgenv().HoodAvatarMorphAccessoriesDropdown
			if dropdown and dropdown.refresh_options then pcall(function() dropdown:refresh_options(list) end) end
		end
		getgenv().HoodVisualsRefreshAvatarMorphDropdown = refreshAccessoryDropdown
		local function addAccessoryById(assetId)
			local idNum = tonumber(assetId)
			if not idNum then return end
			local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. idNum) end)
			if not success or not objects or #objects == 0 then return end
			local model = objects[1]
			local accessory = nil
			if model:IsA("Accessory") then accessory = model
			else
				for _, desc in ipairs(model:GetDescendants()) do
					if desc:IsA("Accessory") then accessory = desc; break end
				end
			end
			if not accessory then return end
			local character = LocalPlayer.Character
			if not character then return end
			local clone = accessory:Clone()
			attachAccessory(character, clone)
			refreshAccessoryDropdown(character)
		end
		getgenv().HoodVisualsApplyAvatarMorph = function(enabled)
			AvatarMorph.Enabled = enabled
			local character = LocalPlayer.Character
			if enabled then
				if character and not AvatarMorph.Originals then saveOriginalAvatar(character) end
				local input = library.flags["hood_visuals_avatar_morph_user"] or "5042596195"
				local userId = resolveUserId(input)
				if userId then AvatarMorph.UserId = userId; applyAvatarMorph(userId) end
			else
				restoreOriginalAvatar(character)
			end
		end
		getgenv().HoodVisualsSetAvatarMorphUser = function(input)
			local userId = resolveUserId(input)
			if userId then
				AvatarMorph.UserId = userId
				if AvatarMorph.Enabled then applyAvatarMorph(userId) end
			end
		end
		getgenv().HoodVisualsSetAddAccessory = function(enabled)
			AvatarMorphAddEnabled = enabled
		end
		getgenv().HoodVisualsAddAccessory = function(assetId)
			if not AvatarMorphAddEnabled then return end
			addAccessoryDebounce = addAccessoryDebounce + 1
			local current = addAccessoryDebounce
			task.delay(0.5, function()
				if current == addAccessoryDebounce then addAccessoryById(assetId) end
			end)
		end
		LocalPlayer.CharacterAdded:Connect(function(char)
			if AvatarMorph.Enabled then
				task.wait(0.5)
				AvatarMorph.Originals = nil
				saveOriginalAvatar(char)
				applyAvatarMorph(AvatarMorph.UserId)
			end
			char.ChildAdded:Connect(function(child) if child:IsA("Accessory") then refreshAccessoryDropdown(char) end end)
			char.ChildRemoved:Connect(function(child) if child:IsA("Accessory") then refreshAccessoryDropdown(char) end end)
			refreshAccessoryDropdown(char)
		end)
		if LocalPlayer.Character then
			LocalPlayer.Character.ChildAdded:Connect(function(child) if child:IsA("Accessory") then refreshAccessoryDropdown(LocalPlayer.Character) end end)
			LocalPlayer.Character.ChildRemoved:Connect(function(child) if child:IsA("Accessory") then refreshAccessoryDropdown(LocalPlayer.Character) end end)
			refreshAccessoryDropdown(LocalPlayer.Character)
		end
	end
end

-- Gun Material
do
	local GunMaterial = {Enabled = false, Material = "Neon", Color = Color3.fromRGB(255, 0, 0), OriginalData = {}}
	local function StoreOriginalData(part)
		if not GunMaterial.OriginalData[part] then
			GunMaterial.OriginalData[part] = {Material = part.Material, Color = part.Color, TextureID = "", Texture = ""}
			local success, textureID = pcall(function() return part.TextureID end)
			if success and textureID then GunMaterial.OriginalData[part].TextureID = textureID end
			local texture = part:FindFirstChildOfClass("Texture")
			if texture and texture.Texture then GunMaterial.OriginalData[part].Texture = texture.Texture end
		end
	end
	local function ApplyGunMaterial(part)
		if not part or not part:IsA("BasePart") then return end
		StoreOriginalData(part)
		pcall(function() part.TextureID = "" end)
		local texture = part:FindFirstChildOfClass("Texture")
		if texture then texture.Texture = "" end
		part.Material = Enum.Material[GunMaterial.Material]
		part.Color = GunMaterial.Color
	end
	local function RestoreOriginalMaterial(part)
		if not part or not part:IsA("BasePart") then return end
		local originalData = GunMaterial.OriginalData[part]
		if originalData then
			part.Material = originalData.Material
			part.Color = originalData.Color
			pcall(function() part.TextureID = originalData.TextureID ~= "" and originalData.TextureID or "" end)
			local texture = part:FindFirstChildOfClass("Texture")
			if texture then texture.Texture = originalData.Texture ~= "" and originalData.Texture or "" end
		end
	end
	local function ProcessGunParts(tool)
		if not tool or not tool:IsA("Tool") then return end
		for _, child in pairs(tool:GetDescendants()) do
			if child:IsA("BasePart") then
				if GunMaterial.Enabled then ApplyGunMaterial(child) else RestoreOriginalMaterial(child) end
			end
		end
	end
	local function UpdateAllGuns()
		if not LocalPlayer.Character then return end
		for _, child in pairs(LocalPlayer.Character:GetChildren()) do
			if child:IsA("Tool") then ProcessGunParts(child) end
		end
		if LocalPlayer.Backpack then
			for _, child in pairs(LocalPlayer.Backpack:GetChildren()) do
				if child:IsA("Tool") then ProcessGunParts(child) end
			end
		end
	end
	getgenv().HoodVisualsUpdateGunMaterial = function()
		GunMaterial.Enabled = library.flags["hood_visuals_gun_material_enabled"] == true
		GunMaterial.Material = library.flags["hood_visuals_gun_material_type"] or "Neon"
		GunMaterial.Color = library.flags["hood_visuals_gun_material_color"] and library.flags["hood_visuals_gun_material_color"].Color or Color3.fromRGB(255, 0, 0)
		UpdateAllGuns()
	end
	local function onToolAdded(tool)
		if tool:IsA("Tool") then task.wait(0.1); ProcessGunParts(tool) end
	end
	local function onToolRemoved(tool)
		if tool:IsA("Tool") then
			for _, child in pairs(tool:GetDescendants()) do
				if child:IsA("BasePart") and GunMaterial.OriginalData[child] then GunMaterial.OriginalData[child] = nil end
			end
		end
	end
	local function onCharacterAdded(character)
		character.ChildAdded:Connect(onToolAdded)
		character.ChildRemoved:Connect(onToolRemoved)
		task.wait(1)
		UpdateAllGuns()
	end
	if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
	LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
	LocalPlayer.CharacterRemoving:Connect(function() GunMaterial.OriginalData = {} end)
	if LocalPlayer.Backpack then
		LocalPlayer.Backpack.ChildAdded:Connect(onToolAdded)
		LocalPlayer.Backpack.ChildRemoved:Connect(onToolRemoved)
	end
	LocalPlayer.ChildAdded:Connect(function(child)
		if child.Name == "Backpack" then
			child.ChildAdded:Connect(onToolAdded)
			child.ChildRemoved:Connect(onToolRemoved)
		end
	end)
	RunService.Heartbeat:Connect(function()
		if GunMaterial.Enabled then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
				for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
					if tool:IsA("Tool") then
						for _, part in pairs(tool:GetDescendants()) do
							if part:IsA("BasePart") and part.Material ~= Enum.Material[GunMaterial.Material] then
								ProcessGunParts(tool)
								break
							end
						end
					end
				end
			end
		end
	end)
end

-- Aspect Ratio
do
	local AspectRatio = {Enabled = false, ScaleX = 1.0, ScaleY = 1.0, ScaleZ = 1.0, Hook = nil}
	local camera = Workspace.CurrentCamera
	local oldNewindex
	oldNewindex = hookmetamethod(game, "__newindex", function(object, propertyName, propertyValue)
		if object == camera and propertyName == "CFrame" then
			if AspectRatio.Enabled then
				propertyValue = propertyValue * CFrame.new(0, 0, 0, AspectRatio.ScaleX, 0, 0, 0, AspectRatio.ScaleY, 0, 0, 0, AspectRatio.ScaleZ)
			end
		end
		return oldNewindex(object, propertyName, propertyValue)
	end)
	AspectRatio.Hook = oldNewindex
	RunService.Heartbeat:Connect(function()
		AspectRatio.Enabled = library.flags["hood_visuals_aspect_ratio_enabled"] == true
		AspectRatio.ScaleX = library.flags["hood_visuals_aspect_ratio_x"] or 1.0
		AspectRatio.ScaleY = library.flags["hood_visuals_aspect_ratio_y"] or 1.0
		AspectRatio.ScaleZ = library.flags["hood_visuals_aspect_ratio_z"] or 1.0
	end)
end

-- Motion Blur
do
	local Lighting = game:GetService("Lighting")
	local blurEffect = Instance.new('BlurEffect')
	blurEffect.Size = 0
	blurEffect.Enabled = false
	blurEffect.Parent = Lighting
	local LastCamPos = nil
	RunService.RenderStepped:Connect(function(dt)
		local enabled = library.flags["hood_visuals_motion_blur_enabled"] == true
		local blurSize = library.flags["hood_visuals_motion_blur_strength"] or 12
		local blurSpeed = library.flags["hood_visuals_motion_blur_threshold"] or 30
		if enabled then
			local camPos = Camera.CFrame.Position
			local vel = (camPos - (LastCamPos or camPos)).Magnitude / math.max(dt, 0.001)
			LastCamPos = camPos
			local target = math.min(blurSize, vel / math.max(blurSpeed, 1) * blurSize)
			blurEffect.Enabled = true
			blurEffect.Size = blurEffect.Size + (target - blurEffect.Size) * 0.1
		else
			blurEffect.Enabled = false
			blurEffect.Size = 0
			LastCamPos = nil
		end
	end)
end

	-- === MISC LOGIC (ported from evolution_hood.lua) ===
	do
		local UserInputService = game:GetService("UserInputService")
		local HM = getgenv().HoodMisc or {}
		getgenv().HoodMisc = HM

		-- Extend StandConfig with missing fields
		do
			local sc = AutoKill.StandConfig
			sc.FollowConnection = sc.FollowConnection or nil
			sc.ChatConnection = sc.ChatConnection or nil
			sc.StandAttributeConnection = sc.StandAttributeConnection or nil
			sc.IsVanished = sc.IsVanished or false
			sc.BringRunning = sc.BringRunning or false
			sc.FormationMode = sc.FormationMode or "follow"
			sc.OrbitMode = sc.OrbitMode or false
			sc.OrbitAngle = sc.OrbitAngle or 0
			sc.FormationAngle = sc.FormationAngle or 0
			sc.KnockResetConnections = sc.KnockResetConnections or {}
			sc.StandNames = sc.StandNames or {}
			sc.Whitelist = sc.Whitelist or {}
			sc.KnifeAuraMode = sc.KnifeAuraMode or false
			sc.KillAuraMode = sc.KillAuraMode or false
			if sc.FormationAngle == 0 then
				local seed = 0
				for i = 1, #LocalPlayer.Name do seed = seed + string.byte(LocalPlayer.Name, i) end
				sc.FormationAngle = (seed % 360) * (math.pi / 180)
			end
		end

		-- Stand helpers
		function AutoKill.SetStandAttribute()
			local char = LocalPlayer.Character
			if char then pcall(function() char:SetAttribute("IsStand", true) end) end
		end

		function AutoKill.ForceResetCharacter()
			if MainEvent then pcall(function() MainEvent:FireServer("Reset") end) end
			pcall(function() LocalPlayer:LoadCharacter() end)
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then pcall(function() hum.Health = 0 end) end
				pcall(function() char:BreakJoints() end)
			end
		end

		function AutoKill.SetupStandCharacter(char)
			AutoKill.SetStandAttribute()
			for _, c in ipairs(AutoKill.StandConfig.KnockResetConnections or {}) do pcall(function() c:Disconnect() end) end
			AutoKill.StandConfig.KnockResetConnections = {}
			local function track(conn) table.insert(AutoKill.StandConfig.KnockResetConnections, conn) end
			local function onKnocked() AutoKill.ForceResetCharacter() end
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			if humanoid then track(humanoid.Died:Connect(onKnocked)) end
			local function hookKO(ko)
				track(ko:GetPropertyChangedSignal("Value"):Connect(function()
					if ko.Value == true then onKnocked() end
				end))
			end
			local be = char and char:FindFirstChild("BodyEffects")
			local ko = be and be:FindFirstChild("K.O")
			if ko then hookKO(ko) end
			if be then
				track(be.ChildAdded:Connect(function(child)
					if child.Name == "K.O" and child:IsA("BoolValue") then hookKO(child) end
				end))
			elseif char then
				track(char.ChildAdded:Connect(function(child)
					if child.Name == "BodyEffects" then
						local ko2 = child:FindFirstChild("K.O")
						if ko2 then hookKO(ko2) end
						track(child.ChildAdded:Connect(function(c2)
							if c2.Name == "K.O" and c2:IsA("BoolValue") then hookKO(c2) end
						end))
					end
				end))
			end
		end

		-- Use Stand logic
		do
			local function findStandPlayer(name)
				if not name or name == "" then return nil end
				local lower = name:lower()
				for _, p in ipairs(Players:GetPlayers()) do
					if p.Name:lower():find(lower, 1, true) or (p.DisplayName and p.DisplayName:lower():find(lower, 1, true)) then
						return p
					end
				end
				return nil
			end
			local function findStandTarget(name)
				if not name or name == "" then return nil end
				local lower = name:lower()
				for _, p in ipairs(Players:GetPlayers()) do
					if p == LocalPlayer then continue end
					if p.Name:lower():find(lower, 1, true) or (p.DisplayName and p.DisplayName:lower():find(lower, 1, true)) then
						return p
					end
				end
				return nil
			end
			local function getCircleOffset(angle, distance)
				return CFrame.new(math.sin(angle) * distance, 0, math.cos(angle) * distance)
			end
			local function getOwnerCircleCFrame(distance)
				local owner = AutoKill.StandConfig.OwnerPlayer
				if not owner or not owner.Character then return nil end
				local ownerRoot = owner.Character:FindFirstChild("HumanoidRootPart")
				if not ownerRoot then return nil end
				local angle = AutoKill.StandConfig.FormationAngle
				if AutoKill.StandConfig.OrbitMode then angle = angle + AutoKill.StandConfig.OrbitAngle end
				local dist = distance + math.sin(angle * 5) * 2.5
				return CFrame.new(ownerRoot.Position) * getCircleOffset(angle, dist)
			end
			local function bringPlayerToOwner(target, owner)
				if AutoKill.StandConfig.BringRunning then return end
				AutoKill.StandConfig.BringRunning = true
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myRoot then AutoKill.StandConfig.BringRunning = false return end
				AutoKill.SetTargetList({target.Name})
				AutoKill.Enabled = true
				AutoKill.StartCycle()
				local timeout = tick() + 8
				while tick() < timeout do
					local tc = target.Character
					local be = tc and tc:FindFirstChild("BodyEffects")
					local ko = be and be:FindFirstChild("K.O")
					local dead = be and be:FindFirstChild("Dead")
					if (ko and ko.Value) or (dead and dead.Value) then break end
					task.wait(0.1)
				end
				AutoKill.Enabled = false
				AutoKill.Target = nil
				AutoKill.StopCycle()
				local tc = target.Character
				local tRoot = tc and tc:FindFirstChild("HumanoidRootPart")
				local oc = owner.Character
				local oRoot = oc and oc:FindFirstChild("HumanoidRootPart")
				if tRoot and oRoot then
					myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.5)
					task.wait(0.1)
					local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
					if mainEvent then
						local grabAttempts = {{"Grabbing", true}, {"Grab", target}, {"Grab", target.Character}, {"PickUp", target}, {"PickUp", target.Character}, {"Carry", target}, {"Carry", target.Character}}
						for _, args in ipairs(grabAttempts) do
							pcall(function() mainEvent:FireServer(unpack(args)) end)
							task.wait(0.05)
						end
					end
					for i = 1, 15 do
						myRoot.CFrame = oRoot.CFrame * CFrame.new(0, 0, 3)
						task.wait(0.05)
					end
					if mainEvent then pcall(function() mainEvent:FireServer("Grabbing", false) end) end
				end
				AutoKill.StandConfig.BringRunning = false
			end
			local function handleStandCommand(msg, sender)
				if sender ~= AutoKill.StandConfig.OwnerPlayer then return end
				local args = msg:split(" ")
				local cmd = args[1] and args[1]:lower()
				if not cmd then return end
				if cmd == ".godmode" then
					if getgenv().AnimGodmode then
						local enabled = not getgenv().AnimGodmode.IsEnabled()
						getgenv().AnimGodmode.Set(enabled)
					end
				elseif cmd == ".ak" then
					local targetName = args[2]
					if not targetName then return end
					local target = findStandTarget(targetName)
					if target then
						AutoKill.StandConfig.IsVanished = false
						AutoKill.UnhideCharacter()
						AutoKill.SetTargetList({target.Name})
						AutoKill.Enabled = true
						AutoKill.StartCycle()
					end
				elseif cmd == ".method" then
					local method = args[2] and args[2]:lower()
					if method == "knife" then
						AutoKill.Method = "Knife"
						AutoKill.StopCycle()
						if AutoKill.Enabled then AutoKill.StartCycle() end
					elseif method == "gun" then
						AutoKill.Method = "Gun"
						AutoKill.StopCycle()
						if AutoKill.Enabled then AutoKill.StartCycle() end
					end
				elseif cmd == ".vanish" then
					AutoKill.StandConfig.IsVanished = true
					AutoKill.HideCharacter()
				elseif cmd == ".unvanish" then
					AutoKill.StandConfig.IsVanished = false
					AutoKill.UnhideCharacter()
				elseif cmd == ".bring" then
					local targetName = args[2]
					if not targetName then return end
					local target = findStandTarget(targetName)
					local owner = AutoKill.StandConfig.OwnerPlayer
					if target and owner then
						AutoKill.StandConfig.IsVanished = false
						AutoKill.UnhideCharacter()
						task.spawn(function() bringPlayerToOwner(target, owner) end)
					end
				elseif cmd == ".formation" then
					local mode = args[2] and args[2]:lower()
					if mode == "circle" or mode == "surround" or mode == "follow" then
						AutoKill.StandConfig.FormationMode = mode
					else
						local modes = {"follow", "circle", "surround"}
						local current = table.find(modes, AutoKill.StandConfig.FormationMode) or 1
						AutoKill.StandConfig.FormationMode = modes[(current % #modes) + 1]
					end
				elseif cmd == ".knifeaura" then
					local enabled = not AutoKill.StandConfig.KnifeAuraMode
					AutoKill.StandConfig.KnifeAuraMode = enabled
					AutoKill.StandConfig.KillAuraMode = false
					AutoKill.StandConfig.IsVanished = false
					AutoKill.UnhideCharacter()
					if enabled then
						AutoKill.Method = "Knife"
						AutoKill.KnifeAura = true
						AutoKill.Enabled = true
						AutoKill.StopCycle()
						AutoKill.StartCycle()
					else
						AutoKill.KnifeAura = false
						AutoKill.Enabled = false
						AutoKill.StopCycle()
					end
				elseif cmd == ".killaura" then
					local enabled = not AutoKill.StandConfig.KillAuraMode
					AutoKill.StandConfig.KillAuraMode = enabled
					AutoKill.StandConfig.KnifeAuraMode = false
					AutoKill.KnifeAura = false
					AutoKill.StandConfig.IsVanished = false
					AutoKill.UnhideCharacter()
					if enabled then
						AutoKill.Method = "Gun"
						AutoKill.Enabled = true
						AutoKill.StopCycle()
						AutoKill.StartCycle()
					else
						AutoKill.Enabled = false
						AutoKill.Target = nil
						AutoKill.StopCycle()
					end
				elseif cmd == ".orbit" then
					AutoKill.StandConfig.OrbitMode = not AutoKill.StandConfig.OrbitMode
				elseif cmd == ".stands" then
					local names = {}
					for i = 2, #args do
						for name in args[i]:gmatch("([^,]+)") do
							name = name:match("^%s*(.-)%s*$")
							if name ~= "" then names[name:lower()] = true end
						end
					end
					AutoKill.StandConfig.StandNames = names
					if AutoKill.StandConfig.OwnerName ~= "" then
						AutoKill.StandConfig.OwnerPlayer = findStandPlayer(AutoKill.StandConfig.OwnerName)
					end
				elseif cmd == ".whitelist" then
					local list = AutoKill.StandConfig.Whitelist
					for i = 2, #args do
						for name in args[i]:gmatch("([^,]+)") do
							name = name:match("^%s*(.-)%s*$")
							if name ~= "" then list[name:lower()] = true end
						end
					end
				elseif cmd == ".unwhitelist" then
					local list = AutoKill.StandConfig.Whitelist
					for i = 2, #args do
						for name in args[i]:gmatch("([^,]+)") do
							name = name:match("^%s*(.-)%s*$")
							if name ~= "" then list[name:lower()] = nil end
						end
					end
				elseif cmd == ".stop" then
					AutoKill.Enabled = false
					AutoKill.Target = nil
					AutoKill.KnifeAura = false
					AutoKill.StopCycle()
					AutoKill.UnhideCharacter()
					AutoKill.StandConfig.KnifeAuraMode = false
					AutoKill.StandConfig.KillAuraMode = false
				end
			end
			local function startStand()
				if AutoKill.StandConfig.ChatConnection then return end
				AutoKill.StandConfig.ChatConnection = TextChatService.MessageReceived:Connect(function(msgObj)
					if not AutoKill.StandConfig.Enabled then return end
					local textSource = msgObj and msgObj.TextSource
					if not textSource then return end
					local sender = Players:GetPlayerByUserId(textSource.UserId)
					if not sender or sender == LocalPlayer then return end
					if not AutoKill.StandConfig.OwnerPlayer then
						AutoKill.StandConfig.OwnerPlayer = findStandPlayer(AutoKill.StandConfig.OwnerName)
					end
					handleStandCommand(msgObj.Text or "", sender)
				end)
				if AutoKill.StandConfig.FollowConnection then return end
				AutoKill.StandConfig.FollowConnection = RunService.Heartbeat:Connect(function(dt)
					local sc = AutoKill.StandConfig
					if not sc.Enabled or sc.IsVanished or sc.BringRunning or AutoKill.GunMethod.StompRunning then return end
					if not sc.OwnerPlayer then sc.OwnerPlayer = findStandPlayer(sc.OwnerName) end
					local owner = sc.OwnerPlayer
					if not owner or not owner.Character then return end
					local ownerRoot = owner.Character:FindFirstChild("HumanoidRootPart")
					local myChar = LocalPlayer.Character
					local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
					if not ownerRoot or not myRoot then return end
					if sc.OrbitMode then
						dt = dt or (1 / 60)
						sc.OrbitAngle = (sc.OrbitAngle + 2 * dt) % (math.pi * 2)
					end
					local targetCFrame
					if sc.KillAuraMode then
						targetCFrame = getOwnerCircleCFrame(18)
					elseif sc.KnifeAuraMode then
						local auraTarget = AutoKill.AuraLockedTarget
						if not auraTarget or not auraTarget.Character then
							auraTarget = AutoKill.GetNearestEnemyToOwner()
							if auraTarget then AutoKill.AuraLockedTarget = auraTarget end
						end
						if auraTarget and auraTarget.Character then
							local troot = auraTarget.Character:FindFirstChild("HumanoidRootPart")
							if troot then
								local angle = sc.FormationAngle
								local dist = 7 + math.sin(angle * 5) * 1.5
								local yOff = math.sin(angle * 3) * 1.5
								local offset = CFrame.new(math.sin(angle) * dist, yOff, math.cos(angle) * dist)
								targetCFrame = troot.CFrame * offset
								targetCFrame = CFrame.lookAt(targetCFrame.Position, troot.Position)
							else
								targetCFrame = getOwnerCircleCFrame(12)
							end
						else
							targetCFrame = getOwnerCircleCFrame(12)
						end
					elseif sc.FormationMode == "circle" or sc.FormationMode == "surround" then
						if AutoKill.Enabled and AutoKill.Target then return end
						targetCFrame = getOwnerCircleCFrame(10)
					else
						if AutoKill.Enabled and AutoKill.Target then return end
						targetCFrame = ownerRoot.CFrame * CFrame.new(0, 0, 8)
					end
					if targetCFrame then
						myRoot.CFrame = targetCFrame
						myRoot.AssemblyLinearVelocity = Vector3.zero
						myRoot.AssemblyAngularVelocity = Vector3.zero
					end
				end)
			end
			local function stopStand()
				local sc = AutoKill.StandConfig
				if sc.ChatConnection then sc.ChatConnection:Disconnect() sc.ChatConnection = nil end
				if sc.FollowConnection then sc.FollowConnection:Disconnect() sc.FollowConnection = nil end
				for _, c in ipairs(sc.KnockResetConnections or {}) do pcall(function() c:Disconnect() end) end
				sc.KnockResetConnections = {}
			end
			HM.StartStand = function()
				local enabled = library.flags["hood_misc_usestand_enabled"] == true
				local ownerName = library.flags["hood_misc_usestand_owner"] or ""
				local whitelistText = library.flags["hood_misc_usestand_whitelist"] or ""
				AutoKill.StandConfig.Enabled = enabled
				AutoKill.StandConfig.OwnerName = ownerName
				local list = {}
				for name in whitelistText:gmatch("([^,]+)") do
					name = name:match("^%s*(.-)%s*$")
					if name ~= "" then list[name:lower()] = true end
				end
				AutoKill.StandConfig.Whitelist = list
				if enabled then
					AutoKill.StandConfig.OwnerPlayer = findStandPlayer(ownerName)
					startStand()
					AutoKill.SetupStandCharacter(LocalPlayer.Character)
					if AutoKill.StandConfig.StandAttributeConnection then pcall(function() AutoKill.StandConfig.StandAttributeConnection:Disconnect() end) end
					AutoKill.StandConfig.StandAttributeConnection = LocalPlayer.CharacterAdded:Connect(function(char)
						task.wait(0.5)
						AutoKill.SetupStandCharacter(char)
					end)
				else
					stopStand()
					if AutoKill.StandConfig.StandAttributeConnection then
						pcall(function() AutoKill.StandConfig.StandAttributeConnection:Disconnect() end)
						AutoKill.StandConfig.StandAttributeConnection = nil
					end
				end
			end
			HM.StopStand = stopStand
		end

		-- CFrame Speed
		task.spawn(function()
			while task.wait(0) do
				local enabled = library.flags["hood_misc_cframe_speed_enabled"] == true
				local bind = library.flags["hood_misc_cframe_speed_bind"]
				if enabled and bind and bind.active then
					local char = LocalPlayer.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hum and hrp and hum.MoveDirection.Magnitude > 0 then
						local speed = library.flags["hood_misc_cframe_speed"] or 10
						hrp.CFrame = hrp.CFrame + hum.MoveDirection * (speed / 20)
					end
				end
			end
		end)

		-- Jump Power
		RunService.RenderStepped:Connect(function()
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if not hum then return end
			hum.JumpPower = library.flags["hood_misc_jump_power_enabled"] == true and (library.flags["hood_misc_jump_power"] or 50) or 50
		end)

		-- Flight
		do
			local flightConn
			local function createCore()
				local existing = workspace:FindFirstChild("HoodMiscFlightCore")
				if existing then existing:Destroy() end
				local core = Instance.new("Part")
				core.Name = "HoodMiscFlightCore"
				core.Size = Vector3.new(0.05, 0.05, 0.05)
				core.CanCollide = false
				core.Transparency = 1
				core.Parent = workspace
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local weld = Instance.new("Weld", core)
					weld.Part0 = core
					weld.Part1 = hrp
					weld.C0 = CFrame.new(0, 0, 0)
				end
				return core
			end
			local function startFly()
				if getgenv().HoodMiscFlying then return end
				getgenv().HoodMiscFlying = true
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then hum.PlatformStand = true end
				local core = createCore()
				local bv = Instance.new("BodyVelocity", core)
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				bv.Velocity = Vector3.zero
				local bg = Instance.new("BodyGyro", core)
				bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
				bg.P = 9e4
				bg.CFrame = core.CFrame
				flightConn = RunService.RenderStepped:Connect(function()
					if not getgenv().HoodMiscFlying then return end
					local cam = workspace.CurrentCamera
					local move = Vector3.zero
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
					bv.Velocity = move * (library.flags["hood_misc_fly_speed"] or 50)
					bg.CFrame = cam.CFrame
				end)
			end
			local function stopFly()
				if not getgenv().HoodMiscFlying then return end
				getgenv().HoodMiscFlying = false
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then hum.PlatformStand = false end
				if flightConn then flightConn:Disconnect() flightConn = nil end
				local core = workspace:FindFirstChild("HoodMiscFlightCore")
				if core then core:Destroy() end
			end
			RunService.RenderStepped:Connect(function()
				local enabled = library.flags["hood_misc_flight_enabled"] == true
				local bind = library.flags["hood_misc_flight_bind"]
				local active = bind and bind.active
				if enabled and active and not getgenv().HoodMiscFlying then
					startFly()
				elseif (not enabled or not active) and getgenv().HoodMiscFlying then
					stopFly()
				end
			end)
		end

		-- Spin Bot
		RunService.Heartbeat:Connect(function(dt)
			if library.flags["hood_misc_spin_bot_enabled"] == true then
				local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if root then
					local speed = library.flags["hood_misc_spin_bot_speed"] or 50
					root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed * 360 * dt), 0)
				end
			end
		end)

		-- Infinite Jump
		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if library.flags["hood_misc_infinite_jump_enabled"] == true and input.KeyCode == Enum.KeyCode.Space then
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
			end
		end)
		RunService.Heartbeat:Connect(function()
			if library.flags["hood_misc_infinite_jump_enabled"] == true then
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
				end
			end
		end)

		-- Auto Reload
		do
			local GUN_NAMES = {["[Revolver]"] = true, ["[DoubleBarrel]"] = true, ["[TacticalShotgun]"] = true, ["[SMG]"] = true, ["[Shotgun]"] = true, ["[Silencer]"] = true, ["[Flintlock]"] = true}
			local lastReload = 0
			local autoReloadConnection = nil
			local function isReloading(char)
				local be = char and char:FindFirstChild("BodyEffects")
				local r = be and (be:FindFirstChild("Reloading") or be:FindFirstChild("Reloading_CLIENT"))
				return r and r.Value
			end
			local function getAmmo(tool)
				local s = tool and tool:FindFirstChild("Script")
				local a = s and s:FindFirstChild("Ammo")
				if a and a:IsA("IntValue") then return a.Value end
				return nil
			end
			local function startAutoReload()
				if autoReloadConnection then autoReloadConnection:Disconnect() end
				autoReloadConnection = RunService.RenderStepped:Connect(function()
					local char = LocalPlayer.Character
					if not char then return end
					local tool = char:FindFirstChildOfClass("Tool")
					if not tool or not GUN_NAMES[tool.Name] then return end
					local ammo = getAmmo(tool)
					if ammo and ammo <= 0 and not isReloading(char) and tick() - lastReload >= 1.1 then
						lastReload = tick()
						pcall(function()
							local me = ReplicatedStorage:WaitForChild("MainEvent", 1)
							if me then me:FireServer("Reload") end
						end)
					end
				end)
			end
			local function stopAutoReload()
				if autoReloadConnection then autoReloadConnection:Disconnect() autoReloadConnection = nil end
			end
			local lastReloadState = false
			RunService.Heartbeat:Connect(function()
				local enabled = library.flags["hood_misc_auto_reload"] == true
				if enabled and not lastReloadState then
					startAutoReload()
				elseif not enabled and lastReloadState then
					stopAutoReload()
				end
				lastReloadState = enabled
			end)
		end

		-- Force Reset
		do
			local function forceResetCharacter()
				local char = LocalPlayer.Character
				if not char then return end
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end
				pcall(function()
					humanoid.PlatformStand = false
					humanoid.Sit = false
					humanoid.Health = 0
				end)
			end
			local function isKnocked()
				local char = LocalPlayer.Character
				if not char then return false end
				local be = char:FindFirstChild("BodyEffects")
				if not be then return false end
				local ko = be:FindFirstChild("K.O")
				return ko and ko.Value == true
			end
			local forceResetConnection = nil
			local function startForceResetLoop()
				stopForceResetLoop()
				forceResetConnection = RunService.Heartbeat:Connect(function()
					if library.flags["hood_misc_force_reset"] == true and isKnocked() then
						forceResetCharacter()
					end
				end)
			end
			local function stopForceResetLoop()
				if forceResetConnection then forceResetConnection:Disconnect() forceResetConnection = nil end
			end
			local lastForceResetState = false
			RunService.Heartbeat:Connect(function()
				local enabled = library.flags["hood_misc_force_reset"] == true
				if enabled and not lastForceResetState then
					forceResetCharacter()
					startForceResetLoop()
				elseif not enabled and lastForceResetState then
					stopForceResetLoop()
				end
				lastForceResetState = enabled
			end)
		end

		-- Chat Spy
		do
			local ChatSpy = {Enabled = false, OriginalSize = nil, Loop = nil}
			local function getChatAppLayout()
				local expChat = CoreGui:FindFirstChild("ExperienceChat")
				if expChat then return expChat:FindFirstChild("appLayout") end
			end
			local function setChatWindow(enabled)
				if enabled then
					TextChatService.ChatWindowConfiguration.Enabled = true
					task.spawn(function()
						local app = getChatAppLayout()
						local waited = 0
						while not app and waited < 5 do
							task.wait(0.1)
							waited = waited + 0.1
							app = getChatAppLayout()
						end
						if app and ChatSpy.Enabled then
							if not ChatSpy.OriginalSize then ChatSpy.OriginalSize = app.Size end
							app.Size = UDim2.new(app.Size.X.Scale, app.Size.X.Offset, 0.6, 0)
							app.Visible = true
						end
					end)
					if ChatSpy.Loop then pcall(function() ChatSpy.Loop:Disconnect() end) end
					ChatSpy.Loop = RunService.Heartbeat:Connect(function()
						if not ChatSpy.Enabled then
							pcall(function() ChatSpy.Loop:Disconnect() end)
							ChatSpy.Loop = nil
							return
						end
						local app = getChatAppLayout()
						if app then
							app.Visible = true
							local target = UDim2.new(app.Size.X.Scale, app.Size.X.Offset, 0.6, 0)
							if app.Size ~= target then app.Size = target end
						end
					end)
				else
					if ChatSpy.Loop then pcall(function() ChatSpy.Loop:Disconnect() end) ChatSpy.Loop = nil end
					TextChatService.ChatWindowConfiguration.Enabled = false
					local app = getChatAppLayout()
					if app and ChatSpy.OriginalSize then app.Size = ChatSpy.OriginalSize end
				end
			end
			local lastChatSpyState = false
			RunService.Heartbeat:Connect(function()
				local enabled = library.flags["hood_misc_chat_spy"] == true
				if enabled ~= lastChatSpyState then
					ChatSpy.Enabled = enabled
					setChatWindow(enabled)
					lastChatSpyState = enabled
				end
			end)
		end

		-- Auto Food
		do
			local lastBuy = 0
			local buyCooldown = 0.5
			local lastEat = 0
			local eatCooldown = 0.5
			local lastFoodIndex = 0
			local cachedFoodItems = nil
			local lastCacheUpdate = 0
			local foodNames = {"[Burger]", "[Taco]", "[Pizza]", "[Chicken]", "[Candy Basket]"}
			local function isFoodTool(name)
				for _, n in ipairs(foodNames) do if name == n then return true end end
				return false
			end
			local function getSelectedFoodList()
				local selected = library.flags["hood_misc_food_items"]
				local list = {}
				if typeof(selected) == "table" then
					for _, name in ipairs(selected) do table.insert(list, name) end
				end
				return list
			end
			local function updateFoodCache()
				if tick() - lastCacheUpdate < 2 and cachedFoodItems then return cachedFoodItems end
				local shop = Workspace:FindFirstChild("FFA_MAP") and Workspace.FFA_MAP:FindFirstChild("Shop")
				cachedFoodItems = {}
				if shop then
					for _, obj in ipairs(shop:GetChildren()) do
						if obj.Name:match("Grab") then
							local head = obj:FindFirstChild("Head")
							local cd = obj:FindFirstChild("ClickDetector")
							if head and cd then
								local cleanName = obj.Name:gsub("Grab %- ", "")
								cachedFoodItems[cleanName] = cd
							end
						end
					end
				end
				lastCacheUpdate = tick()
				return cachedFoodItems
			end
			local function hasFood(name)
				local char = LocalPlayer.Character
				if not char then return false end
				for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name == name then return true end end
				for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name == name then return true end end
				return false
			end
			local function buyFood(name)
				local items = updateFoodCache()
				local cd = items[name]
				if cd and cd.Parent then
					pcall(function() fireclickdetector(cd) end)
					return true
				end
				return false
			end
			local function tryEatTool(tool)
				if not tool then return false end
				local char = LocalPlayer.Character
				if not char then return false end
				if tool.Parent == LocalPlayer.Backpack then tool.Parent = char end
				pcall(function() tool:Activate() end)
				return true
			end
			local function eatFood()
				local char = LocalPlayer.Character
				if not char then return false end
				for _, t in ipairs(char:GetChildren()) do
					if t:IsA("Tool") and isFoodTool(t.Name) then return tryEatTool(t) end
				end
				for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
					if t:IsA("Tool") and isFoodTool(t.Name) then return tryEatTool(t) end
				end
				return false
			end
			RunService.Heartbeat:Connect(function()
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not char or not hum then return end
				local now = tick()
				local eatToggle = library.flags["hood_misc_auto_eat"] == true
				local eatHealth = library.flags["hood_misc_eat_health"] or 50
				if eatToggle and hum.Health > 0 and now - lastEat >= eatCooldown then
					local pct = hum.MaxHealth > 0 and (hum.Health / hum.MaxHealth * 100) or 100
					if pct <= eatHealth then
						if eatFood() then lastEat = now end
					end
				end
				local buyToggle = library.flags["hood_misc_auto_buy_food"] == true
				if buyToggle and now - lastBuy >= buyCooldown then
					local selectedList = getSelectedFoodList()
					if #selectedList > 0 then
						local startIndex = lastFoodIndex
						repeat
							lastFoodIndex = (lastFoodIndex % #selectedList) + 1
							local foodName = selectedList[lastFoodIndex]
							if not hasFood(foodName) then
								if buyFood(foodName) then lastBuy = now end
								break
							end
						until lastFoodIndex == startIndex
					end
				end
			end)
		end

		-- Animation Player
		do
			local AnimationPlayer = {Enabled = false, LoopEmote = false, CurrentEmote = "Ice Spice", EmoteSpeed = 1, CustomId = "", CurrentTrack = nil}
			local EmoteAnimationIds = {
				["Ice Spice"] = "rbxassetid://99558490932154",
				["Crip Walk"] = "rbxassetid://110204898807330",
				["Slow-Mo BackFlip"] = "rbxassetid://83263981931146",
				["Shuffle"] = "rbxassetid://118468821959324",
				["Coffin"] = "rbxassetid://126771729094882",
				["Cat"] = "rbxassetid://127118661424463",
				["Happier Jump"] = "rbxassetid://15609995579",
				["Bouncy Twirl"] = "rbxassetid://14352343065",
				["V Pose"] = "rbxassetid://10214319518",
				["Moonwalk"] = "rbxassetid://507766506",
				["Silly Dance"] = "rbxassetid://507767413",
				["Shuffling"] = "rbxassetid://507767263",
				["Hula Dance"] = "rbxassetid://507766023",
				["Gangnam Style"] = "rbxassetid://507765756",
				["Macarena"] = "rbxassetid://507766248",
			}
			local function StopEmote()
				if AnimationPlayer.CurrentTrack then
					AnimationPlayer.CurrentTrack:Stop()
					AnimationPlayer.CurrentTrack = nil
				end
			end
			local function PlayEmote(animId, loop, speed)
				local character = LocalPlayer.Character
				if not character then return end
				StopEmote()
				if not animId or animId == "" then return end
				if tonumber(animId) then animId = "rbxassetid://" .. animId end
				local anim = Instance.new("Animation")
				anim.AnimationId = animId
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end
				local animTrack = humanoid:LoadAnimation(anim)
				AnimationPlayer.CurrentTrack = animTrack
				animTrack:Play()
				animTrack.Looped = loop
				animTrack:AdjustSpeed(speed)
				if not loop then
					local connection
					connection = animTrack.Stopped:Connect(function()
						if AnimationPlayer.CurrentTrack == animTrack then AnimationPlayer.CurrentTrack = nil end
						connection:Disconnect()
					end)
				end
				return animTrack
			end
			local function GetCurrentAnimId()
				local custom = library.flags["hood_misc_animation_custom_id"] or ""
				if custom ~= "" then return custom end
				local emote = library.flags["hood_misc_animation_emote"] or "Ice Spice"
				return EmoteAnimationIds[emote]
			end
			local function UpdateEmote()
				AnimationPlayer.Enabled = library.flags["hood_misc_animation_enabled"] == true
				AnimationPlayer.LoopEmote = library.flags["hood_misc_animation_loop"] == true
				AnimationPlayer.CurrentEmote = library.flags["hood_misc_animation_emote"] or "Ice Spice"
				AnimationPlayer.EmoteSpeed = library.flags["hood_misc_animation_speed"] or 1
				if not AnimationPlayer.Enabled then StopEmote() return end
				PlayEmote(GetCurrentAnimId(), AnimationPlayer.LoopEmote, AnimationPlayer.EmoteSpeed)
			end
			HM.UpdateEmote = UpdateEmote
			HM.StopEmote = StopEmote
			LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.5)
				if AnimationPlayer.Enabled then UpdateEmote() end
			end)
		end

		-- Animated Tools
		do
			local AnimatedToolsTools = {}
			local AnimatedToolsOriginalGrips = {}
			local AnimatedToolsConnection = nil
			local AnimatedToolsToolAddedConn = nil
			local AnimatedToolsToolRemovedConn = nil
			local AnimatedToolsCharAddedConn = nil
			local function AddAnimatedTool(tool)
				if not tool or not tool:IsA("Tool") then return end
				local handle = tool:FindFirstChild("Handle")
				if not handle then return end
				if AnimatedToolsOriginalGrips[handle] then return end
				AnimatedToolsOriginalGrips[handle] = tool.Grip
				AnimatedToolsTools[handle] = tool
			end
			local function RestoreAllGrips()
				for handle, grip in pairs(AnimatedToolsOriginalGrips) do
					local tool = AnimatedToolsTools[handle]
					if tool and tool.Parent then
						pcall(function() tool.Grip = grip end)
					end
				end
				AnimatedToolsOriginalGrips = {}
				AnimatedToolsTools = {}
			end
			local function AddCurrentTool()
				local char = LocalPlayer.Character
				if not char then return end
				for _, child in ipairs(char:GetChildren()) do AddAnimatedTool(child) end
			end
			local function ConnectToolEvents(char)
				if AnimatedToolsToolAddedConn then AnimatedToolsToolAddedConn:Disconnect() AnimatedToolsToolAddedConn = nil end
				if AnimatedToolsToolRemovedConn then AnimatedToolsToolRemovedConn:Disconnect() AnimatedToolsToolRemovedConn = nil end
				AnimatedToolsToolAddedConn = char.ChildAdded:Connect(function(child) AddAnimatedTool(child) end)
				AnimatedToolsToolRemovedConn = char.ChildRemoved:Connect(function(child)
					if not child:IsA("Tool") then return end
					local handle = child:FindFirstChild("Handle")
					if not handle then return end
					if AnimatedToolsOriginalGrips[handle] then
						pcall(function() child.Grip = AnimatedToolsOriginalGrips[handle] end)
						AnimatedToolsOriginalGrips[handle] = nil
						AnimatedToolsTools[handle] = nil
					end
				end)
			end
			local function UpdateAnimatedTools()
				if AnimatedToolsConnection then AnimatedToolsConnection:Disconnect() AnimatedToolsConnection = nil end
				if AnimatedToolsToolAddedConn then AnimatedToolsToolAddedConn:Disconnect() AnimatedToolsToolAddedConn = nil end
				if AnimatedToolsToolRemovedConn then AnimatedToolsToolRemovedConn:Disconnect() AnimatedToolsToolRemovedConn = nil end
				if AnimatedToolsCharAddedConn then AnimatedToolsCharAddedConn:Disconnect() AnimatedToolsCharAddedConn = nil end
				RestoreAllGrips()
				if not library.flags["hood_misc_animated_tools_enabled"] == true then return end
				local char = LocalPlayer.Character
				if char then
					for _, child in ipairs(char:GetChildren()) do AddAnimatedTool(child) end
					ConnectToolEvents(char)
				end
				AnimatedToolsConnection = RunService.Heartbeat:Connect(function(dt)
					local hMode = library.flags["hood_misc_animated_tools_horizontal"] or "sine spin"
					local vMode = library.flags["hood_misc_animated_tools_vertical"] or "sine spin"
					local hSpeed = (library.flags["hood_misc_animated_tools_horizontal_speed"] or 10) / 4
					local vSpeed = (library.flags["hood_misc_animated_tools_vertical_speed"] or 10) / 4
					local horizontal = 0
					if hMode == "sine spin" then horizontal = math.sin(os.clock()) * 45
					elseif hMode == "random" then horizontal = (math.random() * 2 - 1) * 180
					elseif hMode == "jitter" then horizontal = math.random(-10, 10)
					elseif hMode == "spin" or hMode == "character spin" then horizontal = 45 end
					local vertical = 0
					if vMode == "sine spin" then vertical = math.sin(os.clock()) * 45
					elseif vMode == "random" then vertical = (math.random() * 2 - 1) * 180
					elseif vMode == "jitter" then vertical = math.random(-10, 10)
					elseif vMode == "spin" or vMode == "character spin" then vertical = 45 end
					for handle, tool in pairs(AnimatedToolsTools) do
						if tool and tool.Parent then
							pcall(function()
								tool.Grip = tool.Grip * CFrame.Angles(math.rad(vertical * dt * vSpeed), math.rad(horizontal * dt * hSpeed), 0)
							end)
						end
					end
				end)
				AnimatedToolsCharAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
					if not library.flags["hood_misc_animated_tools_enabled"] == true then return end
					task.wait(0.1)
					for _, child in ipairs(newChar:GetChildren()) do AddAnimatedTool(child) end
					ConnectToolEvents(newChar)
				end)
			end
			HM.UpdateAnimatedTools = UpdateAnimatedTools
		end

		-- Skin Changer
		do
			local CONFIG = {Enabled = false, Revolver = "Candy Cane", DoubleBarrel = "Candy Cane", Shotgun = "Ascension", TacticalShotgun = "Ascension", SMG = "Candy Cane", Knife = "Fishbone"}
			local function GetSkinModel(weapon, skin)
				if not skin or skin == "" or skin == "None" then return nil end
				if weapon == "Knife" then
					local knives = ReplicatedStorage:FindFirstChild("Knives")
					if knives then return knives:FindFirstChild(skin) end
					return nil
				end
				local wraps = ReplicatedStorage:FindFirstChild("Wraps")
				if not wraps then return nil end
				local folder = wraps:FindFirstChild("[" .. weapon .. "]")
				if not folder then return nil end
				return folder:FindFirstChild(skin)
			end
			local function RestoreKnifeVisibility(tool)
				for _, part in ipairs(tool:GetDescendants()) do
					if part:IsA("BasePart") then
						local original = part:GetAttribute("KnifeSkin_OriginalLTM")
						if original ~= nil then
							part.LocalTransparencyModifier = original
							part:SetAttribute("KnifeSkin_OriginalLTM", nil)
						end
					end
				end
			end
			local KnifeSkinData = {}
			local function CleanupKnifeAnimations(tool)
				local data = KnifeSkinData[tool]
				if not data or not data.Tracks then return end
				for _, track in ipairs(data.Tracks) do
					pcall(function()
						if typeof(track) == "Instance" and track:IsA("AnimationTrack") and track.Stop then track:Stop() end
					end)
				end
				data.Tracks = nil
			end
			local function RemoveKnifeSkin(tool)
				if not tool then return end
				local data = KnifeSkinData[tool]
				if data then
					if data.Connections then
						for _, c in ipairs(data.Connections) do pcall(function() c:Disconnect() end) end
					end
					CleanupKnifeAnimations(tool)
					if data.Clone and data.Clone.Parent then data.Clone:Destroy() end
					KnifeSkinData[tool] = nil
				end
				RestoreKnifeVisibility(tool)
			end
			local BAD_ADORNMENT_CLASSES = {SelectionBox = true, BoxHandleAdornment = true, SphereHandleAdornment = true, LineHandleAdornment = true, ConeHandleAdornment = true, CylinderHandleAdornment = true, SurfaceSelection = true, ArcHandles = true, Handles = true}
			local function HookKnifeSkinAnimations(tool, clone)
				local data = KnifeSkinData[tool]
				if not data then return end
				if data.Connections then
					for _, c in ipairs(data.Connections) do pcall(function() c:Disconnect() end) end
				end
				data.Connections = {}
				local conns = data.Connections
				for _, d in ipairs(clone:GetDescendants()) do
					if d:IsA("LocalScript") or d:IsA("Script") or d:IsA("ModuleScript") then return end
				end
				local animFolder = Instance.new("Folder")
				animFolder.Name = "KnifeSkinAnimations"
				for _, d in ipairs(clone:GetDescendants()) do
					if d:IsA("Animation") then d:Clone().Parent = animFolder end
				end
				if #animFolder:GetChildren() == 0 then animFolder:Destroy() return end
				animFolder.Parent = clone
				local function getAnimator()
					local char = LocalPlayer.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					local animator = hum and hum:FindFirstChildOfClass("Animator")
					if not animator and hum then
						animator = Instance.new("Animator")
						animator.Parent = hum
					end
					return animator
				end
				local function playAnim(preferredName)
					local animator = getAnimator()
					if not animator then return end
					local anim = animFolder:FindFirstChild(preferredName)
					if not anim then
						for _, fallback in ipairs({"Slash", "Attack", "Stab", "Swing"}) do
							anim = animFolder:FindFirstChild(fallback)
							if anim then break end
						end
					end
					if anim and anim:IsA("Animation") then
						local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
						if ok and track and typeof(track) == "Instance" and track:IsA("AnimationTrack") and track.Play then
							track:Play()
							data.Tracks = data.Tracks or {}
							table.insert(data.Tracks, track)
						end
					end
				end
				table.insert(conns, tool.Equipped:Connect(function()
					CleanupKnifeAnimations(tool)
					local idle = animFolder:FindFirstChild("Idle") or animFolder:FindFirstChild("IdleLoop")
					if idle then
						local animator = getAnimator()
						if animator then
							local ok, track = pcall(function() return animator:LoadAnimation(idle) end)
							if ok and track and typeof(track) == "Instance" and track:IsA("AnimationTrack") and track.Play then
								track.Looped = true
								track:Play()
								data.Tracks = data.Tracks or {}
								table.insert(data.Tracks, track)
							end
						end
					end
				end))
				table.insert(conns, tool.Activated:Connect(function() playAnim("Slash") end))
				table.insert(conns, tool.Unequipped:Connect(function() CleanupKnifeAnimations(tool) end))
				table.insert(conns, tool.AncestryChanged:Connect(function()
					if not tool:IsDescendantOf(LocalPlayer.Character) then RemoveKnifeSkin(tool) end
				end))
			end
			local KnifeSkinWorkspaceFolder
			local function ApplyKnifeSkin(tool, skinModel)
				if not tool or not skinModel then return end
				local char = tool.Parent
				if not char or not char:IsA("Model") or char ~= LocalPlayer.Character then return end
				local originalHandle = tool:FindFirstChild("Handle")
				if not originalHandle or not originalHandle:IsA("BasePart") then return end
				RemoveKnifeSkin(tool)
				for _, part in ipairs(tool:GetDescendants()) do
					if part:IsA("BasePart") then
						if part:GetAttribute("KnifeSkin_OriginalLTM") == nil then part:SetAttribute("KnifeSkin_OriginalLTM", part.LocalTransparencyModifier) end
						part.LocalTransparencyModifier = 1
					end
				end
				if not KnifeSkinWorkspaceFolder or not KnifeSkinWorkspaceFolder.Parent then
					KnifeSkinWorkspaceFolder = Instance.new("Folder")
					KnifeSkinWorkspaceFolder.Name = "HoodMiscKnifeSkinFolder"
					KnifeSkinWorkspaceFolder.Parent = Workspace
				end
				local clone = skinModel:Clone()
				clone.Name = "AppliedKnifeSkin"
				clone.Parent = KnifeSkinWorkspaceFolder
				for _, d in ipairs(clone:GetDescendants()) do
					if BAD_ADORNMENT_CLASSES[d.ClassName] then d:Destroy()
					elseif d:IsA("BasePart") then
						d.CanCollide = false
						d.Anchored = true
						d.Massless = true
					end
				end
				local skinHandle = clone:FindFirstChild("Handle") or clone:FindFirstChildWhichIsA("BasePart")
				if not skinHandle then clone:Destroy() RestoreKnifeVisibility(tool) return end
				clone.PrimaryPart = skinHandle
				skinHandle.Transparency = 0
				local rootOffset = originalHandle.CFrame:Inverse() * skinHandle.CFrame
				skinHandle.CFrame = originalHandle.CFrame * rootOffset
				local function hasInternalJoint(part)
					for _, d in ipairs(clone:GetDescendants()) do
						if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D") then
							local p0, p1 = d.Part0, d.Part1
							if (p0 == part or p1 == part) and ((p0 and p0:IsDescendantOf(clone)) or (p1 and p1:IsDescendantOf(clone))) then return true end
						end
					end
					return false
				end
				for _, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") and part ~= skinHandle and not hasInternalJoint(part) then
						local weld = Instance.new("Weld")
						weld.Part0 = skinHandle
						weld.Part1 = part
						weld.C0 = skinHandle.CFrame:Inverse() * part.CFrame
						weld.Parent = part
					end
				end
				KnifeSkinData[tool] = {Clone = clone, Connections = {}, Tracks = {}}
				table.insert(KnifeSkinData[tool].Connections, RunService.RenderStepped:Connect(function()
					local currentHandle = tool:FindFirstChild("Handle")
					if not currentHandle or not currentHandle:IsA("BasePart") or not tool:IsDescendantOf(LocalPlayer.Character) then
						RemoveKnifeSkin(tool)
						return
					end
					skinHandle.CFrame = currentHandle.CFrame * rootOffset
				end))
				HookKnifeSkinAnimations(tool, clone)
			end
			local function ApplyGunSkin(holder, skinModel)
				if not holder or not skinModel then return end
				local handle = holder:FindFirstChild("Handle")
				if not handle or not handle:IsA("BasePart") then return end
				for _, child in ipairs(holder:GetChildren()) do if child:IsA("Model") then child:Destroy() end end
				local clone = skinModel:Clone()
				local pp = clone:FindFirstChildWhichIsA("BasePart")
				if not pp then return end
				clone:SetPrimaryPartCFrame(handle.CFrame)
				clone.Parent = holder
				handle.Transparency = 1
				for _, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						part.Anchored = false
						if part ~= pp then
							local w = Instance.new("Weld")
							w.Part0 = handle
							w.Part1 = part
							w.C0 = handle.CFrame:Inverse() * part.CFrame
							w.Parent = part
						end
					end
				end
				local w = Instance.new("Weld")
				w.Part0 = handle
				w.Part1 = pp
				w.C0 = handle.CFrame:Inverse() * pp.CFrame
				w.Parent = pp
			end
			local function OnToolAdded(tool)
				CONFIG.Enabled = library.flags["hood_misc_skin_changer_enabled"] == true
				CONFIG.Revolver = library.flags["hood_misc_revolver_skin"] or "None"
				CONFIG.DoubleBarrel = library.flags["hood_misc_doublebarrel_skin"] or "None"
				CONFIG.Shotgun = library.flags["hood_misc_shotgun_skin"] or "None"
				CONFIG.TacticalShotgun = library.flags["hood_misc_tactical_shotgun_skin"] or "None"
				CONFIG.SMG = library.flags["hood_misc_smg_skin"] or "None"
				CONFIG.Knife = library.flags["hood_misc_knife_skin"] or "None"
				local char = LocalPlayer.Character
				if not char or tool.Parent ~= char then return end
				if tool.Name == "[Knife]" then
					if CONFIG.Enabled and CONFIG.Knife and CONFIG.Knife ~= "None" then
						local skin = GetSkinModel("Knife", CONFIG.Knife)
						if skin then ApplyKnifeSkin(tool, skin) end
					else
						RemoveKnifeSkin(tool)
					end
					return
				end
				if not CONFIG.Enabled then return end
				local weapon = tool.Name:match("^%[(.+)%]$")
				if weapon and CONFIG[weapon] and CONFIG[weapon] ~= "None" then
					local skin = GetSkinModel(weapon, CONFIG[weapon])
					if skin then ApplyGunSkin(tool, skin) end
				end
			end
			local HandleMap = {DB_HANDLE = "DoubleBarrel", REV_HANDLE = "Revolver"}
			local function ApplyHandles(char)
				for h, weapon in pairs(HandleMap) do
					task.defer(function()
						local skin = CONFIG[weapon]
						local folder = char:FindFirstChild(h)
						if folder and skin and skin ~= "" and skin ~= "None" and CONFIG.Enabled then
							local skinmodel = GetSkinModel(weapon, skin)
							if skinmodel then ApplyGunSkin(folder, skinmodel) end
						end
					end)
				end
			end
			local function ConnectCharacter(char)
				char.ChildAdded:Connect(function(child)
					if child:IsA("Tool") then
						task.wait(0.1)
						OnToolAdded(child)
					elseif HandleMap[child.Name] then
						ApplyHandles(char)
					end
				end)
				char.ChildRemoved:Connect(function(child)
					if child:IsA("Tool") and child.Name == "[Knife]" then RemoveKnifeSkin(child) end
				end)
				ApplyHandles(char)
				for _, t in ipairs(char:GetChildren()) do
					if t:IsA("Tool") then
						task.wait(0.05)
						OnToolAdded(t)
					end
				end
			end
			HM.RefreshSkins = function()
				local char = LocalPlayer.Character
				if not char then return end
				for _, t in ipairs(char:GetChildren()) do
					if t:IsA("Tool") then OnToolAdded(t) end
				end
			end
			if LocalPlayer.Character then
				ConnectCharacter(LocalPlayer.Character)
			else
				LocalPlayer.CharacterAdded:Once(ConnectCharacter)
			end
			LocalPlayer.CharacterAdded:Connect(function(char)
				task.wait(0.5)
				ConnectCharacter(char)
			end)
		end

		-- Beam Changer
		do
			if not getgenv().BulletChanger then
				getgenv().BulletChanger = {DoubleBarrel = "Green", Revolver = "Green", Shotgun = "Green", SMG = "Green", TacticalShotgun = "Green"}
			end
			local weaponCodes = {
				DoubleBarrel = "109d1326878cc594bc1bb42d126250810999782f",
				Revolver = "539db315b53f77390c0aa74773158e25bedcdd6e",
				Shotgun = "b415a7273aa86cbc2adc445fde5435eb5afababa",
				SMG = "005af87725b42ac4ca8103d11af6bf0c7d55f7b3",
				TacticalShotgun = "109d1326878cc594bc1bb42d126250810999782f"
			}
			local function ApplyBeamColors()
				local dataFolder = LocalPlayer:FindFirstChild("DataFolder")
				if not dataFolder then return end
				local inventoryData = dataFolder:FindFirstChild("InventoryData")
				if not inventoryData then return end
				local bulletBeams = inventoryData:FindFirstChild("BulletBeams")
				local equippedBulletBeams = dataFolder:FindFirstChild("EquippedBulletBeams")
				local value = library.flags["hood_misc_beam"] or "Green"
				getgenv().BulletChanger.DoubleBarrel = value
				getgenv().BulletChanger.Revolver = value
				getgenv().BulletChanger.Shotgun = value
				getgenv().BulletChanger.SMG = value
				getgenv().BulletChanger.TacticalShotgun = value
				if bulletBeams and bulletBeams:IsA("StringValue") then
					local bulletBeamData = {}
					for weapon, code in pairs(weaponCodes) do
						bulletBeamData[code] = {Name = getgenv().BulletChanger[weapon]}
					end
					bulletBeams.Value = game:GetService("HttpService"):JSONEncode(bulletBeamData)
				end
				if equippedBulletBeams and equippedBulletBeams:IsA("StringValue") then
					local equippedData = {}
					equippedData["[DoubleBarrel]"] = weaponCodes.DoubleBarrel
					equippedData["[Revolver]"] = weaponCodes.Revolver
					equippedData["[TacticalShotgun]"] = weaponCodes.TacticalShotgun
					equippedData["[SMG]"] = weaponCodes.SMG
					equippedData["[Shotgun]"] = weaponCodes.Shotgun
					equippedBulletBeams.Value = game:GetService("HttpService"):JSONEncode(equippedData)
				end
			end
			HM.ApplyBeamColors = ApplyBeamColors
			LocalPlayer.CharacterAdded:Connect(function() task.wait(1) ApplyBeamColors() end)
			task.delay(1, ApplyBeamColors)
		end

		-- Shoot Sounds
		do
			local SelectedShootSounds = {DoubleBarrel = "Mp40", Revolver = "Mp40", SMG = "Mp40", Shotgun = "Mp40", Silencer = "Mp40", TacticalShotgun = "Mp40"}
			local weaponTypes = {"DoubleBarrel", "Revolver", "SMG", "Shotgun", "Silencer", "TacticalShotgun"}
			local ShootSoundCooldowns = {DoubleBarrel = 0.4, SMG = 0.07, Revolver = 0.2, TacticalShotgun = 0.7, Silencer = 0.5, Shotgun = 1.35}
			local LastShootSoundTime = {}
			local OriginalSoundIds = {}
			local soundMap = {Mp40 = "103807799095792", G36C = "4759267374", M249 = "120962559430237", Sniper = "135333708100426", ["Fortnite Pump"] = "106427010095959", DoubleBarrel = "3855292863"}
			local function getWeaponTool(weaponName)
				local char = LocalPlayer.Character
				if not char then return nil end
				for _, tool in pairs(char:GetChildren()) do
					if tool:IsA("Tool") and tool.Name:find(weaponName) then return tool end
				end
				for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
					if tool:IsA("Tool") and tool.Name:find(weaponName) then return tool end
				end
				return nil
			end
			local function changeWeaponSound(weapon, soundId)
				local tool = getWeaponTool(weapon)
				if not tool then return end
				local handle = tool:FindFirstChild("Handle")
				if not handle then return end
				local shootSound = handle:FindFirstChild("Shoot")
				if not shootSound or not shootSound:IsA("Sound") then return end
				if not OriginalSoundIds[weapon] then OriginalSoundIds[weapon] = shootSound.SoundId end
				shootSound.SoundId = "rbxassetid://" .. soundId
				shootSound.Volume = (library.flags["hood_misc_shoot_sounds_volume"] or 50) / 100
			end
			local function applyVolumeToAllSounds()
				for weapon, _ in pairs(SelectedShootSounds) do
					local tool = getWeaponTool(weapon)
					if tool and tool:FindFirstChild("Handle") then
						local shootSound = tool.Handle:FindFirstChild("Shoot")
						if shootSound and shootSound:IsA("Sound") then
							shootSound.Volume = (library.flags["hood_misc_shoot_sounds_volume"] or 50) / 100
						end
					end
				end
			end
			local function applyAllShootSounds()
				if not library.flags["hood_misc_shoot_sounds_enabled"] == true then return end
				for weapon, soundName in pairs(SelectedShootSounds) do
					local id = soundMap[soundName] or soundMap["Mp40"]
					changeWeaponSound(weapon, id)
				end
			end
			local function onToolEquipped(tool)
				if not library.flags["hood_misc_shoot_sounds_enabled"] == true then return end
				task.wait(0.1)
				for weapon, _ in pairs(SelectedShootSounds) do
					if tool.Name:find(weapon) then
						local soundName = library.flags["hood_misc_shootsound_" .. weapon:lower()] or "Mp40"
						local id = soundMap[soundName] or soundMap["Mp40"]
						changeWeaponSound(weapon, id)
						break
					end
				end
			end
			HM.ApplyShootSounds = function()
				for _, weapon in ipairs(weaponTypes) do
					local flagName = "hood_misc_shootsound_" .. weapon:lower()
					local val = library.flags[flagName] or "Mp40"
					SelectedShootSounds[weapon] = val
				end
				if library.flags["hood_misc_shoot_sounds_enabled"] == true then
					applyAllShootSounds()
				else
					for weapon, originalId in pairs(OriginalSoundIds) do
						if originalId then
							local tool = getWeaponTool(weapon)
							if tool and tool:FindFirstChild("Handle") then
								local shootSound = tool.Handle:FindFirstChild("Shoot")
								if shootSound and shootSound:IsA("Sound") then shootSound.SoundId = originalId end
							end
						end
					end
				end
			end
			if LocalPlayer.Backpack then
				LocalPlayer.Backpack.ChildAdded:Connect(function(child)
					if child:IsA("Tool") then
						child.Equipped:Connect(function() onToolEquipped(child) end)
					end
				end)
				for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
					if tool:IsA("Tool") then
						tool.Equipped:Connect(function() onToolEquipped(tool) end)
					end
				end
			end
			LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.5)
				HM.ApplyShootSounds()
			end)
			RunService.Heartbeat:Connect(function()
				if library.flags["hood_misc_shoot_sounds_enabled"] == true then applyVolumeToAllSounds() end
			end)
			task.delay(1, HM.ApplyShootSounds)
		end
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