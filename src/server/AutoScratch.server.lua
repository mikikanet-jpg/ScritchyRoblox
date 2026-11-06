local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local PetService = require(script.Parent:WaitForChild("PetService"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))
local TicketData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData"))

local buyAutoScratch = replicatedStorage:WaitForChild("BuyAutoScratch")
local showMessage = replicatedStorage:WaitForChild("ShowMessage")

local PRICE = 3000

-- Del mejor ticket al peor. El tiquet final solo se rasca a mano.
local AUTO_ORDER = {}
for _, ticketType in TicketData.Order do
	local info = TicketData[ticketType]
	if info.AutoMin then
		table.insert(AUTO_ORDER, 1, { stat = ticketType .. "Tickets", label = string.upper(ticketType), min = info.AutoMin, max = info.AutoMax })
	end
end

buyAutoScratch.OnServerEvent:Connect(function(player)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return
	end

	local money = playerData.Money
	local autoScratch = playerData.AutoScratch

	if autoScratch.Value then
		showMessage:FireClient(player, "Ya tienes Auto Scratch")
	elseif money.Value >= PRICE then
		money.Value -= PRICE
		autoScratch.Value = true
		showMessage:FireClient(player, "AUTO SCRATCH DESBLOQUEADO")
	else
		showMessage:FireClient(player, "Necesitas " .. PRICE .. "$")
	end
end)

local function runAutoScratch(player)
	local playerData = player:WaitForChild("PlayerData", 60)

	-- El bucle termina cuando el jugador sale.
	while playerData and player:IsDescendantOf(Players) do
		task.wait(playerData.AutoScratchSpeed.Value)

		if player:IsDescendantOf(Players) and playerData.AutoScratch.Value then
			for _, ticket in AUTO_ORDER do
				local tickets = playerData[ticket.stat]
				if tickets.Value > 0 then
					tickets.Value -= 1
					local reward = PetService.applyBonus(playerData, math.random(ticket.min, ticket.max))
					playerData.Money.Value += reward
					MissionService.recordEarned(playerData, reward)
					showMessage:FireClient(player, "[AUTO " .. ticket.label .. "] +" .. reward .. "$")
					break
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(runAutoScratch)
for _, player in Players:GetPlayers() do
	task.spawn(runAutoScratch, player)
end
