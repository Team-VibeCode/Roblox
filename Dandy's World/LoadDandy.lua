local LobbyID = 200
local GameID = 300

local PlaceID = game.PlaceId

if PlaceID == LobbyID then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Team-VibeCode/Roblox/refs/heads/main/Dandy's%20World/Lobby.lua"))()
elseif PlaceID == GameID then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Team-VibeCode/Roblox/refs/heads/main/Dandy's%20World/Run.lua"))()
end
