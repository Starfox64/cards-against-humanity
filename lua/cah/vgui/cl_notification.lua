local PANEL = {}

function PANEL:Init()
	local SCREEN_Y = ScrH() / 1080

	self.text = "No Message..."
	self.iconMat = Material("cah/bell64.png")

	self:SetSize(self:GetWide(), SCREEN_Y * 50)
end

function PANEL:Paint( w, h )
	local triangle = {
		{x = 0, y = h / 2},
		{x = 10, y = h / 3},
		{x = 10, y = h / 1.5}
	}

	surface.DisableClipping(true)

	surface.SetDrawColor(Color(68, 142, 253))
	draw.NoTexture()
	surface.DrawPoly(triangle)
	surface.DrawRect(10, 0, 100, h)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(self.iconMat)
	surface.DrawTexturedRect(35, 0, h, h)

	surface.DrawRect(110, 0, w - 110, h)

	surface.SetFont("CAH_TitleFont")
	surface.SetTextColor(Color(68, 68, 68))
	surface.SetTextPos(130, 13)
	surface.DrawText(self.text)

	surface.DisableClipping(false)
end

function PANEL:GetWide()
	surface.SetFont("CAH_TitleFont")
	local textW, textH = surface.GetTextSize(self.text)

	return 150 + textW
end

function PANEL:SetText( text )
	self.text = text
	self:SetWide(self:GetWide())
end

function PANEL:SetIcon( icon )
	self.iconMat = Material(icon)
end

vgui.Register("CAH_Notification", PANEL, "DPanel")