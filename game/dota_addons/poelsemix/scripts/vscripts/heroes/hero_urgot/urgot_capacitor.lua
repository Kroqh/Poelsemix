--Start på W herfra
urgot_capacitor = urgot_capacitor or class({})
LinkLuaModifier("modifier_urgot_capacitor", "heroes/hero_urgot/urgot_capacitor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_urgot_capacitor_slow", "heroes/hero_urgot/urgot_capacitor", LUA_MODIFIER_MOTION_NONE)

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

function modifier_urgot_capacitor:OnCreated()

    local value = self:GetAbility():GetSpecialValueFor("shield_health")
	if self:GetCaster():FindAbilityByName("special_bonus_urgot_3"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_urgot_3"):GetSpecialValueFor("value") end
    self.shield = value
    self:SetHasCustomTransmitterData(true)
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end


function modifier_urgot_capacitor:OnRefresh()

    local value = self:GetAbility():GetSpecialValueFor("shield_health")
	if self:GetCaster():FindAbilityByName("special_bonus_urgot_3"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_urgot_3"):GetSpecialValueFor("value") end
    self.shield = value

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
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end


function modifier_urgot_capacitor:OnAttackLanded(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
            local slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
			keys.target:AddNewModifier(parent, self:GetAbility(), "modifier_urgot_capacitor_slow", {duration = slow_duration})
		end
	end
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


modifier_urgot_capacitor_slow = modifier_urgot_capacitor_slow or class({})

function modifier_urgot_capacitor_slow:OnCreated()
    self.slow = -self:GetAbility():GetSpecialValueFor("slow_percent")
end

function modifier_urgot_capacitor_slow:IsPurgable() return true end
function modifier_urgot_capacitor_slow:IsHidden() return false end
function modifier_urgot_capacitor_slow:IsDebuff() return true end

function modifier_urgot_capacitor_slow:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_urgot_capacitor_slow:GetModifierMoveSpeedBonus_Percentage()
	if self.slow ~= nil then return self.slow end 
end