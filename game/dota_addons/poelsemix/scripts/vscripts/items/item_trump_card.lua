item_trump_card = item_trump_card or class({})

LinkLuaModifier("modifier_item_trump_card", "items/item_trump_card", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_trump_card_unique", "items/item_trump_card", LUA_MODIFIER_MOTION_NONE)

function item_trump_card:GetIntrinsicModifierName()
	return "modifier_item_trump_card"
end

modifier_item_trump_card = modifier_item_trump_card or class({})
function modifier_item_trump_card:IsHidden()		return true end
function modifier_item_trump_card:IsPurgable()		return false end
function modifier_item_trump_card:RemoveOnDeath()	return false end
function modifier_item_trump_card:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_trump_card:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, 
		MODIFIER_PROPERTY_MANA_BONUS
	}
end

function modifier_item_trump_card:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("int")
    end
end
function modifier_item_trump_card:GetModifierManaBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mana")
    end
end

function modifier_item_trump_card:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_trump_card_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_trump_card_unique", {})
		end
	end
end

function modifier_item_trump_card:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_trump_card") then
			parent:RemoveModifierByName("modifier_item_trump_card_unique")
		end
	end
end


modifier_item_trump_card_unique = modifier_item_trump_card_unique or class({})
function modifier_item_trump_card_unique:IsHidden()		return true end
function modifier_item_trump_card_unique:IsPurgable()		return false end
function modifier_item_trump_card_unique:RemoveOnDeath()	return false end

function modifier_item_trump_card_unique:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_trump_card_unique:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then
        local npc = self:GetParent()
        local calc = npc:GetIntellect() * (self:GetAbility():GetSpecialValueFor("spell_amp_ratio")/100)
        return calc
    end
end