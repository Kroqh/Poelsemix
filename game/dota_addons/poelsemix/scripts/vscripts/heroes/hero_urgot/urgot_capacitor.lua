--Start på W herfra
urgot_capacitor = urgot_capacitor or class({})
LinkLuaModifier("modifier_urgot_capacitor", "heroes/hero_urgot/urgot_capacitor", LUA_MODIFIER_MOTION_NONE)

function urgot_capacitor:OnSpellStart()
    if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	



	EmitSoundOn("urgotW", caster)

	caster:AddNewModifier(caster, self, "modifier_urgot_capacitor", {duration = duration})
end



modifier_urgot_capacitor = modifier_urgot_capacitor or class ({})

function modifier_urgot_capacitor:IsDebuff() return false end
function modifier_urgot_capacitor:IsHidden() return false end
function modifier_urgot_capacitor:IsPurgable() return true end

function modifier_urgot_capacitor:GetEffectName()
	return "particles/econ/items/urgot/capacitor.vpcf"
end

function modifier_urgot_capacitor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_urgot_capacitor:OnCreated(keys)
    self.shield = self:GetAbility():GetSpecialValueFor("shield_health")
    self:SetHasCustomTransmitterData(true)
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end



function modifier_urgot_capacitor:GetModifierIncomingDamageConstant(event)
    if not IsServer() then return self.shield end
    if self:GetParent() == event.target then
            local new_shield =  self.shield - event.damage
            local change = abs(new_shield - self.shield)
            self.shield = self.shield - change
            local damage = event.damage+self.shield
            if new_shield <= 0 then self:GetParent():RemoveModifierByName("modifier_urgot_capacitor") end
            if self.shield <= 0 then return -event.damage + damage else return -event.damage end
            --cursed but seems to work
    end
    return 0
end


function modifier_urgot_capacitor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
	return funcs
end


function modifier_urgot_capacitor:OnIntervalThink()
    self:SendBuffRefreshToClients()
    
end
function modifier_urgot_capacitor:AddCustomTransmitterData()
    return {
        shield = self.shield,
    }
end
function modifier_urgot_capacitor:HandleCustomTransmitterData( data )
    self.shield = data.shield
end
