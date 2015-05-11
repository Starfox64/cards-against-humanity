local PANEL = {}

function PANEL:Init()
	self:SetFont("CAH_TitleFont")
	self:SetText("DBText")
	self:SetTextColor(color_white)
end

function PANEL:Paint( w, h )
	local color = Color(68, 142, 253)
	if (self.hover) then
		color = Color(38, 112, 223)
	end

	surface.SetDrawColor(color)
	surface.DrawRect(0, 0, w, h)
end

function PANEL:OnCursorEntered()
	self.hover = true
end

function PANEL:OnCursorExited()
	self.hover = false
end

vgui.Register("CAH_Button", PANEL, "DButton")