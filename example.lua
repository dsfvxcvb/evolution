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
				lock:toggle({name = "Auto Shoot", flag = "auto_shoot"})
				lock:dropdown({name = "Aim Bone", flag = "silent_aim_bone", items = {"Hrp", "Head"}, default = "Head"})                lock:toggle({name = "Invisible Bullets", flag = "invis_bullet", tooltip = "Makes your bullets invisible"})
				
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

	-- Visuals
		local esp;
		local function update_elements() if esp and esp.refresh_elements then esp.refresh_elements() end end 
		local column = Visuals:column()
		local section = column:section({name = "General", toggle = false})
		section:toggle({name = "Enabled", flag = "Enabled", callback = update_elements})
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
		esp = window.esp_section:esp_preview({})
		task.defer(function() if esp and esp.refresh_elements then esp.refresh_elements() end end)

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
					elseif typeof(d) ~= "string" and typeof(d) ~= "boolean" and d then
						if typeof(d) == "Instance" then
							if d.Parent then
								d:Destroy()
							end
						else
							d:Remove()
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
				if player ~= LocalPlayer then
					safeCreateEsp(player)
				end
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