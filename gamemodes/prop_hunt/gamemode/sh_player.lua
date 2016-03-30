-- Finds the player meta table or terminates
local meta = FindMetaTable("Player")
if !meta then return end


-- Blinds the player by setting view out into the void
function meta:Blind(bool)
	if !IsValid(self) then return end
	
	if SERVER then
		net.Start("SetBlind")
			net.WriteBit(bool)
		net.Send(self)
		self.isBlind = bool
	elseif CLIENT then
		blind = bool
	end
end

function meta:IsBlind()
	return false or self.isBlind
end

-- Blinds the player by setting view out into the void
function meta:RemoveProp()
	if CLIENT || !self:IsValid() then return end
	
	if self.ph_prop && self.ph_prop:IsValid() then
		self.ph_prop:Remove()
		self.ph_prop = nil
	end
end