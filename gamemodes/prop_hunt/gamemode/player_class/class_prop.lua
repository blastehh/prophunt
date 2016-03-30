// Create new class
local CLASS = {}


// Some settings for the class
CLASS.DisplayName			= "Prop"
CLASS.WalkSpeed 			= 250
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 250
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false
CLASS.JumpPower				= 240

// Called by spawn and sets loadout
function CLASS:Loadout(pl)
	// Props don't get anything
end


// Called when player spawns with this class
function CLASS:OnSpawn(pl)
	pl:SetColor( Color(255, 255, 255, 0))
	
	pl.ph_prop = ents.Create("ph_prop")
	pl.ph_prop:SetPos(pl:GetPos())
	pl.ph_prop:SetSolid(SOLID_BBOX)
	pl.ph_prop:SetOwner(pl)
	pl.ph_prop.max_health = 100	
	pl.ph_prop:Spawn()
end


// Called when a player dies with this class
function CLASS:OnDeath(pl, attacker, dmginfo)
	pl:RemoveProp()
	
	timer.Create("Ragdoll_"..pl:SteamID(),5,1,function()
		if !IsValid(pl) then return end
		if IsValid(pl:GetRagdollEntity()) then
			pl:GetRagdollEntity():Remove()
		end
	end)
	
end


// Register
player_class.Register("Prop", CLASS)