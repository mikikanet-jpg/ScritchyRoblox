local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GiftData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GiftData"))
local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")

local claimGift = Instance.new("RemoteEvent")
claimGift.Name = "ClaimGift"
claimGift.Parent = ReplicatedStorage

claimGift.OnServerEvent:Connect(function(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or not GiftData.ready(playerData) then
		return
	end

	local reward = GiftData.reward(playerData)
	playerData.GiftDay.Value = GiftData.today()
	playerData.GiftCount.Value += 1
	playerData.Money.Value += reward
	showMessage:FireClient(player, "¡Regalo diario cobrado: " .. reward .. "$!")
end)
