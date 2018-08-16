LinkLuaModifier("modifier_wave_cast", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
wave = class({})
--thanks dota imba for the tutorial luv u mwah hehe xd
function wave:GetAbilityTextureName()
	return "shimakaze_wave"
end

function wave:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_wave_cast", {})
	self:EmitSound("shimakaze_wave")
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
		if caster:HasTalent("special_bonus_shimakaze_1") then
			local bonus_range = caster:FindAbilityByName("special_bonus_shimakaze_1"):GetSpecialValueFor("value")
			max_distance = max_distance + bonus_range
		end
		
		print(max_distance)
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
LinkLuaModifier("modifier_destroyer_speed_cap", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
destroyer_speed = class({})

function destroyer_speed:GetAbilityTextureName()
	return "shimakaze_speed"
end

function destroyer_speed:GetIntrinsicModifierName() 
	return "modifier_destroyer_speed_passive"
end

function destroyer_speed:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_destroyer_speed_passive"):GetStackCount()
		local duration = self:GetSpecialValueFor("duration")

		caster:FindModifierByName("modifier_destroyer_speed_passive"):SetStackCount(0)
		if caster:HasTalent("special_bonus_shimakaze_2") then
			local speed = caster:FindAbilityByName("special_bonus_shimakaze_2"):GetSpecialValueFor("speed")
			CustomNetTables:SetTableValue("player_table", "modifier_destroyer_speed_cap", {speed = speed})
			
			caster:AddNewModifier(caster, self, "modifier_destroyer_speed_cap", {duration = duration})
		end
		caster:AddNewModifier(caster, self, "modifier_destroyer_speed_active", {duration = duration})
		
		self:EmitSound("shimakaze_ossoi")
	end
end

function destroyer_speed:CastFilterResult()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_destroyer_speed_passive"):GetStackCount()
		local stack_count = self:GetSpecialValueFor("max_stacks")
	
		if modifier_stack_count == stack_count then
			return UF_SUCCESS
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
			--print(stacks_to_add)

			if self:GetStackCount() + stacks_to_add > self.max_stacks then
				self:SetStackCount(self.max_stacks)
			else
				self:SetStackCount(stacks + math.floor(distance / 10))
			end
		end

		self.startPos = caster_pos
	end
end

modifier_destroyer_speed_cap = class({})

function modifier_destroyer_speed_cap:IsPurgeable() return false end

function modifier_destroyer_speed_cap:OnCreated(keys)
	self.speed = CustomNetTables:GetTableValue("player_table", "modifier_destroyer_speed_cap").speed
	print(self.speed)
end

function modifier_destroyer_speed_cap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}

	return funcs
end

function modifier_destroyer_speed_cap:GetModifierMoveSpeed_Max()
	return self.speed
end

function modifier_destroyer_speed_cap:GetModifierMoveSpeed_Limit()
	return self.speed
end

function modifier_destroyer_speed_cap:IsHidden()
	return true
end

LinkLuaModifier("modifier_ap_shell", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
ap_shell = class({})

function ap_shell:GetAbilityTextureName()
	return "ap_shell"
end

function ap_shell:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
		local speed = self:GetSpecialValueFor("speed")

		local shell = 
			{
				Target = target,
				Source = caster,
				Ability = self,
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(shell)
		self:EmitSound("shimakaze_ap_shell")
		self:EmitSound("Ability.Assassinate")
	end
end

function ap_shell:OnProjectileHit(target)
	if not target then
		return nil
	end

	local duration = self:GetSpecialValueFor("duration") 

	target:AddNewModifier(self:GetCaster(), self, "modifier_ap_shell", {duration = duration}) 
end

modifier_ap_shell = class({})

function modifier_ap_shell:OnCreated()
	local ability = self:GetAbility()

	self.magic_resist = ability:GetSpecialValueFor("magic_resist")
end

function modifier_ap_shell:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
	return decFuncs
end

function modifier_ap_shell:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_ap_shell:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_ap_shell:StatusEffectPriority()
	return 10
end

LinkLuaModifier("modifier_torpedo_taunt", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_torpedo_stun", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
torpedo = class({})

function torpedo:GetAbilityTextureName()
	return "shimakaze_torpedo"
end

function torpedo:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local caster_pos = caster:GetAbsOrigin()
		local radius = FIND_UNITS_EVERYWHERE
		AddFOWViewer(caster:GetTeamNumber(), Vector(0,0,0), 9999, 1, false)
		self.heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		if #self.heroes == 0 then
			return nil
		end

		for _, target in pairs(self.heroes) do
			AddFOWViewer(target:GetTeamNumber(), caster_pos, 450, 2, false)
			local enemy_target = target:entindex()
			local unit = CreateUnitByName("npc_torpedo", caster_pos, true, caster, caster, caster:GetTeamNumber()) 
			unit:AddNewModifier(caster, self, "modifier_torpedo_taunt", {enemy_to_attack = enemy_target}) 
			unit:SetOwner(caster)

			if caster:HasTalent("special_bonus_shimakaze_3") then
				--print("double torpedo")
				Timers:CreateTimer({
  		 			endTime = 1.5,
   					callback = function()
    				local unit2 = CreateUnitByName("npc_torpedo", caster_pos, true, caster, caster, caster:GetTeamNumber()) 
					unit2:AddNewModifier(caster, self, "modifier_torpedo_taunt", {enemy_to_attack = enemy_target}) 
					unit2:SetOwner(caster)
 		  	 	end
 				})
			end
		end

		self:EmitSound("shimakaze_shelling")
	end
end

modifier_torpedo_taunt = modifier_torpedo_taunt or class({})

function modifier_torpedo_taunt:IsHidden() return true end

function modifier_torpedo_taunt:CheckState()
	local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	return state
end

function modifier_torpedo_taunt:OnCreated(keys)
	if IsServer() then
		self.target = EntIndexToHScript(keys.enemy_to_attack)
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.explosion_particle = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_call_down_explosion_impact_a.vpcf"

		local particle = "particles/heroes/shimakaze/shimakaze_torpedo.vpcf"
		self.pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.pfx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)

		self.time_passed = 0
		self:StartIntervalThink(0.02)
	end
end

function modifier_torpedo_taunt:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local unit = self:GetParent()
		local unit_pos = unit:GetAbsOrigin()
		local target = self.target
		local target_pos = target:GetAbsOrigin()
		local ability = self:GetAbility()
		local interval = 0.02
		local has_damaged = false

		--Special values
		local velocity = ability:GetSpecialValueFor("velocity")*interval
		local radius = ability:GetSpecialValueFor("search_radius")
		local explosion_radius = ability:GetSpecialValueFor("radius")
		local stun_duration = ability:GetSpecialValueFor("stun_duration")

		if caster:HasTalent("special_bonus_shimakaze_4") then
			stun_duration = stun_duration * 2
			--print(stun_duration)
		end

		local enemies = FindUnitsInRadius(unit:GetTeamNumber(), unit_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		if #enemies == 0 then
			enemies = nil
		end
		
		-- torpedo kills itself
		if not target:IsAlive() then
			local heroes = FindUnitsInRadius(caster:GetTeamNumber(), unit_pos, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 
			
			if #heroes == 0 then
				self:StartIntervalThink(-1)
				local explosion = FindUnitsInRadius(unit:GetTeamNumber(), unit_pos, nil, explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				local explosion_pfx = ParticleManager:CreateParticle(self.explosion_particle, PATTACH_WORLDORIGIN, unit)
				ParticleManager:SetParticleControl(explosion_pfx, 3, unit_pos)

				ability:EmitSound("torpedo_hit")
				unit:AddNoDraw()
				unit:ForceKill(false)
			end
			
			if #heroes > 0 then
				self:StartIntervalThink(-1)
				local count = 0
				for _, enemy in pairs(heroes) do
					count = count + 1
				end
				print("amount of heroes is", count)

				local new_target = math.random(1, count)
				print("new target id is", new_target)

				local count_lol = 1

				for _, enemy in pairs(heroes) do
					if new_target == count_lol then
						print("new target is", new_target, "count_lol is", count_lol)
						self.target = enemy
					else
						count_lol = count_lol + 1
					end
				end
			end

			self:StartIntervalThink(interval)
		end

		--Check if table enemies is not empty and torpedo hasn't damaged
		if enemies ~= nil and has_damaged == false then
			self:StartIntervalThink(-1)
			has_damaged = true
			local explosion = FindUnitsInRadius(unit:GetTeamNumber(), unit_pos, nil, explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			local explosion_pfx = ParticleManager:CreateParticle(self.explosion_particle, PATTACH_WORLDORIGIN, unit)
			ParticleManager:SetParticleControl(explosion_pfx, 3, unit_pos)
			ability:EmitSound("torpedo_hit")
			for _, enemy in pairs(explosion) do
				ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_PURE, damage = self.damage, ability = ability})
				enemy:AddNewModifier(caster, ability, "modifier_torpedo_stun", {duration = stun_duration})
			end
			unit:AddNoDraw()
			unit:ForceKill(false)
		else
			local direction = (target_pos - unit_pos):Normalized()
			self.time_passed = self.time_passed + interval

			velocity = velocity * (self.time_passed/10)

			unit:SetForwardVector(direction)
			unit:SetAbsOrigin(unit_pos + direction * velocity)
		end
	end
end

modifier_torpedo_stun = class({})

function modifier_torpedo_stun:IsPurgeable() return false end
function modifier_torpedo_stun:IsHidden() return true end

function modifier_torpedo_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_torpedo_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_torpedo_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

LinkLuaModifier("modifier_dangerous_sea", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dangerous_sea_pool", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dangerous_sea_pool_slow", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)

dangerous_sea = class({})
function dangerous_sea:GetIntrinsicModifierName()
	return "modifier_dangerous_sea"
end

function dangerous_sea:GetAbilityTextureName()
	return "shimakaze_sea"
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
		local distance_req = self:GetAbility():GetSpecialValueFor("distance_req")
		--print("caster has moved", distanceDifference)

		if distanceDifference >= distance_req then
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
