
local towers = {
	["Cowboy"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1,
			Damage = 9,
			AttackRange = 12,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 1,
			Damage = 15,
			AttackRange = 12,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 1,
			Damage = 20,
			AttackRange = 12,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 30,
			Targets = 1,
		}
	},

	["Ninja"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 2,
			AttackRange = 10,
			Targets = 3,			
		},
		[2] ={
			AttackSpeed = 1,
			Damage = 3,
			AttackRange = 11,
			Targets = 3,
		},
		[3] ={
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 3,
		},
		[4] = {
			AttackSpeed = 1,
			Damage = 9,
			AttackRange = 13,
			Targets = 3,
		},
		[5] = {
			AttackSpeed = 1,
			Damage = 12,
			AttackRange = 13,
			Targets = 5,
		}
	},
	
	["Minigunner"] = {
		[1]= {
			AttackSpeed = 5,
			Damage = 2,
			AttackRange = 8,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 5,
			Damage = 3,
			AttackRange = 8,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 5,
			Damage = 4,
			AttackRange = 8,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 5,
			Damage = 5,
			AttackRange = 8,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 5,
			Damage = 6,
			AttackRange = 8,
			Targets = 1,
		}
	},
	
	
	
	["Crossbow"] = {
		[1]= {
			AttackSpeed = 1.5,
			Damage = 7,
			AttackRange = 11,
			Targets = 3,			
		},
		[2] ={
			AttackSpeed = 1.4,
			Damage = 11,
			AttackRange = 13,
			Targets = 3,
		},
		[3] ={
			AttackSpeed = 1.3,
			Damage = 15,
			AttackRange = 15,
			Targets = 3,
		},
		[4] = {
			AttackSpeed = 1.2,
			Damage = 19,
			AttackRange = 19,
			Targets = 3,
		},
		[5] = {
			AttackSpeed = 1.1,
			Damage = 23,
			AttackRange = 23,
			Targets = 3,
		}
	},
	["Sith"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 12,
			Targets = 1,
		}
	},
	["Samurai"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 55,
			AttackRange = 5,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = .3,
			Damage = 55,
			AttackRange = 5,
			Targets = 2,
		},
		[3] ={
			AttackSpeed = .3,
			Damage = 5,
			AttackRange = 5,
			Targets = 3,
		},
		[4] = {
			AttackSpeed = .3,
			Damage = 5,
			AttackRange = 5,
			Targets = 4,
		},
		[5] = {
			AttackSpeed = .3,
			Damage = 5,
			AttackRange = 5,
			Targets = 5,
		}
	},
	
	["Valkyrie"] = {
		[1]= {
			AttackSpeed = .9,
			Damage = 7,
			AttackRange = 5,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = .85,
			Damage = 10,
			AttackRange = 5,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = .8,
			Damage = 12,
			AttackRange = 5,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .7,
			Damage = 15,
			AttackRange = 5,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .6,
			Damage = 19,
			AttackRange = 5,
			Targets = 1,
		}
	},
	
	["Gladiator"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 13,
			AttackRange = 5,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1,
			Damage = 18,
			AttackRange = 5,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = .9,
			Damage = 15,
			AttackRange = 5,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .85,
			Damage = 20,
			AttackRange = 5,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .8,
			Damage = 30,
			AttackRange = 5,
			Targets = 1,
		}
	},
	["Boxer"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 13,
			AttackRange = 5,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1,
			Damage = 18,
			AttackRange = 5,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = .9,
			Damage = 15,
			AttackRange = 5,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .85,
			Damage = 20,
			AttackRange = 5,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .8,
			Damage = 30,
			AttackRange = 5,
			Targets = 1,
		}
	},
	["Sniper"] = {
		[1]= {
			AttackSpeed = 3,
			Damage = 15,
			AttackRange = 15,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 2.7,
			Damage = 20,
			AttackRange = 17,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 2.5,
			Damage = 30,
			AttackRange = 19,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 2.3,
			Damage = 40,
			AttackRange = 21,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 2,
			Damage = 50,
			AttackRange = 25,
			Targets = 1,
		}
	},
	
	["Superman"] = {
		[1]= {
			AttackSpeed = 3,
			Damage = 15,
			AttackRange = 15,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 2.7,
			Damage = 20,
			AttackRange = 17,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 2.5,
			Damage = 25,
			AttackRange = 19,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 2.3,
			Damage = 30,
			AttackRange = 21,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 2,
			Damage = 40,
			AttackRange = 25,
			Targets = 1,
		}
	},
	["Dragon Knight"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 13,
			AttackRange = 9,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = .95,
			Damage = 18,
			AttackRange = 9,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = .9,
			Damage = 22,
			AttackRange = 9,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .8,
			Damage = 27,
			AttackRange = 9,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .7,
			Damage = 32,
			AttackRange = 9,
			Targets = 1,
		}
	},
	["Beam"] = {
		[1]= {
			AttackSpeed = 2.75,
			Damage = 12,
			AttackRange = 9,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 2.5,
			Damage = 15,
			AttackRange = 9,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 2.25,
			Damage = 19,
			AttackRange = 9,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 2,
			Damage = 24,
			AttackRange = 9,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 1.5,
			Damage = 28,
			AttackRange = 9,
			Targets = 1,
		}
	},
	["Soldier"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 5,
			AttackRange = 9,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = .9,
			Damage = 7,
			AttackRange = 9,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = .85,
			Damage = 9,
			AttackRange = 10,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .8,
			Damage = 11,
			AttackRange = 11,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .7,
			Damage = 15,
			AttackRange = 11,
			Targets = 1,
		}
	},
	["Shotgunner"] = {
		[1]= {
			AttackSpeed = 1.2,
			Damage = 4,
			AttackRange = 7,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1.1,
			Damage = 7,
			AttackRange = 7,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 1,
			Damage = 10,
			AttackRange = 7,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .9,
			Damage = 12,
			AttackRange = 7,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .8,
			Damage = 15,
			AttackRange = 7,
			Targets = 1,
		}
	},
	["Jedi"] = {
		[1]= {
			AttackSpeed = 1,
			Damage = 12,
			AttackRange = 7,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = .9,
			Damage = 15,
			AttackRange = 7,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = .85,
			Damage = 20,
			AttackRange = 7,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .8,
			Damage = 23,
			AttackRange = 7,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .7,
			Damage = 25,
			AttackRange = 7,
			Targets = 1,
		}
	},
	["Grenadier"] = {
		[1]= {
			AttackSpeed = 4,
			Damage = 7,
			AttackRange = 11,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 3.7,
			Damage = 10,
			AttackRange = 12,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 3.5,
			Damage = 15,
			AttackRange = 13,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 3.25,
			Damage = 20,
			AttackRange = 14,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 3,
			Damage = 25,
			AttackRange = 15,
			Targets = 1,
		}
	},
	
	["Pirate"] = {
		[1]= {
			AttackSpeed = 1.5,
			Damage = 4,
			AttackRange = 7,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1.3,
			Damage = 10,
			AttackRange = 7,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 1.1,
			Damage = 15,
			AttackRange = 7,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .9,
			Damage = 20,
			AttackRange = 7,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .7,
			Damage = 25,
			AttackRange = 7,
			Targets = 1,
		}
	},
	
	["Alien"] = {
		[1]= {
			AttackSpeed = 1.5,
			Damage = 4,
			AttackRange = 7,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1.3,
			Damage = 10,
			AttackRange = 7,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 1.1,
			Damage = 15,
			AttackRange = 7,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .9,
			Damage = 20,
			AttackRange = 7,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .7,
			Damage = 25,
			AttackRange = 7,
			Targets = 1,
		}
	},
	
	["Wizard"] = {
		[1]= {
			AttackSpeed = 1.5,
			Damage = 4,
			AttackRange = 7,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 1.3,
			Damage = 10,
			AttackRange = 7,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 1.1,
			Damage = 15,
			AttackRange = 7,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = .9,
			Damage = 20,
			AttackRange = 7,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = .7,
			Damage = 25,
			AttackRange = 7,
			Targets = 1,
		}
	},
	
	["Musician"] = {
		[1]= {
			AttackSpeed = 25,
			Damage = 5,
			AttackRange = 15,
			Targets = 1,			
		},
		[2]= {
			AttackSpeed = 25,
			Damage = 7,
			AttackRange = 15,
			Targets = 1,			
		},
		[3]= {
			AttackSpeed = 25,
			Damage = 8,
			AttackRange = 15,
			Targets = 1,			
		},
		[4]= {
			AttackSpeed = 25,
			Damage = 9,
			AttackRange = 15,
			Targets = 1,			
		},
		[5]= {
			AttackSpeed = 25,
			Damage = 10,
			AttackRange = 15,
			Targets = 1,			
		},
	},
	
	["Miner"] = {
		[1]= {
			AttackSpeed = 15,
			Damage = 10,
			AttackRange = 4,
			Targets = 1,			
		},
		[2] ={
			AttackSpeed = 15,
			Damage = 25,
			AttackRange = 4,
			Targets = 1,
		},
		[3] ={
			AttackSpeed = 10,
			Damage = 30,
			AttackRange = 4,
			Targets = 1,
		},
		[4] = {
			AttackSpeed = 8,
			Damage = 40,
			AttackRange = 4,
			Targets = 1,
		},
		[5] = {
			AttackSpeed = 7,
			Damage = 50,
			AttackRange = 4,
			Targets = 1,
		}
	},
}


local towerDebuffs = require(script.TowerDebuffs)

local createStatsFolder = {
	Damage = 0,
	AttackSpeed = 0,
	Exp = 0,
	Stunned = false,
	Level = 1,
	AttackRange = 5,
	Stars = 1,
	Targeting = "Furthest",
	Targets = 1,
}

function createStats(name,starLvl)
	local towerStats = Instance.new("Folder")
	towerStats.Name = "Stats"
	for i,v in pairs(createStatsFolder) do
		towerStats:SetAttribute(i,v)
	end
	towerStats:SetAttribute("Player",name)
	if starLvl then
		towerStats:SetAttribute("Stars",starLvl+1)
	end
	return towerStats
end


local module = {}


local fastForward = false


function module:SetFastForward(val)
	fastForward = val
end

function module:UpgradeTower(tower)
	
end


function module:SetStats(tower,plyr,starLvl)
	if not tower:FindFirstChild("Stats") then
		local towerStats = createStats(plyr.Name,starLvl)
		local lvl = 1
		if starLvl then lvl = starLvl+1 end
		for i,v in pairs(towers[tower.Name][lvl]) do
			if towerStats:GetAttribute(i) then
				towerStats:SetAttribute(i,v)
			end
		end
		towerStats:SetAttribute("OriginalPosition",tower.PrimaryPart.Position)
		towerStats.Parent = tower		
		towerStats.ChildAdded:Connect(function(child)
			print(child)
			towerDebuffs:DebuffAdded(child,towerStats)
		end)
		towerStats.ChildRemoved:Connect(function(child)
			towerDebuffs:DebuffRemoved(child,towerStats)
		end)
		if fastForward then
			local buff = Instance.new("IntValue")
			buff.Name = "FastForward"
			buff.Value = 99999999
			buff.Parent = towerStats
		end
	end
end

return module
