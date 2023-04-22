-------------------------------
--        SACRED ARROW       --
-------------------------------

imba_mirana_arrow = class({})

function imba_mirana_arrow:GetAbilityTextureName()
	return "urgotQ"
end

function imba_mirana_arrow:IsHiddenWhenStolen()
	return false
end

function imba_mirana_arrow:GetCooldown(level)
	if IsServer() then
		local caster = self:GetCaster()
		local qcooldown = self.BaseClass.GetCooldown(self,level)
		
		if caster:HasTalent("special_bonus_urgot_q_boost2") then
			qcooldown = qcooldown/2	
		end

		return qcooldown
	end
end

function imba_mirana_arrow:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()


	-- Set direction for main arrow
	local direction = (target_point - caster:GetAbsOrigin()):Normalized()

	-- Get spawn point
	--local spawn_point = caster:GetAbsOrigin() + direction * spawn_distance -- Gammel kode

	local spawn_point = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_qhand")) + direction * 51 --For at det ligner det kommer fra håndet i suppose


	--Kode fra zuus lightning bolt, bruges til at finde en hero tæt på der hvor at jeg aimede.
	if targethero == nil then
		-- Finds all heroes in the radius (the closest hero takes priority over the closest creep)
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, 200, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, 0, false)
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

	-- Fire main arrow
	FireSacredArrow(caster, ability, spawn_point, direction, targethero)
	targethero = nil

end


function FireSacredArrow(caster, ability, spawn_point, direction, targethero)
	local particle_arrow = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf"

	local arrow_speed = ability:GetSpecialValueFor("arrow_speed")
	local vision_radius = ability:GetSpecialValueFor("vision_radius")
	local arrow_distance = ability:GetSpecialValueFor("arrow_distance")
	if targethero == nil or targethero:HasModifier("modifier_imba_phoenix_fire_spirits_debuff") == false then
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
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = true,
			vVelocity = direction * arrow_speed * Vector(1, 1, 0),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
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
			EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
			iMoveSpeed = arrow_speed,
			vSpawnOrigin = spawn_point,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
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

function imba_mirana_arrow:OnProjectileHit_ExtraData(target, location, extra_data)
	-- If no target was hit, do nothing
	if not target then
		return nil
	end

	-- Ability properties
	local caster = self:GetCaster()


	-- Ability specials
	local damage = self:GetSpecialValueFor("damage")
	if caster:HasTalent("special_bonus_urgot_q_boost") then damage = damage + caster:FindAbilityByName("special_bonus_urgot_q_boost"):GetSpecialValueFor("value") end

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

	return true
end









--Start på W herfra
imba_pipe = class({})
LinkLuaModifier("modifier_shield", "heroes/hero_urgot/hero_urgot", LUA_MODIFIER_MOTION_NONE)

function imba_pipe:GetAbilityTextureName()
	return "urgotW"
end

function imba_pipe:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local shield_health = 0

	if caster:HasTalent("special_bonus_urgot_w_boost") then
		 shield_health = self:GetSpecialValueFor("shield_health")*2
	else
		 shield_health = self:GetSpecialValueFor("shield_health")
	end


	EmitSoundOn("urgotW", caster)

	caster:AddNewModifier(caster, self, "modifier_shield", {duration = 15.0, remaining_health = shield_health})
end



modifier_shield = modifier_shield or class ({})

function modifier_shield:IsDebuff() return false end
function modifier_shield:IsHidden() return false end
function modifier_shield:IsPurgable() return true end

function modifier_shield:GetEffectName()
	return "particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield.vpcf"
end

function modifier_shield:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shield:OnCreated(keys)
	if IsServer() then
		self.remaining_health = keys.remaining_health
		self:SetStackCount(self.remaining_health)
		self:StartIntervalThink(0.1)
	end
end

function modifier_shield:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
	end
end

function modifier_shield:OnIntervalThink()
	if IsServer() then
		if self.remaining_health <= 0 then
			self:GetParent():RemoveModifierByName("modifier_shield")
		end
	end
end

function modifier_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}
	return funcs
end

function modifier_shield:GetModifierAvoidDamage(keys)
	if IsServer() then
			self.remaining_health = self.remaining_health - keys.original_damage
			self:SetStackCount(self.remaining_health)
			return 1
	end
end






-------------------------------------------------------------------
-- Urgot E
-------------------------------------------------------------------

LinkLuaModifier("modifier_imba_phoenix_fire_spirits_debuff", "heroes/hero_urgot/hero_urgot", LUA_MODIFIER_MOTION_NONE)


imba_phoenix_launch_fire_spirit = imba_phoenix_launch_fire_spirit or class({})

function imba_phoenix_launch_fire_spirit:IsHiddenWhenStolen() 		return true end
function imba_phoenix_launch_fire_spirit:IsRefreshable() 			return true  end
function imba_phoenix_launch_fire_spirit:IsStealable() 				return false end
function imba_phoenix_launch_fire_spirit:IsNetherWardStealable() 	return false end
function imba_phoenix_launch_fire_spirit:GetAbilityTextureName()   return "urgotE" end

function imba_phoenix_launch_fire_spirit:GetCooldown(level)
	if IsServer() then
		if self:GetCaster():HasTalent("special_bonus_urgot_e_reduc") then
			return self.BaseClass.GetCooldown(self,level)/2
		else
			return self.BaseClass.GetCooldown(self,level)
		end
	end

end

function imba_phoenix_launch_fire_spirit:OnSpellStart()
	if IsServer() then
	local caster		= self:GetCaster()
	local point 		= self:GetCursorPosition()
	local ability		= self


	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	EmitSoundOn("urgotEshoot", caster)

	-- Projectile
	local distance = (caster:GetAbsOrigin()-point):Length2D()

	local info =
		{
			vSpawnOrigin = caster:GetAbsOrigin(),
			Source = caster,
			Ability = ability,
			fDistance = distance,
			vVelocity = (((point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * self:GetSpecialValueFor("spirit_speed"),
			EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
			bVisibleToEnemies = true,						-- Optional
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
	ProjectileManager:CreateLinearProjectile(info)
	end
end



function imba_phoenix_launch_fire_spirit:OnProjectileHit( hTarget, vLocation)
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local location = vLocation
	if hTarget then
		location = hTarget:GetAbsOrigin()
	end

	self.pfx_explosion = ParticleManager:CreateParticle("particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.pfx_explosion, 0, location)

	Timers:CreateTimer(1, function()
		ParticleManager:DestroyParticle(self.pfx_explosion, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_explosion)
	end)


	EmitSoundOnLocationWithCaster(location, "urgotEHit", caster)

	local units = FindUnitsInRadius(caster:GetTeamNumber(),
		location,
		nil,
		self:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
	for _,unit in pairs(units) do
		if unit ~= caster then
			if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
				unit:AddNewModifier(caster, self, "modifier_imba_phoenix_fire_spirits_debuff", {duration = self:GetSpecialValueFor("duration")} )
			end
		end
	end
	return true
end

function imba_phoenix_launch_fire_spirit:GetCastAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_2
end

modifier_imba_phoenix_fire_spirits_debuff = modifier_imba_phoenix_fire_spirits_debuff or class({})

function modifier_imba_phoenix_fire_spirits_debuff:IsDebuff()			return true  end
function modifier_imba_phoenix_fire_spirits_debuff:IsHidden() 			return false end
function modifier_imba_phoenix_fire_spirits_debuff:IsPurgable() 		return true  end
function modifier_imba_phoenix_fire_spirits_debuff:IsPurgeException() 	return true  end
function modifier_imba_phoenix_fire_spirits_debuff:IsStunDebuff() 		return false end
function modifier_imba_phoenix_fire_spirits_debuff:RemoveOnDeath() 		return true  end

function modifier_imba_phoenix_fire_spirits_debuff:GetTexture()
	return "urgotE"
end

function modifier_imba_phoenix_fire_spirits_debuff:GetEffectName() return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff_c.vpcf" end
function modifier_imba_phoenix_fire_spirits_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end


function modifier_imba_phoenix_fire_spirits_debuff:OnCreated()
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	local tick = ability:GetSpecialValueFor("tick_interval")
	self:StartIntervalThink( tick )
end


function modifier_imba_phoenix_fire_spirits_debuff:OnIntervalThink()
	if not IsServer() then
		return
	end
	if not self:GetParent():IsAlive() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local tick = ability:GetSpecialValueFor("tick_interval")
	local dmg = ability:GetSpecialValueFor("damage_per_second") * ( tick / 1.0 )
	local damageTable = {
		victim = self:GetParent(),
		attacker = caster,
		damage = dmg,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
	}
	ApplyDamage(damageTable)
end

function modifier_imba_phoenix_fire_spirits_debuff:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return func
end

function modifier_imba_phoenix_fire_spirits_debuff:GetModifierPhysicalArmorBonus()
		return self:GetAbility():GetSpecialValueFor("armor_reduction_pct") * 0.01 * self:GetParent():GetPhysicalArmorBaseValue() * (-1)
end








-------------------------------------------------------------------
-- Urgot R
-------------------------------------------------------------------


imba_vengefulspirit_nether_swap = class({})

LinkLuaModifier( "modifier_swap_dmg_reduction", "heroes/hero_urgot/hero_urgot", LUA_MODIFIER_MOTION_NONE )


function imba_vengefulspirit_nether_swap:IsHiddenWhenStolen() return false end
function imba_vengefulspirit_nether_swap:IsRefreshable() return true end
function imba_vengefulspirit_nether_swap:IsStealable() return true end
function imba_vengefulspirit_nether_swap:IsNetherWardStealable() return false end

function imba_vengefulspirit_nether_swap:GetAbilityTextureName()
	return "urgotR"
end
-------------------------------------------

function imba_vengefulspirit_nether_swap:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if caster:HasScepter() then
			
			self.allEnemies = FindUnitsInRadius(caster:GetTeamNumber(),
			Vector(0, 0, 0),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
			
			for _,unit in pairs(self.allEnemies) do
				EmitSoundOn("urgotRStart", unit)
			end

		end

		EmitSoundOn("urgotRStart", caster)
		EmitSoundOn("urgotRStart", target)

		--dmg reduction til urgot del
		local dmgReducDur = 0

		if self:GetCaster():HasTalent("special_bonus_urgot_r_boost") then
			dmgReducDur = self:GetSpecialValueFor("dmg_red_duration")*2
		else
			dmgReducDur = self:GetSpecialValueFor("dmg_red_duration")
		end

		caster:AddNewModifier(caster, self, "modifier_swap_dmg_reduction", {duration = dmgReducDur} )	
	end
end

function imba_vengefulspirit_nether_swap:OnChannelThink(flInterval)
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		
		if caster:HasScepter() then
			for _,unit in pairs(self.allEnemies) do
				if not unit:HasModifier("modifier_stunned") then
					unit:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
				end
			end
		else
			if not unit:HasModifier("modifier_stunned") then
				target:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
			end
		end
	end
end

function imba_vengefulspirit_nether_swap:OnChannelFinish(bInterrupted)
	if IsServer() then
	if bInterrupted then 
		self:GetCaster():RemoveModifierByName("modifier_swap_dmg_reduction")
		return end

		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		-- Parameters
		local tree_radius = self:GetSpecialValueFor("tree_radius")

		-- Ministun the target if it's an enemy
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			target:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
		end

		if caster:HasScepter() then
			for _,unit in pairs(self.allEnemies) do
				unit:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.2})
			end
		end		

		-- Play sounds
		caster:EmitSound("urgotREnd")
		target:EmitSound("urgotREnd")

		-- Disjoint projectiles
		ProjectileManager:ProjectileDodge(caster)
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			ProjectileManager:ProjectileDodge(target)
		end

		-- Play caster particle
		local caster_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControlEnt(caster_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

		-- Play target particle
		local target_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(target_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(target_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

		local target_loc = target:GetAbsOrigin()
		local caster_loc = caster:GetAbsOrigin()
		

			-- Swap positions
			Timers:CreateTimer(FrameTime(), function()
				FindClearSpaceForUnit(caster, target_loc, true)
				FindClearSpaceForUnit(target, caster_loc, true)
			end)

			-- Destroy trees around start and end areas
			GridNav:DestroyTreesAroundPoint(caster_loc, tree_radius, false)
			GridNav:DestroyTreesAroundPoint(target_loc, tree_radius, false)

			if caster:HasScepter() then

				self.allEnemies = FindUnitsInRadius(caster:GetTeamNumber(),
				Vector(0, 0, 0),
				nil,
				FIND_UNITS_EVERYWHERE,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_ALL,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false)

				local allEnemiesPos = {}
				local shitCounter = 0
				for _,unit in pairs(self.allEnemies) do
					allEnemiesPos[shitCounter] = unit:GetOrigin()
					shitCounter = shitCounter + 1
				end

				local counter = math.random(0,table.getn(self.allEnemies)-1)
				for _,unit in pairs(self.allEnemies) do
					local targetPos = allEnemiesPos[counter%table.getn(self.allEnemies)]

					Timers:CreateTimer(FrameTime(), function()
						FindClearSpaceForUnit(unit, targetPos, true)
						EmitSoundOn("urgotREnd", unit)
					end)

					counter = counter+1
				end
			end	
			
	end
end

modifier_swap_dmg_reduction = modifier_swap_dmg_reduction or class({})

-- Modifier properties
function modifier_swap_dmg_reduction:IsDebuff()			return false end
function modifier_swap_dmg_reduction:IsHidden() 			return false end
function modifier_swap_dmg_reduction:IsPurgable() 			return true end
function modifier_swap_dmg_reduction:IsPurgeException() 	return true end
function modifier_swap_dmg_reduction:IsStunDebuff() 		return false end
function modifier_swap_dmg_reduction:RemoveOnDeath() 		return true  end

function modifier_swap_dmg_reduction:OnCreated()
	local ability = self:GetAbility()
	self.dmg_reduction = ability:GetSpecialValueFor("dmg_reduction")
end

function modifier_swap_dmg_reduction:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
	return func
end

function modifier_swap_dmg_reduction:GetModifierIncomingDamage_Percentage( kv )
		return self.dmg_reduction
end