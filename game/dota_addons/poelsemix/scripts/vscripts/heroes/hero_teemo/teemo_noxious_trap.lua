

LinkLuaModifier("modifier_noxious_trap_invis", "heroes/hero_teemo/teemo_noxious_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_handler", "heroes/hero_teemo/teemo_noxious_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_stack_handler", "heroes/hero_teemo/teemo_noxious_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_explosion", "heroes/hero_teemo/teemo_noxious_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_noxious_trap_explosion_damage", "heroes/hero_teemo/teemo_noxious_trap", LUA_MODIFIER_MOTION_NONE)
noxious_trap = noxious_trap or class({})

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

			--right unit
			local unit3 = CreateUnitByName("npc_shroom", right_spawn, true, caster, caster, caster:GetTeamNumber())
			unit3:AddNewModifier(caster, self, "modifier_noxious_trap_handler", {})
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

modifier_noxious_trap_stack_handler = modifier_noxious_trap_stack_handler or class({})

function modifier_noxious_trap_stack_handler:IsDebuff() 	return false end
function modifier_noxious_trap_stack_handler:IsHidden() 	return false end
function modifier_noxious_trap_stack_handler:IsPassive() 	return true end
function modifier_noxious_trap_stack_handler:IsPurgeable() return false end

function modifier_noxious_trap_stack_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		--Give one trap on first level up
		--so no have to wait 30 secs for first shroom
		--Krogh comment: Tror ikke det virker sådan her men ok, not broke
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

		local max_stacks = ability:GetSpecialValueFor("max_stacks")
        if self:GetParent():HasTalent("special_bonus_teemo_1") then max_stacks = max_stacks + self:GetParent():FindAbilityByName("special_bonus_teemo_1"):GetSpecialValueFor("value") end
		self.charge_time = ability:GetSpecialValueFor("charge_time")

		if self:GetStackCount() == max_stacks then
			self.count = 0
		end

		if self.count >= self.charge_time then
			self.count = 0
			if self:GetStackCount() < max_stacks then
				self:SetStackCount(self:GetStackCount() + 1)
			end
		end

		self.count = self.count + 0.1
	end
end

modifier_noxious_trap_handler = class({})

function modifier_noxious_trap_handler:IsHidden() return true end

function modifier_noxious_trap_handler:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_kill", { duration = ability:GetSpecialValueFor("trap_duration") } )
		self:StartIntervalThink(ability:GetSpecialValueFor("delay"))
	end
end

function modifier_noxious_trap_handler:OnIntervalThink()
	if IsServer() then
			local parent = self:GetParent()
			local ability = self:GetAbility()
			parent:AddNewModifier(parent, ability, "modifier_noxious_trap_invis", {})
			parent:AddNewModifier(parent, ability, "modifier_noxious_trap_explosion", {})
			parent:RemoveModifierByName("modifier_noxious_trap_handler")
	end
end

modifier_noxious_trap_invis = class({})

function modifier_noxious_trap_invis:IsHidden() return true end

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
		self:StartIntervalThink(0.1)
	end
end

function modifier_noxious_trap_explosion:IsHidden() return false end

function modifier_noxious_trap_explosion:OnIntervalThink()
	if IsServer() then

		local unit = self:GetParent()
		local unit_pos = unit:GetAbsOrigin()
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
		local enemies = FindUnitsInRadius(unit:GetTeamNumber(), 
			unit_pos, 
			nil, 
			self.radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, 
			false)

		if #enemies == 0 then
			enemies = nil
		end

		--EXPLOSION HAPPENS HERE
		if enemies ~= nil then --hardcoded explosion delay for some reason
			self:StartIntervalThink(-1)
			for _, enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_noxious_trap_explosion_damage", {duration = self.duration})
			end
			--unit:RemoveModifierByName("modifier_noxious_trap_invis")
			local particle = "particles/heroes/teemo/noxious_trap_explosion.vpcf"
			local pfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, unit)
			ParticleManager:SetParticleControl(pfx, 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, Vector(0.65,0.65,0.65))

			EmitSoundOn("teemo_trap_explosion", unit)
			unit:AddNoDraw()
			unit:ForceKill(false)
		end
	end
end

modifier_noxious_trap_explosion_damage = class({})

function modifier_noxious_trap_explosion_damage:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = ability:GetCaster()
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
		damage_type = self:GetAbility():GetAbilityDamageType(),
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