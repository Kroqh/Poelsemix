caro_side_swap = caro_side_swap or class({})


function caro_side_swap:GetCastRange()
    return self:GetSpecialValueFor("cast_range")
end

function caro_side_swap:OnSpellStart()
    if not IsServer() or interrupt then return end

    
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	

    EmitSoundOn("caroswap", self.target )
    EmitSoundOn("caroswap", self:GetCaster())
    local delay = self:GetSpecialValueFor("cast_time")
    if self:GetCaster():HasTalent("special_bonus_caro_2") then delay = delay + self:GetCaster():FindAbilityByName("special_bonus_caro_2"):GetSpecialValueFor("value") end
    if delay < 0 then delay = 0 end

    Timers:CreateTimer({
        endTime = delay,
        callback = function()
            local caster_position = caster:GetAbsOrigin()
	        local target_position = target:GetAbsOrigin()
            -- Swap their positions
            caster:SetAbsOrigin(target_position)
            target:SetAbsOrigin(caster_position)
            -- Make sure that they dont get stuck
            FindClearSpaceForUnit( caster, target_position, true )
            FindClearSpaceForUnit( target, caster_position, true )

            local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
            ParticleManager:SetParticleControlEnt(caster_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(caster_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

            -- Play target particle
            local target_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, target)
            ParticleManager:SetParticleControlEnt(target_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(target_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

            -- Stops the current action of the target
            target:Interrupt()
      end
      })
	
end