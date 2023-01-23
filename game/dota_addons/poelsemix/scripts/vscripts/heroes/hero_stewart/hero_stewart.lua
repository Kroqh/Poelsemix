LinkLuaModifier("modifier_stun", "heroes/hero_stewart/hero_stewart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonny_boy", "heroes/hero_stewart/hero_stewart", LUA_MODIFIER_MOTION_NONE)
sonny_boy = class({})

function sonny_boy:OnSpellStart()
    if not IsServer() then return end
    -- Todo: Add sound effect
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_sonny_boy", {duration = duration})
end

modifier_sonny_boy = class({})

function modifier_sonny_boy:OnCreated()

end

function modifier_sonny_boy:IsHidden() return true end
function modifier_sonny_boy:IsPurgable() return false end

function modifier_sonny_boy:GetIntrinsicModifierName() 
    return "modifier_sonny_boy"
end

function modifier_sonny_boy:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_sonny_boy:GetModifierMoveSpeedBonus_Constant() 
    return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_sonny_boy:OnAttackLanded(keys)
    if not IsServer() then return end
    if not (keys.attacker == self:GetParent()) then return end
    local chance = self:GetAbility():GetSpecialValueFor("bashchance")
    local bash_duration = self:GetAbility():GetSpecialValueFor("bashduration")

    if RollPseudoRandom(100, self) then
        -- Todo: sound effect
        local target = keys.target
        local duration = self:GetAbility():GetSpecialValueFor("bashduration")
        target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stun", {duration = bash_duration})
    end
end

modifier_stun = class({})
function modifier_stun:IsPurgable() return false end    
function modifier_stun:IsHidden() return false end

function modifier_stun:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stun:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stun:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }
    return state
end


