modifier_bonus_to_stealth_invis = class({})

function modifier_bonus_to_stealth_invis:IsPurgeable()
	return false
end
function modifier_bonus_to_stealth_invis:IsDebuff() return false end
function modifier_bonus_to_stealth_invis:IsHidden() return true end

function modifier_bonus_to_stealth_invis:DeclareFunctions()
	local decFuncs = {
	MODIFIER_PROPERTY_INVISIBILITY_LEVEL, 
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
	return decFuncs
end
function modifier_bonus_to_stealth_invis:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movement_speed")
end
function modifier_bonus_to_stealth_invis:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end

function modifier_bonus_to_stealth_invis:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end