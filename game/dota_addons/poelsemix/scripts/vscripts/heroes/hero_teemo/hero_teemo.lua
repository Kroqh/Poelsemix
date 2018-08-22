LinkLuaModifier("modifier_blinding_dart_blind", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
blinding_dart = class({})

function blinding_dart:GetAbilityTextureName()
	return "blinding_dart"
end

function blinding_dart:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf"
		local speed = 1300
		local int_scaling_talent = caster:FindAbilityByName("special_bonus_teemo_3"):GetSpecialValueFor("value")
		CustomNetTables:SetTableValue("player_table", "blinding_dart", {int_scaling_talent = int_scaling_talent})

		local dart = 
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
		ProjectileManager:CreateTrackingProjectile(dart)
		EmitSoundOn("teemo_blindingdart", caster)
	end
end

function blinding_dart:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	local intellect = caster:GetIntellect()
	local int_scaling = self:GetSpecialValueFor("int_scaling")
	if caster:HasTalent("special_bonus_teemo_3") then
		local int_talent = CustomNetTables:GetTableValue("player_table", "blinding_dart").int_scaling_talent
		--print(int_talent)
		local int_scaling = int_scaling + int_talent
	end

	local damage = self:GetSpecialValueFor("damage") + intellect*int_scaling
	local duration = self:GetSpecialValueFor("duration")

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = DAMAGE_TYPE_MAGICAL,
	damage = damage,
	ability = self})
	
	target:AddNewModifier(caster, self, "modifier_blinding_dart_blind", {duration = duration})
end

modifier_blinding_dart_blind = class({})

function modifier_blinding_dart_blind:IsDebuff() return true end

function modifier_blinding_dart_blind:OnCreated()
	if IsServer() then
		EmitSoundOn("teemo_blindingdart_oh", self:GetParent())
	end
end

function modifier_blinding_dart_blind:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MISS_PERCENTAGE}
	return decFuncs
end

function modifier_blinding_dart_blind:GetModifierMiss_Percentage()
	return 100
end

LinkLuaModifier("modifier_move_quick_passive", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_move_quick_handler", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_move_quick_active", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
move_quick = class({})

function move_quick:GetAbilityTextureName()
	return "move_quick"
end

function move_quick:GetIntrinsicModifierName()
	return "modifier_move_quick_handler"
end

function move_quick:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		local particle = "particles/econ/events/ti7/phase_boots_ti7.vpcf"
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)

		caster:AddNewModifier(caster, self, "modifier_move_quick_active", {duration = duration})
		EmitSoundOn("teemo_movequick", caster)
	end
end

modifier_move_quick_active = class({})

function modifier_move_quick_active:OnCreated()
	local ability = self:GetAbility()
	self.movespeed = ability:GetSpecialValueFor("movement_speed") * 2
end

function modifier_move_quick_active:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}	
	return decFuncs
end

function modifier_move_quick_active:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

modifier_move_quick_handler = class({})

function modifier_move_quick_handler:IsHidden() return true end

function modifier_move_quick_handler:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.counter = 5
		self:StartIntervalThink(0.1)
		if self.has_been_attacked == nil then
			self.has_been_attacked = false
		end

		if caster:HasModifier("modifier_move_quick_passive") then
			caster:RemoveModifierByName("modifier_move_quick_passive")
		end

		caster:AddNewModifier(caster, ability, "modifier_move_quick_passive", {})
	end
end

function modifier_move_quick_handler:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACKED}
	return decFuncs
end

function modifier_move_quick_handler:OnAttacked(keys)
	if IsServer() then
		if keys.target == self:GetParent() then
			self.counter = 0
		end
	end
end

function modifier_move_quick_handler:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		self.counter = self.counter + 0.1

		if self.counter < 5 then
			if caster:HasModifier("modifier_move_quick_passive") then
				caster:RemoveModifierByName("modifier_move_quick_passive")
			end
		elseif caster:HasModifier("modifier_move_quick_active") then
			if caster:HasModifier("modifier_move_quick_passive") then
				caster:RemoveModifierByName("modifier_move_quick_passive")
			end
		else
			caster:AddNewModifier(caster, ability, "modifier_move_quick_passive", {})
		end
	end
end

modifier_move_quick_passive = class({})

function modifier_move_quick_passive:IsPurgeable() return false end
function modifier_move_quick_passive:IsBuff() return true end

function modifier_move_quick_passive:OnCreated()
	local ability = self:GetAbility()
	self.movespeed = ability:GetSpecialValueFor("movement_speed")
	--print(self.movespeed)
end

function modifier_move_quick_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_move_quick_passive:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

LinkLuaModifier("modifier_toxic_shot_passive", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_toxic_shot_dot", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
toxic_shot = class({})

function toxic_shot:GetAbilityTextureName()
	return "toxic_shot"
end

function toxic_shot:GetIntrinsicModifierName()
	return "modifier_toxic_shot_passive"
end

modifier_toxic_shot_passive = class({})

function modifier_toxic_shot_passive:IsHidden() return true end

function modifier_toxic_shot_passive:OnCreated()
	if IsServer() then
		
	end
end

function modifier_toxic_shot_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return decFuncs
end

function modifier_toxic_shot_passive:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() then
			local ability = self:GetAbility()
			local caster = self:GetCaster()
			local intellect = caster:GetIntellect()

			self.duration = ability:GetSpecialValueFor("duration")
			self.int_scaling = ability:GetSpecialValueFor("int_scaling_onhit")
			self.damageonhit = ability:GetSpecialValueFor("damage_onhit") + intellect * self.int_scaling
			print(self.damageonhit)

			if caster:HasTalent("special_bonus_teemo_2") then
				local onhit = caster:FindAbilityByName("special_bonus_teemo_2"):GetSpecialValueFor("value")
				self.damageonhit = self.damageonhit + onhit
				print(self.damageonhit)
			end

			ApplyDamage({victim = keys.target,
			attacker = self:GetParent(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage = self.damageonhit,
			ability = self:GetAbility()
			})
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_toxic_shot_dot", {duration = self.duration})
		end
	end
end

modifier_toxic_shot_dot = class({})

function modifier_toxic_shot_dot:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local intellect = caster:GetIntellect()

		self.int_scaling_prsec = ability:GetSpecialValueFor("int_scaling_prsec")
		self.damage = ability:GetSpecialValueFor("damage") + intellect * self.int_scaling_prsec
		--print(self.damage)
		--print("int is ", intellect)
		self.tick = ability:GetSpecialValueFor("tick")
		self:StartIntervalThink(self.tick-0.1)
	end
end

function modifier_toxic_shot_dot:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()

		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = self.damage,
		ability = self:GetAbility()
		})
	end
end

LinkLuaModifier("modifier_noxious_trap_invis", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_handler", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_stack_handler", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_explosion", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_explosion_damage", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
noxious_trap = class({})

function noxious_trap:GetAbilityTextureName()
	return "noxious_trap"
end

function noxious_trap:GetIntrinsicModifierName()
	return "modifier_noxious_trap_stack_handler"
end

function noxious_trap:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local pos = caster:GetCursorPosition()
		local modifier_stacks = caster:FindModifierByName("modifier_noxious_trap_stack_handler"):GetStackCount()
		local speed = self:GetSpecialValueFor("movement_slow")
		CustomNetTables:SetTableValue("player_table", "modifier_noxious_trap_explosion_damage", {speed = speed})

		caster:FindModifierByName("modifier_noxious_trap_stack_handler"):SetStackCount(modifier_stacks - 1)
		local unit = CreateUnitByName("npc_shroom", pos, true, caster, caster, caster:GetTeamNumber())
		unit:AddNewModifier(caster, self, "modifier_noxious_trap_handler", {})
		unit:AddNewModifier(caster, self, "modifier_noxious_trap_explosion", {})

		if caster:HasTalent("special_bonus_teemo_4") then
			--print("caster has talent")
			local left_angle = QAngle(0, 55, 0)
			local right_angle = QAngle(0, -55, 0)

			--rotate pos around caster's position
			local left_spawn = RotatePosition(caster:GetAbsOrigin(), left_angle, pos)

			local right_spawn = RotatePosition(caster:GetAbsOrigin(), right_angle, pos)

			--left unit
			local unit2 = CreateUnitByName("npc_shroom", left_spawn, true, caster, caster, caster:GetTeamNumber())
			unit2:AddNewModifier(caster, self, "modifier_noxious_trap_handler", {})
			unit2:AddNewModifier(caster, self, "modifier_noxious_trap_explosion", {})

			--right unit
			local unit3 = CreateUnitByName("npc_shroom", right_spawn, true, caster, caster, caster:GetTeamNumber())
			unit3:AddNewModifier(caster, self, "modifier_noxious_trap_handler", {})
			unit3:AddNewModifier(caster, self, "modifier_noxious_trap_explosion", {})
		end

		EmitSoundOn("teemo_trap_use", caster)
	end
end

function noxious_trap:CastFilterResultLocation()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier_stack_count = caster:FindModifierByName("modifier_noxious_trap_stack_handler"):GetStackCount()
		--print(modifier_stack_count)

		if modifier_stack_count >= 1 then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function noxious_trap:GetCustomCastErrorLocation()
	return "No traps available"
end

modifier_noxious_trap_stack_handler = class({})

function modifier_noxious_trap_stack_handler:IsPurgeable() return false end

function modifier_noxious_trap_stack_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		--Give one trap on first level up
		--so no have to wait 30 secs for first shroom
		local lol = 0

		if lol == 0 then
			local caster = self:GetCaster()
			self:SetStackCount(1)
			lol = 1
		end

		self.count = 0

		self:StartIntervalThink(0.1)
	end
end

function modifier_noxious_trap_stack_handler:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()

		self.max_stacks = ability:GetSpecialValueFor("max_stacks")
		self.charge_time = ability:GetSpecialValueFor("charge_time")

		if self:GetStackCount() == self.max_stacks then
			self.count = 0
		end

		if self.count >= self.charge_time then
			self.count = 0
			if self:GetStackCount() < self.max_stacks then
				self:SetStackCount(self:GetStackCount() + 1)
			end
		end

		self.count = self.count + 0.1
	end
end

modifier_noxious_trap_handler = class({})

function modifier_noxious_trap_handler:OnCreated()
	if IsServer() then
		self.lifetime = self:GetAbility():GetSpecialValueFor("trap_duration")
		self.count = 0
		self.interval = 1
		self:StartIntervalThink(self.interval)
	end
end

function modifier_noxious_trap_handler:OnIntervalThink()
	if IsServer() then
		--print(self.lifetime)
		if self.count >= self.lifetime then
			self:GetParent():AddNoDraw()
			self:GetParent():ForceKill(false)
		end

		if self.count == 1 then
			local parent = self:GetParent()
			parent:AddNewModifier(parent, nil, "modifier_noxious_trap_invis", {})
		end
		self.count = self.count + self.interval
		--print(self.count)
	end
end

modifier_noxious_trap_invis = class({})

function modifier_noxious_trap_invis:IsPurgeable() return false end
function modifier_noxious_trap_invis:IsDebuff() return false end

function modifier_noxious_trap_invis:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
	return decFuncs
end

function modifier_noxious_trap_invis:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end

function modifier_noxious_trap_invis:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end

modifier_noxious_trap_explosion = class({})

function modifier_noxious_trap_explosion:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		self.radius = ability:GetSpecialValueFor("radius")
		self.duration = ability:GetSpecialValueFor("duration")
		self.wait = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_noxious_trap_explosion:OnIntervalThink()
	if IsServer() then
		self.wait = self.wait + 0.1

		local unit = self:GetParent()
		local unit_pos = unit:GetAbsOrigin()
		local caster = self:GetCaster()
		local enemies = FindUnitsInRadius(unit:GetTeamNumber(), 
			unit_pos, 
			nil, 
			self.radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_NONE, 
			FIND_ANY_ORDER, 
			false)

		if #enemies == 0 then
			enemies = nil
		end

		--EXPLOSION HAPPENS HERE
		if enemies ~= nil and self.wait >= 1.2 then
			self:StartIntervalThink(-1)
			for _, unit in pairs(enemies) do
				unit:AddNewModifier(caster, self:GetAbility(), "modifier_noxious_trap_explosion_damage", {duration = self.duration})
			end
			unit:RemoveModifierByName("modifier_noxious_trap_invis")
			local particle = "particles/heroes/teemo/noxious_trap_explosion.vpcf"
			local pfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, unit)
			ParticleManager:SetParticleControl(pfx, 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, Vector(0.65,0.65,0.65))

			EmitSoundOn("teemo_trap_explosion", self:GetParent())
			unit:AddNoDraw()
			unit:ForceKill(false)
		end
	end
end

modifier_noxious_trap_explosion_damage = class({})

function modifier_noxious_trap_explosion_damage:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self.speed = CustomNetTables:GetTableValue("player_table", "modifier_noxious_trap_explosion_damage").speed
		--print(self.speed)
		local intellect = caster:GetIntellect()

		self.int_scaling = ability:GetSpecialValueFor("int_scaling")
		self.damage = ability:GetSpecialValueFor("damage") + intellect * self.int_scaling
		self.tick = ability:GetSpecialValueFor("tick")

		self:StartIntervalThink(self.tick-0.1)
	end
end

function modifier_noxious_trap_explosion_damage:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()

		ApplyDamage({victim = parent,
		attacker = caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = self.damage,
		ability = self:GetAbility()})
	end
end

function modifier_noxious_trap_explosion_damage:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_noxious_trap_explosion_damage:GetModifierMoveSpeedBonus_Percentage()
	return self.speed
end

LinkLuaModifier("modifier_guerrilla_warfare_passive", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guerrilla_warfare_invis", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guerrilla_warfare_attackspeed", "heroes/hero_teemo/hero_teemo", LUA_MODIFIER_MOTION_NONE)
guerrilla_warfare = class({})

function guerrilla_warfare:GetAbilityTextureName()
	return "guerrilla_warfare"
end

function guerrilla_warfare:GetIntrinsicModifierName()
	return "modifier_guerrilla_warfare_passive"
end

modifier_guerrilla_warfare_passive = class({})

function modifier_guerrilla_warfare_passive:IsPurgeable() return false end
function modifier_guerrilla_warfare_passive:IsHidden() return true end

function modifier_guerrilla_warfare_passive:OnCreated()
	if IsServer() then
		self.wait = self:GetAbility():GetSpecialValueFor("wait")
		self.count = 0
		self.caster_pos = self:GetParent():GetAbsOrigin()
		self:StartIntervalThink(0.1)
	end
end

function modifier_guerrilla_warfare_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START}
	return decFuncs
end

function modifier_guerrilla_warfare_passive:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
			--print("attack")
			self.count = 0
		end
	end
end

function modifier_guerrilla_warfare_passive:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			--print("spell")
			self.count = 0
		end
	end
end

function modifier_guerrilla_warfare_passive:OnIntervalThink()
	if IsServer() then
		local new_pos = self:GetParent():GetAbsOrigin()

		if new_pos ~= self.caster_pos then
			if self:GetParent():HasModifier("modifier_guerrilla_warfare_invis") then
				self:GetParent():RemoveModifierByName("modifier_guerrilla_warfare_invis")
			end
			self.count = 0
		end

		if self.count >= self.wait then
			local caster = self:GetParent()
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_guerrilla_warfare_invis", {})
			self.count = 0
		end

		self.caster_pos = self:GetParent():GetAbsOrigin()
		self.count = self.count + 0.1
	end
end

modifier_guerrilla_warfare_invis = class({})

function modifier_guerrilla_warfare_invis:IsPurgeable() return false end
function modifier_guerrilla_warfare_invis:IsDebuff() return false end

function modifier_guerrilla_warfare_invis:DeclareFunctions()
	local decFuncs = {
	MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
	MODIFIER_EVENT_ON_ATTACK,
	MODIFIER_EVENT_ON_ABILITY_EXECUTED}
	return decFuncs
end

function modifier_guerrilla_warfare_invis:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			self:Destroy()
		end
	end
end

function modifier_guerrilla_warfare_invis:OnAttack(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
			self:Destroy()
		end
	end
end

function modifier_guerrilla_warfare_invis:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_guerrilla_warfare_attackspeed", {duration = duration})
	end
end

function modifier_guerrilla_warfare_invis:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end

function modifier_guerrilla_warfare_invis:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end

modifier_guerrilla_warfare_attackspeed = class({})

function modifier_guerrilla_warfare_attackspeed:IsPurgeable() return false end
function modifier_guerrilla_warfare_attackspeed:IsBuff() return true end

function modifier_guerrilla_warfare_attackspeed:OnCreated()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if caster:GetLevel() < 6 then
		self.attackspeed = ability:GetSpecialValueFor("attackspeed")
	elseif caster:GetLevel() >= 6 and caster:GetLevel() < 12 then
		self.attackspeed = ability:GetSpecialValueFor("attackspeed6")
	elseif caster:GetLevel() >= 12 and caster:GetLevel() < 18 then
		self.attackspeed = ability:GetSpecialValueFor("attackspeed12")
	elseif caster:GetLevel() >= 18 then
		self.attackspeed = ability:GetSpecialValueFor("attackspeed18")
	end

	--print("hero level is ", caster:GetLevel(), " so returned attackspeed is ", self.attackspeed)
end

function modifier_guerrilla_warfare_attackspeed:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
	return decFuncs
end

function modifier_guerrilla_warfare_attackspeed:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

--------------- TODO ----------------
-- ADD CUSTOM SOUNDSET 
