local repo = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/"

if game.PlaceId == 9825515356 then
    loadstring(game:HttpGet(repo .. "evolution_hood.lua"))()
elseif game.PlaceId == 90568084448279 then
    loadstring(game:HttpGet(repo .. "evolution_onetap.lua"))()
else
    game:GetService("Players").LocalPlayer:Kick("[evolution] Game not supported (PlaceId " .. tostring(game.PlaceId) .. ")")
end
