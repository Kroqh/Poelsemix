shadow_stealthy = shadow_stealthy or class({})
LinkLuaModifier( "modifier_bonus_to_stealth_invis", "heroes/hero_shadow/shadow_stealthy", LUA_MODIFIER_MOTION_NONE )

function shadow_stealthy:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_bonus_to_stealth_invis", {duration = duration})
end
modifier_bonus_to_stealth_invis = modifier_bonus_to_stealth_invis or  class({})

function modifier_bonus_to_stealth_invis:IsPurgable() return true end
function modifier_bonus_to_stealth_invis:IsDebuff() return false end
function modifier_bonus_to_stealth_invis:IsHidden() return false end

function modifier_bonus_to_stealth_invis:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_START}
	return decFuncs
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

function modifier_bonus_to_stealth_invis:OnAttackStart(keys)
	if IsServer() then
		local parent = self:GetParent()
		if keys.attacker == parent then
            self:Destroy()
		end
	end
end

function modifier_bonus_to_stealth_invis:OnAbilityExecuted(keys)
	if IsServer() then
		local parent = self:GetParent()
		if keys.unit == parent then
            self:Destroy()
		end
	end
end