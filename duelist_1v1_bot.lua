-- Duelist 1v1 bot: coordinates two configured accounts into the same 1vs1 duel.
-- Config (set before running):
--   getgenv().DuelBotMode     = "Winner" or "Loser"
--   getgenv().DuelBotOpponent = "OtherAccountUsername"
-- Optional:
--   getgenv().DuelBotPadId    = "00000000-..."  -- force a specific 1vs1 pad

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
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DuelsPadUI = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DuelsPadUI")
local LobbySpawn = Workspace:WaitForChild("Lobby"):WaitForChild("LobbySpawn")

local role = cfg.Mode == "Winner" and "Initiator" or "Joiner"
local active = true

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
            occupants[plr.UserId] = plr
        end
    end
    return occupants
end

local function getPadDescriptor(pad)
    local padId = pad:GetAttribute("DuelsPadId")
    if not padId then return nil end
    local model = pad:FindFirstChild("Model")
    if not model then return nil end
    local team1Model = model:FindFirstChild("Team1")
    local team2Model = model:FindFirstChild("Team2")
    if not team1Model or not team2Model then return nil end
    local team1Detect = team1Model:FindFirstChild("Duels Detect")
    local team2Detect = team2Model:FindFirstChild("Duels Detect")
    if not team1Detect or not team2Detect then return nil end

    return {
        pad = pad,
        padId = padId,
        team1Detect = team1Detect,
        team2Detect = team2Detect,
        team1Occupants = getOccupants(team1Detect),
        team2Occupants = getOccupants(team2Detect),
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
    -- Deterministic order so both clients pick the same pad when possible.
    table.sort(list, function(a, b)
        local ap = a:FindFirstChild("TP") and a.TP.Position or Vector3.zero
        local bp = b:FindFirstChild("TP") and b.TP.Position or Vector3.zero
        if ap.X ~= bp.X then return ap.X < bp.X end
        return ap.Z < bp.Z
    end)
    return list
end

local function isPadUsable(desc, opponent)
    local opponentId = opponent and opponent.UserId or 0
    local myId = LocalPlayer.UserId

    -- Team1 must be empty (we will claim it) unless it's us.
    for uid in pairs(desc.team1Occupants) do
        if uid ~= myId then return false end
    end
    -- Team2 must be empty unless it's our opponent.
    for uid in pairs(desc.team2Occupants) do
        if uid ~= opponentId then return false end
    end
    return true
end

local function findPad(opponent)
    local pads = getAll1v1Pads()
    for _, pad in ipairs(pads) do
        local desc = getPadDescriptor(pad)
        if desc then
            if cfg.PadId and desc.padId == cfg.PadId then
                if isPadUsable(desc, opponent) then
                    return desc
                end
            elseif not cfg.PadId and isPadUsable(desc, opponent) then
                return desc
            end
        end
    end
    return nil
end

local function tweenToCFrame(targetCF)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    hrp.Anchored = false
    humanoid.PlatformStand = false
    humanoid.Sit = false
    humanoid.AutoRotate = false

    LocalPlayer:SetAttribute("MovementACIgnore", true)

    local distance = (hrp.Position - targetCF.Position).Magnitude
    local duration = math.clamp(distance / 180, 0.5, 3)

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()

    return true
end

local function nudgeToRegister()
    -- Small unanchored CFrame jiggle so the server acknowledges our position.
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.Anchored = false
    local started = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not active then conn:Disconnect() return end
        if tick() - started > 1.5 then conn:Disconnect() return end
        if hrp and hrp.Parent then
            hrp.CFrame = hrp.CFrame * CFrame.new(
                math.random() * 0.04 - 0.02,
                math.random() * 0.04 - 0.02,
                math.random() * 0.04 - 0.02
            )
        end
    end)
    task.wait(1.6)
end

local function returnToLobbySpawn()
    unfreeze()
    local ok = tweenToCFrame(LobbySpawn.CFrame + Vector3.new(0, 3, 0))
    if ok then
        task.wait(0.5)
    end
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

    local desc = nil
    for i = 1, 60 do
        desc = findPad(opponent)
        if desc then break end
        log("Initiator: waiting for a clean 1vs1 pad...")
        task.wait(0.5)
    end
    if not desc then
        log("Initiator: no clean pad available")
        return false
    end

    log("Initiator: claiming pad", desc.padId)

    -- Last-second random check.
    desc = getPadDescriptor(desc.pad)
    if not desc or not isPadUsable(desc, opponent) then
        log("Initiator: pad became dirty before teleport")
        return false
    end

    if not tweenToCFrame(desc.team1Detect.CFrame) then
        log("Initiator: teleport failed")
        return false
    end

    nudgeToRegister()

    -- Wait for the server to register us as the waiting initiator.
    local waitingId = nil
    for i = 1, 100 do
        waitingId = LocalPlayer:GetAttribute("DuelsWaitingPadId")
        if waitingId and waitingId ~= "" then break end
        if LocalPlayer:GetAttribute("InDuels") == true then break end
        task.wait(0.05)
    end

    if not (waitingId and waitingId ~= "") and LocalPlayer:GetAttribute("InDuels") ~= true then
        log("Initiator: server did not register us on the pad")
        return false
    end

    log("Initiator: waiting on pad", waitingId or desc.padId)

    -- Stand still and let the server handle movement from here.
    unfreeze()

    -- Wait until the duel actually starts (or we time out).
    for i = 1, 120 do
        if verifyMatch() then return true end
        task.wait(0.25)
    end

    log("Initiator: did not end up in the correct duel")
    return false
end

local function runJoiner()
    local opponent = getOpponent()
    if not opponent then
        log("Joiner: opponent not found")
        return false
    end

    log("Joiner: waiting for invite from", opponent.Name)
    local padId = nil
    for i = 1, 200 do
        -- If the opponent started a duel without us, a random stole the spot.
        if opponent:GetAttribute("InDuels") == true then
            log("Joiner: opponent is already in a duel (random likely stole)")
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

    log("Joiner: accepting invite to pad", padId)

    -- Fire the accept remote immediately; don't use MovementACIgnore here.
    DuelsPadUI:FireServer("TELEPORT_LOBBY_DUEL_PAD", padId)

    -- Wait to be placed into the duel.
    for i = 1, 100 do
        if verifyMatch() then return true end
        task.wait(0.1)
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
        active = false
        unfreeze()
        returnToLobbySpawn()
        resetCharacter()
        task.wait(4)
        active = true
    end

    log("ERROR: Could not start a 1v1 duel with", cfg.OpponentName)
end

local ok, err = pcall(main)
if not ok then
    log("CRASH:", err)
    active = false
    unfreeze()
end
