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
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
end

function modifier_yahya_koekkenkniv:OnAttackLanded( params )
	if IsServer() then
		local caster = self:GetCaster()
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
        EmitSoundOn("koekkenkniv", caster)

		if params.attacker == caster and caster:IsRealHero() and (params.target:GetTeamNumber() ~= caster:GetTeamNumber()) and not caster:PassivesDisabled() then
			local cleave_particle = "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
			local cleave_damage_pct = ability:GetSpecialValueFor("cleave_damage_percent") / 100
			local cleave_radius_start = ability:GetSpecialValueFor("cleave_starting_width")
			local cleave_radius_end = ability:GetSpecialValueFor("cleave_ending_width")
			local cleave_distance = ability:GetSpecialValueFor("cleave_distance")

			if caster:HasTalent("special_bonus_yahya_2") then
				local bonus = caster:FindAbilityByName("special_bonus_yahya_2"):GetSpecialValueFor("value") 
				cleave_radius_end= cleave_radius_end + bonus
				cleave_distance  = cleave_distance + bonus
			end
			

			DoCleaveAttack( params.attacker, params.target, ability, (params.damage * cleave_damage_pct), cleave_radius_start, cleave_radius_end, cleave_distance, cleave_particle )
		end
	end
end
function  modifier_yahya_koekkenkniv:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
