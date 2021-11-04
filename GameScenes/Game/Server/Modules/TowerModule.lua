local PhysicsService = game:GetService("PhysicsService")

local towerStatsModule = require(script.TowerStatsModule)
local towerAttackModule = require(script.TowerAttackModule)
local towerPriceModule = require(script.TowerPriceModule)

local module = {}

local fastForward = false

function module:SetFastForward(val)
	fastForward = val
	towerStatsModule:SetFastForward(val)
	towerAttackModule:SetFastForward(val)
end

function towerSpawn(tower)
	for index,Atacks in pairs(towerAttackModule:WhichTower(tower)) do
		coroutine.wrap(Atacks)(tower)
	end
	game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Idle)
	game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Crawl)
	coroutine.wrap(function()
		local summon = game.ServerStorage.TowerDefensePackages.Effects.Summon:Clone()
		summon.Parent = workspace
		summon.CFrame = (tower.Hitbox.CFrame-Vector3.new(0,tower.Hitbox.Size.Y/2,0))*CFrame.Angles(0,0,math.rad(90))
		wait(3)
		if tower and tower:FindFirstChild("Stats") then
			tower.Stats:SetAttribute("Stunned",false)
		end
		wait(1)
		if summon:FindFirstChildWhichIsA("Attachment") then
			for i,v in pairs(summon:FindFirstChildWhichIsA("Attachment"):GetChildren()) do
				v.Enabled = false
			end
		else
			for i,v in pairs(summon:GetChildren()) do
				v.Enabled = false
			end
		end
		wait(3)
		summon:Destroy()
		return
	end)()

end





--[[
local TowersDraw = {
	["Common"] = {'Admin','Katana'},
	["Uncommon"] = {'uncom1','uncom2'},
	["Rare"] = {'rare1','rare2'},
	["SuperRare"] = {'sr1','sr2'}
}

local TowerRarity = {
	[1] = {
		[1] = {Weight = 80, Item = "Common"},
		[2] = {Weight = 60, Item = "Uncommon"},
		[3] = {Weight = 20, Item = "Rare"}
	},
	[2] = {
		[1] = {Weight = 50, Item = "Common"},
		[2] = {Weight = 60, Item = "Uncommon"},
		[3] = {Weight = 20, Item = "Rare"},
		[4] = {Weight = 4, Item = "SuperRare"}
	},
	[3] = {
		[1] = {Weight = 20, Item = "Common"},
		[2] = {Weight = 40, Item = "Uncommon"},
		[3] = {Weight = 60, Item = "Rare"},
		[4] = {Weight = 10, Item = "SuperRare"}
	}
}



function getTotalWeight(LootTable)
	local weight = 0
	for i,v in pairs(LootTable) do
		weight = weight+v.Weight
	end
	return weight
end




function GetRandomItemFromTable(lootTable)
	local weightTotal = getTotalWeight(lootTable)
	local rng = math.random(weightTotal)
	for i,v in pairs(lootTable) do
		if rng <= v.Weight then
			return v.Item
		else
			rng = rng - v.Weight
		end
	end
end

local rarityCost = {
	[1] = 250,
	[2] = 500,
	[3] = 1000,
}
]]



--[[
function module:PurchaseTower(plyr,rarity)
	if #plyr.Inventory:GetChildren() < 3 and plyr.leaderstats.Gold.Value >= rarityCost[rarity] then
		local towerDrawTable = GetRandomItemFromTable(TowerRarity[rarity])
		local tower_ToDraw = TowersDraw[towerDrawTable][math.random(1,#TowersDraw[towerDrawTable])]
		local tower = game.ServerStorage.TowerDefensePackages.Towers[tower_ToDraw][1]:Clone()
		tower.Name = game.ServerStorage.TowerDefensePackages.Towers[tower_ToDraw].Name
		towerStatsModule:SetStats(tower,plyr)
		setPhysics(tower,"Units")
		plyr.leaderstats.Gold.Value -= rarityCost[rarity]
		tower.Parent = plyr.Inventory
	end
end
]]
local towerPrices = {
	["Samurai"] = {Price = 100, multiplier = 2.5},
	["Sniper"] = {Price = 100, multiplier = 2},
	["Soldier"] = {Price = 50, multiplier = 2.5},
	["Minigunner"] = {Price = 65, multiplier = 2.4},
	["Grenadier"] = {Price = 150, multiplier = 2.2},
	["Jedi"] = {Price = 200, multiplier = 2.5},
	["Sith"] = {Price = 200, multiplier = 2.5},
	["Boxer"] = {Price = 50, multiplier = 3},
	["Cowboy"] = {Price = 75, multiplier = 2.5},
	["Pirate"] = {Price = 100, multiplier = 2.2},
	["Miner"] = {Price = 75, multiplier = 3},
	["Alien"] = {Price = 60, multiplier = 2},
	["Ninja"] = {Price = 125, multiplier = 4},
	["Wizard"] = {Price = 125, multiplier = 3},
	["Dragon Knight"] = {Price = 125, multiplier = 3},
	["Beam"] = {Price = 250, multiplier = 2.5},
	["Crossbow"] = {Price = 130, multiplier = 2.75},
	["Shotgunner"] = {Price = 100, multiplier = 2.4},
	["Musician"] = {Price = 125, multiplier = 2.4},

}




local targetingModes = {
	"Closest",
	"Furthest",
	"Strongest"
}

function module:TargetingChange(plyr,tower)
	local pos = table.find(targetingModes,tower.Stats:GetAttribute("Targeting"))
	
	if pos >= #targetingModes then
		pos = 1
	else
		pos+=1
	end
	
	tower.Stats:SetAttribute("Targeting",targetingModes[pos])
end

local updatePlyrModule = require(script.Parent.UpdatePlayer)

function upgrdTower(plyr,tower)
	local towerToCreate = game.ServerStorage.TowerDefensePackages.Towers[tower.Name][tower.Stats:GetAttribute("Stars")+1]:Clone()
	
	towerToCreate:SetPrimaryPartCFrame(CFrame.new(tower.Stats:GetAttribute("OriginalPosition")))
	towerToCreate.Name = tower.Name
	towerStatsModule:SetStats(towerToCreate,plyr,tower.Stats:GetAttribute("Stars"))
	local stars = game.ServerStorage.TowerDefensePackages.Guis.StarsBillBoard:Clone()
	stars.Parent = towerToCreate.Hitbox
	stars.Adornee = towerToCreate.Hitbox
	for i=1,tower.Stats:GetAttribute("Stars") do
		local star = stars.Stars.Star:Clone()
		star.Parent = stars.Stars
	end
	tower:Destroy()
	towerToCreate.Parent = workspace.Ignore.Towers
	updatePlyrModule:SetPhysics(towerToCreate)
	game.ReplicatedStorage.TowerDefenseLocalPackages.Events.LocalTower:FireClient(plyr,towerToCreate)
	towerSpawn(towerToCreate)
end


game.ServerStorage.TowerDefensePackages.UpgradeTower.Event:Connect(function(plyr,tower)
	upgrdTower(plyr,tower)
end)


function module:UpgradeTower(plyr,tower)
	local priceToUpgrade = towerPrices[tower.Name].Price * towerPrices[tower.Name].multiplier * tower.Stats:GetAttribute("Stars")
	print(priceToUpgrade)

	if plyr.leaderstats.Gold.Value >= priceToUpgrade and tower.Stats:GetAttribute("Stars") ~= 5 then
		plyr.leaderstats.Gold.Value -= priceToUpgrade
		upgrdTower(plyr,tower)
		game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Upgraded:FireClient(plyr)
	end
end

function module:PickupTower(plyr,tower)
	if #plyr.Inventory:GetChildren() < 3 then
		tower.Parent = plyr.Inventory
		local unitsPlaced = plyr.Stats:GetAttribute("UnitsPlaced")-1
		plyr.Stats:SetAttribute("UnitsPlaced",unitsPlaced)
	else
		print("not enough space in inventory")
	end	
end


game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Sell.OnServerEvent:Connect(function(plyr,tower)
	if tower:FindFirstChild("Stats") then
		if tower.Stats:GetAttribute("Player") == plyr.Name then
			plyr.leaderstats.Gold.Value += (towerPrices[tower.Name].Price * towerPrices[tower.Name].multiplier * tower.Stats:GetAttribute("Stars"))/1.75
			local plyrUnitsPlaced = plyr.Stats:GetAttribute("UnitsPlaced")
			plyrUnitsPlaced -=1
			plyr.Stats:SetAttribute("UnitsPlaced",plyrUnitsPlaced)
			tower:Destroy()
		end
	end
end)

local towerDebuffsModule = require(script.TowerStatsModule.TowerDebuffs)


function createTower(plyr,towerToClone,region,rotation)
	local unitsPlaced = plyr.Stats:GetAttribute("UnitsPlaced")
	plyr.leaderstats.Gold.Value -= towerPriceModule:TowerPrice(towerToClone.Name) 
	plyr.Stats:SetAttribute("UnitsPlaced",unitsPlaced+1)
	local tower = towerToClone:Clone()
	tower.Stats.ChildAdded:Connect(function(child)
		towerDebuffsModule:DebuffAdded(child,tower.Stats)
	end)
	tower.Stats.ChildRemoved:Connect(function(child)
		if tower then
			if tower:FindFirstChild("Stats") then
				towerDebuffsModule:DebuffRemoved(child,tower.Stats)
			end
		end
	end)
	if fastForward then
		local buff = Instance.new("IntValue")
		buff.Name = "FastForward"
		buff.Value = 99999999
		buff.Parent = tower.Stats
	end
	local stars = game.ServerStorage.TowerDefensePackages.Guis.StarsBillBoard:Clone()
	stars.Parent = tower.Hitbox
	stars.Name = "Stars"
	stars.Adornee = tower.Hitbox
	tower.Hitbox.Transparency = 1
	tower:SetPrimaryPartCFrame(region.CFrame*CFrame.Angles(0,math.rad(rotation),0))	
	tower.Stats:SetAttribute("OriginalPosition",tower.PrimaryPart.Position)
	tower.Parent = workspace.Ignore.Towers
	game.ReplicatedStorage.TowerDefenseLocalPackages.Events.LocalTower:FireClient(plyr,tower)
	towerSpawn(tower)
end


function module:PlaceTower(plyr,tower,region,rotation)
	if tower.Parent == plyr.Inventory then else return end
	print(plyr.Stats:GetAttribute("UnitsPlaced"))
	if plyr.Stats:GetAttribute("UnitsPlaced") <  40/#game.Players:GetChildren() and #game.Workspace.Ignore.Towers:GetChildren() < 40   then
		if plyr.leaderstats.Gold.Value >= towerPriceModule:TowerPrice(tower.Name) then
			local can_TowerBePlaced = false
			local ignore = game.Workspace.Placement:GetChildren()	
			local objects_Touching = workspace:FindPartsInRegion3WithIgnoreList(region,ignore,10)
			if #objects_Touching > 0 then
				local count = #objects_Touching
				for i,v in pairs(objects_Touching) do
					local model = v:FindFirstAncestorOfClass("Model")
					local char = model and model:FindFirstChildOfClass("Humanoid")
					local plyr = model and game:GetService("Players"):GetPlayerFromCharacter(model)
					print(plyr,char)
					if plyr then
						count = count-1
					end
				end
				print(count,objects_Touching)
				if count <= 0 then
					print('can place')
					createTower(plyr,tower,region,rotation)
				else
					print('touching something cant place')
				end
			else
				print('can place')
				createTower(plyr,tower,region,rotation)
			end
		else
			print('you dont have enough money')
		end
	else
		print('too many units')
	end
	
	
end

return module
