ha_rune = ha_rune or class({})
LinkLuaModifier("modifier_harald_rune_aura_emitter", "heroes/hero_harald/harald_runesten", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rune_buff", "heroes/hero_harald/harald_runesten", LUA_MODIFIER_MOTION_NONE)


function ha_rune:OnAbilityPhaseStart()
    if not IsServer() then return end
    caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    
    unit = CreateUnitByName("npc_rune",target_point, true, caster, nil, caster:GetTeam()) 
    
    unit:AddNewModifier(caster, nil, "modifier_invisible", { duration = 0.3 })
    unit:FaceTowards(caster:GetAbsOrigin())
    EmitSoundOn("ha_rune", caster)
    local duration = self:GetSpecialValueFor("duration")
    if caster:HasTalent("special_bonus_harald_6") then duration = duration + caster:FindAbilityByName("special_bonus_harald_6"):GetSpecialValueFor("value") end

    self:StartCooldown(self:GetCooldown(self:GetLevel())) --avoid fuckery with castpoints not trigger cd if stunned or something while placing
    self:PayManaCost()

    Timers:CreateTimer({
        endTime = 0.3,
        callback = function() 
            unit:AddNewModifier(caster, self, "modifier_harald_rune_aura_emitter", { duration = duration} )
            unit:AddNewModifier(caster, self, "modifier_kill", { duration = duration + 0.1 } )
            
           
        end
        }) --Giving it some leverage
end

modifier_harald_rune_aura_emitter = modifier_harald_rune_aura_emitter or class({})
function modifier_harald_rune_aura_emitter:IsHidden()		return true end
function modifier_harald_rune_aura_emitter:IsPurgable()		return false end
function modifier_harald_rune_aura_emitter:IsAura()		return true end
function modifier_harald_rune_aura_emitter:GetAuraRadius() 
    if not IsServer() then return end
    local radius = self:GetAbility():GetSpecialValueFor("aura_radius") 
    if caster:HasTalent("special_bonus_harald_5") then radius = radius + caster:FindAbilityByName("special_bonus_harald_5"):GetSpecialValueFor("value") end
    return radius
end
    
function modifier_harald_rune_aura_emitter:GetAuraSearchTeam()	return self:GetAbility():GetAbilityTargetTeam() end
function modifier_harald_rune_aura_emitter:GetAuraSearchType()	return self:GetAbility():GetAbilityTargetType() end
function modifier_harald_rune_aura_emitter:GetModifierAura()			return  "modifier_rune_buff" end
function modifier_harald_rune_aura_emitter:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end

function modifier_harald_rune_aura_emitter:OnDestroy()
    if not IsServer() then return end
    self:GetParent():AddNoDraw()

end

modifier_rune_buff = modifier_rune_buff or class({})
function modifier_rune_buff:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_rune_buff:IsHidden()		return false end
function modifier_rune_buff:IsPurgable()		return false end

function modifier_rune_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT

	}
end

function  modifier_rune_buff:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("aura_damage")
end
function modifier_rune_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aura_attackspeed")
end
function modifier_rune_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aura_movespeed")
end


function modifier_rune_buff:GetEffectName()
    return "particles/econ/harald/runesten.vpcf"
end