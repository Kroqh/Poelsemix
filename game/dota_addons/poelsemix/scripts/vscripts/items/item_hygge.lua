item_hygge = item_hygge or class({})

LinkLuaModifier("modifier_item_hygge", "items/item_hygge", LUA_MODIFIER_MOTION_NONE)

function item_hygge:GetIntrinsicModifierName()
	return "modifier_item_hygge"
end

function item_hygge:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	local int_scale = self:GetSpecialValueFor("int_healing_ratio") / 100
		
    local heal = caster:GetIntellect() * int_scale
	target:Heal(heal,self)
end


modifier_item_hygge = modifier_item_hygge or class({})
function modifier_item_hygge:IsHidden()		return true end
function modifier_item_hygge:IsPurgable()		return false end
function modifier_item_hygge:RemoveOnDeath()	return false end
function modifier_item_hygge:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_hygge:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED, 
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_hygge:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("int")
    end
end
function modifier_item_hygge:GetModifierAttackSpeedBonus_Constant()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("attack_speed")
    end
end
function modifier_item_hygge:GetModifierConstantManaRegen()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mana_regen")
    end
end

function modifier_item_hygge:OnAttackLanded( params )
	if IsServer() then
		if params.attacker~=self:GetParent() then return end
		-- damage
        
		local heroes = FindUnitsInRadius(self:GetParent():GetTeamNumber(), params.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("heaL_range"), self:GetAbility():GetAbilityTargetTeam(),self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_CLOSEST, false)

		if #heroes > 1 then
			target = 1
			if heroes[1] == self:GetParent() then target = 2 end

			local healproj = 
			{
				Target = heroes[target],
				Source = params.target,
				Ability = self:GetAbility(),
				EffectName = "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf",
				iMoveSpeed = self:GetAbility():GetSpecialValueFor("proj_speed"),
				bDodgeable = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
				ExtraData = {}
			}
			ProjectileManager:CreateTrackingProjectile(healproj)
		end

	end
end
