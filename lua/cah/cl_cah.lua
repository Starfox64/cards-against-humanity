CAH.markupBuffer = CAH.markupBuffer or {}

-- CAH ConVars --
CreateClientConVar("cah_playsound", 1, true)


-- CAH Constants --
local TABLE_WIDTH = 2528
local TABLE_HEIGHT = 944
local SCALE = 0.03125

local CARDS_ORIGIN = {
	{x = 1264, y = 670},
	{x = 1264, y = 670},
	{x = -100, y = 670},
	{x = -100, y = 670}
}

local handMat = Material("cah/hand64.png")
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

surface.CreateFont("CAH_PointsFont", {
	font = "League Gothic",
	size = 4002,
	weight = 10000,
	antialias = false
})


-- CAH Back sides --
local WHITE_FLIPPED = markup.Parse("<color=255,255,255><font=CAH_CardBackFont>Cards Against Humanity</font></color>", 180)
local BLACK_FLIPPED = markup.Parse("<color=0,0,0><font=CAH_CardBackFont>Cards Against Humanity</font></color>", 180)


-- CAH 3D2D Draw Hook --
hook.Add("PostDrawOpaqueRenderables", "CAH_PostDrawOpaqueRenderables", function()
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
				--[[surface.SetDrawColor(Color(255, 0, 0))
				surface.DrawLine(0, 0, 100, 0)
				surface.SetDrawColor(Color(0, 255, 0))
				surface.DrawLine(0, 0, 0, 100)]]

				-- Decks --
				for seatID, client in pairs(cahGame:GetPlayers()) do
					if (seatID == 2 or seatID == 4) then
						for cardKey, cardID in pairs(client:GetCards()) do
							local x, y = CARDS_ORIGIN[seatID].x + cardKey * 200, CARDS_ORIGIN[seatID].y
							CAH:DrawCard(cardID, x, y, client != ply, true)
						end
					end
				end

				-- Black Card --
				if (cahGame:GetBlackCard() and cursor.r == 180) then
					local flipped = cahGame:GetStatus() < CAH_DISCOVER
					CAH:DrawCard(cahGame:GetBlackCard(), 1164, 350, flipped, true)
				end
			cam.End3D2D()

			-- Main 3D2D Context --
			cam.Start3D2D(cahTable:LocalToWorld(cahTable.origin), angles, SCALE)
				--[[surface.SetDrawColor(Color(255, 0, 0))
				surface.DrawLine(0, 0, 100, 0)
				surface.SetDrawColor(Color(0, 255, 0))
				surface.DrawLine(0, 0, 0, 100)]]
				--draw.RoundedBox(0, 0, 0, TABLE_WIDTH, TABLE_HEIGHT, Color(255, 255, 255, 50))

				--[[surface.SetMaterial(Material("cah/exit256.png"))
				surface.SetDrawColor(Color(255, 255, 255, 255))
				surface.DrawTexturedRectRotated(1200, 400, 128, 128, 0)]]

				-- Decks --
				for seatID, client in pairs(cahGame:GetPlayers()) do
					if (seatID == 1 or seatID == 3) then
						for cardKey, cardID in pairs(client:GetCards()) do
							local x, y = CARDS_ORIGIN[seatID].x + cardKey * 200, CARDS_ORIGIN[seatID].y
							CAH:DrawCard(cardID, x, y, client != ply, false)
						end
					end
				end

				-- Black Card --
				if (cahGame:GetBlackCard() and cursor.r == 0) then
					local flipped = cahGame:GetStatus() < CAH_DISCOVER
					CAH:DrawCard(cahGame:GetBlackCard(), 1164, 350, flipped, false)
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
		end
	end
end)

-- CAH Cursor Position Generator --
function CAH:GetCursor( cahTable, angles )
	local ply = LocalPlayer()
	local chairID = ply:GetVehicle():GetNWInt("CAH_ChairID")
	local cursorData = {x = -1, y = -1, r = 0}

	if (ply:InVehicle() and chairID) then
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

-- CAH Cards Drawer --
function CAH:DrawCard( cardID, x, y, flipped, rotateText )
	local textColor = "0,0,0"
	local cardColor = color_white

	if (CAH:GetCard(cardID):IsQuestion()) then
		textColor = "255,255,255"
		cardColor = color_black
	end

	if (not self.markupBuffer[cardID]) then
		self.markupBuffer[cardID] = markup.Parse("<color="..textColor.."><font=CAH_CardFont>"..CAH:GetCard(cardID):GetText().."</font></color>", 180)
	end

	local currentMarkup = self.markupBuffer[cardID]
	if (flipped) then
		if (CAH:GetCard(cardID):IsQuestion()) then
			currentMarkup = WHITE_FLIPPED
		else
			currentMarkup = BLACK_FLIPPED
		end
	end

	draw.RoundedBox(8, x, y, 185, 256, cardColor)
	currentMarkup:Draw(x + 10, y + 10, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

function CAH:CursorInSquare( cursorData, x, y )
	-- body
end


-- CAH Netstream Hook --
netstream.Hook("CAH_Game", function( cahGame )
	setmetatable(cahGame, CAH.gameMeta)
	CAH:GetGames()[cahGame.table] = cahGame
end)

netstream.Hook("CAH_GameDel", function( gameIndex )
	CAH:GetGames()[gameIndex] = nil
end)

netstream.Hook("CAH_Players", function( playerData )
	for ply, data in pairs(playerData) do
		ply.CAH = data
	end
end)