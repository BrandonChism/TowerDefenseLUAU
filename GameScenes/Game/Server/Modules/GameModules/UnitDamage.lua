local module = {}


local units = {
	["Enemy"] = {Damage = 10, Worth = 20},
	["Giant"] = {Damage = 10, Worth = 35},
	["Crawler"] = {Damage = 5, Worth = 20},
	["Zombie"] = {Damage = 7, Worth = 25},
	["Fire Zombie"] = {Damage = 10, Worth = 70},
	["Giant Zombie"] = {Damage = 25, Worth = 150},
	["Riot Zombie"] = {Damage = 7, Worth = 30},
	["Football Zombie"] = {Damage = 7, Worth = 40},
	["Rockstar Zombie"] = {Damage = 7, Worth = 90},
	["Powerline Zombie"] = {Damage = 7, Worth = 80},
	["Electric Zombie"] = {Damage = 7, Worth = 90},
	["Magma Zombie"] = {Damage = 100, Worth = 2500},

	["Green Slime"] = {Damage = 15, Worth = 25},
	["Ninja"] = {Damage = 15, Worth = 20},
	["Glitch"] = {Damage = 15, Worth = 75},
	["Fire Boss"] = {Damage = 25, Worth = 150},
	["Fairy"] = {Damage = 10, Worth = 25},
	["Ghoul"] = {Damage = 10, Worth = 30},
	["Vampire"] = {Damage = 25, Worth = 100},
	["Druid"] = {Damage = 20, Worth = 40},

	
	
	["Crystal Crawler"] = {Damage = 5, Worth = 20},
	["Wraith"] = {Damage = 5, Worth = 25},
	["Crystal Golem"] = {Damage = 10, Worth = 25},
	["Crystal Soldier"] = {Damage = 10, Worth = 20},
	["Crystal Barbarian"] = {Damage = 10, Worth = 35},
	["Crystal Hero"] = {Damage = 20, Worth = 70},
	["Crystal Assassin"] = {Damage = 20, Worth = 70},
	["Crystal Vanguard"] = {Damage = 20, Worth = 50},
	["Crystal Royal Guard"] = {Damage = 20, Worth = 60},
	["Crystal Abomination"] = {Damage = 20, Worth = 70},
	["Crystal Wanderer"] = {Damage = 20, Worth = 65},
	--Bosses
	["Crystal Commander"] = {Damage = 100, Worth = 500},
	["Crystal Queen"] = {Damage = 100, Worth = 1000},
	["Crystal King"] = {Damage = 100, Worth = 5000},
	
	
	
	
	["Mutant"] = {Damage = 20, Worth = 80},
	
	
	["Scout"] = {Damage = 5, Worth = 20},
	["Soldier"] = {Damage = 5, Worth = 25},
	["Mercenary"] = {Damage = 5, Worth = 30},
	["Breacher"] = {Damage = 10, Worth = 35},
	["Vanguard"] = {Damage = 7, Worth = 30},
	["Yeti"] = {Damage = 12, Worth = 45},
	["Spy"] = {Damage = 5, Worth = 40},
	["Commander"] = {Damage = 15, Worth = 65},
	["Ice Fiend"] = {Damage = 15, Worth = 90},
	["Ice Warrior"] = {Damage = 10, Worth = 85},

	["Frozen Spy"] = {Damage = 15, Worth = 100},
	["Caravan"] = {Damage = 100, Worth = 1000},
	["Ice Golem"] = {Damage = 100, Worth = 1000},
	["Ice King"] = {Damage = 100, Worth = 1000},


}

setmetatable(units,{
	__index = function()
		return{
			Damage = 10,
			Worth = 20,
		}
	end
})

local onDeathModule = require(script.UnitDeathFunctions)




local onDeath ={
	["Black Slime"] = {
		onDeathModule.BlackSlime
	}
}


function module:ReachedEnd(unit)
	local hp = game.ReplicatedStorage.TowerDefenseLocalPackages.Stats:GetAttribute("Health")
	hp = hp- units[unit.Name].Damage
	game.ReplicatedStorage.TowerDefenseLocalPackages.Stats:SetAttribute("Health",hp)
	unit:Destroy()
end

local difficulty = "Hard"

function module:SetGamemode(gamemode)
	difficulty = gamemode
end

local DifficultyAmp = {
	["Easy"] = 2,
	["Normal"] = 1.5,
	["Hard"] = 1
}

function module:Damaged(health,Enemy_Unit,currentHealth)
	currentHealth = math.abs(health)
	if currentHealth<=0 then
		if onDeath[Enemy_Unit.Name] then
			local coroutineFunc = onDeath[Enemy_Unit.Name]
			coroutine.wrap(coroutineFunc)(Enemy_Unit.HumanoidRootPart.CFrame)
		end
		Enemy_Unit:Destroy()
		
		local midas = false
		local midasLvl = 1
		for i,v in pairs(game.Players:GetChildren()) do
			if v.Pet.Value == "Midas' Glove" then
				midas = true
				if v.Pet.Level.Value > midasLvl then
					midasLvl = v.Pet.Level.Value
				end
			end
		end
		
		for i,v in pairs(game.Players:GetChildren()) do
			v.leaderstats.Gold.Value += math.floor((units[Enemy_Unit.Name].Worth*DifficultyAmp[difficulty])/#game.Players:GetChildren())
			if midas then
				v.leaderstats.Gold.Value +=midasLvl
			end
		end
	end
end


return module
