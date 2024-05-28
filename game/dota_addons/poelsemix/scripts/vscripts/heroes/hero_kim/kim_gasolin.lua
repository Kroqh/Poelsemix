LinkLuaModifier("kim_gasolin_thinker", "heroes/hero_kim/kim_gasolin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("kim_gasolin_night", "heroes/hero_kim/kim_gasolin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("kim_gasolin_day", "heroes/hero_kim/kim_gasolin", LUA_MODIFIER_MOTION_NONE)
kim_gasolin = kim_gasolin or class({})


function kim_gasolin:GetIntrinsicModifierName()
	return "kim_gasolin_thinker"
end

kim_gasolin_thinker = kim_gasolin_thinker or class({});

function kim_gasolin_thinker:IsPurgable() return false end
function kim_gasolin_thinker:IsHidden() return true end
function kim_gasolin_thinker:IsPassive() return true end
function kim_gasolin_thinker:RemoveOnDeath()	return false end

function kim_gasolin_thinker:OnCreated()
	if not IsServer() then return end
        self:StartIntervalThink(0.1)
end

function kim_gasolin_thinker:OnIntervalThink()
	if not IsServer() then return end
    local caster = self:GetCaster()
    if not caster:IsAlive() then return end
	local ability = self:GetAbility()
    local mod_night = "kim_gasolin_night"
    local mod_day = "kim_gasolin_day"

	if not GameRules:IsDaytime() then
        if caster:HasModifier(mod_day) then caster:RemoveModifierByName(mod_day) end
        caster:AddNewModifier(caster, ability, "kim_gasolin_night", {} )
        
	else
		if caster:HasModifier(mod_night) then caster:RemoveModifierByName(mod_night) end
        caster:AddNewModifier(caster, ability, "kim_gasolin_day", {} )
	end
end



kim_gasolin_night = kim_gasolin_night or class({});

function kim_gasolin_night:IsPurgable() return false end
function kim_gasolin_night:IsHidden() return false end
function kim_gasolin_night:IsDebuff() return false end
function kim_gasolin_night:RemoveOnDeath() return false end

function kim_gasolin_night:OnCreated()
    if not IsServer() then return end
    local change_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(change_fx)
    EmitAnnouncerSoundForPlayer("kim_gasolin_nat", self:GetCaster():GetPlayerID())

end

function kim_gasolin_night:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,

	}
	return funcs
end
function kim_gasolin_night:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("statboost")
end
function kim_gasolin_night:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("statboost")
end
function kim_gasolin_night:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("statboost")
end

function kim_gasolin_night:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end
function kim_gasolin_night:GetEffectName()
	return "particles/units/heroes/hero_kimr/kim_gasolin_nat.vpcf"
end


kim_gasolin_day = kim_gasolin_day or class({});

function kim_gasolin_day:IsPurgable() return false end
function kim_gasolin_day:IsHidden() return false end
function kim_gasolin_day:IsDebuff() return true end
function kim_gasolin_day:RemoveOnDeath() return false end

function kim_gasolin_day:OnCreated()
    if not IsServer() then return end
    local change_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(change_fx)
    EmitAnnouncerSoundForPlayer("kim_gasolin_dag", self:GetCaster():GetPlayerID())

end

function kim_gasolin_day:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end
function kim_gasolin_day:GetModifierBonusStats_Agility()
    local stats = 0
    if self:GetCaster():FindAbilityByName("special_bonus_kim_4"):GetLevel() > 0 then stats = self:GetAbility():GetSpecialValueFor("statboost") * (self:GetCaster():FindAbilityByName("special_bonus_kim_4"):GetSpecialValueFor("value")/100)end 
	return stats
end
function kim_gasolin_day:GetModifierBonusStats_Strength()
	local stats = 0
    if self:GetCaster():FindAbilityByName("special_bonus_kim_4"):GetLevel() > 0 then stats = self:GetAbility():GetSpecialValueFor("statboost") * (self:GetCaster():FindAbilityByName("special_bonus_kim_4"):GetSpecialValueFor("value")/100)end 
	return stats
end
function kim_gasolin_day:GetModifierBonusStats_Intellect()
	local stats = 0
    if self:GetCaster():FindAbilityByName("special_bonus_kim_4"):GetLevel() > 0 then stats = self:GetAbility():GetSpecialValueFor("statboost") * (self:GetCaster():FindAbilityByName("special_bonus_kim_4"):GetSpecialValueFor("value")/100)end 
	return stats
end