LinkLuaModifier("modifier_gametecher_matematik_a_buff", "heroes/hero_gametecher/gametecher_matematik_a", LUA_MODIFIER_MOTION_NONE)
gametecher_matematik_a = gametecher_matematik_a or class({})


function gametecher_matematik_a:GetChannelTime()
    return self:GetSpecialValueFor("channel_time")
end

function gametecher_matematik_a:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("bonus_duration")
    
	if not IsServer() then return end
    caster:EmitSound("matematikA")

    if caster:HasModifier("modifier_gametecher_matematik_a_buff") then 
        caster:RemoveModifierByName("modifier_gametecher_matematik_a_buff")
    end --ensure proper refresh without doubling int from percentage
    caster:AddNewModifier(caster, self, "modifier_gametecher_matematik_a_buff", {duration = duration})
end


modifier_gametecher_matematik_a_buff = modifier_gametecher_matematik_a_buff or class({})

function modifier_gametecher_matematik_a_buff:IsHidden() return false end
function modifier_gametecher_matematik_a_buff:IsPurgable() return true end
function modifier_gametecher_matematik_a_buff:IsDebuff() return false end



function modifier_gametecher_matematik_a_buff:OnCreated()
    self.msloss = self:GetAbility():GetSpecialValueFor("speed_loss")
    if self:GetParent():FindAbilityByName("special_bonus_gametecher_2"):GetLevel() > 0 then self.msloss = self.msloss + self:GetCaster():FindAbilityByName("special_bonus_gametecher_2"):GetSpecialValueFor("value") end 

    if not IsServer() then return end
    local int_percent = self:GetAbility():GetSpecialValueFor("bonus_int_percent")
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_gametecher_dropout_stacks") then 
        local mod = caster:FindModifierByName("modifier_gametecher_dropout_stacks")

        local int_per_stack = self:GetAbility():GetSpecialValueFor("bonus_int_percent_per_dropout")

        if self:GetCaster():FindAbilityByName("special_bonus_gametecher_4"):GetLevel() > 0 then int_per_stack = int_per_stack + self:GetCaster():FindAbilityByName("special_bonus_gametecher_4"):GetSpecialValueFor("value") end 
        int_percent = int_percent + (mod:GetStackCount() * int_per_stack)
    end
    self.int = (int_percent/100) * caster:GetIntellect(true)
    
end

function modifier_gametecher_matematik_a_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT

	}
	return funcs
end
function modifier_gametecher_matematik_a_buff:GetModifierMoveSpeedBonus_Constant()
	return self.msloss
end

function modifier_gametecher_matematik_a_buff:GetModifierBonusStats_Intellect()
    if not self:GetAbility() then return end
	return self.int
end

function modifier_gametecher_matematik_a_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_gametecher_matematik_a_buff:GetEffectName()
	return "particles/units/heroes/hero_gametecher/mat_a.vpcf"
end