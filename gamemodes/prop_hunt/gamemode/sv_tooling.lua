function BannedSpot(v1,v2,id,instakill) -- v1 = x position, v2 = y position, id is a string for the name of the spot.
	local findents = nil
	findents = ents.FindInBox( v1, v2 )
	
	if findents then

		for k, v in pairs(findents) do
			if v:IsPlayer() && v:Alive() && v:Team() == TEAM_PROPS then
				if instakill then
					v:Kill()
				else
					CheckWarn(v,true)
				end
				ServerLog("[OUT OF BOUNDS] ["..string.lower(game.GetMap()).."] ["..id.."] ["..v:SteamID().."] ["..v:Name().."] ["..team.GetName(v:Team()).."] ["..tostring(v:GetPos()).."]\n")
			end
			if v:IsPlayer() and v:IsAdmin() and v:Alive() and (v:Team() == TEAM_HUNTERS) then
				if v.lastSpot != id then
					v:PlayerMsg("Spot: "..id)
					v.lastSpot = id
				end
			end
		end
	end
end

function CheckWarn(v,kill) -- Passing true to kill will kill the player after they exceed the warnings
	v.spotwarned = v.spotwarned or 0
	if kill then v.spotwarned = v.spotwarned + 1 end
	if v.spotwarned > 0 then
	
		if v.spotwarned >= 3 && kill then
			v:Kill()
		elseif v:Alive() then
			v:Ignite(5)
		end
		
	else
	
		v:Ignite(5)
		
	end
	
	if kill then
		v:PlayerMsg("This spot has been banned!")
	else
		v:PlayerMsg("Please move!")
	end
	
end
	
function CheckSnow(v1,v2,kill) -- ply and x are used for this function to call itself. v1,v2 are for vectors and kill is true/false whether to kill the offender.

	local findents = nil
	findents = ents.FindInBox(v1,v2)

	if findents then
		local counter = 0
		for k, v in pairs(findents) do
			if !v:IsPlayer() or !v:Alive() or !(v:Team() == TEAM_PROPS) then continue end
			if v.ph_prop and ( v.ph_prop:OBBMaxs().z < 5.5) then
				CheckWarn(v,kill)
				if kill then
					ServerLog("[OUT OF BOUNDS] ["..string.lower(game.GetMap()).."] [SNOW] ["..v:SteamID().."] ["..v:Name().."] ["..team.GetName(v:Team()).."] ["..tostring(v:GetPos()).."]\n")
				end
			end
			
		end
		
	end
	
end

hook.Add("PlayerSpawn","ResetSpotWarns", function(ply)
	ply.spotwarned = 0
end)


function CheckOOBFunc()
	if !BSList && !SSList then timer.Destroy("CheckOOB") return end
	
	if BSList && #BSList > 0 then

		for k,v in pairs(BSList) do
			BannedSpot( v[1],v[2],v[3],v[4] )
		end
		
	end
	
	if SSList && #SSList > 0 then
		for k,v in pairs(SSList) do
			CheckSnow( v[1],v[2],v[3] )
		end
		
	end
end
timer.Create( "CheckOOB", 5, 0,CheckOOBFunc )








