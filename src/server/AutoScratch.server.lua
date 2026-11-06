local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local PetService = require(script.Parent:WaitForChild("PetService"))
local MissionService = require(script.Parent:WaitForChild("MissionService"))
local TicketRules = require(script.Parent:WaitForChild("TicketRules"))
local TicketData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData"))

local buyAutoScratch = replicatedStorage:WaitForChild("BuyAutoScratch")
local showMessage = replicatedStorage:WaitForChild("ShowMessage")

local PRICE = 3000

-- Del mejor ticket al peor. El tiquet final solo se rasca a mano.
local AUTO_ORDER = {}
for _, ticketType in TicketData.Order do
	if not TicketData[ticketType].IsFinal then
		table.insert(AUTO_ORDER, 1, ticketType)
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

-- Mismas reglas que a mano, con la mitad de XP. No suelta mascotas.
local xpCarry = {}

local function applyResult(player, playerData, ticketType)
	local result = TicketRules.roll(playerData, ticketType)
	local prefix = "[AUTO " .. TicketData[ticketType].Label .. "] "

	if result.kind == "lose" then
		showMessage:FireClient(player, prefix .. "Has perdido")
	else
		playerData.Money.Value += result.reward
		MissionService.recordEarned(playerData, result.reward)
		if result.kind == "jackpot" then
			playerData.Jackpots.Value += 1
			MissionService.recordJackpot(playerData)
			if result.gift then
				playerData[result.gift.stat].Value += result.gift.amount
			end
			showMessage:FireClient(player, prefix .. "JACKPOT +" .. result.reward .. "$")
		else
			showMessage:FireClient(player, prefix .. "+" .. result.reward .. "$")
		end
	end

	local xp = (xpCarry[player] or 0) + TicketRules.xpPerScratch(playerData) / 2
	local whole = math.floor(xp)
	xpCarry[player] = xp - whole
	if whole > 0 then
		TicketRules.addXP(player, playerData, whole)
	end
end

local function runAutoScratch(player)
	local playerData = player:WaitForChild("PlayerData", 60)

	-- El bucle termina cuando el jugador sale.
	while playerData and player:IsDescendantOf(Players) do
		task.wait(playerData.AutoScratchSpeed.Value)

		if player:IsDescendantOf(Players) and playerData.AutoScratch.Value then
			for _, ticketType in AUTO_ORDER do
				local tickets = playerData[ticketType .. "Tickets"]
				if tickets.Value > 0 then
					tickets.Value -= 1
					applyResult(player, playerData, ticketType)
					break
				end
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	xpCarry[player] = nil
end)
Players.PlayerAdded:Connect(runAutoScratch)
for _, player in Players:GetPlayers() do
	task.spawn(runAutoScratch, player)
end
