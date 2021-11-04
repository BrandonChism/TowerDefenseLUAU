
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local towerStatsModule = require(game.ServerScriptService.Main.TowerModule.TowerStatsModule)

local playerCollisionGroupName = "Players"
PhysicsService:CreateCollisionGroup(playerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)
PhysicsService:CollisionGroupSetCollidable("Units", playerCollisionGroupName, false)


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

local ZeusCloud = ChatService:AddSpeaker("Zeus Cloud")
ZeusCloud:JoinChannel("All")

ZeusCloud:SetExtraData("NameColor", Color3.fromRGB(155, 0, 255))
ZeusCloud:SetExtraData("ChatColor", Color3.fromRGB(255, 155, 0))


local TrollMask = ChatService:AddSpeaker("Troll Mask")
TrollMask:JoinChannel("All")

TrollMask:SetExtraData("NameColor", Color3.fromRGB(255, 255, 255))
TrollMask:SetExtraData("ChatColor", Color3.fromRGB(55, 55, 55))

local StarWatch = ChatService:AddSpeaker("Star Watch")
StarWatch:JoinChannel("All")

StarWatch:SetExtraData("NameColor", Color3.fromRGB(55, 255, 255))
StarWatch:SetExtraData("ChatColor", Color3.fromRGB(255, 200, 0))


local MidasGlove = ChatService:AddSpeaker("Midas Glove")
MidasGlove:JoinChannel("All")

MidasGlove:SetExtraData("NameColor", Color3.fromRGB(255, 255, 0))
MidasGlove:SetExtraData("ChatColor", Color3.fromRGB(255, 200, 0))


local previousCollisionGroups = {}

local function setCollisionGroup(object)
	if object:IsA("BasePart") then
		previousCollisionGroups[object] = object.CollisionGroupId
		PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName)
	end
end


local attachOffsets = {
	["Zeus Cloud"] = Vector3.new(-3,-7,-3),
	["Midas' Glove"] = Vector3.new(3,-5,-5),
	["Star Watch"] = Vector3.new(3,-5,-5),
	["Troll Mask"] = Vector3.new(-3,-4,0),
	["Frozen Heart"] = Vector3.new(3,-5,-5),
	["Cursed Artifact"] = Vector3.new(3,-5,-5),
	["Bandage"] = Vector3.new(3,-5,-5),
	["Shooting Star"] = Vector3.new(3,-5,-5),

}

local function setCollisionGroupRecursive(object)
	setCollisionGroup(object)

	for _, child in ipairs(object:GetChildren()) do
		setCollisionGroupRecursive(child)
	end
end

local function resetCollisionGroup(object)
	local previousCollisionGroupId = previousCollisionGroups[object]
	if not previousCollisionGroupId then return end 

	local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId)
	if not previousCollisionGroupName then return end

	PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName)
	previousCollisionGroups[object] = nil
end

local function onCharacterAdded(character)
	setCollisionGroupRecursive(character)
	character.DescendantAdded:Connect(setCollisionGroup)
	character.DescendantRemoving:Connect(resetCollisionGroup)
end





function setPhysics(model,physics)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(v,physics)
		end
	end
end



function zeusCloudAttack(pet,dmg)
	while true do
		if pet then
			local closest = nil
			for i,v in pairs(game.Workspace.Ignore.Enemies:GetChildren()) do
				local distance = (v.PrimaryPart.Position-pet.PrimaryPart.Position).magnitude
				print(distance)
				if distance <= 25 then
					if not closest then
						closest =v
					else
						if distance < (closest.PrimaryPart.Position-pet.PrimaryPart.Position).magnitude then
							closest =v
						end
					end
				end
			end
			
			
			
			if closest then
				
				local rngDmg = math.random(dmg-5, dmg+3)
				
				closest.Humanoid:TakeDamage(rngDmg)
			end
			wait(5)
		end
	end
end

local debris = game:GetService("Debris")

function starWatch(player,pet,lvl)
	while true do
		if pet then else return end
		print((60*4) - ( 60*(lvl-1) )  )
		wait( (60*4) - ( 60*(lvl-1) ) )
		local towers = {}
		for i,v in pairs(workspace.Ignore.Towers:GetChildren()) do
			print(v.Stats:GetAttribute("Player"),player.Name)
			if v.Stats:GetAttribute("Player") == player.Name then
				table.insert(towers,v)
			end
		end
		local towertoUP = nil
		for i,v in pairs(towers) do
			print(v:GetAttribute("Stars"))
			if not towertoUP then
				if v.Stats:GetAttribute("Stars") <5 then
					towertoUP = v
				end
			else
				if v.Stats:GetAttribute("Stars") < towertoUP.Stats:GetAttribute("Stars") then
					towertoUP = v
				end
			end
		end
		
		if towertoUP then
			local petText = game.ServerStorage.TowerDefensePackages.Guis.PetChatGui:Clone()
			petText.Stuff.TextLabel.Text = "I just upgraded "..towertoUP.Name.."!"
			petText.Parent = pet.Main
			petText.Adornee = pet.Main
			debris:AddItem(petText,7)
			
			StarWatch:SayMessage("Upgraded "..player.Name.."'s "..towertoUP.Name,"All")
			game.ServerStorage.TowerDefensePackages.UpgradeTower:Fire(player,towertoUP)
		end
		
	end
end


local players_Data = {}



local module = {}



function module:SetPhysics(what)
	setPhysics(what,"Units")
end

function module:GetTowerData(player)
	
end


function module:PlayerAdded(player)
	
	
	
	local joinData = player:GetJoinData()

	local plyrJoinData = nil



	if joinData then
		if joinData.TeleportData then
			for id,tbl in pairs(joinData.TeleportData) do
				if id == tostring(player.UserId) then
					plyrJoinData = tbl
					players_Data[player.UserId] = tbl
				end
			end
		end
	end
	
	local p_Stats = Instance.new("Folder")
	p_Stats.Name = "Stats"
	p_Stats:SetAttribute("UnitsPlaced",0)
	p_Stats.Parent = player
	
	local Inventory = Instance.new("Folder")
	Inventory.Name = "Inventory"
	Inventory.Parent = player

	local leaderStats = Instance.new("Folder")
	leaderStats.Name = "leaderstats"
	leaderStats.Parent = player
	
	local Voted = Instance.new("BoolValue")
	Voted.Name = "Voted"
	Voted.Parent = player

	local Gold = Instance.new("IntValue")
	Gold.Name = "Gold"
	
	if player:IsInGroup(11517261) then
		Gold.Value = 600
	else
		Gold.Value = 500
	end
	Gold.Parent = leaderStats

	local petInst=  Instance.new("StringValue")
	petInst.Name = "Pet"
	petInst.Value = ""
	petInst.Parent = player
	
	local petLvl = Instance.new("IntValue")
	petLvl.Name = "Level"
	petLvl.Value = 1
	petLvl.Parent = petInst

	player.CharacterAdded:Connect(onCharacterAdded)
	
	
	
	if not plyrJoinData then
		for i,v in pairs(game.ServerStorage.TowerDefensePackages.Towers:GetChildren()) do
			local k = v["1"]:Clone()
			k.Name = v.Name
			k.Parent = Inventory
			towerStatsModule:SetStats(k,player)
			setPhysics(k,"Units")
		end
	else
		for i,v in pairs(plyrJoinData["EquippedTowers"]) do
			if v~= "" then
				local k = game.ServerStorage.TowerDefensePackages.Towers[v]["1"]:Clone()
				k.Name = v
				k.Parent = Inventory
				towerStatsModule:SetStats(k,player)
				setPhysics(k,"Units")
			end
		end
		print(plyrJoinData["Pet"])
		if plyrJoinData.Pet then
			if plyrJoinData["Pet"].Name == "Troll Mask" then
				if plyrJoinData["Pet"].Level == 1 then
					Gold.Value += 300
					TrollMask:SayMessage("Granted "..player.Name.." an extra 300 gold.","All")

				elseif plyrJoinData["Pet"].Level == 2 then
					TrollMask:SayMessage("Granted "..player.Name.." an extra 500 gold.","All")

					Gold.Value +=500
				elseif plyrJoinData["Pet"].Level == 3 then
					Gold.Value+=750
					TrollMask:SayMessage("Granted "..player.Name.." an extra 750 gold.","All")

				end
			elseif plyrJoinData["Pet"].Name == "Midas' Glove" then
				
				if plyrJoinData["Pet"].Level == 1 then
					MidasGlove:SayMessage("Every kill players get will give an extra 1 gold.","All")

				elseif plyrJoinData["Pet"].Level == 2 then
					MidasGlove:SayMessage("Every kill players get will give an extra 3 gold.","All")
				elseif plyrJoinData["Pet"].Level == 3 then
					MidasGlove:SayMessage("Every kill players get will give an extra 5 gold.","All")
				end
			end
			player.CharacterAdded:Connect(function(char)
				repeat wait() until char:FindFirstChild("HumanoidRootPart")
				char.Parent = workspace.Ignore
				if plyrJoinData["Pet"] then
					if plyrJoinData["Pet"].Name ~= ""  and plyrJoinData["Pet"] ~= nil then
						if plyrJoinData["Pet"].Name ~= nil then
							if game.ServerStorage.TowerDefensePackages.Pets:FindFirstChild(plyrJoinData["Pet"].Name) then
								print('petfound')
								petInst.Value = plyrJoinData["Pet"].Name
								print(
									plyrJoinData["Pet"].Level,
									tonumber(plyrJoinData["Pet"].Level)
								)
								petLvl.Value = tonumber(plyrJoinData["Pet"].Level)
								local pet = game.ServerStorage.TowerDefensePackages.Pets[plyrJoinData["Pet"].Name]:Clone()
								local ap = Instance.new("AlignPosition")
								ap.Parent = pet.Main
								local atch0 = Instance.new("Attachment")
								local atch1 = Instance.new("Attachment")
								atch0.Parent = pet.Main
								atch1.Parent = char.HumanoidRootPart
								ap.Attachment0 = atch0
								ap.Attachment1 = atch1
								local aoAttach1 = Instance.new("Attachment")
								aoAttach1.Parent = pet.Main
								local aoAttach0 = Instance.new("Attachment")
								local ao = Instance.new("AlignOrientation")
								aoAttach0.Parent = char.HumanoidRootPart
								ao.Responsiveness = 10000
								ao.RigidityEnabled = true
								ao.Attachment0 = aoAttach1
								ao.Attachment1 = aoAttach0
								ao.Parent = pet.Main
								atch1.Position = atch1.Position-attachOffsets[plyrJoinData["Pet"].Name]
								pet.PrimaryPart.CFrame = char.HumanoidRootPart.CFrame
								pet.Parent = char
								pet.Name = "Summon"
								local petGui = game.ServerStorage.TowerDefensePackages.Pets.PetGui:Clone()
								petGui.Lvl.Text = "Level:"..plyrJoinData["Pet"].Level
								petGui.TextLabel.Text = plyrJoinData["Pet"].Name
								petGui.Parent = pet
								petGui.Adornee = pet.Main
								print(plyrJoinData["Pet"].Name)

								if plyrJoinData["Pet"].Name == "Zeus Cloud" then
									coroutine.wrap(zeusCloudAttack)(pet,plyrJoinData["Pet"].Level)
								elseif plyrJoinData["Pet"].Name == "Star Watch" then
									coroutine.wrap(starWatch)(player,pet,plyrJoinData["Pet"].Level)
								end
							end
						end
					end
				end
			end)
			if player.Character then
				player.Character.Parent = workspace.Ignore
				if plyrJoinData["Pet"] then
					if plyrJoinData["Pet"].Name ~= ""  and plyrJoinData["Pet"] ~= nil then
						if plyrJoinData["Pet"].Name ~= nil then
							if game.ServerStorage.TowerDefensePackages.Pets:FindFirstChild(plyrJoinData["Pet"].Name) then
								print('petfound')
								petInst.Value = plyrJoinData["Pet"].Name
								print(
									plyrJoinData["Pet"].Level,
									tonumber(plyrJoinData["Pet"].Level)
								)
								petLvl.Value = tonumber(plyrJoinData["Pet"].Level)
								local pet = game.ServerStorage.TowerDefensePackages.Pets[plyrJoinData["Pet"].Name]:Clone()
								local ap = Instance.new("AlignPosition")
								ap.Parent = pet.Main
								local atch0 = Instance.new("Attachment")
								local atch1 = Instance.new("Attachment")
								atch0.Parent = pet.Main
								atch1.Parent = player.Character.HumanoidRootPart
								ap.Attachment0 = atch0
								ap.Attachment1 = atch1
								local aoAttach1 = Instance.new("Attachment")
								aoAttach1.Parent = pet.Main
								local aoAttach0 = Instance.new("Attachment")
								local ao = Instance.new("AlignOrientation")
								aoAttach0.Parent = player.Character.HumanoidRootPart
								ao.Responsiveness = 10000
								ao.RigidityEnabled = true
								ao.Attachment0 = aoAttach1
								ao.Attachment1 = aoAttach0
								ao.Parent = pet.Main
								atch1.Position = atch1.Position-attachOffsets[plyrJoinData["Pet"].Name]
								pet.PrimaryPart.CFrame = player.Character.HumanoidRootPart.CFrame
								pet.Parent = player.Character
								pet.Name = "Summon"
								local petGui = game.ServerStorage.TowerDefensePackages.Pets.PetGui:Clone()
								petGui.Lvl.Text = "Level:"..plyrJoinData["Pet"].Level
								petGui.TextLabel.Text = plyrJoinData["Pet"].Name
								petGui.Parent = pet
								petGui.Adornee = pet.Main
								print(plyrJoinData["Pet"].Name)

								if plyrJoinData["Pet"].Name == "Zeus Cloud" then
									coroutine.wrap(zeusCloudAttack)(pet)
								elseif plyrJoinData["Pet"].Name == "Star Watch" then
									coroutine.wrap(starWatch)(player,pet,plyrJoinData["Pet"].Level)
								end
							end
						end
					end
				end
			end
		end
		
	end
	

	
	
	--[[
	if joinData then
		if joinData.TeleportData then
			for i,v in pairs(joinData.TeleportData) do
				if i == tostring(player.UserId) then
					plyrJoinData = v
				end
			end
		end
	end
	]]
	
	
	--[[
	
	if plyrJoinData then
		for i,v in pairs(plyrJoinData["EquippedTowers"]) do
			print(i,v)
			
			if v~= "" then
				local k = game.ServerStorage.TowerDefensePackages.Towers[v]["1"]:Clone()
				k.Name = v
				k.Parent = Inventory
				towerStatsModule:SetStats(k,player)
				setPhysics(k,"Units")
			end
		end
	else
		for i,v in pairs(game.ServerStorage.TowerDefensePackages.Towers:GetChildren()) do
			local k = v["1"]:Clone()
			k.Name = v.Name
			k.Parent = Inventory
			towerStatsModule:SetStats(k,player)
			setPhysics(k,"Units")
		end
	end
	
	
	]]
	
	
	--[[
	for i,v in pairs(game.ServerStorage.TowerDefensePackages.Towers:GetChildren()) do
		local k = v["1"]:Clone()
		k.Parent = Inventory
		k.Name = v.Name
		towerStatsModule:SetStats(k,player)
		setPhysics(k,"Units")
	end
	]]
	

end




local mapId = {
	[7106352570] = "Crystal City",
	[7106368062] = "Classic",
	[7106362329] = "Tundra",
	[7106356528] = "Nuclear Facility"
}


local TPS = game:GetService("TeleportService")

local DATA_STORE_SERVICE = game:GetService("DataStoreService")
local plyrInventory = DATA_STORE_SERVICE:GetDataStore("Player_Inventory8")

local MarketPlaceService = game:GetService("MarketplaceService")


function module:GameOverUpdatePlayer(player,round,win,gameStartTime)
	
	local plyrData = players_Data[player.UserId]
	
	local exp
	local cashEarned
	
	local amp = 0
	if  MarketPlaceService:UserOwnsGamePassAsync(player.UserId,19945640) then
		amp = .25
	end
	
	if win then
		cashEarned = round*25 + (round*25)*amp
		exp = round*6 + (round*6)*amp
	else
		cashEarned = round*10 + (round*10)*amp
		exp = round*2.5 + (round*2.5)*amp
	end
	
	game.ReplicatedStorage.TowerDefenseLocalPackages.Events.GameOver:FireClient(player,exp,cashEarned,gameStartTime,round,mapId[game.PlaceId])

	
	if plyrData then
		if plyrData.Exp+exp >100 then
			for i=1,math.floor((plyrData.Exp+exp)/100)+1 do
				if exp>= 100 then
					plyrData.Level+=1
					exp-=100
				else
					if plyrData.Exp+exp>100 then
						plyrData.Level+=1
						local expRemain = (plyrData.Exp+exp)-100
						plyrData.Exp = expRemain
					else
						plyrData.Exp+=exp
					end
				end
			end
		else
			plyrData.Exp += exp
		end


		plyrData.Cash += cashEarned
		plyrData.Maps[mapId[game.PlaceId]].Played +=1
		plyrData.GamesPlayed +=1
		plyrData.TimePlayed += os.time()- gameStartTime
		
		plyrData.Maps[mapId[game.PlaceId]].TimePlayed += os.time()- gameStartTime
		if win then
			plyrData.Maps[mapId[game.PlaceId]].Wins +=1
			plyrData.Wins +=1
		else
			plyrData.Maps[mapId[game.PlaceId]].Losses +=1
			plyrData.Losses +=1
		end
		players_Data[player.UserId] = plyrData
		plyrInventory:SetAsync(player.UserId,plyrData)
	end
	
end

function module:TeleportPlayer(player)
	
	local plyrData = players_Data[player.UserId]

	if players_Data[player.UserId] then else repeat wait() until players_Data[player.UserId] end

	local plyrData = players_Data[player.UserId]
	TPS:Teleport(7106339517,player,plyrData)
end

return module
