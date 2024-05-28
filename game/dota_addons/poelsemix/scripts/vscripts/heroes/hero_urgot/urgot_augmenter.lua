LinkLuaModifier("modifier_urgot_augmenter", "heroes/hero_urgot/urgot_augmenter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_urgot_augmenter_debuff", "heroes/hero_urgot/urgot_augmenter", LUA_MODIFIER_MOTION_NONE)
urgot_augmenter = urgot_augmenter or class({})


function urgot_augmenter:GetIntrinsicModifierName()
	return "modifier_urgot_augmenter"
end

function urgot_augmenter:ApplyDebuff(target)
    duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(self:GetCaster(), self, "modifier_urgot_augmenter_debuff", {duration = duration})
end
modifier_urgot_augmenter = modifier_urgot_augmenter or class({})

function modifier_urgot_augmenter:IsPurgable() return false end
function modifier_urgot_augmenter:IsPassive() return false end
function modifier_urgot_augmenter:IsHidden() return true end

function modifier_urgot_augmenter:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return decFuncs
end

function modifier_urgot_augmenter:OnAttackLanded(keys)
	if IsServer() then
		local parent = self:GetParent()

		if keys.attacker == parent then
			self:GetAbility():ApplyDebuff(keys.target)
		end
	end
end


modifier_urgot_augmenter_debuff = modifier_urgot_augmenter_debuff or class({})

function modifier_urgot_augmenter_debuff:IsPurgable() return true end
function modifier_urgot_augmenter_debuff:IsHidden() return false end
function modifier_urgot_augmenter_debuff:IsDebuff() return true end

function modifier_urgot_augmenter_debuff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
	return decFuncs
end

function modifier_urgot_augmenter_debuff:GetModifierTotalDamageOutgoing_Percentage()
	local value = self:GetAbility():GetSpecialValueFor("damage_reduction")
	if self:GetCaster():FindAbilityByName("special_bonus_urgot_2"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_urgot_2"):GetSpecialValueFor("value") end
	return value
end