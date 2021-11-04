

local debris = game:GetService("Debris")
local targetingModule = require(script.Parent.TargetingModule)
local particleModule = require(script.TowerAttackParticle)

local fastForward = false




function applyDamage(targets,dmg)
	for i,unit in pairs(targets) do
		if unit and unit:FindFirstChildWhichIsA("Humanoid") then
			if unit:GetAttribute("Shield") >0 then
				local hp = unit:FindFirstChildWhichIsA("Humanoid")
				local shieldHp = unit:GetAttribute("Shield")
				local diff = shieldHp-dmg
				if diff >= 0 then
					unit:SetAttribute("Shield",0)
					if hp.Health - diff >0 then
						hp:TakeDamage(diff)
					else
						hp.Health = 0
					end
				else
					unit:SetAttribute("Shield",shieldHp-dmg)
				end
			else
				local hp = unit:FindFirstChildWhichIsA("Humanoid")
				if hp.Health-dmg > 0 then
					hp:TakeDamage(dmg)
				else
					hp.Health = 0
				end
			end
		end
	end
end


local returnClosest = function(tower,targets, amount)
	return targetingModule:returnClosest(tower,targets,amount)
end



local returnClosestFar = function(tower,targets,amount)	
	return targetingModule:returnClosestFar(tower,targets,amount)	
end



local returnStrongest = function(tower,targets,amount)	
	return targetingModule:retrunStrongest(tower,targets,amount)	
end



function playSound(tower,sound)
	if game.ServerStorage.TowerDefensePackages.Sounds[tower.Name] then
		if game.ServerStorage.TowerDefensePackages.Sounds[tower.Name][sound] then
			local pSound = game.ServerStorage.TowerDefensePackages.Sounds[tower.Name][sound]:Clone()
			pSound.Parent = tower.Hitbox
			pSound:Play()
			debris:AddItem(pSound,5)
		end
	end
end

local targetingFunctions = {
	["Closest"] = {fn = returnClosest},
	["Furthest"] = {fn = returnClosestFar},
	["Strongest"] = {fn = returnStrongest},
}

local Projectile = {
	["Soldier"] = {"MeshPart","Bullet"},
	["Sniper"] = {"Sniper","Bullet"},
	["Shotgunner"] = {"RightHand","Bullet"},
	["Minigunner"] = {"RightHand","Bullet"},
	["Alien"] = {"Gun","SpaceBullet"},
	["Ninja"] = {"RightHand","Kunai"},
	["Wizard"] = {"RightHand","WizardOrb"},
	["Crossbow"] = {"HumanoidRootPart","Bolt"}

}


local module = {}



function module:SetFastForward(val)
	fastForward = val
end

local function sendBulletToClients(tower, target)
	--Bullet stuff
	if Projectile[tower.Name] then
		local gun = tower.Tower[Projectile[tower.Name][1]]
		if gun then
			local function getGunAttachment(gun)
				return gun:FindFirstChildOfClass("Attachment")
			end

			local function getRandomLimb(target)
				if target and #target:GetChildren() > 0 then
					local limbs = {}

					for i, v in pairs(target:GetDescendants()) do
						if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
							table.insert(limbs, v)
						end
					end

					return limbs[math.random(1, #limbs)]
				else
					return target.PrimaryPart
				end
			end

			local targetPart = getRandomLimb(target)
			if targetPart then
				local vA = getGunAttachment(gun)
				if not vA then vA = gun end
				local vB = targetPart

				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Bullet:FireAllClients(vA, vB.Position,tower,Projectile[tower.Name][2])
			else
				warn("target part not found :(")
			end
		end
	end
end

local BasicAttackFunction = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Fire")
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
					particleModule:CreateParticles(tower,targets[__].HumanoidRootPart.CFrame,targets[__])
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
					sendBulletToClients(tower, targets[__])
				end
			end
			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
		end
		wait(.1)
	end
end




local Minigunner = function(tower)
	wait(4)
	local heat = 0
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Fire")
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
					particleModule:CreateParticles(tower,targets[__].HumanoidRootPart.CFrame,targets[__],fastForward)
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
					sendBulletToClients(tower, targets[__])
				end
			end
		end
		wait(.1)
	end
end


local function GetTouchingParts(part)
	local connection = part.Touched:Connect(function() end)
	local results = part:GetTouchingParts()
	connection:Disconnect()
	return results
end


local BeamAttack = function(tower)
	wait(4)
	local towerOriginalPosition = tower.PrimaryPart.CFrame
	while tower and tower:FindFirstChild("Stats") do
		local round = game.ServerStorage.TowerDefensePackages.getRound:Invoke()
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[1] and targets[1]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Fire")
					local targetPosition = targets[1].HumanoidRootPart.Position
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
					if fastForward then
						wait(.25)
					else
						wait(.5)
					end
					
					
					local saberHitBox = game.ServerStorage.TowerDefensePackages.Effects.Jedi.LightSaberThrow:Clone()
					if fastForward then
						debris:AddItem(saberHitBox,.25)
					else
						debris:AddItem(saberHitBox,.5)
					end
					saberHitBox.CFrame = CFrame.new(tower.PrimaryPart.Position,targetPosition )
					saberHitBox.Size = Vector3.new(saberHitBox.Size.X/2,saberHitBox.Size.Y,saberHitBox.Size.Z/2)
					saberHitBox.CFrame = saberHitBox.CFrame*CFrame.new(0,0,-saberHitBox.Size.Z/2)
					saberHitBox.Parent = workspace.Ignore.InvisWalls
					local stuffhitBySaber = GetTouchingParts(saberHitBox)
					local humanoidsHit = {}
					for i,v in pairs(stuffhitBySaber) do
						if v.Parent:FindFirstChild("Humanoid") and v.Parent.Parent == workspace.Ignore.Enemies then
							local alreadyInTable
							for _,found in ipairs(humanoidsHit) do
								if found == v.Parent then
									alreadyInTable = true
								end
							end
							if not alreadyInTable then
								table.insert(humanoidsHit,v.Parent)
							end
						end
					end
					
					applyDamage(humanoidsHit,tower.Stats:GetAttribute("Damage"))
					
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Tween:FireAllClients(tower.Tower.PrimaryPart,tower.Tower.PrimaryPart.CFrame*CFrame.new(0,0,-10),.3)
					if fastForward then
						wait(.2)
					else
						wait(.4)
					end
					tower:SetPrimaryPartCFrame(tower.Tower.PrimaryPart.CFrame*CFrame.new(0,0,-10))
					
					--applyDamage(targets,tower.Stats:GetAttribute("Damage"))
					--sendBulletToClients(tower, targets[__])
				end
			end
			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
		end
		wait(.1)
		if round == game.ServerStorage.TowerDefensePackages.getRound:Invoke() then
		else
			tower:SetPrimaryPartCFrame(towerOriginalPosition)
		end
	end
end



local MultipleAttacksSingleTargetFunc = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			print('attacking')
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,1)
			if #targets >0 then
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
			end
			for i=1,tower.Stats:GetAttribute("Targets") do
				if targets and targets[1] and tower then
					if targets[1]:FindFirstChild("HumanoidRootPart") then
						if (targets[1].HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
							playSound(tower,"Fire")
							sendBulletToClients(tower, targets[1])
							tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z)))
							particleModule:CreateParticles(tower,targets[1].HumanoidRootPart.CFrame,targets[1])
							applyDamage(targets,tower.Stats:GetAttribute("Damage"))
							if fastForward then
								wait(.15)
							else
								wait(.3)
							end
						else
							break
						end
					else
						break
					end
				end
			end
			if tower:FindFirstChild("Stats") then else return end
			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
		end
		wait(.2)
	end
end





local SniperAttackFunction = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			tower.Stats:SetAttribute("Stunned",true)
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") then
					playSound(tower,"Lockon")
					particleModule:CreateParticles(tower,targets[__].HumanoidRootPart.CFrame,targets[__],'Assassinate')
				end
			end
			for i=1,2,.5 do
				for __,unit in ipairs(targets) do
					if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
						if fastForward then
							wait(.25)
						else
							wait(.5)
						end
						else break
					end
				end
			end
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Assassinate")
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
					applyDamage(targets,tower.Stats:GetAttribute("Damage")*2)
					if fastForward then
						wait(.25)
					else
						wait(.5)
					end
				end
			end
			if fastForward then
				wait(.25)
			else
				wait(.5)
			end
			if tower:FindFirstChild("Hitbox") then
				tower.Stats:SetAttribute("Stunned",false)
				if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")*13 ) end
			else
				return
			end
		end
		wait(.2)
	end
end


local MultiFireAttackFunction = function(tower)
	wait(4)
	local attacks = 0
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Fire")
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
					particleModule:CreateParticles(tower,targets[__].HumanoidRootPart.CFrame,targets[__])
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
					
					sendBulletToClients(tower, targets[1])
				end
			end
			attacks +=1
			if attacks >= 6  then wait(tower.Stats:GetAttribute("AttackSpeed")*10) attacks=0 end
		end
		wait(.25)
	end
end

local ForcePush = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,5)
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") and not targets[__]:GetAttribute("Boss") then
					if workspace.Ignore.Path:FindFirstChild(tostring(targets[__].Location.Value-1)) then
						local forcePushDistance = 8
						playSound(tower,"ForcePush")
						tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
						game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].ForcePush,fastForward)
						particleModule:CreateParticles(tower,tower.Tower.PrimaryPart.CFrame,nil,"ForcePush")
						local PathDistance = (workspace.Ignore.Path[tostring(targets[__].Location.Value-1)].Position-workspace.Ignore.Path[tostring(targets[__].Location.Value)].Position).magnitude
						local UnitDistanceToPathEnd = (targets[__].HumanoidRootPart.Position-workspace.Ignore.Path[tostring(targets[__].Location.Value-1)].Position).magnitude
						tower.Stats:SetAttribute("Stunned",true)
						if UnitDistanceToPathEnd >forcePushDistance then
							local force
							targets[__]:SetPrimaryPartCFrame(targets[__].PrimaryPart.CFrame*CFrame.new(0,0,forcePushDistance))
							
						else
							if workspace.Ignore.Path:FindFirstChild(tostring(targets[__].Location.Value-2)) then
								--has to wrap behind other point
								forcePushDistance = forcePushDistance-UnitDistanceToPathEnd
								
								local CFrameToLook = CFrame.new(
									workspace.Ignore.Path[tostring(targets[__].Location.Value-2)].Position,
									workspace.Ignore.Path[tostring(targets[__].Location.Value-1)].Position
								)			
								local distTo = (workspace.Ignore.Path[tostring(targets[__].Location.Value-2)].Position-workspace.Ignore.Path[tostring(targets[__].Location.Value-1)].Position).magnitude
								
								
								CFrameToLook = CFrameToLook*CFrame.new(0,0,-distTo+forcePushDistance)
								
								targets[__].Location.Value=targets[__].Location.Value-1								
								targets[__].Location:SetAttribute("Halt",true)
								targets[__]:SetPrimaryPartCFrame(CFrameToLook)
							else
								targets[__]:SetPrimaryPartCFrame(workspace.Ignore.Path[tostring(targets[__].Location.Value-1)].CFrame)
								--there is no other point to wrap behind, so put it at the earliest point
							end
						end
						
					else
						
					end
				end
			end
						
			if tower:FindFirstChild("Hitbox") then
				if #targets >0 then 
					if fastForward then
						wait(.5)
					else
						wait(1)
					end
					if tower then
						if tower:FindFirstChild("Hitbox") then
							tower.Stats:SetAttribute("Stunned",false)
							wait(tower.Stats:GetAttribute("AttackSpeed")*9 ) 
						end
					end
				end
			else
				return
			end
			
		end
		wait(.25)
	end
end




local ForceChoke = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		local usedAbility = false
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= 14 then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,5)
			if #targets> 0 then
				playSound(tower,"ForceLift")
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers.Sith.VaderForce,fastForward)
			end
			for __,v in pairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") and not targets[__]:GetAttribute("Boss") then
					if targets[1] then
						if targets[1]:FindFirstChildWhichIsA("HumanoidRootPart") then
							tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z)))
						end
					end
					tower.Stats:SetAttribute("Stunned",true)
					usedAbility = true
					local Debuff= Instance.new("IntValue")
					Debuff.Name = "ForceChoke"
					Debuff.Parent = v.Debuffs
					debris:AddItem(Debuff,4)
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(v.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers.Sith.ForceSith,fastForward)
					coroutine.wrap(function()
						if v:FindFirstChild("HumanoidRootPart") then
							for i=.5,4,.5 do
								if v:FindFirstChild("HumanoidRootPart") then
									applyDamage({v},tower.Stats:GetAttribute("Damage"))
									if fastForward then
										wait(.25)
									else
										wait(.5)
									end
								end
							end
							return
						end
					end)(v)
				end
			end
			
			
		end
			

		if tower:FindFirstChild("Hitbox") then
			if usedAbility then
				if fastForward then
					wait(2)
				else
					wait(4)
				end
				tower.Stats:SetAttribute("Stunned",false)
				wait(tower.Stats:GetAttribute("AttackSpeed")*12 ) 
			end
		else
			return
		end
		wait(.25)
	end
end




local SithLightning = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		local usedAbility = false
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= 14 then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,10)
			if #targets> 0 then
				for i,v in pairs(tower.Tower.LeftHand.Attachment:GetChildren()) do
					v.Enabled = true
				end
				for i,v in pairs(tower.Tower.RightHand.Attachment:GetChildren()) do
					v.Enabled = true
				end
				playSound(tower,"Lightning")
				
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers.Sith.DarthLightning,fastForward)
			end
			for __,v in pairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					tower.Stats:SetAttribute("Stunned",true)
					usedAbility = true
					local particle = game.ServerStorage.TowerDefensePackages.Effects.Sith.SithLightning:Clone()
					if v:FindFirstChild("UpperTorso") then
						particle.Parent = v.UpperTorso
					else
						if  targets[__]:FindFirstChild("Head") then
							particle.Parent = v.Head
						else
							if targets[__]:FindFirstChild("HumanoidRootPart") then
								particle.Parent = v.HumanoidRootPart
							end
						end
					end
					debris:AddItem(particle,4)
					coroutine.wrap(function()
						if v:FindFirstChild("HumanoidRootPart") then
							for i=.5,4,.5 do
								applyDamage({v},tower.Stats:GetAttribute("Damage"))
								if fastForward then
									wait(.25)
								else
									wait(.5)
								end
							end
							return
						end
					end)(v)
				end
			end


		end


		if tower:FindFirstChild("Hitbox") then
			if usedAbility then
				if fastForward then
					wait(.5)
				else
					wait(1)
				end
				for i,v in pairs(tower.Tower.LeftHand.Attachment:GetChildren()) do
					v.Enabled = false
				end
				for i,v in pairs(tower.Tower.RightHand.Attachment:GetChildren()) do
					v.Enabled = false
				end
				wait(tower.Stats:GetAttribute("AttackSpeed")) 
				tower.Stats:SetAttribute("Stunned",false)
			end
		else
			return
		end
		wait(.25)
	end
end



local ThrowSaber = function(tower)
	wait(4.1)
	while tower and tower:FindFirstChild("Stats") do
		local threw = false
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= 14 then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,1)
			
			if targets[1] then
				threw = true
				tower.Stats:SetAttribute("Stunned",true)	
				if fastForward then
					wait(.15)
				else
					wait(.3)
				end
				if targets[1] and targets[1]:FindFirstChild("HumanoidRootPart") then
					
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z)))
					
					
					
					local saberHitBox = game.ServerStorage.TowerDefensePackages.Effects.Jedi.LightSaberThrow:Clone()

					saberHitBox.CFrame = CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z))
					saberHitBox.CFrame = saberHitBox.CFrame*CFrame.new(0,0,-saberHitBox.Size.Z/2)
					saberHitBox.Parent = workspace.Ignore.InvisWalls
					local stuffhitBySaber = GetTouchingParts(saberHitBox)
					local humanoidsHit = {}
					for i,v in pairs(stuffhitBySaber) do
						if v.Parent:FindFirstChild("Humanoid") and v.Parent.Parent == workspace.Ignore.Enemies then
							local alreadyInTable
							for _,found in ipairs(humanoidsHit) do
								if found == v.Parent then
									alreadyInTable = true
								end
							end
							if not alreadyInTable then
								table.insert(humanoidsHit,v.Parent)
							end
						end
					end
					
					for i,v in pairs(humanoidsHit) do
						particleModule:CreateParticles("",v.PrimaryPart.CFrame,v,"SaberHit")
					end
					applyDamage(humanoidsHit,tower.Stats:GetAttribute("Damage"))
					
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].ThrowSaber,fastForward)
					playSound(tower,"SaberThrow1")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow2")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow1")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow2")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow1")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow2")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end

					local stuffhitBySaber = GetTouchingParts(saberHitBox)
					saberHitBox:Destroy()
					local humanoidsHit = {}
					for i,v in pairs(stuffhitBySaber) do
						if v.Parent:FindFirstChild("Humanoid") and v.Parent.Parent == workspace.Ignore.Enemies then
							local alreadyInTable
							for _,found in ipairs(humanoidsHit) do
								if found == v.Parent then
									alreadyInTable = true
								end
							end
							if not alreadyInTable then
								table.insert(humanoidsHit,v.Parent)
							end
						end
					end
					for i,v in pairs(humanoidsHit) do
						particleModule:CreateParticles("",v.PrimaryPart.CFrame,v,"SaberHit")
					end
					applyDamage(humanoidsHit,tower.Stats:GetAttribute("Damage"))
					playSound(tower,"SaberThrow1")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow2")
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
					playSound(tower,"SaberThrow1")
					if fastForward then
						wait(.3)
					else
						wait(.6)
					end
				end
			end
		end
		
		if tower:FindFirstChild("Hitbox") then
			if threw then 
				tower.Stats:SetAttribute("Stunned",false)
				wait(tower.Stats:GetAttribute("AttackSpeed")*7 ) 
			end
		else
			return
		end
		wait(.25)
	end
end

local ThrowGrenadeFunc = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			local pos
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					pos = targets[__].HumanoidRootPart.Position
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
				end
			end
			if #targets>0 and pos then
				targets = {}
				for __,enemies in pairs(workspace.Ignore.Enemies:GetChildren()) do
					if enemies:FindFirstChild("HumanoidRootPart") then
						local dist = (enemies.HumanoidRootPart.Position-pos).magnitude
						if dist <= 6 then
							table.insert(targets,enemies)
						end
					end
				end
				if #targets>0 then
					playSound(tower,"Fire")
					if fastForward then
						wait(.05)
					else
						wait(.1)
					end
					particleModule:CreateParticles(tower,pos)
					playSound(tower,"Explosion")
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
				end
			end
			
			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
		end
		wait(.1)
	end
end



local shotgun = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			local pos
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					pos = targets[__].HumanoidRootPart.Position
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
				end
			end
			if #targets>0 and pos then
				targets = {}
				for __,enemies in pairs(workspace.Ignore.Enemies:GetChildren()) do
					if enemies:FindFirstChild("HumanoidRootPart") then
						sendBulletToClients(tower,enemies)
						local dist = (enemies.HumanoidRootPart.Position-pos).magnitude
						if dist <= 2.5 then
							table.insert(targets,enemies)
						end
					end
				end
				if #targets>0 then
					playSound(tower,"Fire")
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
				end
			end

			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
		end
		wait(.1)
	end
end

local BreathFire = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			local pos
			for __,unit in ipairs(targets) do
				if targets[1] and targets[1]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					pos = targets[1].HumanoidRootPart.Position
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z)))
				end
			end
			if #targets>0 and pos then
				tower.Stats:SetAttribute("Stunned",true)
				targets = {}
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].BreathFire,fastForward)
				for __,enemies in pairs(workspace.Ignore.Enemies:GetChildren()) do
					if enemies:FindFirstChild("HumanoidRootPart") then
						local dist = (enemies.HumanoidRootPart.Position-pos).magnitude
						if dist <= 9 then
							table.insert(targets,enemies)
						end
					end
				end
				if #targets>0 then
					playSound(tower,"BreathFire")
					if fastForward then
						wait(.05)
					else
						wait(.1)
					end
					for i,v in pairs(tower.Tower.Head.Attachment:GetChildren()) do
						v.Enabled = true
					end
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
				end
			end

			if #targets >0 then
				if fastForward then
					wait(1.5/2)
				else
					wait(1.5)
				end
				for i,v in pairs(tower.Tower.Head.Attachment:GetChildren()) do
					v.Enabled = false
				end
				tower.Stats:SetAttribute("Stunned",false)
				local waitTime = 24
				if fastForward then waitTime = waitTime/2 end
				wait( waitTime - ( 2* tower.Stats:GetAttribute("Stars"))  )
			end
		end
		wait(1)
	end
end




local Musician = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			playSound(tower,"Fire")
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
			for i,v in pairs(workspace.Ignore.Towers:GetChildren()) do
				local dist = (v.PrimaryPart.Position-tower.PrimaryPart.Position).magnitude
				if dist <= tower.Stats:GetAttribute("AttackRange") then
					local buff = Instance.new("IntValue")
					buff.Name = "AttackSpeed"
					buff.Value = tower.Stats:GetAttribute("Damage")
					buff.Parent = v.Stats
					local particle = game.ServerStorage.TowerDefensePackages.Effects.Music:Clone()
					particle.Parent = v.PrimaryPart
					debris:AddItem(particle,tower.Stats:GetAttribute("Damage"))
				end
			end
		end
		wait(tower.Stats:GetAttribute("AttackSpeed"))
	end
end



local ArrowStorm = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			local pos
			for __,unit in ipairs(targets) do
				if targets[1] and targets[1]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					pos = targets[1].HumanoidRootPart.Position-Vector3.new(0,targets[1].Humanoid.HipHeight,0)
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[1].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[1].HumanoidRootPart.Position.Z)))
				end
			end
			if pos then
				local arrowStorm = game.ServerStorage.TowerDefensePackages.Effects.ArrowStorm:Clone()
				arrowStorm:SetPrimaryPartCFrame(CFrame.new(pos)-Vector3.new(0,-.3,0))
				arrowStorm.Parent = workspace.Ignore
				debris:AddItem(arrowStorm,4.1)
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].ArrowStorm,fastForward)
				for i= 1, 20 do
					targets = {}
					for __,enemies in pairs(workspace.Ignore.Enemies:GetChildren()) do
						if enemies:FindFirstChild("HumanoidRootPart") then
							local dist = (enemies.HumanoidRootPart.Position-pos).magnitude
							if dist <= 4 then
								table.insert(targets,enemies)
							end
						end
					end
					if #targets>0 then
						applyDamage(targets,tower.Stats:GetAttribute("Damage")/2)
					end
					if fastForward then
						wait(.1)
					else
						wait(.2)
					end
				end
				local waitTime = 30
				if fastForward then waitTime = 30/2 end
				wait( waitTime - ( 2* tower.Stats:GetAttribute("Stars"))  )
			end
		end
		wait(.15)
	end
end


local PirateAttackFunction = function(tower)
	wait(4)
	while tower and tower:FindFirstChild("Stats") do
		if tower.Stats:GetAttribute("Stunned") == false then
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange") then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Fire")
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Attack,fastForward)
					particleModule:CreateParticles(tower,targets[__].HumanoidRootPart.CFrame,targets[__])
					applyDamage(targets,tower.Stats:GetAttribute("Damage")*2)
					sendBulletToClients(tower, targets[__])
				end
			end
			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
			local targets = {}
			for i,v in pairs(workspace.Ignore.Enemies:GetChildren()) do
				if (v.HumanoidRootPart.Position-tower.PrimaryPart.Position).magnitude <= tower.Stats:GetAttribute("AttackRange")*2 then
					table.insert(targets,v)
				end
			end
			local tgtFunc = targetingFunctions[tower.Stats:GetAttribute("Targeting")].fn
			targets = tgtFunc(tower,targets,tower.Stats:GetAttribute("Targets"))
			for __,unit in ipairs(targets) do
				if targets[__] and targets[__]:FindFirstChild("HumanoidRootPart") and tower:FindFirstChild("Hitbox") then
					playSound(tower,"Shoot")
					tower.Tower:SetPrimaryPartCFrame(CFrame.new(tower.PrimaryPart.Position, Vector3.new(targets[__].HumanoidRootPart.Position.X,tower.PrimaryPart.Position.Y,targets[__].HumanoidRootPart.Position.Z)))
					game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(tower.Tower.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[tower.Name].Shoot,fastForward)
					particleModule:CreateParticles(tower,targets[__].HumanoidRootPart.CFrame,targets[__])
					applyDamage(targets,tower.Stats:GetAttribute("Damage"))
					sendBulletToClients(tower, targets[__])
				end
			end
			if #targets >0 then wait(tower.Stats:GetAttribute("AttackSpeed")) end
		end
		wait(.1)
	end
end


local MineGold = function(tower)
	wait(4) 
	while tower and tower:FindFirstChild("Stats") do
		local plyr = tower.Stats:GetAttribute("Player")		
		plyr = game.Players:FindFirstChild(plyr)
		if plyr then
			playSound(tower,"Mine")
			plyr.leaderstats.Gold.Value += tower.Stats:GetAttribute("Damage")
		end
		wait(tower.Stats:GetAttribute("AttackSpeed"))
	end
end


local towerAttacks = {
	['Cowboy'] = {
		[1] = {BasicAttackFunction,},
		[2] = {BasicAttackFunction},
		[3] = {BasicAttackFunction},
		[4] = {BasicAttackFunction},
		[5] = {BasicAttackFunction},
	},
	['Pirate'] = {
		[1] = {PirateAttackFunction,},
		[2] = {PirateAttackFunction},
		[3] = {PirateAttackFunction},
		[4] = {PirateAttackFunction},
		[5] = {PirateAttackFunction},
	},
	['Boxer'] = {
		[1] = {BasicAttackFunction},
		[2] = {BasicAttackFunction},
		[3] = {BasicAttackFunction},
		[4] = {BasicAttackFunction},
		[5] = {BasicAttackFunction},
	},
	['Alien'] = {
		[1] = {BasicAttackFunction},
		[2] = {BasicAttackFunction},
		[3] = {BasicAttackFunction},
		[4] = {BasicAttackFunction},
		[5] = {BasicAttackFunction},
	},
	['Ninja'] = {
		[1] = {BasicAttackFunction},
		[2] = {BasicAttackFunction},
		[3] = {BasicAttackFunction},
		[4] = {BasicAttackFunction},
		[5] = {BasicAttackFunction},
	},
	['Wizard'] = {
		[1] = {BasicAttackFunction},
		[2] = {BasicAttackFunction},
		[3] = {BasicAttackFunction},
		[4] = {BasicAttackFunction},
		[5] = {BasicAttackFunction},
	},
	['Samurai'] = {
		[1] = {BasicAttackFunction},
		[2] = {MultipleAttacksSingleTargetFunc},
		[3] = {MultipleAttacksSingleTargetFunc},
		[4] = {MultipleAttacksSingleTargetFunc},
		[5] = {MultipleAttacksSingleTargetFunc},
	},
	['Crossbow'] = {
		[1] = {MultipleAttacksSingleTargetFunc},
		[2] = {MultipleAttacksSingleTargetFunc},
		[3] = {MultipleAttacksSingleTargetFunc,ArrowStorm},
		[4] = {MultipleAttacksSingleTargetFunc,ArrowStorm},
		[5] = {MultipleAttacksSingleTargetFunc,ArrowStorm},
	},
	['Jedi'] = {
		[1] = {BasicAttackFunction},
		[2] = {BasicAttackFunction,ForcePush},
		[3] = {BasicAttackFunction,ForcePush},
		[4] = {BasicAttackFunction,ForcePush},
		[5] = {BasicAttackFunction,ForcePush,ThrowSaber},
	},
	['Captain America'] = {
		[1] = {BasicAttackFunction,ThrowSaber},
		[2] = {BasicAttackFunction,ThrowSaber},
		[3] = {BasicAttackFunction,ThrowSaber},
		[4] = {BasicAttackFunction,ThrowSaber},
		[5] = {BasicAttackFunction,ThrowSaber},
	},
	['Sith'] = {
		[1] = {BasicAttackFunction},
		[2] = {BasicAttackFunction,ThrowSaber},
		[3] = {BasicAttackFunction,ThrowSaber},
		[4] = {BasicAttackFunction,ThrowSaber,ForceChoke},
		[5] = {SithLightning},
	},
	['Sniper'] = {
		[1] = {BasicAttackFunction,SniperAttackFunction},
		[2] = {BasicAttackFunction,SniperAttackFunction},
		[3] = {BasicAttackFunction,SniperAttackFunction},
		[4] = {BasicAttackFunction,SniperAttackFunction},
		[5] = {BasicAttackFunction,SniperAttackFunction},
	},
	['Soldier'] = {
		[1] = {BasicAttackFunction,MultiFireAttackFunction},
		[2] = {BasicAttackFunction,MultiFireAttackFunction},
		[3] = {BasicAttackFunction,MultiFireAttackFunction},
		[4] = {BasicAttackFunction,MultiFireAttackFunction},
		[5] = {BasicAttackFunction,MultiFireAttackFunction},
	},
	['Grenadier'] = {
		[1] = {ThrowGrenadeFunc},
		[2] = {ThrowGrenadeFunc},
		[3] = {ThrowGrenadeFunc},
		[4] = {ThrowGrenadeFunc},
		[5] = {ThrowGrenadeFunc},
	},
	['Miner'] = {
		[1] = {MineGold},
		[2] = {MineGold},
		[3] = {MineGold},
		[4] = {MineGold},
		[5] = {MineGold},
	},
	['Dragon Knight'] = {
		[1] = {BasicAttackFunction,BreathFire},
		[2] = {BasicAttackFunction,BreathFire},
		[3] = {BasicAttackFunction,BreathFire},
		[4] = {BasicAttackFunction,BreathFire},
		[5] = {BasicAttackFunction,BreathFire},
	},
	['Beam'] = {
		[1] = {BeamAttack},
		[2] = {BeamAttack},
		[3] = {BeamAttack},
		[4] = {BeamAttack},
		[5] = {BeamAttack},
	},
	['Shotgunner'] = {
		[1] = {shotgun},
		[2] = {shotgun},
		[3] = {shotgun},
		[4] = {shotgun},
		[5] = {shotgun},
	},
	['Minigunner'] = {
		[1] = {Minigunner},
		[2] = {Minigunner},
		[3] = {Minigunner},
		[4] = {Minigunner},
		[5] = {Minigunner},
	},
	['Musician'] = {
		[1] = {Musician},
		[2] = {Musician},
		[3] = {Musician},
		[4] = {Musician},
		[5] = {Musician},
	},
}

function module:WhichTower(tower)
	return towerAttacks[tower.Name][tower.Stats:GetAttribute("Stars")]
end

return module
