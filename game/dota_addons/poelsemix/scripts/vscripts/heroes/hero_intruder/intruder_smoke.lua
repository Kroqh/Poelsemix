intruder_smoke = intruder_smoke or class({})

LinkLuaModifier("modifier_intruder_stealth", "heroes/hero_intruder/modifier_intruder_stealth", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("intruder_smoke_cloud_modifier_friendly", "heroes/hero_intruder/intruder_smoke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("intruder_smoke_cloud_modifier_hostile", "heroes/hero_intruder/intruder_smoke", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("intruder_smoke_cloud_modifier_debuff", "heroes/hero_intruder/intruder_smoke", LUA_MODIFIER_MOTION_NONE)

function intruder_smoke:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local distance = (caster:GetAbsOrigin() - target_point):Length2D()
    local direction = (target_point - caster:GetAbsOrigin()):Normalized()
    caster:EmitSound("intruder_throw_smoke")

    -- Launch the smoke grenade projectile
    local smoke_projectile = {
        Target = GetGroundPosition(target_point,nil),
        vSpawnOrigin = caster:GetAbsOrigin(),
        Source = caster,
        Ability = self,
        fDistance = distance,
        EffectName = "particles/units/heroes/hero_intruder/sniper_shard_concussive_grenade_model.vpcf",
        fStartRadius		= 50,
		fEndRadius			= 50,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDodgeable = false,
        bDeleteOnHit = true,
        bIgnoreSource = true,
        bProvidesVision = false,
        --iMoveSpeed = self:GetSpecialValueFor("proj_speed"),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        vVelocity 	= direction * self:GetSpecialValueFor("proj_speed") * Vector(1, 1, 0)
    }
    ProjectileManager:CreateLinearProjectile(smoke_projectile)
end

function intruder_smoke:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    EmitSoundOnLocationWithCaster(location,"intruder_smoke",caster)

    dur = self:GetSpecialValueFor("smoke_dur")
    if caster:HasTalent("special_bonus_intruder_2") then  dur = dur + caster:FindAbilityByName("special_bonus_intruder_2"):GetSpecialValueFor("value") end
    CreateModifierThinker(caster, self, "intruder_smoke_cloud_modifier_friendly", {
		duration = dur
	}, GetGroundPosition(location, nil), caster:GetTeamNumber(), false)

    CreateModifierThinker(caster, self, "intruder_smoke_cloud_modifier_hostile", {
		duration = dur
	}, GetGroundPosition(location, nil), caster:GetTeamNumber(), false)

    return true
end

function intruder_smoke:GetAOERadius()
    return self:GetSpecialValueFor("smoke_radius")
end




intruder_smoke_cloud_modifier_friendly = intruder_smoke_cloud_modifier_friendly or class({})


function intruder_smoke_cloud_modifier_friendly :OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.radius	= self:GetAbility():GetSpecialValueFor("smoke_radius")

    if not IsServer() then return end
end

function intruder_smoke_cloud_modifier_friendly:GetEffectName()
    return "particles/units/heroes/hero_intruder/riki_smokebomb.vpcf"
end

function intruder_smoke_cloud_modifier_friendly:IsAura()						return true end
function intruder_smoke_cloud_modifier_friendly:IsAuraActiveOnDeath() 			return false end

function intruder_smoke_cloud_modifier_friendly:GetAuraDuration()				return 0.1 end
function intruder_smoke_cloud_modifier_friendly:GetAuraRadius()				return self.radius end
function intruder_smoke_cloud_modifier_friendly:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end
function intruder_smoke_cloud_modifier_friendly:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function intruder_smoke_cloud_modifier_friendly:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO end
function intruder_smoke_cloud_modifier_friendly:GetModifierAura()				return "modifier_intruder_stealth" end


intruder_smoke_cloud_modifier_hostile = intruder_smoke_cloud_modifier_hostile or class({})


function intruder_smoke_cloud_modifier_hostile :OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.radius	= self:GetAbility():GetSpecialValueFor("smoke_radius")

    if not IsServer() then return end
end

function intruder_smoke_cloud_modifier_hostile:IsAura()						return true end
function intruder_smoke_cloud_modifier_hostile:IsAuraActiveOnDeath() 			return false end

function intruder_smoke_cloud_modifier_hostile:GetAuraDuration()				return 0.1 end
function intruder_smoke_cloud_modifier_hostile:GetAuraRadius()				return self.radius end
function intruder_smoke_cloud_modifier_hostile:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end
function intruder_smoke_cloud_modifier_hostile:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_ENEMY end
function intruder_smoke_cloud_modifier_hostile:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO end
function intruder_smoke_cloud_modifier_hostile:GetModifierAura()				return "intruder_smoke_cloud_modifier_debuff" end


intruder_smoke_cloud_modifier_debuff = intruder_smoke_cloud_modifier_debuff or class({})


function  intruder_smoke_cloud_modifier_debuff:IsPurgeable() return false end
function  intruder_smoke_cloud_modifier_debuff:IsDebuff() return true end
function  intruder_smoke_cloud_modifier_debuff:IsHidden() return false end

function intruder_smoke_cloud_modifier_debuff:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE
	}
	return decFuncs
end

function intruder_smoke_cloud_modifier_debuff:GetBonusVisionPercentage()
    return self:GetAbility():GetSpecialValueFor("smoke_vision")
end