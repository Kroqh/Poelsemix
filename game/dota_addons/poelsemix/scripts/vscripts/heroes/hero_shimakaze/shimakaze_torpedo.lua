LinkLuaModifier("shimakaze_modifier_torpedo_taunt", "heroes/hero_shimakaze/shimakaze_torpedo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shimakaze_modifier_torpedo_stun", "heroes/hero_shimakaze/shimakaze_torpedo", LUA_MODIFIER_MOTION_NONE)
shimakaze_torpedo = shimakaze_torpedo or class({})

function shimakaze_torpedo:GetAbilityTextureName()
	return "shimakaze_torpedo"
end

function shimakaze_torpedo:OnSpellStart() 
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
			unit:AddNewModifier(caster, self, "shimakaze_modifier_torpedo_taunt", {enemy_to_attack = enemy_target}) 
			unit:SetOwner(caster)

			if caster:HasTalent("special_bonus_shimakaze_3") then
				--print("double torpedo")
				Timers:CreateTimer({
  		 			endTime = 1.5,
   					callback = function()
    				local unit2 = CreateUnitByName("npc_torpedo", caster_pos, true, caster, caster, caster:GetTeamNumber()) 
					unit2:AddNewModifier(caster, self, "shimakaze_modifier_torpedo_taunt", {enemy_to_attack = enemy_target}) 
					unit2:SetOwner(caster)
 		  	 	end
 				})
			end
		end

		self:EmitSound("shimakaze_shelling")
	end
end

shimakaze_modifier_torpedo_taunt = shimakaze_modifier_torpedo_taunt or class({})

function shimakaze_modifier_torpedo_taunt:IsHidden() return true end

function shimakaze_modifier_torpedo_taunt:CheckState()
	local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	return state
end

function shimakaze_modifier_torpedo_taunt:OnCreated(keys)
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

function shimakaze_modifier_torpedo_taunt:OnIntervalThink()
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
				ApplyDamage({victim = enemy, attacker = caster, damage_type = ability:GetAbilityDamageType(), damage = self.damage, ability = ability})
				enemy:AddNewModifier(caster, ability, "shimakaze_modifier_torpedo_stun", {duration = stun_duration})
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

shimakaze_modifier_torpedo_stun = shimakaze_modifier_torpedo_stun or class({})

function shimakaze_modifier_torpedo_stun:IsPurgeable() return true end
function shimakaze_modifier_torpedo_stun:IsHidden() return false end

function shimakaze_modifier_torpedo_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function shimakaze_modifier_torpedo_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function shimakaze_modifier_torpedo_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end
