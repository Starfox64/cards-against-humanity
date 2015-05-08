-- Required Resources --
resource.AddFile("models/props_interiors/table_picnic.mdl")
resource.AddFile("materials/models/props_interiors/table_picnic.vmt")

CAH.expansions = CAH.expansions or {"Base"}

-- Server ConVars --
CAH.CVAR.maxpoints = CreateConVar("cah_maxpoints", 5, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))

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

function CAH:Notify( message, icon, noSound )
	netstream.Start(nil, "CAH_Notification", {m = message, i = icon, ns = noSound})
end