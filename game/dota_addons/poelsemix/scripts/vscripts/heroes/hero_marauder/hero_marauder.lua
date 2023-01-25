--------------------------------------------------------------------------------
-- Move Only
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_move_only", "heroes/hero_marauder/hero_marauder", LUA_MODIFIER_MOTION_NONE)
move_only = move_only or class({})

function move_only:GetIntrinsicModifierName()
    return "modifier_move_only"
end

modifier_move_only = modifier_move_only or class({})

function modifier_move_only:IsHidden() return true end
function modifier_move_only:IsPurgeable() return false end

function modifier_move_only:CheckState()
	local state = {
	    [MODIFIER_STATE_DISARMED] = true
	}
	return state
end


