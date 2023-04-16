caro_crossfit = caro_crossfit or class({})
LinkLuaModifier("modifier_caro_crossfit", "heroes/hero_caro/caro_crossfit", LUA_MODIFIER_MOTION_NONE)

function caro_crossfit:GetIntrinsicModifierName()
	return "modifier_caro_crossfit"
end

modifier_caro_crossfit = modifier_caro_crossfit or class({})

function modifier_caro_crossfit:IsPurgeable() return false end
function modifier_caro_crossfit:IsHidden() return true end
function modifier_caro_crossfit:IsPassive() return true end
function modifier_caro_crossfit:RemoveOnDeath()	return false end

function modifier_caro_crossfit:OnCreated()
    if not IsServer() then return end
    self.baseattacktimehero = self:GetParent():GetBaseAttackTime()
    self:RollStats()
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("reroll_delay"))
end

function modifier_caro_crossfit:OnIntervalThink()
	if not IsServer() then end
    self:RollStats()
end

function modifier_caro_crossfit:RollStats()
    if not IsServer() then return end
    self.as = 0
    self.ad = 0
    self.agi = 0
    self.str = 0
    self.at = 0
    points = self:GetAbility():GetSpecialValueFor("total_stats")
    if self:GetParent():HasTalent("special_bonus_caro_3") then points = points + self:GetParent():FindAbilityByName("special_bonus_caro_3"):GetSpecialValueFor("value") end
    local stats = 4
    if self:GetParent():HasTalent("special_bonus_caro_4") then stats = stats + 1 end --if talent 4, then roll attack time

    count = 0
    while (count < points) do
        local roll = math.random(stats)
        if roll == 1 then self.as = self.as + 1
        elseif roll == 2 then self.ad = self.ad + 1
        elseif roll == 3 then self.agi = self.agi + 1
        elseif roll == 4 then self.str = self.str + 1
        elseif roll == 5 then self.at = self.at + 1 end
        count = count + 1
    end
    print("Rolling")
    print(self.as)
    print(self.ad)
    print(self.agi)
    print(self.str)
    print(self.at)
end

function modifier_caro_crossfit:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
}
    return decFuncs
end
function modifier_caro_crossfit:GetModifierAttackSpeedBonus_Constant()
    if not IsServer() then return end
	return self.as
end
function modifier_caro_crossfit:GetModifierBaseAttack_BonusDamage()
    if not IsServer() then return end
    return self.ad
end
function modifier_caro_crossfit:GetModifierBonusStats_Strength()
    if not IsServer() then return end
    return self.str
end
function modifier_caro_crossfit:GetModifierBonusStats_Agility()
    if not IsServer() then return end
    return self.agi
end
function modifier_caro_crossfit:GetModifierBaseAttackTimeConstant()
    if not IsServer() then return end
    if self.at == nil then return 0 end --makes an error otherwise if it tries to execute next step with 0
    return_value = self.baseattacktimehero + (self:GetAbility():GetSpecialValueFor("attacktime_per_stack") * self.at)
	return  return_value
end 