LinkLuaModifier("modifier_harald_convert","heroes/hero_harald/harald_convert.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_harald_convert_bonus","heroes/hero_harald/harald_convert.lua",LUA_MODIFIER_MOTION_NONE)

ha_convert = ha_convert or class({})

function ha_convert:OnAbilityPhaseStart() --doesnt auto start for some reason
	--self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2)
end

function ha_convert:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("ha_fader")
    if caster:HasTalent("special_bonus_harald_7") then duration = duration + caster:FindAbilityByName("special_bonus_harald_7"):GetSpecialValueFor("value")  end
    target:AddNewModifier(caster, self, "modifier_harald_convert", {duration = duration})
end


modifier_harald_convert = modifier_harald_convert or class({})

function modifier_harald_convert:IsPurgable() return true end
function modifier_harald_convert:GetTexture() return "ha_convert" end
function modifier_harald_convert:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_harald_convert:GetAuraSearchTeam()	return self:GetAbility():GetAbilityTargetTeam() end
function modifier_harald_convert:GetAuraSearchType()	return DOTA_UNIT_TARGET_BASIC end
function modifier_harald_convert:GetModifierAura()			return  "modifier_harald_convert_bonus" end
function modifier_harald_convert:IsAura()
    if not IsServer() then return end
    if self:GetCaster():HasTalent("special_bonus_harald_8") then return true end
end

function modifier_harald_convert:GetAuraRadius()
    if not IsServer() then return end
    return self:GetCaster():FindAbilityByName("special_bonus_harald_8"):GetSpecialValueFor("value")
end

function modifier_harald_convert:DeclareFunctions()
	local funcs = {
		 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL
	}
	return funcs
end
function modifier_harald_convert:GetEffectName() return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf" end
function modifier_harald_convert:GetStatusEffectName() return "particles/status_fx/status_effect_guardian_angel.vpcf" end
function modifier_harald_convert:StatusEffectPriority() return 2 end

modifier_harald_convert_bonus = modifier_harald_convert_bonus or class({})

function modifier_harald_convert_bonus:GetTexture() return "ha_convert" end
function modifier_harald_convert_bonus:GetAbsoluteNoDamagePhysical() return 1 end

function modifier_harald_convert_bonus:DeclareFunctions()
	local funcs = {
		 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL
	}
	return funcs
end

function modifier_harald_convert_bonus:GetStatusEffectName() return "particles/status_fx/status_effect_guardian_angel.vpcf" end
function modifier_harald_convert_bonus:StatusEffectPriority() return 2 end