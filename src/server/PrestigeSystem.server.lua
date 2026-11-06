local replicatedStorage = game:GetService("ReplicatedStorage")

local TicketData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData"))

local prestigeEvent = replicatedStorage:WaitForChild("PrestigeEvent")

prestigeEvent.OnServerEvent:Connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local level = playerData:WaitForChild("TicketLevel")

	if level.Value >= 20 then

        playerData.Prestige.Value += 1

        level.Value = 1
        playerData.TicketXP.Value = 0

        playerData.Money.Value = 100

        for _, ticketType in TicketData.Order do
            playerData[ticketType .. "Tickets"].Value = 0
        end

        playerData.Luck.Value += 1

        game.ReplicatedStorage.ShowMessage:FireClient(
            player,
            "¡PRESTIGIO COMPLETADO!"
        )

    else

        game.ReplicatedStorage.ShowMessage:FireClient(
            player,
            "Necesitas llegar al nivel 20"
        )

    end

end)