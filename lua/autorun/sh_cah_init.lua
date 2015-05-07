CAH = {}

MsgC(Color(251, 184, 41), "[CAH] Initializing Cards Against Humanity...\n")

if (SERVER) then
	AddCSLuaFile("cah/cl_cah.lua")
	AddCSLuaFile("cah/sh_cah.lua")

	AddCSLuaFile("cah/vgui/cl_notification.lua")
	AddCSLuaFile("cah/vgui/cl_card.lua")
	AddCSLuaFile("cah/vgui/cl_settings.lua")

	AddCSLuaFile("external/von.lua")
	AddCSLuaFile("external/netstream.lua")

	include("external/von.lua")
	include("external/netstream.lua")

	include("cah/sv_hooks.lua")
	include("cah/sh_cah.lua")
	include("cah/sv_cah.lua")
else
	include("external/von.lua")
	include("external/netstream.lua")

	include("cah/sh_cah.lua")
	include("cah/cl_cah.lua")

	include("cah/vgui/cl_notification.lua")
	include("cah/vgui/cl_card.lua")
	include("cah/vgui/cl_settings.lua")
end

MsgC(Color(251, 184, 41), "[CAH] Cards Against Humanity Initialized!\n")