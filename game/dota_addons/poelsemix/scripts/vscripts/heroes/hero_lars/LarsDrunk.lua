function LarsDrunkStart( keys )
	local caster = keys.caster
	local target = keys.target

	AllUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	Vector(0, 0, 0),
	nil,
	FIND_UNITS_EVERYWHERE,
	DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	DOTA_UNIT_TARGET_ALL,
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_ANY_ORDER,
	false)

	for _,unit in pairs(AllUnits) do

		if target:IsAlive() then
			local order = 
			{
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			}
	
			ExecuteOrderFromTable(order)
		else
			unit:Stop()
		end
	
		-- Set the force attack target to be the caster
		unit:SetForceAttackTargetAlly(target)
	-------------------------------------------
	end
end


function LarsDrunkEnd( keys )
	local caster = keys.caster
	local target = keys.target

	for _,unit in pairs(AllUnits) do

		-- Set the force attack target to be the caster
		unit:SetForceAttackTargetAlly(nil)
		-------------------------------------------
		end
end
