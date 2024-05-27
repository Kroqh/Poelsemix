LinkLuaModifier("modifier_raio_unstable_passive", "heroes/hero_raio/raio_unstable", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raio_voltage_mark", "heroes/hero_raio/raio_unstable", LUA_MODIFIER_MOTION_NONE)
raio_unstable = raio_unstable or class({})


function raio_unstable:GetIntrinsicModifierName()
	return "modifier_raio_unstable_passive"
end

function raio_unstable:GetCastRange()
	return self:GetSpecialValueFor("radius")
end



modifier_raio_unstable_passive = modifier_raio_unstable_passive or class({})

function modifier_raio_unstable_passive:IsPurgable() return false end
function modifier_raio_unstable_passive:IsHidden() return true end
function modifier_raio_unstable_passive:IsPassive() return true end

function modifier_raio_unstable_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_raio_unstable_passive:OnAttackLanded(event)
	if not IsServer() then return end
	if event.attacker ~= self:GetParent() or event.target:IsBuilding() or not event.target:IsAlive() then return end

	local amount = 1
	if self:GetCaster():FindAbilityByName("special_bonus_raio_6"):GetLevel() > 0 then --talent 6, chance of extra mark on attack
		if RollPercentage(self:GetCaster():FindAbilityByName("special_bonus_raio_6"):GetSpecialValueFor("value")) then
			amount = amount + 1
		end
	end
	self:ApplyMark(event.target, amount)

end

function modifier_raio_unstable_passive:ApplyMark(target, amount)

	local duration = self:GetAbility():GetSpecialValueFor("voltage_falloff")
	if target:HasModifier("modifier_raio_voltage_mark") then
		local mod = target:FindModifierByName("modifier_raio_voltage_mark")
		mod:SetDuration(duration, true)
		mod:SetStackCount(mod:GetStackCount() + amount)
	else
		local mod = target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_raio_voltage_mark", {duration = duration})
		mod:SetStackCount(amount)
	end

end

function modifier_raio_unstable_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("rate"))
end

function modifier_raio_unstable_passive:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	if not parent:IsAlive() then return end
	local ability = self:GetAbility()
	local radius = self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
	

		local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(), 
			parent:GetAbsOrigin(), 
			nil, 
			radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, 
			false
		)
	
	local targets_to_hit = ability:GetSpecialValueFor("targets_to_hit")

	if self:GetCaster():FindAbilityByName("special_bonus_raio_5"):GetLevel() > 0 then targets_to_hit = targets_to_hit + self:GetCaster():FindAbilityByName("special_bonus_raio_5"):GetSpecialValueFor("value") end

	local nonhero = {}
	local final_targets = {}
	if #enemies > 0 then
		for _, target in pairs(enemies) do
			if target:IsHero() then --shitty prioritise hero function
				table.insert(final_targets, target)
			else
				table.insert(nonhero, target)
			end
			if #final_targets >= targets_to_hit then break end
		end
		
		if targets_to_hit > #final_targets then
			for _, target in pairs(nonhero) do --if not enough heroes, target other
				table.insert(final_targets, target)
				if #final_targets >= targets_to_hit then break end
			end
		end
	end
	if #final_targets > 0 then
		parent:EmitSoundParams("Hero_Zuus.ArcLightning.Cast", 1, 0.15, 0)

		local stun = (self:GetCaster():FindAbilityByName("special_bonus_raio_2"):GetLevel() > 0)

		for _, target in pairs(final_targets) do

			local lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControlEnt(lightning_particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(lightning_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			--ParticleManager:SetParticleControl(lightning_particle, 62, Vector(2, 0, 2))
			ParticleManager:ReleaseParticleIndex(lightning_particle)

			local scaling = ability:GetSpecialValueFor("int_damage_scaling")
			local damage = ability:GetSpecialValueFor("base_damage") + (scaling * parent:GetIntellect(true))
			
			self:ApplyMark(target, 1)
			ApplyDamage({
				victim 			= target,
				damage 			= damage,
				damage_type		= ability:GetAbilityDamageType(),
				attacker 		= parent,
				ability 		= ability
			})

			if stun then
				local duration = self:GetCaster():FindAbilityByName("special_bonus_raio_2"):GetSpecialValueFor("value")
				target:AddNewModifier(caster, ability, "modifier_stunned", {duration = duration})
			end

		end
	end

	local rate = self:GetAbility():GetSpecialValueFor("rate")
	if self:GetCaster():FindAbilityByName("special_bonus_raio_3"):GetLevel() > 0 then rate = rate + self:GetCaster():FindAbilityByName("special_bonus_raio_3"):GetSpecialValueFor("value") end

	self:StartIntervalThink(rate)
end




modifier_raio_voltage_mark = modifier_raio_voltage_mark or class({})

function modifier_raio_voltage_mark:IsPurgable() return true end
function modifier_raio_voltage_mark:IsDebuff() return true end


function modifier_raio_voltage_mark:GetEffectName() return "particles/units/heroes/hero_zuus/zuus_shard_slow.vpcf" end

function modifier_raio_voltage_mark:GetTexture() return "raio_amp" end