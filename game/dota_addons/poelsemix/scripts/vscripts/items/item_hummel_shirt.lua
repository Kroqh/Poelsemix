item_hummel_shirt = item_hummel_shirt or class({})

LinkLuaModifier("modifier_item_hummel_shirt", "items/item_hummel_shirt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_hummel_shirt_aura", "items/item_hummel_shirt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_hummel_shirt_active", "items/item_hummel_shirt", LUA_MODIFIER_MOTION_NONE)

function item_hummel_shirt:GetIntrinsicModifierName()
	return "modifier_item_hummel_shirt"
end

function item_hummel_shirt:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_item_hummel_shirt_active", {duration = self:GetSpecialValueFor("duration")})
    EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)
end

function item_hummel_shirt:GetCastRange()
    local range = self:GetSpecialValueFor("radius")
    return range
end

modifier_item_hummel_shirt = modifier_item_hummel_shirt or class({})
function modifier_item_hummel_shirt:IsHidden()		return true end
function modifier_item_hummel_shirt:IsPurgable()		return false end
function modifier_item_hummel_shirt:RemoveOnDeath()	return false end
function modifier_item_hummel_shirt:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_hummel_shirt:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end


function modifier_item_hummel_shirt:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
		local damage = self:GetAbility():GetSpecialValueFor("damage")
        return damage
    end
end
function modifier_item_hummel_shirt:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("as")
    end
end
function modifier_item_hummel_shirt:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("armor")
    end
end

function modifier_item_hummel_shirt:IsAura()						return true end
function modifier_item_hummel_shirt:IsAuraActiveOnDeath() 		return false end

function modifier_item_hummel_shirt:GetAuraDuration()				return 0.1 end
function modifier_item_hummel_shirt:GetAuraRadius()				return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_item_hummel_shirt:GetAuraSearchFlags()			return self:GetAbility():GetAbilityTargetFlags() end
function modifier_item_hummel_shirt:GetAuraSearchTeam()			return self:GetAbility():GetAbilityTargetTeam() end
function modifier_item_hummel_shirt:GetAuraSearchType()			return self:GetAbility():GetAbilityTargetType() end
function modifier_item_hummel_shirt:GetModifierAura()				return "modifier_item_hummel_shirt_aura" end




modifier_item_hummel_shirt_aura = modifier_item_hummel_shirt_aura or class({})
function modifier_item_hummel_shirt_aura:IsHidden()		return false end
function modifier_item_hummel_shirt_aura:IsDebuff()		return self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() end
function modifier_item_hummel_shirt_aura:IsPurgable()		return false end

function modifier_item_hummel_shirt_aura:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_hummel_shirt_aura:OnCreated()
	self.is_teammate = self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber()
end

function modifier_item_hummel_shirt_aura:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        if self.is_teammate then return self:GetAbility():GetSpecialValueFor("as_aura") else return end
    end
end

function modifier_item_hummel_shirt_aura:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then
        if self.is_teammate then return self:GetAbility():GetSpecialValueFor("armor_gain_aura") else return self:GetAbility():GetSpecialValueFor("armor_loss_aura")  end
    end
end
function modifier_item_hummel_shirt_aura:GetTexture()
    return "hummel_shirt" 
end


modifier_item_hummel_shirt_active = modifier_item_hummel_shirt_active or class({})
function modifier_item_hummel_shirt_active:IsHidden()		return false end
function modifier_item_hummel_shirt_active:IsPurgable()		return true end

function modifier_item_hummel_shirt_active:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_item_hummel_shirt_active:OnTakeDamage(keys)
	if not IsServer() then return end
    if keys.unit == parent and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= parent:GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then

        ApplyDamage({victim = keys.attacker,
        attacker = self:GetCaster(),
        damage_type = DAMAGE_TYPE_PURE,
        damage = keys.damage * (self:GetAbility():GetSpecialValueFor("damage_reflect_percent")/100),
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
        })
    end
    
end

function modifier_item_hummel_shirt_active:GetEffectName()
    return "particles/econ/items/spectre/spectre_arcana/spectre_arcana_blademail.vpcf"
end

function modifier_item_hummel_shirt_active:GetTexture()
    return "hummel_shirt"
end