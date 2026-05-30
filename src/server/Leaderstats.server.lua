game.Players.PlayerAdded:Connect(function(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "PlayerData"
	leaderstats.Parent = player

	-- DINERO

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 100
	money.Parent = leaderstats

	-- TICKETS

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

	-- SUERTE

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = leaderstats

	-- NIVEL TICKETS

	local ticketLevel = Instance.new("IntValue")
	ticketLevel.Name = "TicketLevel"
	ticketLevel.Value = 1
	ticketLevel.Parent = leaderstats

	local TicketXP = Instance.new("IntValue")
	TicketXP.Name = "TicketXP"
	TicketXP.Value = 0
	TicketXP.Parent = playerData
	-- JACKPOTS

	local jackpots = Instance.new("IntValue")
	jackpots.Name = "Jackpots"
	jackpots.Value = 0
	jackpots.Parent = leaderstats

	local selectedTicket = Instance.new("StringValue")
	selectedTicket.Name = "SelectedTicket"
	selectedTicket.Value = "Basic"
	selectedTicket.Parent = player

end)