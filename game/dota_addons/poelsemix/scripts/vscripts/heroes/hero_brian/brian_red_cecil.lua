LinkLuaModifier("modifier_smokerlungs","heroes/hero_brian/brian_red_cecil.lua",LUA_MODIFIER_MOTION_NONE)

red_cecil = red_cecil or class({})

function red_cecil:OnAbilityPhaseStart()  --doesnt auto start for some reason
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
end

function red_cecil:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:EmitSound("cough_brian")
    target_point = self:GetCursorPosition()
    local smoke_projectile = {
        Target = target_point,
        vSpawnOrigin = caster:GetAbsOrigin(),
        Source = caster,
        Ability = self,
        fDistance = self:GetSpecialValueFor("range"),
        EffectName = "particles/heroes/brian/red_cecil.vpcf",
        fStartRadius		= 0,
        fEndRadius		= 125,
        iUnitTargetTeam = self:GetAbilityTargetTeam(),
        iUnitTargetType = self:GetAbilityTargetType(),
        iUnitTargetFlags = self:GetAbilityTargetFlags(),
        bDodgeable = false,
        bDeleteOnHit = false,
        bIgnoreSource = true,
        bProvidesVision = false,
        bHasFrontalCone = false,
        vVelocity = (((target_point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * self:GetSpecialValueFor("proj_speed"),
    }
    ProjectileManager:CreateLinearProjectile(smoke_projectile)
end
function red_cecil:GetAOERadius()
    return self:GetSpecialValueFor("range")
end

function red_cecil:OnProjectileHit(target, location)
    if not IsServer() then return end
    if not target then return false end
    local caster = self:GetCaster()
    duration = self:GetSpecialValueFor("debuff_duration")
    if caster:HasTalent("special_bonus_brian_8") then duration = duration + caster:FindAbilityByName("special_bonus_brian_8"):GetSpecialValueFor("value") end

    target:AddNewModifier(caster, self, "modifier_smokerlungs", {duration = duration})

    local damageTable = {
        victim			= target,
        damage			= self:GetSpecialValueFor("damage"),
        damage_type		= self:GetAbilityDamageType(),
        attacker		    = caster,
        ability			= self

      }
      ApplyDamage(damageTable)

    return false
end

modifier_smokerlungs = modifier_smokerlungs or class({})


function modifier_smokerlungs:IsPurgeable() return false end
function modifier_smokerlungs:IsDebuff() return true end
function modifier_smokerlungs:IsHidden() return false end

function modifier_smokerlungs:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return decFuncs
end

function modifier_smokerlungs:OnCreated()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_brian_7") then
        self:StartIntervalThink(caster:FindAbilityByName("special_bonus_brian_7"):GetSpecialValueFor("tick_rate"))
    end
end

function modifier_smokerlungs:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()

        local damageTable = {
            victim			= self:GetParent(),
            damage			= self:GetCaster():FindAbilityByName("special_bonus_brian_7"):GetSpecialValueFor("damage"),
            damage_type		= self:GetAbility():GetAbilityDamageType(),
            attacker		    = self:GetCaster(),
            ability			= self:GetAbility()
    
          }
          ApplyDamage(damageTable)
	end
end

function  modifier_smokerlungs:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end
function  modifier_smokerlungs:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("dmg_reduction_pct")
end
function  modifier_smokerlungs:GetEffectName()
    return "particles/heroes/brian/smoke_debuff.vpcf"
end