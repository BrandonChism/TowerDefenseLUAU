--Modules

--local packages = "rbxassetid://6972518133"

--packages.Parent = workspace

local gameModule = require(script.GameModule)
local updatePlyrModule = require(script.UpdatePlayer)
local TowerModule = require(script.TowerModule)
local MapWaveModule = require(script.GameModule.MapWaveModule)

--Services
local SERVER_STORAGE = game:GetService("ServerStorage")
local TOWER_ASSETS = SERVER_STORAGE.TowerDefensePackages
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local DATA_STORE_SERVICE = game:GetService("DataStoreService")
local TPS = game:GetService("TeleportService")
--Variables




local TowerDefenseLocalPackages = REPLICATED_STORAGE.TowerDefenseLocalPackages

local Events = TowerDefenseLocalPackages.Events
local Towers = TOWER_ASSETS.Towers

local plyrInventory = DATA_STORE_SERVICE:GetDataStore("Player_Inventory8")

--Events

game.Players.PlayerAdded:Connect(function(p) updatePlyrModule:PlayerAdded(p) 

	
end)

Events.Purchase.OnServerEvent:Connect(function(plyr,towerPurchase) TowerModule:PurchaseTower(plyr,towerPurchase) end)

Events.PlaceTower.OnServerEvent:Connect(function(plyr,obj,region,rotation)  TowerModule:PlaceTower(plyr,obj,region,rotation) end)

Events.Upgrade.OnServerEvent:Connect(function(plyr,tower) TowerModule:UpgradeTower(plyr,tower) end)

Events.Targeting.OnServerEvent:Connect(function(plyr,tower) TowerModule:TargetingChange(plyr,tower) end)

Events.Pickup.OnServerEvent:Connect(function(plyr,tower) TowerModule:PickupTower(plyr,tower) end)



local votes = 0

local fastForward=  false



Events.FastForward.OnServerEvent:Connect(function(plyr,val)

	if val then votes+=1 else votes-=1 end

	if votes>= #game.Players:GetChildren() and not fastForward then
		fastForward = true
		game.ReplicatedStorage.TowerDefenseLocalPackages.Events.FastForward:FireAllClients(fastForward)
		gameModule:SetFastForward(true)
		TowerModule:SetFastForward(true)
		for i,v in pairs(game.Workspace.Ignore.Enemies:GetChildren()) do
			local buff = Instance.new("IntValue")
			buff.Name = "FastForward"
			buff.Value = 999999999
			buff.Parent = v.Debuffs
		end
		for i,v in pairs(game.Workspace.Ignore.Towers:GetChildren()) do
			local buff = Instance.new("IntValue")
			buff.Name = "FastForward"
			buff.Value = 999999999
			buff.Parent = v.Stats 
		end
	elseif votes < #game.Players:GetChildren() and fastForward  then
		fastForward = false
		game.ReplicatedStorage.TowerDefenseLocalPackages.Events.FastForward:FireAllClients(fastForward)
		gameModule:SetFastForward(false)
		TowerModule:SetFastForward(false)
		for i,v in pairs(game.Workspace.Ignore.Enemies:GetChildren()) do
			if v.Debuffs:FindFirstChild("FastForward") then
				v.Debuffs.FastForward:Destroy()
			end
		end
		for i,v in pairs(game.Workspace.Ignore.Towers:GetChildren()) do
			if v.Stats:FindFirstChild("FastForward") then
				v.Stats.FastForward:Destroy()
			end
		end
	end

end)


--Game Script

local round = 0

local RoundTimer = 30

local unitsAlive = 0

local gameStats = REPLICATED_STORAGE.TowerDefenseLocalPackages.Stats

local gameOver = false

local debris = game:GetService("Debris")

local win = false


local messagingService = game:GetService("MessagingService")

local ChatService = require(game:GetService("ServerScriptService"):WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

if not ChatService:GetChannel("All") then
	while true do
		local ChannelName = ChatService.ChannelAdded:Wait()
		if ChannelName == "All" then
			break
		end
	end
end

local FrozenHeart = ChatService:AddSpeaker("Frozen Heart")
FrozenHeart:JoinChannel("All")

FrozenHeart:SetExtraData("NameColor", Color3.fromRGB(55, 255, 255))
FrozenHeart:SetExtraData("ChatColor", Color3.fromRGB(0, 155, 255))



local mapId = {
	[7106352570] = "Crystal City",
	[7106368062] = "Classic",
	[7106362329] = "Tundra",
	[7106356528] = "Nuclear Facility"
}



for i,v in pairs(game.Players:GetChildren()) do
	updatePlyrModule:PlayerAdded(v) 
end

local player_Data = {}

local gameStartTime



workspace.Ignore.Enemies.ChildAdded:Connect(function() unitsAlive += 1 end)
workspace.Ignore.Enemies.ChildRemoved:Connect(function() unitsAlive -= 1 end)


Events.Teleport.OnServerEvent:Connect(function(player)
	
	
	
	updatePlyrModule:TeleportPlayer(player) 

end)

local Votes = {
	["Easy"] = 0,
	["Normal"] = 0,
	["Hard"] = 0,
}

game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Vote.OnServerEvent:Connect(function(plyr,vote)
	print(vote)
	if Votes[vote] then
		Votes[vote] +=1
	end
	plyr.Voted.Value = true
end)

local gamemode = "Easy"


function gameModeVote()
	local highest = 0
	for i,v in pairs(Votes) do
		if v > highest then
			highest = v
			gamemode = i
		end
	end
end


wait(30)


gameModeVote()

gameModule:SetGamemode(gamemode)


game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Vote:FireAllClients(gamemode)

game.ServerStorage.TowerDefensePackages.getRound.OnInvoke = function() return round end

gameStartTime = os.time()

while round ~= #MapWaveModule[game.PlaceId][gamemode]+1 and not gameOver do
	
	if #MapWaveModule[game.PlaceId][gamemode] == 0 then return end
	
	Events.RoundBegin:FireAllClients(round,gameModule:RoundTime(round))
	local secondsThatWereLeftInRoundWhenEnded = 0
	
	if round == 20 or round == 30 or round == 40 then
		game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Music:FireAllClients("Boss")
	end
	coroutine.wrap(function()
		local waveIncs = {}
		for i,v in pairs(workspace.Ignore.Spawns:GetChildren()) do
			local waveInc = game.ServerStorage.TowerDefensePackages.Guis.IncomingWaveGui:Clone()
			table.insert(waveIncs,waveInc)
			waveInc.Adornee = v
			waveInc.Parent = v
		end

		for i=1,5 do
			if fastForward then
				wait(.5)
			else
				wait(1)
			end
		end
		for i,v in pairs(waveIncs) do
			v:Destroy()
		end
		return
	end)()
	
	for countDown=gameModule:RoundTime(round),0,-1 do
		if gameOver then 
			break
		end
		gameModule:SpawnUnit(
			round,
			math.floor(gameModule:RoundTime(round)-(countDown))
		)

		local timeLeft = math.floor(countDown)
		if unitsAlive <= 0 and countDown <= gameModule:RoundTime(round)- #MapWaveModule[game.PlaceId][gamemode][round].Units then--and countDown < gameModule:RoundTime(round)/2 then
			print('all units dead give reward and continue to next round')
			secondsThatWereLeftInRoundWhenEnded = countDown
			break
		end
		--gameModule:MoveUnits()
		if fastForward then
			wait(.5)
		else
			wait(1)
		end
	end

	Events.RoundOver:FireAllClients(gameModule:Intermission(round))

	print('round over')
	gameModule:GivePlayersGold(gameModule:EarlyRoundCompletionReward(round,secondsThatWereLeftInRoundWhenEnded))
	
	
	if round == 20 or round == 30 or round == 40 then
		game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Music:FireAllClients()
	end
	
	round += 1
	
	
	wait(gameModule:Intermission(round))

end


while #game.Workspace.Ignore.Enemies:GetChildren() >= 1 do
	wait(1)
end

win = true

gameStats:SetAttribute("Health",0)

local module = {}

return module
