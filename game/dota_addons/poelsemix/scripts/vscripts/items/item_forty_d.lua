item_forty_d = item_forty_d or class({})

LinkLuaModifier("modifier_item_forty_d", "items/item_forty_d", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_forty_d_attack", "items/item_forty_d", LUA_MODIFIER_MOTION_NONE)

function item_forty_d:GetIntrinsicModifierName()
	return "modifier_item_forty_d"
end

modifier_item_forty_d = modifier_item_forty_d or class({})
function modifier_item_forty_d:IsHidden()		return true end
function modifier_item_forty_d:IsPurgable()		return false end
function modifier_item_forty_d:RemoveOnDeath()	return false end
function modifier_item_forty_d:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_forty_d:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, 
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_item_forty_d:OnAbilityExecuted(event)
    if event.unit ~= self:GetParent() then return end
	if event.ability:IsToggle() then return end
	if self:GetAbility():IsCooldownReady() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_forty_d_attack", {duration = self:GetAbility():GetSpecialValueFor("duration")})
		self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("cooldown"))
	end
end

function modifier_item_forty_d:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("str")
    end
end
function modifier_item_forty_d:GetModifierPercentageCooldown()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("cdr")
    end
end
function modifier_item_forty_d:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("magic_resist")
	end
end
function modifier_item_forty_d:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attack_speed")
    end
end

modifier_item_forty_d_attack = modifier_item_forty_d_attack or class({})

function modifier_item_forty_d_attack:IsHidden() return false end
function modifier_item_forty_d_attack:IsPurgable() return true end
function modifier_item_forty_d_attack:IsDebuff() return false end

function modifier_item_forty_d_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_item_forty_d_attack:GetEffectName()
    return "particles/units/items/forty_d.vpcf"
end

function modifier_item_forty_d_attack:OnAttackLanded( params )
	if IsServer() then
		local dmg = self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("max_hp_percent_damage") / 100)
		if (params.attacker ~= self:GetParent()) then return end 
				
		local damageTable = {
				victim = params.target,
				damage = dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				attacker = params.attacker,
				ability = self:GetAbility()
			}

		ApplyDamage(damageTable)
		self:GetParent():RemoveModifierByName("modifier_item_forty_d_attack")
	end
end

function modifier_item_forty_d_attack:GetTexture()
	return "forty_d"
end