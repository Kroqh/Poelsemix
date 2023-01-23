stealthy = class({})
LinkLuaModifier( "modifier_bonus_to_stealth_passive", "heroes/hero_shadow/bonus_to_stealth/modifier_bonus_to_stealth_passive", LUA_MODIFIER_MOTION_NONE )

function stealthy:GetIntrinsicModifierName()
	return "modifier_bonus_to_stealth_passive"
end
