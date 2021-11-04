local player = game.Players.LocalPlayer


local loadTowers = require(script.LoadTowers)
local plyrGui = player.PlayerGui
local screenGui = plyrGui:WaitForChild("ScreenGui") or player.ScreenGui
local Inventory = screenGui:WaitForChild("Inventory") or screenGui.Inventory
local Inventory = Inventory:WaitForChild("Inventory") or Inventory.Inventory
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage = ReplicatedStorage:WaitForChild("TowerDefenseLocalPackages") or ReplicatedStorage.TowerDefenseLocalPackages
local GUIS = ReplicatedStorage:WaitForChild("Guis") or ReplicatedStorage.Guis
local towerPlacing = nil
local mouse = player:GetMouse()
local RS = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local rotation = 0
local towerSelected = nil
local EVENTS = ReplicatedStorage:WaitForChild("Events") or ReplicatedStorage.Events
local tblToIgnore
local range
local defaultTargetFilter = workspace.Ignore.InvisWalls
local bbGui = screenGui:WaitForChild("BillboardGui") or screenGui.BillboardGui
local stuff = bbGui:WaitForChild("Stuff") or bbGui.Stuff
stuff = stuff:WaitForChild("Frame") or stuff.Frame
--local pickup_Button = stuff:WaitForChild("PickupButton") or stuff.PickupButton
--local sell_Button =  stuff:WaitForChild("SellButton") or stuff.SellButton
local upgrade_Button = stuff:WaitForChild("UpgradeButton") or stuff.UpgradeButton
local targeting_Button = stuff:WaitForChild("TargetingButton") or stuff.TargetingButton
local sell_Button = stuff:WaitForChild("SellButton") or stuff.SellButton
--local stats_Button = stuff:WaitForChild("StatsButton") or stuff.StatsButton
local pInventory = player:WaitForChild("Inventory") or player.Inventory
mouse.TargetFilter = defaultTargetFilter
local mobilePlacementButtons = screenGui:WaitForChild("MobilePlacement") or screenGui.MobilePlacement
local muteMusicButton = screenGui:WaitForChild("MuteMusicButton") or screenGui.MuteMusicButton

local muted = false

muteMusicButton.MouseButton1Click:Connect(function()
	if muted then
		muteMusicButton.MusicOffButton.Visible = false
		muted = false
		game.SoundService.Music.Volume = .5
	else
		muteMusicButton.MusicOffButton.Visible = true
		muted = true
		game.SoundService.Music.Volume = 0

	end
end)

local module = {}

function module:ViewGUI(gui)
	if gui.Visible then
		gui.Visible = false
	else
		gui.Visible = true
	end
end

local function round(n)
	return math.floor(n + 0.5)
end



local towerPrices = {
	["Samurai"] = {Price = 100, multiplier = 2.5},
	["Sniper"] = {Price = 100, multiplier = 2},
	["Soldier"] = {Price = 50, multiplier = 2.5},
	["Grenadier"] = {Price = 150, multiplier = 2.2},{},
	["Jedi"] = {Price = 200, multiplier = 2.5},{},
	["Sith"] = {Price = 200, multiplier = 2.5},{},
	["Boxer"] = {Price = 50, multiplier = 3},{},
	["Cowboy"] = {Price = 75, multiplier = 2.5},{},
	["Pirate"] = {Price = 100, multiplier = 2.2},{},
	["Miner"] = {Price = 75, multiplier = 3},{},
	["Alien"] = {Price = 60, multiplier = 2},{},
	["Ninja"] = {Price = 125, multiplier = 3},{},
	["Wizard"] = {Price = 125, multiplier = 3},
	["Beam"] = {Price = 250, multiplier = 2.5},
	["Dragon Knight"] = {Price = 125, multiplier = 3},
	["Crossbow"] = {Price = 130, multiplier = 2.75},
	["Shotgunner"] = {Price = 100, multiplier = 2.4},
	["Minigunner"] = {Price = 65, multiplier = 2.4},
	["Musician"] = {Price = 125, multiplier = 2.4},

}




function fireBullet(vA, vB,tower,projectile)
	
	local bullet = game.ReplicatedStorage.TowerDefenseLocalPackages.Local[projectile]:Clone()
	local tweenPos = true
	local dist
	bullet.Parent = game.Workspace.Ignore	
	if vA:IsA("Attachment") then
		bullet.Position = vA.WorldPosition
		
	else
		tweenPos = false
		bullet.CFrame = CFrame.new(tower.PrimaryPart.Position, Vector3.new(vB.X,vB.Y,vB.Z))
		dist = (vA.Position-vB).Magnitude
	end
	if tweenPos then
		local bulletTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		local bulletTween = TS:Create(bullet, bulletTweenInfo, {Position = vB})

		bulletTween.Completed:Connect(function()
			bullet:Destroy()
		end)

		bulletTween:Play()
	else
		local bulletTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
		local bulletTween = TS:Create(bullet, bulletTweenInfo, {CFrame = bullet.CFrame*CFrame.new(0,0,-dist)})
		bulletTween.Completed:Connect(function()
			bullet:Destroy()
		end)

		bulletTween:Play()
	end
end

game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Bullet.OnClientEvent:Connect(fireBullet)

function createRangePart(tower)
	range = game.ReplicatedStorage.TowerDefenseLocalPackages.Local.Range:Clone()
	range.Transparency = .75
	range.Color = Color3.fromRGB(0,255,255)
	local rangeDist = tower.Stats:GetAttribute("AttackRange")
	range.Attachment.ParticleEmitter.Size = NumberSequence.new(rangeDist)
	range.Size = Vector3.new(0,0,0)
	TS:Create(range,TweenInfo.new(.3),{Size = Vector3.new(rangeDist*2,rangeDist*2,rangeDist*2)}):Play()
	range.CFrame = tower.Tower.HumanoidRootPart.CFrame
end

function setPosition(dt)
	towerPlacing:SetPrimaryPartCFrame(CFrame.new(round(mouse.Hit.X),mouse.Hit.Y+(towerPlacing.Hitbox.Size.Y/2),round(mouse.Hit.Z))*CFrame.Angles(0,math.rad(rotation),0))
	local min = towerPlacing.Hitbox.Position - (.5*towerPlacing.Hitbox.Size)
	local max = towerPlacing.Hitbox.Position + (.5*towerPlacing.Hitbox.Size)
	local region = Region3.new(min,max)
	local towerTouching = workspace:FindPartsInRegion3WithIgnoreList(region,tblToIgnore,5)
	if #towerTouching == 0 then
		range.Color = Color3.fromRGB(0,255,0)
	else
		range.Color = Color3.fromRGB(255, 102, 204)
	end
end
	
function rotateTower(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		rotation += 90
	end
end

function confirmPlacement(action,inputState,inputObject)
	local pos = inputObject.Position
	local min = towerPlacing.Hitbox.Position - (.5*towerPlacing.Hitbox.Size)
	local max = towerPlacing.Hitbox.Position + (.5*towerPlacing.Hitbox.Size)
	local region = Region3.new(min,max)
	local objects = plyrGui:GetGuiObjectsAtPosition(pos.X,pos.Y)
	for i,v in pairs(objects) do
		if v.Name == "TouchControlFrame" then
			table.remove(objects,i)
		end
	end
	if #objects <= 0 and range.Color == Color3.fromRGB(0,255,0) then
		game.SoundService.Place:Play()
		EVENTS.PlaceTower:FireServer(towerSelected,region,rotation)
		towerPlacing:Destroy()
		mouse.TargetFilter = defaultTargetFilter
		towerPlacing = nil
		towerSelected=nil
		for i,v in pairs(mobilePlacementButtons:GetChildren()) do
			v.Visible = false
		end
		CAS:UnbindAction("CancelPlacement")
		RS:UnbindFromRenderStep("Placement")
		CAS:UnbindAction("Rotate")
		CAS:UnbindAction("ConfirmPlacement")
	else
		local otherThanGui = 0
		for i,v in pairs(objects) do
			if v:FindFirstAncestorWhichIsA("ScreenGui") then
			else
				otherThanGui +=1
			end
		end
		if otherThanGui == 0 then
			game.SoundService.Place:Play()
			EVENTS.PlaceTower:FireServer(towerSelected,region,rotation)
			towerPlacing:Destroy()
			mouse.TargetFilter = defaultTargetFilter
			towerPlacing = nil
			towerSelected=nil
			for i,v in pairs(mobilePlacementButtons:GetChildren()) do
				v.Visible = false
			end
			CAS:UnbindAction("CancelPlacement")
			RS:UnbindFromRenderStep("Placement")
			CAS:UnbindAction("Rotate")
			CAS:UnbindAction("ConfirmPlacement")
		else
			game.SoundService.No:Play()
			for i,v in pairs(objects) do
				print(v)
			end
		end
	end
end

function unbindPlacement()
	mouse.TargetFilter = defaultTargetFilter
	RS:UnbindFromRenderStep("Placement")
	CAS:UnbindAction("Rotate")
	CAS:UnbindAction("ConfirmPlacement")
	CAS:UnbindAction("CancelPlacement")
	towerPlacing:Destroy()
	towerSelected=nil
	towerPlacing=nil
	rotation = 0
end


local dragging = true
local dragInput = nil


local cancelPlacementButton = mobilePlacementButtons:WaitForChild("CancelPlacement") or mobilePlacementButtons.CancelPlacement
local confirmPlacementButton = mobilePlacementButtons:WaitForChild("ConfirmPlacement") or mobilePlacementButtons.ConfirmPlacement
local RotatePlacementButton = mobilePlacementButtons:WaitForChild("RotatePlacement") or mobilePlacementButtons.RotatePlacement


cancelPlacementButton.MouseButton1Click:Connect(function()
	
	RS:UnbindFromRenderStep("Placement")
	CAS:UnbindAction("Rotate")
	CAS:UnbindAction("ConfirmPlacement")
	CAS:UnbindAction("CancelPlacement")
	
	
	if range then range:Destroy() end
	mouse.TargetFilter = defaultTargetFilter
	if towerPlacing then
		towerPlacing:Destroy()
	end
	towerSelected=nil
	towerPlacing=nil
	rotation = 0
	for i,v in pairs(mobilePlacementButtons:GetChildren()) do
		v.Visible = false
	end
end)

confirmPlacementButton.MouseButton1Click:Connect(function()
	print(towerPlacing)
	if towerPlacing then
		local pos = towerPlacing.PrimaryPart.Position
		local min = towerPlacing.Hitbox.Position - (.5*towerPlacing.Hitbox.Size)
		local max = towerPlacing.Hitbox.Position + (.5*towerPlacing.Hitbox.Size)
		local region = Region3.new(min,max)
		local objects = plyrGui:GetGuiObjectsAtPosition(pos.X,pos.Y)
		for i,v in pairs(objects) do
			if v.Name == "TouchControlFrame" then
				table.remove(objects,i)
			end
		end
		game.SoundService.Place:Play()
		print(#objects.. " this many objects")
		print(range.Color)
		if #objects <= 0 and range.Color == Color3.fromRGB(0,255,0) then
			game.SoundService.Place:Play()
			EVENTS.PlaceTower:FireServer(towerSelected,region,rotation)
			towerPlacing:Destroy()
			mouse.TargetFilter = defaultTargetFilter
			towerPlacing = nil
			towerSelected=nil
			for i,v in pairs(mobilePlacementButtons:GetChildren()) do
				v.Visible = false
			end
		else
			local otherThanGui = 0
			for i,v in pairs(objects) do
				if v:FindFirstAncestorWhichIsA("ScreenGui") then
				else
					otherThanGui +=1
				end
			end
			if otherThanGui == 0 then
				game.SoundService.Place:Play()
				EVENTS.PlaceTower:FireServer(towerSelected,region,rotation)
				towerPlacing:Destroy()
				mouse.TargetFilter = defaultTargetFilter
				towerPlacing = nil
				towerSelected=nil
				for i,v in pairs(mobilePlacementButtons:GetChildren()) do
					v.Visible = false
				end
				CAS:UnbindAction("CancelPlacement")
				RS:UnbindFromRenderStep("Placement")
				CAS:UnbindAction("Rotate")
				CAS:UnbindAction("ConfirmPlacement")
			else
				game.SoundService.No:Play()
				for i,v in pairs(objects) do
					print(v)
				end
			end
		end
	end
end)

RotatePlacementButton.MouseButton1Click:Connect(function()
	rotateTower(nil,Enum.UserInputState.Begin)
end)


UIS.TouchStarted:Connect(function(input,gp)
	if not dragging then
		dragInput = input
		if towerPlacing then
			dragging = true
		end
	end
end)

UIS.TouchMoved:Connect(function(input, gameProcessed)
	if input == dragInput and dragging and towerPlacing and not gameProcessed then
		setPosition()
	end
end)

UIS.TouchEnded:Connect(function()
	if towerPlacing and dragging then
		dragging = false
	end
end)

UIS.TouchTap:Connect(function(touchpos,gameproccessed)
	
	local guisAtPosition = plyrGui:GetGuiObjectsAtPosition(touchpos[1].X, touchpos[1].Y)
	
	local canPlace = true
	
	for i,v in pairs(guisAtPosition) do
		if v:FindFirstAncestorOfClass("ScreenGui") then
			if v.Name == "ScreenGui" then
				canPlace = false
			end
		end
	end
	
	if towerPlacing and canPlace and not gameproccessed then
		setPosition()
	end
end)

function setPlacement(child)
	
	
	local userInputService = game:GetService("UserInputService")

	if userInputService.TouchEnabled then
		if towerPlacing then
			mouse.TargetFilter = defaultTargetFilter
			towerPlacing:Destroy()
			towerSelected=nil
			towerPlacing=nil
			rotation = 0
			for i,v in pairs(mobilePlacementButtons:GetChildren()) do
				v.Visible = false
			end
		else
			if range then range:Destroy() end
			mouse.TargetFilter = workspace.Ignore
			bbGui.Enabled = false
			towerPlacing = pInventory[child.Name]:Clone()
			towerPlacing.Parent = workspace.Ignore
			towerSelected = pInventory[child.Name]
			tblToIgnore = towerPlacing.Tower:GetChildren()
			createRangePart(towerPlacing)
			range.Parent = towerPlacing
			table.insert(tblToIgnore,range)
			table.insert(tblToIgnore,towerPlacing.Hitbox)
			for i,v in pairs(workspace.Placement:GetChildren()) do
				table.insert(tblToIgnore,v)
			end
			for i,v in pairs(game.Players:GetChildren()) do
				for i,v in pairs(v.Character:GetDescendants()) do
					if v:IsA("MeshPart") or v:IsA("BasePart") then
						table.insert(tblToIgnore,v)
					end
				end
			end
			for i,v in pairs(mobilePlacementButtons:GetChildren()) do
				v.Visible = true
			end
		end
	else
		if towerPlacing then
			mouse.TargetFilter = defaultTargetFilter
			RS:UnbindFromRenderStep("Placement")
			CAS:UnbindAction("Rotate")
			CAS:UnbindAction("ConfirmPlacement")
			CAS:UnbindAction("CancelPlacement")
			towerPlacing:Destroy()
			towerSelected=nil
			towerPlacing=nil
			rotation = 0
		else
			if range then range:Destroy() end
			bbGui.Enabled = false
			towerPlacing = pInventory[child.Name]:Clone()
			towerPlacing.Parent = workspace.Ignore
			towerSelected = pInventory[child.Name]
			tblToIgnore = towerPlacing.Tower:GetChildren()
			createRangePart(towerPlacing)
			range.Parent = towerPlacing
			table.insert(tblToIgnore,range)
			table.insert(tblToIgnore,towerPlacing.Hitbox)
			for i,v in pairs(workspace.Placement:GetChildren()) do
				table.insert(tblToIgnore,v)
			end
			for i,v in pairs(game.Players:GetChildren()) do
				for i,v in pairs(v.Character:GetDescendants()) do
					if v:IsA("MeshPart") or v:IsA("BasePart") then
						table.insert(tblToIgnore,v)
					end
				end
			end
			mouse.TargetFilter = workspace.Ignore
			RS:BindToRenderStep("Placement",1,setPosition)
			CAS:BindAction("CancelPlacement",unbindPlacement,false,Enum.KeyCode.Q)
			CAS:BindAction("ConfirmPlacement",confirmPlacement,false,Enum.UserInputType.MouseButton1)
			CAS:BindAction("Rotate",rotateTower,false,Enum.KeyCode.R)
		end
	end
end

--[[
pickup_Button.MouseButton1Click:Connect(function()
	if range then range:Destroy() end
	bbGui.Enabled = false
	EVENTS.Pickup:FireServer(bbGui.Adornee.Parent)
end)
]]

upgrade_Button.MouseButton1Click:Connect(function()
	if range then range:Destroy() end
	bbGui.Enabled = false
	EVENTS.Upgrade:FireServer(bbGui.Adornee.Parent)
end)

game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Upgraded.OnClientEvent:Connect(function()
	game.SoundService.UpgradeUnit:Play()
end)

sell_Button.MouseButton1Click:Connect(function()
	if range then range:Destroy() end
	sell_Button.Sound:Play()
	bbGui.Enabled = false
	EVENTS.Sell:FireServer(bbGui.Adornee.Parent)
	game.SoundService.PickUp:Play()
end)


targeting_Button.MouseButton1Click:Connect(function()
	if range then range:Destroy() end
	bbGui.Enabled = false
	EVENTS.Targeting:FireServer(bbGui.Adornee.Parent)
end)


function createViewport(gui,which)


	local towerDisplay = game.ReplicatedStorage.TowerDefenseLocalPackages.Viewport[which.Name]:Clone()
	towerDisplay.Parent = gui.ViewportFrame



	local viewCamera = Instance.new("Camera")
	gui.ViewportFrame.CurrentCamera = viewCamera
	viewCamera.Parent = gui.ViewportFrame
	towerDisplay.Tower:SetPrimaryPartCFrame(CFrame.new(0,0,0)*CFrame.Angles(math.rad(0),math.rad(200),math.rad(0)))

	viewCamera.CFrame = CFrame.new(Vector3.new(0,0,2),towerDisplay.Tower.PrimaryPart.Position)

	local anim = towerDisplay.Tower.Humanoid:LoadAnimation(game.ReplicatedStorage.TowerDefenseLocalPackages.Animations.Towers[which.Name].Idle)
	anim:Play()

	viewCamera.CFrame = viewCamera.CFrame*CFrame.Angles(math.rad(-20),0,math.rad(0))
	viewCamera.CFrame = viewCamera.CFrame+Vector3.new(0,.5,0)
end



function module:InventoryUpdated(inventory,tower)
	local gui = loadTowers:CreateTowerIcon(tower.Name)
	gui.Name = tower.Name
	gui.Parent = Inventory
	createViewport(gui,tower)
	gui.TextButton.MouseButton1Click:Connect(function()
		if player.Stats:GetAttribute("UnitsPlaced") <  40/#game.Players:GetChildren() and #game.Workspace.Ignore.Towers:GetChildren() < 40  and player.leaderstats.Gold.Value >= tonumber(string.sub(gui.Price.Text,2,string.len(gui.Price.Text))) then
			if towerPlacing then
				for i,v in pairs(mobilePlacementButtons:GetChildren()) do
					v.Visible = false
				end
				unbindPlacement()
			else
				setPlacement(gui)
			end
		else
			game.SoundService.No:Play()
		end
	end)
end




function module:Tween(what,cframe,eta)
	if what:IsA("Model") then
		TS:Create(what.PrimaryPart,TweenInfo.new(eta),{CFrame = cframe}):Play()
	else
		TS:Create(what,TweenInfo.new(eta),{CFrame = cframe}):Play()
	end
end


function ViewEnemy(enemy)
	print(enemy)
end

function upgradeCost(level)
	return level*500
end

function setStats(tower)
	bbGui.Stuff.Frame.Stats.Range.Text = tower.Stats:GetAttribute("AttackRange")
	bbGui.Stuff.Frame.TowerName.Text = tower.Name
	bbGui.Stuff.Frame.TargetingButton.Text = "Attacking: "..tower.Stats:GetAttribute("Targeting")
	screenGui.BillboardGui.Stuff.Frame.Stats.Damage.Text = tower.Stats:GetAttribute("Damage")
	screenGui.BillboardGui.Stuff.Frame.Stats.Speed.Text = tower.Stats:GetAttribute("AttackSpeed")
	if tower.Stats:GetAttribute("Stars") < 5 then
		screenGui.BillboardGui.Stuff.Frame.UpgradeCost.TextLabel.Text = "$"..math.floor(towerPrices[tower.Name].Price*towerPrices[tower.Name].multiplier*tower.Stats:GetAttribute("Stars"))
	else
		screenGui.BillboardGui.Stuff.Frame.UpgradeCost.TextLabel.Text = "Max Level"
	end
end

function viewTower(tower)
	if range then range:Destroy() end
	setStats(tower)
	createRangePart(tower)
	range.Parent = workspace.Ignore
	screenGui.BillboardGui.Enabled = true
	screenGui.BillboardGui.Adornee = tower.Hitbox
end

function module:MouseClick(target)
	
	if range and not towerPlacing then range:Destroy() end
	
	bbGui.Enabled = false
	
	if target and target.Parent then
		if target:FindFirstAncestorOfClass("Model") then
			local target_P = target:FindFirstAncestorOfClass("Model") 
			if target_P.Parent then
				if target_P.Parent == workspace.Ignore.Enemies then
					ViewEnemy(target_P) return
				elseif target_P:FindFirstChild("Stats") then
					if target_P.Stats:GetAttribute("Player") == player.Name and target_P.Parent == workspace.Ignore.Towers then
						viewTower(target_P) return
					end
				end
			end
		end
	end
end




return module
