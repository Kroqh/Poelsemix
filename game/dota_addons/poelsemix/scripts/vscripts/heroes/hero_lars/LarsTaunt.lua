--[[Author: Pizzalol
	Date: 09.02.2015.
	Forces the target to attack the caster]]
    function BerserkersCall( keys )
        local caster = keys.caster
        local target = keys.target
    
        AllUnits = FindUnitsInRadius(target:GetTeamNumber(),
        Vector(0, 0, 0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

for _,unit in pairs(AllUnits) do
    if unit ~= caster then
--------------------------------------------
--Taget fra Axe
-------------------------------------------
	-- Clear the force attack target
	--unit:SetForceAttackTargetAlly(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
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
        
    end
    
    -- Clears the force attack target upon expiration
    function BerserkersCallEnd( keys )
        local target = keys.target
        local caster = keys.caster

        for _,unit in pairs(AllUnits) do
            unit:SetForceAttackTarget(nil)
            end
    end
