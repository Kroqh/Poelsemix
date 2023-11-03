item_abaddon_lichcap = item_abaddon_lichcap or class({})

LinkLuaModifier("modifier_item_abaddon_lichcap", "items/item_abaddon_lichcap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_abaddon_lichcap_unique", "items/item_abaddon_lichcap", LUA_MODIFIER_MOTION_NONE)

function item_abaddon_lichcap:GetIntrinsicModifierName()
	return "modifier_item_abaddon_lichcap"
end

modifier_item_abaddon_lichcap = modifier_item_abaddon_lichcap or class({})
function modifier_item_abaddon_lichcap:IsHidden()		return true end
function modifier_item_abaddon_lichcap:IsPurgable()		return false end
function modifier_item_abaddon_lichcap:RemoveOnDeath()	return false end
function modifier_item_abaddon_lichcap:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_abaddon_lichcap:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
end

function modifier_item_abaddon_lichcap:GetModifierBaseAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("damage")
    end
end

function modifier_item_abaddon_lichcap:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_abaddon_lichcap_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_abaddon_lichcap_unique", {})
		end
	end
end

function modifier_item_abaddon_lichcap:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_abaddon_lichcap") then
			parent:RemoveModifierByName("modifier_item_abaddon_lichcap_unique")
		end
	end
end


modifier_item_abaddon_lichcap_unique = modifier_item_abaddon_lichcap_unique or class({})
function modifier_item_abaddon_lichcap_unique:IsHidden()		return true end
function modifier_item_abaddon_lichcap_unique:IsPurgable()		return false end
function modifier_item_abaddon_lichcap_unique:RemoveOnDeath()	return false end

function modifier_item_abaddon_lichcap_unique:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_item_abaddon_lichcap_unique:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        local npc = self:GetParent()
        local calc = (math.ceil(npc:GetDamageMax() + npc:GetDamageMin()) / 2) * (1 + (self:GetAbility():GetSpecialValueFor("damage_multi_percentage")/100))
        return calc
    end
end