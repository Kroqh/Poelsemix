
mewtwo_teleport = mewtwo_teleport or class({})

function mewtwo_teleport:OnAbilityPhaseStart() 
	if not IsServer() then return end
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
	local blink_pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_newtwo/mewtwo_teleport.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_pfx1)
	self:GetCaster():EmitSound("mewtwo_teleport")
	return true
end

function mewtwo_teleport:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local ability = self
    local int = caster:GetIntellect()
	local casterPos = caster:GetAbsOrigin()

	
	FindClearSpaceForUnit(caster, target_point, false)	

	Timers:CreateTimer(0.01, function() --ensures position change before particles fire
		local blink_pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_newtwo/mewtwo_teleport.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:ReleaseParticleIndex(blink_pfx2)
	end)

	
end

function mewtwo_teleport:GetCastRange()
	local range = self:GetSpecialValueFor("blink_range")
	return range
end