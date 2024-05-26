
shadow_gun = shadow_gun or class({})

LinkLuaModifier("modifier_shadow_gun_stack_handler", "heroes/hero_shadow/shadow_gun", LUA_MODIFIER_MOTION_NONE)

function shadow_gun:GetCastRange()
    local value = self:GetSpecialValueFor("range")
    return value
end

function shadow_gun:GetIntrinsicModifierName()
	return "modifier_shadow_gun_stack_handler"
end


function shadow_gun:CastFilterResultLocation()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_shadow_gun_stack_handler"):GetStackCount()
		--print(modifier_stack_count)

		if modifier_stack_count >= 1 then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function shadow_gun:GetCustomCastErrorLocation()
	return "NO AMMO"
end


function shadow_gun:OnSpellStart()
	if not IsServer() then return end
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    if target_point == caster:GetAbsOrigin() then target_point = caster:GetForwardVector() end
	local direction = (target_point - caster:GetAbsOrigin()):Normalized()
	local spawn_point = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack2")) --For at det ligner det kommer fra håndet i suppose

	local modifier_stacks = caster:FindModifierByName("modifier_shadow_gun_stack_handler"):GetStackCount()
	caster:FindModifierByName("modifier_shadow_gun_stack_handler"):SetStackCount(modifier_stacks - 1)

	FireProjectile(caster, ability, spawn_point, direction)

end


function FireProjectile(caster, ability, spawn_point, direction, targethero)
	local particle_gun = "particles/econ/heroes/shadow/shadow_gun.vpcf"
	local arrow_speed = ability:GetSpecialValueFor("proj_speed")
	local arrow_distance = ability:GetSpecialValueFor("range")
		EmitSoundOn("shadow_gun_shoot", caster)
		local arrow_projectile = {  Ability = ability,
			EffectName = particle_gun,
			vSpawnOrigin = spawn_point,
			fDistance = arrow_distance,
			fStartRadius = 40,
			fEndRadius = 40,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = ability:GetAbilityTargetType(),
			iUnitTargetFlags = ability:GetAbilityTargetFlags(),
			bDeleteOnHit = true,
			vVelocity = direction * arrow_speed * Vector(1, 1, 0),
			bProvidesVision = false,
			iVisionTeamNumber = caster:GetTeamNumber(),
			
		}
		ProjectileManager:CreateLinearProjectile(arrow_projectile)
end

function shadow_gun:OnProjectileHit(target, location)
	-- If no target was hit, do nothing
	if not target then
		return nil
	end

	-- Ability properties
	local caster = self:GetCaster()

	-- Ability specials
	local damage = self:GetSpecialValueFor("damage")
	if self:GetCaster():FindAbilityByName("special_bonus_shadow_2"):GetLevel() > 0 then damage = damage + self:GetCaster():FindAbilityByName("special_bonus_shadow_2"):GetSpecialValueFor("value") end 

	-- Apply damage
	local damageTable = {victim = target,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		attacker = caster,
		ability = self
	}
	ApplyDamage(damageTable)

	local particle_blood = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_blood.vpcf"
	local particle_blood_fx = ParticleManager:CreateParticle(particle_blood, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_blood_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_blood_fx)

	return true
end


modifier_shadow_gun_stack_handler = modifier_shadow_gun_stack_handler or class({})

function modifier_shadow_gun_stack_handler:IsDebuff() 	return false end
function modifier_shadow_gun_stack_handler:IsHidden() 	return false end
function modifier_shadow_gun_stack_handler:IsPassive() 	return true end
function modifier_shadow_gun_stack_handler:IsPurgeable() return false end

function modifier_shadow_gun_stack_handler:IsPurgable() return false end

function modifier_shadow_gun_stack_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		--Give one trap on first level up
		--so no have to wait 30 secs for first shroom
		local lol = 0

		if lol == 0 then
			local caster = self:GetCaster()
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("max_ammo"))
			lol = 1
		end
		self.parent_last_pos = self:GetParent():GetAbsOrigin()
		self.distance_diff = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_shadow_gun_stack_handler:OnIntervalThink()
	if not IsServer() then return end
        self.distance_diff = self.distance_diff + FindDistance(self:GetParent():GetAbsOrigin(), self.parent_last_pos)
        local distance_per_stack = self:GetAbility():GetSpecialValueFor("distance_per_ammo")
        if self.distance_diff > distance_per_stack then
            local stacks_to_add = math.floor(self.distance_diff / distance_per_stack)
            self.distance_diff = self.distance_diff % distance_per_stack
            self:SetStackCount(self:GetStackCount()+stacks_to_add)

			local max_ammo = self:GetAbility():GetSpecialValueFor("max_ammo")
			if self:GetCaster():FindAbilityByName("special_bonus_shadow_1"):GetLevel() > 0 then max_ammo = max_ammo + self:GetCaster():FindAbilityByName("special_bonus_shadow_1"):GetSpecialValueFor("value") end 
			if self:GetStackCount() > max_ammo then self:SetStackCount(max_ammo) else EmitSoundOnClient("shadow_gun_ammo", self:GetParent():GetPlayerOwner()) end
        end
    self.parent_last_pos = self:GetParent():GetAbsOrigin()
end