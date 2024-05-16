LinkLuaModifier("modifier_stewart_sonny_boy", "heroes/hero_stewart/stewart_sonny_boy", LUA_MODIFIER_MOTION_NONE)
stewart_sonny_boy = stewart_sonny_boy or class({})

function stewart_sonny_boy:OnSpellStart()
    if not IsServer() then return end
    
    local caster = self:GetCaster()
    caster:EmitSound("stewart_sonnyboy")
    local duration = self:GetSpecialValueFor("duration")
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_1"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_stewart_1"):GetSpecialValueFor("value") end
    caster:AddNewModifier(caster, self, "modifier_stewart_sonny_boy", {duration = duration})
end

modifier_stewart_sonny_boy = modifier_stewart_sonny_boy or class({})

function modifier_stewart_sonny_boy:OnCreated()
    self.speed = self:GetAbility():GetSpecialValueFor("speed")
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_6"):GetLevel() > 0 then self.speed = self.speed + self:GetCaster():FindAbilityByName("special_bonus_stewart_6"):GetSpecialValueFor("value") end
    self.str_ratio = self:GetAbility():GetSpecialValueFor("str_to_hp_regen")
end

function modifier_stewart_sonny_boy:IsPurgable() return true end


function modifier_stewart_sonny_boy:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_stewart_sonny_boy:GetModifierMoveSpeedBonus_Constant() 
    return  self.speed
end

function modifier_stewart_sonny_boy:GetModifierConstantHealthRegen() 
    return self.str_ratio * self:GetParent():GetStrength()
end

function modifier_stewart_sonny_boy:GetEffectName()
    return "particles/units/heroes/hero_stewart/sonny_boy.vpcf"
end
