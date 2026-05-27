local interactPart = workspace:WaitForChild("TicketTable_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local showMessage = game.ReplicatedStorage:WaitForChild("ShowMessage")

prompt.Triggered:Connect(function(player)

	local leaderstats = player:WaitForChild("leaderstats")

	local tickets = leaderstats:WaitForChild("Tickets")
	local money = leaderstats:WaitForChild("Money")

	if tickets.Value > 0 then

		tickets.Value -= 1

		local random = math.random(1, 100)

		if random <= 45 then

			showMessage:FireClient(player, "Has perdido")

		elseif random <= 95 then

			local reward = 25
			money.Value += reward

			showMessage:FireClient(player, "+" .. reward .. "$")

		else

			local jackpot = 100
			money.Value += jackpot

			showMessage:FireClient(player, "JACKPOT! +" .. jackpot .. "$")

		end

	else

		showMessage:FireClient(player, "No tienes tickets")

	end

end)