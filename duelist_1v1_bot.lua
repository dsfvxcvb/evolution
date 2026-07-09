-- Duelist 1v1 bot: both accounts physically run/walk to a 1vs1 pad.
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
--
-- Optional globals:
--   getgenv().DuelBotWalkSpeed = 64   -- normal speed boost
--   getgenv().DuelBotTpWalk    = 0    -- set to 2 for Infinite-Yield-style tp-walk
--   getgenv().DuelBotAutoKill  = true -- auto-configures silent aim (wallcheck off, auto fire on)
--
-- To stop when running manually, set:
--   getgenv().DuelBotEnabled = false

local cfg = {
    Mode = getgenv().DuelBotMode or "Winner",
    OpponentName = getgenv().DuelBotOpponent or "",
    TpWalk = getgenv().DuelBotTpWalk or 0,
    WalkSpeed = getgenv().DuelBotWalkSpeed or 64,
    AutoKill = getgenv().DuelBotAutoKill or false,
}

assert(cfg.OpponentName ~= "", "DuelBotOpponent must be set")
assert(cfg.Mode == "Winner" or cfg.Mode == "Loser", "DuelBotMode must be 'Winner' or 'Loser'")

-- If loaded from the UI, Enabled is already managed. If run manually, default to looping.
if getgenv().DuelBotEnabled == nil then
    getgenv().DuelBotEnabled = true
end
getgenv().DuelBotStop = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local activeMoveConn = nil

local function log(...)
    print("[DuelBot]", ...)
end

local function isActive()
    return getgenv().DuelBotEnabled == true and getgenv().DuelBotStop ~= true
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
    if activeMoveConn then
        pcall(function() activeMoveConn:Disconnect() end)
        activeMoveConn = nil
    end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:Move(Vector3.zero)
    end
    LocalPlayer:SetAttribute("MovementACIgnore", nil)
end

local function applyAutoKill()
    if not cfg.AutoKill then return end
    local evo = getgenv().EvolutionDuelist
    if not evo then return end
    evo.SilentAimEnabled = true
    evo.AutoFire = true
    evo.WallCheck = false
    evo.TeamCheck = false
    evo.HitPart = "Head"
    evo.Hitchance = 100
    evo.MaxDistance = 5000
    evo.RapidFire = true
    log("AutoKill: silent aim configured")
end

local function moveTo(targetPos)
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
    if cfg.TpWalk > 0 then
        -- Infinite-Yield-style tp walk.
        activeMoveConn = RunService.Heartbeat:Connect(function()
            if not isActive() then stopMove() return end
            if not (hrp and hrp.Parent) then stopMove() return end
            local dir = targetPos - hrp.Position
            local dist = dir.Magnitude
            if dist <= 2 then
                arrived = true
                stopMove()
                return
            end
            dir = dir.Unit
            local step = math.min(dist, cfg.TpWalk)
            local newPos = hrp.Position + dir * step
            hrp.CFrame = hrp.CFrame - hrp.CFrame.Position + newPos
        end)
    else
        -- Normal run with speed hack.
        local conn
        conn = humanoid.MoveToFinished:Connect(function(reached)
            arrived = arrived or reached
        end)
        activeMoveConn = conn

        local function refreshMove()
            if not isActive() then return end
            humanoid:MoveTo(targetPos)
        end
        refreshMove()

        task.spawn(function()
            while not arrived and isActive() and hrp and hrp.Parent do
                if (hrp.Position - targetPos).Magnitude <= 2 then
                    arrived = true
                    break
                end
                refreshMove()
                task.wait(0.4)
            end
        end)
    end

    local t0 = tick()
    while isActive() and not arrived do
        if tick() - t0 > 25 then
            log("moveTo timed out")
            stopMove()
            return false
        end
        task.wait(0.05)
    end

    if not isActive() then return false end

    -- Settle so the server registers us.
    task.wait(0.6)
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

local function isPadCleanForWinner(desc, opponent)
    local myId = LocalPlayer.UserId
    local opponentId = opponent and opponent.UserId or 0
    local t1 = getOccupants(desc.team1Detect)
    local t2 = getOccupants(desc.team2Detect)
    for uid in pairs(t1) do
        if uid ~= myId then return false end
    end
    for uid in pairs(t2) do
        if uid ~= opponentId then return false end
    end
    return true
end

local function findCleanPad(opponent)
    for _, pad in ipairs(getAll1v1Pads()) do
        local desc = getPadDescriptor(pad)
        if desc and isPadCleanForWinner(desc, opponent) then
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
        return "stop"
    end

    local desc = nil
    for i = 1, 40 do
        desc = findCleanPad(opponent)
        if desc then break end
        if not isActive() then return "stop" end
        log("Winner: waiting for a clean 1vs1 pad...")
        task.wait(0.5)
    end
    if not desc then
        log("Winner: no clean pad")
        return "retry"
    end

    log("Winner: moving to pad", desc.padId)
    if not isPadCleanForWinner(desc, opponent) then
        log("Winner: pad became dirty before move")
        return "retry"
    end

    if not moveTo(desc.team1Detect.CFrame.Position) then
        log("Winner: failed to reach pad")
        return "retry"
    end

    -- Wait for the server to register us as the waiting initiator.
    local sawWaiting = false
    for i = 1, 120 do
        if not isActive() then return "stop" end
        if verifyMatch() then return "success" end
        local waitingId = LocalPlayer:GetAttribute("DuelsWaitingPadId")
        if waitingId and waitingId ~= "" then
            sawWaiting = true
            log("Winner: waiting on pad", waitingId)
            break
        end
        task.wait(0.05)
    end

    if not sawWaiting then
        log("Winner: server never registered us")
        return "retry"
    end

    -- Wait for the duel to actually start.
    local waitingGoneAt = nil
    for i = 1, 240 do
        if not isActive() then return "stop" end
        if verifyMatch() then return "success" end

        -- If our waiting attribute disappeared, give the server a moment to set InDuels.
        local waitingId = LocalPlayer:GetAttribute("DuelsWaitingPadId")
        if not (waitingId and waitingId ~= "") then
            if not waitingGoneAt then waitingGoneAt = tick() end
            if tick() - waitingGoneAt > 3 then
                log("Winner: lost waiting status")
                return "retry"
            end
        else
            waitingGoneAt = nil
        end

        -- Random player took Team2 while we were waiting.
        local t2 = getOccupants(desc.team2Detect)
        for uid, plr in pairs(t2) do
            if uid ~= opponent.UserId then
                log("Winner: random player", plr.Name, "took Team2")
                return "retry"
            end
        end

        task.wait(0.25)
    end

    log("Winner: duel did not start in time")
    return "retry"
end

local function runLoser()
    local opponent = getOpponent()
    if not opponent then
        log("Loser: opponent not found")
        return "stop"
    end

    log("Loser: waiting for Winner to claim a pad...")
    local padId = nil
    for i = 1, 200 do
        if not isActive() then return "stop" end

        -- If opponent started without us, a random stole the spot.
        if opponent:GetAttribute("InDuels") == true then
            log("Loser: Winner already in a duel (random steal or we were too slow)")
            return "retry"
        end

        padId = opponent:GetAttribute("DuelsWaitingPadId")
        if padId and padId ~= "" then break end
        task.wait(0.05)
    end

    if not padId then
        log("Loser: never saw Winner claim a pad")
        return "retry"
    end

    local desc = findPadById(padId)
    if not desc then
        log("Loser: could not find pad", padId)
        return "retry"
    end

    -- Make sure the spot is still free.
    local t2 = getOccupants(desc.team2Detect)
    for uid, plr in pairs(t2) do
        if uid ~= LocalPlayer.UserId then
            log("Loser: random player", plr.Name, "already on Team2")
            return "retry"
        end
    end

    log("Loser: moving to pad", padId)
    if not moveTo(desc.team2Detect.CFrame.Position) then
        log("Loser: failed to reach pad")
        return "retry"
    end

    for i = 1, 240 do
        if not isActive() then return "stop" end
        if verifyMatch() then return "success" end

        -- If winner already finished without us, random stole.
        if opponent:GetAttribute("InDuels") == true then
            log("Loser: Winner started without us")
            return "retry"
        end

        task.wait(0.25)
    end

    log("Loser: duel did not start in time")
    return "retry"
end

local function main()
    log("Starting as", cfg.Mode, "opponent:", cfg.OpponentName)

    if not waitForCharacter(30) then
        log("ERROR: Character did not load")
        return
    end

    applyAutoKill()

    while isActive() do
        if verifyMatch() then
            log("SUCCESS: both accounts are in the same duel (match:", tostring(LocalPlayer:GetAttribute("DuelsMatchId")), ")")
            applyAutoKill()
            break
        end

        local result = "retry"
        if cfg.Mode == "Winner" then
            result = runWinner()
        else
            result = runLoser()
        end

        if result == "success" or verifyMatch() then
            log("SUCCESS: both accounts are in the same duel (match:", tostring(LocalPlayer:GetAttribute("DuelsMatchId")), ")")
            applyAutoKill()
            break
        elseif result == "stop" then
            log("Stopped")
            break
        end

        log("Retrying in 5s...")
        stopMove()
        resetCharacter()
        task.wait(5)
        applyAutoKill()
    end

    stopMove()
    getgenv().DuelBotEnabled = false
    getgenv().DuelBotStop = false
    log("Finished")
end

local ok, err = pcall(main)
if not ok then
    log("CRASH:", err)
    stopMove()
    getgenv().DuelBotEnabled = false
    getgenv().DuelBotStop = false
end
