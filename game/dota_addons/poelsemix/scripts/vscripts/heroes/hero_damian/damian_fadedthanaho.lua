LinkLuaModifier("modifier_damian_fadedthanaho_passive", "heroes/hero_damian/damian_fadedthanaho", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_fadedthanaho_stack", "heroes/hero_damian/damian_fadedthanaho", LUA_MODIFIER_MOTION_NONE)

damian_fadedthanaho = damian_fadedthanaho or class({})
baseattacktimehero = 0
function damian_fadedthanaho:GetIntrinsicModifierName()
	return "modifier_damian_fadedthanaho_passive"
end

modifier_damian_fadedthanaho_passive = modifier_damian_fadedthanaho_passive or class({})

function modifier_damian_fadedthanaho_passive:IsPurgeable() return false end
function modifier_damian_fadedthanaho_passive:IsHidden() return true end
function modifier_damian_fadedthanaho_passive:IsPassive() return true end
function modifier_damian_fadedthanaho_passive:RemoveOnDeath()	return false end


function modifier_damian_fadedthanaho_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function modifier_damian_fadedthanaho_passive:OnCreated()
    if not IsServer() then return end
    baseattacktimehero = self:GetParent():GetBaseAttackTime()
end
function modifier_damian_fadedthanaho_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
	if (params.attacker ~= parent) then return end 
    if parent:HasModifier("modifier_damian_faded_pooped") then return end

    local rand = RandomFloat(1, 100)
    local chance = ability:GetSpecialValueFor("base_chance")
    if self:GetCaster():FindAbilityByName("special_bonus_damian_1"):GetLevel() > 0 then chance = chance + self:GetCaster():FindAbilityByName("special_bonus_damian_1"):GetSpecialValueFor("value") end
    
    local multi = ability:GetSpecialValueFor("faded_chance_multi")
    
    if self:GetCaster():FindAbilityByName("special_bonus_damian_2"):GetLevel() > 0 then multi = multi + self:GetCaster():FindAbilityByName("special_bonus_damian_2"):GetSpecialValueFor("value") end
    chance = chance + (parent:FindModifierByName("modifier_damian_faded"):GetStackCount() * multi)
    
    if rand <= chance then
        mod = parent:FindModifierByName("modifier_damian_fadedthanaho_stack")
        if mod ~= nil then
            stackcap = ability:GetSpecialValueFor("max_stacks")
            if self:GetCaster():HasTalent("special_bonus_damian_5") then stackcap = stackcap + self:GetCaster():FindAbilityByName("special_bonus_damian_5"):GetSpecialValueFor("value") end
            if mod:GetStackCount() < stackcap then
                mod:SetStackCount(mod:GetStackCount()+1)
                parent:EmitSound("damian_fadedthanaho")
                mod2= parent:FindModifierByName("modifier_damian_faded")
                mod2:SetStackCount(mod2:GetStackCount()+ability:GetSpecialValueFor("faded_stacks_gained"))
            end    
        else
            mod = parent:AddNewModifier(parent, ability,"modifier_damian_fadedthanaho_stack",{})
            mod:SetStackCount(1)
            parent:EmitSound("damian_fadedthanaho")
            mod2= parent:FindModifierByName("modifier_damian_faded")
            mod2:SetStackCount(mod2:GetStackCount()+ability:GetSpecialValueFor("faded_stacks_gained"))
        end

    end
end

modifier_damian_fadedthanaho_stack = modifier_damian_fadedthanaho_stack or class({})

function modifier_damian_fadedthanaho_stack:IsPurgeable() return false end
function modifier_damian_fadedthanaho_stack:IsHidden() return false end
function modifier_damian_fadedthanaho_stack:RemoveOnDeath()	return true end


function modifier_damian_fadedthanaho_stack:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
}
	
	return decFuncs
end
function modifier_damian_fadedthanaho_stack:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("stack_falloff"))
end 

function modifier_damian_fadedthanaho_stack:GetModifierBaseAttackTimeConstant()
    if not IsServer() then return end
    local return_value = baseattacktimehero + (self:GetAbility():GetSpecialValueFor("base_attack_time_buff_per_stack") * self:GetStackCount())
	return  return_value
end 

function modifier_damian_fadedthanaho_stack:GetModifierBaseAttack_BonusDamage()
    if not IsServer() then return end
	return self:GetAbility():GetSpecialValueFor("damage_per_stack") * self:GetStackCount()
end

function modifier_damian_fadedthanaho_stack:OnIntervalThink()
    if not IsServer() then return end

    self:DecrementStackCount()
    if self:GetStackCount() == 0 then self:Destroy() end

end