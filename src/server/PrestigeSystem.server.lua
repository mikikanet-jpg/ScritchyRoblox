print("PRESTIGE SERVER FUNCIONA")

local replicatedStorage = game:GetService("ReplicatedStorage")

local prestigeEvent = replicatedStorage:WaitForChild("PrestigeEvent")

prestigeEvent.OnServerEvent:Connect(function(player)
    print("SERVIDOR RECIBE PRESTIGIO")
	local playerData = player:WaitForChild("PlayerData")

	local level = playerData:WaitForChild("TicketLevel")

	if level.Value >= 5 then

        playerData.Prestige.Value += 1

        level.Value = 1
        playerData.TicketXP.Value = 0

        playerData.Money.Value = 100

        playerData.BasicTickets.Value = 0
        playerData.SilverTickets.Value = 0
        playerData.GoldTickets.Value = 0

        playerData.Luck.Value += 1

        game.ReplicatedStorage.ShowMessage:FireClient(
            player,
            "¡PRESTIGIO COMPLETADO!"
        )

    else

        game.ReplicatedStorage.ShowMessage:FireClient(
            player,
            "Necesitas llegar al nivel 5"
        )

    end

end)