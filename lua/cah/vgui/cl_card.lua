local PANEL = {}

function PANEL:Init()
	self.cardID = 1
end

function PANEL:Paint( w, h )
	CAH:DrawCard(self.cardID, 0, 0, self.flipped)
end

function PANEL:SetCard( cardID, flipped )
	self.cardID = cardID
	self.flipped = flipped
end

vgui.Register("CAH_Card", PANEL, "DPanel")