local interactPart = workspace:WaitForChild("PC_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local replicatedStorage = game:GetService("ReplicatedStorage")

local openShop = replicatedStorage:WaitForChild("OpenShop")
local buyTicket = replicatedStorage:WaitForChild("BuyTicket")

local TicketData = require(game.ReplicatedStorage.Shared.TicketData)

prompt.Triggered:Connect(function(player)

	openShop:FireClient(player)

end)

buyTicket.OnServerEvent:Connect(function(player, ticketType)

	local PlayerData = player:WaitForChild("PlayerData")
	local money = PlayerData:WaitForChild("Money")

	local ticketInfo = TicketData[ticketType]

	if ticketInfo and money.Value >= ticketInfo.Price then

		money.Value -= ticketInfo.Price

		local ticketStat = PlayerData:FindFirstChild(ticketType .. "Tickets")

		if ticketStat then

			ticketStat.Value += 1

		end

	end

end)