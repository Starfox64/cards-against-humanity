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

hook.Add("PopulateToolMenu", "CAH_PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "CAH", "CAHClient", "Client", "", "", CAH.clientOptions)
end)