local interactPart = workspace:WaitForChild("TicketTable_Interact")
local prompt = interactPart:WaitForChild("ProximityPrompt")

local replicatedStorage = game:GetService("ReplicatedStorage")

local openScratch = replicatedStorage:WaitForChild("OpenScratch")

prompt.Triggered:Connect(function(player)

	openScratch:FireClient(player)

end)