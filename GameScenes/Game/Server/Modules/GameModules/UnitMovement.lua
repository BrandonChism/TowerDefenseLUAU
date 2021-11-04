
local ReachedEnd = require(script.UnitDamage)

local TowerAttackParticle = require(script.Parent.Parent.TowerModule.TowerAttackModule.TowerAttackParticle)
local UnitDebuffs = require(script.Parent.UnitDebuffs)
local UnitHealth = require(script.Parent.UnitHealth)
local UnitDamage = require(script.UnitDamage)

local PhysicsService = game:GetService("PhysicsService")

function setPhysics(model,physics)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(v,physics)
		end
	end
end


function setOwnerShip(unit)
	for i,v in pairs(unit:GetChildren()) do
		if v:IsA("BasePart") then
			v:SetNetworkOwner(nil)
		end
	end
end
local debris = game:GetService("Debris")

function playSound(unit,sound)
	if game.ServerStorage.TowerDefensePackages.Sounds[sound] then
		if game.ServerStorage.TowerDefensePackages.Sounds[sound] then
			local pSound = game.ServerStorage.TowerDefensePackages.Sounds[sound]:Clone()
			pSound.Parent = unit.HumanoidRootPart
			pSound:Play()
			debris:AddItem(pSound,5)
		end
	end
end

local module = {}

function module:MoveToCoroutine(unit)
	local goals = workspace.Ignore.Path
	local atGoal = false
	local destination =nil
	setOwnerShip(unit)
	

	
	local function moveTo()
		
		

		local con2
		local con3
		local connection
		if unit:FindFirstChild("Humanoid") then else return end
		connection = unit.Humanoid.MoveToFinished:Connect(function(reached)
			if not atGoal then
				connection:Disconnect()
				con2:Disconnect()
				con3:Disconnect()
				wait()
				moveTo()
			end
		end)
		
		
		
		con2 = unit.Location:GetAttributeChangedSignal("Backwards"):Connect(function()
			if unit.Location:GetAttribute("Backwards") == true then
				if unit.Location.Value ~= 0 then
					connection:Disconnect()
					con2:Disconnect()
					con3:Disconnect()
					wait()
					destination =  goals[tostring(unit.Location.Value-1)]
					moveTo()
				end
			else
				connection:Disconnect()
				con2:Disconnect()
				con3:Disconnect()
				wait()
				destination =  goals[tostring(unit.Location.Value+1)]
				moveTo()
			end
		end)
		
		con3 = unit.Location:GetAttributeChangedSignal("Halt"):Connect(function()
			if unit.Location:GetAttribute("Halt") == true then
				unit.Location:SetAttribute("Halt",false)
				connection:Disconnect()
				con2:Disconnect()
				con3:Disconnect()
				wait()
				destination = goals[tostring(unit.Location.Value)]
				moveTo()
			end
		end)

		if #goals:GetChildren() > unit.Location.Value then
			if not destination then
				destination = goals[tostring(unit.Location.Value)]
				if goals[tostring(unit.Location.Value)]:IsA("Folder") then
					destination = destination[math.random(1,#destination:GetChildren())]
				end
			end
			if (unit.HumanoidRootPart.Position-destination.Position).Magnitude > .9+(unit.Humanoid.HipHeight) then
				unit.Humanoid:MoveTo(destination.Position)
			else
				if unit.Location:GetAttribute("Backwards") == false then
					unit.Location.Value +=1
				else
					if unit.Location.Value~= 0 then
						unit.Location.Value-=1
					end
				end
				if #goals:GetChildren() > unit.Location.Value then
					if destination:GetAttribute("Teleport") then
						local setTo = goals[tostring(unit.Location.Value)]
						unit:SetPrimaryPartCFrame(setTo.CFrame+Vector3.new(0,unit.Humanoid.HipHeight,0))
					end
					destination = nil
					con2:Disconnect()
					con3:Disconnect()

					connection:Disconnect()
					wait()
					moveTo()
				else
					atGoal = true
					destination = nil
					con2:Disconnect()
					con3:Disconnect()

					connection:Disconnect()
					ReachedEnd:ReachedEnd(unit)
					return
				end
			end
		else
			destination = nil
			atGoal = true
			con2:Disconnect()
			con3:Disconnect()

			connection:Disconnect()
			ReachedEnd:ReachedEnd(unit)
			return
		end
		
	end
	
	moveTo()
	
end

function module:SmokeScreenCoroutine(unit)
	while wait(math.random(4,23)) do
		if unit and unit:FindFirstChild("HumanoidRootPart") then
			TowerAttackParticle:CreateParticles(unit,unit.HumanoidRootPart.CFrame,nil,"SmokeScreen")
			wait(.2)
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				playSound(unit,"SmokeScreen")
				unit:SetAttribute("Targetable",false)
				for i,v in pairs(unit:GetDescendants()) do
					if v:IsA("BasePart") and v.Name ~="HumanoidRootPart" then
						v.Transparency = .8
					end
				end
			end
			wait(2)
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				unit:SetAttribute("Targetable",true)
				for i,v in pairs(unit:GetDescendants()) do
					if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
						v.Transparency = 0
					end
				end
			end
			else break
		end
	end

end


function module:Wraith(unit)
	while wait(math.random(10,23)) do
		if unit and unit:FindFirstChild("HumanoidRootPart") then
			playSound(unit,"Wraith")
			local debuff = Instance.new("IntValue")
			debuff.Name = "Wraith"
			debuff.Parent = unit.Debuffs
			debris:AddItem(debuff,2)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies.Wraith.Wraith)
			unit:SetAttribute("Targetable",false)
			for i,v in pairs(unit:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~="HumanoidRootPart" then
					v.Material = Enum.Material.ForceField
				elseif v:IsA("Trail") then
					v.Enabled = true
				end
			end
			wait(2)
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				unit:SetAttribute("Targetable",true)
				for i,v in pairs(unit:GetDescendants()) do
					if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
						v.Material = Enum.Material.Foil
					elseif v:IsA("Trail") then
						v.Enabled = false
					end
				end
			end
		else break
		end
	end

end


function module:Sprint(unit)
	while wait(math.random(10,23)) do
		if unit and unit:FindFirstChild("HumanoidRootPart") then
			local debuff = Instance.new("IntValue")
			debuff.Name = "Wraith"
			debuff.Parent = unit.Debuffs
			debris:AddItem(debuff,2)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Football Zombie"].Sprint)
			unit.Head.Handle.Attachment.Core.Enabled = true
			unit.Head.Handle.Attachment.Space.Enabled = true
			wait(2)
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				unit.Head.Handle.Attachment.Core.Enabled = false
				unit.Head.Handle.Attachment.Space.Enabled = false
			end
		else break
		end
	end

end


function module:SetBossHP(unit)
	unit.Head.EnemyDisplay.AlwaysOnTop = true
	unit.Head.EnemyDisplay.EnemyName.TextColor3 = Color3.new(1,0,0)
	unit.Head.EnemyDisplay.EnemyName.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	unit.Head.EnemyDisplay.Size = UDim2.new(5,0,.6,0)
	unit.Head.EnemyDisplay.Frame.Frame.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,0),Color3.fromRGB(255,0,255))
end

function module:SummonUnits(unit,summonedUnit)
	while unit do
		wait(math.random(12,20))
		if unit:FindFirstChild("Humanoid") then
			local debuff = Instance.new("IntValue")
			debuff.Name = "SummonBats"
			debuff.Value = 1
			debuff.Parent = unit.Debuffs
			debris:AddItem(debuff,2)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies.Vampire.SummonBats)
			for i=1,4 do
				local Summon = game.ServerStorage.TowerDefensePackages.Enemies:FindFirstChild(summonedUnit):Clone()
				Summon:SetPrimaryPartCFrame(unit.PrimaryPart.CFrame+Vector3.new(math.random(0,1)/10,0,math.random(0,10)/10))
				Summon.Location.Value = unit.Location.Value
				setPhysics(Summon,"Units")
				Summon.Parent = workspace.Ignore.Enemies
				setOwnerShip(Summon)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
				UnitHealth:CreateUnitHealth(Summon)
				local currentHealth = Summon.Humanoid.Health
				Summon.Humanoid.HealthChanged:Connect(function(health)
					UnitDamage:Damaged(math.abs(health),Summon,currentHealth)
				end)
				local Debuffs = Instance.new("Folder")
				Debuffs.Name = "Debuffs"
				Debuffs.Parent = Summon
				Debuffs.ChildAdded:Connect(function(child) UnitDebuffs:DebuffAdded(child,Summon)end)
				Debuffs.ChildRemoved:Connect(function(child) UnitDebuffs:DebuffRemoved(child,Summon)end)
				local basicMove = function(Summon)
					module:MoveToCoroutine(Summon)
				end
				local func = coroutine.create(basicMove)
				coroutine.resume(func,Summon)
				wait(.15)
			end
		else
			return
		end
	end
end


local GuitarSoloEnemies = {
	"Zombie Deliver",
	"Zombie",
	"Zombie Knight",
	"Abomination",
	"Fire Zombie",
}


function module:GuitarSolo(unit)
	while unit do
		wait(math.random(12,20))
		if unit:FindFirstChild("Humanoid") then
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Rockstar Zombie"].Strum)
			local sound = game.ServerStorage.TowerDefensePackages.Sounds.GuitarStrum:Clone()
			sound.Parent = unit.PrimaryPart
			sound:Play()
			debris:AddItem(sound,5)
			for i=1,math.random(2,5) do
				wait(.5)
				local summonedUnit = GuitarSoloEnemies[math.random(1,#GuitarSoloEnemies)]
				local Summon = game.ServerStorage.TowerDefensePackages.Enemies:FindFirstChild(summonedUnit):Clone()
				Summon:SetPrimaryPartCFrame(unit.PrimaryPart.CFrame+Vector3.new(math.random(-25,25)/10,0,math.random(-25,25)/10))
				Summon.Location.Value = unit.Location.Value
				setPhysics(Summon,"Units")
				Summon.Parent = workspace.Ignore.Enemies
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(Summon.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies[summonedUnit].Idle)
				setOwnerShip(Summon)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
				UnitHealth:CreateUnitHealth(Summon)
				local currentHealth = Summon.Humanoid.Health
				Summon.Humanoid.HealthChanged:Connect(function(health)
					UnitDamage:Damaged(math.abs(health),Summon,currentHealth)
				end)
				local Debuffs = Instance.new("Folder")
				Debuffs.Name = "Debuffs"
				Debuffs.Parent = Summon
				Debuffs.ChildAdded:Connect(function(child) UnitDebuffs:DebuffAdded(child,Summon)end)
				Debuffs.ChildRemoved:Connect(function(child) UnitDebuffs:DebuffRemoved(child,Summon)end)
				local basicMove = function(Summon)
					module:MoveToCoroutine(Summon)
				end
				local func = coroutine.create(basicMove)
				coroutine.resume(func,Summon)
				wait(.5)
			end
		else
			return
		end
	end
end



local RadioEnemies = {
	"Breacher",
	"Spy",
	"Soldier",
	"Scout",
	"Mercenary",
	"Vanguard"
}



function module:RadioIn(unit)
	while unit do
		wait(math.random(12,20))
		if unit:FindFirstChild("Humanoid") then
			local summonedUnit = RadioEnemies[math.random(1,#RadioEnemies)]
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies.Commander.Radio)
			for i=1,math.random(2,5) do
				wait(.5)
				local Summon = game.ServerStorage.TowerDefensePackages.Enemies:FindFirstChild(summonedUnit):Clone()
				Summon:SetPrimaryPartCFrame(unit.PrimaryPart.CFrame+Vector3.new(math.random(-25,25)/10,0,math.random(-25,25)/10))
				Summon.Location.Value = unit.Location.Value
				setPhysics(Summon,"Units")
				Summon.Parent = workspace.Ignore.Enemies
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(Summon.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies[summonedUnit].Idle)
				setOwnerShip(Summon)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
				UnitHealth:CreateUnitHealth(Summon)
				local currentHealth = Summon.Humanoid.Health
				Summon.Humanoid.HealthChanged:Connect(function(health)
					UnitDamage:Damaged(math.abs(health),Summon,currentHealth)
				end)
				local Debuffs = Instance.new("Folder")
				Debuffs.Name = "Debuffs"
				Debuffs.Parent = Summon
				Debuffs.ChildAdded:Connect(function(child) UnitDebuffs:DebuffAdded(child,Summon)end)
				Debuffs.ChildRemoved:Connect(function(child) UnitDebuffs:DebuffRemoved(child,Summon)end)
				local basicMove = function(Summon)
					module:MoveToCoroutine(Summon)
				end
				local func = coroutine.create(basicMove)
				coroutine.resume(func,Summon)
				wait(.5)
			end
		else
			return
		end
	end
end

function module:BlockImmune(unit)
	while unit do
		wait(math.random(5,20))
		if unit:FindFirstChild("Humanoid") then
			local debuff = Instance.new("IntValue")
			unit:SetAttribute("Targetable",false)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Immune:FireAllClients(unit,3)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Crystal Commander"].Protect)
			wait(3)
			if unit then
				if unit:FindFirstChild("Humanoid") then
					unit:SetAttribute("Targetable",true)
				end
			end
		else
			return
		end
	end
end

function module:CrystalHeal(unit)
	while unit do
		wait(math.random(10,25))
		if unit:FindFirstChild("Humanoid") then
			local debuff = Instance.new("IntValue")
			unit:SetAttribute("Targetable",false)
			debuff.Name = "Crystallize"
			debuff.Value = 1
			debuff.Parent = unit.Debuffs
			debris:AddItem(debuff,.8)
			local effect = game.ServerStorage.TowerDefensePackages.Effects.CrystalQueen.Attachment:Clone()
			effect.Parent = unit.UpperTorso
			effect.WorldOrientation = Vector3.new(0,unit.HumanoidRootPart.Orientation.Y,0)
			effect.Position = Vector3.new(0,0,-.7)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Crystal Queen"].Heal)
			for i=1,20 do
				unit.Humanoid.Health+=77
				wait(.25)
				
				if math.modf(i/5) == 0 then
					for i,v in pairs(effect:GetChildren()) do
						v.Enabled = true
					end
				end
				if math.modf((i-1)/5) == 0 then
					for i,v in pairs(effect:GetChildren()) do
						v.Enabled = false
					end
				end
			end
			effect:Destroy()
			if unit then
				if unit:FindFirstChild("Humanoid") then
					unit:SetAttribute("Targetable",true)
				end
			end
		else
			return
		end
	end
end


function module:Crystallize(unit)
	while unit do
		wait(math.random(10,25))
		if unit:FindFirstChild("Humanoid") then
			local debuff = Instance.new("IntValue")
			unit:SetAttribute("Targetable",false)
			debuff.Name = "Crystallize"
			debuff.Value = 1
			debuff.Parent = unit.Debuffs
			debris:AddItem(debuff,7)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Crystal King"].Crystallize)
			local crystal = game.ServerStorage.TowerDefensePackages.Effects.Crystal:Clone()
			crystal.CFrame = unit.PrimaryPart.CFrame
			crystal.Parent = workspace.Ignore
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Crystallize:FireAllClients(crystal)
			debris:AddItem(crystal,7)
			for i=1,5 do
				wait(1)
				if unit then
					if unit:FindFirstChild("Humanoid") then
						unit.Humanoid.Health += unit.Humanoid.MaxHealth*.05
					end
				end
			end
			wait(2)
			if unit then
				if unit:FindFirstChild("Humanoid") then
					unit:SetAttribute("Targetable",true)
				end
			end
		else
			return
		end
	end
end



function module:CreateIcePortal(unit)
	while unit do
		wait(25)
		if unit:FindFirstChild("Humanoid") then
			local summonedUnit = game.ServerStorage.TowerDefensePackages.Enemies["Ice Angel"]
			local portal = game.ServerStorage.TowerDefensePackages.Effects.IceKingSummon:Clone()
			portal.CFrame = unit.HumanoidRootPart.CFrame*CFrame.new(0,3,0) *CFrame.Angles(0,math.rad(90),0)
			portal.Parent = workspace.Ignore
			debris:AddItem(portal,5)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies.Commander.Radio)
			for i=1,5 do
				wait(.5)
				local Summon = summonedUnit:Clone()
				Summon:SetPrimaryPartCFrame(portal.CFrame*CFrame.Angles(0,-math.rad(90),0))
				Summon.Location.Value = unit.Location.Value
				setPhysics(Summon,"Units")
				Summon.Parent = workspace.Ignore.Enemies
				game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(Summon.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies[Summon.Name].Idle)
				setOwnerShip(Summon)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
				Summon.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
				UnitHealth:CreateUnitHealth(Summon)
				local currentHealth = Summon.Humanoid.Health
				Summon.Humanoid.HealthChanged:Connect(function(health)
					UnitDamage:Damaged(math.abs(health),Summon,currentHealth)
				end)
				local Debuffs = Instance.new("Folder")
				Debuffs.Name = "Debuffs"
				Debuffs.Parent = Summon
				Debuffs.ChildAdded:Connect(function(child) UnitDebuffs:DebuffAdded(child,Summon)end)
				Debuffs.ChildRemoved:Connect(function(child) UnitDebuffs:DebuffRemoved(child,Summon)end)
				local basicMove = function(Summon)
					module:MoveToCoroutine(Summon)
				end
				local func = coroutine.create(basicMove)
				coroutine.resume(func,Summon)
				wait(.5)
			end
		else
			return
		end
	end
end


function module:FreezeAoe(unit)
	while unit do
		wait(18)
		if unit:FindFirstChild("Humanoid") then
			local debuff = Instance.new("IntValue")
			debuff.Name = "Crystallize"
			debuff.Value = 2
			debuff.Parent = unit.Debuffs
			debris:AddItem(debuff,2)
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Ice King"].Freeze)
			wait(1.5)
			if unit then
				if unit:FindFirstChild("HumanoidRootPart") then
					local sound = game.ServerStorage.TowerDefensePackages.Sounds.Freeze:Clone()
					sound.Parent = unit.HumanoidRootPart
					sound:Play()
					wait(.5)
					if unit then
						for i,v in pairs(workspace.Ignore.Towers:GetChildren()) do
							local dist = (v.Hitbox.Position - unit.HumanoidRootPart.Position).magnitude
							if dist <= 20 then
								local tower_Debuff = Instance.new("IntValue")
								tower_Debuff.Name = "Frozen"
								tower_Debuff.Value = 4
								tower_Debuff.Parent = v.Stats
								local frozenSound = game.ServerStorage.TowerDefensePackages.Sounds.Frozen:Clone()
								frozenSound.Parent = v.Hitbox
								frozenSound:Play()
								debris:AddItem(frozenSound,2)
							end
						end
					end
				end
			end
		else
			return
		end
	end
end

function module:FreezeRay(unit)
	while unit do
		wait(math.random(5,10))
		if unit:FindFirstChild("Humanoid") then
			if unit then
				if unit:FindFirstChild("HumanoidRootPart") then
					local unitsToFreeze = {}
					if unit then
						for i,v in pairs(workspace.Ignore.Towers:GetChildren()) do
							local dist = (v.Hitbox.Position - unit.HumanoidRootPart.Position).magnitude
							if dist <= 20 then
								table.insert(unitsToFreeze,v)
							end
						end
					end
					
					if #unitsToFreeze > 0 then
						local unitFrozen = unitsToFreeze[math.random(1,#unitsToFreeze)]

						if unitFrozen:FindFirstChild("Hitbox") then			
							local debuff = Instance.new("IntValue")
							debuff.Name = "Crystallize"
							debuff.Value = 1
							debuff.Parent = unit.Debuffs
							debris:AddItem(debuff,1)
							local sound = game.ServerStorage.TowerDefensePackages.Sounds.FreezeRay:Clone()
							sound.Parent = unit.HumanoidRootPart
							sound:Play()
							game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Animate:FireAllClients(unit.Humanoid,game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Enemies["Lab Scientist"].Shoot)
							game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Bullet:FireAllClients(unit.RightHand.Handle.Attachment,unitFrozen.Hitbox.Position,nil,"IceRay")
							unit:SetPrimaryPartCFrame(CFrame.new(unit.PrimaryPart.Position, Vector3.new(unitFrozen.PrimaryPart.Position.X,unitFrozen.PrimaryPart.Position.Y,unitFrozen.PrimaryPart.Position.Z)))
							local frozenSound = game.ServerStorage.TowerDefensePackages.Sounds.Frozen:Clone()
							frozenSound.Parent = unitFrozen.Hitbox
							frozenSound:Play()
							debris:AddItem(frozenSound,2)
							local tower_Debuff = Instance.new("IntValue")
							tower_Debuff.Name = "Frozen"
							tower_Debuff.Value = 4
							tower_Debuff.Parent = unitFrozen.Stats
						end
					end
				end
			end
		else
			return
		end
	end
end

return module
