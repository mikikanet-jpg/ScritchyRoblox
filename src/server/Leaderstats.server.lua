game.Players.PlayerAdded:Connect(function(player)

	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"
	playerData.Parent = player

	-- MONEY

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 1000000
	money.Parent = playerData

	-- TICKETS

	local basicTickets = Instance.new("IntValue")
	basicTickets.Name = "BasicTickets"
	basicTickets.Value = 0
	basicTickets.Parent = playerData

	local silverTickets = Instance.new("IntValue")
	silverTickets.Name = "SilverTickets"
	silverTickets.Value = 0
	silverTickets.Parent = playerData

	local goldTickets = Instance.new("IntValue")
	goldTickets.Name = "GoldTickets"
	goldTickets.Value = 0
	goldTickets.Parent = playerData

	-- STATS

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = playerData

	local ticketLevel = Instance.new("IntValue")
	ticketLevel.Name = "TicketLevel"
	ticketLevel.Value = 1
	ticketLevel.Parent = playerData

	local ticketXP = Instance.new("IntValue")
	ticketXP.Name = "TicketXP"
	ticketXP.Value = 0
	ticketXP.Parent = playerData

	local jackpots = Instance.new("IntValue")
	jackpots.Name = "Jackpots"
	jackpots.Value = 0
	jackpots.Parent = playerData

	local prestige = Instance.new("IntValue")
	prestige.Name = "Prestige"
	prestige.Value = 0
	prestige.Parent = playerData

	local autoScratch = Instance.new("BoolValue")
	autoScratch.Name = "AutoScratch"
	autoScratch.Value = false
	autoScratch.Parent = playerData

	local autoScratchSpeed = Instance.new("NumberValue")
	autoScratchSpeed.Name = "AutoScratchSpeed"
	autoScratchSpeed.Value = 5
	autoScratchSpeed.Parent = playerData
end)