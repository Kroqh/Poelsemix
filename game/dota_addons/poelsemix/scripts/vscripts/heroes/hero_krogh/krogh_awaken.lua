awaken = awaken or class({})
LinkLuaModifier("modifier_awaken", "heroes/hero_krogh/krogh_awaken", LUA_MODIFIER_MOTION_NONE)

function awaken:GetIntrinsicModifierName()
	return "modifier_awaken"
end

function awaken:OnUpgrade()
	if not IsServer() then return end
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)
    self:GetCaster():EmitSound("awaken")
end

modifier_awaken = modifier_awaken or class({})

function modifier_awaken:IsPurgable() return false end
function modifier_awaken:IsHidden() return true end
function modifier_awaken:IsPassive() return true end
function modifier_awaken:RemoveOnDeath()	return false end

function modifier_awaken:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_MODEL_SCALE
}
    return decFuncs
end

function modifier_awaken:GetModifierAttackRangeBonus()
    if not IsServer() then return end
	local value = self:GetAbility():GetSpecialValueFor("attack_range")
    if self:GetParent():HasTalent("special_bonus_krogh_3") then value = value + self:GetParent():FindAbilityByName("special_bonus_krogh_3"):GetSpecialValueFor("value") end
    return value
end
function modifier_awaken:GetModifierBaseAttack_BonusDamage()
    if not IsServer() then return end
    local value = self:GetAbility():GetSpecialValueFor("attack_damage")
    if self:GetParent():HasTalent("special_bonus_krogh_3") then value = value + self:GetParent():FindAbilityByName("special_bonus_krogh_3"):GetSpecialValueFor("value") end
    return value
end
function modifier_awaken:GetModifierBonusStats_Strength()
    if not IsServer() then return end
    local value = self:GetAbility():GetSpecialValueFor("strength")
    if self:GetParent():HasTalent("special_bonus_krogh_3") then value = value * self:GetParent():FindAbilityByName("special_bonus_krogh_3"):GetSpecialValueFor("value") end
    return value
end
function modifier_awaken:GetModifierBonusStats_Agility()
    if not IsServer() then return end
    local value = self:GetAbility():GetSpecialValueFor("agility")
    if self:GetParent():HasTalent("special_bonus_krogh_3") then value = value * self:GetParent():FindAbilityByName("special_bonus_krogh_3"):GetSpecialValueFor("value") end
    return value
end
function modifier_awaken:GetModifierModelScale()
    if not IsServer() then return end
    local value = self:GetAbility():GetSpecialValueFor("model_scale")
    if self:GetParent():HasTalent("special_bonus_krogh_3") then value = value * self:GetParent():FindAbilityByName("special_bonus_krogh_3"):GetSpecialValueFor("value") end
    return value
end