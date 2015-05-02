AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "CAH Table"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Cards Against Humanity"

ENT.seatPos = {
	{pos = Vector(27, 15, 18), ang = Angle(0, 90, 0)},
	{pos = Vector(-27, -15, 18), ang = Angle(0, -90, 0)},
	{pos = Vector(27, -15, 18), ang = Angle(0, 90, 0)},
	{pos = Vector(-27, 15, 18), ang = Angle(0, -90, 0)}
}

ENT.origin = Vector(-14.85, -39.5, 34.25)
ENT.originR = Vector(14.85, 39.5, 34.25)

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_interiors/table_picnic.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:Wake()
		end

		self.seats = {}
		for k, seatPos in pairs(self.seatPos) do
			local seat = ents.Create("prop_vehicle_prisoner_pod")
			seat:SetModel("models/nova/airboat_seat.mdl")
			seat:SetKeyValue("vehiclescript" , "scripts/vehicles/prisoner_pod.txt")
			seat:SetKeyValue("limitview" , 0)
			seat.VehicleTable = list.Get("Vehicles")["airboat_seat"]
			seat:SetNWInt("CAH_ChairID", k)
			seat:SetPos(self:LocalToWorld(seatPos.pos))
			seat:SetAngles(self:LocalToWorldAngles(seatPos.ang))
			seat:Spawn()
			seat:SetNotSolid(true)
			seat:SetParent(self)
			seat:SetColor(Color(255,255,255, 0))
			seat:SetRenderMode(RENDERMODE_TRANSALPHA)
			seat:DeleteOnRemove(self)

			self.seats[k] = seat
		end

		CAH:AddTable(self)
	end

	function ENT:Use( activator, client )
		local cahGame = CAH:GetGame(self)

		if (IsValid(cahGame)) then
			if (client:CanJoinCAH(cahGame)) then
				cahGame:AddPlayer(client)
			end
		else
			-- Notify, error
		end
	end
end