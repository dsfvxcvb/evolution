-- Duelist 1v1 bot: makes two configured accounts duel each other on a 1vs1 pad.
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
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local DuelsPadUI = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DuelsPadUI")

-- Winner physically claims a pad; Loser teleports to the Winner's pad via the invite remote.
local role = cfg.Mode == "Winner" and "Initiator" or "Joiner"
local initiatorTeam = "Team1"
local joinerTeam = "Team2"

local function log(...)
    print("[DuelBot]", ...)
end

local function getOpponent()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == cfg.OpponentName:lower() then
            return plr
        end
    end
    return nil
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

local function resetCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function() humanoid.Health = 0 end)
    else
        pcall(function() char:BreakJoints() end)
    end
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
    LocalPlayer:SetAttribute("MovementACIgnore", nil)
end

local function getPlayerFromHRP(part)
    if not part or part.Name ~= "HumanoidRootPart" then return nil end
    local char = part.Parent
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    return Players:GetPlayerFromCharacter(char)
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
    local teamModel = model:FindFirstChild(initiatorTeam)
    local otherModel = model:FindFirstChild(joinerTeam)
    if not teamModel or not otherModel then return nil end
    local teamDetect = teamModel:FindFirstChild("Duels Detect")
    local otherDetect = otherModel:FindFirstChild("Duels Detect")
    if not teamDetect or not otherDetect then return nil end

    local teamOcc = getOccupants(teamDetect)
    local otherOcc = getOccupants(otherDetect)
    local teamGuiCount, teamMax = readGuiCount(pad, initiatorTeam)
    local otherGuiCount, otherMax = readGuiCount(pad, joinerTeam)

    local function countDict(dict)
        local n = 0
        for _ in pairs(dict) do n = n + 1 end
        return n
    end

    local teamCount = countDict(teamOcc)
    local otherCount = countDict(otherOcc)
    if teamCount == 0 then teamCount = teamGuiCount end
    if otherCount == 0 then otherCount = otherGuiCount end

    return {
        pad = pad,
        teamDetect = teamDetect,
        otherDetect = otherDetect,
        teamOccupants = teamOcc,
        otherOccupants = otherOcc,
        teamCount = teamCount,
        otherCount = otherCount,
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

        if cfg.PadId then
            local index = tonumber(cfg.PadId)
            if index then
                local pos = table.find(pads, pad)
                if pos ~= index then continue end
            end
        end

        -- Initiator team must be empty and no random on the joiner team.
        if desc.teamCount ~= 0 then continue end
        if desc.otherCount ~= 0 and not desc.otherOccupants[opponentId] then continue end

        return desc
    end
    return nil
end

local function teleportToDetect(detect)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return nil end

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

    hrp.Anchored = false
    hrp.CFrame = targetCF

    pcall(function()
        firetouchinterest(hrp, detect, 0)
        task.wait(0.05)
        firetouchinterest(hrp, detect, 1)
    end)

    return targetCF
end

local function holdInitiatorPosition(targetCF)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    local started = tick()
    local sawWaitingId = false

    while tick() - started < 12 do
        if LocalPlayer:GetAttribute("InDuels") == true then
            return true
        end

        local offset = CFrame.new(
            math.random(-2, 2) / 12,
            math.random(-2, 2) / 12,
            math.random(-2, 2) / 12
        )
        local tween = TweenService:Create(hrp, TweenInfo.new(0.12), {CFrame = targetCF * offset})
        tween:Play()

        local waitingId = LocalPlayer:GetAttribute("DuelsWaitingPadId")
        if waitingId and waitingId ~= "" then
            sawWaitingId = true
        end

        task.wait(0.18)
    end

    return sawWaitingId
end

local function verifyMatch()
    local opponent = getOpponent()
    if not opponent then
        log("Verify: opponent not found")
        return false
    end

    if LocalPlayer:GetAttribute("InDuels") ~= true then
        log("Verify: local player not in duel")
        return false
    end

    if opponent:GetAttribute("InDuels") ~= true then
        log("Verify: opponent not in duel")
        return false
    end

    local myMatch = tostring(LocalPlayer:GetAttribute("DuelsMatchId") or "")
    local oppMatch = tostring(opponent:GetAttribute("DuelsMatchId") or "")
    if myMatch == "" or myMatch ~= oppMatch then
        log("Verify: match id mismatch (mine:", myMatch, " theirs:", oppMatch, ")")
        return false
    end

    local myTeam = LocalPlayer:GetAttribute("DuelsTeam")
    local oppTeam = opponent:GetAttribute("DuelsTeam")
    if myTeam ~= "Team1" and myTeam ~= "Team2" then
        log("Verify: invalid team", myTeam)
        return false
    end
    if oppTeam ~= "Team1" and oppTeam ~= "Team2" then
        log("Verify: invalid opponent team", oppTeam)
        return false
    end
    if myTeam == oppTeam then
        log("Verify: both on same team")
        return false
    end

    return true
end

local function runInitiator()
    local opponent = getOpponent()
    if not opponent then
        log("Initiator: opponent not found")
        return false
    end

    local selectedPad = nil
    if cfg.PadId then
        for idx, pad in ipairs(getAll1v1Pads()) do
            if tonumber(cfg.PadId) == idx then
                selectedPad = getPadDescriptor(pad)
                break
            end
        end
    else
        for attempt = 1, 60 do
            selectedPad = findSuitablePad(opponent)
            if selectedPad then break end
            task.wait(0.5)
        end
    end

    if not selectedPad then
        log("Initiator: no suitable pad")
        return false
    end

    log("Initiator: teleporting to", initiatorTeam)
    local targetCF = teleportToDetect(selectedPad.teamDetect)
    if not targetCF then
        log("Initiator: teleport failed")
        return false
    end

    log("Initiator: holding pad")
    local ok = holdInitiatorPosition(targetCF)
    unfreeze()

    if not ok then
        log("Initiator: pad was not claimed")
        return false
    end

    if verifyMatch() then
        return true
    end

    log("Initiator: matched with wrong player")
    return false
end

local function runJoiner()
    local opponent = getOpponent()
    if not opponent then
        log("Joiner: opponent not found")
        return false
    end

    log("Joiner: waiting for", opponent.Name, "to claim a pad")
    local padId = nil
    for i = 1, 150 do
        -- Don't teleport if the opponent already started a duel with someone else.
        if opponent:GetAttribute("InDuels") == true then
            log("Joiner: opponent already in duel")
            return false
        end

        padId = opponent:GetAttribute("DuelsWaitingPadId")
        if padId and padId ~= "" then
            break
        end
        task.wait(0.05)
    end

    if not padId then
        log("Joiner: never saw a pad invite")
        return false
    end

    log("Joiner: teleporting to pad", padId)
    DuelsPadUI:FireServer("TELEPORT_LOBBY_DUEL_PAD", padId)

    for i = 1, 80 do
        if LocalPlayer:GetAttribute("InDuels") == true then
            break
        end
        task.wait(0.1)
    end

    unfreeze()

    if verifyMatch() then
        return true
    end

    log("Joiner: did not end up in the correct duel")
    return false
end

local function main()
    log("Starting as", cfg.Mode, "role:", role, "opponent:", cfg.OpponentName)

    local myChar = waitForCharacter(LocalPlayer, 30)
    if not myChar then
        log("ERROR: Character did not load")
        return
    end

    for attempt = 1, 10 do
        if verifyMatch() then
            log("SUCCESS: both accounts are in the same duel (match:", tostring(LocalPlayer:GetAttribute("DuelsMatchId")), ")")
            return
        end

        log("Attempt", attempt, "...")
        local ok = false
        if role == "Initiator" then
            ok = runInitiator()
        else
            ok = runJoiner()
        end

        if ok and verifyMatch() then
            log("SUCCESS: both accounts are in the same duel (match:", tostring(LocalPlayer:GetAttribute("DuelsMatchId")), ")")
            return
        end

        log("Attempt failed, resetting...")
        resetCharacter()
        task.wait(3)
    end

    log("ERROR: Could not start a 1v1 duel with", cfg.OpponentName)
end

local ok, err = pcall(main)
if not ok then
    log("CRASH:", err)
    unfreeze()
end
