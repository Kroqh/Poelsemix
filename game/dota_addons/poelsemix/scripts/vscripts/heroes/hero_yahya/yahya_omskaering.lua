LinkLuaModifier("modifier_yahya_omskaering", "heroes/hero_yahya/yahya_omskaering", LUA_MODIFIER_MOTION_NONE)
yahya_omskaering= yahya_omskaering or class({})

function yahya_omskaering:OnSpellStart()
    
    local caster = self:GetCaster()
    self.duration = self:GetSpecialValueFor("duration")
    
	if IsServer() then  
		EmitSoundOn("min_er_flot", caster)
        caster:AddNewModifier(caster, self, "modifier_yahya_omskaering", {duration = self.duration})
	end
end
modifier_yahya_omskaering = modifier_yahya_omskaering or class({})

function modifier_yahya_omskaering:IsBuff() return true end


function modifier_yahya_omskaering:OnCreated()
    self.str = self:GetCaster():GetStrength()
    self.multiplier = self:GetSpecialValueFor("str_to_agi_ratio")
    if not IsServer() then return end
    self:GetCaster():SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)
end
function modifier_yahya_omskaering:OnRemoved()
    if not IsServer() then return end
    self:GetCaster():SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
end

function modifier_yahya_omskaering:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_EVENT_ON_HERO_KILLED}
	return decFuncs
end
function modifier_yahya_omskaering:GetModifierBonusStats_Agility()
    return self.str * self.multiplier
end

function modifier_yahya_omskaering:GetModifierBonusStats_Strength()
    if self:GetCaster():FindAbilityByName("special_bonus_yahya_8"):GetLevel() > 0 then return (-self.str + (self.str * (self:GetCaster():FindAbilityByName("special_bonus_yahya_8"):GetSpecialValueFor("value") / 100))) end
    return -self.str
end
function modifier_yahya_omskaering:GetModifierBaseAttackTimeConstant()
    if self:GetCaster():FindAbilityByName("special_bonus_yahya_4"):GetLevel() > 0 then return self:GetAbility():GetSpecialValueFor("base_attack_time") + self:GetCaster():FindAbilityByName("special_bonus_yahya_4"):GetSpecialValueFor("value") end
	return self:GetAbility():GetSpecialValueFor("base_attack_time")
end 
function modifier_yahya_omskaering:OnHeroKilled(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end
    if self:GetCaster():HasScepter() then 
        self:SetDuration(self:GetAbility().duration, true) 
        EmitSoundOn("yahya_onkill", self:GetCaster())
    end
end
function modifier_yahya_omskaering:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_yahya_omskaering:GetEffectName()
    return "particles/units/heroes/hero_yahya/yahya_omskaering.vpcf"
end