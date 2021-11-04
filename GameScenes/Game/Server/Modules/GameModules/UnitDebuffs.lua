local debris = game:GetService("Debris")

local fastForward=  false


local debuffs = {
	
	
	["HeartFreeze"] = {
		Multipliers = {
			WalkSpeed = .01
		},
		Adds = {

		},
		Particle = {
			game.ServerStorage.TowerDefensePackages.Effects.Slow
		},
		ParticleEnabledTimer = .3,
		ParticlesDebris = 3
	},
	
	["FastForward"] = {
		Multipliers = {
			WalkSpeed = 2
		},
		Adds = {

		},
		Particle = {
			
		},
		ParticleEnabledTimer = 0,
		ParticlesDebris = 0
	},

	["HeartFreezeDamage"] = {
		Multipliers = {
			Health = .2
		},
		Adds = {

		},
		Particle = {
			game.ServerStorage.TowerDefensePackages.Effects.Slow
		},
		ParticleEnabledTimer = .3,
		ParticlesDebris = 3
	},
	
	
	["Slow"] = {
		Multipliers = {
			WalkSpeed = .5
		},
		Adds = {
			
		},
		Particle = {
			game.ServerStorage.TowerDefensePackages.Effects.Slow
		},
		ParticleEnabledTimer = .3,
		ParticlesDebris = 3
	},
	["ForceChoke"] = {
		Multipliers = {
			WalkSpeed = .01
		},
		Adds = {

		},
		Particle = {
			
		},
		ParticleEnabledTimer = 0,
		ParticlesDebris = 0
	},
	["Crystallize"] = {
		Multipliers = {
			WalkSpeed = .01
		},
		Adds = {

		},
		Particle = {

		},
		ParticleEnabledTimer = 0,
		ParticlesDebris = 0
	},
	["Wraith"] = {
		Multipliers = {
			WalkSpeed = 3
		},
		Adds = {

		},
		Particle = {
			
		},
		ParticleEnabledTimer = 0,
		ParticlesDebris = 0
	},
	["SummonBats"] ={
		Multipliers = {
			WalkSpeed = .01
		},
		Adds = {

		},
		Particle = {
			game.ServerStorage.TowerDefensePackages.Effects.SummonBats
		},
		ParticleEnabledTimer = .3,
		ParticlesDebris = 3
	},
}


local module = {}

function module:FastForward(val)
	fastForward = val
end

function module:DebuffAdded(child,unit)
	for __,adjust in pairs(debuffs[child.Name].Multipliers) do
		unit.Humanoid[__] = unit.Humanoid[__]*adjust
	end
	for __,adjust in pairs(debuffs[child.Name].Adds) do
		unit.Humanoid[__] = unit.Humanoid[__]-adjust
	end
	for i,v in pairs(debuffs[child.Name].Particle) do
		local particle = game.ServerStorage.TowerDefensePackages.Effects[v.Name]:Clone()
		if particle:IsA("ParticleEmitter") then
			particle.Parent = unit.HumanoidRootPart
			wait(debuffs[child.Name].ParticleEnabledTimer)
			particle.Enabled = false
		else
			particle.Parent = workspace.Ignore
			particle.CFrame = unit.HumanoidRootPart.CFrame
			wait(debuffs[child.Name].ParticleEnabledTimer)
			for i,v in pairs(particle:GetChildren()) do
				v.Enabled = false
			end
		end
		local reduction = 1
		if fastForward then
			reduction = 2
		end
		debris:AddItem(particle,debuffs[child.Name].ParticlesDebris*reduction)
	end
end

function module:DebuffRemoved(child,unit)
	for __,adjust in pairs(debuffs[child.Name].Multipliers) do
		if adjust and unit:FindFirstChild("Humanoid") then
			unit.Humanoid[__] = unit.Humanoid[__]/adjust
		end
	end
	for __,adjust in pairs(debuffs[child.Name].Adds) do
		if adjust and unit:FindFirstChild("Humanoid") then
			print(__,adjust)
			unit.Humanoid[__] = unit.Humanoid[__]+adjust
		end
	end
end

return module
