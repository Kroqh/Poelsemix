LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua", LUA_MODIFIER_MOTION_NONE )

function SpeedCap(keys)
		local caster = keys.caster
		if caster:HasModifier("modifier_movement_cap") == false then
				caster:AddNewModifier(caster, nil, "modifier_movement_cap", {})
		end
end

