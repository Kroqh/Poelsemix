intruder_flash = intruder_flash or class({})

function intruder_flash:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()
    local distance = (caster:GetAbsOrigin() - target_point):Length2D()
    local direction = (target_point - caster:GetAbsOrigin()):Normalized()
    caster:EmitSound("intruder_throw_flash")

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

function intruder_flash:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end


function intruder_flash:OnProjectileHit(target, location)
    if not IsServer() then return end
    local caster = self:GetCaster()
    EmitSoundOnLocationWithCaster(location,"intruder_flash",caster)

    dur = self:GetSpecialValueFor("duration")
    if caster:HasTalent("special_bonus_intruder_1") then  dur = dur + caster:FindAbilityByName("special_bonus_intruder_1"):GetSpecialValueFor("value") end
    local damage = self:GetSpecialValueFor("damage")

    local particle_flash = "particles/units/heroes/hero_intruder/sniper_shard_concussive_grenade_impact_flash.vpcf"
	local particle_flash_fx = ParticleManager:CreateParticle(particle_flash, PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(particle_flash_fx, 0, location)
	ParticleManager:ReleaseParticleIndex(particle_flash_fx)
    
        

     for _, enemy in pairs(FindUnitsInRadius(caster:GetTeamNumber(), location,  nil,self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
                    enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = dur } )

                  local damageTable = {
                  victim			= enemy,
                  damage			= damage,
                  damage_type		= DAMAGE_TYPE_MAGICAL,
                  attacker		    = caster,
                  ability			= self

                }
			
            
                ApplyDamage(damageTable)
     end

    return true
end
