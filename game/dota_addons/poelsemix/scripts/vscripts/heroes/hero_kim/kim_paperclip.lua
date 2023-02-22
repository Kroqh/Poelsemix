kim_paperclip = kim_paperclip or class({})

function kim_paperclip:OnAbilityPhaseStart()
    if not IsServer() then end
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    caster:EmitSound("kim_papirclip")
end

function kim_paperclip:OnSpellStart()
    if not IsServer() then end
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor( "illusion_duration")
	local outgoingDamage = self:GetSpecialValueFor( "illusion_outgoing_damage")
    local illusionAmount = self:GetSpecialValueFor( "illusion_amount")
    if caster:HasTalent("special_bonus_kim_1") then duration = duration + caster:FindAbilityByName("special_bonus_kim_1"):GetSpecialValueFor("value") end
    if caster:HasTalent("special_bonus_kim_2") then illusionAmount = illusionAmount + caster:FindAbilityByName("special_bonus_kim_2"):GetSpecialValueFor("value") end

    local illusions = CreateIllusions(self:GetCaster(), target, {
        outgoing_damage = outgoing_damage,
        incoming_damage	= -100,
        bounty_base		= 0,
        bounty_growth	= nil,
        outgoing_damage_structure	= nil,
        outgoing_damage_roshan		= nil,
        duration	= duration
    }
    , illusionAmount, 70, false, true)
    
    
    for _, illusion in pairs(illusions) do
		illusion:SetControllableByPlayer(-1, true) -- uncontrollable
        illusion:AddNewModifier(self:GetCaster(), self, "modifier_imba_terrorblade_reflection_unit", {enemy_entindex = target:entindex()})
        illusion:AddNewModifier(self:GetCaster(), self, "modifier_terrorblade_reflection_invulnerability", {})
        illusion:SetForceAttackTarget(target)
	end
end
