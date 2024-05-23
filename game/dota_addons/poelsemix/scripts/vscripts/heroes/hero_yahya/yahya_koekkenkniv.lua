LinkLuaModifier("modifier_yahya_koekkenkniv", "heroes/hero_yahya/yahya_koekkenkniv", LUA_MODIFIER_MOTION_NONE)


yahya_koekkenkniv = yahya_koekkenkniv or class({})

function yahya_koekkenkniv:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_yahya_koekkenkniv", nil )
	else
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_yahya_koekkenkniv" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

modifier_yahya_koekkenkniv = modifier_yahya_koekkenkniv or class({})
function modifier_yahya_koekkenkniv:IsDebuff() return false end
function modifier_yahya_koekkenkniv:IsHidden() return true end
function modifier_yahya_koekkenkniv:IsPurgable() return false end
function modifier_yahya_koekkenkniv:IsPurgeException() return false end
-------------------------------------------

function modifier_yahya_koekkenkniv:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
end

function modifier_yahya_koekkenkniv:OnAttackLanded( params )
	if IsServer() then
		local caster = self:GetCaster()
		if params.attacker == caster and not caster:PassivesDisabled() then
		
		local ability = self:GetAbility()
		if not caster:HasTalent("special_bonus_yahya_7") then
			local mana_after = caster:GetMana() - ability:GetSpecialValueFor("manacost")
			if mana_after == 0 then
			caster:SetMana(0)
			ability:ToggleAbility()
			elseif mana_after < 0 then
			ability:ToggleAbility()
			return
			else
			caster:SetMana(mana_after)
			end
		end

		local max_hp_dmg = self:GetAbility():GetSpecialValueFor("bonus_max_hp_damage_perc")
		if self:GetCaster():FindAbilityByName("special_bonus_yahya_2"):GetLevel() > 0 then max_hp_dmg = max_hp_dmg + self:GetCaster():FindAbilityByName("special_bonus_yahya_2"):GetSpecialValueFor("value") end

		local dmg = params.target:GetMaxHealth() * (max_hp_dmg/100)
		ApplyDamage({victim = params.target,
    	attacker = params.attacker,
    	damage_type = self:GetAbility():GetAbilityDamageType(),
    	damage =  dmg,
    	ability = self:GetAbility()})
		end
	end
end
function  modifier_yahya_koekkenkniv:GetModifierBaseAttack_BonusDamage()
	local value = self:GetAbility():GetSpecialValueFor("bonus_damage")
	
    return value
end

function modifier_yahya_koekkenkniv:GetAttackSound()
	return "koekkenkniv"
end
