local PetData = require(script.Parent:WaitForChild("PetData"))
local RoomData = require(script.Parent:WaitForChild("RoomData"))

local MissionData = {}

-- Se reinician cada día. La recompensa crece con el nivel y no se pierde nada por no entrar.
MissionData.Daily = {
	{ id = "daily_scratch", name = "Rasca 20 tickets hoy", emoji = "🎟️", stat = "DailyScratched", target = 20, rewardPerLevel = 100 },
	{ id = "daily_earn", name = "Gana $1.000 hoy", emoji = "💰", stat = "DailyEarned", target = 1000, rewardPerLevel = 100 },
	{ id = "daily_jackpot", name = "Saca un jackpot hoy", emoji = "🎉", stat = "DailyJackpots", target = 1, rewardPerLevel = 300 },
}

-- Logros permanentes: se reclaman una vez.
MissionData.Achievements = {
	{ id = "scratch_1", name = "Primer rasca", emoji = "🎟️", stat = "TotalScratched", target = 1, reward = 50 },
	{ id = "scratch_50", name = "Rasca 50 tickets", emoji = "🎟️", stat = "TotalScratched", target = 50, reward = 500 },
	{ id = "scratch_500", name = "Rasca 500 tickets", emoji = "🎟️", stat = "TotalScratched", target = 500, reward = 10000 },
	{ id = "scratch_2000", name = "Rasca 2.000 tickets", emoji = "🎟️", stat = "TotalScratched", target = 2000, reward = 100000 },
	{ id = "earn_10k", name = "Gana $10.000 en total", emoji = "💰", stat = "TotalEarned", target = 10000, reward = 1000 },
	{ id = "earn_1m", name = "Gana $1.000.000 en total", emoji = "💰", stat = "TotalEarned", target = 1000000, reward = 50000 },
	{ id = "earn_100m", name = "Gana $100.000.000 en total", emoji = "💰", stat = "TotalEarned", target = 100000000, reward = 1000000 },
	{ id = "jackpot_1", name = "Tu primer jackpot", emoji = "🎉", stat = "Jackpots", target = 1, reward = 500 },
	{ id = "jackpot_25", name = "Saca 25 jackpots", emoji = "🎉", stat = "Jackpots", target = 25, reward = 25000 },
	{ id = "pets_3", name = "Consigue 3 mascotas", emoji = "🐶", counter = "pets", target = 3, reward = 5000 },
	{ id = "pets_all", name = "Consigue todas las mascotas", emoji = "🐶", counter = "pets", target = #PetData.Pets, reward = 500000 },
	{ id = "room_all", name = "Compra toda la decoración", emoji = "🏠", counter = "room", target = #RoomData.Items, reward = 50000 },
	{ id = "prestige_1", name = "Haz tu primer prestigio", emoji = "👑", stat = "Prestige", target = 1, reward = 10000 },
	{ id = "game_won", name = "Completa el tiquet final", emoji = "🏆", stat = "GameWon", target = 1, reward = 1000000 },
}

-- Estadísticas que cambian el progreso de alguna misión.
MissionData.WatchedStats = {
	"DailyDay", "DailyScratched", "DailyEarned", "DailyJackpots", "DailyClaimed", "ClaimedMissions",
	"TotalScratched", "TotalEarned", "Jackpots", "OwnedPets", "RoomItems", "Prestige", "GameWon", "TicketLevel",
}

local function countList(text)
	if text == "" then
		return 0
	end
	return #string.split(text, ",")
end

function MissionData.today()
	return math.floor(os.time() / 86400)
end

function MissionData.get(id)
	for _, list in { MissionData.Daily, MissionData.Achievements } do
		for _, mission in list do
			if mission.id == id then
				return mission, list == MissionData.Daily
			end
		end
	end
	return nil, false
end

function MissionData.progress(mission, playerData, isDaily)
	if isDaily and playerData.DailyDay.Value ~= MissionData.today() then
		return 0
	end
	if mission.counter == "pets" then
		return countList(playerData.OwnedPets.Value)
	elseif mission.counter == "room" then
		return countList(playerData.RoomItems.Value)
	end
	local value = playerData[mission.stat].Value
	if value == true then
		return 1
	elseif value == false then
		return 0
	end
	return value
end

function MissionData.reward(mission, playerData)
	if mission.rewardPerLevel then
		return mission.rewardPerLevel * playerData.TicketLevel.Value
	end
	return mission.reward
end

function MissionData.isClaimed(mission, playerData, isDaily)
	if isDaily then
		return playerData.DailyDay.Value == MissionData.today()
			and table.find(string.split(playerData.DailyClaimed.Value, ","), mission.id) ~= nil
	end
	return table.find(string.split(playerData.ClaimedMissions.Value, ","), mission.id) ~= nil
end

return MissionData
