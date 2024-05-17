item_peter_madsens = item_peter_madsens or class({})

LinkLuaModifier("modifier_item_peter_madsens", "items/item_peter_madsens", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_peter_debuff", "items/item_peter_madsens", LUA_MODIFIER_MOTION_NONE)

function item_peter_madsens:GetIntrinsicModifierName()
	return "modifier_item_peter_madsens"
end

function item_peter_madsens:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self
        local target = self:GetCursorTarget()
        local sound_cast = "DOTA_Item.HeavensHalberd.Activate"    
        local modifier_mark = "modifier_item_peter_debuff"

        -- Ability specials
        local mark_duration = ability:GetSpecialValueFor("active_duration")

        EmitSoundOn(sound_cast, target)

            target:AddNewModifier(caster, ability, modifier_mark, {duration = mark_duration})
    end

end


modifier_item_peter_madsens = modifier_item_peter_madsens or class({})
function modifier_item_peter_madsens:IsHidden()		return true end
function modifier_item_peter_madsens:IsPurgable()		return false end
function modifier_item_peter_madsens:RemoveOnDeath()	return false end
function modifier_item_peter_madsens:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_peter_madsens:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE
	}
end

function modifier_item_peter_madsens:GetModifierStatusResistance()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("tenacity")
    end
end
function modifier_item_peter_madsens:GetModifierLifestealRegenAmplify_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("heal_amp")
    end
end
function modifier_item_peter_madsens:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("armor")
    end
end

function modifier_item_peter_madsens:GetModifierHPRegenAmplify_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("heal_amp")
    end
end
function modifier_item_peter_madsens:GetModifierBonusStats_Strength()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("strength")
    end
end


modifier_item_peter_debuff = modifier_item_peter_debuff or class({})


function modifier_item_peter_debuff:IsHidden() return false end
function modifier_item_peter_debuff:IsPurgable() return false end
function modifier_item_peter_debuff:IsDebuff() return true end

function modifier_item_peter_debuff:GetEffectName()
	return "particles/units/heroes/hero_demonartist/demonartist_engulf_disarm/items2_fx/heavens_halberd.vpcf"
end

function modifier_item_peter_debuff:GetTexture()
    return "peter_madsens"
end


function modifier_item_peter_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_item_peter_debuff:GetModifierEvasion_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("evasion_debuff")
    end
end

function modifier_item_peter_debuff:CheckState()
	local state =
		{
			[MODIFIER_STATE_DISARMED] = true
		}
	return state
end