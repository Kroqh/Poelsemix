
modifier_item_flaeskesteg_healing = modifier_item_flaeskesteg_healing or class({})
function modifier_item_flaeskesteg_healing:IsHidden()		return false end
function modifier_item_flaeskesteg_healing:IsPurgable()		return false end
function modifier_item_flaeskesteg_healing:RemoveOnDeath()	return false end

function modifier_item_flaeskesteg_healing:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
end


function modifier_item_flaeskesteg_healing:OnCreated(kv)
	if not IsServer() then return end
	self.icon = kv.icon
	self.healing = kv.healing
	self:SetHasCustomTransmitterData(true)
	self:StartIntervalThink(FrameTime())
end

function modifier_item_flaeskesteg_healing:OnIntervalThink(kv)
	if not IsServer() then return end
	local parent = self:GetParent()
	local particle_self = "particles/items/fleskesteg/fleskesteg.vpcf"
    local pfx_fire = ParticleManager:CreateParticle(particle_self, PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(pfx_fire, 0,  parent:GetAbsOrigin())
	self:StartIntervalThink(1)

end

function modifier_item_flaeskesteg_healing:OnRefresh(kv)
	if not IsServer() then return end
	self.icon = kv.icon
	self.healing = kv.healing
	self:SetHasCustomTransmitterData(true)
end

function modifier_item_flaeskesteg_healing:AddCustomTransmitterData()
    return {
        icon = self.icon,
        healing = self.healing

    }
end

function modifier_item_flaeskesteg_healing:HandleCustomTransmitterData( data )
    self.icon = data.icon
    self.healing = data.healing
end

function modifier_item_flaeskesteg_healing:GetModifierHealthRegenPercentage()
    return self.healing
end


function modifier_item_flaeskesteg_healing:GetTexture()
	if self.icon == 0 then
		return "flaeskesteg"
	elseif self.icon == 1 then
		return "flaeskesteg_sovs_kartofler"
	end
end