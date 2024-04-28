modifier_remove_speed_cap = modifier_remove_speed_cap or class({})


--REMOVE SPEED LIMIT, APPLIED TO EVERYONE ON SPAWN

function modifier_remove_speed_cap:IsHidden()
	return true
end

function modifier_remove_speed_cap:RemoveOnDeath()
	return false
end
function modifier_remove_speed_cap:IsPurgable()
	return false
end


function modifier_remove_speed_cap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	}
	return funcs
end

function modifier_remove_speed_cap:GetModifierIgnoreMovespeedLimit()
	return 1
end
  