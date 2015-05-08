CAH.markupBuffer = CAH.markupBuffer or {}
CAH.clickPos = CAH.clickPos or {}
CAH.canClick = CAH.canClick or true
CAH.notifications = CAH.notifications or {}

-- CAH ConVars --
CAH.CVAR.playsound = CreateClientConVar("cah_playsound", 1, true)
CAH.CVAR.notiftime = CreateClientConVar("cah_notiftime", 10, true)
CAH.CVAR.cardtime = CreateClientConVar("cah_cardtime", 5, true)


-- CAH Constants --
local TABLE_WIDTH = 2528
local TABLE_HEIGHT = 944
local SCALE = 0.03125

local CARD_WIDTH = 185
local CARD_HEIGHT = 256

local CARDS_ORIGIN = {
	{x = 1264, y = 670},
	{x = 1264, y = 670},
	{x = -100, y = 670},
	{x = -100, y = 670}
}

local EXIT_ORIGIN = {
	{x = 1280, y = 800},
	{x = 1280, y = 160},
	{x = 1280, y = 800},
	{x = 1280, y = 160}
}

local handMat = Material("cah/hand64.png")
local circleMat = Material("cah/circle64.png")
local exitMat = Material("cah/exit256.png")
local cursorColor = Color(220, 220, 220, 255)

CAH.playerColors = {
	Color(249, 56, 38),
	Color(253, 119, 41),
	Color(138, 208, 69),
	Color(13, 155, 190)
}


-- Fonts --
surface.CreateFont("CAH_CardFont", {
	font = "Helvetica-Neue-Bold",
	size = 22,
	weight = 1000,
	antialias = false
})

surface.CreateFont("CAH_CardBackFont", {
	font = "Helvetica-Neue-Bold",
	size = 32,
	weight = 1000,
	antialias = false
})

surface.CreateFont("CAH_NotificationFont", {
	font = "Lato",
	size = 22,
	weight = 500,
	antialias = true
})


-- CAH Back sides --
local WHITE_FLIPPED = markup.Parse("<color=255,255,255><font=CAH_CardBackFont>Cards Against Humanity</font></color>", 180)
local BLACK_FLIPPED = markup.Parse("<color=0,0,0><font=CAH_CardBackFont>Cards Against Humanity</font></color>", 180)


-- CAH 3D2D Draw Hook --
hook.Add("PostDrawOpaqueRenderables", "CAH_PostDrawOpaqueRenderables", function()
	CAH.clickPos = {}

	for k, cahGame in pairs(CAH:GetGames()) do
		local cahTable = cahGame:GetTable()
		local ply = LocalPlayer()

		if (IsValid(cahTable) and cahTable:GetPos():DistToSqr(ply:GetPos()) < 40000) then
			local angles = cahTable:GetAngles()
			angles:RotateAroundAxis(angles:Up(), 90)

			local cursor = CAH:GetCursor(cahTable, angles)

			-- Reversed 3D2D Context --
			local anglesR = cahTable:GetAngles()
			anglesR:RotateAroundAxis(anglesR:Up(), -90)
			cam.Start3D2D(cahTable:LocalToWorld(cahTable.originR), anglesR, SCALE)
				-- Decks --
				for seatID, client in pairs(cahGame:GetPlayers()) do
					if (seatID == 2 or seatID == 4) then
						for cardKey, cardID in pairs(client:GetCards()) do
							local x, y = CARDS_ORIGIN[seatID].x + cardKey * 200, CARDS_ORIGIN[seatID].y
							local flipped, shifted = cahGame:ShouldDrawCard(cardID, client)

							if (shifted) then
								y = y - 270
							end

							CAH:DrawCard(cardID, x, y, flipped)

							-- "TABLE_WIDTH - x - CARD_WIDTH, TABLE_HEIGHT - y - CARD_HEIGHT" is to convert the Reversed 3D2D position to the Main 3D2D position.
							if (client == ply) then
								CAH:AddClickPos(TABLE_WIDTH - x - CARD_WIDTH, TABLE_HEIGHT - y - CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT, IN_ATTACK, "draw", cardID)
							end
							CAH:AddClickPos(TABLE_WIDTH - x - CARD_WIDTH, TABLE_HEIGHT - y - CARD_HEIGHT, CARD_WIDTH, CARD_HEIGHT, IN_ATTACK2, "preview", {cardID = cardID, flipped = flipped})
						end
					end
				end

				-- Black Card --
				if (cahGame:GetBlackCard() and cursor.r == 180) then
					local flipped = cahGame:GetStatus() < CAH_DISCOVER
					CAH:DrawCard(cahGame:GetBlackCard(), 1164, 350, flipped)
				end
			cam.End3D2D()

			-- Main 3D2D Context --
			cam.Start3D2D(cahTable:LocalToWorld(cahTable.origin), angles, SCALE)
				--draw.RoundedBox(0, 0, 0, TABLE_WIDTH, TABLE_HEIGHT, Color(255, 255, 255, 50))

				-- Decks --
				for seatID, client in pairs(cahGame:GetPlayers()) do
					if (seatID == 1 or seatID == 3) then
						for cardKey, cardID in pairs(client:GetCards()) do
							local x, y = CARDS_ORIGIN[seatID].x + cardKey * 200, CARDS_ORIGIN[seatID].y
							local flipped, shifted = cahGame:ShouldDrawCard(cardID, client)

							if (shifted) then
								y = y - 270
							end

							CAH:DrawCard(cardID, x, y, flipped)

							if (client == ply) then
								CAH:AddClickPos(x, y, CARD_WIDTH, CARD_HEIGHT, IN_ATTACK, "draw", cardID)
							end
							CAH:AddClickPos(x, y, CARD_WIDTH, CARD_HEIGHT, IN_ATTACK2, "preview", {cardID = cardID, flipped = flipped})
						end
					end

					if (client == ply) then
						surface.SetMaterial(exitMat)
						surface.SetDrawColor(Color(35, 31, 32, 255))
						surface.DrawTexturedRectRotated(EXIT_ORIGIN[seatID].x, EXIT_ORIGIN[seatID].y, 200, 200, cursor.r)

						CAH:AddClickPos(EXIT_ORIGIN[seatID].x - 100, EXIT_ORIGIN[seatID].y - 100, 200, 200, IN_ATTACK, "quit")
					end
				end

				-- Black Card --
				if (cahGame:GetBlackCard() and cursor.r == 0) then
					local flipped = cahGame:GetStatus() < CAH_DISCOVER
					CAH:DrawCard(cahGame:GetBlackCard(), 1164, 350, flipped)
					CAH:AddClickPos(1164, 350, CARD_WIDTH, CARD_HEIGHT, IN_ATTACK2, "preview", {cardID = cahGame:GetBlackCard(), flipped = flipped})
				end

				-- Cursor --
				if (cursor.x != -1 and cursor.y != -1) then
					local offX, offY = 9, 25

					if (cursor.r == 180) then
						offX, offY = -9, -25
					end

					surface.SetMaterial(handMat)
					surface.SetDrawColor(cursorColor)
					surface.DrawTexturedRectRotated(cursor.x + offX, cursor.y + offY, 64, 64, cursor.r)
				end
			cam.End3D2D()

			CAH:CheckClickPos(cursor)
		end
	end
end)

-- CAH Cursor Position Generator --
function CAH:GetCursor( cahTable, angles )
	local ply = LocalPlayer()
	local cursorData = {x = -1, y = -1, r = 0}

	if (ply:InVehicle() and ply:GetVehicle():GetNWInt("CAH_ChairID")) then
		local chairID = ply:GetVehicle():GetNWInt("CAH_ChairID")
		local hitPos = util.IntersectRayWithPlane(ply:EyePos(), gui.ScreenToVector(ScrW()/2, ScrH()/2), cahTable:LocalToWorld(cahTable.origin), angles:Up())

		if (chairID == 2 or chairID == 4) then
			cursorData.r = 180
		end

		if (hitPos) then
			local offset = hitPos - cahTable:LocalToWorld(cahTable.origin)
			offset:Rotate(Angle(-angles.p, -angles.y, -angles.r))

			cursorData.x, cursorData.y = offset.x * (1 / SCALE), -(offset.y * (1 / SCALE))
		end

		if (cursorData.x >= TABLE_WIDTH or cursorData.x <= 0 or cursorData.y >= TABLE_HEIGHT or cursorData.y <= 0) then
			cursorData.x, cursorData.y = -1, -1
		end
	end

	return cursorData
end

-- Draws a card using the cardID
function CAH:DrawCard( cardID, x, y, flipped )
	local card = CAH:GetCard(cardID)
	local textColor = "0,0,0"
	local cardColor = color_white

	if (card:IsQuestion()) then
		textColor = "255,255,255"
		cardColor = color_black
	end

	if (not self.markupBuffer[cardID]) then
		self.markupBuffer[cardID] = markup.Parse("<color="..textColor.."><font=CAH_CardFont>"..card:GetText().."</font></color>", 180)
	end

	local currentMarkup = self.markupBuffer[cardID]
	if (flipped) then
		if (card:IsQuestion()) then
			currentMarkup = WHITE_FLIPPED
		else
			currentMarkup = BLACK_FLIPPED
		end
	end

	draw.RoundedBox(8, x, y, CARD_WIDTH, CARD_HEIGHT, cardColor)
	currentMarkup:Draw(x + 10, y + 10, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	if (card:IsPick2() and not flipped) then
		surface.SetMaterial(circleMat)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(x + 140, y + 210, 32, 32)

		draw.SimpleText("PICK", "CAH_CardBackFont", x + 100, y + 225, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("2", "CAH_CardBackFont", x + 155, y + 225, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

-- Adds a clickable square to the current table.
function CAH:AddClickPos( x, y, w, h, key, action, arg )
	local clickPosData = {
		x = x,
		y = y,
		w = w,
		h = h,
		key = key,
		action = action,
		arg = arg
	}

	table.insert(self.clickPos, clickPosData)
end

-- Checks if the cursor is within a clickable square while M1/2 are down.
function CAH:CheckClickPos( cursor )
	if (LocalPlayer():KeyDown(IN_ATTACK) or LocalPlayer():KeyDown(IN_ATTACK2)) then
		if (CAH.canClick) then
			for k, clickPos in ipairs(CAH.clickPos) do
				if (LocalPlayer():KeyDown(clickPos.key)) then
					if (cursor.x >= clickPos.x and cursor.y >= clickPos.y and cursor.x <= clickPos.x + clickPos.w and cursor.y <= clickPos.y + clickPos.h) then
						if (clickPos.action == "draw") then
							netstream.Start("CAH_DrawCard", clickPos.arg)
						elseif (clickPos.action == "choose") then
							netstream.Start("CAH_ChooseCard", clickPos.arg)
						elseif (clickPos.action == "quit") then
							CAH:DermaQuery("Confirmation...", "Are you already sick of being a horrible person?", function()
								netstream.Start("CAH_Quit")
							end)
						elseif (clickPos.action == "preview") then
							self:PreviewCard(clickPos.arg.cardID, clickPos.arg.flipped)
						end
					end
				end
			end
		end

		CAH.canClick = false
	else
		CAH.canClick = true
	end
end

-- Draws and animates CAH notifications.
function CAH:Notify( message, icon, noSound )
	icon = icon or "cah/bell64.png"

	local SCREEN_X, SCREEN_Y = ScrW() / 1920, ScrH() / 1080

	local panel = vgui.Create("CAH_Notification")
	panel:SetAlpha(0)
	panel:SetText(message)
	panel:SetIcon(icon)
	panel:SetPos(-panel:GetWide() - 10, SCREEN_Y * 25)

	panel:MoveTo(SCREEN_X * 25, SCREEN_Y * 25, 0.5, 0.45, 5)
	panel:AlphaTo(255, 0.5, 0.5)

	panel:AlphaTo(0, 1, 0.5 + self.CVAR.notiftime:GetInt(), function( animData, panel )
		table.RemoveByValue(self.notifications, panel)
		panel:Remove()
	end)

	for k, notif in pairs(self.notifications) do
		local x = (#self.notifications + 1 - k) * SCREEN_Y * 70 + SCREEN_Y * 25
		notif:MoveTo(SCREEN_X * 25, x, 0.4, 0, 10)
	end

	table.insert(self.notifications, panel)

	MsgC(Color(68, 142, 253), "[CAH] "..message.."\n")

	if (not noSound and self.CVAR.playsound:GetBool()) then
		timer.Simple(0.45, function()
			surface.PlaySound("cah/notification.wav")
		end)
	end
end

-- Draws and animates a preview card on the HUD.
function CAH:PreviewCard( cardID, flipped )
	local SCREEN_X, SCREEN_Y = ScrW() / 1920, ScrH() / 1080

	local function newCard()
		CAH.previewCard = vgui.Create("CAH_Card")
		CAH.previewCard:SetAlpha(0)
		CAH.previewCard:SetCard(cardID, flipped)
		CAH.previewCard:SetSize(CARD_WIDTH, CARD_HEIGHT)
		CAH.previewCard:SetPos(SCREEN_X * 1500, SCREEN_Y * 1090)

		CAH.previewCard:MoveTo(SCREEN_X * 1500, SCREEN_Y * 1090 - CAH.previewCard:GetTall(), 0.3, 0, 5)
		CAH.previewCard:AlphaTo(255, 0.3)

		CAH.previewCard:AlphaTo(0, 1, 0.3 + self.CVAR.cardtime:GetInt(), function( animData, panel )
			panel:Remove()
		end)
	end

	if (IsValid(CAH.previewCard)) then
		CAH.previewCard:AlphaTo(0, 0.3, 0, function( animData, panel )
			panel:Remove()
			newCard()
		end)
	else
		newCard()
	end
end


-- CAH Netstream Hooks --
netstream.Hook("CAH_UpdateGameData", function( cahGame )
	setmetatable(cahGame, CAH.gameMeta)
	CAH:GetGames()[cahGame.table] = cahGame
end)

netstream.Hook("CAH_UpdatePlayerData", function( playerData )
	for ply, data in pairs(playerData) do
		ply.CAH = data
	end
end)

netstream.Hook("CAH_Notification", function( data )
	CAH:Notify(data.m, data.i, data.ns)
end)