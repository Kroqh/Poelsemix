--------------------------------------------------------------------------------
-- Move Only
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_move_only", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
move_only = move_only or class({})

function move_only:GetIntrinsicModifierName()
    return "modifier_move_only"
end

modifier_move_only = modifier_move_only or class({})

function modifier_move_only:IsHidden() return true end
function modifier_move_only:IsPurgeable() return false end

function modifier_move_only:CheckState()
	local state = {
	    [MODIFIER_STATE_DISARMED] = true
	}
	return state
end

--------------------------------------------------------------------------------
-- Cyclone
-- TODO: 
-- - Add animation
-- - Add particle -- DONE
-- - Add movement slow -- DONE
-- - Add talents -- DONE
-- - Prevent toggle if vaal cyclone is active
-- - Add aghs upgrade  -- DONE
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_poe_cyclone", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_poe_cyclone_motion", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
poe_cyclone = poe_cyclone or class({})

-- ASSUMES ONLY ONE
-- IF LEVEL 30 THEN INCREASED AOE + damage
local function calculateCycloneRadius(caster)
	local radius = caster:FindAbilityByName("poe_cyclone"):GetSpecialValueFor("radius")
	
	if caster:HasTalent("marauder_cyclone_inc_aoe") then
		local new_range = caster:FindAbilityByName("marauder_cyclone_inc_aoe"):GetSpecialValueFor("radius")
		print("new_range = " .. new_range)
		return radius + new_range
	end

	if caster:HasTalent("conc_effect") then
		local new_range = caster:FindAbilityByName("conc_effect"):GetSpecialValueFor("radius_reduction")
		print("new_range = " .. new_range)
		return radius * (1 - new_range)
	end


	return radius
end

function poe_cyclone:GetCastRange()
	return calculateCycloneRadius(self:GetCaster())
end

function poe_cyclone:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_poe_cyclone", {})
		caster:AddNewModifier(caster, self, "modifier_poe_cyclone_motion", {})
	else
		caster:FindModifierByName("modifier_poe_cyclone"):Destroy()
		caster:FindModifierByName("modifier_poe_cyclone_motion"):Destroy()
	end
end

modifier_poe_cyclone = modifier_poe_cyclone or class({})

function modifier_poe_cyclone:IsHidden() return false end
function modifier_poe_cyclone:IsPurgeable() return false end
function modifier_poe_cyclone:ResetToggleOnRespawn()	return true end

function modifier_poe_cyclone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_poe_cyclone:OnCreated()
	if not IsServer() then return end
	local particle = "particles/heroes/marauder/cyclone_particle.vpcf"

	local caster = self:GetCaster()

	local aps_base = self:GetAbility():GetSpecialValueFor("aps_base")
	local ats_scaling = self:GetAbility():GetSpecialValueFor("ats_scaling")
	local min_aps = self:GetAbility():GetSpecialValueFor("min_aps")

	-- CONC EFFECT
	self.radius = calculateCycloneRadius(caster)

	print("self.radius = " .. self.radius)

	-- ATTACKS PER SECOND
	local aps = aps_base - ats_scaling * caster:GetAttackSpeed()
	print("aps base - ats_scaling * caster:GetAttackSpeed() = " .. aps_base .. " - " .. ats_scaling .. " * " .. caster:GetAttackSpeed() .. " = " .. aps)
	if aps < min_aps then
		aps = min_aps
	end

	-- self.current_orientation = caster:GetForwardVector()
	self.pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius * 0.35, 0, 0))

	self:StartIntervalThink(0.2)
end

function modifier_poe_cyclone:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_slow")
end

function modifier_poe_cyclone:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	
	local base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
	-- CONC EFFECT
	if caster:HasTalent("conc_effect") then
		local bonus_damage = caster:FindAbilityByName("conc_effect"):GetSpecialValueFor("base_dmg")
		base_damage = base_damage + bonus_damage
	end

	print("base_damage = " .. base_damage)

	local damage_scaling = self:GetAbility():GetSpecialValueFor("damage_scaling")

	-- DAMAGE APPLIED PER TICK
	local damage = base_damage + damage_scaling * caster:GetAttackDamage()
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									  caster:GetAbsOrigin(), 
									  nil, 
									  self.radius, 
									  DOTA_UNIT_TARGET_TEAM_ENEMY, 
									  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
									  DOTA_UNIT_TARGET_FLAG_NONE, 
									  FIND_ANY_ORDER, 
									  false)

	for _, enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility()
		})
	end

	-- AGHS
	if caster:HasScepter() then
		IceNova(self, enemies)
	end


	caster:ReduceMana(self:GetAbility():GetManaCost(-1))

	if caster:GetMana() < self:GetAbility():GetManaCost(-1) then
		self:GetAbility():ToggleAbility()
	end
end

function modifier_poe_cyclone:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
end

function IceNova(self, enemies) 
	if not IsServer() then return end
	-- todo: dont proc on mirage saviours


	local particle = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"
	local caster = self:GetCaster()
	local damage = self:GetAbility():GetSpecialValueFor("ice_nova_damage")
	local radius = calculateCycloneRadius(caster)
	local chance = self:GetAbility():GetSpecialValueFor("ice_nova_chance")
	local damage_type = DAMAGE_TYPE_MAGICAL

	for _, enemy in pairs(enemies) do
		if RollPseudoRandom(chance, self) then
			print("ice nova proc")
			caster:EmitSound("Hero_Crystal.CrystalNova")
			ApplyDamage({
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = damage_type,
				ability = self:GetAbility()
			})

			local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 1, radius))
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end

-- ANIMATION for later

modifier_poe_cyclone_motion = modifier_poe_cyclone_motion or class({})

-- function modifier_poe_cyclone_motion:GetOverrideAnimation()
-- 	return ACT_DOTA_FLAIL
-- end

-- function modifier_poe_cyclone_motion:IsHidden() return true end
-- function modifier_poe_cyclone_motion:IsPurgeable() return false end

-- function modifier_poe_cyclone_motion:OnCreated()
-- 	if not IsServer() then return end
-- 	local caster = self:GetCaster()
-- 	local ability = self:GetAbility()

-- 	self.forward = caster:GetForwardVector()
-- 	self:StartIntervalThink(FrameTime())
-- end

-- function modifier_poe_cyclone_motion:OnIntervalThink()
-- 	-- rotate the unit a small bit to the right
-- 	local angle = self:GetParent():GetAngles()
-- 	local new_angle = RotateOrientation(angle, QAngle(0,20,0))
-- 	self:GetParent():SetAngles(new_angle.x, new_angle.y, new_angle.z)
-- 	-- self:GetParent():SetForwardVector(new_angle:Forward())
-- 	self.forward = self:GetParent():GetForwardVector()
-- end

--------------------------------------------------------------------------------
-- LEAP SLAM
--------------------------------------------------------------------------------
-- add sound
-- add particle
-- add damage -- done
-- add fortify
LinkLuaModifier("modifier_leap_slam", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
leap_slam = leap_slam or class({})

function leap_slam:OnSpellStart() 
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("leap_duration")
	caster:AddNewModifier(caster, self, "modifier_leap_slam", {duration = duration})
end

modifier_leap_slam = modifier_leap_slam or class({})

function modifier_leap_slam:IsMotionController() return true end
function modifier_leap_slam:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_leap_slam:CheckState()
	if not IsServer() then return end
	local state = {	[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
	return state
end

function modifier_leap_slam:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.click_location = caster:GetCursorPosition()

	self.max_distance = (self.click_location - caster:GetAbsOrigin()):Length2D()
	self.direction = (self.click_location - caster:GetAbsOrigin()):Normalized()
	self.distance_to_move_pr_frame = self.max_distance / self:GetDuration()
	self.distance_traveled = 0
	
	caster:SetForwardVector(self.direction)
	self:StartIntervalThink(FrameTime())
end

function modifier_leap_slam:OnIntervalThink()
	if not IsServer() then return end
	self:HorizontalMotion(self:GetParent(), FrameTime())
	self:VerticalMotion(self:GetParent(), FrameTime())
end

function modifier_leap_slam:HorizontalMotion(me, dt)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local distance = self.distance_to_move_pr_frame * dt
	local new_pos = caster:GetAbsOrigin() + self.direction * distance
	caster:SetAbsOrigin(new_pos)

	self.distance_traveled = self.distance_traveled + distance
	if self.distance_traveled >= self.max_distance then
		self:Destroy()
	end
end

function modifier_leap_slam:VerticalMotion(me, dt)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local distance = self.distance_to_move_pr_frame * dt
	local height = 0
	local height_change = 20

	if self.distance_traveled < self.max_distance / 2 then
		height = height_change
	else
		height = (-1 * height_change)
	end

	local new_pos = caster:GetAbsOrigin() + Vector(0,0,height)
	caster:SetAbsOrigin(new_pos)
end

function modifier_leap_slam:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	FindClearSpaceForUnit(caster, self.click_location, true)
	self:leap_slam_damage(self, self.click_location)
end

function modifier_leap_slam:leap_slam_damage(self, click_location) 
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	local radius = ability:GetSpecialValueFor("radius")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_type = ability:GetAbilityDamageType()


	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									  click_location, 
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
	-- particle
	-- sound
end


