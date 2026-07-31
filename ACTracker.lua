local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AC = {
    serverPos = {},
    smoothed = {},
    lastValid = {},
    conns = {},
    MAX_DELTA = 1000,
    SMOOTH_ALPHA = 0.15,
    RECONCILE = 50
}

local function trackPlayer(p)
    if AC.conns[p.UserId] then return end
    local function onChar(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        AC.smoothed[p.UserId] = hrp.CFrame
        AC.lastValid[p.UserId] = hrp.CFrame
        AC.serverPos[p.UserId] = hrp.CFrame
        AC.conns[p.UserId] = hrp:GetPropertyChangedSignal("CFrame"):Connect(function()
            local incoming = hrp.CFrame
            local last = AC.lastValid[p.UserId]
            if last and (incoming.Position - last.Position).Magnitude > AC.MAX_DELTA then return end
            AC.lastValid[p.UserId] = incoming
            AC.smoothed[p.UserId] = (AC.smoothed[p.UserId] or incoming):Lerp(incoming, AC.SMOOTH_ALPHA)
            AC.serverPos[p.UserId] = AC.smoothed[p.UserId]
        end)
    end
    if p.Character then onChar(p.Character) end
    p.CharacterAdded:Connect(onChar)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then trackPlayer(p) end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then trackPlayer(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    AC.serverPos[p.UserId] = nil
    AC.smoothed[p.UserId] = nil
    AC.lastValid[p.UserId] = nil
    if AC.conns[p.UserId] then
        AC.conns[p.UserId]:Disconnect()
        AC.conns[p.UserId] = nil
    end
end)

return AC
