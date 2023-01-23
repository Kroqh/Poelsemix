courier_superspeed = class({})

function courier_superspeed:GetIntrinsicModifierName()
    return "modifier_courier_superspeed"
end

LinkLuaModifier("modifier_courier_superspeed", "abilities/courier", LUA_MODIFIER_MOTION_NONE)

modifier_courier_superspeed = modifier_courier_superspeed or class({})

function modifier_courier_superspeed:IsPurgable() return false end
function modifier_courier_superspeed:IsHidden() return true end
function modifier_courier_superspeed:RemoveOnDeath() return false end

function modifier_courier_superspeed:OnCreated()
    
end

function modifier_courier_superspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
	}

	return funcs
end

function modifier_courier_superspeed:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("movespeed")	
end

function modifier_courier_superspeed:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("movespeed")	
end

function modifier_courier_superspeed:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_FLYING] = true
    }
    return state
end








