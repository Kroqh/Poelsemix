LinkLuaModifier("modifier_pro_deity_stat_remove", "heroes/hero_pr0ph3cy/prophecy_deity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pro_deity_stat_gain", "heroes/hero_pr0ph3cy/prophecy_deity", LUA_MODIFIER_MOTION_NONE)
pr0_deity = pr0_deity or class({})

function pr0_deity:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_prophecy_3"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_prophecy_3"):GetSpecialValueFor("value") end
    return cd
end

function pr0_deity:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
        EmitSoundOnClient("pr0_ult", caster:GetPlayerOwner())
		EmitSoundOnClient("pr0_d31ty", caster:GetPlayerOwner())

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags() , FIND_ANY_ORDER, false)
		for i, unit in pairs(targets) do
			EmitSoundOnClient("pr0_ult", unit:GetPlayerOwner())
			EmitSoundOnClient("pr0_d31ty", unit:GetPlayerOwner())
			unit:AddNewModifier(caster, self, "modifier_pro_deity_stat_remove", {duration = duration})
		end
		caster:AddNewModifier(caster, self, "modifier_pro_deity_stat_gain", {duration = duration})
	end
end

modifier_pro_deity_stat_gain = modifier_pro_deity_stat_gain or class({})

function modifier_pro_deity_stat_gain:IsHidden()		return false end
function modifier_pro_deity_stat_gain:IsPurgable()		return true end
function modifier_pro_deity_stat_gain:IsDebuff()		return false end


function modifier_pro_deity_stat_gain:OnCreated()
	self.int = self:GetAbility():GetSpecialValueFor("int_gain")
end

function modifier_pro_deity_stat_gain:OnRefresh()
	self.int = self:GetAbility():GetSpecialValueFor("int_gain")
end
function modifier_pro_deity_stat_gain:DeclareFunctions()
	local funcs = {
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
					}
	return funcs
end
function modifier_pro_deity_stat_gain:GetModifierBonusStats_Intellect()	return self.int end

modifier_pro_deity_stat_remove = modifier_pro_deity_stat_remove or class({})


function modifier_pro_deity_stat_remove:IsHidden()		return false end
function modifier_pro_deity_stat_remove:IsPurgable()		return true end
function modifier_pro_deity_stat_remove:IsDebuff()		return true end


function modifier_pro_deity_stat_remove:OnCreated()
	self.stat_loss = self:GetAbility():GetSpecialValueFor("stat_loss")
	if self:GetCaster():FindAbilityByName("special_bonus_prophecy_8"):GetLevel() > 0 then self.stat_loss = self.stat_loss + self:GetCaster():FindAbilityByName("special_bonus_prophecy_8"):GetSpecialValueFor("value") end
end
function modifier_pro_deity_stat_remove:OnRefresh()
	self.stat_loss = self:GetAbility():GetSpecialValueFor("stat_loss")
	if self:GetCaster():FindAbilityByName("special_bonus_prophecy_8"):GetLevel() > 0 then self.stat_loss = self.stat_loss + self:GetCaster():FindAbilityByName("special_bonus_prophecy_8"):GetSpecialValueFor("value") end
end

function modifier_pro_deity_stat_remove:DeclareFunctions()
	local funcs = {
                    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                    MODIFIER_PROPERTY_STATS_AGILITY_BONUS
					}
	return funcs
end
function modifier_pro_deity_stat_remove:GetModifierBonusStats_Intellect() return self.stat_loss end
function modifier_pro_deity_stat_remove:GetModifierBonusStats_Agility() return self.stat_loss end
function modifier_pro_deity_stat_remove:GetModifierBonusStats_Strength() return self.stat_loss end

function modifier_pro_deity_stat_remove:GetEffectName()
    return "particles/units/heroes/hero_prophecy/deity_hack_effect.vpcf"
end

function modifier_pro_deity_stat_remove:GetStatusEffectName()
	return "particles/pro/deity_hack.vpcf"
end
function modifier_pro_deity_stat_remove:StatusEffectPriority()
	return 20
end



