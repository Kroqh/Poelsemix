item_danish_sewing_kit = item_danish_sewing_kit or class({})

LinkLuaModifier("modifier_item_danish_sewing_kit", "items/item_danish_sewing_kit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_danish_sewing_kit_unique", "items/item_danish_sewing_kit", LUA_MODIFIER_MOTION_NONE)

function item_danish_sewing_kit:GetIntrinsicModifierName()
	return "modifier_item_danish_sewing_kit"
end


function item_danish_sewing_kit:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local damage = self:GetCaster():GetAverageTrueAttackDamage(nil) * (self:GetSpecialValueFor("damage_percent") / 100)
	local damageTable = {
			victim = target,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            attacker = self:GetCaster(),
            ability = self
        }
    ApplyDamage(damageTable)
end

modifier_item_danish_sewing_kit = modifier_item_danish_sewing_kit or class({})

function modifier_item_danish_sewing_kit:IsHidden()		return true end
function modifier_item_danish_sewing_kit:IsPurgable()		return false end
function modifier_item_danish_sewing_kit:RemoveOnDeath()	return false end
function modifier_item_danish_sewing_kit:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end



function modifier_item_danish_sewing_kit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end


function modifier_item_danish_sewing_kit:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("agi")
end

function modifier_item_danish_sewing_kit:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end



function modifier_item_danish_sewing_kit:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_danish_sewing_kit_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_danish_sewing_kit_unique", {})
		end
	end
end

function modifier_item_danish_sewing_kit:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_danish_sewing_kit") then
			parent:RemoveModifierByName("modifier_item_danish_sewing_kit_unique")
		end
	end
end

modifier_item_danish_sewing_kit_unique = modifier_item_danish_sewing_kit_unique or class({})

function modifier_item_danish_sewing_kit_unique:IsHidden()		return true end
function modifier_item_danish_sewing_kit_unique:IsPurgable()		return false end
function modifier_item_danish_sewing_kit_unique:RemoveOnDeath()	return false end

function modifier_item_danish_sewing_kit_unique:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end



function modifier_item_danish_sewing_kit_unique:OnAttackLanded(params)
	if (params.attacker ~= self:GetParent()) then return end 
	if not IsServer() then return end

	local range = 0
	if self:GetParent():IsRangedAttacker() then
		range = self:GetAbility():GetSpecialValueFor("range_ranged")
	else
		range = self:GetAbility():GetSpecialValueFor("range_melee")
	end
	local count = 0
	local maxCount = self:GetAbility():GetSpecialValueFor("targets")
	local speed = self:GetAbility():GetSpecialValueFor("needle_speed")
	

	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), params.target:GetAbsOrigin(), nil, range, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_CLOSEST, false)) do
			if (enemy ~= params.target) then
				if (count >= maxCount) then break end
				count = count + 1
				
				local particle = "particles/units/items/sewing_kit.vpcf"
				

				local bullet = 
			{
				Target = enemy,
				Source = params.target,
				Ability = self:GetAbility(),
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			}
			ProjectileManager:CreateTrackingProjectile(bullet)
		end
	end
end