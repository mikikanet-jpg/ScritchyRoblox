local interactPart = workspace:WaitForChild("PC_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local replicatedStorage = game:GetService("ReplicatedStorage")

local openShop = replicatedStorage:WaitForChild("OpenShop")
local buyTicket = replicatedStorage:WaitForChild("BuyTicket")

local prices = {
	Basic = 10,
	Silver = 50,
	Gold = 150
}

prompt.Triggered:Connect(function(player)

	print("PC usado")

	openShop:FireClient(player)

end)

buyTicket.OnServerEvent:Connect(function(player, ticketType)

	local leaderstats = player:WaitForChild("leaderstats")

	local money = leaderstats:WaitForChild("Money")

	local price = prices[ticketType]

	if money.Value >= price then

		money.Value -= price

		if ticketType == "Basic" then

			leaderstats.BasicTickets.Value += 1

		elseif ticketType == "Silver" then

			leaderstats.SilverTickets.Value += 1

		elseif ticketType == "Gold" then

			leaderstats.GoldTickets.Value += 1

		end

	end

end)