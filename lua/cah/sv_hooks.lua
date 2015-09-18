hook.Add("CanExitVehicle", "CAH_CanExitVehicle", function( veh, client )
	if (veh:GetNWInt("CAH_ChairID")) then
		return false
	end
end)

hook.Add("EntityRemoved", "CAH_EntityRemoved", function( ent )
	if (ent:GetClass() == "cah_table") then
		local cahGame = CAH:GetGame(ent)

		if (not IsValid(cahGame)) then return end

		for k, client in pairs(cahGame:GetPlayers()) do
			cahGame:RemovePlayer(client)
		end

		CAH.Games[ent:EntIndex()] = nil
		netstream.Start(nil, "CAH_GameDel", ent:EntIndex())
	end
end)

hook.Add("PlayerInitialSpawn", "CAH_PlayerInitialSpawn", function( client )
	netstream.Start(client, "CAH_RefreshConfig", CAH.Config)

	if (CAH.Ready) then
		netstream.Start(client, "CAH_LoadCards", CAH.SHA)
	end

	for k, cahGame in pairs(CAH:GetGames()) do
		cahGame:Send(true, client)
	end
end)

hook.Add("Think", "CAH_Think", function()
	for _, cahGame in pairs(CAH:GetGames()) do
		local playerCount = #cahGame:GetPlayers()
		local status = cahGame:GetStatus()
		local timeLeft = cahGame:GetTimeLeft()

		if (playerCount < 3 and (status != CAH_IDLE or (status == CAH_IDLE and timeLeft != math.huge))) then -- Too many players left.
			cahGame:SetStatus(CAH_IDLE)
			cahGame:SetTimeLeft(math.huge)

			for _, client in pairs(cahGame:GetPlayers()) do
				client:SetCAHPoints(0)
				client.CAH.cards = {}
				client.CAH.selected = {}
			end

			CAH:Notify("There needs to be at least 3 players to play, find new friends.", cahGame:GetPlayers())

			cahGame:Send(true)
		elseif (playerCount >= 3 and status == CAH_IDLE and timeLeft == math.huge) then -- Enough players to start and game isn't already starting.
			cahGame:SetTimeLeft(CAH.Config.startTime)
			cahGame:Send()

			CAH:Notify("The game will start in "..CAH.Config.startTime.." seconds.", cahGame:GetPlayers())
		elseif ((status == CAH_IDLE or status == CAH_DISCOVER) and timeLeft <= 0) then -- Game starting / Czar inactive.
			local wPool, bPool = CAH:GeneratePool()
			cahGame.wPool, cahGame.bPool = wPool, bPool

			cahGame:NewRound()
		elseif (status == CAH_ANSWER) then -- Players are answering to / completing the black card.
			local playersReady, nextPhase = 0, false
			local requiredCards = CAH:GetCard(cahGame:GetBlackCard()):IsPick2() and 2 or 1 -- Counts how many cards a player needs to draw.

			for _, client in pairs(cahGame:GetPlayers()) do
				if (#client:GetSelectedCards() == requiredCards) then
					playersReady = playersReady + 1
				end
			end

			if (timeLeft <= 0) then -- If players take too long to draw their cards then we draw cards for them.
				for _, client in pairs(cahGame:GetPlayers()) do
					if (#client:GetSelectedCards() == requiredCards) then
						for i = 1, requiredCards do
							local isSecond = i == 2 and true or false
							client:SetSelectedCard(isSecond, table.Random(client:GetCards()))
						end
					end
					CAH:Notify("You were too slow, better luck next time.", client)
				end

				nextPhase = true
			elseif (playersReady == playerCount) then
				nextPhase = true
			end

			if (nextPhase) then
				cahGame:SetStatus(CAH_CHOOSE)
				cahGame:SetTimeLeft(CAH.Config.chooseTime)

				CAH:Notify("The Card Czar may now choose his favorite card"..(CAH:GetCard(cahGame:GetBlackCard()):IsPick2() and "s" or "")..".", cahGame:GetPlayers())
			end
		elseif (status == CAH_CHOOSE and timeLeft <= 0) then -- The Card Czar did not choose a winning card.
			CAH:Notify("The Card Czar did not choose a winning card.", cahGame:GetPlayers())
			cahGame:NewRound()
		elseif (status == CAH_END and timeLeft <= 0) then -- The end phase is over.
			for _, client in pairs(cahGame:GetPlayers()) do
				if (client:GetCAHPoints() >= CAH.Config.maxPoints) then
					CAH:Notify(client:Name().." won this game!", "cah/win64.png", cahGame:GetPlayers())

					cahGame:SetStatus(CAH_IDLE)
					cahGame:SetTimeLeft(math.huge)

					return
				end
			end

			cahGame:NewRound()
		end
	end
end)