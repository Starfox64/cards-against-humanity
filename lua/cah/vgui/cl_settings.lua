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

	panel:AddControl("Slider", {
		Label = "Max points:",
		Type = "Integer",
		Min = "1",
		Max = "20"
	}):SetTooltip("The amount of AP required to win a game.")

	panel:AddControl("Slider", {
		Label = "Start Time:",
		Type = "Integer",
		Min = "1",
		Max = "45"
	}):SetTooltip("The amount of time it takes for a round to (re)start.")

	panel:AddControl("Slider", {
		Label = "Choose Time:",
		Type = "Integer",
		Min = "10",
		Max = "60"
	}):SetTooltip("The amount of time players have to choose a card.")

	local expansions = panel:AddControl("DListView", {})
	expansions:SetMultiSelect(false)
	expansions:AddColumn("Name")
	expansions:AddColumn("Enabled")
	expansions:SetTall(ScrH() * 5 / 10)

	for _, expansion in pairs(CAH.expansions) do
		expansions:AddLine(expansion, tostring(CAH.Config.expansions[expansion]))
	end

	panel:AddControl("Button", {
		Label = "Refresh Config"
	})

	panel:AddControl("Button", {
		Label = "Save Config"
	})
end

function CAH.setupOptionsControl( name, panel )
	-- body
end

hook.Add("PopulateToolMenu", "CAH_PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "CAH", "CAHClient", "Client", "", "", CAH.clientOptions)
	spawnmenu.AddToolMenuOption("Options", "CAH", "CAHServer", "Server", "", "", CAH.serverOptions)
end)