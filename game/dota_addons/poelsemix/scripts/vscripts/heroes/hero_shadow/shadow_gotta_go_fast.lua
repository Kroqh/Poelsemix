shadow_gotta_go_fast = shadow_gotta_go_fast or class({})

LinkLuaModifier("modifier_shadow_gotta_go_fast", "heroes/hero_shadow/shadow_gotta_go_fast.lua", LUA_MODIFIER_MOTION_NONE)

function shadow_gotta_go_fast:GetIntrinsicModifierName()
    return "modifier_shadow_gotta_go_fast"
end

modifier_shadow_gotta_go_fast = modifier_shadow_gotta_go_fast or class({})

function modifier_shadow_gotta_go_fast:DeclareFunctions()
	local funcs	=	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_shadow_gotta_go_fast:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms_per_stack")
end

function modifier_shadow_gotta_go_fast:OnTakeDamage(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetParent() then return end
    if not self.damage_taken then self.damage_taken = true end
end

function modifier_shadow_gotta_go_fast:OnCreated()
	if not IsServer() then return end
    self.parent_last_pos = self:GetParent():GetAbsOrigin()
    self:SetStackCount(0)
    self:StartIntervalThink(0.1)
    self.damage_taken = false
    self.counter = 0
    self.distance_diff = 0
    self.fall_off = self:GetAbility():GetSpecialValueFor("fall_off")
end

function modifier_shadow_gotta_go_fast:OnIntervalThink()
    if not IsServer() then return end
    if (not self.damage_taken) then
        self.distance_diff = self.distance_diff + FindDistance(self:GetParent():GetAbsOrigin(), self.parent_last_pos)
        local distance_per_stack = self:GetAbility():GetSpecialValueFor("distance_per_stack")
        if self.distance_diff > distance_per_stack then
            local stacks_to_add = math.floor(self.distance_diff / distance_per_stack)
            self.distance_diff = self.distance_diff % distance_per_stack
            self:SetStackCount(self:GetStackCount()+stacks_to_add)
        end
    else
        self.counter = self.counter + 0.1
        if self.counter >= self.fall_off then
            self.counter = 0
            self.damage_taken = false
            self:SetStackCount(0)
        end
    end
    self.parent_last_pos = self:GetParent():GetAbsOrigin()
  end

-- Modifier properties
function modifier_shadow_gotta_go_fast:IsDebuff() 	return false end
function modifier_shadow_gotta_go_fast:IsHidden() 	return false end
function modifier_shadow_gotta_go_fast:IsPurgable() return false end
function modifier_shadow_gotta_go_fast:IsPassive() 	return true end
