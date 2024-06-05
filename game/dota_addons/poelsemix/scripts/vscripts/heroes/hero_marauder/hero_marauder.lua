--------------------------------------------------------------------------------
-- Move Only
--------------------------------------------------------------------------------




---------------------------
-- VAAL CYCLONE
-- TODO
-- Add particle - done
-- add damage - done
-- add suck - done
-- add animation 
-- add charges - done
-- add talents 
-- make vaal cyclone same as cyclone stats
---------------------------

LinkLuaModifier("modifier_vaal_cyclone", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vaal_cyclone_stack", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stunned", "heroes/hero_stewart/hero_stewart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vaal_cyclone_suck", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
vaal_cyclone = vaal_cyclone or class({})

function vaal_cyclone:GetIntrinsicModifierName()
	return "modifier_vaal_cyclone_stack"
end

function vaal_cyclone:CastFilterResult()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local modifier = "modifier_vaal_cyclone_stack"
	local max_stacks = self:GetSpecialValueFor("stacks_needed")

	local current_stacks = caster:GetModifierStackCount(modifier, caster)
	if current_stacks >= max_stacks then
		caster:FindModifierByName("modifier_vaal_cyclone_stack"):SetStackCount(0)

		local cyclone_spell = caster:FindAbilityByName("poe_cyclone")
		if cyclone_spell:GetToggleState() then
			cyclone_spell:ToggleAbility()
		end

		return UF_SUCCESS
	end
	
	return UF_FAIL_CUSTOM
end

function vaal_cyclone:GetCustomCastError()
	return "Not enough stacks"
end

function vaal_cyclone:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_vaal_cyclone", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_stunned", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_vaal_cyclone_suck", {duration = duration})
end

modifier_vaal_cyclone = modifier_vaal_cyclone or class({})

function modifier_vaal_cyclone:IsHidden() return false end

function modifier_vaal_cyclone:CheckState()
	local state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true }
	return state
end

function modifier_vaal_cyclone:OnCreated()
	if not IsServer() then return end
	local particle = "particles/heroes/marauder/cyclone_particle.vpcf"

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	
	local min_aps = ability:GetSpecialValueFor("min_aps")
	local aps_base = ability:GetSpecialValueFor("aps_base")
	local aps_scaling = ability:GetSpecialValueFor("ats_scaling")

	local aps = aps_base - caster:GetAttackSpeed() * aps_scaling
	local radius = ability:GetSpecialValueFor("radius")

	if aps < min_aps then
		aps = min_aps
	end

	self.pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius * 0.35, 0, 0))
	
	self:StartIntervalThink(aps)
end

function modifier_vaal_cyclone:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local damage_type = ability:GetAbilityDamageType()

	local base_dmg = ability:GetSpecialValueFor("base_damage")
	local damage_scaling = ability:GetSpecialValueFor("damage_scaling")
	local damage = base_dmg + (caster:GetAttackDamage() * damage_scaling)

	local radius = ability:GetSpecialValueFor("radius")

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									  caster:GetAbsOrigin(), 
									  nil, 
									  radius, 
									  DOTA_UNIT_TARGET_TEAM_ENEMY, 
									  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
									  DOTA_UNIT_TARGET_FLAG_NONE, 
									  FIND_ANY_ORDER, 
									  false)

	for _, enemy in pairs(enemies) do
		ApplyDamage({victim = enemy, 
				attacker = caster, 
				damage = damage, 
				damage_type = damage_type,
				ability = ability
			})
	end
end

function modifier_vaal_cyclone:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
end

modifier_vaal_cyclone_stack = modifier_vaal_cyclone_stack or class({})

function modifier_vaal_cyclone_stack:IsHidden() return false end
function modifier_vaal_cyclone_stack:IsPurgable() return false end
function modifier_vaal_cyclone_stack:IsPassive() return true end

modifier_vaal_cyclone_suck = modifier_vaal_cyclone_suck or class({})
function modifier_vaal_cyclone_suck:IsHidden() return false end
function modifier_vaal_cyclone_suck:IsPurgable() return false end

function modifier_vaal_cyclone_suck:OnCreated() 
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local aps_base = ability:GetSpecialValueFor("aps_base")
	local aps_scaling = ability:GetSpecialValueFor("ats_scaling")
	local min_aps = caster:FindAbilityByName("poe_cyclone"):GetSpecialValueFor("min_aps")

	local suck_speed =  aps_base - (caster:GetAttackSpeed() * aps_scaling)

	print("suck speed: " .. suck_speed)

	if suck_speed < 0.1 then
		suck_speed = min_aps
		print(suck_speed)
	end

	self:StartIntervalThink(suck_speed)
end

function modifier_vaal_cyclone_suck:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local caster_pos = caster:GetAbsOrigin()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									  caster_pos, 
									  nil, 
									  radius, 
									  DOTA_UNIT_TARGET_TEAM_ENEMY, 
									  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
									  DOTA_UNIT_TARGET_FLAG_NONE, 
									  FIND_ANY_ORDER, 
									  false)

	for _, enemy in pairs(enemies) do
		local enemy_pos = enemy:GetAbsOrigin()
		local direction = (caster_pos - enemy_pos)

		-- pull 40% of the distance to the caster
		FindClearSpaceForUnit(enemy, enemy_pos + direction * 0.4, true)
	end
end


