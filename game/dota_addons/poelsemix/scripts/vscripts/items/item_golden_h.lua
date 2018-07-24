function use(keys)	
	

		keys.caster:EmitSound("goldenhorns")

		local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.EnduranceRadius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			
		for i, nearby_ally in ipairs(nearby_allied_units) do  --Apply the buff modifier to every found ally.
			keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_golden_horns_active", nil)
		end
		for i, nearby_ally in ipairs(nearby_allied_units) do  --Apply the buff modifier to every found ally.
			keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_gh_spellshield", nil)
		end
    
		
	
end
function flame_guard_init( keys )
	-- Inherited variables
	local targetUnit = keys.target
	local ability = keys.ability
	targetUnit.flame_guard_absorb_amount = ability:GetLevelSpecialValueFor( "absorb_amount", ability:GetLevel() - 1 )
	
	-- Table for look up
	targetUnit.take_next = {}
	
	-- Check if listener is already running
	if targetUnit.listener ~= nil then
		targetUnit.listener = true
		return
	end
	
	--[[
		Anything below this point should be called only ONCE per game session
		unless someone know how to properly stop listener
	]]
	
	-- Set flags
	targetUnit.listener = true
	
	-- Targeting variables
	local targetEntIndex = targetUnit:entindex()
	local abilityBlockType = DAMAGE_TYPE_MAGICAL
	
	-- Listening to entity hurt
	ListenToGameEvent( "entity_hurt", function( event )
			-- check if should keep listening
			if targetUnit.listener == true then
				local inflictor = event.entindex_inflictor
				local attacker = event.entindex_attacker
				local compareTarget = event.entindex_killed
				-- Check if it's correct unit
				if compareTarget == targetEntIndex and inflictor ~= nil then
					local ability = EntIndexToHScript( inflictor )
					-- Check whether it is the correct type to block
					if ability:GetAbilityDamageType() == abilityBlockType then
						targetUnit.take_next[ attacker ] = false	-- use attacker entindex as ref point
					end
				end
			end
		end, nil
	)
end

--[[
	Author: kritth
	Date: 13.01.2015.
	Decide whether this damage will be taken or not
]]
function flame_guard_on_take_damage( keys )
	-- Inherited variables
	local targetUnit = keys.unit
	local attackerEnt = keys.attacker:entindex()
	local damageTaken = keys.Damage
	local modifierName = keys.modifier
	
	-- Forcefully dispell the modifier
	if targetUnit.flame_guard_absorb_amount < 0 then
		targetUnit:RemoveModifierByName( modifierName )
		keys.attacker.take_next = nil
		targetUnit.listener = false
		return
	end
	
	-- Check if flag has been turned from listener
	if targetUnit.take_next[ attackerEnt ] ~= nil and targetUnit.take_next[ attackerEnt ] == false then
		-- Absorb damage
		targetUnit.flame_guard_absorb_amount = targetUnit.flame_guard_absorb_amount - damageTaken
		targetUnit:SetHealth( targetUnit:GetHealth() + damageTaken )	-- restore health
		targetUnit.take_next[ attackerEnt ] = true
		
		-- If the shield absorbs over damage then remove buff
		if targetUnit.flame_guard_absorb_amount < 0 then
			targetUnit:SetHealth( targetUnit:GetHealth() + targetUnit.flame_guard_absorb_amount )
			targetUnit:RemoveModifierByName( modifierName )
			keys.attacker.take_next = nil
			targetUnit.listener = false
			return
		end
	end
end
function flame_guard_stop_listening( keys )
	keys.target.take_next = nil
	keys.target.listener = false
end