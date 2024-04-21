LinkLuaModifier("modifier_choke", "heroes/hero_baseboys/baseboys_choke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_choke_stun", "heroes/hero_baseboys/baseboy_choke", LUA_MODIFIER_MOTION_NONE)
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
	{MODIFIER_EVENT_ON_ATTACKED, MODIFIER_EVENT_ON_ABILITY_EXECUTED}
	return decFuncs
end

function modifier_choke:OnAttacked(keys)
	if IsServer() then

		if keys.target == self:GetParent() then

			local ability = self:GetAbility()
			local chance = ability:GetSpecialValueFor("chance") 
			local duration = ability:GetSpecialValueFor("duration")
			local caster = self:GetParent()

			if caster:PassivesDisabled() or caster:IsHexed() then
				return nil
			end

			if RollPseudoRandom(chance, self) then

				keys.attacker:AddNewModifier(caster, ability, "modifier_choke_stun", {duration = duration})
				ability:EmitSound("hej_mathilde")
			end
		end
	end
end

function modifier_choke:OnAbilityExecuted(keys) --move to the actual ability lol?
	if IsServer() then
		local parent = self:GetParent()
		if keys.unit == parent and keys.ability:GetAbilityName() == "naga_siren_mirror_image" then
			
			if parent:HasItemInInventory("item_norwegian_eul") then
				parent:EmitSound("baseboys_1000_norsk")
			else
				parent:EmitSound("baseboys_1000_dansk")
			end
		end
	end
end

modifier_choke_stun = class({})

function modifier_choke_stun:IsPurgeable() return false end
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