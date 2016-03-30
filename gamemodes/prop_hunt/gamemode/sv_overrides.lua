function GM:PlayerSelectTeamSpawn( TeamID, ply )

	local SpawnPoints = team.GetSpawnPoints( TeamID )
	
	if ( !SpawnPoints || table.Count( SpawnPoints ) == 0 ) then return end
	
	local NumberOfSpawns = table.Count( SpawnPoints )
	local ChosenSpawnPoint = nil
	
	for i=0, NumberOfSpawns do

	
		local ChosenSpawnPoint = table.Random( SpawnPoints )
		if ( hook.Call( "IsSpawnpointSuitable", GAMEMODE, ply, ChosenSpawnPoint, i == NumberOfSpawns ) ) then
			return ChosenSpawnPoint
		end
	
	end
	
	return ChosenSpawnPoint

end

function GM:IsSpawnpointSuitable( ply, spawnpointent, bMakeSuitable )

	local Pos = spawnpointent:GetPos()
	
	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	-- (HL2DM kills everything within a 128 unit radius)
	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )
	
	if ( ply:Team() == TEAM_SPECTATOR || ply:Team() == TEAM_UNASSIGNED ) then return true end
	
	local Blockers = 0


	for k, v in pairs( Ents ) do
		if ( IsValid( v ) && v:GetClass() == "player" && v:Alive() ) then


			Blockers = Blockers + 1
			
			if ( bMakeSuitable ) then
				v:KillSilent()
				timer.Simple(2, function() v:Spawn() end )
				MsgAll( "Map needs more spawns!\n" )
			end
			
		end
	end
	

	if ( bMakeSuitable or Blockers < 1) then return true end
	return false

end

function GM:PlayerCanJoinTeam( ply, teamid )

	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
	if !ply.TeamChangeCount then
		ply.TeamChangeCount = 0
	end
	
	
	
	if ( ply:Team() == teamid ) then 
		ply:ChatPrint( "You're already on that team" )
		return false
	end
	
	if ( ply:IsAdmin() or ply:IsUserGroup("little_justice") or ply:IsUserGroup("justice") or ply:IsUserGroup("big_justice") ) then
		return true
	end
	
	if ( GAMEMODE:TeamHasEnoughPlayers( teamid ) ) then
		ply:ChatPrint( "That team is full!" )
		ply:SendLua("GAMEMODE:ShowTeam()")
		return false
	end
	
	if ( ply:Team() == TEAM_SPECTATOR || ply:Team() == TEAM_UNASSIGNED ) then
		if ply.TeamChangeCount > 0 then
			ply.TeamChangeCount = ply.TeamChangeCount + 1
			return true
		else
			ply.TeamChangeCount = 3
			return true
		end
	end
	if ( ply.TeamChangeCount > 0 ) then
		ply:ChatPrint( "You've already changed teams recently! Wait ".. ply.TeamChangeCount .. " more round(s) and try again.")
		return false
	end
--[[
	if ( ply.LastTeamSwitch && RealTime()-ply.LastTeamSwitch < TimeBetweenSwitches ) then
		ply.LastTeamSwitch = ply.LastTeamSwitch + 1;
		ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", (TimeBetweenSwitches - (RealTime()-ply.LastTeamSwitch)) + 1 ) )
		return false
	end
--]]
	
	ply.TeamChangeCount = 3
	
	return true
	
end

function GM:PlayerSpray( ply )

	return ply:Team() == TEAM_SPECTATOR
	--return false
	


end

function GM:ShowTeam( ply )

	if (!GAMEMODE.TeamBased) then return end
	ply:SendLua( "GAMEMODE:ShowTeam()" )

end

function GM:PlayerCanSeePlayersChat( strText, bTeamOnly, pListener, pSpeaker )
	
	if ( bTeamOnly ) then
		if ( !IsValid( pSpeaker ) || !IsValid( pListener ) ) then return false end
		
		if AdminGroups[pListener:GetUserGroup()] and pListener:GetInfoNum( "ph_team_chat", 0 ) == 1 then return true end
		if ( pListener:Team() != pSpeaker:Team() ) then return false end
	end
	
	return true
	
end

function GM:IsValidSpectatorTarget( ply, ent )

	if ( !IsValid( ent ) ) then return false end
	if ( ent == ply ) then return false end
	if ( !table.HasValue( GAMEMODE:GetValidSpectatorEntityNames( ply ), ent:GetClass() ) ) then return false end
	if ( ent:IsPlayer() && !ent:Alive() ) then return false end
	if ( ent:IsPlayer() && ent:IsObserver() ) then return false end
	
	--if ( (ply:Team() != TEAM_SPECTATOR) && (ent:IsPlayer() && GAMEMODE.CanOnlySpectateOwnTeam) && (ply:Team() != ent:Team()) && !ply.CanSpectateOwnTeam ) then return false end
	local timePlayed
	local SPECTIME = GAMEMODE.MinimumSpecTimeTeam and GAMEMODE.MinimumSpecTimeTeam * 60 or 0
	if type(FindMetaTable("Player").GetUTimeTotalTime) == "function" then
		timePlayed = ply:GetUTimeTotalTime()
	else
		timePlayed = SPECTIME + 1
	end
	
	if ply:Team() == TEAM_HUNTERS or timePlayed < SPECTIME then
		return ent:Team() == TEAM_HUNTERS
	else
		return ply:Team() == ent:Team() or (ply:Team() == TEAM_SPECTATOR && timePlayed >= SPECTIME)
	end
	--return true

end

function GM:GetValidSpectatorModes( ply )

	local SPECTIME = GAMEMODE.MinimumSpecTimeModes and GAMEMODE.MinimumSpecTimeModes * 60 or 0
	if type(FindMetaTable("Player").GetUTimeTotalTime) == "function" then
		if ply:GetUTimeTotalTime() >= SPECTIME then
			return GAMEMODE.ValidSpectatorModesExtra
		end
	else
		return GAMEMODE.ValidSpectatorModesExtra
	end
	
	return GAMEMODE.ValidSpectatorModes

end

-- Hacky workaround for spawning inside things. Uncomment to enable.
--[[
hook.Add("PlayerSpawn", "CheckSpawnPoint", 
	function(ply)
		timer.Simple(0.1, function()
			if !IsValid(ply) then return end
			if (ply:Team() == TEAM_PROPS or ply:Team() == TEAM_HUNTERS) and GAMEMODE:InRound() then
				local plyPos = ply:GetPos()
				local findEnts = ents.FindInBox( plyPos + Vector( -17, -17, -16 ), plyPos + Vector( 17, 17, 100 ) )
				local spawnPoints = team.GetSpawnPoints( ply:Team() )
				local found = false
				
				for k,v in pairs(findEnts) do
				
					for k2,v2 in pairs(spawnPoints) do
					
						if v == v2 then
							found = true
							break
						end	
						
					end
					if found then
						break
					end
				end
				
				if !found then
					ServerLog(ply:Nick() .. " spawned somewhere weird\n")
					ply:UnLock()
					timer.Simple(0, function() ply:Spawn() end )
				end
				
			end
		end )
	end )
	--]]