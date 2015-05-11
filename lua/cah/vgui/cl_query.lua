local PANEL = {}

function PANEL:Init()
	local SCREEN_X, SCREEN_Y = ScrW() / 1920, ScrH() / 1080

	self.title = "DQueryTitle"
	self.text = "DQueryText"
	self.iconMat = Material("cah/bell64.png")
	self.funcY = function() end
	self.funcN = function() end

	self:SetSize(self:GetWide(), SCREEN_Y * 150)
	self:Center()

	self.panel = vgui.Create("DPanel", self)
	self.panel:SetTall(SCREEN_Y * 40)
	self.panel:SetDrawBackground(false)

	self.yesBtn = vgui.Create("CAH_Button", self.panel)
	self.yesBtn:SetText("Yes")
	self.yesBtn.DoClick = function()
		self:Remove()
		self.funcY()
	end
	self.yesBtn:SetPos(SCREEN_X * 20, SCREEN_Y * 5)

	self.noBtn = vgui.Create("CAH_Button", self.panel)
	self.noBtn:SetText("No")
	self.noBtn.DoClick = function()
		self:Remove()
		self.funcN()
	end
	self.noBtn:SetPos(SCREEN_X * 40 + self.yesBtn:GetWide(), SCREEN_Y * 5)

	self.panel:SetWide(SCREEN_X * 60 + self.yesBtn:GetWide() + self.noBtn:GetWide())
	self.panel:CenterHorizontal()
	self.panel:AlignBottom(SCREEN_Y * 10)

	self:MakePopup()
end

function PANEL:Paint( w, h )
	local SCREEN_X, SCREEN_Y = ScrW() / 1920, ScrH() / 1080

	local triangle = {
		{x = 0, y = SCREEN_Y * 50 / 2},
		{x = 10, y = SCREEN_Y * 50 / 3},
		{x = 10, y = SCREEN_Y * 50 / 1.5}
	}

	surface.SetDrawColor(Color(68, 142, 253))
	surface.DrawPoly(triangle)
	surface.DrawRect(10, 0, 100, 50)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(self.iconMat)
	surface.DrawTexturedRect(35, 0, 50, 50)

	surface.DrawRect(110, 0, w - 110, 50)

	surface.SetFont("CAH_TitleFont")
	surface.SetTextColor(Color(68, 68, 68))
	surface.SetTextPos(130, 13)
	surface.DrawText(self.title)

	surface.SetDrawColor(color_white)
	surface.DrawRect(10, 50, w - 10, h - 50)

	surface.SetFont("CAH_TextFont")
	surface.SetTextColor(Color(68, 68, 68))
	surface.SetTextPos(20, 58)
	surface.DrawText(self.text)
end

function PANEL:GetWide()
	local SCREEN_Y = ScrH() / 1080
	local w, offset

	surface.SetFont("CAH_TitleFont")
	local titleW, titleH = surface.GetTextSize(self.title)

	surface.SetFont("CAH_TextFont")
	local textW, textH = surface.GetTextSize(self.text)

	if (textW > titleW) then
		w, offset = textW, 30
	else
		w, offset = titleW, 150
	end

	return offset + w
end

function PANEL:SetTitle( title )
	self.title = title
	self:SetWide(self:GetWide())
	self.panel:CenterHorizontal()
end

function PANEL:SetText( text )
	self.text = text
	self:SetWide(self:GetWide())
	self.panel:CenterHorizontal()
end

function PANEL:SetIcon( icon )
	self.iconMat = Material(icon)
end

function PANEL:SetFunctions( funcY, funcN )
	self.funcY = funcY or function() end
	self.funcN = funcN or function() end
end

vgui.Register("CAH_Query", PANEL, "DPanel")