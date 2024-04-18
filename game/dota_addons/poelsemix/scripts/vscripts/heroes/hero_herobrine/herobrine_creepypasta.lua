
herobrine_creepypasta = herobrine_creepypasta or class({})


function herobrine_creepypasta:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local ability = self
    local int = caster:GetIntellect()
	local casterPos = caster:GetAbsOrigin()

	local blink_pfx_1 = ParticleManager:CreateParticle("particles/econ/heroes/herobrine/herobrine_creepypasta.vpcf", PATTACH_ABSORIGIN, caster)
	
	ParticleManager:ReleaseParticleIndex(blink_pfx_1)


	local blink_pfx_2 = ParticleManager:CreateParticle("particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour_smoke_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(blink_pfx_2)

	EmitSoundOnLocationWithCaster(casterPos, "Hero_QueenOfPain.Blink_out", caster)
    

	FindClearSpaceForUnit(caster, target_point, false)	

	EmitSoundOnLocationWithCaster(target_point, "Hero_QueenOfPain.Blink_in", caster)
end

function herobrine_creepypasta:GetCastRange()
	local range = self:GetSpecialValueFor("blink_range")
	return range
end