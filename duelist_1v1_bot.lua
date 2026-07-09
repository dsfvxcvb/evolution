-- Duelist 1v1 bot: teleports two configured accounts onto the same 1vs1 pad.
-- Config (set before running):
--   getgenv().DuelBotMode     = "Winner" or "Loser"
--   getgenv().DuelBotOpponent = "OtherAccountUsername"
-- Optional: force both accounts to use the same pad id (use MCP to pick a free one)
--   getgenv().DuelBotPadId    = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

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

local function getPadDescriptor(pad)
    local model = pad:FindFirstChild("Model")
    if not model then return nil end
    local teamModel = model:FindFirstChild(assignedTeam)
    local otherModel = model:FindFirstChild(otherTeam)
    if not teamModel or not otherModel then return nil end
    local teamDetect = teamModel:FindFirstChild("Duels Detect")
    local otherDetect = otherModel:FindFirstChild("Duels Detect")
    if not teamDetect or not otherDetect then return nil end

    local function readCount(teamName)
        local screen = pad:FindFirstChild("Screen")
        local teamPart = screen and screen:FindFirstChild(teamName)
        if not teamPart then return 0, nil end
        local numberLabel = nil
        for _, d in ipairs(teamPart:GetDescendants()) do
            if d:IsA("TextLabel") and d.Name == "Number" then
                numberLabel = d
                break
            end
        end
        if not numberLabel then return 0, nil end
        local count, max = numberLabel.Text:match("(%d+)/(%d+)")
        return tonumber(count) or 0, tonumber(max) or 1
    end

    local function readOccupantId(teamName)
        local screen = pad:FindFirstChild("Screen")
        local teamPart = screen and screen:FindFirstChild(teamName)
        if not teamPart then return nil end
        local pg = nil
        for _, d in ipairs(teamPart:GetDescendants()) do
            if d:IsA("SurfaceGui") and d.Name == "ParticipantsGui" then
                pg = d
                break
            end
        end
        if not pg then return nil end
        local container = pg:FindFirstChild("Container")
        if not container then return nil end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("GuiObject") then
                local uid = tonumber(child.Name)
                if uid and uid ~= 0 then
                    return uid
                end
            end
        end
        return nil
    end

    return {
        pad = pad,
        padId = pad:GetAttribute("DuelsPadId"),
        teamDetect = teamDetect,
        otherDetect = otherDetect,
        teamCount = readCount(assignedTeam),
        teamMax = select(2, readCount(assignedTeam)) or 1,
        otherCount = readCount(otherTeam),
        otherOccupantId = readOccupantId(otherTeam),
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
        if desc.teamCount ~= 0 then continue end
        if desc.otherCount == 0 then
            return desc
        end
        if opponentId ~= 0 and desc.otherOccupantId == opponentId then
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

    local targetCF = detect.CFrame * CFrame.new(0, 3, 0)
    local distance = (hrp.Position - targetCF.Position).Magnitude
    local duration = math.clamp(distance / 800, 1.2, 3)

    humanoid.PlatformStand = false
    humanoid.Sit = false

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()

    hrp.Anchored = true
    hrp.CFrame = targetCF
    return true
end

local function unfreeze()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored = false end
    if humanoid then humanoid.PlatformStand = false end
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
        for _, pad in ipairs(getAll1v1Pads()) do
            local desc = getPadDescriptor(pad)
            if desc and tostring(desc.padId) == tostring(cfg.PadId) then
                selectedPad = desc
                break
            end
        end
        if not selectedPad then
            log("ERROR: Could not find pad with id", cfg.PadId)
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
    log("Selected pad", selectedPad.pad.Name, "id:", selectedPad.padId, "team:", assignedTeam)

    local success = teleportToDetect(selectedPad.teamDetect)
    if not success then
        log("ERROR: Teleport failed")
        unfreeze()
        LocalPlayer:SetAttribute("MovementACIgnore", nil)
        return
    end

    log("Anchored on pad, waiting for duel to start...")
    local inDuel = false
    for i = 1, 80 do
        if LocalPlayer:GetAttribute("InDuels") == true then
            inDuel = true
            break
        end
        task.wait(0.1)
    end

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
