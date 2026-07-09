-- Duelist 1v1 bot: teleports two configured accounts onto the same 1vs1 pad.
-- Config (set before running):
--   getgenv().DuelBotMode     = "Winner" or "Loser"
--   getgenv().DuelBotOpponent = "OtherAccountUsername"
-- Optional:
--   getgenv().DuelBotPadId    = 1 (1-based index of the 1vs1 pad, sorted by TP position)

local cfg = {
    Mode = getgenv().DuelBotMode or "Winner",
    OpponentName = getgenv().DuelBotOpponent or nil,
    PadId = getgenv().DuelBotPadId or nil,
}

assert(cfg.OpponentName and cfg.OpponentName ~= "", "DuelBotOpponent must be set")
assert(cfg.Mode == "Winner" or cfg.Mode == "Loser", "DuelBotMode must be 'Winner' or 'Loser'")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local assignedTeam = cfg.Mode == "Winner" and "Team1" or "Team2"
local otherTeam = assignedTeam == "Team1" and "Team2" or "Team1"

local function log(...)
    print("[DuelBot]", ...)
end

local function waitForCharacter(player, timeout)
    timeout = timeout or 30
    local t0 = tick()
    while not (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid")) do
        if tick() - t0 > timeout then return nil end
        task.wait(0.1)
    end
    return player.Character
end

local function getOpponent()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == cfg.OpponentName:lower() then
            return plr
        end
    end
    return nil
end

local function getPlayerFromHRP(part)
    if not part or part.Name ~= "HumanoidRootPart" then return nil end
    local char = part.Parent
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local plr = Players:GetPlayerFromCharacter(char)
    return plr
end

local function getOccupants(detectPart)
    local occupants = {}
    if not detectPart then return occupants end
    local success, parts = pcall(function()
        return Workspace:GetPartsInPart(detectPart)
    end)
    if not success or not parts then return occupants end
    for _, part in ipairs(parts) do
        local plr = getPlayerFromHRP(part)
        if plr then
            occupants[plr.UserId] = plr.Name
        end
    end
    return occupants
end

local function readGuiCount(pad, teamName)
    local screen = pad:FindFirstChild("Screen")
    local teamPart = screen and screen:FindFirstChild(teamName)
    if not teamPart then return 0, 1 end
    local numberLabel = nil
    for _, d in ipairs(teamPart:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "Number" then
            numberLabel = d
            break
        end
    end
    if not numberLabel then return 0, 1 end
    local count, max = numberLabel.Text:match("(%d+)/(%d+)")
    return tonumber(count) or 0, tonumber(max) or 1
end

local function getPadDescriptor(pad)
    local model = pad:FindFirstChild("Model")
    if not model then return nil end
    local teamModel = model:FindFirstChild(assignedTeam)
    local otherModel = model:FindFirstChild(otherTeam)
    if not teamModel or not otherModel then return nil end
    local teamDetect = teamModel:FindFirstChild("Duels Detect")
    local otherDetect = otherModel:FindFirstChild("Duels Detect")
    if not teamDetect or not otherDetect then return nil end

    local teamOcc = getOccupants(teamDetect)
    local otherOcc = getOccupants(otherDetect)
    local teamGuiCount, teamMax = readGuiCount(pad, assignedTeam)
    local otherGuiCount, otherMax = readGuiCount(pad, otherTeam)

    local function countDict(dict)
        local n = 0
        for _ in pairs(dict) do n = n + 1 end
        return n
    end

    -- Prefer physics occupancy, fall back to GUI count
    local teamCount = countDict(teamOcc)
    local otherCount = countDict(otherOcc)
    if teamCount == 0 then teamCount = teamGuiCount end
    if otherCount == 0 then otherCount = otherGuiCount end

    return {
        pad = pad,
        padId = pad:GetAttribute("DuelsPadId"),
        teamDetect = teamDetect,
        otherDetect = otherDetect,
        teamOccupants = teamOcc,
        otherOccupants = otherOcc,
        teamCount = teamCount,
        teamMax = teamMax,
        otherCount = otherCount,
        otherMax = otherMax,
    }
end

local function getAll1v1Pads()
    local padsFolder = Workspace:FindFirstChild("Pads")
    if not padsFolder then return {} end
    local list = {}
    for _, child in ipairs(padsFolder:GetChildren()) do
        if child.Name == "1vs1" then
            table.insert(list, child)
        end
    end
    table.sort(list, function(a, b)
        local ap = a:FindFirstChild("TP") and a.TP.Position or Vector3.zero
        local bp = b:FindFirstChild("TP") and b.TP.Position or Vector3.zero
        if ap.X == bp.X then return ap.Z < bp.Z end
        return ap.X < bp.X
    end)
    return list
end

local function findSuitablePad(opponent)
    local opponentId = opponent and opponent.UserId or 0
    local pads = getAll1v1Pads()
    for _, pad in ipairs(pads) do
        local desc = getPadDescriptor(pad)
        if not desc then continue end

        -- If a specific pad index was requested, only consider that one
        if cfg.PadId then
            local index = tonumber(cfg.PadId)
            if index then
                local pos = table.find(pads, pad)
                if pos ~= index then continue end
            end
        end

        -- Our team must be empty
        if desc.teamCount ~= 0 then continue end

        -- Other team must be empty or already occupied by our opponent
        if desc.otherCount == 0 then
            return desc
        end
        if opponentId ~= 0 and desc.otherOccupants[opponentId] then
            return desc
        end
    end
    return nil
end

local function teleportToDetect(detect)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    LocalPlayer:SetAttribute("MovementACIgnore", true)

    local targetCF = detect.CFrame * CFrame.new(0, 2.5, 0)
    local distance = (hrp.Position - targetCF.Position).Magnitude
    local duration = math.clamp(distance / 800, 1.2, 3)

    humanoid.PlatformStand = false
    humanoid.Sit = false
    humanoid.AutoRotate = false

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()

    -- Keep the character inside the detection part without anchoring.
    -- Direct CFrame writes get reverted by the anti-cheat, but TweenService updates are accepted.
    hrp.Anchored = false
    hrp.CFrame = targetCF

    pcall(function()
        firetouchinterest(hrp, detect, 0)
        task.wait(0.05)
        firetouchinterest(hrp, detect, 1)
    end)

    return targetCF
end

local function holdPositionUntilDuel(targetCF, detect)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    local started = tick()
    local inDuel = false

    -- Jiggle the HRP with tiny tweens so the server keeps registering us inside the detect part.
    while tick() - started < 12 do
        if LocalPlayer:GetAttribute("InDuels") == true then
            inDuel = true
            break
        end

        local offset = CFrame.new(
            math.random(-2, 2) / 12,
            math.random(-2, 2) / 12,
            math.random(-2, 2) / 12
        )
        local tween = TweenService:Create(hrp, TweenInfo.new(0.12), {CFrame = targetCF * offset})
        tween:Play()

        task.wait(0.18)
    end

    return inDuel
end

local function unfreeze()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.Anchored = false
    end
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end
end

local function main()
    log("Starting as", cfg.Mode, "(team:", assignedTeam .. ")", "opponent:", cfg.OpponentName)

    if LocalPlayer:GetAttribute("InDuels") == true then
        log("Already in a duel.")
        return
    end

    local opponent = nil
    for i = 1, 60 do
        opponent = getOpponent()
        if opponent then break end
        task.wait(0.5)
    end
    if not opponent then
        log("ERROR: Could not find opponent", cfg.OpponentName)
        return
    end
    log("Found opponent", opponent.Name, "UserId:", opponent.UserId)

    local myChar = waitForCharacter(LocalPlayer, 30)
    local oppChar = waitForCharacter(opponent, 30)
    if not myChar or not oppChar then
        log("ERROR: Characters did not load in time")
        return
    end

    local selectedPad = nil
    if cfg.PadId then
        for idx, pad in ipairs(getAll1v1Pads()) do
            if tonumber(cfg.PadId) == idx then
                selectedPad = getPadDescriptor(pad)
                break
            end
        end
        if not selectedPad then
            log("ERROR: Could not find pad at index", cfg.PadId)
            return
        end
    else
        for attempt = 1, 60 do
            selectedPad = findSuitablePad(opponent)
            if selectedPad then break end
            log("No suitable 1vs1 pad yet, retrying... (" .. attempt .. ")")
            task.wait(0.5)
        end
    end
    if not selectedPad then
        log("ERROR: No suitable 1vs1 pad found after retries")
        return
    end
    log("Selected pad", selectedPad.pad.Name, "team:", assignedTeam)

    local targetCF = teleportToDetect(selectedPad.teamDetect)
    if not targetCF then
        log("ERROR: Teleport failed")
        unfreeze()
        LocalPlayer:SetAttribute("MovementACIgnore", nil)
        return
    end

    log("Holding position on pad, waiting for duel to start...")
    local inDuel = holdPositionUntilDuel(targetCF, selectedPad.teamDetect)

    unfreeze()

    if not inDuel then
        log("ERROR: Duel did not start")
        LocalPlayer:SetAttribute("MovementACIgnore", nil)
        return
    end

    local myMatchId = LocalPlayer:GetAttribute("DuelsMatchId")
    local oppMatchId = opponent:GetAttribute("DuelsMatchId")
    local oppInDuels = opponent:GetAttribute("InDuels") == true

    log("InDuels = true", "MatchId:", myMatchId, "Team:", LocalPlayer:GetAttribute("DuelsTeam"))

    if not oppInDuels then
        log("WARNING: Opponent is not in a duel yet")
    elseif tostring(oppMatchId) ~= tostring(myMatchId) then
        log("WARNING: Opponent is in a different match (mine:", myMatchId, " theirs:", oppMatchId, ")")
    else
        log("SUCCESS: Both accounts are in the same duel (match:", myMatchId .. ")")
    end

    LocalPlayer:SetAttribute("MovementACIgnore", nil)
end

local ok, err = pcall(main)
if not ok then
    log("CRASH:", err)
    unfreeze()
    LocalPlayer:SetAttribute("MovementACIgnore", nil)
end
