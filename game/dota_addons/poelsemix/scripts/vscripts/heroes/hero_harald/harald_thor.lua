ha_thor = ha_thor or class({})


function ha_thor:OnSpellStart()
    if not IsServer() then return end

    
    local caster = self:GetCaster()
	local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")
    local particle_hit = "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf"


    local particle_self = "particles/units/heroes/hero_zuus/zuus_lightning_bolt_start.vpcf"

    local pfx_fire = ParticleManager:CreateParticle(particle_self, PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(pfx_fire, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
    
    EmitSoundOnLocationWithCaster(point,"ha_thor", caster)
    local targets = 1
    if (caster:HasTalent("special_bonus_harald_4")) then targets = targets+1 end
    local count = 0
	for _,unit in pairs(FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)) do
            if (caster:HasTalent("special_bonus_harald_3")) then unit:AddNewModifier(caster, self, "modifier_stunned", {Duration = caster:FindAbilityByName("special_bonus_harald_3"):GetSpecialValueFor("value")}) end
            ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType()})
            -- Renders the particle on the target
            local particle = ParticleManager:CreateParticle(particle_hit, PATTACH_WORLDORIGIN, unit)
            -- Raise 1000 value if you increase the camera height above 1000
            ParticleManager:SetParticleControl(particle, 0, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
            ParticleManager:SetParticleControl(particle, 1, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,1000 ))
            ParticleManager:SetParticleControl(particle, 2, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))

            count = count + 1
            if count == targets then break end
    end

    if count == 0 then --fire particle on ground instead if no enemies hit
        local particle = ParticleManager:CreateParticle(particle_hit, PATTACH_WORLDORIGIN, caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle, 0, Vector(point.x,point.y,point.z))
        ParticleManager:SetParticleControl(particle, 1, Vector(point.x,point.y,1000))
        ParticleManager:SetParticleControl(particle, 2, Vector(point.x,point.y,point.z))
    end
end