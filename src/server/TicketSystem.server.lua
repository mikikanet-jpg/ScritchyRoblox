local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local interactPart = workspace:WaitForChild("TicketTable_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")
local openScratch = ReplicatedStorage:WaitForChild("OpenScratch")
local scratchTicket = ReplicatedStorage:WaitForChild("ScratchTicket")

local function getRemote(name)
	local remote = ReplicatedStorage:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = ReplicatedStorage
	end
	return remote
end

-- El servidor decide el premio al empezar y lo paga al terminar de rascar.
local scratchStarted = getRemote("ScratchStarted")
local scratchReveal = getRemote("ScratchReveal")

local AUTO_REVEAL_SECONDS = 120

-- lose y win son el límite superior de una tirada del 1 al 100.
local OUTCOMES = {
	Basic = { lose = 35, win = 90, reward = 30, jackpot = 100, jackpotText = "JACKPOT! +" },
	Silver = { lose = 25, win = 85, reward = 500, jackpot = 1500, jackpotText = "JACKPOT PLATA! +" },
	Gold = { lose = 15, win = 75, reward = 25000, jackpot = 50000, jackpotText = "JACKPOT ORO! +" },
}

local pending = {}

prompt.Triggered:Connect(function(player)
	openScratch:FireClient(player)
end)

local function finishScratch(player, scratch)
	if pending[player] ~= scratch then
		return
	end
	pending[player] = nil

	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return
	end

	local ticketXP = playerData.TicketXP
	local ticketLevel = playerData.TicketLevel

	ticketXP.Value += 2 ^ playerData.Prestige.Value

	local requiredXP = ticketLevel.Value * 10
	if ticketXP.Value >= requiredXP then
		ticketXP.Value = 0
		ticketLevel.Value += 1
		showMessage:FireClient(player, "SUBES A NIVEL " .. ticketLevel.Value)
	end

	if scratch.kind == "lose" then
		showMessage:FireClient(player, "Has perdido")
	elseif scratch.kind == "win" then
		playerData.Money.Value += scratch.reward
		showMessage:FireClient(player, "+" .. scratch.reward .. "$")
	else
		playerData.Money.Value += scratch.reward
		playerData.Jackpots.Value += 1
		showMessage:FireClient(player, scratch.text .. scratch.reward .. "$")
	end
end

scratchTicket.OnServerEvent:Connect(function(player, ticketType)
	local outcome = typeof(ticketType) == "string" and OUTCOMES[ticketType]
	if not outcome or pending[player] then
		return
	end

	local playerData = player:FindFirstChild("PlayerData")
	local tickets = playerData and playerData:FindFirstChild(ticketType .. "Tickets")
	if not tickets then
		return
	end

	if tickets.Value <= 0 then
		showMessage:FireClient(player, "No tienes tickets")
		return
	end

	tickets.Value -= 1

	local roll = math.random(1, 100)
	local scratch
	if roll <= outcome.lose then
		scratch = { kind = "lose", reward = 0 }
	elseif roll <= outcome.win then
		scratch = { kind = "win", reward = outcome.reward }
	else
		scratch = { kind = "jackpot", reward = outcome.jackpot, text = outcome.jackpotText }
	end

	pending[player] = scratch
	scratchStarted:FireClient(player, ticketType, scratch.kind, scratch.reward)

	-- Si el jugador nunca termina, no pierde el premio.
	task.delay(AUTO_REVEAL_SECONDS, finishScratch, player, scratch)
end)

scratchReveal.OnServerEvent:Connect(function(player)
	local scratch = pending[player]
	if scratch then
		finishScratch(player, scratch)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	pending[player] = nil
end)
