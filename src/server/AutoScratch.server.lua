print("AUTO SCRATCH SERVER FUNCIONA")

local replicatedStorage = game:GetService("ReplicatedStorage")

local buyAutoScratch = replicatedStorage:WaitForChild("BuyAutoScratch")

local showMessage = replicatedStorage:WaitForChild("ShowMessage")

-- COMPRAR

buyAutoScratch.OnServerEvent:Connect(function(player)

	local playerData = player:WaitForChild("PlayerData")

	local money = playerData:WaitForChild("Money")

	local autoScratch = playerData:WaitForChild("AutoScratch")

	if autoScratch.Value == true then

		showMessage:FireClient(player, "Ya tienes Auto Scratch")

		return

	end

	if money.Value >= 5000 then

		money.Value -= 5000

		autoScratch.Value = true

		showMessage:FireClient(player, "AUTO SCRATCH DESBLOQUEADO")

	else

		showMessage:FireClient(player, "Necesitas 5000$")

	end

end)

-- AUTO SCRATCH LOOP

game.Players.PlayerAdded:Connect(function(player)

	task.spawn(function()

        while true do

            local playerData = player:FindFirstChild("PlayerData")

            if not playerData then
                task.wait(1)
                continue
            end

            local speed = playerData:FindFirstChild("AutoScratchSpeed")

            task.wait(speed.Value)

			local autoScratch = playerData:FindFirstChild("AutoScratch")

			if autoScratch and autoScratch.Value == true then

				local money = playerData:FindFirstChild("Money")

				local goldTickets = playerData:FindFirstChild("GoldTickets")
				local silverTickets = playerData:FindFirstChild("SilverTickets")
				local basicTickets = playerData:FindFirstChild("BasicTickets")

				-- GOLD

				if goldTickets and goldTickets.Value > 0 then

					goldTickets.Value -= 1

					local reward = math.random(5000,30000)

					money.Value += reward

					showMessage:FireClient(
						player,
						"[AUTO GOLD] +" .. reward .. "$"
					)

				-- SILVER

				elseif silverTickets and silverTickets.Value > 0 then

					silverTickets.Value -= 1

					local reward = math.random(500,2500)

					money.Value += reward

					showMessage:FireClient(
						player,
						"[AUTO SILVER] +" .. reward .. "$"
					)

				-- BASIC

				elseif basicTickets and basicTickets.Value > 0 then

					basicTickets.Value -= 1

					local reward = math.random(15,30)

					money.Value += reward

					showMessage:FireClient(
						player,
						"[AUTO BASIC] +" .. reward .. "$"
					)

				end

			end

		end

	end)

end)