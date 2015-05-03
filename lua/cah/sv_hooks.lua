hook.Add("CanExitVehicle", "CAH_CanExitVehicle", function( veh, client )
	if (veh:GetNWInt("CAH_ChairID")) then
		--return false
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
	for k, cahGame in pairs(CAH:GetGames()) do
		cahGame:Send(client)
	end
end)