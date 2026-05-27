game.Players.PlayerAdded:Connect(function(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 100
	money.Parent = leaderstats

	local tickets = Instance.new("IntValue")
	tickets.Name = "Tickets"
	tickets.Value = 0
	tickets.Parent = leaderstats

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = leaderstats

	local ticketLevel = Instance.new("IntValue")
	ticketLevel.Name = "TicketLevel"
	ticketLevel.Value = 1
	ticketLevel.Parent = leaderstats

end)