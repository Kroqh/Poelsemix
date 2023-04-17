kazuya_rage = kazuya_rage or class({})
LinkLuaModifier("modifier_kazuya_rage_fury_handler", "heroes/hero_kazuya/kazuya_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kazuya_rage", "heroes/hero_kazuya/kazuya_rage", LUA_MODIFIER_MOTION_NONE)

function kazuya_rage:GetIntrinsicModifierName()
	return "modifier_kazuya_rage_fury_handler"
end

modifier_kazuya_rage_fury_handler = modifier_kazuya_rage_fury_handler or class({})



function modifier_kazuya_rage_fury_handler:IsPurgeable() return false end
function modifier_kazuya_rage_fury_handler:IsHidden() return false end
function modifier_kazuya_rage_fury_handler:IsPassive() return true end
function modifier_kazuya_rage_fury_handler:RemoveOnDeath()	return false end

function modifier_kazuya_rage_fury_handler:OnCreated()
	if not IsServer() then return end
    
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.fury = 0
        self:StartIntervalThink(1)
        self:GetParent():EmitSound("kazuya_intro")

end

function modifier_kazuya_rage_fury_handler:OnIntervalThink()
	if not IsServer() then end
    self:ChangeFury(self.ability:GetSpecialValueFor("fury_passively"), true)

    local threshold = self.ability:GetSpecialValueFor("rage_threshold")
    if (self.parent:HasTalent("special_bonus_kazuya_2")) then threshold = threshold + self.parent:FindAbilityByName("special_bonus_kazuya_2"):GetSpecialValueFor("value") end
    if self.parent:GetHealth() >= (self.parent:GetMaxHealth() * (threshold  / 100)) then
        if self.parent:HasModifier("modifier_kazuya_rage") then self.parent:RemoveModifierByName("modifier_kazuya_rage") end
    end

end

function modifier_kazuya_rage_fury_handler:GetEnoughFury(fury)
    return fury <= self.fury
end
function modifier_kazuya_rage_fury_handler:ChangeFury(change, multiply)
    if multiply then --apply multipliers if positive change
        multiply = 1
        if self.parent:HasModifier("modifier_kazuya_rage") then multiply = multiply + self.ability:GetSpecialValueFor("rage_fury_multi") - 1 end
        if self.parent:HasTalent("special_bonus_kazuya_3") then multiply = multiply + self.parent:FindAbilityByName("special_bonus_kazuya_3"):GetSpecialValueFor("value") - 1 end
        if self.parent:HasTalent("special_bonus_kazuya_8") then 
            if self.parent:HasModifier("modifier_kazuya_demon") then
            multiply = multiply + self.parent:FindAbilityByName("special_bonus_kazuya_8"):GetSpecialValueFor("value") - 1 
            end
        end
        change = change * multiply
    end

    self.fury = self.fury + change
    local fury_cap = self.ability:GetSpecialValueFor("fury_cap")
    if self.parent:HasTalent("special_bonus_kazuya_1") then fury_cap = fury_cap + self.parent:FindAbilityByName("special_bonus_kazuya_1"):GetSpecialValueFor("value") end
    if self.fury < 0 then self.fury = 0 elseif self.fury > fury_cap then self.fury = fury_cap end
    self:SetStackCount(math.floor(self.fury))
end
function modifier_kazuya_rage_fury_handler:OnRespawn(keys)
    if keys.unit ~= self.parent then return end
	self:GetParent():EmitSound("kazuya_intro")
end

function modifier_kazuya_rage_fury_handler:GetTexture()
	return "kazuya_fury"
end


function modifier_kazuya_rage_fury_handler:DeclareFunctions()
	local decFuncs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_RESPAWN
}
    return decFuncs
end
function modifier_kazuya_rage_fury_handler:OnTakeDamage(keys)
    if not IsServer() then return end
	if keys.unit ~= self.parent then return end
    local threshold = self.ability:GetSpecialValueFor("rage_threshold")
    if (self.parent:HasTalent("special_bonus_kazuya_2")) then threshold = threshold + self.parent:FindAbilityByName("special_bonus_kazuya_2"):GetSpecialValueFor("value") end
    if self.parent:GetHealth() <= (self.parent:GetMaxHealth() * (threshold  / 100)) then
        if not self.parent:HasModifier("modifier_kazuya_rage") then self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_kazuya_rage", {}) end
    end
end

function modifier_kazuya_rage_fury_handler:OnAttackLanded(keys)
    if not IsServer() then return end
	if keys.attacker ~= self.parent then return end
    self:ChangeFury(self.ability:GetSpecialValueFor("fury_on_hit"), true)
end


modifier_kazuya_rage = modifier_kazuya_rage or class({})

function modifier_kazuya_rage:IsPurgeable() return false end
function modifier_kazuya_rage:IsHidden() return false end

function modifier_kazuya_rage:GetStatusEffectName()
    return "particles/heroes/kazuya/rage/rage.vpcf"
end

function modifier_kazuya_rage:StatusEffectPriority()
    return 5
end

function modifier_kazuya_rage:GetTexture()
	return "kazuya_rage"
end

function modifier_kazuya_rage:OnCreated()
	if not IsServer() then return end
	self:GetParent():EmitSound("kazuya_rage_activate")
end

function modifier_kazuya_rage:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE ,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
}
    return decFuncs
end

function  modifier_kazuya_rage:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("rage_spell_amp")
end
function  modifier_kazuya_rage:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("rage_attack_damage")
end