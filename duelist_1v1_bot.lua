-- Duelist 1v1 bot: both accounts physically walk/run to a 1vs1 pad.
--
-- WHERE TO PUT THE NAMES:
--   On the account that should be the Winner, run:
--       getgenv().DuelBotMode     = "Winner"
--       getgenv().DuelBotOpponent = "emBerywooD"   -- the Loser's username
--       loadstring(game:HttpGet("https://raw.githubusercontent.com/dsfvxcvb/evolution/main/duelist_1v1_bot.lua"))()
--
--   On the account that should be the Loser, run:
--       getgenv().DuelBotMode     = "Loser"
--       getgenv().DuelBotOpponent = "lyynxryn"     -- the Winner's username
--       loadstring(game:HttpGet("https://raw.githubusercontent.com/dsfvxcvb/evolution/main/duelist_1v1_bot.lua"))()

local cfg = {
    Mode = getgenv().DuelBotMode or "Winner",
    OpponentName = getgenv().DuelBotOpponent or "",
    TpWalk = getgenv().DuelBotTpWalk or 2,       -- studs to "tp walk" per frame
    WalkSpeed = getgenv().DuelBotWalkSpeed or 64, -- normal walkspeed boost
}

assert(cfg.OpponentName ~= "", "DuelBotOpponent must be set")
assert(cfg.Mode == "Winner" or cfg.Mode == "Loser", "DuelBotMode must be 'Winner' or 'Loser'")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local active = true
local currentMoveConn = nil

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

local function waitForCharacter(timeout)
    timeout = timeout or 30
    local t0 = tick()
    while not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")) do
        if tick() - t0 > timeout then return nil end
        task.wait(0.1)
    end
    return LocalPlayer.Character
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

local function stopMove()
    if currentMoveConn then
        pcall(function() currentMoveConn:Disconnect() end)
        currentMoveConn = nil
    end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:Move(Vector3.zero)
    end
end

local function tpWalkTo(targetPos)
    -- "TP walk" style: every frame we shift the HRP a small amount toward the goal.
    -- This looks like running but ignores path distance and is AC-safe with MovementACIgnore.
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end

    LocalPlayer:SetAttribute("MovementACIgnore", true)
    hrp.Anchored = false
    humanoid.PlatformStand = false
    humanoid.Sit = false
    humanoid.WalkSpeed = cfg.WalkSpeed

    stopMove()

    local arrived = false
    currentMoveConn = RunService.Heartbeat:Connect(function()
        if not active then stopMove() return end
        if not (hrp and hrp.Parent) then stopMove() return end

        local dir = targetPos - hrp.Position
        local dist = dir.Magnitude
        if dist <= 1.5 then
            arrived = true
            stopMove()
            return
        end

        dir = dir.Unit
        local step = math.min(dist, cfg.TpWalk)
        local newPos = hrp.Position + dir * step

        -- Keep current orientation, just change position.
        hrp.CFrame = hrp.CFrame - hrp.CFrame.Position + newPos
    end)

    local t0 = tick()
    while active and not arrived do
        if tick() - t0 > 30 then
            log("tpWalkTo timed out")
            stopMove()
            return false
        end
        task.wait(0.05)
    end

    -- Small settle jiggle so the server registers us inside the pad.
    local start = tick()
    while tick() - start < 1 do
        if hrp and hrp.Parent then
            hrp.CFrame = hrp.CFrame * CFrame.new(
                math.random() * 0.04 - 0.02,
                math.random() * 0.04 - 0.02,
                math.random() * 0.04 - 0.02
            )
        end
        task.wait(0.05)
    end

    LocalPlayer:SetAttribute("MovementACIgnore", nil)
    return true
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
    local success, parts = pcall(function() return Workspace:GetPartsInPart(detectPart) end)
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
    table.sort(list, function(a, b)
        local ap = a:FindFirstChild("TP") and a.TP.Position or Vector3.zero
        local bp = b:FindFirstChild("TP") and b.TP.Position or Vector3.zero
        if ap.X ~= bp.X then return ap.X < bp.X end
        return ap.Z < bp.Z
    end)
    return list
end

local function findPadById(padId)
    for _, pad in ipairs(getAll1v1Pads()) do
        if pad:GetAttribute("DuelsPadId") == padId then
            return getPadDescriptor(pad)
        end
    end
    return nil
end

local function isPadUsable(desc, opponent)
    local opponentId = opponent and opponent.UserId or 0
    local myId = LocalPlayer.UserId

    for uid in pairs(desc.team1Occupants) do
        if uid ~= myId then return false end
    end
    for uid in pairs(desc.team2Occupants) do
        if uid ~= opponentId then return false end
    end
    return true
end

local function findCleanPad(opponent)
    for _, pad in ipairs(getAll1v1Pads()) do
        local desc = getPadDescriptor(pad)
        if desc and isPadUsable(desc, opponent) then
            return desc
        end
    end
    return nil
end

local function verifyMatch()
    local opponent = getOpponent()
    if not opponent then return false end
    if LocalPlayer:GetAttribute("InDuels") ~= true then return false end
    if opponent:GetAttribute("InDuels") ~= true then return false end

    local myMatch = tostring(LocalPlayer:GetAttribute("DuelsMatchId") or "")
    local oppMatch = tostring(opponent:GetAttribute("DuelsMatchId") or "")
    if myMatch == "" or myMatch ~= oppMatch then return false end

    local myTeam = LocalPlayer:GetAttribute("DuelsTeam")
    local oppTeam = opponent:GetAttribute("DuelsTeam")
    if myTeam ~= "Team1" and myTeam ~= "Team2" then return false end
    if oppTeam ~= "Team1" and oppTeam ~= "Team2" then return false end
    if myTeam == oppTeam then return false end

    return true
end

local function runWinner()
    local opponent = getOpponent()
    if not opponent then
        log("Winner: opponent not found")
        return false
    end

    local desc = nil
    for i = 1, 60 do
        desc = findCleanPad(opponent)
        if desc then break end
        log("Winner: waiting for a clean 1vs1 pad...")
        task.wait(0.5)
    end
    if not desc then
        log("Winner: no clean pad")
        return false
    end

    log("Winner: walking to pad", desc.padId)
    if not tpWalkTo(desc.team1Detect.CFrame.Position) then
        log("Winner: failed to reach pad")
        return false
    end

    -- Wait until the server registers us as waiting.
    for i = 1, 100 do
        local waitingId = LocalPlayer:GetAttribute("DuelsWaitingPadId")
        if waitingId and waitingId ~= "" then
            log("Winner: waiting on pad", waitingId)
            break
        end
        if verifyMatch() then return true end
        task.wait(0.05)
    end

    -- Wait for the duel to start.
    for i = 1, 120 do
        if verifyMatch() then return true end

        -- If our waiting attribute disappeared and we're not in a duel, something went wrong.
        local waitingId = LocalPlayer:GetAttribute("DuelsWaitingPadId")
        if not (waitingId and waitingId ~= "") and LocalPlayer:GetAttribute("InDuels") ~= true then
            log("Winner: lost waiting status (random may have pushed us off)")
            return false
        end

        task.wait(0.25)
    end

    log("Winner: duel did not start")
    return false
end

local function runLoser()
    local opponent = getOpponent()
    if not opponent then
        log("Loser: opponent not found")
        return false
    end

    log("Loser: waiting for Winner to claim a pad...")
    local padId = nil
    for i = 1, 200 do
        -- If opponent started without us, random stole the spot.
        if opponent:GetAttribute("InDuels") == true then
            log("Loser: Winner started a duel without us (random steal)")
            return false
        end

        padId = opponent:GetAttribute("DuelsWaitingPadId")
        if padId and padId ~= "" then break end
        task.wait(0.05)
    end

    if not padId then
        log("Loser: never saw Winner claim a pad")
        return false
    end

    local desc = findPadById(padId)
    if not desc then
        log("Loser: could not find pad", padId)
        return false
    end

    -- Make sure the spot is still free.
    local t2Occ = getOccupants(desc.team2Detect)
    for uid, plr in pairs(t2Occ) do
        if uid ~= LocalPlayer.UserId then
            log("Loser: random player", plr.Name, "already on Team2")
            return false
        end
    end

    log("Loser: walking to pad", padId)
    if not tpWalkTo(desc.team2Detect.CFrame.Position) then
        log("Loser: failed to reach pad")
        return false
    end

    for i = 1, 100 do
        if verifyMatch() then return true end
        task.wait(0.1)
    end

    log("Loser: duel did not start")
    return false
end

local function main()
    log("Starting as", cfg.Mode, "opponent:", cfg.OpponentName)

    if not waitForCharacter(30) then
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
        if cfg.Mode == "Winner" then
            ok = runWinner()
        else
            ok = runLoser()
        end

        if ok and verifyMatch() then
            log("SUCCESS: both accounts are in the same duel (match:", tostring(LocalPlayer:GetAttribute("DuelsMatchId")), ")")
            return
        end

        log("Attempt failed, resetting...")
        active = false
        stopMove()
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
    stopMove()
end
