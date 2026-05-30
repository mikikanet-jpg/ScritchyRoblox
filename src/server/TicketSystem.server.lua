local interactPart = workspace:WaitForChild("TicketTable_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local replicatedStorage = game:GetService("ReplicatedStorage")

local showMessage = replicatedStorage:WaitForChild("ShowMessage")
local openScratch = replicatedStorage:WaitForChild("OpenScratch")
local scratchTicket = replicatedStorage:WaitForChild("ScratchTicket")

-- ABRIR MENU

prompt.Triggered:Connect(function(player)

	openScratch:FireClient(player)

end)

-- RASCAR TICKETS

scratchTicket.OnServerEvent:Connect(function(player, ticketType)

	local PlayerData = player:WaitForChild("PlayerData")

	local money = PlayerData:WaitForChild("Money")

	local ticketName = ticketType .. "Tickets"
	local tickets = PlayerData:WaitForChild(ticketName)

	if tickets.Value <= 0 then

		showMessage:FireClient(player, "No tienes tickets")

		return

	end

	tickets.Value -= 1

	local ticketXP = PlayerData:WaitForChild("TicketXP")
	local ticketLevel = PlayerData:WaitForChild("TicketLevel")

	ticketXP.Value += 1

	local requiredXP = ticketLevel.Value * 10

	if ticketXP.Value >= requiredXP then

		ticketXP.Value = 0
		ticketLevel.Value += 1

		showMessage:FireClient(player, "SUBES A NIVEL " .. ticketLevel.Value)

	end

	local random = math.random(1,100)

	-- BASIC

	if ticketType == "Basic" then

		if random <= 35 then

			showMessage:FireClient(player, "Has perdido")

		elseif random <= 90 then

			local reward = 30
			money.Value += reward

			showMessage:FireClient(player, "+" .. reward .. "$")

		else

			local jackpot = 100
			money.Value += jackpot

			showMessage:FireClient(player, "JACKPOT! +" .. jackpot .. "$")

		end

	-- SILVER

	elseif ticketType == "Silver" then

		if random <= 25 then

			showMessage:FireClient(player, "Has perdido")

		elseif random <= 85 then

			local reward = 125
			money.Value += reward

			showMessage:FireClient(player, "+" .. reward .. "$")

		else

			local jackpot = 500
			money.Value += jackpot

			showMessage:FireClient(player, "JACKPOT PLATA! +" .. jackpot .. "$")

		end

	-- GOLD

	elseif ticketType == "Gold" then

		if random <= 15 then

			showMessage:FireClient(player, "Has perdido")

		elseif random <= 75 then

			local reward = 325
			money.Value += reward

			showMessage:FireClient(player, "+" .. reward .. "$")

		else

			local jackpot = 2000
			money.Value += jackpot

			showMessage:FireClient(player, "JACKPOT ORO! +" .. jackpot .. "$")

		end

	end

end)