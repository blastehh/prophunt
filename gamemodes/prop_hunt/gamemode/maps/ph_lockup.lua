if SERVER then

	hook.Add("PostCleanupMap","WeaponRoomRemover",function()

		crates = ents.FindByClass("item_ammo_crate")
		buttons = ents.FindByClass("func_button")

		for k,v in pairs(buttons) do
			local entid = v:EntIndex()
			print("Removing button entity with ID: "..entid)
			SafeRemoveEntity(v)
		end
		
		for k,v in pairs(crates) do
			local entid = v:EntIndex()
			print("Removing crate entity with ID: "..entid)
			SafeRemoveEntity(v)
		end

	end)
	
end