local ContentProvider = game:GetService("ContentProvider")


local towerGuis = {
	["Samurai"] = {Price = "$500"},
	["Sniper"] = {Image = "6800030688", Price = "$500"},
	["Soldier"] = {Image = "6804899975", Price = "$300"},
	["Grenadier"] = {Image = "6808160269", Price = "$400"},
	["Jedi"] = {Image = "6808160269", Price = "$600"},
	["Sith"] = {Image = "", Price = "$700"},
	["Boxer"] = {Image = "", Price = "$400"},
	["Cowboy"] = {Image = "", Price = "$600"},
	["Pirate"] = {Image = "", Price = "$650"},
	["Miner"] = {Image = "", Price = "$300"},
	["Alien"] = {Image = "", Price = "$400"},
	["Ninja"] = {Image = "", Price = "$475"},
	["Wizard"] = {Image = "", Price = "$300"},
	["Captain America"] = {Image = "", Price = "$550"},
	["Superman"] = {Image = "", Price = "$500"},
	["Dragon Knight"] = {Image = "", Price = "$500"},
	["Beam"] = {Image = "", Price = "$400"},
	["Crossbow"] = {Image = "", Price = "$550"},
	["Shotgunner"] = {Image = "", Price = "$350"},
	["Minigunner"] = {Image = "", Price = "$450"},
	["Musician"] = {Image = "", Price = "$250"},

}


local module = {}





function module:CreateTowerIcon(tower)
	local gui = game.ReplicatedStorage.TowerDefenseLocalPackages.Guis.Towers.Gui:Clone()
	gui.Price.Text = towerGuis[tower].Price
	gui.Tower.Text = tower
	return gui
end


return module
