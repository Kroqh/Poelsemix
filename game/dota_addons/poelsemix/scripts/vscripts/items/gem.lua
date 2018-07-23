function SpendChargeRight(keys)
	keys.ability:SpendCharge()
end

function IllusionModifierCleaner(keys)
	local caster = keys.caster
	Timers:CreateTimer(0.03, function()
		if keys.modifier and IsValidEntity(caster) and (caster:IsIllusion() or (caster.IsWukongsSummon and caster:IsWukongsSummon())) then
			caster:RemoveModifierByName(keys.modifier)
		end
	end)
end