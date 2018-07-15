function HunterInTheNight( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier

	if not GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	else
		if caster:HasModifier(modifier) then caster:RemoveModifierByName(modifier) end
	end
end