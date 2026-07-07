local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local autoStepEnabled = false
local autoFarmEnabled = false

local trackingEnabled = false
local autofarmStartTime = 0
local startingCoins = 0
local startingRebirths = 0
local timeLabel = nil
local statsLabel = nil

local function getHighestFolderNumber()
	local mapFolder = workspace:FindFirstChild("Map")
	if not mapFolder then return 0 end
	
	local highest = 0
	for _, child in ipairs(mapFolder:GetChildren()) do
		if child:IsA("Folder") then
			local num = tonumber(child.Name)
			if num and num > 0 and num > highest then
				highest = num
			end
		end
	end
	
	return highest
end

local function getCurrentLevel()
	local success, levelText = pcall(function()
		local indicator = LocalPlayer.PlayerGui:WaitForChild("PlayerHUD"):WaitForChild("NavContainer"):WaitForChild("LevelIndicator")
		return indicator.Text
	end)
	
	if success and levelText then
		local num = tonumber(levelText:match("%d+"))
		return num or 0
	end
	
	return 0
end

local function getCoins()
	local success, coins = pcall(function()
		return LocalPlayer:WaitForChild("Coins").Value
	end)
	return success and coins or 0
end

local function getRebirths()
	local success, rebirths = pcall(function()
		return LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Rebirths").Value
	end)
	return success and rebirths or 0
end

local function formatTime(seconds)
	local hrs = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

local function updateStatsDisplay()
	if not timeLabel or not statsLabel then return end
	
	local elapsed = tick() - autofarmStartTime
	local currentCoins = getCoins()
	local currentRebirths = getRebirths()
	local earnedCoins = currentCoins - startingCoins
	local earnedRebirths = currentRebirths - startingRebirths
	local level = getCurrentLevel()
	
	timeLabel:Set({Title = "Time Elapsed", Content = "Time: " .. formatTime(elapsed)})
	statsLabel:Set({Title = "Auto Farm Stats", Content = string.format("Level: %d | Coins: +%d | Rebirths: +%d", level, earnedCoins, earnedRebirths)})
end

local function getSpawnLocationsInFolder(folder)
	local spawns = {}
	for _, child in ipairs(folder:GetDescendants()) do
		if child:IsA("SpawnLocation") or (child:IsA("BasePart") and child.Name:lower():find("spawn")) then
			table.insert(spawns, child)
		end
	end
	
	table.sort(spawns, function(a, b)
		return a.Name < b.Name
	end)
	
	return spawns
end

local function teleportToPart(part)
	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if part:IsA("BasePart") then
		part.CanCollide = true
	end
	
	hrp.CFrame = part.CFrame + Vector3.new(0, 0.7, 0)
	hrp.AssemblyLinearVelocity = Vector3.zero
end

local function fireRebirthRemote()
	local Event = game:GetService("ReplicatedStorage"):WaitForChild("RebirthRemote")
	Event:FireServer()
end

local function stepThroughFolders()
	repeat
		if not autoStepEnabled then break end
		
		local highest = getHighestFolderNumber()
		local currentLevel = getCurrentLevel()
		local startFrom = currentLevel + 1
		
		if highest == 0 or startFrom > highest then 
			task.wait(1)
			continue
		end
		
		local mapFolder = workspace:FindFirstChild("Map")
		
		for i = startFrom, highest do
			if not autoStepEnabled then break end
			
			local folder = mapFolder:FindFirstChild(tostring(i))
			if folder then
				local spawns = getSpawnLocationsInFolder(folder)
				local levelIncreased = false
				local maxRetries = 3
				
				for retry = 1, maxRetries do
					if not autoStepEnabled then break end
					if levelIncreased then break end
					
					for _, spawn in ipairs(spawns) do
						if not autoStepEnabled then break end
						teleportToPart(spawn)
						task.wait(0.4)
					end
					
					task.wait(0.5)
					
					if getCurrentLevel() >= i then
						levelIncreased = true
						break
					elseif retry < maxRetries then
						task.wait(0.5)
					end
				end
				
				if not levelIncreased then
					autoStepEnabled = false
					Rayfield:Notify({
						Title = "Step Carefully",
						Content = "Failed to advance past level " .. i .. " after " .. maxRetries .. " attempts",
						Duration = 3,
						Image = "alert"
					})
					break
				end
			end
			
			task.wait(0.2)
		end
		
		if autoStepEnabled and autoFarmEnabled then
			task.wait(0.5)
			fireRebirthRemote()
			task.wait(2)
		else
			autoStepEnabled = false
		end
		
	until not autoStepEnabled or not autoFarmEnabled
end

local Window = Rayfield:CreateWindow({
	Name = "SC | Tread Lightly UI",
	Icon = 0,
	LoadingTitle = "Tread Lightly",
	LoadingSubtitle = "Loading..",
	Theme = "Default",
	DisableRayfieldPrompts = false,
	ConfigurationSaving = {
		Enabled = false,
		FolderName = "TreadLightly",
		FileName = "Config"
	},
	KeySystem = false
})

local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateSection("Settings")

MainTab:CreateToggle({
	Name = "AutoFarm Toggle (Use Complete Stages)",
	CurrentValue = false,
	Flag = "AutoFarmToggle",
	Callback = function(Value)
		autoFarmEnabled = Value
	end,
})

MainTab:CreateToggle({
	Name = "No Render",
	CurrentValue = false,
	Flag = "NoRenderToggle",
	Callback = function(Value)
		RunService:Set3dRenderingEnabled(not Value)
	end,
})

MainTab:CreateSection("Auto Step")

MainTab:CreateToggle({
	Name = "Complete Stages",
	CurrentValue = false,
	Flag = "CompleteStagesToggle",
	Callback = function(Value)
		autoStepEnabled = Value
		
		if Value then
			task.spawn(stepThroughFolders)
		end
	end,
})

MainTab:CreateButton({
	Name = "Check Current Level",
	Callback = function()
		local level = getCurrentLevel()
		local highest = getHighestFolderNumber()
		Rayfield:Notify({
			Title = "Step Carefully",
			Content = "Current: " .. level .. " | Next: " .. (level + 1) .. " | Highest: " .. highest,
			Duration = 3,
			Image = "info"
		})
	end,
})

local StatsTab = Window:CreateTab("Stats", "activity")

StatsTab:CreateSection("Tracking Controls")

StatsTab:CreateToggle({
	Name = "Track Stats",
	CurrentValue = false,
	Flag = "TrackStatsToggle",
	Callback = function(Value)
		trackingEnabled = Value
		if Value then
			autofarmStartTime = tick()
			startingCoins = getCoins()
			startingRebirths = getRebirths()
			updateStatsDisplay()
		end
	end,
})

StatsTab:CreateSection("Statistics")

timeLabel = StatsTab:CreateParagraph({
	Title = "Time Elapsed",
	Content = "Time: 00:00:00"
})

statsLabel = StatsTab:CreateParagraph({
	Title = "Auto Farm Stats",
	Content = "Level: 0 | Coins: +0 | Rebirths: +0"
})

StatsTab:CreateButton({
	Name = "Reset Stats",
	Callback = function()
		autofarmStartTime = tick()
		startingCoins = getCoins()
		startingRebirths = getRebirths()
		updateStatsDisplay()
		Rayfield:Notify({
			Title = "Stats Reset",
			Content = "Statistics have been reset",
			Duration = 2,
			Image = "refresh"
		})
	end,
})

task.spawn(function()
	while task.wait(0.5) do
		if trackingEnabled then
			updateStatsDisplay()
		end
	end
end)
