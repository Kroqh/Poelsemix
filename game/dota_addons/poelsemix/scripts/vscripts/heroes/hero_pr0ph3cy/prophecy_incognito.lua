LinkLuaModifier("modifier_pr0_incognito", "heroes/hero_pr0ph3cy/prophecy_incognito", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pr0_incognito_stealth", "heroes/hero_pr0ph3cy/prophecy_incognito", LUA_MODIFIER_MOTION_NONE)

pr0_incognito = pr0_incognito or class({})

function pr0_incognito:GetIntrinsicModifierName()
	return "modifier_pr0_incognito"
end


modifier_pr0_incognito = modifier_pr0_incognito or class({})

function modifier_pr0_incognito:IsPassive() return true end
function modifier_pr0_incognito:IsHidden() return true end
function modifier_pr0_incognito:IsPurgable() return false end

function modifier_pr0_incognito:OnCreated()
	if not IsServer() then return end

	local fade = self:GetAbility():GetSpecialValueFor("fade_time")
	if self:GetCaster():FindAbilityByName("special_bonus_prophecy_2"):GetLevel() > 0 then fade = fade + self:GetCaster():FindAbilityByName("special_bonus_prophecy_2"):GetSpecialValueFor("value") end      
    self:StartIntervalThink(fade)

end

function modifier_pr0_incognito:OnIntervalThink()
	if not IsServer() then return end
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pr0_incognito_stealth", {})
	self:StartIntervalThink(-1)
end

function modifier_pr0_incognito:ModCheck()
	local parent = self:GetParent()
	if parent:HasModifier("modifier_pr0_incognito_stealth") then
		parent:RemoveModifierByName("modifier_pr0_incognito_stealth")
		local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:ReleaseParticleIndex(particle)
	end
	local fade = self:GetAbility():GetSpecialValueFor("fade_time")
	if self:GetCaster():FindAbilityByName("special_bonus_prophecy_2"):GetLevel() > 0 then fade = fade + self:GetCaster():FindAbilityByName("special_bonus_prophecy_2"):GetSpecialValueFor("value") end      
    self:StartIntervalThink(fade)
end

function modifier_pr0_incognito:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ATTACK_START
	}
	return funcs
end

function modifier_pr0_incognito:OnTakeDamage(keys)
    if not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end
	self:ModCheck()
end
function modifier_pr0_incognito:OnAbilityExecuted(keys)
    if not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end
	self:ModCheck()
end
function modifier_pr0_incognito:OnAttackStart(keys)
    if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_ring_fast.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:ReleaseParticleIndex(particle)
	self:ModCheck()
end

modifier_pr0_incognito_stealth = modifier_pr0_incognito_stealth or  class({})

function modifier_pr0_incognito_stealth:IsPurgable() return true end
function modifier_pr0_incognito_stealth:IsDebuff() return false end
function modifier_pr0_incognito_stealth:IsHidden() return false end

function modifier_pr0_incognito_stealth:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
	return decFuncs
end
function modifier_pr0_incognito_stealth:OnCreated()
	if not IsServer() then return end
    self:StartIntervalThink(0.01)

end

function modifier_pr0_incognito_stealth:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():IsChanneling() then --should not interrupt blockchain channel
		if self:GetParent():IsMoving() then --holy ugly
			self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
			self:GetParent():StartGesture(ACT_DOTA_CHANNEL_ABILITY_4)
		else
			self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
			self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4)
		end
	end
end

function modifier_pr0_incognito_stealth:OnRemoved()
	if not IsServer() then return end
	self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
	self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
end


function modifier_pr0_incognito_stealth:GetModifierInvisibilityLevel()
	if IsClient() then
		return 1
	end
end

function modifier_pr0_incognito_stealth:CheckState()
	if IsServer() then
		local state = {[MODIFIER_STATE_INVISIBLE] = true}
		return state
	end
end