local replicatedStorage = game:GetService("ReplicatedStorage")

local buyLuck = replicatedStorage:WaitForChild("BuyLuck")

local showMessage = replicatedStorage:WaitForChild("ShowMessage")
local TicketData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData"))

buyLuck.OnServerEvent:Connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local money = playerData:WaitForChild("Money")
	local luck = playerData:WaitForChild("Luck")

	if luck.Value >= TicketData.MaxLuck then
		showMessage:FireClient(player, "Tu suerte ya está al máximo")
		return
	end

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