--thanks birzha memov

function GiveGoldBig(keys)
	local target = keys.target
	local caster = keys.caster
	
	local target_location = target:GetAbsOrigin()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, 3400, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false)
	for i,unit in ipairs(units) do
		if unit:IsRealHero() then 
			unit:ModifyGold(6, true, 0)
		end
	end
end

function GiveGoldSmall(keys)
	local target = keys.target
	local caster = keys.caster
	local target_location = target:GetAbsOrigin()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, 1000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false)
	for i,unit in ipairs(units) do
		if unit:IsRealHero() then
			unit:ModifyGold(12, true, 0)
		end
	end
end

function GiveGoldSmall2(keys)
	local target = keys.target
	local caster = keys.caster
	local target_location = target:GetAbsOrigin()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, 1400, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false)
	for i,unit in ipairs(units) do
		if unit:IsRealHero() then
			unit:ModifyGold(6, true, 0)
		end
	end
end