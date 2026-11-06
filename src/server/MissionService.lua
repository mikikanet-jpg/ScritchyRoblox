local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MissionData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MissionData"))

local MissionService = {}

local function refreshDay(playerData)
	local today = MissionData.today()
	if playerData.DailyDay.Value ~= today then
		playerData.DailyDay.Value = today
		playerData.DailyScratched.Value = 0
		playerData.DailyEarned.Value = 0
		playerData.DailyJackpots.Value = 0
		playerData.DailyClaimed.Value = ""
	end
end

MissionService.refreshDay = refreshDay

function MissionService.recordScratch(playerData)
	refreshDay(playerData)
	playerData.TotalScratched.Value += 1
	playerData.DailyScratched.Value += 1
end

function MissionService.recordEarned(playerData, amount)
	refreshDay(playerData)
	playerData.TotalEarned.Value += amount
	playerData.DailyEarned.Value += amount
end

function MissionService.recordJackpot(playerData)
	refreshDay(playerData)
	playerData.DailyJackpots.Value += 1
end

return MissionService
