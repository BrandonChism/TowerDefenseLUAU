local PlayerModule = require(script.UpdatePlayer)
local ElevatorModule = require(script.ElevatorModule)


game.Players.PlayerAdded:Connect(function(plyr) 
	PlayerModule:PlayerAdded(plyr) 
end)

game.Players.PlayerRemoving:Connect(function(plyr) 
	
	
	PlayerModule:PlayerRemoving(plyr) 
	
end)

local timeleft = nil

local hourlyPets={}

game.ReplicatedStorage.Events.UpdateData.OnServerEvent:Connect(function(plyr,which,date,timeleft) PlayerModule:UpdatePlayerData(plyr,which,date,timeleft) end)




ElevatorModule:SetTouchEvent()

game.ReplicatedStorage.Events.EquipTower.OnServerEvent:Connect(function(plyr,slot,tower) PlayerModule:EquipTower(plyr,slot,tower) end)

function fetchPlayerData(plyr)
	return PlayerModule:RetrivePlayerData(plyr)
end

game.ReplicatedStorage.Events.RetrieveData.OnServerInvoke = fetchPlayerData











local syncedtime = require(script.SyncedTime)
syncedtime.init() 

local function toHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end



local commonPets = {
	"Frozen Heart",
	--"Shooting Star",
	--"Bandage"
}

local uncommonPets = {
	"Troll Mask",
}

local rarePets = {
	"Star Watch",
	"Midas' Glove",
}

local superRarePets = {
	--"Cursed Artifact"
}

local godlikePets = {
	"Zeus Cloud",
}

local weights = {
	Common = 60,
	Uncommon = 38,
	Rare = 20,
	SuperRare = 4,
	Godlike = 2,
}


function generate(day)

	local max = 100
	local seMax = 60
	local remaining = max
	local segments = 5
	local results = {}


	for i=1,segments do
		local rng = Random.new(day+(i-1))
		local r = tonumber( tostring("."..rng:NextInteger(1,100)) ) *  seMax
		if i == segments then
			r = remaining
		end
		table.insert(results,r)
		remaining -= r
		seMax = remaining
	end

	return results
end


function getAvailableItems(day, numberofitems) 
	local rng = Random.new(day) 
	local shopItems = {} 
	local count = 0
	
	local function shallowCopy(original) 
		local copy = {}
		for key, value in pairs(original) do
			copy[key] = value
		end
		return copy
	end

	local function Generate()
		local shopitem
		local returnedRarity

		local function GenerateWeightedItem() 
			local rarity
			local weightNumber = rng:NextNumber(0, 100) 
			
			local thisRng = Random.new(day+count)
			
			local weightitem
			
			
			if weightNumber < weights.Godlike  then 
				weightitem = godlikePets[thisRng:NextInteger(1,#godlikePets)] 
				rarity = godlikePets
			elseif weightNumber < weights.SuperRare then 
				weightitem = superRarePets[thisRng:NextInteger(1,#superRarePets)] 
				rarity = superRarePets
			elseif weightNumber < weights.Rare  then
				weightitem = rarePets[thisRng:NextInteger(1,#rarePets)] 
				rarity = rarePets
			elseif weightNumber < weights.Uncommon then
				weightitem = uncommonPets[thisRng:NextInteger(1,#uncommonPets)] 
				rarity = uncommonPets
			else
				weightitem = commonPets[thisRng:NextInteger(1,#commonPets)] 
				rarity = commonPets
			end
			count+=5
			return weightitem, rarity
		end

		shopitem, returnedRarity = GenerateWeightedItem()
		local itemtablecopy = shallowCopy(returnedRarity) 


		table.insert(shopItems, shopitem)
	end

	repeat
		Generate()
	until #shopItems >= numberofitems
	
	
	return shopItems
end






local currentDay 
local currentShopItems = {} 
local hourOffset = 0 






local petInfo = {
	["Zeus Cloud"] = {
		Rarity = "Godlike",
		Color = Color3.fromRGB(255,0,0),
		Name = "Zeus Cloud",
		Equipped = false
	},
	["Midas' Glove"] = {
		Rarity = "Rare",
		Color = Color3.fromRGB(255,205,95),
		Name = "Midas' Glove",
		Equipped = false
	},
	["Troll Mask"] = {
		Rarity = "Uncommon",
		Color = Color3.fromRGB(-0,255,0),
		Name = "Troll Mask",
		Equipped = false
	},
	["Frozen Heart"] = {
		Rarity = "Common",
		Color = Color3.fromRGB(255,255,255),
		Name = "Frozen Heart",
		Equipped = false
	},
	["Shooting Star"] = {
		Rarity = "Common",
		Color = Color3.fromRGB(255,255,255),
		Name = "Shooting Star",
		Equipped = false
	},
	["Bandage"] = {
		Rarity = "Common",
		Color = Color3.fromRGB(255,255,255),
		Name = "Bandage",
		Equipped = false
	},
	["Star Watch"] = {
		Rarity = "Rare",
		Color = Color3.fromRGB(255,205,95),
		Name = "Star Watch",
		Equipped = false
	},
	--[[["Cursed Artifact"] = {
		Rarity = "Super Rare",
		Color = Color3.fromRGB(255,0,255),
		Name = "Cursed Artifact",
		Equipped = false
	}]]
}

local petRarity = {
	["Zeus Cloud"] = 1,
	["Midas' Glove"] = 3,
	["Star Watch"] = 3,
	--["Cursed Artifact"] = 4,
	["Troll Mask"] = 4,
	["Frozen Heart"] = 5,
	["Shooting Star"] = 5,
	["Bandage"] = 5,

}


local offset = (60 * 60 * hourOffset) 


game.ServerStorage.HourlyShop.OnInvoke = function()
	return hourlyPets
end

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

local Speaker = ChatService:AddSpeaker("Daily Loot Box")
Speaker:JoinChannel("All")

Speaker:SetExtraData("NameColor", Color3.fromRGB(255, 200, 15))
Speaker:SetExtraData("ChatColor", Color3.fromRGB(255, 0, 255))


messagingService:SubscribeAsync("GlobalChat",function(message)
	Speaker:SayMessage(message.Data, "All")
end)



while true do
	local day = math.floor((syncedtime.time() + offset) / (60 * 60 * 1))
	local t = (math.floor(syncedtime.time())) - offset 
	local daypass = t % 3600 
	local timeleft = 3600 - daypass
	local timeleftstring = toHMS(timeleft) 
	if day ~= currentDay then
		currentDay = day 
		currentShopItems = getAvailableItems(day, 5) 
		local rarity = generate(day)
		table.sort(rarity,function(a,b)
			return a<b
		end)
		table.sort(currentShopItems,function(a,b)
			return petRarity[a]<petRarity[b]
		end)
		for i=1,#currentShopItems do		
			hourlyPets[i] = {["PetInfo"] = petInfo[currentShopItems[i]],["Rarity"] = rarity[i]}
			game.StarterGui.Summons.Frame[tostring(i)].TextLabel.Text = string.sub(rarity[i],1,4).."%"
			game.StarterGui.Summons.Frame[tostring(i)].TextLabel.TextColor3 = petInfo[currentShopItems[i]].Color
			game.StarterGui.Summons.TextLabel.Text = t
			game.StarterGui.Summons.Frame[tostring(i)]:SetAttribute("Summon",petInfo[currentShopItems[i]].Name)
		end
		game.ReplicatedStorage.Events.SummonEvent:FireAllClients(hourlyPets,timeleft)
	end
	wait(1)
end