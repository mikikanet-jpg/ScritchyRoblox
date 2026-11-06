-- Reglas comunes de los tickets, para que rascar a mano y Auto Scratch den lo mismo.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TicketData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TicketData"))
local PetService = require(script.Parent:WaitForChild("PetService"))
local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")

local TicketRules = {}

-- Cada nivel de suerte por encima del 1 cambia un punto de "sin premio" por premio normal.
function TicketRules.loseChance(ticket, luck)
	local reduction = math.min(luck - 1, TicketData.MaxLuck - 1)
	return math.max(0, ticket.Lose - reduction)
end

function TicketRules.roll(playerData, ticketType)
	local ticket = TicketData[ticketType]
	local roll = math.random(1, 100)
	if roll <= TicketRules.loseChance(ticket, playerData.Luck.Value) then
		return { kind = "lose", reward = 0, ticketType = ticketType }
	elseif roll <= ticket.Win then
		return { kind = "win", reward = PetService.applyBonus(playerData, ticket.Reward), ticketType = ticketType }
	end
	return {
		kind = "jackpot",
		reward = PetService.applyBonus(playerData, ticket.Jackpot),
		text = ticket.JackpotText,
		ticketType = ticketType,
		gift = ticket.JackpotGift,
	}
end

function TicketRules.addXP(player, playerData, amount)
	local ticketXP = playerData.TicketXP
	local ticketLevel = playerData.TicketLevel

	ticketXP.Value += amount

	if ticketXP.Value >= ticketLevel.Value * TicketData.XPPerLevel then
		ticketXP.Value = 0
		ticketLevel.Value += 1
		showMessage:FireClient(player, "SUBES A NIVEL " .. ticketLevel.Value)
	end
end

function TicketRules.xpPerScratch(playerData)
	return 2 ^ playerData.Prestige.Value
end

return TicketRules
