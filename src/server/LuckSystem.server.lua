local replicatedStorage = game:GetService("ReplicatedStorage")

local buyLuck = replicatedStorage:WaitForChild("BuyLuck")

local showMessage = replicatedStorage:WaitForChild("ShowMessage")

buyLuck.OnServerEvent:Connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local money = playerData:WaitForChild("Money")
	local luck = playerData:WaitForChild("Luck")

	local price = luck.Value * 1000

	if money.Value >= price then

		money.Value -= price

		luck.Value += 1

		showMessage:FireClient(
			player,
			"+1 Luck"
		)

	else

		showMessage:FireClient(
			player,
			"No tienes suficiente dinero"
		)

	end

end)