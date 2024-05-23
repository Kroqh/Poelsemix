LinkLuaModifier("modifier_guerrilla_warfare_passive", "heroes/hero_teemo/teemo_guerrilla_warfare", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guerrilla_warfare_invis", "heroes/hero_teemo/teemo_guerrilla_warfare", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guerrilla_warfare_attackspeed", "heroes/hero_teemo/teemo_guerrilla_warfare", LUA_MODIFIER_MOTION_NONE)
guerrilla_warfare = guerrilla_warfare or class({})


function guerrilla_warfare:GetIntrinsicModifierName()
	return "modifier_guerrilla_warfare_passive"
end

modifier_guerrilla_warfare_passive = modifier_guerrilla_warfare_passive or class({})

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
	local decFuncs = {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end

function modifier_guerrilla_warfare_passive:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
			self.count = 0
		end
	end
end

function modifier_guerrilla_warfare_passive:OnTakeDamage(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
			self.count = 0
		end
	end
end

function modifier_guerrilla_warfare_passive:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.unit == parent then
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

modifier_guerrilla_warfare_invis = modifier_guerrilla_warfare_invis or class({})

function modifier_guerrilla_warfare_invis:IsPurgeable() return false end
function modifier_guerrilla_warfare_invis:IsDebuff() return false end

function modifier_guerrilla_warfare_invis:DeclareFunctions()
	local decFuncs = {
	MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
	MODIFIER_EVENT_ON_ATTACK_START,
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

function modifier_guerrilla_warfare_invis:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then

			if parent:HasScepter() then
				local ability = parent:FindAbilityByName("blinding_dart")
				if ability:GetLevel() == 0 then return end
				
				local cdleft = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				local manaRestore = ability:GetManaCost(ability:GetLevel())
				if parent:GetMana() < manaRestore then --Incase the hero doesnt have enough mana
					parent:GiveMana(manaRestore)
					manaRestore = 0 -- make sure it doesnt double restore
				end
	
				parent:CastAbilityOnTarget(keys.target, ability, 0)
				if cdleft == 0 then
					ability:EndCooldown()
				else
					ability:EndCooldown() --needs to be ended before it can be restarted lmao
					ability:StartCooldown(cdleft)
				end
				
				parent:GiveMana(manaRestore) -- restore mana after
				end
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
    if not IsServer() then return end
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

    if caster:HasTalent("special_bonus_teemo_7") then self.attackspeed = self.attackspeed + caster:FindAbilityByName("special_bonus_teemo_7"):GetSpecialValueFor("value") end

end

function modifier_guerrilla_warfare_attackspeed:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
	return decFuncs
end

function modifier_guerrilla_warfare_attackspeed:GetModifierAttackSpeedBonus_Constant()
    if not IsServer() then return end
	return self.attackspeed
end
