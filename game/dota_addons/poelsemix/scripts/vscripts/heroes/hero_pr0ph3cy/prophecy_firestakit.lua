LinkLuaModifier("modifier_pr0_firestakit", "heroes/hero_pr0ph3cy/prophecy_firestakit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pr0_firestakit_pos", "heroes/hero_pr0ph3cy/prophecy_firestakit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pr0_firestakit_wall", "heroes/hero_pr0ph3cy/prophecy_firestakit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pr0_firestakit_knockback", "heroes/hero_pr0ph3cy/prophecy_firestakit", LUA_MODIFIER_MOTION_HORIZONTAL)
--TAK IMBA
pr0_firestakit = pr0_firestakit or class({})


function pr0_firestakit:GetCastRange()
	local range = self:GetSpecialValueFor("range")
	return range
end
function pr0_firestakit:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius")
	return radius
end


function pr0_firestakit:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		local particle = "particles/units/heroes/hero_prophecy/firestakit_fence.vpcf"
		self.radius = self:GetSpecialValueFor("radius")  
		local delay = self:GetSpecialValueFor("delay")       
		self.duration = self:GetSpecialValueFor("duration")
		if self:GetCaster():FindAbilityByName("special_bonus_prophecy_7"):GetLevel() > 0 then self.duration = self.duration + self:GetCaster():FindAbilityByName("special_bonus_prophecy_7"):GetSpecialValueFor("value") end      
        EmitSoundOn("pr0_fire", caster)

		local formation_particle_fx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(formation_particle_fx, 0, target_point)
		ParticleManager:SetParticleControl(formation_particle_fx, 1, Vector(self.radius, 1, 0))
		ParticleManager:SetParticleControl(formation_particle_fx, 2, Vector(delay+self.duration, 0, 0))
		ParticleManager:SetParticleControl(formation_particle_fx, 4, Vector(1, 1, 1))
		ParticleManager:SetParticleControl(formation_particle_fx, 15, target_point)    

		Timers:CreateTimer(delay, function()
			CreateModifierThinker(caster, self, "modifier_pr0_firestakit", {duration = self.duration, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z, formation_particle_fx = formation_particle_fx}, target_point, caster:GetTeamNumber(), false)
		end)
    end
end


modifier_pr0_firestakit = modifier_pr0_firestakit or class({})

function modifier_pr0_firestakit:IsHidden()	return true end
function modifier_pr0_firestakit:IsPassive() return true end

function modifier_pr0_firestakit:OnCreated(keys)
	

	if IsServer() then
		self.caster = self:GetCaster()
		self.target = self:GetParent()
		self.ability = self:GetAbility()
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		--fuck you vectors --Lmao
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		self.duration = self.ability.duration
		local particle_field = "particles/units/heroes/hero_prophecy/firestakit_aura.vpcf" -- the field itself
		self.formation_particle_fx = keys.formation_particle_fx
		self.sound_cast = "pr0_fire_bgm"
		EmitSoundOn(self.sound_cast, self.caster)

		AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetAbsOrigin(), self.radius, self.duration, false)
			
		
		self.field_particle = ParticleManager:CreateParticle(particle_field, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.field_particle, 0, self.target_point)
		ParticleManager:SetParticleControl(self.field_particle, 1, Vector(self.radius, 1, 1))
		ParticleManager:SetParticleControl(self.field_particle, 2, Vector(self.duration, 0, 0))

		self.damage = self:GetAbility():GetSpecialValueFor("damage_tick")
		if self:GetCaster():FindAbilityByName("special_bonus_prophecy_6"):GetLevel() > 0 then self.damage = self.damage + self:GetCaster():FindAbilityByName("special_bonus_prophecy_6"):GetSpecialValueFor("value") end      

		self.tick_rate = self:GetAbility():GetSpecialValueFor("tick")
		self.time_since_last_tick = self.tick_rate
    	self.last_interval = 0

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_pr0_firestakit:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		ParticleManager:DestroyParticle(self.formation_particle_fx, true)
		ParticleManager:ReleaseParticleIndex(self.formation_particle_fx)	
		ParticleManager:DestroyParticle(self.field_particle, true)
		ParticleManager:ReleaseParticleIndex(self.field_particle)
		StopSoundEvent(self.sound_cast, caster)
	end
end

function modifier_pr0_firestakit:OnIntervalThink()
	local enemies_in_field = FindUnitsInRadius(
		self.caster:GetTeamNumber(),
		self.target_point,
		nil,
		self.radius,
		self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),
		self.ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,
		false
	)
	local parent = self:GetParent()
	self.time_since_last_tick = self.time_since_last_tick + (self:GetElapsedTime() - self.last_interval)
    self.last_interval = self:GetElapsedTime()

    if self.time_since_last_tick >= self.tick_rate then
        for _, enemy in pairs(enemies_in_field) do
			ApplyDamage({victim = enemy,
			attacker = self:GetCaster(),
			damage_type = self:GetAbility():GetAbilityDamageType(),
			damage = self.damage,
			ability = self:GetAbility()})
		end
        self.time_since_last_tick = self.time_since_last_tick - self.tick_rate
    end

	for _, enemy in pairs(enemies_in_field) do
		enemy:AddNewModifier(self.caster, self.ability, "modifier_pr0_firestakit_pos", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z, radius = self.radius})
	end
	
end


modifier_pr0_firestakit_pos = modifier_pr0_firestakit_pos or class({})

function modifier_pr0_firestakit_pos:IsHidden()	return true end
function modifier_pr0_firestakit_pos:OnCreated(keys)
	if not IsServer() then return end
	self.radius = keys.radius
	self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)

	
	self:StartIntervalThink(FrameTime())
end


function modifier_pr0_firestakit_pos:OnIntervalThink()
	if not IsServer() then return end

	self:kineticize(self:GetCaster(), self:GetParent(), self:GetAbility())
end

function modifier_pr0_firestakit_pos:kineticize(caster, target, ability)
	local center_of_field = self.target_point

	-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
	local distance = (target:GetAbsOrigin() - center_of_field):Length2D()
	local distance_from_border = distance - self.radius
	local modifier_barrier = "modifier_pr0_firestakit_wall"

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
		target:AddNewModifier(caster, ability, "modifier_pr0_firestakit_knockback", {duration = 0.2 * (1 - target:GetStatusResistance()), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
	else
		-- Removes debuffs, so the unit can move freely
		if target:HasModifier(modifier_barrier) then
			target:RemoveModifierByName(modifier_barrier)
		end
		self:Destroy()
	end
end

function modifier_pr0_firestakit_pos:GetEffectName()
	return "particles/pro/firestakit_fire.vpcf"
  end
  function modifier_pr0_firestakit_pos:GetEffectAttachType()
	  return PATTACH_ABSORIGIN
  end

function modifier_pr0_firestakit_pos:OnDestroy()
	if IsServer() then
		local target = self:GetParent()
			if target:HasModifier("modifier_pr0_firestakit_wall") then
				target:RemoveModifierByName("modifier_pr0_firestakit_wall")
			end
	end
end

modifier_pr0_firestakit_wall = modifier_pr0_firestakit_wall or class({})

function modifier_pr0_firestakit_wall:IsHidden()	return true end

function modifier_pr0_firestakit_wall:DeclareFunctions()
  local funcs = {
	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
  }
  return funcs
end
function modifier_pr0_firestakit_wall:GetModifierMoveSpeed_Absolute()
  return 0.1
end



modifier_pr0_firestakit_knockback = modifier_pr0_firestakit_knockback or class({})

function modifier_pr0_firestakit_knockback:IsHidden()	return true end
function modifier_pr0_firestakit_knockback:IsMotionController()	return true end
function modifier_pr0_firestakit_knockback:GetMotionControllerPriority()	return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_pr0_firestakit_knockback:OnCreated( keys )
	if IsServer() then
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)	
	end
end

function modifier_pr0_firestakit_knockback:DeclareFunctions()
  local funcs = { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
  return funcs
end
function modifier_pr0_firestakit_knockback:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end

function modifier_pr0_firestakit_knockback:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = IsServer()
	}
	return state
end

function modifier_pr0_firestakit_knockback:OnIntervalThink()
	-- Check motion controllers
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end
	-- Horizontal motion
	self:HorizontalMotion()	
end

function modifier_pr0_firestakit_knockback:HorizontalMotion()
	if IsServer() then
		local pull_distance = 5
		local direction = (self.target_point - self.parent:GetAbsOrigin()):Normalized()
		local set_point = self.parent:GetAbsOrigin() + direction * pull_distance
		self.parent:SetAbsOrigin(Vector(set_point.x, set_point.y, GetGroundPosition(set_point, self.parent).z))
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), false)
	end
end
