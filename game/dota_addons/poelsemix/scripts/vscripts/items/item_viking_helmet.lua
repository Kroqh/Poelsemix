item_viking_helmet = item_viking_helmet or class({})

LinkLuaModifier("modifier_item_viking_helmet", "items/item_viking_helmet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_viking_helmet_unique", "items/item_viking_helmet", LUA_MODIFIER_MOTION_NONE)

function item_viking_helmet:GetIntrinsicModifierName()
	return "modifier_item_viking_helmet"
end

modifier_item_viking_helmet = modifier_item_viking_helmet or class({})
function modifier_item_viking_helmet:IsHidden()		return true end
function modifier_item_viking_helmet:IsPurgable()		return false end
function modifier_item_viking_helmet:RemoveOnDeath()	return false end
function modifier_item_viking_helmet:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_viking_helmet:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_viking_helmet:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("str")
    end
end
function modifier_item_viking_helmet:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attack_speed")
    end
end
function modifier_item_viking_helmet:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_viking_helmet_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_viking_helmet_unique", {})
		end
	end
end

function modifier_item_viking_helmet:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_viking_helmet") then
			parent:RemoveModifierByName("modifier_item_viking_helmet_unique")
		end
	end
end


modifier_item_viking_helmet_unique = modifier_item_viking_helmet_unique or class({})
function modifier_item_viking_helmet_unique:IsHidden()		return true end
function modifier_item_viking_helmet_unique:IsPurgable()		return false end
function modifier_item_viking_helmet_unique:RemoveOnDeath()	return false end

function modifier_item_viking_helmet_unique:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	}
end

function modifier_item_viking_helmet_unique:GetModifierAttackSpeedPercentage(params)
	local parent = self:GetParent()
    local as = (1 - ( parent:GetHealth() / parent:GetMaxHealth())*100) * self:GetAbility():GetSpecialValueFor("as_pct_per_missing_hp")
    return as
end