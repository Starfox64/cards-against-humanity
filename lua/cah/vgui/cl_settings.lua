function CAH.clientOptions( panel )
	panel:ClearControls()

	panel:AddControl("CheckBox", {
		Label = "Play notification sound",
		Command = "cah_playsound"
	}):SetTooltip("Play a sound when a notification pops up?.")

	panel:AddControl("Slider", {
		Label = "Notification time:",
		Command = "cah_notiftime",
		Type = "Integer",
		Min = "5",
		Max = "30"
	}):SetTooltip("The amount of time in seconds notifications are displayed for.")

	panel:AddControl("Slider", {
		Label = "Card display time:",
		Command = "cah_cardtime",
		Type = "Integer",
		Min = "2",
		Max = "15"
	}):SetTooltip("The amount of time in seconds cards are displayed for when previewing them.")
end

function CAH.serverOptions( panel )
	panel:ClearControls()

	local maxPoints = panel:AddControl("Slider", {
		Label = "Max points:",
		Type = "Integer",
		Min = "1",
		Max = "20"
	})
	maxPoints:SetTooltip("The amount of AP required to win a game.")
	maxPoints:SetValue(CAH.Config.maxPoints)
	function maxPoints:OnValueChanged( value )
		CAH.Config.maxPoints = value
	end

	local startTime = panel:AddControl("Slider", {
		Label = "Start Time:",
		Type = "Integer",
		Min = "1",
		Max = "45"
	})
	startTime:SetTooltip("The amount of time it takes for a round to (re)start.")
	startTime:SetValue(CAH.Config.startTime)
	function startTime:OnValueChanged( value )
		CAH.Config.startTime = value
	end

	local chooseTime = panel:AddControl("Slider", {
		Label = "Choose Time:",
		Type = "Integer",
		Min = "10",
		Max = "60"
	})
	chooseTime:SetTooltip("The amount of time players have to choose a card.")
	chooseTime:SetValue(CAH.Config.chooseTime)
	function chooseTime:OnValueChanged( value )
		CAH.Config.chooseTime = value
	end

	panel:AddControl("Header", {
		Description = "Right Click to toggle an expansion."
	})

	local expansions = panel:AddControl("DListView", {})
	expansions:SetMultiSelect(false)
	expansions:AddColumn("Name")
	expansions:AddColumn("Enabled")
	expansions:SetTall(ScrH() * 5 / 10)

	for _, expansion in pairs(CAH.expansions) do
		local line = expansions:AddLine(expansion, CAH.Config.expansions[expansion] and "Yes" or "No")
		line.enabled = CAH.Config.expansions[expansion] and true or false

		function line:OnRightClick()
			self.enabled = not self.enabled
			self:SetColumnText(2, self.enabled and "Yes" or "No")
			CAH.Config.expansions[self:GetColumnText(1)] = self.enabled
		end
	end

	local refresh = panel:AddControl("Button", {
		Label = "Refresh Config"
	})

	function refresh:DoClick()
		if (LocalPlayer():IsSuperAdmin()) then
			self:GetParent():GetParent():AddControl("Header", {Description = "Refreshing Config..."})
			netstream.Start("CAH_RefreshConfig")
		else
			self:GetParent():GetParent():AddControl("Header", {Description = "You need to be a super admin to use this feature!"})
		end

		self:SetDisabled(true)
	end

	local save = panel:AddControl("Button", {
		Label = "Save Config"
	})

	function save:DoClick()
		if (LocalPlayer():IsSuperAdmin()) then
			self:GetParent():GetParent():AddControl("Header", {Description = "Saving Config..."})
			netstream.Start("CAH_SaveConfig", CAH.Config)
		else
			self:GetParent():GetParent():AddControl("Header", {Description = "You need to be a super admin to use this feature!"})
		end

		self:SetDisabled(true)
	end
end

hook.Add("PopulateToolMenu", "CAH_PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "CAH", "CAHClient", "Client", "", "", CAH.clientOptions)
	spawnmenu.AddToolMenuOption("Options", "CAH", "CAHServer", "Server", "", "", CAH.serverOptions)
end)

netstream.Hook("CAH_RefreshConfig", function( config )
	CAH.Config = config
	CAH.serverOptions(controlpanel.Get("CAHServer"))
end)