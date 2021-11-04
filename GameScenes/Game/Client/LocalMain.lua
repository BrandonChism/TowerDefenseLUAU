

---Services

local CAS = game:GetService("ContextActionService")
local Replicated_Storage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local EVENTS = Replicated_Storage.TowerDefenseLocalPackages.Events

local playerModule = require(script.ModuleScript)
local GUIModule = require(script.GUIModule)



---Variables

local player = game.Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats") or player.leaderstats
local gold = leaderstats:WaitForChild("Gold") or leaderstats.Gold
local plyrGui = player.PlayerGui
local screenGui = plyrGui.ScreenGui or plyrGui:WaitForChild("ScreenGui")
local inventory = player:WaitForChild("Inventory") or player.Inventory
local gameStats = Replicated_Storage.TowerDefenseLocalPackages:WaitForChild("Stats") or Replicated_Storage.TowerDefenseLocalPackages.gameStats
local mouse = player:GetMouse()
local inventoryGui = screenGui:WaitForChild("Inventory") or screenGui.Inventory
inventoryGui = inventoryGui:WaitForChild("Inventory") or inventoryGui.Inventory
local ignore = workspace:WaitForChild("Ignore") or workspace.Ignore
local Enemies = ignore:WaitForChild("Enemies") or ignore.Enemies
local spawns = ignore:WaitForChild("Spawns") or ignore.Spawns
local gameModeVote = screenGui:WaitForChild("GameModeVote") or screenGui.GameModeVote
local gameModeVoteFrame = gameModeVote:WaitForChild("Frame") or gameModeVote.Frame

gameModeVote.Visible = true
---RemoteEventVariables

local PurchaseEvent = EVENTS.Purchase
local RoundBegin = EVENTS.RoundBegin
local RoundOver = EVENTS.RoundOver
local Tween = EVENTS.Tween
local Animate = EVENTS.Animate

---events

local curRound = 0
RoundBegin.OnClientEvent:Connect(function(round,timer)
	curRound = round
	screenGui.Round.Text = "Wave: "..round
	local est=0
	local timerToTrack = tonumber(timer)
	coroutine.wrap(function() 
		while curRound == round and est~= timerToTrack do 
			est+=1
			screenGui.Timer.Text = "Next wave in.."..tostring(timerToTrack-est)
			wait(1)
		end 
		if est==timerToTrack then
			screenGui.Timer.Text = "Wave completed.."
		end
		return
	end)()
end)

game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Music.OnClientEvent:Connect(function(which)
	if which == "Boss" then
		game.SoundService.Music:Stop()
		game.SoundService.Boss:Play()
	else
		game.SoundService.Music:Play()
		game.SoundService.Boss:Stop()
	end
end)

RoundOver.OnClientEvent:Connect(function(timer)
	curRound = -1
	local timerToTrack = tonumber(timer)
	local est = 0
	coroutine.wrap(function() 
		while curRound == -1 and est~= timerToTrack do 
			wait(1)
			est+=1
			screenGui.Timer.Text = "Next wave will begin in.."..tostring(timerToTrack-est)
		end 
		if est==timerToTrack then
			screenGui.Timer.Text = "Next wave beginning..."
		end
		return
	end)()
end)

function setTowerStats(tower)
	
end

Tween.OnClientEvent:Connect(function(what,cframe,eta)
	playerModule:Tween(what,cframe,eta)
end)

EVENTS.LocalTower.OnClientEvent:Connect(function(tower)
	local towerViewer = game.ReplicatedStorage.TowerDefenseLocalPackages.Local.LocalTower:Clone()
	towerViewer.CFrame = (tower.Hitbox.CFrame-Vector3.new(0,tower.Hitbox.Size.Y/2,0))
	towerViewer.Parent = tower
end)

Animate.OnClientEvent:Connect(function(hum,anim)
	hum:LoadAnimation(anim):Play()
end)


EVENTS.Immune.OnClientEvent:Connect(function(unit,howlong)
	local immuneGui = game.ReplicatedStorage.TowerDefenseLocalPackages.Guis.ImmuneGui:Clone()
	immuneGui.Adornee = unit.Head
	immuneGui.Parent = unit.Head
	local immuneTween = TS:Create(immuneGui.EnemyName,TweenInfo.new(.5,Enum.EasingStyle.Bounce,Enum.EasingDirection.In,0,true),{Position = UDim2.new(0,0,0,0)})
	immuneTween.Completed:Connect(function()
		immuneTween:Play()
	end)
	immuneTween:Play()
	wait(howlong)
	immuneGui:Destroy()
end)


EVENTS.Crystallize.OnClientEvent:Connect(function(crystal)
	local dest = crystal.CFrame* CFrame.new(0,0,-.5)
	crystal.CFrame = crystal.CFrame* CFrame.new(0,-3,-.5)
	wait(1)
	local immuneGui = game.ReplicatedStorage.TowerDefenseLocalPackages.Guis.ImmuneGui:Clone()
	immuneGui.Adornee = crystal
	immuneGui.Parent = crystal
	local immuneTween = TS:Create(immuneGui.EnemyName,TweenInfo.new(.5,Enum.EasingStyle.Bounce,Enum.EasingDirection.In,0,true),{Position = UDim2.new(0,0,0,0)})
	immuneTween.Completed:Connect(function()
		immuneTween:Play()
	end)
	immuneTween:Play()
	TS:Create(crystal,TweenInfo.new(.7,Enum.EasingStyle.Linear),{CFrame = dest}):Play()
	TS:Create(crystal,TweenInfo.new(.7,Enum.EasingStyle.Linear),{Size = Vector3.new(4.407, 8.053, 1.844)}):Play()
end)

game.Workspace.Ignore.Enemies.ChildAdded:Connect(function(Enemy_Unit)
	Enemy_Unit:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
		Enemy_Unit.Head.EnemyDisplay.TextLabel.Text = Enemy_Unit.Humanoid.Health
		TS:Create(Enemy_Unit.Head.EnemyDisplay.Frame.Frame,TweenInfo.new(.3,Enum.EasingStyle.Linear),{Size = UDim2.new(Enemy_Unit.Humanoid.Health/Enemy_Unit.Humanoid.MaxHealth,0,1,0)}):Play()
	end)
end)

--functions 

inventory.ChildAdded:Connect(function(child)
	playerModule:InventoryUpdated(inventoryGui, child)
end)

mouse.Button1Down:Connect(function()
	playerModule:MouseClick(mouse.Target)
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		playerModule:MouseClick(mouse.Target)
	end
end)

gameStats:GetAttributeChangedSignal("Health"):Connect(GUIModule.UpdateHealth)

for i,v in pairs(inventory:GetChildren()) do
	playerModule:InventoryUpdated(inventoryGui,v)
end

screenGui.GameOver.LobbyButton.MouseButton1Click:Connect(function()
	EVENTS.Teleport:FireServer()
end)


screenGui.ReturnToLobby.MouseButton1Click:Connect(function()
	EVENTS.Teleport:FireServer()
end)

screenGui.GameOver.TextButton.MouseButton1Click:Connect(function()
	screenGui.GameOver.Visible = false
	local camera = game.Workspace.Camera
	camera.CameraType = Enum.CameraType.Custom
	screenGui.ReturnToLobby.Visible = true
end)

local mapColor = {
	["Crystal City"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,255)),
	},
	["Tundra"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255)),
	},
	["Classic"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255,155,0)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,155,0)),
	},
	["Nuclear Facility"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,0)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,155,0)),
	},
}


local function toHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end


EVENTS.GameOver.OnClientEvent:Connect(function(exp,cash,startTime,round,place)
	local camera = game.Workspace.Camera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = workspace.Ignore.Camera.Start.CFrame
	local CameraCFrame = TS:Create(camera,TweenInfo.new(3,Enum.EasingStyle.Linear),{CFrame = workspace.Ignore.Camera.End.CFrame})
	CameraCFrame:Play()
	wait(3)
	local tweenPlay = TS:Create(screenGui.GameOver,TweenInfo.new(.5,Enum.EasingStyle.Bounce),{Position = UDim2.new(0.3, 0,0.3,0)})
	screenGui.GameOver.Position = UDim2.new(.3,0,1.5,0)
	screenGui.GameOver.Map.Text = place
	screenGui.GameOver.Map.UIGradient.Color = mapColor[place]
	screenGui.GameOver.Time.Text = "Time: "..toHMS(os.time()-startTime)
	screenGui.GameOver.Waves.Text = "Waves Survived: "..tostring(round)
	screenGui.GameOver.Experience.Text = "+"..exp.." Experience!"
	screenGui.GameOver.Cash.Text = "+$"..cash.." Cash!"
	screenGui.GameOver.Visible = true
	
	tweenPlay:Play()
end)

screenGui.Cash.Text = "$"..gold.Value

gold.Changed:Connect(function()
	
	local updatedGold = gold.Value- tonumber(string.sub(screenGui.Cash.Text,2,string.len(screenGui.Cash.Text)))
	local cashClone = screenGui.Cash:Clone()
	
	local cashUPdateTween
	
	if updatedGold > 0 then
		cashClone.Text = "+$"..updatedGold
		cashClone.TextColor3 = Color3.fromRGB(0,255,0)
		cashUPdateTween = TS:Create(cashClone,TweenInfo.new(.5,Enum.EasingStyle.Linear),{Position = cashClone.Position-UDim2.new(0,0,.1,0)})
	else
		cashClone.Text = "-$"..updatedGold
		cashClone.TextColor3 = Color3.fromRGB(255,0,0)
		cashUPdateTween = TS:Create(cashClone,TweenInfo.new(.5,Enum.EasingStyle.Linear),{Position = cashClone.Position+UDim2.new(0,0,.1,0)})
	end
	
	cashClone.ZIndex = -1
	
	cashUPdateTween.Completed:Connect(function()
		cashClone:Destroy()
	end)
	screenGui.Cash.Text = "$"..gold.Value
	cashClone.Parent = screenGui
	cashUPdateTween:Play()
end)


for i,v in pairs(spawns:GetChildren()) do
	v.ChildAdded:Connect(function(child)
		local textLabel = child:WaitForChild("TextLabel") or child.TextLabel
		local tween1 = TS:Create(child.TextLabel,TweenInfo.new(.3,Enum.EasingStyle.Exponential,Enum.EasingDirection.In,0,true),{Position = child.TextLabel.Position+UDim2.new(0,0,-.1,0)})
		
		local tween2 = TS:Create(child.TextLabel,TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,true),{TextColor3 = Color3.fromRGB(255,0,0)})

		tween2.Completed:Connect(function()
			tween2:Play()
		end)
		
		tween1.Completed:Connect(function()
			tween1:Play()
		end)
		
		tween2:Play()
		tween1:Play()
	end)
end

for i,v in pairs(gameModeVoteFrame:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Vote:FireServer(v.Name)
			gameModeVote.Visible = false
		end)
	end
end

game.ReplicatedStorage.TowerDefenseLocalPackages.Events.Vote.OnClientEvent:Connect(function(gamemode)
	screenGui.Gamemode.Text = gamemode
	gameModeVote:Destroy()
end)