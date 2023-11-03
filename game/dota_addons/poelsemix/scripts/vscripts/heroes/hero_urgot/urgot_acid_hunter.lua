
urgot_acid_hunter = urgot_acid_hunter or class({})

function urgot_acid_hunter:GetCastRange()
    local value = self:GetSpecialValueFor("range")
	if self:GetCaster():FindAbilityByName("special_bonus_urgot_4"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_urgot_4"):GetSpecialValueFor("value") end 
    return value
end


function urgot_acid_hunter:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self,level)
	if self:GetCaster():FindAbilityByName("special_bonus_urgot_7"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_urgot_7"):GetSpecialValueFor("value") end 
    return cd
end

function urgot_acid_hunter:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()

    if target_point == caster:GetAbsOrigin() then target_point = caster:GetForwardVector() end
	local direction = (target_point - caster:GetAbsOrigin()):Normalized()



	local spawn_point = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")) + direction * 20 --For at det ligner det kommer fra håndet i suppose


	--Kode fra zuus lightning bolt, bruges til at finde en hero tæt på der hvor at jeg aimede.
	if targethero == nil then
		-- Finds all heroes in the radius (the closest hero takes priority over the closest creep)
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, 200, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
		local closest = 200
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = target_point - unit_location
			local distance = (vector_distance):Length2D()
			-- If the hero is closer than the closest checked so far, then we set its distance as the new closest distance and it as the new target
			if distance < closest then
				closest = distance
				targethero = unit
			end
		end
	end

	FireProjectile(caster, ability, spawn_point, direction, targethero)
	targethero = nil

end


function FireProjectile(caster, ability, spawn_point, direction, targethero)
	local particle_arrow = "particles/units/heroes/urgot/acid_hunter.vpcf"
	local arrow_speed = ability:GetSpecialValueFor("proj_speed")
	local arrow_distance = ability:GetSpecialValueFor("range")
	if targethero == nil or targethero:HasModifier("modifier_urgot_corrosive") == false then
		EmitSoundOn("urgotQNonTargeted", caster)
		local arrow_projectile = {  Ability = ability,
			EffectName = particle_arrow,
			vSpawnOrigin = spawn_point,
			fDistance = arrow_distance,
			fStartRadius = 50,
			fEndRadius = 50,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = ability:GetAbilityTargetType(),
			bDeleteOnHit = true,
			vVelocity = direction * arrow_speed * Vector(1, 1, 0),
			bProvidesVision = false,
			iVisionTeamNumber = caster:GetTeamNumber(),
			ExtraData = {cast_loc_x = tostring(caster:GetAbsOrigin().x),
				cast_loc_y = tostring(caster:GetAbsOrigin().y),
				cast_loc_z = tostring(caster:GetAbsOrigin().z)}
		}
		ProjectileManager:CreateLinearProjectile(arrow_projectile)
	else
		EmitSoundOn("urgotQTargeted", caster)
		local arrow_projectile = {  Ability = ability,
			Target = targethero,
			EffectName = "particles/units/heroes/urgot/q_targeted.vpcf",
			iMoveSpeed = arrow_speed,
			vSpawnOrigin = spawn_point,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = ability:GetAbilityTargetType(),
			bDeleteOnHit = true,
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber(),
			ExtraData = {cast_loc_x = tostring(caster:GetAbsOrigin().x),
				cast_loc_y = tostring(caster:GetAbsOrigin().y),
				cast_loc_z = tostring(caster:GetAbsOrigin().z)}
		}
		ProjectileManager:CreateTrackingProjectile(arrow_projectile)
	end
end

function urgot_acid_hunter:OnProjectileHit_ExtraData(target, location, extra_data)
	-- If no target was hit, do nothing
	if not target then
		return nil
	end

	-- Ability properties
	local caster = self:GetCaster()


	-- Ability specials
	local damage = self:GetSpecialValueFor("damage")
	if caster:FindAbilityByName("special_bonus_urgot_1"):GetLevel() > 0 then damage = damage + caster:FindAbilityByName("special_bonus_urgot_1"):GetSpecialValueFor("value") end


	-- Play impact sound
	EmitSoundOn("urgotQHit", target)


	-- Apply damage
	local damageTable = {victim = target,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		attacker = caster,
		ability = self
	}

	ApplyDamage(damageTable)
    if caster:HasAbility("urgot_augmenter") then caster:FindAbilityByName("urgot_augmenter"):ApplyDebuff(target) end
	return true
end
