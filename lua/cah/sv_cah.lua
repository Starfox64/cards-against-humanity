-- Required Resources --
resource.AddFile("models/props_interiors/table_picnic.mdl")
resource.AddFile("materials/models/props_interiors/table_picnic.vmt")

CAH.expansions = CAH.expansions or {"Base"}

-- Server Default Config LEGACY --
CAH.Config = {}
CAH.Config.maxPoints = 5
CAH.Config.startTime = 30
CAH.Config.chooseTime = 30


function CAH:AddTable( cahTable )
	if self.Ready then
		local wPool, bPool = CAH:GeneratePool(self.expansions)

		local cahGame = {
			table = cahTable:EntIndex(),
			players = {},
			czar = nil,
			black = nil,
			wPool = wPool,
			bPool = bPool,
			endTime = math.huge,
			status = CAH_IDLE
		}
		setmetatable(cahGame, CAH.gameMeta)

		self.Games[cahTable:EntIndex()] = cahGame
		cahGame:Send()
	else
		-- Change icon
		CAH:Notify("Cannot create CAH Table, cards not loaded!")
	end
end

function CAH:GeneratePool( expansions )
	local wPool, bPool = {}, {}

	for cardID, card in pairs(CAH:GetCards()) do
		for k, extension in pairs(expansions) do
			if (card:IsExpansion(extension)) then
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


-- CAH Netstream Hooks --
netstream.Hook("CAH_Quit", function( client )
	if (IsValid(client:GetCAHGame())) then
		client:GetCAHGame():RemovePlayer(client)

		CAH:Notify("You left the game.", client)
	end
end)

netstream.Hook("CAH_DrawCard", function( client, cardID )
	client:DrawCard(cardID)
end)

netstream.Hook("CAH_ChooseCard", function( client, winner )
	client:ChooseCard(winner)
end)