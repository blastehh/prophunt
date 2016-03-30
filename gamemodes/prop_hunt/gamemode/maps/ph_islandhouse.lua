-- BSList format: Vector(X position) , Vector(Y Position) , "Name of spot" , true/false(instakill for being there)
BSList = {
	{ Vector(-1551,-400,120), Vector(-1518,-350,130), "01", false },
	{ Vector(-1551,-350,120), Vector(-1522,-175,155), "02", true },
	{ Vector(-3070,-2028,-235), Vector(-2202,-1169,250), "03", true },
	{ Vector(-2228,-982,120), Vector(-2155,-943,128), "04", false },
	{ Vector(-1551,-400,120), Vector(-1518,-350,130), "05", false },
	{ Vector(-1560,-1117,139), Vector(-1557,-1107,150), "Toilet01", false },
	{ Vector(-1560,-1037,139), Vector(-1557,-1026,150), "Toilet02", false },
	{ Vector(-1560,-960,139), Vector(-1557,-949,150), "Toilet03", false },
	{ Vector(-1560,-885,139), Vector(-1557,-875,150), "Toilet04", false },
	{ Vector(-1843,-309,291), Vector(-1840,-299,301), "Toilet Upstairs", false },
}

if SERVER then
	-- Props underwater should die on this level
	print( "Underwater death loaded!" )
	last_hurt_interval = CurTime()
	hook.Add("Think", "ph_islandhouse_think", function()
		if last_hurt_interval + 1 < CurTime() then
			for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do
				if pl && pl:WaterLevel() >= 1 && pl:Alive() then
					
					ServerLog("[OUT OF BOUNDS] [WATER] ["..pl:SteamID().."] ["..pl:Name().."] ["..team.GetName(pl:Team()).."] ["..tostring(pl:GetPos()).."]\n")
					pl:Kill()
					pl:PlayerMsg("Wow, you shouldn't be here.")

				end
			end
			last_hurt_interval = CurTime()
		end
	end)
end