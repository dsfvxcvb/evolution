-- Standalone desync replica for Hood Customs / Da-Hood style games.
-- Replicates the working logic from the active script:
--   1. Create an invisible anchored "Desync Setback" part.
--   2. On Heartbeat: snapshot the real HRP CFrame, teleport the HRP to a
--      spoof position, make the camera follow the setback, RenderStepped:Wait(),
--      then move the setback to the real position and restore the HRP.
-- Because the camera follows the setback (which stays at the real position),
-- your screen stays stable while the server sees the spoofed position.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Desync = {
    Enabled = false,
    Mode = "Void", -- Void, DestroyCheaters, Underground, UndergroundV2, Custom, VoidSpam, Raining, TeleportMaze, Rotation
    CustomOffset = Vector3.new(10, 10, 10),
    ToggleKey = Enum.KeyCode.V,

    _setback = nil,
    _conn = nil,
    _charConn = nil,
    _busy = false,
}

-- Create the setback part that the camera will follow.
local function getSetback()
    if Desync._setback and Desync._setback.Parent then
        return Desync._setback
    end
    local part = Instance.new("Part")
    part.Name = "Desync Setback"
    part.Parent = Workspace
    part.Size = Vector3.new(2, 2, 1)
    part.CanCollide = false
    part.Anchored = true
    part.Transparency = 1
    part.Massless = true
    Desync._setback = part
    return part
end

local function getCharacter()
    return LocalPlayer.Character
        or (Workspace:FindFirstChild("Players")
            and Workspace.Players:FindFirstChild("Characters")
            and Workspace.Players.Characters:FindFirstChild(LocalPlayer.Name))
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function resetCamera()
    local humanoid = getHumanoid()
    if humanoid then
        Camera.CameraSubject = humanoid
    end
end

local function computeTeleportPosition(rootPart)
    local pos = rootPart.Position
    local mode = Desync.Mode

    if mode == "DestroyCheaters" or mode == "Destroy Cheaters" then
        return Vector3.new(11223344556677889900, 1, 1)

    elseif mode == "Underground" then
        return pos - Vector3.new(0, 9, 0)

    elseif mode == "UndergroundV2" or mode == "UnderGroundV2" then
        return pos - Vector3.new(0, 11, 0)

    elseif mode == "Custom" then
        return pos - Desync.CustomOffset

    elseif mode == "VoidSpam" or mode == "Void Spam" then
        if math.random(1, 2) == 1 then
            return rootPart.CFrame.Position
        else
            return Vector3.new(
                math.random(10000, 50000),
                math.random(10000, 50000),
                math.random(10000, 50000)
            )
        end

    elseif mode == "Raining" then
        return Vector3.new(
            pos.X + math.random(-10, 10),
            pos.Y + math.random(2, 5),
            pos.Z + math.random(-10, 10)
        )

    elseif mode == "TeleportMaze" or mode == "Teleport Maze" then
        return Vector3.new(
            math.random(-100, 100),
            math.random(5, 50),
            math.random(-100, 100)
        )

    else -- default "Void"
        return Vector3.new(
            pos.X + math.random(-444444, 444444),
            pos.Y + math.random(-444444, 444444),
            pos.Z + math.random(-44444, 44444)
        )
    end
end

local function onHeartbeat()
    if not Desync.Enabled or Desync._busy then return end

    local char = getCharacter()
    if not char then return end

    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    Desync._busy = true

    local oldCFrame = rootPart.CFrame
    local teleportPosition = computeTeleportPosition(rootPart)

    if Desync.Mode ~= "Rotation" then
        rootPart.CFrame = CFrame.new(teleportPosition)
        Camera.CameraSubject = getSetback()

        RunService.RenderStepped:Wait()

        getSetback().CFrame = oldCFrame * CFrame.new(0, rootPart.Size.Y / 2 + 0.5, 0)
        rootPart.CFrame = oldCFrame
    end

    Desync._busy = false
end

function Desync.Toggle()
    Desync.Enabled = not Desync.Enabled
    if Desync.Enabled then
        Camera.CameraSubject = getSetback()
        print("[desync] enabled (mode: " .. tostring(Desync.Mode) .. ")")
    else
        resetCamera()
        print("[desync] disabled")
    end
end

function Desync.SetEnabled(state)
    if state ~= Desync.Enabled then
        Desync.Toggle()
    end
end

function Desync.SetMode(mode)
    Desync.Mode = tostring(mode)
    print("[desync] mode set to " .. tostring(mode))
end

function Desync.SetCustomOffset(vec)
    Desync.CustomOffset = vec
end

-- Cleanup any previous load of this file.
local old = getgenv().Desync
if old then
    pcall(function() if old._conn then old._conn:Disconnect() end end)
    pcall(function() if old._charConn then old._charConn:Disconnect() end end)
    pcall(function() if old._setback then old._setback:Destroy() end end)
end

Desync._conn = RunService.Heartbeat:Connect(onHeartbeat)

Desync._charConn = LocalPlayer.CharacterAdded:Connect(function()
    if Desync.Enabled then
        Camera.CameraSubject = getSetback()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Desync.ToggleKey then
        Desync.Toggle()
    end
end)

getgenv().Desync = Desync
print("[desync] standalone loaded. Press '" .. tostring(Desync.ToggleKey) .. "' to toggle.")
print("[desync] modes: Void | DestroyCheaters | Underground | UndergroundV2 | Custom | VoidSpam | Raining | TeleportMaze | Rotation")
