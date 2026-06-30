-- protected.lua
-- Sensitive exploit logic. Obfuscate THIS file with PolSec.
-- Load this BEFORE the main UI script via loader.lua.
print("ll")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

getgenv().MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
getgenv().LocalPlayer = LocalPlayer
getgenv().Workspace = Workspace
getgenv().Players = Players

getgenv().ForceHit = {
    HitPart = "UpperTorso",
    MaxDistance = 200,
    WallCheck = true,
    ForceFieldCheck = true,
    PrefireForceField = false,
    DeathCheck = true,
    LastShotTime = 0,
    Enabled = false,
    LastBeamTime = 0,
    WeaponCooldowns = {
        ["[Revolver]"] = 0.2,
        ["[DoubleBarrel]"] = 0.4,
        ["[TacticalShotgun]"] = 0.3,
        ["[SMG]"] = 0.1,
        ["[Shotgun]"] = 0.35,
        ["[Silencer]"] = 0.15,
    },
    DefaultCooldown = 0.15
}

getgenv().FH_IsWallBetween = function(startPos, endPos, targetCharacter)
    local direction = (endPos - startPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter, getgenv().HitChamsFolder}
    local result = Workspace:Raycast(startPos, direction, raycastParams)
    return result ~= nil
end

getgenv().FH_GetWeaponAmmo = function()
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return 0 end
    
    local script = tool:FindFirstChild("Script")
    if script then
        local ammo = script:FindFirstChild("Ammo")
        if ammo and ammo:IsA("IntValue") then
            return ammo.Value
        end
    end
    
    return -1
end

getgenv().FH_GetWeaponCooldown = function()
    local character = LocalPlayer.Character
    if not character then return getgenv().ForceHit.DefaultCooldown end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return getgenv().ForceHit.DefaultCooldown end
    
    local weaponName = tool.Name
    local cooldown = getgenv().ForceHit.WeaponCooldowns[weaponName]
    
    return cooldown or getgenv().ForceHit.DefaultCooldown
end

getgenv().FH_GetChestPart = function(character)
    if not character then return nil end
    return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
end

getgenv().FH_GetHitChamsClone = function(player)
    if not player then return nil end
    return getgenv().Workspace:FindFirstChild("HitChams_Clone_" .. player.Name)
end

getgenv().FH_ActiveBeams = {}

getgenv().FH_TracerConfig = {
    Enabled = true,
    UseSpread = false,
    Color = Color3.fromRGB(255, 255, 255),
    EndColor = Color3.fromRGB(255, 255, 255),
    Lifetime = 2,
    Transparency0 = 0,
    Transparency1 = 1,
    Texture = "",
    Textures = {
        ["Default"] = "",
        ["Hoodcustoms"] = "",
        ["laser"] = "rbxassetid://12781800668",
        ["light"] = "rbxassetid://2382169232",
        ["flow"] = "rbxassetid://12788927812"
    },
    Segments = 5,
    LightEmission = 1,
    LightInfluence = 0,
    FaceCamera = true,
    FadeOut = true,
    Preset = "Default",
    TextureName = "Default",
    SpreadFactors = {
        ["[Revolver]"] = 0.25,
        ["[Silencer]"] = 0.20,
        ["[SMG]"] = 0.45,
        ["[Shotgun]"] = 0.70,
        ["[TacticalShotgun]"] = 0.60,
        ["[DoubleBarrel]"] = 0.75,
        ["Default"] = 0.35
    }
}

getgenv().FH_ApplyTracerPreset = function(name)
    local cfg = getgenv().FH_TracerConfig
    if not cfg then return end
    if name == "Default" then
        cfg.Color = Color3.fromRGB(255, 50, 50)
        cfg.EndColor = Color3.fromRGB(255, 50, 50)
        cfg.Transparency0 = 0
        cfg.Transparency1 = 1
        cfg.Texture = ""
        cfg.Segments = 5
        cfg.LightEmission = 1
        cfg.LightInfluence = 0
        cfg.FaceCamera = true
        cfg.FadeOut = true
        cfg.Preset = "Default"
    end
end

getgenv().FH_CreateBeam = function(startPos, endPos, color, targetPlayer, attachPart, staticEnd)
    local character = LocalPlayer.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local cfg = getgenv().FH_TracerConfig
    if not cfg or not cfg.Enabled then return end

    if not getgenv().FH_Storage then
        getgenv().FH_Storage = Instance.new("Folder")
        getgenv().FH_Storage.Name = "FHTracersStorage"
        getgenv().FH_Storage.Parent = Workspace
    end

    local isHoodcustoms = (Options and Options.ForceHitTracersTexture and Options.ForceHitTracersTexture.Value == "Hoodcustoms")

    local endPart = attachPart
    local livePart = (targetPlayer and targetPlayer.Character) and (targetPlayer.Character:FindFirstChild(getgenv().ForceHit.HitPart) or getgenv().FH_GetChestPart(targetPlayer.Character)) or nil
    if not endPart and not staticEnd then
        endPart = livePart
    end

    local function makeBeam(worldEndPos)
        local p0 = Instance.new("Part")
        p0.Anchored = true; p0.CanCollide = false; p0.Size = Vector3.new(0.01,0.01,0.01)
        p0.Transparency = 1; p0.CFrame = CFrame.new(startPos); p0.Parent = getgenv().FH_Storage

        local a0 = Instance.new("Attachment", p0)
        local a1
        local p1

        if endPart then
            a1 = Instance.new("Attachment", endPart)
            a1.CFrame = CFrame.new(endPart.CFrame:PointToObjectSpace(worldEndPos))
        else
            p1 = Instance.new("Part")
            p1.Anchored = true; p1.CanCollide = false; p1.Size = Vector3.new(0.01,0.01,0.01)
            p1.Transparency = 1; p1.CFrame = CFrame.new(worldEndPos); p1.Parent = getgenv().FH_Storage
            a1 = Instance.new("Attachment", p1)
        end

        local beamColor, baseTransparency, fadeOut
        if isHoodcustoms then
            beamColor = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 242, 90)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 209, 41))
            })
            baseTransparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.82),
                NumberSequenceKeypoint.new(1, 0.22)
            })
            fadeOut = false
        else
            beamColor = ColorSequence.new({
                ColorSequenceKeypoint.new(0, cfg.Color or color or Color3.fromRGB(255, 50, 50)),
                ColorSequenceKeypoint.new(1, cfg.EndColor or cfg.Color or color or Color3.fromRGB(255, 50, 50))
            })
            baseTransparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, cfg.Transparency0 or 0),
                NumberSequenceKeypoint.new(1, cfg.Transparency1 or 1)
            })
            fadeOut = cfg.FadeOut
        end
        local lifetime = cfg.Lifetime or 2

        local beam = Instance.new("Beam")
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Color = beamColor
        beam.Transparency = baseTransparency
        beam.Texture = cfg.Texture or ""
        beam.TextureSpeed = isHoodcustoms and 1 or 1
        beam.TextureLength = isHoodcustoms and 0.5 or 0.5
        beam.Width0 = isHoodcustoms and 0 or 0.15
        beam.Width1 = isHoodcustoms and 0.1 or 0.15
        beam.Segments = isHoodcustoms and 5 or (cfg.Segments or 5)
        beam.LightEmission = isHoodcustoms and 1 or (cfg.LightEmission or 1)
        beam.LightInfluence = isHoodcustoms and 0.1 or (cfg.LightInfluence or 0)
        beam.FaceCamera = isHoodcustoms or (cfg.FaceCamera ~= false)
        beam.Parent = getgenv().FH_Storage

        local start = tick()
        getgenv().FH_ActiveBeams[beam] = {Beam = beam, EndAttach = a1, TargetPlayer = targetPlayer, Created = start}
        local conn
        conn = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - start
            local alpha = math.min(elapsed / lifetime, 1)
            if fadeOut then
                local kps = {}
                for _, kp in ipairs(baseTransparency.Keypoints) do
                    table.insert(kps, NumberSequenceKeypoint.new(kp.Time, kp.Value + (1 - kp.Value) * alpha))
                end
                beam.Transparency = NumberSequence.new(kps)
            end

            if alpha >= 1 then
                conn:Disconnect()
                getgenv().FH_ActiveBeams[beam] = nil
                pcall(function() p0:Destroy(); if a1 then a1:Destroy() end; if p1 then p1:Destroy() end; beam:Destroy() end)
            end
        end)
    end

    local spreadWeapons = {
        ["[DoubleBarrel]"] = true,
        ["[Shotgun]"] = true,
        ["[TacticalShotgun]"] = true
    }

    if cfg.UseSpread and spreadWeapons[tool.Name] then
        local spreadFactors = cfg.SpreadFactors or {}
        local spreadFactor = spreadFactors[tool.Name] or spreadFactors.Default or 0.35

        local hitRadius = 2
        local refPart = endPart or livePart
        if refPart then
            local size = refPart.Size
            hitRadius = math.max(size.X, size.Z) * 0.5
        end

        local maxOffset = hitRadius * spreadFactor
        local cf = CFrame.lookAt(startPos, endPos)
        for i = 1, 5 do
            local r = math.sqrt(math.random()) * maxOffset
            local theta = math.random() * 2 * math.pi
            local offset = (cf.RightVector * math.cos(theta) + cf.UpVector * math.sin(theta)) * r
            makeBeam(endPos + offset)
        end
    else
        makeBeam(endPos)
    end
end

getgenv().FH_CreateBeamToHitChams = function(player, cloneChest)
    local shot = getgenv().FH_LastValidShot
    if not shot then return end
    if shot.TargetPlayer ~= player then return end
    if tick() - shot.Timestamp > 3 then return end
    getgenv().FH_CreateBeam(shot.StartPosition, cloneChest.Position, nil, player, cloneChest)
end

getgenv().FH_LastValidShot = nil

getgenv().FH_Fire = function(targetPlayer)
    if not getgenv().ForceHit.Enabled then 
        return false 
    end
    
    if not targetPlayer or not targetPlayer.Character then 
        return false 
    end
    
    local character = LocalPlayer.Character
    if not character then 
        return false 
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then 
        return false 
    end
    
    local currentAmmo = getgenv().FH_GetWeaponAmmo()
    if currentAmmo == 0 then
        return false
    end
    
    if onPlayerShoot then
        onPlayerShoot()
    end
    
    local currentTime = tick()
    local weaponCooldown = getgenv().FH_GetWeaponCooldown()
    if currentTime - getgenv().ForceHit.LastShotTime < weaponCooldown then
        return false
    end
    
    local targetCharacter = targetPlayer.Character
    local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    
    if getgenv().ForceHit.DeathCheck then
        if not humanoid or humanoid.Health <= 0 then 
            return false 
        end
        local be = targetCharacter:FindFirstChild("BodyEffects")
        if be and be:FindFirstChild("K.O") and be["K.O"].Value then 
            return false 
        end
    end
    
    local targetPart = targetCharacter:FindFirstChild(getgenv().ForceHit.HitPart) or getgenv().FH_GetChestPart(targetCharacter)
    if not targetPart then 
        return false 
    end
    
    if targetCharacter:FindFirstChildOfClass("ForceField") then 
        return false 
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then 
        return false 
    end
    
    local playerPos = root.Position
    local targetPos = targetPart.Position
    
    local distance = (playerPos - targetPos).Magnitude
    if distance > getgenv().ForceHit.MaxDistance then 
        return false 
    end
    
    if getgenv().ForceHit.WallCheck then
        local hasWall = getgenv().FH_IsWallBetween(playerPos, targetPos, targetCharacter)
        if hasWall then 
            return false
        end
    end
    
    if getgenv().ForceHit.PrefireForceField then
        if targetCharacter:FindFirstChildOfClass("ForceField") then 
            return false 
        end
    end
    
    local handle = tool:FindFirstChild("Handle")
    local startPos = handle and handle.Position or playerPos

    local expectedDamage = nil
    local gunData = tool:FindFirstChild("GunData")
    if gunData then
        local ok, data = pcall(function() return require(gunData) end)
        if ok and data then
            local isHead = getgenv().ForceHit.HitPart == "Head"
            expectedDamage = isHead and (data.headshot_damage or data.damage) or (data.damage or 0)
        end
    end

    getgenv().FH_LastValidShot = {
        TargetPlayer = targetPlayer,
        TargetPosition = targetPos,
        TargetPart = targetPart,
        WeaponName = tool.Name,
        Timestamp = currentTime,
        StartPosition = startPos,
        Damage = expectedDamage
    }
    
    local rayPositions = {}
    local rayOffsets = {}
    local spreadWeapons = {
        ["[DoubleBarrel]"] = true,
        ["[Shotgun]"] = true,
        ["[TacticalShotgun]"] = true
    }

    if spreadWeapons[tool.Name] then
        local cfg = getgenv().FH_TracerConfig
        local spreadFactors = cfg and cfg.SpreadFactors or {}
        local spreadFactor = spreadFactors[tool.Name] or spreadFactors.Default or 0.35

        local size = targetPart.Size
        local hitRadius = math.max(size.X, size.Z) * 0.5
        local maxOffset = hitRadius * spreadFactor
        local cf = CFrame.lookAt(startPos, targetPos)

        for i = 1, 5 do
            local r = math.sqrt(math.random()) * maxOffset
            local theta = math.random() * 2 * math.pi
            local offset = (cf.RightVector * math.cos(theta) + cf.UpVector * math.sin(theta)) * r
            rayPositions[i] = targetPos + offset
            rayOffsets[i] = offset
        end
    else
        for i = 1, 5 do
            rayPositions[i] = targetPos
            rayOffsets[i] = Vector3.new(0, 0, 0)
        end
    end

    local args = {
        [1] = "Shoot",
        [2] = {
            [1] = {
                [1] = {Normal=rayPositions[1],Instance=targetPart,Position=rayPositions[1]},
                [2] = {Normal=rayPositions[2],Instance=targetPart,Position=rayPositions[2]},
                [3] = {Normal=rayPositions[3],Instance=targetPart,Position=rayPositions[3]},
                [4] = {Normal=rayPositions[4],Instance=targetPart,Position=rayPositions[4]},
                [5] = {Normal=rayPositions[5],Instance=targetPart,Position=rayPositions[5]},
            },
            [2] = {
                [1] = {thePart=targetPart,theOffset=rayOffsets[1]},
                [2] = {thePart=targetPart,theOffset=rayOffsets[2]},
                [3] = {thePart=targetPart,theOffset=rayOffsets[3]},
                [4] = {thePart=targetPart,theOffset=rayOffsets[4]},
                [5] = {thePart=targetPart,theOffset=rayOffsets[5]},
            },
            [3] = playerPos,
            [4] = playerPos,
            [5] = getgenv().Workspace:GetServerTimeNow()
        }
    }
    
    local success, err = pcall(function() 
        getgenv().MainEvent:FireServer(unpack(args)) 
    end)

    if success then
        local weaponType = getgenv().getWeaponTypeFromTool(tool)
        if weaponType then
            getgenv().playShootSound(weaponType)
        end
        getgenv().ForceHit.LastShotTime = currentTime
        if not (Toggles.HitChamsEnabled and Toggles.HitChamsEnabled.Value) then
            getgenv().FH_CreateBeam(startPos, targetPos, nil, targetPlayer, nil, true)
        end
        return true
    end

    return false
end

-- Animation Godmode module
local AnimGodmode = {
    Enabled = false,
    EmoteId = "rbxassetid://70883871260184",
    FreezeTime = 0.1265,
    Track = nil,
    Heartbeat = nil,
    Connection = nil
}

local function cleanupAnimGodmode()
    if AnimGodmode.Track then
        AnimGodmode.Track:Stop()
        AnimGodmode.Track:Destroy()
        AnimGodmode.Track = nil
    end
    if AnimGodmode.Heartbeat then
        AnimGodmode.Heartbeat:Disconnect()
        AnimGodmode.Heartbeat = nil
    end
    if AnimGodmode.Connection then
        AnimGodmode.Connection:Disconnect()
        AnimGodmode.Connection = nil
    end
end

local function getGodmodeHumanoid()
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char:WaitForChild("Humanoid")
end

local function playFrozenEmote()
    if not AnimGodmode.Enabled then return end
    cleanupAnimGodmode()
    local hum = getGodmodeHumanoid()
    local anim = Instance.new("Animation")
    anim.AnimationId = AnimGodmode.EmoteId
    AnimGodmode.Track = hum:LoadAnimation(anim)
    -- Core priority + weight 1: the track is active and replicates server-side,
    -- but default idle/walk animations (Movement priority) override it locally.
    AnimGodmode.Track.Priority = Enum.AnimationPriority.Core
    AnimGodmode.Track:Play(0, 1, 1)
    AnimGodmode.Heartbeat = RunService.Heartbeat:Connect(function()
        if AnimGodmode.Track and AnimGodmode.Enabled then
            AnimGodmode.Track.TimePosition = AnimGodmode.FreezeTime
            AnimGodmode.Track:AdjustSpeed(0)
        end
    end)
    AnimGodmode.Connection = hum.AnimationPlayed:Connect(function(newTrack)
        if AnimGodmode.Enabled and AnimGodmode.Track and newTrack ~= AnimGodmode.Track then
            task.delay(0.02 + math.random() * 0.03, playFrozenEmote)
        end
    end)
end

function AnimGodmode.Enable()
    AnimGodmode.Enabled = true
    playFrozenEmote()
end

function AnimGodmode.Disable()
    AnimGodmode.Enabled = false
    cleanupAnimGodmode()
end

function AnimGodmode.Set(enabled)
    if enabled then
        AnimGodmode.Enable()
    else
        AnimGodmode.Disable()
    end
end

function AnimGodmode.IsEnabled()
    return AnimGodmode.Enabled
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.25)
    if AnimGodmode.Enabled then
        playFrozenEmote()
    end
end)

getgenv().AnimGodmode = AnimGodmode
