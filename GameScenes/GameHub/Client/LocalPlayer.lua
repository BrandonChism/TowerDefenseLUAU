
local player = game.Players.LocalPlayer

local shopModule = require(script.ShopModule)

local camera = workspace.Camera

local player = game.Players.LocalPlayer
local PG = player.PlayerGui
local TS = game:GetService("TweenService")



local sidebar = PG:WaitForChild("Sidebar") or PG.Sidebar
local shop = PG:WaitForChild("Shop")
local options = PG:WaitForChild("Settings")
local profile = PG:WaitForChild("Profile")


local shopFrame = shop.shopFrame
local settingsFrame = options.settingsFrame
local emoteBar = sidebar:WaitForChild("EmoteBar") or sidebar.EmoteBar


local buttons = {["shopBtn"] = shopFrame, ["settingsBtn"] = settingsFrame,["EmoteButton"] = emoteBar, ["ProfileButton"] = profile.Frame}

local settingsCogTI = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local settingsCogTurn = TS:Create(sidebar.settingsBtn.inset.btnIcon, settingsCogTI, {Rotation = 45})
local settingsCogReturn = TS:Create(sidebar.settingsBtn.inset.btnIcon, settingsCogTI, {Rotation = 0})

local summonGui = player.PlayerGui:WaitForChild("Summons") or player.PlayerGui.Summons

local summonFrame = summonGui:WaitForChild("Frame") or summonGui.Frame
local click = game:GetService("SoundService"):WaitForChild("Click") or game:GetService("SoundService").Click

local hour = nil

local function toHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end



local crateImages=  {
	[""] = 0,
	["Troll Mask"] = 7112510682,
	["Enchanted Sword"] = 0,
	["Zeus Cloud"] = 7112482064,
	["Midas' Glove"] = 7112356062,
	["Frozen Heart"] = 7112342695,
	["Star Watch"] = 7112323522,
	["Shooting Star"] = 7149586892,
	["Cursed Artifact"] = 7149556465,
	["Bandage"] = 7154534939,
}

if summonFrame["1"]:GetAttribute("Summon") ~= "" then
	wait()
	local txtLabel = summonGui:WaitForChild("TextLabel") or summonGui.TexLabel
	local daypass = tonumber(txtLabel.Text) % 3600 
	local timeleft = 3600 - daypass
	hour = timeleft
	
	for i,v in pairs(summonFrame:GetChildren()) do
		if v:IsA("ImageLabel") then
			print(summonFrame[v.Name],"yo")
			print(crateImages[summonFrame[v.Name]:GetAttribute("Summon")])
			summonFrame[v.Name].Image = "rbxassetid://".. crateImages[summonFrame[v.Name]:GetAttribute("Summon")]
			shop.DailyCrate.Frame[v.Name].Summon.Image = "rbxassetid://".. crateImages[summonFrame[v.Name]:GetAttribute("Summon")]
			shop.DailyCrate.Frame[v.Name].TextLabel.Text = v.TextLabel.Text
			shop.DailyCrate.Frame[v.Name].TextLabel.TextColor3 = v.TextLabel.TextColor3
			coroutine.wrap(function()
				local hourBefore = hour
				local count = 0
				local txtLabel = summonGui:WaitForChild("TextLabel") or summonGui.TextLabel
				while hourBefore == hour do
					txtLabel.Text = "Shop reset: ".. toHMS(hour-count)
					count-=-1
					wait(1)
				end
			end)()
		end
	end
else
	print(summonFrame["1"]:GetAttribute("Summon"))
end









game.ReplicatedStorage.Events.SummonEvent.OnClientEvent:Connect(function(hourlyPets,hour)
	
	
	hour = hour
	for i,v in pairs(hourlyPets) do
		
		
		
		
		summonFrame[i].Image = "http://www.roblox.com/asset/?id=".. tostring(crateImages[hourlyPets[i].PetInfo.Name])
		
		if string.sub(hourlyPets[i].Rarity,1,1) == "0" and string.sub(hourlyPets[i].Rarity,2,2) == "." and string.sub(hourlyPets[i].Rarity,3,3) == "0" and string.sub(hourlyPets[i].Rarity,4,4) == "0" then
			summonFrame[i].TextLabel.Text = "0.01%"
		else
			summonFrame[i].TextLabel.Text = string.sub(hourlyPets[i].Rarity,1,4).."%"
		end
		summonFrame[i].TextLabel.TextColor3 = hourlyPets[i].PetInfo.Color
		
		
		shop.DailyCrate.Frame[tostring(i)].Summon.Image = summonFrame[i].Image
		shop.DailyCrate.Frame[tostring(i)].TextLabel.Text = summonFrame[i].TextLabel.Text
		shop.DailyCrate.Frame[tostring(i)].TextLabel.TextColor3 = summonFrame[i].TextLabel.TextColor3

	end
	
	
	coroutine.wrap(function()
		local hourBefore = hour
		local count = 0
		local txtLabel = summonGui:WaitForChild("TextLabel") or summonGui.TextLabel
		while hourBefore == hour do
			txtLabel.Text = "Shop reset: ".. toHMS(hour-count)
			count-=-1
			wait(1)
		end
	end)()
	
end)


for i, v in pairs(buttons) do
	local button = sidebar[i]
	local btnFrame = v

	--Button Hover
	local savedColor = nil
	button.Input.MouseEnter:Connect(function()
		savedColor = button.inset.btnIcon.ImageColor3
		button.inset.btnIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		button.inset.UIStroke.Color = Color3.fromRGB(255, 255, 255)
	end)

	button.Input.MouseLeave:Connect(function()
		if savedColor then
			button.inset.btnIcon.ImageColor3 = savedColor
			button.inset.UIStroke.Color = savedColor
		end
	end)

	local originalFramePos = v.Position
	button.Input.MouseButton1Click:Connect(function(input, gp)
		click:Play()
		if i == "ProfileButton" and not v.Visible then
			game.ReplicatedStorage.Events.ProfileData:FireServer(player)
		end
		
		btnFrame.Visible = not btnFrame.Visible

		if i == "settingsBtn" then
			if btnFrame.Visible == true then
				settingsCogTurn:Play()
			else
				settingsCogReturn:Play()
			end
		end

		--Loop through to close other open frames
		for x, q in pairs(buttons) do
			if q ~= v then
				q.Visible = false
				--q.Position = originalFramePos
			end
		end

		--UI Frame on open
		if btnFrame.Visible == true then	
			btnFrame.Position = originalFramePos + UDim2.fromScale(0, 0.072)

			local btnFrameTI = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
			local btnFrameTween = TS:Create(btnFrame, btnFrameTI, {Position = UDim2.fromScale(btnFrame.Position.X.Scale, btnFrame.Position.Y.Scale - 0.072)})

			btnFrameTween:Play()
		else
			btnFrame.Position = originalFramePos
		end
	end)

	--Button Press Down Anim
	local savedPos = nil
	button.Input.MouseButton1Down:Connect(function()
		click:Play()
		if savedPos then button.Position = savedPos end

		savedPos = button.Position
		button.Position = UDim2.fromScale(button.Position.X.Scale, button.Position.Y.Scale + 0.008)
	end)

	button.Input.MouseButton1Up:Connect(function()
		if savedPos then
			button.Position = savedPos
		end
	end)
end



game.ReplicatedStorage.Events.JoinLobby.OnClientEvent:Connect(function(lobby)
	if lobby then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = lobby.CFrame * CFrame.new(0,0,8)
	else
		camera.CameraType = Enum.CameraType.Custom
	end
end)


