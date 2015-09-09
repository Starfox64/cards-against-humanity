CAH.Cards = CAH.Cards or {}
CAH.Games = CAH.Games or {}
CAH.CVAR = CAH.CVAR or {}
CAH.Config = CAH.Config or {}
CAH.expansions = CAH.expansions or {"Base"}
CAH.Ready = CAH.Ready or false

CAH.CardsURL = "https://raw.githubusercontent.com/Starfox64/cards-against-humanity/master/cah.json"
CAH.LatestReleaseURL = "https://api.github.com/repos/Starfox64/cards-against-humanity/releases/latest"
CAH.CurrentRelease = "0.0.0"

-- Status Enums --
CAH_IDLE = 0
CAH_DISCOVER = 1
CAH_ANSWER = 2
CAH_CHOOSE = 3
CAH_END = 4

-- Config Defaults --
CAH.Config.maxPoints = CAH.Config.maxPoints or 5
CAH.Config.startTime = CAH.Config.startTime or 20
CAH.Config.chooseTime = CAH.Config.chooseTime or 30
CAH.Config.expansions = CAH.Config.expansions or {Base = true}


-- CAH Utils --
function CAH:LoadCards()
	http.Fetch(CAH.CardsURL,
		function( body, len, headers, code )
			local cards = body
			cards = util.JSONToTable(cards)

			if (cards) then
				self.Cards = {}

				for _, card in pairs(cards) do
					if (card.numAnswers > 2) then continue end -- The game isn't compatible with 3 blanks black cards. (Soon™)

					local text = htmlentities.decode(card.text)

					self.Cards[card.id] = {
						cardType = card.cardType,
						text = text,
						numAnswers = card.numAnswers,
						expansion = card.expansion
					}
					setmetatable(self.Cards[card.id], self.cardMeta)

					if (not table.HasValue(self.expansions, card.expansion)) then
						table.insert(self.expansions, card.expansion)
					end
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

function CAH:CheckUpdate()
	http.Fetch(self.LatestReleaseURL,
		function( body, len, headers, code )
			local response = util.JSONToTable(body)

			if (response and response.tag_name) then
				if (response.tag_name == self.CurrentRelease) then
					MsgC(Color(25, 200, 25), "[CAH] You are using the latest version ("..self.CurrentRelease..").\n")
				else
					MsgC(Color(251, 184, 41), "\n[CAH] Warning: You are not using the latest version!\n")
					MsgC(Color(25, 200, 25), "[CAH] Latest: "..response.tag_name.."\n")
					MsgC(Color(200, 70, 70), "[CAH] Current: "..self.CurrentRelease.."\n")
					MsgC(Color(251, 184, 41), "[CAH] Update Title: "..response.name.."\n")
					MsgC(Color(251, 184, 41), "[CAH] Update Description:\n"..response.body.."\n\n")
					MsgC(Color(251, 184, 41), "[CAH] Download: "..response.html_url.."\n\n")
				end
			else
				MsgC(Color(200, 70, 70), "[CAH] Cannot check for updates, GitHub API response incorrect!\n")
			end
		end,
		function( err )
			MsgC(Color(200, 70, 70), "[CAH] Cannot check for updates, GitHub API unreachable! (http.Fetch: "..err..")\n")
		end
	)
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
	return IsValid(self:GetTable())
end

function CAH.gameMeta:GetStatus()
	return self.status
end

function CAH.gameMeta:GetTimeLeft()
	return self.endTime - CurTime()
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
		client:ExitVehicle()

		client.CAH = {
			gameID = 0,
			ap = 0,
			cards = {},
			selected = {}
		}

		self:Send(true)
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
					cards = {},
					selected = {}
				}

				break
			end
		end

		--self:GenerateCards()
		self:Send(true)
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

	function CAH.gameMeta:NewRound()
		self:SetStatus(CAH_DISCOVER)
		self:GenerateCards()
		local newCzar = self:FindNewCzar()

		local poolIndex = math.random(1, #self.bPool)
		self:SetBlackCard(self.bPool[poolIndex])
		table.remove(self.bPool, poolIndex)

		self:Send(true)

		for _, client in pairs(self:GetPlayer()) do
			CAH:Notify("A new round is starting, the Card Czar is "..newCzar:Name(), cahGame:GetPlayers())
		end
	end

	function CAH.gameMeta:SetTimeLeft( timeLeft )
		self.endTime = CurTime() + timeLeft
	end

	function CAH.gameMeta:SetCzar( czar )
		self.czar = czar
	end

	function CAH.gameMeta:FindNewCzar()
		local newCzar, nextIsCzar, reProcess

		for seatID, client in pairs(self:GetPlayers()) do
			if (client == self) then
				nextIsCzar = true

				if (seatID == 4) then
					reProcess = true
				end
			elseif (nextIsCzar) then
				newCzar = client
				break
			end
		end

		if (reProcess) then
			for _, client in pairs(self:GetPlayers()) do
				newCzar = client
			end
		end

		self:SetCzar(newCzar)

		return newCzar
	end

	function CAH.gameMeta:SetBlackCard( cardID )
		self.black = cardID
	end

	function CAH.gameMeta:SetStatus( status )
		self.status = status
	end

	function CAH.gameMeta:Send( sendPlayers, target )
		local clGame = table.Copy(self)
		clGame.wPool, clGame.bPool = nil, nil -- The client doesn't need the pools

		netstream.Start(target, "CAH_UpdateGameData", clGame)

		if (sendPlayers) then
			local playerData = {}
			for k, client in pairs(self:GetPlayers()) do
				playerData[client] = client.CAH
			end
			netstream.Start(target, "CAH_UpdatePlayerData", playerData)
		end
	end

else

	-- returns: flipped, shifted
	function CAH.gameMeta:ShouldDrawCard( cardID, owner )
		if (self:GetStatus() < CAH_CHOOSE and owner:IsSelectedCard(cardID)) then
			return true, true
		elseif (self:GetStatus() >= CAH_CHOOSE and owner:IsSelectedCard(cardID)) then
			return false, true
		elseif (not owner:IsSelectedCard(cardID) and owner == LocalPlayer()) then
			return false, false
		end

		return true, false
	end

end


-- CAH Player Metatable --
CAH.playerMeta = FindMetaTable("Player")

function CAH.playerMeta:CanJoinCAH( cahGame )
	if (IsValid(cahGame)) then
		if (#cahGame:GetPlayers() < 4) then
			if (cahGame:GetStatus() != CAH_IDLE) then
				CAH:Notify("This game already started.", self)
				return false
			end

			if (hook.Run("CanJoinCAH", self, cahGame) == false) then
				return false
			end

			return true
		end
		CAH:Notify("This table is full.", self)
	end

	return false
end

function CAH.playerMeta:HasCard( cardID )
	if not (self.CAH) then return false end
	return table.HasValue(self.CAH.cards, cardID)
end

function CAH.playerMeta:GetCards()
	if not (self.CAH) then return {} end
	return self.CAH.cards
end

function CAH.playerMeta:GetCAHPoints()
	if not (self.CAH) then return 0 end
	return self.CAH.ap
end

function CAH.playerMeta:IsSelectedCard( cardID )
	if not (self.CAH) then return end
	return self.CAH.selected[1] == cardID or self.CAH.selected[2] == cardID
end

function CAH.playerMeta:GetSelectedCards()
	if not (self.CAH) then return end
	return self.CAH.selected
end

function CAH.playerMeta:GetCAHGame()
	if not (self.CAH) then return end
	return CAH:GetGame(self.CAH.gameID)
end

if (SERVER) then

	function CAH.playerMeta:SetCAHGame( cahGame )
		if (IsValid(cahGame)) then
			self.CAH.game = cahGame:GetTable():EntIndex()
		end
	end

	function CAH.playerMeta:DrawCard( cardID )
		local cahGame = self:GetCAHGame()
		if (IsValid(cahGame)) then
			if (cahGame:GetStatus() == CAH_ANSWER) then
				local maxSelected = 1

				if (CAH:GetCard(cahGame:GetBlackCard()):IsPick2()) then
					maxSelected = 2
				end

				if (#self:GetSelectedCards() < maxSelected) then
					if (self:IsSelectedCard(cardID)) then
						self:SetSelectedCard(false)
					elseif (#self:GetSelectedCards() == 1) then
						self:SetSelectedCard(true, cardID)
					else
						self:SetSelectedCard(false, cardID)
					end

					local playerData = {}
					playerData[self] = self.CAH

					netstream.Start(nil, "CAH_UpdatePlayerData", playerData)
				else
					CAH:Notify("You have already played!", self)
				end
			else
				CAH:Notify("You may not draw a card right now.", self)
			end
		end
	end

	function CAH.playerMeta:ChooseCard( winner )
		local cahGame = self:GetCAHGame()
		if (IsValid(cahGame) and IsValid(winner) and winner:IsPlayer() and winner:GetCAHGame() == cahGame) then
			if (cahGame:GetStatus() == CAH_CHOOSE and cahGame:GetCzar() == self) then
				winner:AddCAHPoint(1)

				for _, client in pairs(cahGame:GetPlayers()) do
					for _, cardID in pairs(client:GetSelectedCards()) do
						table.RemoveByValue(client.CAH.cards, cardID)
					end

					client.CAH.selected = {}
				end

				CAH:Notify(winner:Name().." won this round!", "cah/award64.png", cahGame:GetPlayers())

				cahGame:GenerateCards()
				cahGame:SetStatus(CAH_END)
				cahGame:SetTimeLeft(5)
				cahGame:Send(true)
			else
				CAH:Notify("You may not choose a winning card now.", self)
			end
		end
	end

	function CAH.playerMeta:SetSelectedCard( isSecond, cardID )
		if not (self.CAH) then return end
		local index = isSecond and 2 or 1

		self.CAH.selected[index] = cardID
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

		-- Listen servers don't like calling http.Fetch on 2 realms at the same time so we add a delay.
		timer.Simple(1, function()
			CAH:CheckUpdate()
		end)
	else
		timer.Simple(1.5, function()
			CAH:CheckUpdate()
		end)
		timer.Simple(2, function()
			CAH:LoadCards()
		end)
	end
end

-- Card loading auto-retry --
CAH.nextTry = 0
hook.Add("Think", "CAH_LoadRetry", function()
	if (not CAH.Ready and CurTime() > CAH.nextTry) then
		CAH:LoadCards()
		CAH.nextTry = CurTime() + 15
	end
end)
