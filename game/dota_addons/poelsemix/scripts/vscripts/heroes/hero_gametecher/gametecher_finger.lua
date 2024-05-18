LinkLuaModifier("modifier_gametecher_finger_delay", "heroes/hero_gametecher/gametecher_finger", LUA_MODIFIER_MOTION_NONE)
gametecher_finger = gametecher_finger or class({})

function gametecher_finger:GetCastRange()
	local range = self:GetSpecialValueFor("range")
	return range
end

function gametecher_finger:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
	return true
end

function gametecher_finger:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()     
	-- Ability specials    
	local damage = ability:GetSpecialValueFor("damage")
    local scaling = ability:GetSpecialValueFor("int_scaling_damage")
	if self:GetCaster():FindAbilityByName("special_bonus_gametecher_5"):GetLevel() > 0 then scaling = scaling + self:GetCaster():FindAbilityByName("special_bonus_gametecher_5"):GetSpecialValueFor("value") end 
    damage = damage + (caster:GetIntellect() * scaling)
	-- Cast sound
	EmitSoundOn("gametecher_kapow", caster)    
	
	-- Finger main enemy
	FingerOfDeath(caster, caster, self, target, damage)
	
	if self:GetCaster():FindAbilityByName("special_bonus_gametecher_7"):GetLevel() > 0 then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("range"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
		if #enemies >= 2 then --1 is the target itself
			FingerOfDeath(caster, target, self, enemies[2], damage)
        end
	end
end

function FingerOfDeath(caster, particle_source, ability, target, damage)
	-- Ability properties
	local particle_finger = "particles/units/heroes/hero_gametecher/gametecher_finger.vpcf"

	-- Ability specials
	local damage_delay = ability:GetSpecialValueFor("damage_delay")    

	-- Add particle effects
	local particle_finger_fx = ParticleManager:CreateParticle(particle_finger, PATTACH_CENTER_FOLLOW, caster)

	local source = "attach_attack2"
	if particle_source ~= caster then source = "attach_hitloc" end

	ParticleManager:SetParticleControlEnt(particle_finger_fx, 0, particle_source, PATTACH_POINT_FOLLOW, source, particle_source:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_finger_fx, 1, target:GetCenter())
	ParticleManager:SetParticleControl(particle_finger_fx, 2, target:GetCenter())
	ParticleManager:ReleaseParticleIndex(particle_finger_fx)           

		
	local damageTable = {victim = target,
						attacker = caster, 
					    damage = damage,
						damage_type = ability:GetAbilityDamageType(),
						ability = ability
						}
	
	ApplyDamage(damageTable)
end