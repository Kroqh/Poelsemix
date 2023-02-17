LinkLuaModifier("modifier_damian_faded_pooped", "heroes/hero_damian/damian_faded", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_faded_max_stack_tracker", "heroes/hero_damian/damian_faded", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_faded", "heroes/hero_damian/damian_faded", LUA_MODIFIER_MOTION_NONE)


damian_faded = damian_faded or class({})
function damian_faded:GetIntrinsicModifierName()
	return "modifier_damian_faded"
end

modifier_damian_faded = modifier_damian_faded or class({})

function modifier_damian_faded:IsPurgeable() return false end
function modifier_damian_faded:IsHidden() return false end
function modifier_damian_faded:IsPassive() return true end
function modifier_damian_faded:RemoveOnDeath()	return false end

function modifier_damian_faded:OnDeath()
    if not IsServer() then return end
    self:SetStackCount(0)
end
function modifier_damian_faded:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}

	return funcs
end
function modifier_damian_faded:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("ms_per_stack") * self:GetStackCount()
end
function modifier_damian_faded:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("agi_per_stack") * self:GetStackCount()
end

function modifier_damian_faded:OnCreated()
    if not IsServer() then return end
    parent = self:GetParent()
    self.mod = parent:AddNewModifier(parent,self:GetAbility(),"modifier_damian_faded_max_stack_tracker", {})
    self.mod:SetStackCount(self:GetAbility():GetSpecialValueFor("base_max_stacks"))
end

function modifier_damian_faded:OnStackCountChanged(old)
    if not IsServer() then return end
    if self:GetStackCount() >= self.mod:GetStackCount() then
            local parent = self:GetParent()
            print("poopy time")
            parent:EmitSound("damian_poop")
            self:SetStackCount(0)
            if parent:HasModifier("modifier_damian_fadedthanaho_stack") then parent:RemoveModifierByName("modifier_damian_fadedthanaho_stack") end

            duration = self:GetAbility():GetSpecialValueFor("poop_duration")
            if parent:HasTalent("special_bonus_damian_2") then duration = duration + parent:FindAbilityByName("special_bonus_damian_2"):GetSpecialValueFor("value") end 
            parent:AddNewModifier(parent,self:GetAbility(),"modifier_damian_faded_pooped", {duration = duration})
    end
end

modifier_damian_faded_max_stack_tracker = modifier_damian_faded_max_stack_tracker or class({})

function modifier_damian_faded_max_stack_tracker:IsPurgeable() return false end
function modifier_damian_faded_max_stack_tracker:IsHidden() return false end
function modifier_damian_faded_max_stack_tracker:IsPassive() return true end
function modifier_damian_faded_max_stack_tracker:RemoveOnDeath() return false end


modifier_damian_faded_pooped= modifier_damian_faded_pooped or class({})

function modifier_damian_faded_pooped:IsPurgeable() return true end
function modifier_damian_faded_pooped:IsHidden() return false end
function modifier_damian_faded_pooped:RemoveOnDeath() return true end
function modifier_damian_faded_pooped:IsDebuff() return true end

function modifier_damian_faded_pooped:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end
function modifier_damian_faded_pooped:GetStatusEffectName()
	return "particles/heroes/damian/damian_poop.vpcf"
end
function modifier_damian_faded_pooped:StatusEffectPriority()
	return 11
end
function modifier_damian_faded_pooped:GetTexture()
    return "damian_shit"
end