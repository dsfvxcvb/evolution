if game.PlaceId == 9825515356 then
    loadfile("C:/Users/Adkin/Downloads/scripts/evolution_hood.lua")()
elseif game.PlaceId == 90568084448279 then
    loadfile("C:/Users/Adkin/Downloads/scripts/evolution_onetap.lua")()
else
    game:GetService("Players").LocalPlayer:Kick("[evolution] Game not supported (PlaceId " .. tostring(game.PlaceId) .. ")")
end
