
local TeleportService = game:GetService("TeleportService")

local dataModule = require(script.Parent.UpdatePlayer)

local MPS = game:GetService("MarketplaceService")

local Maps = {
	["Normal"] = {
		7106352570, --Crystal City
		7106356528, --Nuclear
		7106368062, -- Classic
		7106362329, -- Tundra
	},
	["Medium"] = {
		7106356528, --Nuclear
		7106368062, -- Classic
		7106362329, -- Tundra

	},
	["Hard"] = {
		7106356528, --Nuclear
		7106368062, -- Classic
		7106362329, -- Tundra

	},
	["Event"] = {
		7106356528, --Nuclear
		7106368062, -- Classic
		7106362329, -- Tundra

	},
	["Endless"] = {
		7106356528, --Nuclear
		7106368062, -- Classic
		7106362329, -- Tundra

	}
}

local lobbies = {
	
}

local mapImages = {
	["Tundra"] = 7078225555,
	["Nuclear Facility"] = 7042610587,
	["Crystal City"] = 7073487108,
	["Classic"] = 7074946231,
}


function clearLobbyList(lobby)
	lobby.Elevator.SurfaceGui.TextLabel.Text = ""
	lobby.Players = {}
	lobby.Starting = false
end


function touchedDoor(door,hit)
	local character = hit:FindFirstAncestorWhichIsA("Model")
	local plyr = game.Players:GetPlayerFromCharacter(character)
	if plyr then
		if door:GetAttribute("Level") then
			local plyrData = dataModule:RetrivePlayerData(plyr)
			if plyrData.Level >= door:GetAttribute("Level") then
				else return
			end
		end
		for i,v in pairs(lobbies) do
			if table.find(v.Players,plyr) then
				print('is in lobby already')
				table.remove(v.Players,table.find(v.Players,plyr))
				game.ReplicatedStorage.Events.JoinLobby:FireClient(plyr)
				character:SetPrimaryPartCFrame(CFrame.new(door["Exit Elevator"].WorldPosition))
				return
			end
		end
		
		for i,v in pairs(lobbies) do
			print(#v.Players)
			if v.Elevator == door and #v.Players < 4 then
				game.ReplicatedStorage.Events.JoinLobby:FireClient(plyr,door)
				character:SetPrimaryPartCFrame(CFrame.new(door["EnterElevator"].WorldPosition))
				table.insert(v.Players,plyr)
				if not v.Starting then v.Starting = true

					coroutine.wrap(function(lobby)
						for i=6,0,-1 do
							door.SurfaceGui.TextLabel.Text = "Game starting in "..i..".."
							wait(1)

							if #lobby.Players >0 then
								
							else
								clearLobbyList(lobby)
								return
							end
						end
						
						local dataToPass = {
							
						}

						for i,v in pairs(lobby.Players) do
							dataToPass[v.UserId] = dataModule:RetrivePlayerData(v)
						end
						
						print(dataToPass)
						
						local code 
						
						
						local success,result = pcall(function()
							code = TeleportService:ReserveServer(lobby.Map)
						end)


						if success then
							for i,v in pairs(lobby.Players) do
								game.ReplicatedStorage.Events.Loading:FireClient(v)
							end
						else
							print('could not set a private server')
							warn(result)
							for __,plyr in pairs(lobby.Players) do
								if plyr.Character then
									game.ReplicatedStorage.Events.JoinLobby:FireClient(plyr)
									plyr.Character:SetPrimaryPartCFrame(CFrame.new(lobby.Elevator["Exit Elevator"].WorldPosition))
								end
							end
							clearLobbyList(lobby)
						end					
						

						
						local success, result = pcall(function()
							TeleportService:TeleportToPrivateServer(lobby.Map,code,lobby.Players,nil,dataToPass)
						end)


						if success then
							
						else
							for __,plyr in pairs(lobby.Players) do
								game.ReplicatedStorage.Events.Loading:FireClient(plyr)
								if plyr.Character then
									plyr.Character:SetPrimaryPartCFrame(CFrame.new(lobby.Elevator["Exit Elevator"].WorldPosition))
								end
							end
							print('couldnt teleport')
							warn(result)
						end
						
						clearLobbyList(lobby)
						return
					end)(v)
					return
				end
				return
			end
		end
	end
end




function createConnection(v)
	local con
	con = v.Touched:Connect(function(hit)
		con:Disconnect()
		touchedDoor(v,hit)
		wait(.5)
		createConnection(v)
	end)
end



spawn(function()
	while true do
		wait(30)
		for i,v in pairs(lobbies) do
			wait(5)
			if v.Starting == false then
				local selected_Map = Maps[v.Elevator:GetAttribute("Type")][math.random(1,#Maps[v.Elevator:GetAttribute("Type")])]
				v.Map = selected_Map
				
				local mapName = MPS:GetProductInfo(selected_Map).Name
				v.Elevator.MapInfo.SurfaceGui.TextLabel.Text = mapName
				if mapImages[mapName] then
					v.Elevator.MapInfo.SurfaceGui.ImageLabel.Image = "rbxassetid://"..mapImages[mapName]
				else
					v.Elevator.MapInfo.SurfaceGui.ImageLabel.Image = ""

				end
			end
		end
	end
end)
	
local module = {}


function module:PlayerLeftCheckElevators(plyr)
	for i,v in pairs(lobbies) do
		if v.Players:FindFirstChild(plyr) then
			print('foudn player in elevator... removing')
		end
	end
end

local mapNames = {
	[7106352570] = "Crystal City",
	[7106356528] = "Nuclear Facility",
	[7106368062] = "Classic",
	[7106362329] = "Tundra",
}

function module:SetTouchEvent()
	
	
	for i,v in pairs(workspace.Elevators:GetChildren()) do
		wait()
		v.Name = i
		local selected_Map = Maps[v:GetAttribute("Type")][math.random(1,#Maps[v:GetAttribute("Type")])]
		local mapName = mapNames[selected_Map]
		v.MapInfo.SurfaceGui.TextLabel.Text = mapName
		v.SurfaceGui.TextLabel.Text = ""
		if mapImages[mapName] then
			v.MapInfo.SurfaceGui.ImageLabel.Image = "rbxassetid://"..mapImages[mapName]
		end
		table.insert(
			lobbies,
			
			i,
			
			{
				
				Elevator = v,
				Players = {},
				Starting = false,
				Map = selected_Map,
			}
		)
		createConnection(v)
	end
	
	print(lobbies)
	
end

return module

