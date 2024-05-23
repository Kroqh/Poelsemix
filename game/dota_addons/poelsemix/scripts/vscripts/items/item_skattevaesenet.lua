item_skattevaesenet = item_skattevaesenet or class({})

LinkLuaModifier("modifier_item_skattevaesenet", "items/item_skattevaesenet", LUA_MODIFIER_MOTION_NONE)

function item_skattevaesenet:GetIntrinsicModifierName()
	return "modifier_item_skattevaesenet"
end

function item_skattevaesenet:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self
        local target = self:GetCursorTarget()
        local sound_cast = "item_cash"    

        -- Ability specials

        if (target:HasItemInInventory("item_talisman_of_tax_evasion")) then
            sound_cast = "tax_evasion"
            local particle_slash_fx = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_msg_deny_symbol.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle_slash_fx, 0, target:GetAbsOrigin())
        else
            
            local gold = target:GetGold() * (self:GetSpecialValueFor("tax_percent")/100)
            if gold < self:GetSpecialValueFor("min_gold") then gold_amount = self:GetSpecialValueFor("min_gold") end
            caster:ModifyGold(gold, true, 0)
            target:ModifyGold(-gold, true, 0)
            ParticleManager:CreateParticle("particles/econ/courier/courier_flopjaw_gold/flopjaw_death_coins_gold.vpcf", PATTACH_ABSORIGIN, target)
        end

        EmitSoundOn(sound_cast, target)
        
    end

end

modifier_item_skattevaesenet = modifier_item_skattevaesenet or class({})
function modifier_item_skattevaesenet:IsHidden()			return true end
function modifier_item_skattevaesenet:IsPurgable()		return false end
function modifier_item_skattevaesenet:RemoveOnDeath()	return false end
function modifier_item_skattevaesenet:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_skattevaesenet:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
end

function modifier_item_skattevaesenet:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("attack_speed")
	end
end
function modifier_item_skattevaesenet:GetModifierHealthBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("health")
    end
end
function modifier_item_skattevaesenet:GetModifierCastRangeBonus()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
    end
end