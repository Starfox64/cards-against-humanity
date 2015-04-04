CAH.Cards = CAH.Cards or {}
CAH.Games = CAH.Games or {}

CAH.CardsURL = "https://raw.githubusercontent.com/Starfox64/cards-against-humanity/master/cah.json"

--[[
	Purpose: Loads the cards from the mighty internet into the CAH.Cards table.
]]--
function CAH:LoadCards()
	http.Fetch(CAH.CardsURL,
		function( body, len, headers, code )
			local cards = body
			cards = util.JSONToTable(cards)

			if (cards) then
				self.Cards = {}

				for _, card in pairs(cards) do
					self.Cards[card.id] = {
						cardType = card.cardType,
						text = card.text,
						numAnswers = card.numAnswers,
						expansion = card.expansion
					}
					setmetatable(self.Cards[card.id], self.cardMeta)
				end

				MsgC(Color(25, 200, 25), "[CAH] Loaded "..table.Count(self.Cards).." cards.\n")
			else
				MsgC(Color(200, 70, 70), "[CAH] Failed to load cards! (JSON Error)\n")
			end
		end,
		function( err )
			MsgC(Color(200, 70, 70), "[CAH] Failed to load cards! (http.Fetch: "..err..")\n")
		end
	)
end

CAH:LoadCards()


-- CAH Cards Metatable --
CAH.cardMeta = {}
CAH.cardMeta.__index = CAH.cardMeta

--[[
	Purpose: Returns true if a card is a question.
]]--
function CAH.cardMeta:IsQuestion()
	return self.cardType == "Q"
end

--[[
	Purpose: Returns true if a card is an answer.
]]--
function CAH.cardMeta:IsAnswer()
	return self.cardType == "A"
end

--[[
	Purpose: Returns true is a card is a 'Pick 2'.
]]--
function CAH.cardMeta:IsPick2()
	return self.numAnswers > 1
end

--[[
	Purpose: Returns the text of the card.
]]--
function CAH.cardMeta:GetText()
	return self.text
end

--[[
	Purpose: Returns the expansion pack of the card.
]]--
function CAH.cardMeta:GetExpansion()
	return self.expansion
end

--[[
	Purpose: Returns true if the card is from the specified expansion pack.
]]--
function CAH.cardMeta:IsExpansion( expansion )
	return self.expansion == expansion
end


function CAH:GetCard( id )
	return self.Cards[id]
end