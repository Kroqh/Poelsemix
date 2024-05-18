LinkLuaModifier("modifier_gametecher_thirst_passive", "heroes/hero_gametecher/gametecher_thirst", LUA_MODIFIER_MOTION_NONE)

gametecher_thirst = gametecher_thirst or class({})

function gametecher_thirst:GetIntrinsicModifierName()
	return "modifier_gametecher_thirst_passive"
end
function gametecher_thirst:GetCastRange()
    return self:GetSpecialValueFor("radius")
end

modifier_gametecher_thirst_passive = modifier_gametecher_thirst_passive or class({})

function modifier_gametecher_thirst_passive:IsHidden()
	return false
end

function modifier_gametecher_thirst_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_gametecher_thirst_passive:OnIntervalThink()
	if IsServer() then
		if self:GetParent():PassivesDisabled() then
			self:SetStackCount(0)
		end
		
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		local hpDeficit = 0
		for _,enemy in pairs(enemies) do
			if enemy and not enemy:IsNull() and (enemy:IsRealHero() or enemy:IsClone()) and enemy:IsAlive() then
				local hpDiff = 1 - (enemy:GetHealth()/enemy:GetMaxHealth())
                if hpDiff > hpDeficit then hpDeficit = hpDiff end
			end
		end
		if #enemies >= 1 and hpDeficit > 0 then
            self:SetStackCount(hpDeficit*100)
        else
            self:SetStackCount(0)
        end
	end
end

function modifier_gametecher_thirst_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_gametecher_thirst_passive:GetModifierAttackSpeedPercentage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("as_pct_per_missing_hp")
end

function modifier_gametecher_thirst_passive:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms_pct_per_missing_hp")
end

function modifier_gametecher_thirst_passive:GetEffectName()
	return "particles/units/heroes/hero_gametecher/thirst.vpcf"
end