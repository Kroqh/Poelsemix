function LarsDrunkStart( keys )
	print("loool")
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	caster:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	if target:IsAlive() then
		local order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		caster:Stop()
	end

	-- Set the force attack target to be the caster
	caster:SetForceAttackTarget(target)
end


function LarsDrunkEnd( keys )
	local caster = keys.caster
	local target = keys.target


		-- Set the force attack target to be the caster
		caster:SetForceAttackTargetAlly(nil)
		-------------------------------------------
end
