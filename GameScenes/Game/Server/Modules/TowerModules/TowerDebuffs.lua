local module = {}

local debris = game:GetService("Debris")




local debuffs = {


	["Frozen"] ={
		WhichStat = {
			Stunned = true
		},
	},
	["AttackSpeed"] = {
		WhichStat = {
			AttackSpeed = 1.2
		}
	},
	["FastForward"] = {
		WhichStat = {
			AttackSpeed = 2
		}
	}
}




function module:DebuffAdded(child,towerStats)
	print(child.Name)
	debris:AddItem(child,child.Value)
	for whichOne,adjust in pairs(debuffs[child.Name].WhichStat) do
		if whichOne == "Stunned" then
			print(towerStats:GetAttribute("Stunned"))
			towerStats:SetAttribute("Stunned", true)
			if child.Name == "Frozen" then
				towerStats.Parent.Hitbox.Transparency = .5
				towerStats.Parent.Hitbox.Reflectance = .5
			end
		elseif whichOne == "AttackSpeed" then
			local attackSpeed = towerStats:GetAttribute("AttackSpeed")
			towerStats:SetAttribute("AttackSpeed",attackSpeed/adjust)
		end
	end
end

function module:DebuffRemoved(child,towerStats)
	for __,adjust in pairs(debuffs[child.Name].WhichStat) do
		if __ == "Stunned" then
			
			local canUnstun = true
			local canremoveStunType = true
			
			for i,v in pairs(towerStats:GetChildren()) do
				if debuffs[child.Name].WhichStat.Stunned == true then
					if child.Name == v.Name then
						canremoveStunType = false
					end
					canUnstun = false
				end
			end
			
			if canremoveStunType then
				if child.Name == "Frozen" then
					towerStats.Parent.Hitbox.Transparency = 1
				end
			end
			if canUnstun then
				towerStats:SetAttribute("Stunned", false)
			end
		elseif __ == "AttackSpeed" then
			local attackSpeed = towerStats:GetAttribute("AttackSpeed")
			towerStats:SetAttribute("AttackSpeed", attackSpeed*adjust)
		end
	end
end

return module

