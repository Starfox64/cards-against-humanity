-- Required Resources --
resource.AddFile("models/props_interiors/table_picnic.mdl")
resource.AddFile("materials/models/props_interiors/table_picnic.vmt")


function CAH:AddTable( cahTable )
	local cahGame = {
		table = cahTable:EntIndex(),
		players = {},
		czar = nil,
		black = nil,
		wPool = {},
		bPool = {},
		endTime = math.huge,
		status = CAH_IDLE
	}
	setmetatable(cahGame, CAH.gameMeta)

	self.Games[cahTable:EntIndex()] = cahGame
	cahGame:Send()
end

function CAH:GeneratePool()
	local wPool, bPool = {}, {}

	for cardID, card in pairs(self:GetCards()) do
		for k, expansion in pairs(self.expansions) do
			if (self.Config.expansions[expansion] and card:IsExpansion(expansion)) then
				if (card:IsAnswer()) then
					table.insert(wPool, cardID)
				else
					table.insert(bPool, cardID)
				end
				break
			end
		end
	end

	return wPool, bPool
end

function CAH:Notify( message, target, icon, noSound )
	netstream.Start(target, "CAH_Notification", {m = message, i = icon, ns = noSound})
end

function CAH:SaveConfig()
	if (self.Ready) then
		-- Adds expansions to the config table if they aren't already.
		for _, expansion in pairs(self.expansions) do
			if (self.Config.expansions[expansion] == nil) then
				self.Config.expansions[expansion] = false
			end
		end

		local configData = von.serialize(self.Config)
		file.Write("cah/config.txt", configData)

		MsgC(Color(25, 200, 25), "[CAH] Server config saved.\n")
	end
end

function CAH:LoadConfig()
	if (file.Exists("cah/config.txt", "DATA")) then
		local success, configData = pcall(von.deserialize, file.Read("cah/config.txt", "DATA"))

		if (success) then
			-- Adds expansions to the config table if they aren't already.
			for _, expansion in pairs(self.expansions) do
				if (configData.expansions[expansion] == nil) then
					configData.expansions[expansion] = false
				end
			end

			self.Config = configData

			MsgC(Color(25, 200, 25), "[CAH] Server config successfully loaded.\n")
		else
			MsgC(Color(200, 70, 70), "[CAH] Failed to load the server config! (cah_config.txt corrupted)\n")
		end
	else
		MsgC(Color(251, 184, 41), "[CAH] Server config not found, using default config.\n")
	end
end

-- Waits until the cards are loaded to load the server config.
hook.Add("Think", "CAH_ConfigLoader", function()
	if (CAH.Ready) then
		CAH:LoadConfig()
		hook.Remove("Think", "CAH_ConfigLoader")
	end
end)


-- CAH Netstream Hooks --
netstream.Hook("CAH_Quit", function( client )
	if (IsValid(client:GetCAHGame())) then
		client:GetCAHGame():RemovePlayer(client)

		CAH:Notify("You left the game.", client)
	end
end)

netstream.Hook("CAH_DiscoverCard", function( client )
	client:Discover()
end)

netstream.Hook("CAH_DrawCard", function( client, cardID )
	client:DrawCard(cardID)
end)

netstream.Hook("CAH_ChooseCard", function( client, winner )
	client:ChooseCard(winner)
end)

netstream.Hook("CAH_RefreshConfig", function( client )
	netstream.Start(client, "CAH_RefreshConfig", CAH.Config)
end)

netstream.Hook("CAH_SaveConfig", function( client, config )
	if (client:IsSuperAdmin()) then
		if (#table.KeysFromValue(config.expansions, true) == 0) then
			CAH:Notify("The config you are trying to save does not have any active expansions!", client)
			return
		end

		CAH.Config = config
		CAH:SaveConfig()

		CAH:Notify("The config has been saved!", client)
		netstream.Start(client, "CAH_RefreshConfig", CAH.Config)
		MsgC(Color(251, 184, 41), "[CAH] "..client:Name().." ("..client:SteamID()..") edited the config.\n")
	else
		CAH:Notify("You need to be a super admin to edit the config", client)
	end
end)