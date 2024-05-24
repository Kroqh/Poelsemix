LinkLuaModifier("modifier_damian_dabbington_city", "heroes/hero_damian/damian_dabbington_city", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_dabbington_city_enemy", "heroes/hero_damian/damian_dabbington_city", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_dabbington_city_pos", "heroes/hero_damian/damian_dabbington_city", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_dabbington_city_wall", "heroes/hero_damian/damian_dabbington_city", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damian_dabbington_city_knockback", "heroes/hero_damian/damian_dabbington_city", LUA_MODIFIER_MOTION_HORIZONTAL)
--TAK IMBA
damian_dabbington_city = damian_dabbington_city or class({})


function damian_dabbington_city:GetCastRange()
	local range = self:GetSpecialValueFor("cast_range")
	return range
end


function damian_dabbington_city:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local target_point = target:GetAbsOrigin()
		local particle = "particles/units/heroes/hero_prophecy/firestakit_fence.vpcf"
		self.radius = self:GetSpecialValueFor("arena_size")      
		self.duration = self:GetSpecialValueFor("duration")
        EmitSoundOn("damian_dabbington", caster)
		caster:AddNewModifier(caster, self, "modifier_damian_dabbington_city", {duration = self.duration, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z, formation_particle_fx = formation_particle_fx, target = target:GetEntityIndex() })
		target:AddNewModifier(caster, self, "modifier_damian_dabbington_city_enemy", {duration = self.duration, target =  caster:GetEntityIndex()})
    end
end


modifier_damian_dabbington_city_enemy = modifier_damian_dabbington_city_enemy or class({})

function modifier_damian_dabbington_city_enemy:IsHidden()	return false end
function modifier_damian_dabbington_city_enemy:IsPurgable() return false end
function modifier_damian_dabbington_city_enemy:IsDebuff() return true end
function modifier_damian_dabbington_city_enemy:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_damian_dabbington_city_enemy:OnCreated(keys)
	if IsServer() then
		self.target = EntIndexToHScript( keys.target)
	end
end


function modifier_damian_dabbington_city_enemy:OnHeroKilled(event)
	if IsServer() then
		if event.target ~= self.target then return end
		ParticleManager:CreateParticle("particles/treasure_courier_death_coins.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		self:GetParent():ModifyGold(self:GetAbility():GetSpecialValueFor("bonus_gold_winner"), false, 0)
		self:Destroy()
	end
end

function modifier_damian_dabbington_city_enemy:GetModifierIncomingDamage_Percentage(event)
	if IsServer() then
		if event.attacker ~=  self.target and event.target == self:GetParent() then 
			return -(100 - self:GetAbility():GetSpecialValueFor("damage_percent_from_other_sources"))
		end
	end
end

function modifier_damian_dabbington_city_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end


modifier_damian_dabbington_city = modifier_damian_dabbington_city or class({})

function modifier_damian_dabbington_city:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end


function modifier_damian_dabbington_city:OnHeroKilled(event)
	if IsServer() then
		if event.target ~= self.target then return end
		ParticleManager:CreateParticle("particles/treasure_courier_death_coins.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		self:GetParent():ModifyGold(self:GetAbility():GetSpecialValueFor("bonus_gold_winner"), false, 0)
		local mod =self:GetParent():FindModifierByName("modifier_damian_faded_max_stack_tracker")
		local stacks = self:GetAbility():GetSpecialValueFor("damian_faded_stack_cap_for_win")
		if self:GetCaster():FindAbilityByName("special_bonus_damian_8"):GetLevel() > 0 then stacks = stacks + self:GetCaster():FindAbilityByName("special_bonus_damian_8"):GetSpecialValueFor("value") end
		mod:SetStackCount(mod:GetStackCount()+stacks)
		EmitSoundOn("damian_cheers", self:GetParent())
		self:Destroy()
	end
end

function modifier_damian_dabbington_city:GetModifierIncomingDamage_Percentage(event)
	if IsServer() then
		if event.attacker ~=  self.target and event.target == self:GetParent() then 
			return -(100 - self:GetAbility():GetSpecialValueFor("damage_percent_from_other_sources")) 
		end
	end
end

function modifier_damian_dabbington_city:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end


function modifier_damian_dabbington_city:IsHidden()	return false end
function modifier_damian_dabbington_city:IsPurgable() return false end

function modifier_damian_dabbington_city:OnCreated(keys)
	if IsServer() then
		self.caster = self:GetCaster()
		self.point = self:GetParent()
		self.ability = self:GetAbility()
		self.radius = 350
		self.target = EntIndexToHScript( keys.target)
		--fuck you vectors --Lmao
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		self.duration = self.ability.duration
		local particle_field = "particles/units/heroes/hero_damian/dabbington_city.vpcf" -- the field itself
		self.formation_particle_fx = keys.formation_particle_fx

		AddFOWViewer(self.caster:GetTeamNumber(), self.point:GetAbsOrigin(), self.radius, self.duration, false)
			
		self.field_particle = ParticleManager:CreateParticle(particle_field, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.field_particle, 0, self.target_point)
		ParticleManager:SetParticleControl(self.field_particle, 1, Vector(self.radius, 1, 1))
		ParticleManager:SetParticleControl(self.field_particle, 2, Vector(self.duration, 0, 0))


		self:StartIntervalThink(FrameTime())
	end
end

function modifier_damian_dabbington_city:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		--ParticleManager:DestroyParticle(self.formation_particle_fx, true)
		--ParticleManager:ReleaseParticleIndex(self.formation_particle_fx)	
		ParticleManager:DestroyParticle(self.field_particle, true)
		ParticleManager:ReleaseParticleIndex(self.field_particle)
	end
end

function modifier_damian_dabbington_city:OnIntervalThink()
	self.target:AddNewModifier(self.caster, self.ability, "modifier_damian_dabbington_city_pos", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z, radius = self.radius})
	self.caster:AddNewModifier(self.caster, self.ability, "modifier_damian_dabbington_city_pos", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z, radius = self.radius})
end


modifier_damian_dabbington_city_pos = modifier_damian_dabbington_city_pos or class({})

function modifier_damian_dabbington_city_pos:IsHidden()	return true end
function modifier_damian_dabbington_city_pos:OnCreated(keys)
	if not IsServer() then return end
	self.radius = keys.radius
	self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)

	
	self:StartIntervalThink(FrameTime())
end


function modifier_damian_dabbington_city_pos:OnIntervalThink()
	if not IsServer() then return end

	self:kineticize(self:GetCaster(), self:GetParent(), self:GetAbility())
end

function modifier_damian_dabbington_city_pos:kineticize(caster, target, ability)
	local center_of_field = self.target_point

	-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
	local distance = (target:GetAbsOrigin() - center_of_field):Length2D()
	local distance_from_border = distance - self.radius
	local modifier_barrier = "modifier_damian_dabbington_city_wall"

	-- The target's angle in the world
--	local target_angle = target:GetAnglesAsVector().y
	
	-- Solves for the target's angle in relation to the center of the circle in radians
	local origin_difference =  center_of_field - target:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Converts the radians to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local angle_from_center = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	angle_from_center = angle_from_center + 180.0	
	-- Checks if the target is inside the field
	if distance_from_border <= 0 and math.abs(distance_from_border) <= math.max(target:GetHullRadius(), 50) then
	
		target:InterruptMotionControllers(true)
	-- Checks if the target is outside the field,
	elseif distance_from_border > 0 and math.abs(distance_from_border) <= math.max(target:GetHullRadius(), 60) then
	
		target:InterruptMotionControllers(true)
		target:AddNewModifier(caster, ability, "modifier_damian_dabbington_city_knockback", {duration = 0.2 * (1 - target:GetStatusResistance()), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
	else
		-- Removes debuffs, so the unit can move freely
		if target:HasModifier(modifier_barrier) then
			target:RemoveModifierByName(modifier_barrier)
		end
		self:Destroy()
	end
end

function modifier_damian_dabbington_city_pos:OnDestroy()
	if IsServer() then
		local target = self:GetParent()
			if target:HasModifier("modifier_damian_dabbington_city_wall") then
				target:RemoveModifierByName("modifier_damian_dabbington_city_wall")
			end
	end
end

modifier_damian_dabbington_city_wall = modifier_damian_dabbington_city_wall or class({})

function modifier_damian_dabbington_city_wall:IsHidden()	return true end

function modifier_damian_dabbington_city_wall:DeclareFunctions()
  local funcs = {
	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
  }
  return funcs
end
function modifier_damian_dabbington_city_wall:GetModifierMoveSpeed_Absolute()
  return 0.1
end



modifier_damian_dabbington_city_knockback = modifier_damian_dabbington_city_knockback or class({})

function modifier_damian_dabbington_city_knockback:IsHidden()	return true end
function modifier_damian_dabbington_city_knockback:IsMotionController()	return true end
function modifier_damian_dabbington_city_knockback:GetMotionControllerPriority()	return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_damian_dabbington_city_knockback:OnCreated( keys )
	if IsServer() then
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)	
	end
end

function modifier_damian_dabbington_city_knockback:DeclareFunctions()
  local funcs = { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
  return funcs
end
function modifier_damian_dabbington_city_knockback:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end

function modifier_damian_dabbington_city_knockback:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = IsServer()
	}
	return state
end

function modifier_damian_dabbington_city_knockback:OnIntervalThink()
	-- Check motion controllers
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end
	-- Horizontal motion
	self:HorizontalMotion()	
end

function modifier_damian_dabbington_city_knockback:HorizontalMotion()
	if IsServer() then
		local pull_distance = 5
		local direction = (self.target_point - self.parent:GetAbsOrigin()):Normalized()
		local set_point = self.parent:GetAbsOrigin() + direction * pull_distance
		self.parent:SetAbsOrigin(Vector(set_point.x, set_point.y, GetGroundPosition(set_point, self.parent).z))
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), false)
	end
end
