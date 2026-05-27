game.Players.PlayerAdded:Connect(function(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 100
	money.Parent = leaderstats

	local basicTickets = Instance.new("IntValue")
    basicTickets.Name = "BasicTickets"
    basicTickets.Value = 0
    basicTickets.Parent = leaderstats

    local silverTickets = Instance.new("IntValue")
    silverTickets.Name = "SilverTickets"
    silverTickets.Value = 0
    silverTickets.Parent = leaderstats

    local goldTickets = Instance.new("IntValue")
    goldTickets.Name = "GoldTickets"
    goldTickets.Value = 0
    goldTickets.Parent = leaderstats

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = leaderstats

	local ticketLevel = Instance.new("IntValue")
	ticketLevel.Name = "TicketLevel"
	ticketLevel.Value = 1
	ticketLevel.Parent = leaderstats

end)