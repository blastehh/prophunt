-- Custom Stuff
util.AddNetworkString("LoadCurrentMapLua")
util.AddNetworkString("PH_Voice")
util.AddNetworkString("PH_SM")

-- PH Stuff
util.AddNetworkString("SetBlind")
util.AddNetworkString("ResetHull")
util.AddNetworkString("SetHull")

-- Taunt Menu Stuff
util.AddNetworkString("RandomTaunt")
util.AddNetworkString("BuildTauntMenu")
util.AddNetworkString("CloseTauntMenu")
util.AddNetworkString("PlayTaunt")

-- Crosshair Stuff
util.AddNetworkString("ph_crossh") 

-- Send the required lua files to the client
AddCSLuaFile("cl_overrides.lua")
include("sv_debug.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("cl_tauntmenu.lua")
AddCSLuaFile("sh_taunts.lua")
AddCSLuaFile("cl_debug.lua")

-- If there is a mapfile send it to the client (sometimes servers want to change settings for certain maps).
if file.Exists("gamemodes/prop_hunt/gamemode/maps/"..string.lower(game.GetMap())..".lua", "GAME") then
	AddCSLuaFile("maps/"..string.lower(game.GetMap())..".lua")
	MapHasLua = true
end

-- Include the required lua files

include("sh_init.lua")
include("sv_tooling.lua")
include("sv_overrides.lua")

-- Probably best not to change these.
FirstBlooded = FirstBlooded or false
local multiKillDelay = 2.5
local multiKillExtend = 3

function PointsForKill()
	if DEBUG or !GAMEMODE:InRound() then return false end
	if GetConVar("PH_POINTSHOP_POINTS_KILL"):GetInt() > 0 then
		return PS and true
	end
end

function PointsForTaunt()
	if DEBUG or !GAMEMODE:InRound() then return false end
	if GetConVar("PH_POINTSHOP_POINTS_TAUNT"):GetInt() > 0 then
		return PS and true
	end
end

function PH_PlayerInitialSpawn(ply)

	if MapHasLua then
		net.Start( "LoadCurrentMapLua" )
		net.Send( ply )
	end

end
hook.Add("PlayerInitialSpawn", "RunPlayerInitialSpawn", PH_PlayerInitialSpawn)

function FirstBlood(attacker,victim)
	if GetConVar("PH_FIRSTBLOOD"):GetInt() < 1 and !GAMEMODE:InRound() then return end
	if !FirstBlooded then
		local firstBloodPoints = GetConVar( "PH_POINTSHOP_FIRSTBLOOD_POINTS"):GetInt()
		FirstBlooded = true
		BroadcastMsg( Color(255,30,0), attacker:Nick().." got First Blood!" )
		BroadcastSound("firstblood.mp3")
		hook.Run("ST_FirstBlood",attacker,victim)
		if PointsForKill() then
			attacker:PS_GivePoints(firstBloodPoints)
			attacker:PS_Notify("First Blood for " .. tostring(firstBloodPoints) .. " extra " .. PS.Config.PointsName .. "!")
		end
	end

end

local function MultiKillAnnounce(attacker, num)
	BroadcastSound(MULTIKILLS_TABLE[num]["sound"])
	BroadcastMsg( Color(255,30,0), attacker:Nick().." got a ".. MULTIKILLS_TABLE[num]["word"] .." Kill!" )
	ServerLog(attacker:Nick().." got a ".. MULTIKILLS_TABLE[num]["word"] .." Kill!\n" )
	hook.Run("ST_MultiKill",attacker,num)
	if PointsForKill() then
		attacker:PS_GivePoints(MULTIKILLS_TABLE[num]["points"])
		attacker:PS_Notify(MULTIKILLS_TABLE[num]["word"] .." kill for ".. tostring(MULTIKILLS_TABLE[num]["points"]) .." extra "..PS.Config.PointsName.."!")
	end
	attacker.killLevel = 0
end

function MultiKill(attacker)
	if !GAMEMODE:InRound() or GetConVar("PH_MULTIKILLS"):GetInt() < 1 then return end
	attacker.killtrack = attacker.killtrack or 0
	attacker.killLevel = attacker.killLevel and attacker.killLevel + 1 or 1
	attacker.multiKillExpire = attacker.multiKillExpire or CurTime() + multiKillDelay
	if attacker.multiKillExpire and CurTime() > attacker.multiKillExpire then
		attacker.killtrack = 0
	end
	
	attacker.killtrack = attacker.killtrack < 7 and attacker.killtrack + 1 or 7
	attacker.multiKillExpire = attacker.killtrack < 2 and CurTime() + multiKillDelay or CurTime() + multiKillExtend
	
	if MULTIKILLS_TABLE[attacker.killtrack] then
		if timer.Exists("killLevelReset"..attacker:SteamID()) then timer.Destroy("killLevelReset"..attacker:SteamID()) end
		local killLevel = attacker.killtrack
		if timer.Exists("KillTrack"..attacker:SteamID()) then

			if attacker.killLevel > attacker.killtrack and CurTime() - attacker.timerCreated > 0.1 then return end
			timer.Adjust("KillTrack"..attacker:SteamID(), multiKillExtend, 1, function()
				if !IsValid(attacker) then return end
				MultiKillAnnounce(attacker, killLevel)
			end)
			
		else
			timer.Create("KillTrack"..attacker:SteamID(), multiKillDelay, 1, function()
				if !IsValid(attacker) then return end
				MultiKillAnnounce(attacker, killLevel)
			end)
			attacker.timerCreated = CurTime()
		end

	else
		timer.Create("killLevelReset"..attacker:SteamID(), multiKillDelay, 1, function()
			if !IsValid(attacker) then return end
			attacker.killLevel = 0
		end)
	end
	
end
	
-- Called a lot
function GM:CheckPlayerDeathRoundEnd()
	if !GAMEMODE.RoundBased || !GAMEMODE:InRound() then 
		return
	end

	local Teams = GAMEMODE:GetTeamAliveCounts()
	local teamcount = table.Count(Teams)
	if teamcount == 0 then
		GAMEMODE:RoundEndWithResult(1001, "Draw, everyone loses!")
		hook.Run("ST_RoundEnded")
		hook.Run("PH_RoundEnded",1001)
	elseif teamcount == 1 then
		local TeamID = table.GetFirstKey(Teams)
		GAMEMODE:RoundEndWithResult(TeamID, team.GetName(TeamID).." win!")
		hook.Run("ST_RoundEnded")
		hook.Run("PH_RoundEnded",TeamID)
	end	
	return
	
end

function HunterDamage(victim, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	local dmgAmt = dmginfo:GetDamage()
	if inflictor and inflictor == attacker and inflictor:IsPlayer() then
		inflictor = inflictor:GetActiveWeapon()
		if !inflictor || inflictor == NULL then inflictor = attacker end
	end
	
	if victim and IsValid(victim) and victim:Alive() and dmgAmt >= 1 then
		victim:SetHealth(victim:Health() - dmgAmt)
		if victim:Health() < 1 then
			victim:KillSilent()
			attacker:AddFrags(1)
			victim:AddDeaths(1)
			MultiKill(attacker)

			net.Start( "PlayerKilledByPlayer" )
				net.WriteEntity( victim )
				net.WriteString( inflictor:GetClass() )
				net.WriteEntity( attacker )
			net.Broadcast()
			
			CloseTauntMenuMSG(victim)
			
			if PointsForKill() then
				local pointsForKillAmount = GetConVar("PH_POINTSHOP_KILL_POINTS"):GetInt()
				attacker:PS_GivePoints(pointsForKillAmount)
				attacker:PS_Notify("You got " .. pointsForKillAmount .. " " .. PS.Config.PointsName .. " for killing " .. victim:Name() .. "!")
			end

			MsgAll(attacker:Name() .. " got revenge on " .. victim:Name() .. "\n") 
			ServerLog(attacker:Name() .. " got revenge on" .. victim:Name() .. "\n")
		end
	end
	
end

function PropDamage(victim,dmginfo,isPlayer)
	local vict
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	if inflictor and inflictor == attacker and inflictor:IsPlayer() then
		inflictor = inflictor:GetActiveWeapon()
		if !inflictor || inflictor == NULL then inflictor = attacker end
	end
	if isPlayer then
		-- Workaround for props taking double damage from explosives
		if (inflictor:GetClass() == "grenade_ar2") or (inflictor:GetClass() == "npc_grenade_frag") or (inflictor:GetClass() == "rpg_missile") then return end
		vict = victim
	else
		vict = victim:GetOwner()
	end
	
	-- Health
	if vict and IsValid(vict) and vict:Alive() and vict:IsPlayer() and dmginfo:GetDamage() >= 1 then
		vict.ph_prop.health = vict.ph_prop.health - dmginfo:GetDamage()
		vict:SetHealth(vict.ph_prop.health)
		if vict.ph_prop.health >= 1 then
			vict.ph_prop.hppercent = (vict.ph_prop.health / vict.ph_prop.max_health)
		end
		
		if DEBUG then
			vict:PlayerMsg(tostring(vict.ph_prop.hppercent))
			vict:PlayerMsg(tostring(attacker:Name()))
		end
		
		if vict.ph_prop.health < 1 then
			if vict.kleiner and GAMEMODE:InRound() then
				hook.Run("ST_KleinerKill",attacker)
			end
			vict:KillSilent()
			vict:RemoveProp()
			
		-- ########### First Blood Stuff Start ###########
			FirstBlood(attacker,vict)

		-- ########### Multi Kill Stuff Start ###########
			MultiKill(attacker)
			
			local nadesForKill = GetConVar("GRENADES_FOR_KILL"):GetInt()
			if nadesForKill > 0 then
				attacker.nadegain = attacker.nadegain or 0
				if DEBUG then print(tostring(inflictor:GetClass())) end
				if inflictor:GetClass() == "weapon_smg1" or inflictor:GetClass() == "weapon_shotgun" or inflictor:GetClass() == "weapon_crowbar" then
					if attacker.nadegain < nadesForKill then
						attacker:GiveAmmo(1,"SMG1_Grenade")
						attacker:PlayerMsg("+1 SMG Grenade for kill")
						attacker.nadegain = attacker.nadegain + 1
					end
				end
			end
			
			net.Start( "PlayerKilledByPlayer" )
				net.WriteEntity( vict )
				net.WriteString( inflictor:GetClass() )
				net.WriteEntity( attacker )
			net.Broadcast()
			
			CloseTauntMenuMSG(vict)
			
			if PointsForKill() then
				local pointsForKillAmount = GetConVar("PH_POINTSHOP_KILL_POINTS"):GetInt()
				attacker:PS_GivePoints(pointsForKillAmount)
				attacker:PS_Notify("You got " .. pointsForKillAmount .. " " .. PS.Config.PointsName .. " for killing " .. vict:Name() .. "!")
			end

			MsgAll(attacker:Name() .. " found and killed " .. vict:Name() .. "\n") 
			ServerLog(attacker:Name() .. " found and killed " .. vict:Name() .. "\n")
			
			attacker:AddFrags(1)
			vict:AddDeaths(1)
			
			if GAMEMODE:InRound() then
				hook.Run("ST_Kill",attacker,vict,inflictor:GetClass())
			end
			
			local huntermax = attacker:Health()
			if huntermax < 100 then
				huntermax = 100
			end
			attacker:SetHealth(math.Clamp(attacker:Health() + GetConVar("HUNTER_KILL_BONUS"):GetInt(), 1, huntermax))
			
			
		end
	end
	
end

-- Called when an entity takes damage
function EntityTakeDamage(victim, dmginfo)
    local att = dmginfo:GetAttacker()
	if !IsValid(att) || !IsValid(victim) || !att:IsPlayer() then return end
	
	local damage = dmginfo:GetDamage()
	if DEBUG then
		--att:PlayerMsg("hit ".. tostring(victim:GetClass()) .." for "..dmginfo:GetDamage())
		BroadcastMsg("Hit "..tostring(victim:EntIndex()))
	end
	if IsValid(victim) and table.HasValue(EXPLOITABLE_DOORS, victim:GetClass()) then -- Door removal code
		victim.damagetaken = victim.damagetaken or 0
		if victim.damagetaken + damage >= 200 then
			victim:SetKeyValue("spawnflags", "4096")				-- Silence the door open sound
			victim:Fire("Open","",0.01)										-- We want to open the door before removing it, so that any vis blocks are triggered. Prevents hall of mirrors effect.
			timer.Create("Breakdoor"..tostring(victim),0.05,1, function()
				if IsValid(victim) then
					victim:Remove()
				end
			end)
		else
			victim.damagetaken = victim.damagetaken + damage
		end
	end
	if victim and victim:IsPlayer() then
		if victim:Alive() and (att:Team() != victim:Team()) then
			if victim:Team() == TEAM_PROPS then
				PropDamage(victim,dmginfo,true)
			elseif victim:Team() == TEAM_HUNTERS then
				HunterDamage(victim, dmginfo)
			end
		end
	elseif victim and (victim:GetClass() == "ph_prop") and victim:GetOwner():IsPlayer() and (victim:GetOwner():Team() != att:Team()) then
		PropDamage(victim,dmginfo,false)
	end
	if GAMEMODE:InRound() and victim and victim:GetClass() != "ph_prop" and !victim:IsPlayer() and att and att:IsPlayer() and att:Team() == TEAM_HUNTERS and att:Alive() and !( table.HasValue(EXPLOITABLE_DOORS, victim:GetClass()) ) then
		att.damageScale = att.damageScale or 1
		att:SetHealth(att:Health() - ( GetConVar("HUNTER_FIRE_PENALTY"):GetInt() * att.damageScale) )
		if att:Health() <= 0 then
			MsgAll(att:Name() .. " felt guilty for hurting so many innocent props and committed suicide\n")
			att:Kill()
			hook.Run("ST_Suicide",att)
		end
	end
end
hook.Add("EntityTakeDamage", "PH_EntityTakeDamage", EntityTakeDamage)

-- Called when player tries to pickup a weapon
function GM:PlayerCanPickupWeapon(ply, ent)
	if ply:Team() == TEAM_PROPS then
		if GetConVar("PH_LAST_PROP_STANDING"):GetInt() < 1 then return false end
		local propsAlive = 0
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_PROPS and v:Alive() then
				propsAlive = propsAlive + 1
				if propsAlive > 1 then break end
			end
		end
		return propsAlive == 1
	end
	return ply:Team() == TEAM_HUNTERS
end

function GM:AllowPlayerPickup( ply, ent )
	return ply:Team() == TEAM_HUNTERS
end

-- Restricting flashlight so only hunters can use it
function GM:PlayerSwitchFlashlight(ply, SwitchOn)
     return ply:Team() == TEAM_HUNTERS or not SwitchOn
end

function GM:CanPlayerSuicide( ply )
	if !ply:Alive() || (ply:Team() == TEAM_SPECTATOR) || (ply:Team() == TEAM_UNASSIGNED) then return false end

	if ply:Team() == TEAM_HUNTERS then return true end
	if timer.Exists("Suiciding_"..ply:SteamID()) then return false end
	ply:Freeze(true)
	ply:PlayerMsg("Suiciding in 3 seconds...")
	timer.Create("Suiciding_"..ply:SteamID(),3,1,function()
		if !IsValid(ply) then return end
		ply:Freeze(false)
		if !ply:Alive() then return false end
		ply:Kill()
	end)
	return false
end
	
-- Called when player needs a model
function GM:PlayerSetModel(ply)

	local player_model = "models/props_lab/huladoll.mdl"
	
	if ply:Team() == TEAM_HUNTERS then
		player_model = "models/player/combine_super_soldier.mdl"
	end
	
	util.PrecacheModel(player_model)
	ply:SetModel(player_model)
end

-- Called when a player tries to use an object
function GM:PlayerUse(ply, useEnt)
	ply._lastused = ply._lastused or 0
	if CurTime() - ply._lastused < 0.3 then return false end
	ply._lastused = CurTime()
	if DEBUG then
		ply:PlayerMsg("Model: " ..tostring(useEnt:GetModel()))
		ply:PlayerMsg( "Size: " .. tostring(useEnt:OBBMaxs()))
	end
	if !ply:Alive() || ply:Team() == TEAM_SPECTATOR then return false end
	if ply:Team() == TEAM_PROPS and ply:IsOnGround() and !ply:Crouching() and table.HasValue(USABLE_PROP_ENTITIES, useEnt:GetClass()) and useEnt:GetModel() then
		if !IsValid(ply.ph_prop) then return end
		if table.HasValue(BANNED_PROP_MODELS, useEnt:GetModel()) then
			ply:ChatPrint("That prop has been banned by the server.")
		elseif IsValid(useEnt:GetPhysicsObject()) and ply.ph_prop:GetModel() != useEnt:GetModel() then
			ply.ph_prop.hppercent = ply.ph_prop.hppercent or 1.0
			local ent_health = math.Clamp(useEnt:GetPhysicsObject():GetVolume() / 250, 20, 200)
			ply.ph_prop.max_health = ent_health
			local new_health = math.Clamp((ply.ph_prop.max_health * ply.ph_prop.hppercent),1,200)
			ply.ph_prop.health = new_health
			
			ply.kleiner = false
			-- Here I mess with the run speed
			local new_speed = math.Round( ( ent_health + ply.NormSpeed - 60 ) * ( 1 / math.pow((ent_health*1.25),0.01) ) )
			new_speed = math.Clamp(new_speed,180,370)
			ply:SetRunSpeed(new_speed * ply.RTDSpeed)
			ply:SetWalkSpeed(new_speed * ply.RTDSpeed)
			-- I'm done messing with run speed
			
			ply.ph_prop:SetModel(useEnt:GetModel())		
			ply.ph_prop:SetSkin(useEnt:GetSkin())
			if DEBUG then
				ply:PlayerMsg(tostring(ply.ph_prop.hppercent))
			end

			ply.ph_prop:SetSolid(SOLID_VPHYSICS)
			ply.ph_prop:SetPos(ply:GetPos() - Vector(0, 0, useEnt:OBBMins().z))

			local hullxymax = math.Round(math.Max(useEnt:OBBMaxs().x, useEnt:OBBMaxs().y))
			local hullxymin = hullxymax * -1
			local hullz = math.Round(useEnt:OBBMaxs().z)

			ply:SetHull(Vector(hullxymin, hullxymin, 0), Vector(hullxymax, hullxymax, hullz))
			ply:SetHullDuck(Vector(hullxymin, hullxymin, 0), Vector(hullxymax, hullxymax, hullz))
			ply:SetHealth(new_health)
			
			net.Start("SetHull")
				net.WriteInt(hullxymax,32)
				net.WriteInt(hullz,32)
				net.WriteInt(new_health,16)
			net.Send(ply)
		end
		return false --true allows props to pick up props
	end
	
	-- Prevent the door exploit
	if table.HasValue(EXPLOITABLE_DOORS, useEnt:GetClass()) then
		useEnt.__last_door_time = useEnt.__last_door_time or 0
		if CurTime() - useEnt.__last_door_time < 1.3 then
			return false
		else
			useEnt.__last_door_time = CurTime()
		end
	end
	
	if ply:Team() == TEAM_HUNTERS then return true end
	if ply:Team() == TEAM_PROPS  and !table.HasValue(USABLE_PROP_ENTITIES, useEnt:GetClass()) then return true end  -- Added a check to see if the object is a prop, otherwise they can jump and pick up props
	return
end

function RequestTaunt(len, ply, minDuration)
	-- Check if we're being called via networking
	local minTauntDuration = minDuration or 0
	
	if len then

		local tauntChosen = net.ReadString()
		local clTauntLength = net.ReadString()
		
		if GAMEMODE:InRound() and ply:Alive() and (ply:Team() == TEAM_HUNTERS || ply:Team() == TEAM_PROPS) and ply.taunt_delay <= CurTime() then
			local tauntTable
			if ply:Team() == TEAM_HUNTERS then
				tauntTable = HUNTER_TAUNTS
			elseif ply:Team() == TEAM_PROPS then
				tauntTable = PROP_TAUNTS
			end
			local tauntLength
			local found = false
			for k = #tauntTable, 1, -1 do
				local v = tauntTable[k]
				if v[1] == tauntChosen then
					tauntChosen = v[2]
					tauntLength = v[3]
					found = true
					break
				end
			end
			if !found then return end
			if clTauntLength != tauntLength then print("Taunt length mismatch for ".. ply:Nick() .. "! Requested: "..clTauntLength.." Actual: "..tauntLength) return end
			ply.last_taunt = tauntChosen
			ply:EmitSound(tauntChosen)
			ply.taunt_delay = CurTime() + tauntLength
			ply.last_taunt = tauntChosen
			local PointsForTauntAmount = math.Round(tauntLength / 2)

			if (ply.last_point_time <= CurTime()) and (ply:Team() == TEAM_PROPS) and PointsForTaunt() then
				ply:PS_GivePoints(PointsForTauntAmount)
				ply:PS_Notify("You got " .. PointsForTauntAmount .. " " .. PS.Config.PointsName .. " for taunting!")
			end
			hook.Run("ST_Taunt",ply)
		end
		return
	end
	
	-- Not networking, selecting random taunt
	if GAMEMODE:InRound() and ply:Alive() and (ply:Team() == TEAM_HUNTERS || ply:Team() == TEAM_PROPS) and ply.taunt_delay <= CurTime() and #PROP_TAUNTS > 1 and #HUNTER_TAUNTS > 1 then
		
		if ply:Team() == TEAM_HUNTERS then
			repeat
				rand_taunt = table.Random(HUNTER_TAUNTS)
			until rand_taunt[2] != ply.last_taunt
		else
			repeat
				rand_taunt = table.Random(PROP_TAUNTS)
			until (rand_taunt[2] != ply.last_taunt) and (tonumber(rand_taunt[3]) > minTauntDuration)
		end
		
		ply:EmitSound(rand_taunt[2])
		ply.taunt_delay = CurTime() + rand_taunt[3]
		ply.last_taunt = rand_taunt[2]
		local PointsForTauntAmount = math.Round(rand_taunt[3] / 2)

		if (ply.last_point_time <= CurTime()) and (ply:Team() == TEAM_PROPS) and PointsForTaunt() then
			ply:PS_GivePoints(PointsForTauntAmount)
			ply:PS_Notify("You got " .. PointsForTauntAmount .. " " .. PS.Config.PointsName .. " for taunting!")
		end
		hook.Run("ST_Taunt",ply)
	end
end

-- Called when player presses [F3]. Plays a taunt for their team
function GM:ShowSpare1(ply)
	--local emptything = nil
	--RequestTaunt(emptything,ply)
end

function RequestRandomTaunt(len,ply)
	RequestTaunt(nil,ply)
end

-- Called when the gamemode is initialized
function Initialize()

end
hook.Add("Initialize", "PH_Initialize", Initialize)

function TauntRebuild(ply)
	if ply:Team() == TEAM_HUNTERS || ply:Team() == TEAM_PROPS then
		net.Start( "CloseTauntMenu" )
		net.Send( ply )
		net.Start( "BuildTauntMenu" )
		net.Send( ply )
	end
end
hook.Add("OnPlayerChangedTeam", "TauntRebuildMessage", TauntRebuild)

-- Called when a player leaves
function PlayerDisconnected(ply)
	ply:RemoveProp()
end
hook.Add("PlayerDisconnected", "PH_PlayerDisconnected", PlayerDisconnected)


-- Called when the players spawns
function PlayerSpawn(ply)
	if DEBUG then BroadcastMsg("PlayerSpawn") end
	ply:Blind(false)
	ply:RemoveProp()
	ply:SetColor( Color(255, 255, 255, 255))
	ply:SetRenderMode( RENDERMODE_TRANSALPHA )
	ply:UnLock()
	ply:ResetHull()
	ply.BoughtForceTaunt = false
	ply.taunt_delay = 0
	ply.HasJumpPower = 0
	ply.RTDSpeed = 1
	ply.last_point_time = CurTime() + (GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt()) -- stop props from gaining points before hunters are released
	ply.nadegain = 0
	ply.kleiner = true
	net.Start("ResetHull")
	net.Send(ply)
	ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	
	timer.Create(ply:SteamID().."_setspeed", 0.5,1, function()
		if ply:IsValid() then
			ply.NormSpeed = ply:GetRunSpeed()
			ply.NormJumpPower = ply:GetJumpPower()
		end
	end)
	
	TauntRebuild(ply)
end
hook.Add("PlayerSpawn", "PH_PlayerSpawn", PlayerSpawn)

-- Removes all weapons on a map
function RemoveWeaponsAndItems()
	for _, wep in pairs(ents.FindByClass("weapon_*")) do
		wep:Remove()
	end
	
	for _, item in pairs(ents.FindByClass("item_*")) do
		item:Remove()
	end
end
hook.Add("InitPostEntity", "PH_RemoveWeaponsAndItems", RemoveWeaponsAndItems)

-- This doesn't actually run. At all.
function RoundEnd()
	for _, ply in pairs(team.GetPlayers(TEAM_HUNTERS)) do
		ply:Blind(false)
		ply:UnLock()
	end
	if DEBUG then BroadcastMsg("RoundEnd") end
end
hook.Add("RoundEnd", "PH_RoundEnd", RoundEnd)

-- This is called when the round time ends (props win)
function GM:RoundTimerEnd()
	if !GAMEMODE:InRound() then
		return
	end
   
	GAMEMODE:RoundEndWithResult(TEAM_PROPS, "Props win!")
	hook.Run("ST_RoundEnded")
	hook.Run("PH_RoundEnded",TEAM_PROPS)
end

-- Called before start of round
function GM:OnPreRoundStart(num)
	ServerLog("Starting round "..num.."\n")
	game.CleanUpMap()
	FirstBlooded = false
	
	if SWAP_TEAMS_EVERY_ROUND == 1 then
		local tempScore = team.GetScore(1)
		team.SetScore( 1, team.GetScore(2) )
		team.SetScore( 2, tempScore )
	end
	
	if DEBUG then BroadcastMsg("OnPreRoundStart") end
	for _, ply in pairs(player.GetAll()) do
		if !IsValid(ply) then continue end
		ply:UnLock()
		ply.TeamChangeCount = ply.TeamChangeCount or 0
		if ply.TeamChangeCount > 0 then
			ply.TeamChangeCount = ply.TeamChangeCount - 1
		end
	end

	if GetGlobalInt("RoundNumber") != 1 and SWAP_TEAMS_EVERY_ROUND == 1 then
		for _, ply in pairs(player.GetAll()) do
			if ply:Team() == TEAM_PROPS || ply:Team() == TEAM_HUNTERS then
				if ply:Team() == TEAM_PROPS then
					ply:SetTeam(TEAM_HUNTERS)
				else
					ply:SetTeam(TEAM_PROPS)
				end
				
				ply:ChatPrint("Teams have been swapped!")
				CloseTauntMenuMSG(ply)
				--TauntRebuild(ply)
			end
		end
	end
	
	hook.Run("PH_PreRoundStart",num)
	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()
end

-- Prop rotation stuff
function GM:Think()

	-- Calculate the location of every Prop's prop entity.
	for _, ply in pairs(team.GetPlayers(TEAM_PROPS)) do
		
		-- Check for a valid player/prop, and if they aren't freezing their prop.
		if ply and ply:IsValid() and ply:Alive() and ply.ph_prop and ply.ph_prop:IsValid() then
			ply.ph_prop:SetPos(ply:GetPos() - Vector(0, 0, ply.ph_prop:OBBMins().z))  --set's the props position over the player entity each server tick if they're valid+alive etc
			if ply and ply:IsValid() and ply:Alive() and ply.ph_prop and ply.ph_prop:IsValid() and (ply:KeyDown(IN_ATTACK2)) then --set rotation of prop in addition to the above if right click is held down
				ply.ph_prop:SetAngles(Angle(0,ply:EyeAngles().y,0))
			end
		end
	
	end
                
end

function CloseTauntMenuMSG(ply)
	net.Start( "CloseTauntMenu" )
	net.Send( ply )
	if ply.last_taunt then
		ply:StopSound(ply.last_taunt) -- Stop taunt playing when they die
	end
end
hook.Add("DoPlayerDeath", "SomeoneDied", CloseTauntMenuMSG)



local function CheckChat( ply, text, teamonly )

	if (string.lower(text) == "!grenade" ) then
		ply:PS_BuyItem("grenade")
		return ""
	end
	if (string.lower(text) == "!sg" ) then
		ply:PS_BuyItem("smggrenade")
		return ""
	end
	if (string.lower(text) == "!debug")  then
		GameDebugMode(ply)
	end
	if (string.lower(text) == "!timeleft")  then
		local tl = GAMEMODE:GetGameTimeLeft()
		if ( tl == -1 ) then return end
	
		local Time = util.ToMinutesSeconds( tl )
	
		if !lasttimeleft then lasttimeleft = 0 end
		
		if (lasttimeleft + 30 <= CurTime() ) then
			lasttimeleft = CurTime()
			BroadcastMsg("Time left: "..Time)
		end
		
	end
	
	if (string.lower(text) == "!crosshair") || (string.lower(text) == "/crosshair") then
		
		net.Start("ph_crossh")
		net.Send(ply)
		return ""
	end

end
hook.Add( "PlayerSay", "PlayerSaidSomething", CheckChat )

net.Receive("PlayTaunt", RequestTaunt)
net.Receive("RandomTaunt", RequestRandomTaunt)

ServerLog("[Prop Hunt] init.lua loaded\n")