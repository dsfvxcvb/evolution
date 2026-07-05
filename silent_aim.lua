local repo = 'https://raw.githubusercontent.com/dsfvxcvb/evolution/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = 'Silent Aim',
    Center = true,
    AutoShow = true,
})

local SilentAimTab = Window:AddTab('Silent Aim')
local MainGroup = SilentAimTab:AddLeftGroupbox('Main')

MainGroup:AddToggle('SilentAimEnabled', {
    Text = 'Enabled',
    Default = false,
})

MainGroup:AddToggle('SilentAimTeamCheck', {
    Text = 'Team Check',
    Default = false,
})

MainGroup:AddToggle('SilentAimVisibleCheck', {
    Text = 'Visible Check',
    Default = false,
})

MainGroup:AddDropdown('SilentAimAimPart', {
    Text = 'Aim Part',
    Values = { 'Head', 'Torso', 'HumanoidRootPart' },
    Default = 'Head',
})

MainGroup:AddSlider('SilentAimFov', {
    Text = 'FOV',
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 0,
})

MainGroup:AddSlider('SilentAimMaxDistance', {
    Text = 'Max Distance',
    Default = 1000,
    Min = 50,
    Max = 5000,
    Rounding = 0,
})

local function IsAlive(character)
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    return humanoid and humanoid.Health > 0
end

local function GetAimPart(character)
    local partName = Options.SilentAimAimPart.Value or 'Head'
    local part = character:FindFirstChild(partName)
    if not part then
        part = character:FindFirstChild('Head')
            or character:FindFirstChild('Torso')
            or character:FindFirstChild('HumanoidRootPart')
    end
    return part
end

local function IsTeammate(player)
    if not Toggles.SilentAimTeamCheck.Value then
        return false
    end
    if player.Neutral or LocalPlayer.Neutral then
        return false
    end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(character, part)
    if not Toggles.SilentAimVisibleCheck.Value then
        return true
    end
    local origin = Camera.CFrame.Position
    local target = part.Position
    local direction = target - origin
    local distance = direction.Magnitude
    direction = direction.Unit

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    if Workspace:FindFirstChild("Spawned") and Workspace.Spawned:FindFirstChild("MouseIgnoreFolder") then
        table.insert(params.FilterDescendantsInstances, Workspace.Spawned.MouseIgnoreFolder)
    end

    local result = Workspace:Raycast(origin, direction * distance, params)
    if not result then
        return true
    end
    return result.Instance:IsDescendantOf(character)
end

local function GetClosestTarget()
    local closest = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local fov = Options.SilentAimFov.Value or 100
    local maxDist = Options.SilentAimMaxDistance.Value or 1000

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeammate(player) then continue end
        local character = player.Character
        if not character or not IsAlive(character) then continue end
        local part = GetAimPart(character)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if screenDist > fov then continue end

        local worldDist = (part.Position - Camera.CFrame.Position).Magnitude
        if worldDist > maxDist then continue end

        if not IsVisible(character, part) then continue end

        if screenDist < closestDist then
            closestDist = screenDist
            closest = part
        end
    end

    return closest
end

local CommunicateGun
pcall(function()
    CommunicateGun = ReplicatedStorage:WaitForChild("Events", 5):WaitForChild("EventsReplication", 5):WaitForChild("CommunicateGun", 5)
end)

if not CommunicateGun then
    Library:Notify("Silent Aim: CommunicateGun remote not found", 5)
    return
end

local mt = getrawmetatable(game)
if not mt or not mt.__namecall then
    Library:Notify("Silent Aim: executor missing getrawmetatable", 5)
    return
end

local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if self == CommunicateGun and method == "FireServer" and Toggles.SilentAimEnabled.Value then
        local args = {...}
        if args[1] == "Fired" then
            local origin = args[2]
            if typeof(origin) == "Vector3" then
                local target = GetClosestTarget()
                if target then
                    local direction = (target.Position - origin).Unit
                    args[3] = direction
                    args[4] = target.Position
                    if typeof(args[5]) == "table" and args[5][1] and typeof(args[5][1][2]) == "Vector3" then
                        args[5][1][2] = direction
                    end
                end
            end
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

Library:Notify("Silent Aim loaded", 3)
