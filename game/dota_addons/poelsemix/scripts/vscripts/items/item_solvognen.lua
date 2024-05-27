item_solvognen = item_solvognen or class({})

LinkLuaModifier("modifier_item_solvognen", "items/item_solvognen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_solvognen_unique", "items/item_solvognen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_solvognen_miss_aura", "items/item_solvognen", LUA_MODIFIER_MOTION_NONE)

function item_solvognen:GetIntrinsicModifierName()
	return "modifier_item_solvognen"
end
function item_solvognen:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end

modifier_item_solvognen = modifier_item_solvognen or class({})
function modifier_item_solvognen:IsHidden()		return true end
function modifier_item_solvognen:IsPurgable()		return false end
function modifier_item_solvognen:RemoveOnDeath()	return false end
function modifier_item_solvognen:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_solvognen:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_RESPAWN
	}
end

function modifier_item_solvognen:GetModifierBaseAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("damage")
    end
end

function modifier_item_solvognen:GetModifierConstantHealthRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("health_regen")
    end
end

function modifier_item_solvognen:GetModifierEvasion_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("evasion")
    end
end
function modifier_item_solvognen:OnRespawn(event)
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
		if event.unit ~= self:GetParent() then return end

		if not parent:HasModifier("modifier_item_solvognen_unique") then
			parent:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_solvognen_unique", {})
		end
    end

end

function modifier_item_solvognen:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end

		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_solvognen_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_solvognen_unique", {})
		end
	end
end

function modifier_item_solvognen:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_solvognen") then
			parent:RemoveModifierByName("modifier_item_solvognen_unique")
		end
	end
end


modifier_item_solvognen_unique = modifier_item_solvognen_unique or class({})
function modifier_item_solvognen_unique:IsHidden()		return true end
function modifier_item_solvognen_unique:IsPurgable()		return false end

function modifier_item_solvognen_unique:GetAuraSearchTeam()	return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_solvognen_unique:GetAuraSearchType()	return self:GetAbility():GetAbilityTargetType() end
function modifier_item_solvognen_unique:GetModifierAura()			return  "modifier_item_solvognen_miss_aura" end
function modifier_item_solvognen_unique:IsAura() return true end

function modifier_item_solvognen_unique:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_solvognen_unique:OnCreated()
    if not IsServer() then return end
	local tick_rate = self:GetAbility():GetSpecialValueFor("aura_tick_rate")
	local effectiveness = 1
	if self:GetParent():IsIllusion() then
		effectiveness = effectiveness * (1 + (self:GetAbility():GetSpecialValueFor("aura_illusion_reduced_effectiveness")/100))
	end
	self.damage = self:GetAbility():GetSpecialValueFor("aura_damage_sec")  * tick_rate * effectiveness
	self.regen = self:GetAbility():GetSpecialValueFor("aura_regen_sec")  * tick_rate * effectiveness
	self:StartIntervalThink(tick_rate)
end

function modifier_item_solvognen_unique:OnIntervalThink()
    if not IsServer() then return end
	local parent = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("aura_radius")
	local units = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(), 
	self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _, unit in pairs(units) do
			if unit:GetTeamNumber() == parent:GetTeamNumber() then
				unit:Heal(self.regen, parent)
			else
				ApplyDamage({victim = unit, attacker = parent, damage_type = self:GetAbility():GetAbilityDamageType(), damage = self.damage, ability = self})
			end
		end
end

function modifier_item_solvognen_unique:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_item_solvognen_unique:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_2022_cc/ogre_2022_cc_trail_fire.vpcf"
end



modifier_item_solvognen_miss_aura = modifier_item_solvognen_miss_aura or class({})
function modifier_item_solvognen_miss_aura:IsPurgable()		return false end
function modifier_item_solvognen_miss_aura:IsDebuff()	return true end

function modifier_item_solvognen_miss_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
end

function modifier_item_solvognen_miss_aura:GetModifierMiss_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("aura_missrate")
    end
end