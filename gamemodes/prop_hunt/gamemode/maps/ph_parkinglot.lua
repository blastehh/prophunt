if SERVER then
	local entNum = 612 + game.MaxPlayers()
	hook.Add("InitPostEntity","WeaponRoom",function()
		if Entity(entNum) and Entity(entNum):GetClass() == "func_breakable" then
			SafeRemoveEntity(Entity(entNum))
		else
			print("Couldn't find weapon entity at "..entNum)
			for k,v in pairs(ents.FindByClass("func_breakable")) do
				local entid = v:EntIndex()
				if entid > 600 then
					print("Removing entity with ID: "..entid)
					SafeRemoveEntity(v)
					break
				end
			end
		end
	end)

	hook.Add("PostCleanupMap","WeaponRoomRemover",function()
		local wepRoomEnt = Entity(entNum) and Entity(entNum):GetClass() or "notfound"
		if wepRoomEnt == "func_breakable" then
			print("Found weapon room secret and removing.")
			SafeRemoveEntity(Entity(entNum))
		else
			print("Didn't find weapon room secret. Got "..wepRoomEnt)
			for k,v in pairs(ents.FindByClass("func_breakable")) do
				local entid = v:EntIndex()
				if entid > 600 then
					print("Removing entity with ID: "..entid)
					SafeRemoveEntity(v)
					break
				end
			end
		end
	end)
	
end