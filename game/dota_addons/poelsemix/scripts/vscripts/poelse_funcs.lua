function FindDistance(unit1, unit2)
	local pos1 = unit1
	local pos2 = unit2

	local distanceDifference = (pos1 - pos2):Length2D()
	return distanceDifference
end

function CDOTA_BaseNPC:HasTalent(talent)
    if self:FindAbilityByName(talent):GetLevel() > 0 then
        return true
    end

    return false
end


-- Thanks dota imba
-- Returns a unit's existing increased cast range modifiers
function GetCastRangeIncrease( unit )
    local cast_range_increase = 0
    -- Only the greatefd st increase counts for items, they do not stack
    for _, parent_modifier in pairs(unit:FindAllModifiers()) do        
        if parent_modifier.GetModifierCastRangeBonus then
            cast_range_increase = math.max(cast_range_increase,parent_modifier:GetModifierCastRangeBonus())
        end        
    end    

    for _, parent_modifier in pairs(unit:FindAllModifiers()) do        
        if parent_modifier.GetModifierCastRangeBonusStacking then
            cast_range_increase = cast_range_increase + parent_modifier:GetModifierCastRangeBonusStacking()
        end
    end        

    return cast_range_increase
end

function CDOTA_Modifier_Lua:CheckMotionControllers()
    local parent = self:GetParent()
    local modifier_priority = self:GetMotionControllerPriority()
    local is_motion_controller = false
    local motion_controller_priority
    local found_modifier_handler

    local non_imba_motion_controllers =
    {"modifier_brewmaster_storm_cyclone",
     "modifier_dark_seer_vacuum",
     "modifier_eul_cyclone",
     "modifier_earth_spirit_rolling_boulder_caster",
     "modifier_huskar_life_break_charge",
     "modifier_invoker_tornado",
     "modifier_item_forcestaff_active",
     "modifier_rattletrap_hookshot",
     "modifier_phoenix_icarus_dive",
     "modifier_shredder_timber_chain",
     "modifier_slark_pounce",
     "modifier_spirit_breaker_charge_of_darkness",
     "modifier_tusk_walrus_punch_air_time",
     "modifier_earthshaker_enchant_totem_leap"}
    

    -- Fetch all modifiers
    local modifiers = parent:FindAllModifiers() 

    for _,modifier in pairs(modifiers) do       
        -- Ignore the modifier that is using this function
        if self ~= modifier then            

            -- Check if this modifier is assigned as a motion controller
            if modifier.IsMotionController then
                if modifier:IsMotionController() then
                    -- Get its handle
                    found_modifier_handler = modifier

                    is_motion_controller = true

                    -- Get the motion controller priority
                    motion_controller_priority = modifier:GetMotionControllerPriority()

                    -- Stop iteration                   
                    break
                end
            end

            -- If not, check on the list
            for _,non_imba_motion_controller in pairs(non_imba_motion_controllers) do               
                if modifier:GetName() == non_imba_motion_controller then
                    -- Get its handle
                    found_modifier_handler = modifier

                    is_motion_controller = true

                    -- We assume that vanilla controllers are the highest priority
                    motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST

                    -- Stop iteration                   
                    break
                end
            end
        end
    end

    -- If this is a motion controller, check its priority level
    if is_motion_controller and motion_controller_priority then

        -- If the priority of the modifier that was found is higher, override
        if motion_controller_priority > modifier_priority then          
            return false

        -- If they have the same priority levels, check which of them is older and remove it
        elseif motion_controller_priority == modifier_priority then         
            if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then              
                return false
            else                
                found_modifier_handler:Destroy()
                return true
            end

        -- If the modifier that was found is a lower priority, destroy it instead
        else            
            parent:InterruptMotionControllers(true)
            found_modifier_handler:Destroy()
            return true
        end
    else
        -- If no motion controllers were found, apply
        return true
    end
end