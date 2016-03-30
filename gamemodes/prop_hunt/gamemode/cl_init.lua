DEBUG = (GetGlobalInt("DEBUG") > 0)
CreateConVar( "ph_debug", "0", FCVAR_REPLICATED)

-- Include the needed files
include("sh_init.lua")
include("cl_tauntmenu.lua")
include("cl_overrides.lua")
include("cl_debug.lua")
--include("cl_hints.lua")

local blankingScreen = false

-- SNOW SHIT
CreateClientConVar("ph_snow", 1, true, false)
local SNOW = (os.date("%m") == "12") and GetConVarNumber("ph_snow") == 1
local snowMat = Material( "banana/snowflake1.png", "smooth" )
local snowParticlesTable = {}
local snowRowTable = {}
local resHeight = ScrH()
local snowRowCount = math.Round((20 / 800) * resHeight)
local flakeSize = math.Round( (20 / 800) * resHeight )
local snowInit = snowInit or false

hook.Add("OnPlayerChat", "SnowToggler", function(ply, text)
	if ply == LocalPlayer() and string.lower(text) == "!snow" then
		SNOW = (os.date("%m") == "12") and !SNOW or false
		RunConsoleCommand( "ph_snow", SNOW and 1 or 0 )
	end
end)
CreateClientConVar("ph_snowcount", 2, true, false)

-- END OF SNOW SHIT

net.Receive("DebugCheck", function(len)
	DEBUG = net.ReadBit() == 1
	if DEBUG == true then
		LoadDebugStuff()
		print("Debugging ON!")
	end
	
end)

if DEBUG == true then
	LoadDebugStuff()
end
	
net.Receive("PH_Voice", function(len)
	PH_VoiceHide = net.ReadBit() == 1
end)

CreateClientConVar("ph_lan", "0", true, false)
CreateClientConVar("ph_team_chat", "0", true, true)


local ph_crosshair = CreateClientConVar( "ph_crosshair", "2", true, false )

local PH_SM_T = nil
net.Receive("PH_SM", function(len)
	local bool = net.ReadBit() == 1
	if bool then
		local targ = net.ReadEntity()
		if IsValid(targ) then
			PH_SM_T = targ
		end
	else
		PH_SM_T = nil
	end
end)

local function PH_LoadLua()
	include("prop_hunt/gamemode/maps/"..string.lower(game.GetMap())..".lua")
end
net.Receive("LoadCurrentMapLua",PH_LoadLua)

local function DebugChanged()
	DEBUG = GetConVarNumber("ph_debug") > 0
end
cvars.AddChangeCallback("ph_debug", DebugChanged)

-- Receiving end of the chat command to cycle through crosshair setting.
net.Receive("ph_crossh", function(len)
	local newCrossH = ph_crosshair:GetInt() + 1
	if newCrossH > 2 then newCrossH = 0 end
	RunConsoleCommand("ph_crosshair",newCrossH)
end)

local function DrawSnow(indexNum, snowParticles)
	surface.SetMaterial( snowMat )
	
	local frameDrawTime = RealFrameTime()
	local waveFunc = TimedSin
	
	snowParticlesTable[indexNum] = snowParticlesTable[indexNum] or {}
	for i = 1, snowParticles do
		if i % 2 == 0 then
			waveFunc = TimedCos
		else
			waveFunc = TimedSin
		end
		
		snowParticlesTable[indexNum][i] = snowParticlesTable[indexNum][i] or {}
		snowParticlesTable[indexNum][i].x = snowParticlesTable[indexNum][i].x or math.random(-20,ScrW()+20)
		snowParticlesTable[indexNum][i].y = snowParticlesTable[indexNum][i].y or ((indexNum > 1 and snowParticlesTable[indexNum][1].y) and snowParticlesTable[indexNum][1].y or -10 )
		snowParticlesTable[indexNum][i].rot = snowParticlesTable[indexNum][i].rot or 0
		local opacity = math.Clamp( (1 - ((snowParticlesTable[indexNum][i].y / resHeight) + 0.05) ), 0, 1 )
		surface.SetDrawColor(215,245,255,90 * opacity)
		surface.DrawTexturedRectRotated( snowParticlesTable[indexNum][i].x, snowParticlesTable[indexNum][i].y, flakeSize, flakeSize, snowParticlesTable[indexNum][i].rot )
		
		snowParticlesTable[indexNum][i].x = snowParticlesTable[indexNum][i].x + waveFunc( 0.3,  0, 1.2, 0 ) + math.Rand(-0.1,0.1)
		snowParticlesTable[indexNum][i].y = (snowParticlesTable[indexNum][i].y > resHeight) and -10 or ( snowParticlesTable[indexNum][i].y + ( (resHeight * frameDrawTime) * 0.13 ) - math.Rand(0.1,0.44) )
		snowParticlesTable[indexNum][i].rot = math.NormalizeAngle(snowParticlesTable[indexNum][i].rot - (frameDrawTime * 35))
	end
	--surface.DrawText(tostring(), Default, 0, 0, Color(255,255,255,255))
end

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	
	if LocalPlayer() && LocalPlayer():IsValid() then
		if (trace.Entity:IsPlayer()) then
			if (trace.Entity:Team() == LocalPlayer():Team()) then
				text = trace.Entity:Nick()
			else
				if (trace.Entity:Team() == TEAM_HUNTERS) then
					text = trace.Entity:Nick()
				else
					 return
				end
			end
		else
			 return
		end
	end


	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30

	--Testing code
	--[[
	if LocalPlayer() && LocalPlayer():IsValid() then
		if (LocalPlayer():GetEyeTrace().Entity:IsValid()) then
		
			local pos = LocalPlayer():GetShootPos()
			local ang = LocalPlayer():GetAimVector()
			local tracedata = {}
			tracedata.start = pos+(ang*38) --38 is the lowest distance that doesn't catch the player model
			tracedata.endpos = pos+(ang*250)
			tracedata.filter = LocalPlayer()	
			
			
			local trace = util.TraceLine( tracedata )
			
			--local trace = util.QuickTrace(LocalPlayer():GetShootPos(), LocalPlayer():GetAimVector(),LocalPlayer())
			
			if (trace.Hit) then
				if (trace.Entity:IsValid()) then
					text = trace.Entity:GetClass() --Class is not the same as name :(
				end
			end
		end
	end
	--]]
	
	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = trace.Entity:Health() .. "%"
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2
	
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end

-- Decides where  the player view should be (forces third person for props)
function GM:CalcView(pl, origin, angles, fov)
	local view = {} 
	
	if blind then
		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
		view.fov = fov
		
		return view
	end
	
 	view.origin = origin 
 	view.angles	= angles
 	view.fov = fov 
 	
 	-- Give the active weapon a go at changing the viewmodel position 
	if pl:Team() == TEAM_PROPS && pl:Alive() then

		for _,pr in pairs(ents.FindByClass("ph_prop")) do
			if pr:GetOwner() == pl then
				pr:SetPos(pl:GetPos() - Vector(0, 0, pr:OBBMins().z))
			end
		end




		view.origin = origin + Vector(0, 0, hullz - 60) + (angles:Forward() * -80)
	else
	 	local wep = pl:GetActiveWeapon() 
	 	if wep && wep != NULL then 
	 		local func = wep.GetViewModelPosition 
	 		if func then 
	 			view.vm_origin, view.vm_angles = func(wep, origin*1, angles*1) -- Note: *1 to copy the object so the child function can't edit it. 
	 		end
	 		 
	 		local func = wep.CalcView 
	 		if func then 
	 			view.origin, view.angles, view.fov = func(wep, pl, origin*1, angles*1, fov) -- Note: *1 to copy the object so the child function can't edit it. 
	 		end 
	 	end
	end
 	
 	return view 
end

local SpecCPerm = {
	["superadmin"] = true,
	["admin"] = true,
	["big_justice"] = true,
	["justice"] = true,
	["little_justice"] = true,
	["operator"] = true
}

local SpecClist = {}
local SpecCname = "error!"

-- Draw round timeleft and hunter release timeleft

hook.Add("HUDShouldDraw","CrosshairSetting", function(id)
    if (id == "CHudCrosshair") then
        return (ph_crosshair:GetInt() == 1)
    end
end)

function HUDPaint()
	
	if DEBUG then  -- co-ordinates tool
		local ply = LocalPlayer()
		if ply:Alive() then
			local vm = ply:GetViewModel()
			local attachmentIndex = vm:LookupAttachment( "muzzle" )
			local t = util.GetPlayerTrace(ply)
			local tr = util.TraceLine(t)
			if attachmentIndex > 0 then
				cam.Start3D(EyePos(), EyeAngles())
					render.SetMaterial(Material("sprites/bluelaser1"))
					render.DrawBeam(vm:GetAttachment(attachmentIndex).Pos, tr.HitPos, 2, 0, 12.5, Color(255, 0, 0, 255))
					local Size = 10 
					render.SetMaterial(Material("Sprites/light_glow02_add_noz"))
					render.DrawQuadEasy(tr.HitPos, (EyePos() - tr.HitPos):GetNormal(), Size, Size, Color(255,0,0,255), 0)
				cam.End3D()
				local pos = tr.HitPos
				local text = tostring(math.Round(pos.x,2)).." "..tostring(math.Round(pos.y,2)).." "..tostring(math.Round(pos.z,2))
				surface.SetFont("Trebuchet24")
				surface.SetTextColor(255, 255, 255, 255)
				local textw, texth = surface.GetTextSize(text)
				draw.RoundedBox(8, (surface.ScreenWidth() / 2)-(textw/2)-10, surface.ScreenHeight() - 320, textw + 20, 30, Color(0,0, 0, 170 ))
				surface.SetTextPos((surface.ScreenWidth() / 2)-(textw/2), surface.ScreenHeight() - 318)
			
				surface.DrawText(text)
			end
		end
	end
	
	if LocalPlayer() && LocalPlayer():Alive() && (LocalPlayer():Team() == TEAM_HUNTERS) && (ph_crosshair:GetInt() == 2) then
	
		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		local gap = 3
		local length = gap + 12
		surface.SetDrawColor(250, 120, 20, 150)
		surface.DrawLine( x - length, y, x - gap, y )
		surface.DrawLine( x + length, y, x + gap, y )
		surface.DrawLine( x, y - length, x, y - gap )
		surface.DrawLine( x, y + length, x, y + gap )
		
	end
	
	if GetGlobalBool("InRound", false) then
		local blindlock_time_left = (GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt() - (CurTime() - GetGlobalFloat("RoundStartTime", 0))) + 1
		
		if blindlock_time_left < 1 && blindlock_time_left > -6 then
			blindlock_time_left_msg = "Hunters have been released!"
		elseif blindlock_time_left > 0 then
			blindlock_time_left_msg = "Hunters will be unblinded and released in "..string.ToMinutesSeconds(blindlock_time_left)
		else
			blindlock_time_left_msg = nil
		end
		
		if blindlock_time_left_msg then
			surface.SetFont("MyFont")
			local tw, th = surface.GetTextSize(blindlock_time_left_msg)
			
			draw.RoundedBox(8, 20, 20, tw + 20, 26, Color(0, 0, 0, 75))
			draw.DrawText(blindlock_time_left_msg, "MyFont", 31, 26, Color(255, 255, 0, 255), TEXT_ALIGN_LEFT)
		end
	end
	
	if SpecCPerm[ LocalPlayer():GetNWString("UserGroup", "user") ] then
	-- Start
	
		local SpecCTarg = LocalPlayer():GetObserverTarget()
		if !IsValid(SpecCTarg) then SpecCTarg = LocalPlayer() end	
		SpecCname = SpecCTarg:Nick()
		for k,v in pairs(player.GetAll()) do
			if (v:Team() == TEAM_SPECTATOR) or !v:Alive() then
				if v:GetObserverTarget() == SpecCTarg and !table.HasValue(SpecClist, v) and v != LocalPlayer() then
					table.insert(SpecClist,v)
				end
			end
			for k,v in pairs(SpecClist) do
				if !IsValid(v) or (v:GetObserverTarget() != SpecCTarg) then
					table.remove(SpecClist,k)
				end
			end
		end

		
		local SpecWidest = 0
		local SpecTotalHeight = 0
		local SpecHeight = 65
		surface.SetFont("default")
		
		surface.SetTextColor(255, 255, 255, 255)
		for k,v in pairs(SpecClist) do
			local W, H = surface.GetTextSize(v:Nick())
			if W > SpecWidest then
					SpecWidest = W
			end
			SpecTotalHeight = SpecTotalHeight + H
		end
		local W, H = surface.GetTextSize(SpecCname)
		W = W + 85
		if W > SpecWidest then
			SpecWidest = W
		end
		if #SpecClist > 0 then
			draw.RoundedBox(8, 10, SpecHeight + 135, SpecWidest + 30, SpecTotalHeight + 30, Color(50, 150, 255, 100 ))
			surface.SetTextPos(20, SpecHeight + 140)	
			surface.DrawText("Players Watching: "..SpecCname)
		end
		for k,v in pairs(SpecClist) do
			local text = v:Nick()
			surface.SetTextPos(20, SpecHeight + 155)
			local W, H = surface.GetTextSize(text)
			
			surface.DrawText(text)
			SpecHeight = SpecHeight + H
		end
		local PH_SM_V = nil
		if IsValid(PH_SM_T) then PH_SM_V = PH_SM_T:GetObserverTarget() end
		if IsValid(PH_SM_T) && IsValid(PH_SM_V) then
			local PH_SMText = PH_SM_T:Nick().." is watching "..PH_SM_V:Nick()
			local W, H = surface.GetTextSize(PH_SMText)
			draw.RoundedBox(8, 10, 175, W + 20, H + 4, Color(50, 150, 255, 100 ))
			surface.SetTextPos(20, 176)
			surface.DrawText(PH_SMText)
		end
				
	-- Finish
	end
	
end
hook.Add("HUDPaint", "PH_HUDPaint", HUDPaint)

hook.Add("HUDPaintBackground", "PH_HUDPaintBG", function()
	
	if SNOW && GetConVarNumber("ph_snowcount") > 0 then
		if !snowInit then
			thisTime = CurTime()
			for i = 1, snowRowCount do
				snowRowTable[i] = snowRowTable[i] or {}
				snowRowTable[i].born = (i > 1 and snowRowTable[i-1].born + math.Rand(1.0,1.9) ) or thisTime
			end
			snowInit = true
		end
		local currentTime = CurTime()
		local partCount = GetConVarNumber("ph_snowcount")
		for k, v in pairs(snowRowTable) do
			if v.born < currentTime then
				DrawSnow(k, partCount)
			end
		end
	end
	
	if blind or blankingScreen then
	
		surface.SetDrawColor( Color( 0,0,0))
		draw.NoTexture()
		surface.DrawRect( 0,0,ScrW(),ScrH())
	
	end
end)

-- Called immediately after starting the gamemode 
function Initialize()
	hullz = 80
	--surface.CreateFont("Arial", 14, 1200, true, false, "ph_arial")
	surface.CreateFont( "MyFont",
	{
		font	= "Arial",
		size	= 14,
		weight	= 1200,
		antialias = true,
		underline = false
	})
	DEBUG = (GetGlobalInt("DEBUG") > 0)
end
hook.Add("Initialize", "PH_Initialize", Initialize)

-- Awesome glow shit happens here, yo
hook.Add("PreDrawHalos", "AddHalos", function()
    -- effects.halo.Add(ents.FindInCone(LocalPlayer():GetShootPos(), LocalPlayer():GetAimVector(), 3000, 90), Color(255, 0, 0), 5, 5, 2)
	--local tr = util.GetPlayerTrace( LocalPlayer() )
	--tr.filter = { LocalPlayer() }

	local pos = LocalPlayer():GetShootPos()
	local ang = LocalPlayer():GetAimVector()
	local tracedata = {}
	tracedata.start = pos+(ang*38)
	tracedata.endpos = pos+(ang*250)
	--tracedata.filter = LocalPlayer().Owner
	tracedata.filter = player.GetAll()
	

	local trace = util.TraceLine( tracedata )
	
	--local trace = util.QuickTrace(LocalPlayer():GetPos(), LocalPlayer():GetAimVector(),LocalPlayer())
	
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end  
	if (!table.HasValue(USABLE_PROP_ENTITIES, trace.Entity:GetClass())) then return end

	if LocalPlayer() && LocalPlayer():IsValid() then
		if (LocalPlayer():Team() == TEAM_PROPS) then
			halo.Add({trace.Entity}, Color(255, 157, 0), 5, 5, 2, true, true)
			end
	end
    
end)

-- Resets the player hull
function ResetHull(len)
	if LocalPlayer() && LocalPlayer():IsValid() then
		LocalPlayer():ResetHull()
		hullz = 80
	end
end
net.Receive("ResetHull", ResetHull)


-- Sets the local blind variable to be used in CalcView
function SetBlind(len)
	blind = net.ReadBit() == 1
end
net.Receive("SetBlind", SetBlind)


-- Sets the player hull
function SetHull(len)
	hullxy = net.ReadInt(32)
	hullz = net.ReadInt(32)
	new_health = net.ReadInt(16)
	
	LocalPlayer():SetHull(Vector(hullxy * -1, hullxy * -1, 0), Vector(hullxy, hullxy, hullz))
	LocalPlayer():SetHullDuck(Vector(hullxy * -1, hullxy * -1, 0), Vector(hullxy, hullxy, hullz))

	LocalPlayer():SetHealth(new_health)
end
net.Receive("SetHull", SetHull)

-- This part removes shadows from props' second entity when the flashlight is turned on.
function HideProps()
	if LocalPlayer():Team() == TEAM_HUNTERS && LocalPlayer():Alive() then
		for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do 
			if pl:Alive() then
				pl:SetNoDraw( true )
			end
		end
	else
		for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do 
			if pl:Alive() then
				pl:SetNoDraw( false )
			end
		end
	end
end
hook.Add("Think","ShadowDestroyer",HideProps)

-- Lan Section

local function HandleScreenBlank(ply,bind,press)
	if string.find(bind, "+speed") && GetConVarNumber("ph_lan") > 0 then
		blankingScreen = !blankingScreen
	end
end
hook.Add("PlayerBindPress","HandleScreenBlank",HandleScreenBlank)