raio_amp_it_up = raio_amp_it_up or class({})

function raio_amp_it_up:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("raio_voltage")
	return true
end


function raio_amp_it_up:GetCastRange()
	return self:GetSpecialValueFor("range")
end

function raio_amp_it_up:CastFilterResultTarget(target)
	if IsServer() then
		if target:HasModifier("modifier_raio_voltage_mark") then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function raio_amp_it_up:GetCustomCastErrorTarget(target)
	return "NO VOLTAGE ON TAGET"
end


function raio_amp_it_up:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		target:EmitSound("Hero_Zuus.LightningBolt.Cast")
		local mod = target:FindModifierByName("modifier_raio_voltage_mark")
		local marks = mod:GetStackCount()
	
		local base_damage = self:GetSpecialValueFor("base_damage_per_volt")
		local scaling = self:GetSpecialValueFor("int_damage_scaling_per_volt")
		if self:GetCaster():FindAbilityByName("special_bonus_raio_4"):GetLevel() > 0 then scaling = scaling + self:GetCaster():FindAbilityByName("special_bonus_raio_4"):GetSpecialValueFor("value") end

		local total_damage = marks * (base_damage+ (scaling*caster:GetIntellect(true)))

		ApplyDamage({
			victim 			= target,
			damage 			= total_damage,
			damage_type		= self:GetAbilityDamageType(),
			attacker 		= caster,
			ability 		= self
		})

		local particle_fx = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_fx, 0, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_fx)
		mod:Destroy()
	end
end