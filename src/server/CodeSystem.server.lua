-- Códigos que regalan dinero del juego. La lista solo está en el servidor para que nadie la lea.
-- Para añadir uno, pon una línea más. Cada jugador usa cada código una sola vez.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local showMessage = ReplicatedStorage:WaitForChild("ShowMessage")

local CODES = {
	TIKTOK = 5000,
	SCRITCHY = 2500,
	WELCOME = 1000,
}

local redeemCode = Instance.new("RemoteEvent")
redeemCode.Name = "RedeemCode"
redeemCode.Parent = ReplicatedStorage

local lastTry = {}

redeemCode.OnServerEvent:Connect(function(player, text)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or typeof(text) ~= "string" or #text > 40 then
		return
	end
	-- Un intento por segundo, para que no se puedan probar códigos a lo loco.
	if os.clock() - (lastTry[player] or 0) < 1 then
		return
	end
	lastTry[player] = os.clock()

	local code = string.upper((string.gsub(text, "%s", "")))
	local reward = CODES[code]
	local used = playerData.RedeemedCodes
	if not reward then
		showMessage:FireClient(player, "Ese código no existe")
	elseif table.find(string.split(used.Value, ","), code) then
		showMessage:FireClient(player, "Ya has usado ese código")
	else
		used.Value = used.Value == "" and code or (used.Value .. "," .. code)
		playerData.Money.Value += reward
		showMessage:FireClient(player, "¡Código canjeado: " .. reward .. "$!")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastTry[player] = nil
end)
