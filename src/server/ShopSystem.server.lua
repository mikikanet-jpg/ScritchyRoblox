local interactPart = workspace:WaitForChild("PC_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local replicatedStorage = game:GetService("ReplicatedStorage")

local openShop = replicatedStorage:WaitForChild("OpenShop")
local buyTicket = replicatedStorage:WaitForChild("BuyTicket")

local TicketData = require(game.ReplicatedStorage.Shared.TicketData)

prompt.Triggered:Connect(function(player)

	-- Sin dinero ni tickets no se podría seguir jugando, así que se regala uno.
	local data = player:FindFirstChild("PlayerData")
	if data and data.Money.Value < TicketData.Basic.Price
		and data.BasicTickets.Value + data.SilverTickets.Value + data.GoldTickets.Value == 0 then
		data.BasicTickets.Value = 1
		replicatedStorage.ShowMessage:FireClient(player, "Te regalamos un ticket para seguir jugando")
	end

	openShop:FireClient(player)

end)

buyTicket.OnServerEvent:Connect(function(player, ticketType)

	local PlayerData = player:WaitForChild("PlayerData")
	local money = PlayerData:WaitForChild("Money")

	local ticketInfo = typeof(ticketType) == "string" and TicketData[ticketType]
	local level = PlayerData:WaitForChild("TicketLevel")

	-- El servidor también comprueba el nivel, no solo el menú.
	if ticketInfo and level.Value >= ticketInfo.UnlockLevel and money.Value >= ticketInfo.Price then

		money.Value -= ticketInfo.Price

		local ticketStat = PlayerData:FindFirstChild(ticketType .. "Tickets")

		if ticketStat then

			ticketStat.Value += 1

		end

	end

end)