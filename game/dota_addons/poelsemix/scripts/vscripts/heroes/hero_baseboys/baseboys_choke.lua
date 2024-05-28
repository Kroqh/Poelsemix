LinkLuaModifier("modifier_choke", "heroes/hero_baseboys/baseboys_choke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_choke_stun", "heroes/hero_baseboys/baseboys_choke", LUA_MODIFIER_MOTION_NONE)
baseboys_choke = baseboys_choke or class({})

function baseboys_choke:GetAbilityTextureName()
	return "hej_mathilde"
end

function baseboys_choke:GetIntrinsicModifierName()
	return "modifier_choke"
end

modifier_choke = modifier_choke or class({})

function modifier_choke:IsHidden() return true end

function modifier_choke:DeclareFunctions()
	local decFuncs = 
	{MODIFIER_EVENT_ON_ATTACKED}
	return decFuncs
end

function modifier_choke:OnAttacked(keys)
	if IsServer() then

		if keys.target == self:GetParent() then

			local ability = self:GetAbility()
			local chance = ability:GetSpecialValueFor("chance")
			if self:GetCaster():FindAbilityByName("special_bonus_baseboys_3"):GetLevel() > 0 then chance = chance + self:GetCaster():FindAbilityByName("special_bonus_baseboys_3"):GetSpecialValueFor("value") end 
			local caster = self:GetParent()

			if caster:PassivesDisabled() or caster:IsHexed() then
				return nil
			end

			if RollPseudoRandom(chance, self) then
				local duration = ability:GetSpecialValueFor("duration")
				if self:GetCaster():FindAbilityByName("special_bonus_baseboys_1"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_baseboys_1"):GetSpecialValueFor("value") end
				keys.attacker:AddNewModifier(caster, ability, "modifier_choke_stun", {duration = duration})
				caster:EmitSound("hej_mathilde")
			end
		end
	end
end


modifier_choke_stun = class({})

function modifier_choke_stun:IsPurgable() return false end
function modifier_choke_stun:IsHidden() return false end

function modifier_choke_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"

end

function modifier_choke_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_choke_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end