LinkLuaModifier("modifier_wave_cast", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
wave = class({})
--thanks dota imba for the tutorial luv u mwah hehe xd
function wave:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_wave_cast", {})
end

function wave:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
	return true
end

modifier_wave_cast = class ({})

function modifier_wave_cast:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wave_cast:IsPurgable() return	false end
function modifier_wave_cast:IsHidden() return	true end
function modifier_wave_cast:IgnoreTenacity() return true end
function modifier_wave_cast:IsMotionController() return true end
function modifier_wave_cast:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_wave_cast:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end

function modifier_wave_cast:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local max_distance = ability:GetSpecialValueFor("range") + GetCastRangeIncrease(caster)
		local distance = (caster:GetAbsOrigin() - caster:GetCursorPosition() ):Length2D()
		if distance > max_distance then distance = max_distance end

		self.direction = ( caster:GetCursorPosition() - caster:GetAbsOrigin() ):Normalized()
		self.velocity = ability:GetSpecialValueFor("velocity")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
	end
end

function modifier_wave_cast:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end

		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_wave_cast:HorizontalMotion(me, dt)
	if IsServer() then
		local caster = self:GetCaster()

		if self.distance_traveled < self.distance then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
		else
			self:Destroy()
		end
	end
end

function modifier_wave_cast:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
		end)
	end
end

LinkLuaModifier("modifier_destroyer_speed_passive", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_destroyer_speed_active", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
destroyer_speed = class({})

function destroyer_speed:GetIntrinsicModifierName() 
	return "modifier_destroyer_speed_passive"
end

function destroyer_speed:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_destroyer_speed_passive"):GetStackCount()
		local duration = self:GetSpecialValueFor("duration")

		caster:FindModifierByName("modifier_destroyer_speed_passive"):SetStackCount(0)
		caster:AddNewModifier(caster, self, "modifier_destroyer_speed_active", {duration = duration}) 
	end
end

function destroyer_speed:CastFilterResult()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_destroyer_speed_passive"):GetStackCount()
		local stack_count = self:GetSpecialValueFor("max_stacks")
	
		if modifier_stack_count == stack_count then
			return UF_SUCCES
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function destroyer_speed:GetCustomCastError()
	return "Not enough stacks"
end

modifier_destroyer_speed_active = class({})

function modifier_destroyer_speed_active:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_destroyer_speed_active:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_destroyer_speed_active:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

modifier_destroyer_speed_passive = class({})

function modifier_destroyer_speed_passive:IsPurgeable() return false end

function modifier_destroyer_speed_passive:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()

		self.startPos = self:GetCaster():GetAbsOrigin()
		self.stacks = 0
		self.max_stacks = ability:GetSpecialValueFor("max_stacks")
		self:StartIntervalThink(0.1)
	end
end

function modifier_destroyer_speed_passive:OnIntervalThink()
	if IsServer() then
		local caster_pos = self:GetCaster():GetAbsOrigin()
		local stacks = self:GetStackCount()

		if caster_pos ~= self.startPos and stacks < self.max_stacks then
			local distance = FindDistance(caster_pos, self.startPos)
			local stacks_to_add = math.floor(distance/10)
			print(stacks_to_add)

			if self:GetStackCount() + stacks_to_add > self.max_stacks then
				self:SetStackCount(self.max_stacks)
			else
				self:SetStackCount(stacks + math.floor(distance / 10))
			end
		end

		self.startPos = caster_pos
	end
end

torpedo = class({})

function torpedo:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local caster_pos = caster:GetAbsOrigin()
		local radius = FIND_UNITS_EVERYWHERE
		local speed = 500
		local damage = 0
		local vision_radius = 500
		local vision_duration = 5

		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

		if #heroes == 0 then
			return nil
		end

		for _, target in pairs(heroes) do
			local unit = CreateUnitByName("npc_torpedo", caster_pos, true, caster, caster, caster:GetTeamNumber()) 
			unit:SetForceAttackTarget(target)
			print(unit:GetForceAttackTarget())
		end

		--[[ shit
		for _, enemy in pairs(heroes) do
			local torpedo = 
			{
				Target = enemy,
				Source = caster,
				Ability = self,
				EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
				bProvidesVision = true,
				iMoveSpeed = speed,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO,
				bDeleteOnHit = true,
				fStartRadius = 200,
				fEndRadius = 200,

				ExtraData = {damage = damage, vision_radius = vision_radius, vision_duration = vision_duration, 
				speed = speed, 
				cast_origin_x = caster_pos.x, 
				cast_origin_y = caster_pos.y}
			}
			ProjectileManager:CreateTrackingProjectile(torpedo)
		end
		--]]
	end
end

LinkLuaModifier("modifier_dangerous_sea", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dangerous_sea_pool", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dangerous_sea_pool_slow", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)

dangerous_sea = class({})
function dangerous_sea:GetIntrinsicModifierName()
	return "modifier_dangerous_sea"
end

modifier_dangerous_sea = class({})

function modifier_dangerous_sea:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()

		self.pos = caster:GetAbsOrigin()
		self:StartIntervalThink(0.1)
	end
end

function modifier_dangerous_sea:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local distanceDifference = FindDistance(self.pos, caster:GetAbsOrigin())
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		--print("caster has moved", distanceDifference)

		if distanceDifference >= 300 then
			local thinker = CreateModifierThinker(caster, self:GetAbility(), "modifier_dangerous_sea_pool", {duration = duration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
			self.pos = caster:GetAbsOrigin()
		end
	end
end

--hidden modifier
modifier_dangerous_sea_pool = class({})

function modifier_dangerous_sea_pool:OnCreated()
	if IsServer() then
		--print("created thinker")
		local particle = "particles/heroes/shimakaze/shimakaze_run_water_ground.vpcf"
		local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
		self.caster_start = self:GetParent():GetAbsOrigin()
		self.pfx_pool = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx_pool, 0, self:GetParent():GetAbsOrigin())
		self.ability_damage = 0
		self:StartIntervalThink(tick_interval)
	end
end

function modifier_dangerous_sea_pool:OnDestroy()
	if IsServer() then 
		ParticleManager:DestroyParticle(self.pfx_pool, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_pool)
	end
end

function modifier_dangerous_sea_pool:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local damage = ability:GetSpecialValueFor("damage")
		local intellect = self:GetCaster():GetIntellect()
		local radius = ability:GetSpecialValueFor("radius")
		local duration_slow = ability:GetSpecialValueFor("duration_slow")
		local int_scaling_aghs = ability:GetSpecialValueFor("int_scaling_aghs")
		local int_scaling = ability:GetSpecialValueFor("int_scaling")	

		if caster:HasScepter() then
			self.ability_damage = damage + intellect*int_scaling_aghs
		else
			self.ability_damage = damage + intellect*int_scaling
		end

		local units = FindUnitsInRadius(caster:GetTeamNumber(), self.caster_start, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do
			ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = self.ability_damage, ability = ability})
			enemy:AddNewModifier(caster, ability, "modifier_dangerous_sea_pool_slow", {duration = duration_slow})
		end
	end
end

--slow modifier
modifier_dangerous_sea_pool_slow = class({})

function modifier_dangerous_sea_pool_slow:OnCreated()
	local slow_percentage = self:GetAbility():GetSpecialValueFor("move_slow")

	self.slow = slow_percentage
end

function modifier_dangerous_sea_pool_slow:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_dangerous_sea_pool_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

LinkLuaModifier("modifier_water", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
water = class({})

function water:GetIntrinsicModifierName()
	return "modifier_water"
end
--hidden modifier
modifier_water = class({})

function modifier_water:IsHidden() return true end

function modifier_water:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		self.prevPos = caster:GetAbsOrigin()

		self:StartIntervalThink(0.2)
	end
end

function modifier_water:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()

		--check if hero is moving
		if self.prevPos ~= caster:GetAbsOrigin() then
			self.particle = "particles/heroes/shimakaze/shimakaze_run_water.vpcf"
			self.pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(self.pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		end

		self.prevPos = caster:GetAbsOrigin()
	end
end
