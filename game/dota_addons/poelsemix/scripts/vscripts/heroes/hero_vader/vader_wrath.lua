vader_wrath = vader_wrath or class({})
LinkLuaModifier("modifier_vader_wrath", "heroes/hero_vader/vader_wrath", LUA_MODIFIER_MOTION_NONE)

function vader_wrath:GetIntrinsicModifierName()
	return "modifier_vader_wrath"
end

modifier_vader_wrath = modifier_vader_wrath or class({})



function modifier_vader_wrath:IsPurgable() return false end
function modifier_vader_wrath:IsHidden() return false end
function modifier_vader_wrath:IsPassive() return true end
function modifier_vader_wrath:RemoveOnDeath()	return false end

function modifier_vader_wrath:OnCreated()
	if not IsServer() then return end
    self.parent = self:GetParent()
    local particle_self = "particles/units/heroes/vader/wrath_aura.vpcf"
    	self.aura = ParticleManager:CreateParticle(particle_self, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    	ParticleManager:SetParticleControlEnt(self.aura, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), false)

end

function modifier_vader_wrath:DeclareFunctions()
	local decFuncs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE ,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
    return decFuncs
end

function modifier_vader_wrath:GetModifierMoveSpeedBonus_Constant()
    if self:GetCaster():FindAbilityByName("special_bonus_vader_8"):GetLevel() > 0 then
        return self:GetCaster():FindAbilityByName("special_bonus_vader_8"):GetSpecialValueFor("value") * self:GetStackCount()
    end
end

function modifier_vader_wrath:OnDeath(keys)
    if not IsServer() then return end
	if keys.unit ~= self.parent then return end
    if not keys.unit:IsHero() then return end
    self:SetStackCount(0)
end

function modifier_vader_wrath:OnAttackLanded(keys)
    if not IsServer() then return end
	if keys.attacker ~= self.parent then return end
    if not keys.target:IsHero() then return end
    local stacks = 1
    if self:GetCaster():FindAbilityByName("special_bonus_vader_4"):GetLevel() > 0 then
        local chance = self:GetCaster():FindAbilityByName("special_bonus_vader_4"):GetSpecialValueFor("value")
        local roll = RandomInt(1,100)
        if roll <= chance then
		    stacks = stacks + 1
        end
    end
    self:AddStacks(stacks)
    
end
function modifier_vader_wrath:AddStacks(count)
    self:SetStackCount(self:GetStackCount()+count)
end

function modifier_vader_wrath:GetTexture()
	return "vader_wrath"
end

function  modifier_vader_wrath:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount() *self:GetAbility():GetSpecialValueFor("wrath_spell_amp")
end
function  modifier_vader_wrath:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("wrath_attack_speed")
end

function modifier_vader_wrath:OnStackCountChanged()
    if not IsServer() then return end
    ParticleManager:SetParticleControl(self.aura,1,Vector(self:GetStackCount(),0,0))
end

function modifier_vader_wrath:GetAttackSound()
	return "vader_saber_attack"
end

