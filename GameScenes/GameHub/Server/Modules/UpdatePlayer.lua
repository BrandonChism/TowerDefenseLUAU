
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local MarketPlaceService = game:GetService("MarketplaceService")

local http = game:GetService("HttpService")

local playerCollisionGroupName = "Players"
PhysicsService:CreateCollisionGroup(playerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)

local player_Data = {}

local previousCollisionGroups = {}


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

local function setCollisionGroup(object)
	if object:IsA("BasePart") then
		if object.Name == "Head" then
			local player = game.Players:GetPlayerFromCharacter(object.Parent)
			if player_Data[player.UserId] then
				local tag =game.ServerStorage.BillboardGui:Clone()
				tag.Adornee = object
				tag.TextLabel.Text = "Level "..player_Data[player.UserId].Level
				tag.Parent = object
			end
		end
		previousCollisionGroups[object] = object.CollisionGroupId
		PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName)
	end
end

local function setCollisionGroupRecursive(object,character)
	setCollisionGroup(object,character)

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
	character.DescendantAdded:Connect(function(obj)
		setCollisionGroup(obj,character)
	end)
	character.DescendantRemoving:Connect(resetCollisionGroup)
end





function setPhysics(model,physics)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(v,physics)
		end
	end
end


local DSS = game:GetService("DataStoreService")

local plyrInventory = DSS:GetDataStore("Player_Inventory10")




local towerPrices = {
	["Sith"]			= 10000,
	["Jedi"] 			= 10000,
	["Ice Ranger"] 		= 5000,
	["Dragon Knight"] 	= 10000,
	["Beam"] 			= 10000,
	["Samurai"]			= 2500,
	["Alien"]			= 2500,
	["Superman"]		= 10000,
	["Crossbow"]		= 10000,
	["Pirate"]			= 500,
	["Cowboy"]			= 500,
	["Boxer"]			= 500,
	["Miner"]			= 5000,
	["Ninja"]			= 5000,
	["Wizard"]			= 5000,
	["Shotgunner"]		= 2500,
	["Minigunner"]		= 2500,
	["Musician"]		= 5000,


}

local forcegamePass = 20092500



function createPet(petName,char,lvl)
	if char:FindFirstChild("Summon") then
		char.Summon:Destroy()
	end
	if game.ServerStorage.Pets:FindFirstChild(petName) then
		local pet = game.ServerStorage.Pets[petName]:Clone()
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
		atch1.Position = atch1.Position-attachOffsets[petName]
		pet.PrimaryPart.CFrame = char.HumanoidRootPart.CFrame
		pet.Parent = char
		pet.Name = "Summon"
		local petGui = game.ServerStorage.PetGui:Clone()
		petGui.Lvl.Text = "Level:"..lvl
		petGui.TextLabel.Text = petName
		petGui.Parent = pet
		petGui.Adornee = pet.Main
	end
end


function createInventory(plyr,priorData)
	local plyrData
	
	local success,err
	
	if priorData then
		plyrData = priorData
	else
		success,err = pcall(function()
			plyrData = plyrInventory:GetAsync(plyr.UserId) 
		end)
	end

	
	if err then
		warn(err)
		warn("unable to fetch"..plyr.Name.."data") return
	end
	if not plyrData then
		plyr.Cash.Value = 100
		player_Data[plyr.UserId] = 
			{
				Skins = {},
				Towers = {"Grenadier","Soldier","Sniper"},
				Cash = 100,
				Level = 1,
				Exp = 0,
				DailyReward = 0,
				EquippedTowers = {
					["1"] = "Sniper",
					["2"] = "Soldier",
					["3"] = "Grenadier",
					["4"] = "",
					["5"] = "",
					["6"] = ""
				},
				GamesPlayed = 0,
				Wins = 0,
				Losses = 0,
				TimePlayed = 0,
				Maps = {
					["Crystal City"] = {Wins = 0, Losses = 0, Played = .1, TimePlayed = 0},
					["Nuclear Facility"] = {Wins = 0, Losses = 0, Played = .1, TimePlayed = 0},
					["Classic"] = {Wins = 0, Losses = 0, Played = .1, TimePlayed = 0},
					["Tundra"] = {Wins = 0, Losses = 0, Played = .1, TimePlayed = 0},
				},
				Emotes ={
					
				},
				Pet = "",
				Pets = {},
				Muted = false
				
			}
		if MarketPlaceService:UserOwnsGamePassAsync(plyr.UserId,forcegamePass) then
			table.insert(player_Data[plyr.UserId]["Towers"],"Jedi")
			table.insert(player_Data[plyr.UserId]["Towers"],"Sith")
		end
		
		plyr.CharacterAdded:Connect(function(char)
			repeat wait() until char:FindFirstChild("HumanoidRootPart")
			if plyrData then
				if plyrData["Pet"] then
					if plyrData["Pet"].Name  then
						if game.ServerStorage.Pets:FindFirstChild(plyrData["Pet"].Name) then
							local pet = game.ServerStorage.Pets[plyrData["Pet"].Name]:Clone()
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
							atch1.Position = atch1.Position-attachOffsets[plyrData["Pet"].Name]
							pet.PrimaryPart.CFrame = char.HumanoidRootPart.CFrame
							pet.Parent = char
							pet.Name = "Summon"
							local petGui = game.ServerStorage.PetGui:Clone()
							petGui.Lvl.Text = "Level:"..plyrData["Pet"].Level
							petGui.TextLabel.Text = plyrData["Pet"].Name
							petGui.Parent = pet
							petGui.Adornee = pet.Main
						end
					end
				end
			end
		end)
		
		
		return player_Data[plyr.UserId]
	end
	
	
	if MarketPlaceService:UserOwnsGamePassAsync(plyr.UserId,forcegamePass) then
		local hasTowers = false
		for i,v in pairs(plyrData["Towers"]) do
			if v == "Jedi" or v == "Sith" then
				hasTowers = true
			end
		end
		
		if not hasTowers then
			table.insert(plyrData["Towers"],"Jedi")
			table.insert(plyrData["Towers"],"Sith")
			print('added jedi and sith to towers')
		end
	end
	if plyrData then
		if plyrData.Pet then
			plyr.CharacterAdded:Connect(function(char)
				repeat wait() until char:FindFirstChild("HumanoidRootPart")
				if plyrData["Pet"] then
					if plyrData["Pet"].Name  then
						if game.ServerStorage.Pets:FindFirstChild(plyrData["Pet"].Name) then
							local pet = game.ServerStorage.Pets[plyrData["Pet"].Name]:Clone()
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
							atch1.Position = atch1.Position-attachOffsets[plyrData["Pet"].Name]
							pet.PrimaryPart.CFrame = char.HumanoidRootPart.CFrame
							pet.Parent = char
							pet.Name = "Summon"
							local petGui = game.ServerStorage.PetGui:Clone()
							petGui.Lvl.Text = "Level:"..plyrData["Pet"].Level
							petGui.TextLabel.Text = plyrData["Pet"].Name
							petGui.Parent = pet
							petGui.Adornee = pet.Main
						end
					end
				end
			end)
		end
	end
	
	
	plyr.Cash.Value = plyrData.Cash
	
	player_Data[plyr.UserId] = plyrData
	
	
	print(plyrData)
	return plyrData
end




game.ReplicatedStorage.Events.ProfileData.OnServerEvent:Connect(function(plyr,playerToLookAt)
	game.ReplicatedStorage.Events.ProfileData:FireClient(plyr,player_Data[playerToLookAt.UserId],playerToLookAt)
end)


game.ReplicatedStorage.Events.MuteMusic.OnServerEvent:Connect(function(plyr,muted)
	if player_Data[plyr.UserId] then
		print(muted)
		player_Data[plyr.UserId]["LobbyMusicMuted"] = muted
		
	end
end)

local rarityPrice = {
	["Common"] = {
		[1] = 50,
		[2] = 100,
		[3] = 250,
	},
	["Uncommon"] = {
		[1] = 75,
		[2] = 150,
		[3] = 225,
	},
	["Rare"] = {
		[1] = 200,
		[2] = 400,
		[3] = 600,
	},
	["Super Rare"] = {
		[1] = 300,
		[2] = 400,
		[3] = 800,
	},
	["Legendary"] = {
		[1] = 1000,
		[2] = 2000,
		[3] = 3000,
	},
	["Godlike"] = {
		[1] = 1000,
		[2] = 2000,
		[3] = 3000,
	},
	["Go"] = {
		[1] = 1000,
		[2] = 2000,
		[3] = 3000,
	},
}



game.ReplicatedStorage.Events.EquipPet.OnServerEvent:Connect(function(plyr,pet)
	local plyrData
	if player_Data[plyr.UserId] then
		plyrData = player_Data[plyr.UserId]
		if plyrData then
			plyrData.Pet = plyrData.Pets[pet]
			for i,v in pairs(plyrData.Pets) do
				v.Equipped = false
			end
			if plyr.Character then
				if plyr.Character:FindFirstChild("Summon") then
					plyr.Character.Summon:Destroy()
				end
			end
			plyrData.Pets[pet].Equipped = true
			createPet(plyrData.Pets[pet].Name,plyr.Character, plyrData.Pets[pet].Level)
			game.ReplicatedStorage.Events.UpdateClient:FireClient(plyr,plyrData.Cash)
		end
	end
end)

game.ReplicatedStorage.Events.SellPet.OnServerEvent:Connect(function(plyr,pet)
	local plyrData
	if player_Data[plyr.UserId] then
		plyrData = player_Data[plyr.UserId]
		if plyrData then
			print(plyrData.Pets[pet].Rarity)
			plyrData.Cash += rarityPrice[plyrData.Pets[pet].Rarity][plyrData.Pets[pet].Level]
			print(plyrData.Pets)
			if plyrData.Pets[pet].Equipped == true then
				plyrData.Pet = ""
				if plyr.Character then
					if plyr.Character:FindFirstChild("Summon") then
						plyr.Character.Summon:Destroy()
					end
				end
			end
			plyrData.Pets[pet] = nil
			local count = 1
			local newPetTabl = {}
			for i,v in pairs(plyrData.Pets) do
				newPetTabl[count] = plyrData.Pets[i]
				count+=1
			end
			plyrData.Pets = newPetTabl
			print(plyrData.Pets)
			game.ReplicatedStorage.Events.UpdateClient:FireClient(plyr,plyrData.Cash)
		end
	end
end)

game.ReplicatedStorage.Events.UpgradePet.OnServerEvent:Connect(function(plyr,pet)
	local plyrData
	if player_Data[plyr.UserId] then
		plyrData = player_Data[plyr.UserId]
		if plyrData.Pets[pet].Level <3 then
			plyrData.Pets[pet].Level+=1
			print(plyrData)
			game.ReplicatedStorage.Events.UpdateClient:FireClient(plyr,plyrData.Cash)
		end
	end
end)

local messagingservice = game:GetService("MessagingService")



function whichPetRoll(rng,hourlyShop,plyr)
	if rng <= hourlyShop[1].Rarity then
		return hourlyShop[1]
	elseif rng <= hourlyShop[2].Rarity and rng>hourlyShop[1].Rarity then
		return hourlyShop[2]
	elseif rng <= hourlyShop[3].Rarity and rng>hourlyShop[2].Rarity then

		return hourlyShop[3]
	elseif rng <= hourlyShop[4].Rarity and rng>hourlyShop[3].Rarity then

		return hourlyShop[4]
	elseif rng > hourlyShop[4].Rarity then
		return hourlyShop[5]
	end
end




game.ReplicatedStorage.Events.Summon.OnServerEvent:Connect(function(plyr, crate)
	
	local plyrData = player_Data[plyr.UserId]
	
	
	if plyrData then
		if plyrData.Cash >= 400 then
		else
			return
		end
	else
		return
	end
	local rng = math.random(1,10000)/100
	print(rng)
	local hourlyPets 
	local pet = whichPetRoll(rng,game.ServerStorage.HourlyShop:Invoke(),plyr)
	
	if pet.PetInfo.Rarity == "Godlike" then
		messagingservice:PublishAsync("GlobalChat",plyr.Name.." has recieved a GODLIKE drop!")
	elseif pet.PetInfo.Rarity == "Super Rare" then
		messagingservice:PublishAsync("GlobalChat",plyr.Name.." has recieved a SUPER RARE drop!")
	end
	
	local plyrPet = {
		Level = 1,
		Name = pet.PetInfo.Name,
		Rarity = pet.PetInfo.Rarity,
		DroppedWith = string.sub(pet.Rarity,1,5).."%",
	}
	
	
	local plyrData = player_Data[plyr.UserId]
	
	
	if plyrData then
		wait(.5)
		plyrData.Cash-=400
		table.insert(plyrData.Pets,plyrPet)
		game.ReplicatedStorage.Events.UpdateClient:FireClient(plyr,plyrData.Cash,true)
		
	end
	
	game.ReplicatedStorage.Events.Summon:FireClient(plyr,pet.PetInfo.Name)
		
end)

local module = {}


function module:RetrivePlayerData(player,data)
	if player_Data[player.UserId] then
		return player_Data[player.UserId]
	else
		repeat wait(.4) until player_Data[player.UserId]
		return player_Data[player.UserId]
	end
end

function module:SetNewPlayerData(plyr)
	
end

function module:PlayerAdded(player,timeleft)
		
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Parent = player
	
	local plyrData
	
	local joinData =  player:GetJoinData()
	
	if joinData then
		if joinData.TeleportData then
			plyrData = createInventory(player,joinData.TeleportData)
		else
			plyrData = createInventory(player)
		end
	else
		plyrData = createInventory(player)
	end
	
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
		repeat wait() until player.Character:FindFirstChild("HumanoidRootPart")
			if plyrData then
				if plyrData["Pet"] then
					if plyrData["Pet"].Name  then
						if game.ServerStorage.Pets:FindFirstChild(plyrData["Pet"].Name) then
							local pet = game.ServerStorage.Pets[plyrData["Pet"].Name]:Clone()
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
							atch1.Position = atch1.Position-attachOffsets[plyrData["Pet"].Name]
						pet.PrimaryPart.CFrame = player.Character.HumanoidRootPart.CFrame
						pet.Parent = player.Character
							pet.Name = "Summon"
							local petGui = game.ServerStorage.PetGui:Clone()
							petGui.Lvl.Text = "Level:"..plyrData["Pet"].Level
							petGui.TextLabel.Text = plyrData["Pet"].Name
							petGui.Parent = pet
							petGui.Adornee = pet.Main
						end
					end
			end
		end
	end
end


local CurrencyPurchases = {
	
	
	["1191201072"] = 500,
	["1191201134"] = 1000,
	["1191201184"] = 2500,
	["1192987387"] = 5000,
	["1192987549"] = 10000,
}

local webhook_URL = "https://discordapp.com/api/webhooks/869926207859339266/BTAh8QKhQLthJgsrHorBQrPwhSzsTPlEATtAgfRtWr7qIbxn2BpHVKp3CyADUbRX72XL"

function processReceipt(receiptInfo)
	
	local foundPlayerData = false
	
	print(receiptInfo)
	
	if player_Data[receiptInfo.PlayerId] then
		
		foundPlayerData =  player_Data[receiptInfo.PlayerId]
		
	end
	
	
	if foundPlayerData then
		
		print(CurrencyPurchases[tostring(receiptInfo.ProductId)])
		
		foundPlayerData.Cash += CurrencyPurchases[tostring(receiptInfo.ProductId)]
		
		local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId)
				
		if player then
			player.Cash.Value = foundPlayerData.Cash
			game.ReplicatedStorage.Events.UpdateClient:FireClient(player,foundPlayerData.Cash)
			plyrInventory:SetAsync(player.UserId,player_Data[player.UserId])
			local Data = {
				["content"] = player.UserId.." has purchased "..CurrencyPurchases[tostring(receiptInfo.ProductId)].." cash. ("..player.Name..")"
			}

			Data = http:JSONEncode(Data)

			http:PostAsync(webhook_URL, Data) --Put the link you saved between the two quotes.
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	
end


MarketPlaceService.ProcessReceipt = processReceipt




game.ReplicatedStorage.Events.PurchaseTower.OnServerEvent:Connect(function(player,towerToPurchase)
	if towerPrices[towerToPurchase] then
		if player.Cash.Value >= towerPrices[towerToPurchase] then
			
			
			local foundPlayerData = false
			
			if player_Data[player.UserId] then

				foundPlayerData =  player_Data[player.UserId]

			end
			
			if foundPlayerData then
				
				if not foundPlayerData.Towers[towerToPurchase] then
					
					foundPlayerData.Cash -= towerPrices[towerToPurchase]
					table.insert(foundPlayerData.Towers,towerToPurchase)
					player.Cash.Value = foundPlayerData.Cash
					game.ReplicatedStorage.Events.UpdateClient:FireClient(player,foundPlayerData.Cash,true)

				else
					print('already own the tower')
				end
				
			end
			
			
			
		end
	end
end)



function module:PlayerRemoving(player)
	
	
	
	
	if player_Data[player.UserId] then
		local success,err = pcall(function()
			plyrInventory:SetAsync(player.UserId,player_Data[player.UserId])
		end)
		
		if success then
			print('successfully saved data')
		else
			warn(err)
		end	
		
		player_Data[player.UserId] = nil
		--plyrInventory:RemoveAsync(player.UserId)
		print(player_Data[player.UserId])
	else
		print('data failed to load prior, will not overwrite')
	end
	
	

end



function module:UpdatePlayerData(player,which,data,timeleft)
	player_Data[player.UserId][which] = data
end

local gamepassId = 19945640



function module:EquipTower(player,slot,tower)
	if tower == "" then
		player_Data[player.UserId].EquippedTowers[slot] = tower
	else
		
		
		local ownTower = false
		
		for i,v in pairs(player_Data[player.UserId].Towers) do
			if v == tower then ownTower = true end
		end
		
		print(ownTower)
		local canEquip = false
		if slot == "4" or slot == "5" or slot == "6" then
			print('is one of the slots')
			if slot == "4" and  player_Data[player.UserId].Level >= 5  then
				canEquip = true
			end
			if slot == "5" and player_Data[player.UserId].Level >=25 then
				canEquip = true
			end
			if slot == "6" and MarketPlaceService:UserOwnsGamePassAsync(player.UserId,gamepassId) then
				print('owns gamepass')
				canEquip = true
			end
			
		else
			canEquip = true
		end
		
		print(canEquip)
		if ownTower and canEquip then
			for i,v in pairs(player_Data[player.UserId].EquippedTowers) do
				if v == tower then
					player_Data[player.UserId].EquippedTowers[tostring(i)] = ""
				end
			end	
			player_Data[player.UserId].EquippedTowers[slot] = tower
		end
		
		
		
	end
end

function module:GetPlayerData()
	return player_Data
end

function saveData(plyrId)
	plyrInventory:SetAsync(plyrId, player_Data[plyrId])
end

game:BindToClose(function()
	for i,v in pairs(player_Data) do
		coroutine.wrap(saveData)(i)
	end
end)


return module


