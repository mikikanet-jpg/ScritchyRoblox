local interactPart = workspace:WaitForChild("PC_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local replicatedStorage = game:GetService("ReplicatedStorage")

local openShop = replicatedStorage:WaitForChild("OpenShop")
local buyTicket = replicatedStorage:WaitForChild("BuyTicket")

local TicketData = require(game.ReplicatedStorage.Shared.TicketData)

prompt.Triggered:Connect(function(player)

	-- Sin dinero ni tickets no se podría seguir jugando, así que se regala uno.
	local data = player:FindFirstChild("PlayerData")
	if data and data.Money.Value < TicketData.Basic.Price then
		local total = 0
		for _, ticketType in TicketData.Order do
			total += data[ticketType .. "Tickets"].Value
		end
		if total == 0 then
			data.BasicTickets.Value = 1
			replicatedStorage.ShowMessage:FireClient(player, "Te regalamos un ticket para seguir jugando")
		end
	end

	openShop:FireClient(player)

end)

buyTicket.OnServerEvent:Connect(function(player, ticketType)

	local PlayerData = player:WaitForChild("PlayerData")
	local money = PlayerData:WaitForChild("Money")

	local ticketInfo = table.find(TicketData.Order, ticketType) and TicketData[ticketType]
	local level = PlayerData:WaitForChild("TicketLevel")
	if not ticketInfo then
		return
	end

	-- El tiquet final solo se puede tener una vez.
	if ticketInfo.IsFinal and (PlayerData.GameWon.Value or PlayerData.FinalTickets.Value > 0) then
		return
	end

	-- El servidor también comprueba los requisitos, no solo el menú.
	local unlocked = level.Value >= ticketInfo.UnlockLevel and PlayerData.Prestige.Value >= (ticketInfo.UnlockPrestige or 0)
	if unlocked and money.Value >= ticketInfo.Price then

		money.Value -= ticketInfo.Price

		local ticketStat = PlayerData:FindFirstChild(ticketType .. "Tickets")

		if ticketStat then

			ticketStat.Value += 1

		end

	end

end)