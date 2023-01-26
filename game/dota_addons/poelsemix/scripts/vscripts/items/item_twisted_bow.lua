item_twisted_bow = item_twisted_bow or class({})

LinkLuaModifier("modifier_item_twisted_bow", "items/item_twisted_bow", LUA_MODIFIER_MOTION_NONE)


function item_twisted_bow:GetIntrinsicModifierName()
	return "modifier_item_twisted_bow"
end

modifier_item_twisted_bow = modifier_item_twisted_bow or class({})

function modifier_item_twisted_bow:IsHidden()		return true end
function modifier_item_twisted_bow:IsPurgable()		return false end
function modifier_item_twisted_bow:RemoveOnDeath()	return false end
function modifier_item_twisted_bow:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end



function modifier_item_twisted_bow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_twisted_bow:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self:GetAbility():GetSpecialValueFor("bonus_range")
	end
end

function modifier_item_twisted_bow:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("agi")
end

function modifier_item_twisted_bow:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end


function modifier_item_twisted_bow:OnAttackLanded(params)
	if (params.attacker ~= self:GetParent()) then return end 
	local tbow_damage = params.damage * params.target:GetMagicalArmorValue()
	local damageTable = {
			victim = params.target,
            damage = tbow_damage,
            damage_type = DAMAGE_TYPE_PURE,
            attacker = params.attacker,
            ability = self:GetAbility()
        }
    ApplyDamage(damageTable)
	
end