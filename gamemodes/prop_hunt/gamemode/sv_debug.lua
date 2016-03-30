-- Debug setting
CreateConVar( "ph_debug", "0", FCVAR_REPLICATED)
DEBUG = GetConVarNumber("ph_debug") > 0
SetGlobalInt("DEBUG",GetConVarNumber("ph_debug"))

util.AddNetworkString("DebugCheck")

local function ChangeDebugMode()
	SetGlobalInt("DEBUG", GetConVarNumber("ph_debug"))
	DEBUG = GetConVarNumber("ph_debug") > 0
	PointsForKill = !DEBUG
	PointsForTaunt = !DEBUG
	if DEBUG then
		
		GAME_TIME = 99999
		ROUNDS_PER_MAP = 9999
		ROUND_TIME = 999999
		SWAP_TEAMS_EVERY_ROUND = 0
		RunConsoleCommand("HUNTER_BLINDLOCK_TIME", "6")
		
	else
	
		GAME_TIME = 40
		ROUNDS_PER_MAP = 12
		ROUND_TIME = 300
		SWAP_TEAMS_EVERY_ROUND = 1
		RunConsoleCommand("HUNTER_BLINDLOCK_TIME", "40")
		
	end
	
	GAMEMODE.RoundLimit = ROUNDS_PER_MAP
	GAMEMODE.RoundLength = ROUND_TIME
	GAMEMODE.GameLength = GAME_TIME
end

function DebugChanged()
	ChangeDebugMode()
	net.Start("DebugCheck")
		net.WriteBit(DEBUG)
	net.Broadcast()
end
cvars.AddChangeCallback("ph_debug", DebugChanged)

hook.Add("PlayerInitialSpawn","DebugState", function(ply)
	net.Start("DebugCheck")
		net.WriteBit(GetConVarNumber("ph_debug") > 0)
	net.Send(ply)
end)

hook.Add("InitPostEntity","UpdateConVars",function()
	timer.Create("InitialDebugCheck", 1, 1, function()
		ChangeDebugMode()
	end)
end)

function GameDebugMode(ply)
	if ( DEBUG ) then
		ply:PlayerMsg("Default speed x: "..ply.RTDSpeed)
		ply:PlayerMsg("Default speed: "..ply.NormSpeed)
		ply:PlayerMsg("Current speed: "..ply:GetRunSpeed())
		ply:PlayerMsg("Default jump power: "..ply.NormJumpPower)
		ply:PlayerMsg("Current jump power: "..ply:GetJumpPower())
		if ( !IsTableOfEntitiesValid( TableOfSpawns ) ) then
			TableOfSpawns = nil
			TableOfSpawnsIPS = nil
			TableOfSpawnsIPD = nil
			TableOfSpawnsIPR = nil
			TableOfSpawnsCT = nil
			TableOfSpawnsT = nil
			TableOfSpawnsIPC = nil
			
			print("Table not valid, ADDING!")
			TableOfSpawnsIPS = ents.FindByClass( "info_player_start" )
			TableOfSpawns = table.Add( TableOfSpawns, TableOfSpawnsIPS)

			TableOfSpawnsIPD = ents.FindByClass( "info_player_deathmatch" )
			TableOfSpawnsIPC = ents.FindByClass( "info_player_combine" )
			TableOfSpawnsIPR = ents.FindByClass( "info_player_rebel" )
			TableOfSpawns = table.Add( TableOfSpawns, TableOfSpawnsIPD )
			TableOfSpawns = table.Add( TableOfSpawns, TableOfSpawnsIPC )
			TableOfSpawns = table.Add( TableOfSpawns, TableOfSpawnsIPR )
			
			-- CS Maps
			TableOfSpawnsCT = ents.FindByClass( "info_player_counterterrorist" )
			TableOfSpawnsT = ents.FindByClass( "info_player_terrorist" )
			TableOfSpawns = table.Add( TableOfSpawns, TableOfSpawnsT)
			TableOfSpawns = table.Add( TableOfSpawns, TableOfSpawnsCT)
			-- DOD Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_axis" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_allies" ) )

			-- (Old) GMod Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "gmod_player_start" ) )
			
			-- TF Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_teamspawn" ) )
			
			-- INS Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "ins_spawnpoint" ) )  

			-- AOC Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "aoc_spawnpoint" ) )

			-- Dystopia Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "dys_spawn_point" ) )

			-- PVKII Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_pirate" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_viking" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_knight" ) )

			-- DIPRIP Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "diprip_start_team_blue" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "diprip_start_team_red" ) )
	 
			-- OB Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_red" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_blue" ) )        
	 
			-- SYN Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_coop" ) )
	 
			-- ZPS Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_human" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_zombie" ) )      
	 
			-- ZM Maps
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_deathmatch" ) )
			TableOfSpawns = table.Add( TableOfSpawns, ents.FindByClass( "info_player_zombiemaster" ) )  		

		end
		
		local Count = table.Count( TableOfSpawns )
		if TableOfSpawnsIPS then
			local spawnc = table.Count( TableOfSpawnsIPS )
			if spawnc > 0 then
				ServerLog("[SpawnCounter] There are "..spawnc.." info_player_start spawns\n")
				BroadcastMsg("[SpawnCounter] There are "..spawnc.." info_player_start spawns")
			end
		end
		
		if TableOfSpawnsIPD then
			local spawnc = table.Count( TableOfSpawnsIPD )
			if spawnc > 0 then
				ServerLog("[SpawnCounter] There are "..spawnc.." info_player_deathmatch spawns\n")
				BroadcastMsg("[SpawnCounter] There are "..spawnc.." info_player_deathmatch spawns")
			end
		end
		
		if TableOfSpawnsIPC then
			local spawnc = table.Count( TableOfSpawnsIPC )
			if spawnc > 0 then
				ServerLog("[SpawnCounter] There are "..spawnc.." info_player_combine spawns\n")
				BroadcastMsg("[SpawnCounter] There are "..spawnc.." info_player_combine spawns")
			end
		end
		
		if TableOfSpawnsIPR then
			local spawnc = table.Count( TableOfSpawnsIPR )
			if spawnc > 0 then
				ServerLog("[SpawnCounter] There are "..spawnc.." info_player_rebel spawns\n")
				BroadcastMsg("[SpawnCounter] There are "..spawnc.." info_player_rebel spawns")
			end
		end
		
		if TableOfSpawnsCT then
			local spawnc = table.Count( TableOfSpawnsCT )
			if spawnc > 0 then
				ServerLog("[SpawnCounter] There are "..spawnc.." CT spawns\n")
				BroadcastMsg("[SpawnCounter] There are "..spawnc.." CT spawns")
			end
		end
		
		if TableOfSpawnsT then
			local spawnc = table.Count( TableOfSpawnsT )
			if spawnc > 0 then
				ServerLog("[SpawnCounter] There are "..spawnc.." T spawns\n")
				BroadcastMsg("[SpawnCounter] There are "..spawnc.." T spawns")
			end
		end
		
		ServerLog("[SpawnCounter] There are "..Count.." total spawns\n")
		BroadcastMsg("[SpawnCounter] There are "..Count.." total spawns")
		for k,v in pairs(TableOfSpawns) do
			local _addition = ents.Create( "prop_dynamic" ); //debug_entity
			_addition:SetModel( "models/player.mdl" );
			_addition:SetPos( v:GetPos() );
			_addition:SetAngles( v:GetAngles() );
			_addition:Spawn( );
		end
		
	end
end