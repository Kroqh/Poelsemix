LinkLuaModifier("kim_nat_aura", "heroes/hero_kim/kim_nat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("kim_nat_aura_debuff", "heroes/hero_kim/kim_nat", LUA_MODIFIER_MOTION_NONE)
kim_nat = kim_nat or class({})

function kim_nat:OnSpellStart()
    if not IsServer() then end
    local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration")
    caster:EmitSound("kim_nat_lyd")
    GameRules:BeginNightstalkerNight(duration)
	local dark_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(dark_fx)

    caster:AddNewModifier(caster, self, "kim_nat_aura", {duration = duration} )
end

kim_nat_aura = kim_nat_aura or class({});

function kim_nat_aura:IsHidden() return false end
function kim_nat_aura:IsPurgable() return false end
function kim_nat_aura:IsDebuff() return false end


function kim_nat_aura:OnCreated()
    self.speed = self:GetAbility():GetSpecialValueFor("self_speed")
end

function kim_nat_aura:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT

	}
	return funcs
end
function kim_nat_aura:GetModifierMoveSpeedBonus_Constant()
	return self.speed
end


function kim_nat_aura:IsAura()						return true end
function kim_nat_aura:IsAuraActiveOnDeath() 		return false end
function kim_nat_aura:GetAuraDuration()				return 0.5 end
function kim_nat_aura:GetAuraRadius()				return 9999999 end
function kim_nat_aura:GetAuraSearchFlags()			return self:GetAbility():GetAbilityTargetFlags() end
function kim_nat_aura:GetAuraSearchTeam()			return self:GetAbility():GetAbilityTargetTeam() end
function kim_nat_aura:GetAuraSearchType()			return self:GetAbility():GetAbilityTargetType() end
function kim_nat_aura:GetModifierAura()				return "kim_nat_aura_debuff" end

kim_nat_aura_debuff = kim_nat_aura_debuff or class({});

function kim_nat_aura_debuff:IsHidden() return false end
function kim_nat_aura_debuff:IsPurgable() return false end
function kim_nat_aura_debuff:IsDebuff() return true end


function kim_nat_aura_debuff:OnCreated()
    if not IsServer() then end
    local target = self:GetParent()
	local ability = self:GetAbility()
    print(target:GetName())
	local blind_percentage = ability:GetSpecialValueFor("blind_percentage") / -100
	target.original_vision = target:GetBaseNightTimeVisionRange()
	target:SetNightTimeVisionRange(target.original_vision * (1 - blind_percentage))
end


function kim_nat_aura_debuff:OnDestroy()
    if not IsServer() then end
    local target = self:GetParent()
	target:SetNightTimeVisionRange(target.original_vision)
end
