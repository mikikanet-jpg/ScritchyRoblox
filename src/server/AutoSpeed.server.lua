local replicatedStorage = game:GetService("ReplicatedStorage")

local upgradeEvent = replicatedStorage:WaitForChild("UpgradeAutoSpeed")

local showMessage = replicatedStorage:WaitForChild("ShowMessage")

upgradeEvent.OnServerEvent:Connect(function(player)

	local playerData = player:WaitForChild("PlayerData")

	local money = playerData:WaitForChild("Money")

	local speed = playerData:WaitForChild("AutoScratchSpeed")

	local price = 2500

	if speed.Value <= 0.5 then

		showMessage:FireClient(
			player,
			"Velocidad máxima alcanzada"
		)

		return

	end

	if money.Value >= price then

		money.Value -= price

		speed.Value -= 0.5

		showMessage:FireClient(
			player,
			"Auto Scratch mejorado"
		)

	else

		showMessage:FireClient(
			player,
			"No tienes suficiente dinero"
		)

	end

end)