CAH.Cards = CAH.Cards or {}
CAH.Games = CAH.Games or {}
CAH.Ready = false

CAH.CardsURL = "https://raw.githubusercontent.com/Starfox64/cards-against-humanity/master/cah.json"

-- Status Enums --
CAH_IDLE = 0
CAH_DISCOVER = 1
CAH_ANSWER = 2
CAH_CHOOSE = 3


-- CAH Utils --
function CAH:LoadCards()
	http.Fetch(CAH.CardsURL,
		function( body, len, headers, code )
			local cards = body
			cards = util.JSONToTable(cards)

			if (cards) then
				self.Cards = {}

				for _, card in pairs(cards) do
					local text = string.Replace(card.text, "&trade;", "™")
					text = string.Replace(text, "&copy;", "©")
					text = string.Replace(text, "&reg;", "®")

					self.Cards[card.id] = {
						cardType = card.cardType,
						text = text,
						numAnswers = card.numAnswers,
						expansion = card.expansion
					}
					setmetatable(self.Cards[card.id], self.cardMeta)
				end

				MsgC(Color(25, 200, 25), "[CAH] Loaded "..table.Count(self.Cards).." cards.\n")
				self.Ready = true
			else
				MsgC(Color(200, 70, 70), "[CAH] Failed to load cards! (JSON Parsing Error)\n")
			end
		end,
		function( err )
			MsgC(Color(200, 70, 70), "[CAH] Failed to load cards! (http.Fetch: "..err..")\n")
		end
	)
end

function CAH:GetCard( id )
	return self.Cards[id]
end

function CAH:GetCards()
	return self.Cards
end

function CAH:GetGame( cahTable )
	if (type(cahTable) == "number") then
		return self.Games[cahTable]
	elseif (type(cahTable) == "Entity") then
		return self.Games[cahTable:EntIndex()]
	end
end

function CAH:GetGames()
	return self.Games
end


-- CAH Card Metatable --
CAH.cardMeta = {}
CAH.cardMeta.__index = CAH.cardMeta

function CAH.cardMeta:IsValid()
	return true
end

function CAH.cardMeta:IsQuestion()
	return self.cardType == "Q"
end

function CAH.cardMeta:IsAnswer()
	return self.cardType == "A"
end

function CAH.cardMeta:IsPick2()
	return self.numAnswers > 1
end

function CAH.cardMeta:GetText()
	return self.text
end

function CAH.cardMeta:GetExpansion()
	return self.expansion
end

function CAH.cardMeta:IsExpansion( expansion )
	return self.expansion == expansion
end


-- CAH Game Metatable --
CAH.gameMeta = {}
CAH.gameMeta.__index = CAH.gameMeta

function CAH.gameMeta:IsValid()
	return true
end

function CAH.gameMeta:GetStatus()
	return self.status
end

function CAH.gameMeta:GetTable()
	return Entity(self.table)
end

function CAH.gameMeta:GetPlayers()
	return self.players
end

function CAH.gameMeta:GetCzar()
	return self.czar
end

function CAH.gameMeta:GetBlackCard()
	return self.black
end

if (SERVER) then

	function CAH.gameMeta:RemovePlayer( client )
		table.RemoveByValue(self.players, client)
	end

	function CAH.gameMeta:AddPlayer( client )
		if (not client:CanJoinCAH(self)) then return end

		for k, seat in pairs(self:GetTable().seats) do
			if (not IsValid(seat:GetDriver())) then
				client:EnterVehicle(seat)
				self.players[k] = client

				client.CAH = {
					gameID = self.table,
					ap = 0,
					cards = {}
				}

				break
			end
		end

		self:GenerateCards()
		self:Send()
	end

	function CAH.gameMeta:GenerateCards()
		for seatID, client in pairs(self:GetPlayers()) do
			local missingCards = 5 - #client:GetCards()

			if (missingCards != 0) then
				for i=1, missingCards do
					local poolIndex = math.random(1, #self.wPool)
					table.insert(client.CAH.cards, self.wPool[poolIndex])
					table.remove(self.wPool, poolIndex)
				end
			end
		end
	end

	function CAH.gameMeta:SetCzar( czar )
		self.czar = czar
	end

	function CAH.gameMeta:Send( target )
		netstream.Start(target, "CAH_Game", self)

		local playerData = {}
		for k, client in pairs(self:GetPlayers()) do
			playerData[client] = client.CAH
		end
		netstream.Start(target, "CAH_Players", playerData)
	end

end


-- CAH Player Metatable --
CAH.playerMeta = FindMetaTable("Player")

function CAH.playerMeta:CanJoinCAH( cahGame )
	if (IsValid(cahGame)) then
		if (#cahGame:GetPlayers() < 4) then
			if (hook.Run("CanJoinCAH", self, cahGame) == false) then
				return false
			end

			return true
		end
	end

	return false
end

function CAH.playerMeta:HasCard( id )
	if not (self.CAH) then return false end
	return table.HasValue(self.CAH.cards, id)
end

function CAH.playerMeta:GetCards()
	if not (self.CAH) then return {} end
	return self.CAH.cards
end

function CAH.playerMeta:GetCAHPoints()
	if not (self.CAH) then return 0 end
	return self.CAH.ap
end

if (SERVER) then

	function CAH.playerMeta:SetCAHGame( cahGame )
		if (IsValid(cahGame)) then
			self.CAH.game = cahGame:GetID()
		end
	end

	function CAH.playerMeta:SetCAHPoints( points )
		if not (self.CAH) then return end
		self.CAH.ap = points
	end

	function CAH.playerMeta:AddCAHPoints( points )
		if not (self.CAH) then return end
		self.CAH.ap = self.CAH.ap + points
	end

end


if (not CAH.Ready) then
	if (SERVER) then
		CAH:LoadCards()
	else
		timer.Simple(1, function() -- Listen servers don't like calling http.Fetch on 2 realms at the same time.
			CAH:LoadCards()
		end)
	end
end

-- Card loading auto-retry --
CAH.nextTry = 0
hook.Add("Think", "CAH_LoadRetry", function()
	if (not CAH.Ready and CurTime() > CAH.nextTry) then
		CAH:LoadCards()
		CAH.nextTry = CAH.nextTry + 15
	end
end)