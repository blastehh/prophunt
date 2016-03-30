-- Admin groups
AdminGroups = {
	["superadmin"] = true,
	["admin"] = true
}

-- Props will not be able to become these models
BANNED_PROP_MODELS = {

	"models/props/cs_assault/dollar.mdl",
	"models/props/cs_assault/money.mdl",
	"models/props/cs_office/snowman_arm.mdl",
	"models/props/cs_office/computer_mouse.mdl",
	"models/props/cs_office/projector_remote.mdl",
	"models/sims/lightwall2.mdl",
	"models/props_debris/concrete_chunk09a.mdl",
	"models/props_debris/concrete_chunk04a.mdl",
	"models/props_junk/garbage_glassbottle001a_chunk02.mdl",
	"models/props_junk/glassbottle01a_chunk01a.mdl",
	"models/props/cs_office/computer_caseb_p2a.mdl"

}

EXPLOITABLE_DOORS = {
	"func_door",
	"prop_door_rotating", 
	"func_door_rotating"
}

USABLE_PROP_ENTITIES = {
	"prop_physics",
	"prop_physics_multiplayer"
}

-- Set how many points to give for each multi-kill level
MULTIKILLS_TABLE = {
	[2] = {
			sound = "doublekill.mp3",
			word = "Double",
			points = 30
	},
	[3] = {
			sound = "triplekill.mp3",
			word = "Triple",
			points = 100
	},
	[4] = {
			sound = "quadrakill.mp3",
			word = "Quadra",
			points = 400
	},
	[5] = {
			sound = "pentakill.mp3",
			word = "Penta",
			points = 1200
	},
	[6] = {
			sound = "hexakill.mp3",
			word = "Hexa",
			points = 2000
	},
	[7] = {
			sound = "legendarykill.mp3",
			word = "Lengendary",
			points = 3000
	}
}

-- Maximum time (in minutes) for this fretta gamemode (Default: 30)
GAME_TIME = 40
ROUNDS_PER_MAP = 12
ROUND_TIME = 300
SWAP_TEAMS_EVERY_ROUND = 1
CreateConVar("HUNTER_BLINDLOCK_TIME", "40", FCVAR_REPLICATED)

--Create the convars here
-- Health points removed from hunters when they shoot  (Default: 5)
CreateConVar( "HUNTER_FIRE_PENALTY", "5", FCVAR_REPLICATED)

-- How much health to give back to the Hunter after killing a prop (Default: 20)
CreateConVar( "HUNTER_KILL_BONUS", "20", FCVAR_REPLICATED)

-- Whether or not we include grenade launcher ammo (default: 1)
CreateConVar( "WEAPONS_ALLOW_GRENADE", "1", FCVAR_REPLICATED)

CreateConVar( "GRENADES_FOR_KILL", "1", FCVAR_REPLICATED, "Give SMG grenades for prop kills. Number indicates how many times it can happen each round")

CreateConVar( "PH_LAST_PROP_STANDING", "0", FCVAR_REPLICATED, "Unfinished feature, leave as 0")

-- Pointshop Stuff
CreateConVar( "PH_POINTSHOP_POINTS_KILL", "1", FCVAR_REPLICATED, "Give Pointshop points for kills")
CreateConVar( "PH_POINTSHOP_KILL_POINTS", "10", FCVAR_REPLICATED, "Amount of Pointshop points to give for kills")
CreateConVar( "PH_POINTSHOP_POINTS_TAUNT", "1", FCVAR_REPLICATED, "Give Pointshop points for taunts")
CreateConVar( "PH_POINTSHOP_FIRSTBLOOD_POINTS", "50", FCVAR_REPLICATED, "Amount of Pointshop points to give for first blood")

-- Kill announcements
CreateConVar( "PH_MULTIKILLS", "1", FCVAR_REPLICATED, "Announce multi-kills")
CreateConVar( "PH_FIRSTBLOOD", "1", FCVAR_REPLICATED, "Announce the first kill for each round")