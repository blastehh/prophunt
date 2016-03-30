// Send required files to client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


// Include needed files
include("shared.lua")

// Called when the entity initializes
function ENT:Initialize()
	--self:SetModel("models/player/Kleiner.mdl")
	self:SetModel("models/player/hostage/hostage_03.mdl")
	self.health = 100
end 

// Called when we take damge
function ENT:OnTakeDamage(dmg)
end 