-- Required Resources --
resource.AddFile("models/props_interiors/table_picnic.mdl")
resource.AddFile("materials/models/props_interiors/table_picnic.vmt")

CAH.expansions = CAH.expansions or {"Base"}

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
		-- Notify, server not ready
		print("Cards not loaded!")
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