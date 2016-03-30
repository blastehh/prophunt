// Create new class
local CLASS = {}


// Some settings for the class
CLASS.DisplayName			= "Hunter"
CLASS.WalkSpeed 			= 230
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 230
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false
CLASS.JumpPower				= 200

// Called by spawn and sets loadout
function CLASS:Loadout(pl)
	if DEBUG then BroadcastMsg("Loadout") end
	pl:Give("weapon_crowbar")
	pl:GiveAmmo(64, "Buckshot")
	pl:GiveAmmo(255, "SMG1")
	pl:Give("weapon_shotgun")
	pl:Give("weapon_smg1")

	if GetConVar("WEAPONS_ALLOW_GRENADE"):GetBool() then
		pl:Give("weapon_frag")
	end
	
	local cl_defaultweapon = pl:GetInfo("cl_defaultweapon") 
 	 
 	if pl:HasWeapon(cl_defaultweapon) then 
 		pl:SelectWeapon(cl_defaultweapon)
 	end 

	
end


// Called when player spawns with this class
function CLASS:OnSpawn(pl)
	local unlock_time = math.Clamp(GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt() - (CurTime() - GetGlobalFloat("RoundStartTime", 0)), 0, GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt())
	if DEBUG then BroadcastMsg("OnSpawn") end
	if unlock_time > 2 then
		
		pl:Blind(true)
		timer.Create("unblind"..pl:SteamID(), unlock_time, 1, function()
			if IsValid(pl) then
				pl:Blind(false)
			end
		end)
		
		timer.Create("SpawnLock_"..pl:SteamID(),0.5,1, function()
			if IsValid(pl) then
				pl:Lock()
			end
		end)
		
		timer.Create("unlock"..pl:SteamID(), unlock_time, 1, function()
			if IsValid(pl) then
				pl:UnLock()
			end
		end)
		
	end

end


// Called when a player dies with this class
function CLASS:OnDeath(pl, attacker, dmginfo)
	if DEBUG then BroadcastMsg("OnDeath") end
	pl:CreateRagdoll()
	timer.Create("Ragdoll_"..pl:SteamID(),20,1,function()
		if !IsValid(pl) then return end
		if IsValid(pl:GetRagdollEntity()) then
			pl:GetRagdollEntity():Remove()
		end
	end)
	pl:UnLock()
end


// Register
player_class.Register("Hunter", CLASS)