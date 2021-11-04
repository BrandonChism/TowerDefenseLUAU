local towers = {
	["Samurai"] = 500,
	["Sniper"] = 500,
	["Soldier"] = 300,
	["Grenadier"] = 400,
	["Jedi"] = 700,
	["Sith"] = 700,
	["Boxer"] = 400,
	["Cowboy"] = 600,
	["Pirate"] = 600,
	["Miner"] = 300,
	["Alien"] = 400,
	["Beam"] = 400,
	["Ninja"] = 475,
	["Wizard"] = 300,
	["Dragon Knight"] = 500,
	["Crossbow"] = 550,
	["Shotgunner"] = 350,
	["Minigunner"] = 450,
	["Musician"] = 250,

}


local module = {}

function module:TowerPrice(tower)
	return towers[tower]
end

return module
