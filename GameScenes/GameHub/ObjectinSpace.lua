
function createConnection(v)
	local con
	con = v.Touched:Connect(function(hit)
		con:Disconnect()
		if hit.Parent then
			if hit.Parent:FindFirstChildWhichIsA("Humanoid") then
				if hit.Parent:FindFirstChild("HumanoidRootPart") then
					hit.Parent:SetPrimaryPartCFrame(CFrame.new(-64.246, 50.096, -450.377))
				end
			end
		end
		wait(.5)
		createConnection(script.Parent)
	end)
end

createConnection(script.Parent)