function AddIntellect(keys)
	local caster = keys.caster	
	local ability = keys.ability
	
	if not ability.currentStacks then
		ability.currentStacks = 0
	end
	
	ability.currentStacks = ability.currentStacks+1

	caster:ModifyAgility(ability:GetSpecialValueFor("bonus_agi"))
	caster:CalculateStatBonus()

	caster:SetModifierStackCount("modifier_rygeagi", ability, ability.currentStacks)
end 

function stacksSpawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if not ability.currentStacks then
		ability.currentStacks = 0
	end
	
	ability.currentStacks = ability.currentStacks
	
	caster:SetModifierStackCount("modifier_rygeagi", ability, ability.currentStacks)
end
--lol