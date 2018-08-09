modifier_remove_speed_cap = class({})

function modifier_remove_speed_cap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}

	return funcs
end

function modifier_remove_speed_cap:GetModifierMoveSpeed_Max()
	return 1200
end

function modifier_remove_speed_cap:GetModifierMoveSpeed_Limit()
	return 1200
end

function modifier_remove_speed_cap:IsHidden()
	return true
end