intruder_smoke = intruder_smoke or class({})

function intruder_smoke:OnSpellStart()
    if not IsServer then return end
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local distance = (caster:GetAbsOrigin() - target_point):Length2D()
    local direction = (target_point - caster:GetAbsOrigin()):Normalized()

    -- Launch the smoke grenade projectile
    local smoke_projectile = {
        Target = target_point,
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
    if not IsServer then return end
    -- Create the particle effect for the smoke grenade
    print("test")
    print(target)
    print(location)
    print(self:GetCaster():GetAbsOrigin())
    local radius = self:GetSpecialValueFor("smoke_radius")
    local smoke_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_smoke.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(smoke_particle, 0, location)
    ParticleManager:SetParticleControl(smoke_particle, 1, Vector(smoke_radius, 0, smoke_radius))

    return true
end