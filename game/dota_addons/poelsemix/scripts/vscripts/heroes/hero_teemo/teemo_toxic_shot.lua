LinkLuaModifier("modifier_toxic_shot_passive", "heroes/hero_teemo/teemo_toxic_shot", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_toxic_shot_dot", "heroes/hero_teemo/teemo_toxic_shot", LUA_MODIFIER_MOTION_NONE)
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
			local intellect = caster:GetIntellect(true)

			local duration = ability:GetSpecialValueFor("duration")
			local int_scaling = ability:GetSpecialValueFor("int_scaling_onhit")
            if caster:HasTalent("special_bonus_teemo_5") then int_scaling = int_scaling + caster:FindAbilityByName("special_bonus_teemo_5"):GetSpecialValueFor("value") end

			local damageonhit = ability:GetSpecialValueFor("damage_onhit") + intellect * int_scaling

			if caster:HasTalent("special_bonus_teemo_2") then
				local onhit = caster:FindAbilityByName("special_bonus_teemo_2"):GetSpecialValueFor("value")
				damageonhit = damageonhit + onhit
			end

			ApplyDamage({victim = keys.target,
			attacker = self:GetParent(),
			damage_type = ability:GetAbilityDamageType(),
			damage = damageonhit,
			ability = ability
			})
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_toxic_shot_dot", {duration = duration})
		end
	end
end

modifier_toxic_shot_dot = modifier_toxic_shot_dot or class({})

function modifier_toxic_shot_dot:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local intellect = caster:GetIntellect(true)

		local int_scaling_prsec = ability:GetSpecialValueFor("int_scaling_prsec")
        if caster:HasTalent("special_bonus_teemo_6") then int_scaling_prsec = int_scaling_prsec + caster:FindAbilityByName("special_bonus_teemo_6"):GetSpecialValueFor("value") end
		self.damage = ability:GetSpecialValueFor("damage_tick") + intellect * int_scaling_prsec

		self.tick = ability:GetSpecialValueFor("tick_rate")
		self:StartIntervalThink(self.tick-0.1)
	end
end

function modifier_toxic_shot_dot:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()

		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage = self.damage,
		ability = self:GetAbility()
		})
		self:StartIntervalThink(self.tick)
	end
end