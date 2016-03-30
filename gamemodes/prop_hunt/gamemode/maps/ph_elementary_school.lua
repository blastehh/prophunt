if SERVER then
	local doRemove = {
		["item_healthkit"] = true,
		["item_healthvial"] = true
	}
	hook.Add("PostCleanupMap","HealthKits",function()

		for k,v in pairs(ents.GetAll()) do
			if doRemove[v:GetClass()] then
				local entid = v:EntIndex()
				print("Removing entity with ID: "..entid)
				SafeRemoveEntity(v)
			end
		end

	end)
	
end