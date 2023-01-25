flyby_attack = class({})
LinkLuaModifier( "modifier_flyby_passive", "heroes/hero_shadow/flyby_attack/modifier_flyby_passive", LUA_MODIFIER_MOTION_NONE )

function flyby_attack:GetIntrinsicModifierName()
	return "modifier_flyby_passive"
end