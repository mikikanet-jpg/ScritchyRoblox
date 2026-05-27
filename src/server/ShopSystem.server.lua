local interactPart = workspace:WaitForChild("PC_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local ticketPrice = 10

prompt.Triggered:Connect(function(player)

	local leaderstats = player:WaitForChild("leaderstats")

	local money = leaderstats:WaitForChild("Money")
	local tickets = leaderstats:WaitForChild("Tickets")

	if money.Value >= ticketPrice then

		money.Value = money.Value - ticketPrice
		tickets.Value = tickets.Value + 1

		print(player.Name .. " ha comprado un ticket")

	else

		print(player.Name .. " no tiene suficiente dinero")

	end

end)