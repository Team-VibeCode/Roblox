local scriptName = ...

local scripts = {
    ["Step Carefully"] = "https://raw.githubusercontent.com/Team-VibeCode/Roblox/refs/heads/main/TreadLightly/Step%20Carefully.lua",
    ["Dandy's Abuse Hub"] = "https://raw.githubusercontent.com/Team-VibeCode/Roblox/refs/heads/main/Dandy's%20World/Lobby.lua",
}

if not scriptName then
    warn("Usage: loadstring(...)('ScriptName')")
    warn("Available scripts: " .. table.concat(table.keys(scripts), ", "))
    return
end

local url = scripts[scriptName]

if url then
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("Failed to load " .. scriptName .. ": " .. tostring(err))
    end
else
    warn("Script '" .. tostring(scriptName) .. "' not found.")
    warn("Available: " .. table.concat(table.keys(scripts), ", "))
end
