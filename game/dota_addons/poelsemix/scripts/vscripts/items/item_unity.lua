item_unity = item_unity or class({})

LinkLuaModifier("modifier_item_unity", "items/item_unity", LUA_MODIFIER_MOTION_NONE)

function item_unity:GetIntrinsicModifierName()
	return "modifier_item_unity"
end

modifier_item_unity = modifier_item_unity or class({})
function modifier_item_unity:IsHidden()		return true end
function modifier_item_unity:IsPurgable()		return false end
function modifier_item_unity:RemoveOnDeath()	return false end
function modifier_item_unity:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_unity:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
end

function modifier_item_unity:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
		local int = self:GetParent():GetIntellect()
		local str = self:GetParent():GetStrength()
		local agi = self:GetParent():GetAgility()
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		
		damage = damage - math.abs(math.min(int,agi,str) - math.max(int,agi,str)) --gets gap between best and worst attribute
		
        return damage
    end
end
function modifier_item_unity:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("all_attributes")
    end
end

function modifier_item_unity:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("all_attributes")
    end
end
function modifier_item_unity:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("all_attributes")
    end
end