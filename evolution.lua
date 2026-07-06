local repo = "https://raw.githubusercontent.com/dsfvxcvb/evolution/main/"

if game.PlaceId == 9825515356 then
    loadstring(game:HttpGet(repo .. "protected.lua"))()
    loadstring(game:HttpGet(repo .. "evolution_hood.lua"))()
elseif game.PlaceId == 90568084448279 then
    loadstring(game:HttpGet(repo .. "evolution_onetap.lua"))()
elseif game.PlaceId == 122310270867133 then
    loadstring(game:HttpGet(repo .. "evolution_duelist.lua"))()
else
    loadstring(game:HttpGet(repo .. "protected.lua"))()
    loadstring(game:HttpGet(repo .. "evolution_hood.lua"))()
end
