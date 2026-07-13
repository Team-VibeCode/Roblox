local Script_Version = "V.1"
local Version = "1.6.64"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
-------------------------------------------------------------------------------------------------------------------
local Window = WindUI:CreateWindow({
    Title = "Dandy's Abuse Hub",
    Icon = "door-open",
    Author = "by Team-VibeCode",
    Folder = "DandyAbuseHub",
})

Window:Tag({
    Title = Script_Version,
    Icon = "book-marked",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 30,
})
-------------------------------------------------------------------------------------------------------------------
local AC = game.ReplicatedStorage:FindFirstChild("AntiCheatTrigger", true)
if AC then
    AC:Destroy()
end
-------------------------------------------------------------------------------------------------------------------
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "globe",
    Locked = false,
})

local DandyStore = workspace:WaitForChild("DandyStore")
local AnimationsFolder = DandyStore:WaitForChild("Animations")

local animationNames = {}
local animationObjects = {}
local CurrentTrack = nil
local LoopEnabled = false

for _, obj in ipairs(AnimationsFolder:GetChildren()) do
    if obj:IsA("Animation") then
        local displayName = obj.Name:gsub("^L_", ""):gsub("_", " ")
        table.insert(animationNames, displayName)
        animationObjects[displayName] = obj
    end
end

local SelectedAnimation = animationNames[1]

local AnimationsDropdown = MainTab:Dropdown({
    Title = "Dandy's Animations",
    Desc = "Select an animation to play",
    Values = animationNames,
    Value = animationNames[1],
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        SelectedAnimation = option
    end
})

local function playAnimation()
    local anim = animationObjects[SelectedAnimation]
    if not anim then return end
    
    local humanoid = DandyStore:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    if CurrentTrack then
        CurrentTrack:Stop()
    end
    
    CurrentTrack = animator:LoadAnimation(anim)
    CurrentTrack.Looped = LoopEnabled
    CurrentTrack:Play()
    
    if LoopEnabled then
        CurrentTrack.Stopped:Connect(function()
            if LoopEnabled and CurrentTrack then
                CurrentTrack:Play()
            end
        end)
    end
end

local PlayAnimationButton = MainTab:Button({
    Title = "Play Selected Animation",
    Desc = "Plays the chosen animation",
    Locked = false,
    Callback = playAnimation
})

local StopAnimationButton = MainTab:Button({
    Title = "Stops Animation",
    Desc = "Stops current animation",
    Locked = false,
    Callback = function(state)
        if CurrentTrack then
        CurrentTrack:Stop()
    end
end
})


local AnimationLoopToggle = MainTab:Toggle({
    Title = "Animation Looping",
    Desc = "Toggles whether or not animations should loop",
    Icon = "check",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        LoopEnabled = state
        if CurrentTrack then
            CurrentTrack.Looped = state
            if state then
                CurrentTrack:Play()
            else
                CurrentTrack:Stop()
            end
        end
    end
})
-------------------------------------------------------------------------------------------------------------------
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "file-text",
    Locked = false,
})

local collisionEnabled = true

local ToggleCollisionButton = MiscTab:Button({
    Title = "Toggle Door collision to Dandy's Shop",
    Locked = false,
    Callback = function()
        collisionEnabled = not collisionEnabled
        
        local parts = {
            workspace:FindFirstChild("DevDoor") and workspace.DevDoor:FindFirstChild("DevDoorPart"),
            workspace:FindFirstChild("Lobby") 
                and workspace.Lobby:FindFirstChild("DandyRoom") 
                and workspace.Lobby.DandyRoom:FindFirstChild("Walls") 
                and workspace.Lobby.DandyRoom.Walls:FindFirstChild("Collider"),
            workspace:FindFirstChild("DevDoor2") and workspace.DevDoor2:FindFirstChild("DevDoorPart")
        }
        
        for _, part in pairs(parts) do
            if part and part:IsA("BasePart") then
                part.CanCollide = collisionEnabled
            end
        end
    end
})
-------------------------------------------------------------------------------------------------------------------
local AnimationTab = Window:Tab({
    Title = "Animations",
    Icon = "user",
    Locked = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name

local PlayerAnimNames = {}
local PlayerAnimObjects = {}
local PlayerCurrentTrack = nil
local PlayerSelectedAnim = nil
local PlayerLoopEnabled = false

local function getPlayerAnimations()
    PlayerAnimNames = {}
    PlayerAnimObjects = {}
    
    local character = workspace:FindFirstChild(PlayerName) or LocalPlayer.Character
    if not character then return {} end
    
    local animsFolder = character:FindFirstChild("Animations")
    if not animsFolder then return {} end
    
    for _, obj in ipairs(animsFolder:GetChildren()) do
        if obj:IsA("Animation") then
            local displayName = obj.Name
            if displayName == "Decode" then
                displayName = "Extracting"
            else
                displayName = displayName:gsub("^L_", ""):gsub("_", " ")
            end
            table.insert(PlayerAnimNames, displayName)
            PlayerAnimObjects[displayName] = obj
        end
    end
    
    return PlayerAnimNames
end

local initialAnims = getPlayerAnimations()
if #initialAnims == 0 then initialAnims = {"No animations"} end

local PlayerAnimDropdown = AnimationTab:Dropdown({
    Title = "Player Animations",
    Desc = "Animations available for your character",
    Values = initialAnims,
    Value = initialAnims[1],
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        PlayerSelectedAnim = option
    end
})

AnimationTab:Button({
    Title = "Refresh List",
    Callback = function()
        local newList = getPlayerAnimations()
        if #newList == 0 then newList = {"No animations"} end
        PlayerAnimDropdown:SetValues(newList)
    end
})

AnimationTab:Toggle({
    Title = "Animation Looping",
    Desc = "Toggle animation looping",
    Icon = "check",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        PlayerLoopEnabled = state
        if PlayerCurrentTrack then
            PlayerCurrentTrack.Looped = state
        end
    end
})

local function playPlayerAnimation()
    local anim = PlayerAnimObjects[PlayerSelectedAnim]
    if not anim then return end
    
    local character = workspace:FindFirstChild(PlayerName) or LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    if PlayerCurrentTrack then
        PlayerCurrentTrack:Stop()
    end
    
    PlayerCurrentTrack = animator:LoadAnimation(anim)
    PlayerCurrentTrack.Looped = PlayerLoopEnabled
    PlayerCurrentTrack:Play()
    
    if PlayerLoopEnabled then
        PlayerCurrentTrack.Stopped:Connect(function()
            if PlayerLoopEnabled and PlayerCurrentTrack then
                PlayerCurrentTrack:Play()
            end
        end)
    end
end

AnimationTab:Button({
    Title = "Play Selected Animation",
    Desc = "Plays the chosen animation",
    Locked = false,
    Callback = playPlayerAnimation
})

AnimationTab:Button({
    Title = "Stop Animation",
    Desc = "Stops current animation",
    Locked = false,
    Callback = function()
        if PlayerCurrentTrack then
            PlayerCurrentTrack:Stop()
        end
    end
})
