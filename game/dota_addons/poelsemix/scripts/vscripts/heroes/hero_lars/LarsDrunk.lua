function LarsDrunkStart( keys )
	local caster = keys.caster
	local target = keys.target

		if target:IsAlive() then
			local order = 
			{
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = caster:entindex()
			}
	
			ExecuteOrderFromTable(order)
		else
			caster:Stop()
		end
	
		-- Set the force attack target to be the caster (unit loooool)
		caster:SetForceAttackTargetAlly(target)
	-------------------------------------------
end


function LarsDrunkEnd( keys )
	local caster = keys.caster
	local target = keys.target


		-- Set the force attack target to be the caster
		caster:SetForceAttackTargetAlly(nil)
		-------------------------------------------
end
