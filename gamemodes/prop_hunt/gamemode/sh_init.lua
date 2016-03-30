-- Include the required lua files
include("sh_config.lua")
include("sh_player.lua")
include("sh_taunts.lua")

-- Include the configuration for this map.
if file.Exists("gamemodes/prop_hunt/gamemode/maps/"..string.lower(game.GetMap())..".lua", "GAME") || file.Exists("prop_hunt/gamemode/maps/"..string.lower(game.GetMap())..".lua", "GAME") then
	if SERVER then
		include("maps/"..string.lower(game.GetMap())..".lua")
		net.Start( "LoadCurrentMapLua" )
		net.Broadcast()			
	end
end


-- Fretta!
DeriveGamemode("fretta")
IncludePlayerClasses()


-- Information about the gamemode
GM.Name		= "Prop Hunt"
GM.Author	= "Kow@lski (Original by AMT)"
GM.Email	= "kowalski.7cc@xspacesoft.com"
GM.Website	= "http://xspacesoft.github.io/PropHunt/"


-- Help info
GM.Help = [[Prop Hunt is a twist on the classic backyard game Hide and Seek.

As a Prop you have ]]..GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt()..[[ seconds to replicate an existing prop on the map and then find a good hiding spot. Press [E] to replicate the prop you are looking at. Your health is scaled based on the size of the prop you replicate.

As a Hunter you will be blindfolded for the first ]]..GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt()..[[ seconds of the round while the Props hide. When your blindfold is taken off, you will need to find props controlled by players and kill them. Damaging non-player props will lower your health significantly. However, killing a Prop will increase your health by ]]..GetConVar("HUNTER_KILL_BONUS"):GetInt()..[[ points.

Both teams can press [F3] to play a taunt sound.]]


-- Fretta configuration
GM.AddFragsToTeamScore			= false
GM.CanOnlySpectateOwnTeam	= true
GM.Data									= {}
GM.EnableFreezeCam					= true
GM.GameLength						= GAME_TIME
GM.NoAutomaticSpawning			= true
GM.NoNonPlayerPlayerDamage	= true
GM.NoPlayerPlayerDamage			= true
GM.RoundBased							= true
GM.RoundLimit							= ROUNDS_PER_MAP
GM.RoundLength						= ROUND_TIME
GM.RoundPreStartTime				= 0
GM.SelectModel							= false
GM.SuicideString						= "couldn't take the pressure and committed suicide."
GM.TeamBased 							= true
GM.ForceJoinBalancedTeams		= true

-- Custom spectate settings for utime
GM.ValidSpectatorModes				= { OBS_MODE_CHASE, OBS_MODE_IN_EYE } -- The spectator modes that are allowed
GM.ValidSpectatorModesExtra		= { OBS_MODE_CHASE, OBS_MODE_IN_EYE, OBS_MODE_ROAMING }
GM.MinimumSpecTimeTeam		= 8 * 60	-- Played time in minutes needed to spectate team
GM.MinimumSpecTimeModes		= 8 * 60	-- Played time in minutes needed to unlock extra spectator modes

-- Called on gamemdoe initialization to create teams
function GM:CreateTeams()
	if !GAMEMODE.TeamBased then
		return
	end
	
	TEAM_HUNTERS = 1
	team.SetUp(TEAM_HUNTERS, "Hunters", Color(150, 205, 255, 255))
	team.SetSpawnPoint(TEAM_HUNTERS, {"info_player_counterterrorist", "info_player_combine", "info_player_deathmatch", "info_player_axis", "info_player_start"})
	team.SetClass(TEAM_HUNTERS, {"Hunter"})

	TEAM_PROPS = 2
	team.SetUp(TEAM_PROPS, "Props", Color(255, 60, 60, 255))
	team.SetSpawnPoint(TEAM_PROPS, {"info_player_terrorist", "info_player_rebel", "info_player_deathmatch", "info_player_allies", "info_player_start"})
	team.SetClass(TEAM_PROPS, {"Prop"})
end