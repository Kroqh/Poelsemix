LinkLuaModifier("modifier_stewart_ask_for_help", "heroes/hero_stewart/stewart_ask_for_help", LUA_MODIFIER_MOTION_NONE)
stewart_ask_for_help = stewart_ask_for_help or class({})


function stewart_ask_for_help:GetCastRange()
    local value = self:GetSpecialValueFor("radius")
    return value
end

function stewart_ask_for_help:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("stewart_sporg_om_hjalp")
    caster:AddNewModifier(caster, self, "modifier_stewart_ask_for_help", {duration = duration})
end



modifier_stewart_ask_for_help = modifier_stewart_ask_for_help or class({})

function modifier_stewart_ask_for_help:IsPurgable() return false end

function modifier_stewart_ask_for_help:OnCreated()
    self.stats_per_hero = self:GetAbility():GetSpecialValueFor("str_per_hero")
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_4"):GetLevel() > 0 then self.stats_per_hero = self.stats_per_hero + self:GetCaster():FindAbilityByName("special_bonus_stewart_4"):GetSpecialValueFor("value") end 
    if not IsServer() then return end

    self:StartIntervalThink(0.2)
end

function modifier_stewart_ask_for_help:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_stewart_ask_for_help:OnIntervalThink()
    local caster = self:GetCaster()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(),self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    
    self:SetStackCount(#heroes-1) -- -1 to not count himself

end

function modifier_stewart_ask_for_help:OnRefresh()
    self.stats_per_hero = self:GetAbility():GetSpecialValueFor("str_per_hero")
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_4"):GetLevel() > 0 then self.stats_per_hero = self.stats_per_hero + self:GetCaster():FindAbilityByName("special_bonus_stewart_4"):GetSpecialValueFor("value") end 
    if not IsServer() then return end
end

function modifier_stewart_ask_for_help:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self.stats_per_hero
end

function modifier_stewart_ask_for_help:GetStatusEffectName()
	return "particles/status_fx/status_effect_overpower.vpcf"
end
function modifier_stewart_ask_for_help:StatusEffectPriority()
	return 6
end