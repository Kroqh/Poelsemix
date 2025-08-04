item_calculator = item_calculator or class({})

LinkLuaModifier("modifier_item_calculator", "items/item_calculator", LUA_MODIFIER_MOTION_NONE)

function item_calculator:GetIntrinsicModifierName()
	return "modifier_item_calculator"
end

modifier_item_calculator = modifier_item_calculator or class({})
function modifier_item_calculator:IsHidden()		return true end
function modifier_item_calculator:IsPurgable()		return false end
function modifier_item_calculator:RemoveOnDeath()	return false end
function modifier_item_calculator:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_calculator:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_item_calculator:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("int")
    end
end
function modifier_item_calculator:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mana_regen")
    end
end
function modifier_item_calculator:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mana")
    end
end
function modifier_item_calculator:GetModifierHealthBonus()
    if self:GetAbility() then
        return (self:GetParent():GetMaxMana() * self:GetAbility():GetSpecialValueFor("mana_to_health_ratio") / 100)
    end
end

function modifier_item_calculator:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return 
    end
end