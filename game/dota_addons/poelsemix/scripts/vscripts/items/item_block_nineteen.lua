item_block_nineteen = item_block_nineteen or class({})

LinkLuaModifier("modifier_item_block_nineteen", "items/item_block_nineteen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_block_nineteen_unique", "items/item_block_nineteen", LUA_MODIFIER_MOTION_NONE)

function item_block_nineteen:GetIntrinsicModifierName()
	return "modifier_item_block_nineteen"
end

modifier_item_block_nineteen = modifier_item_block_nineteen or class({})
function modifier_item_block_nineteen:IsHidden()		return true end
function modifier_item_block_nineteen:IsPurgable()		return false end
function modifier_item_block_nineteen:RemoveOnDeath()	return false end
function modifier_item_block_nineteen:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_block_nineteen:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_block_nineteen:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("damage")
    end
end
function modifier_item_block_nineteen:GetModifierBonusStats_Agility()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("agi")
    end
end
function modifier_item_block_nineteen:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attack_speed")
    end
end
function modifier_item_block_nineteen:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_block_nineteen_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_block_nineteen_unique", {})
		end
	end
end

function modifier_item_block_nineteen:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_block_nineteen") then
			parent:RemoveModifierByName("modifier_item_block_nineteen_unique")
		end
	end
end


modifier_item_block_nineteen_unique = modifier_item_block_nineteen_unique or class({})
function modifier_item_block_nineteen_unique:IsHidden()		return true end
function modifier_item_block_nineteen_unique:IsPurgable()		return false end
function modifier_item_block_nineteen_unique:RemoveOnDeath()	return false end

function modifier_item_block_nineteen_unique:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_block_nineteen_unique:OnAttackLanded(event)
    if not IsServer() then return end
	if event.attacker ~= self:GetParent() then return end
	local dmg = event.target:GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("max_hp_dmg_pct")/100)
	ApplyDamage({victim = event.target,
    attacker = event.attacker,
    damage_type = DAMAGE_TYPE_PURE,
    damage =  dmg,
    ability = self:GetAbility()})
end

function modifier_item_block_nineteen_unique:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        local chance = self:GetAbility():GetSpecialValueFor("crit_chance")

        if RollPercentage(chance) then
            local hTarget = params.target
            return self:GetAbility():GetSpecialValueFor("crit_damage")
        end
    end
end