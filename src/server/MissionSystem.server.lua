local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MissionData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MissionData"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))
local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")

local claimMission = Instance.new("RemoteEvent")
claimMission.Name = "ClaimMission"
claimMission.Parent = ReplicatedStorage

claimMission.OnServerEvent:Connect(function(player, missionId)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or typeof(missionId) ~= "string" then
		return
	end

	local mission, isDaily = MissionData.get(missionId)
	if not mission then
		return
	end

	if isDaily then
		MissionService.refreshDay(playerData)
	end
	if MissionData.isClaimed(mission, playerData, isDaily) or MissionData.progress(mission, playerData, isDaily) < mission.target then
		return
	end

	local list = isDaily and playerData.DailyClaimed or playerData.ClaimedMissions
	list.Value = list.Value == "" and mission.id or (list.Value .. "," .. mission.id)

	local reward = MissionData.reward(mission, playerData)
	playerData.Money.Value += reward
	showMessage:FireClient(player, "¡Premio cobrado: " .. reward .. "$!")
end)
