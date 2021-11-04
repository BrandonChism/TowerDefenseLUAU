local module = {}




function module:returnClosest(tower,targets, amount)
	local closestTargets = {}

	local function createTargetsAmount(i)
		for __,unit in pairs(targets) do
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				if unit:GetAttribute("Targetable") == true then
					if closestTargets[i] then
						if (unit.HumanoidRootPart.Position-tower.Hitbox.Position).magnitude < (closestTargets[i].HumanoidRootPart.Position-tower.Hitbox.Position).magnitude then
							closestTargets[i] = unit
						end
					else
						closestTargets[i] = unit
					end
				end
			end
		end
		for __,unit in pairs(targets) do
			if unit == closestTargets[i] then
				table.remove(targets,__)
				break
			end
		end
	end
	
	for i=1,amount do
		local unit_to_remove = createTargetsAmount(i)
	end

	return closestTargets
end




function module:retrunStrongest(tower,targets,amount)
	local furthestTargets ={}
	local mostHealthTargets = {}

	local function createTargetsAmount(i)
		for __,unit in pairs(targets) do
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				if unit:GetAttribute("Targetable") == true then
					if furthestTargets[i] then
						if unit.Humanoid.MaxHealth >furthestTargets[i].Humanoid.MaxHealth then
							furthestTargets[i] = unit
						elseif unit.Humanoid.MaxHealth == furthestTargets[i].Humanoid.MaxHealth then
							local distance_To_Goal = (unit.HumanoidRootPart.Position-workspace.Ignore.Path[tostring(unit.Location.Value)].Position).magnitude
							local distance_To_Compare = (furthestTargets[i].HumanoidRootPart.Position-workspace.Ignore.Path[tostring(unit.Location.Value)].Position).magnitude
							if distance_To_Compare > distance_To_Goal then
								furthestTargets[i] = unit
							end
						end
					else
						furthestTargets[i] = unit
					end
				end
			end
		end
		for __,unit in pairs(targets) do
			if unit == furthestTargets[i] then
				table.remove(targets,__)
				break
			end
		end	
	end	

	for i=1,amount do
		createTargetsAmount(i)
	end

	return furthestTargets
end


function module:returnClosestFar(tower,targets,amount)
	local furthestTargets ={}
	
	
	local function createTargetsAmount(i)
		for __,unit in pairs(targets) do
			if unit and unit:FindFirstChild("HumanoidRootPart") then
				if unit:GetAttribute("Targetable") == true then
					if furthestTargets[i] then
						if unit.Location.Value >furthestTargets[i].Location.Value then
							furthestTargets[i] = unit
						elseif unit.Location.Value == furthestTargets[i].Location.Value then
							local distance_To_Goal = (unit.HumanoidRootPart.Position-workspace.Ignore.Path[tostring(unit.Location.Value)].Position).magnitude
							local distance_To_Compare = (furthestTargets[i].HumanoidRootPart.Position-workspace.Ignore.Path[tostring(unit.Location.Value)].Position).magnitude
							if distance_To_Compare > distance_To_Goal then
								furthestTargets[i] = unit
							end
						end
					else
						furthestTargets[i] = unit
					end
				end
			end
		end
		for __,unit in pairs(targets) do
			if unit == furthestTargets[i] then
				table.remove(targets,__)
				break
			end
		end	
	end	
	
	for i=1,amount do
		createTargetsAmount(i)
	end
	
	return furthestTargets
end





return module
