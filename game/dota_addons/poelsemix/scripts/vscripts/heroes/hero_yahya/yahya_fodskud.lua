LinkLuaModifier("modifier_yahya_fodskud_debuff", "heroes/hero_yahya/yahya_fodskud", LUA_MODIFIER_MOTION_NONE)
yahya_fodskud = yahya_fodskud or class({})

function yahya_fodskud:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack.vpcf"
		local speed = 1500

		local bullet = 
			{
				Target = target,
				Source = caster,
				Ability = self,
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(bullet)
		EmitSoundOn("pistol_skud", caster)
	end
end

function yahya_fodskud:GetCastRange()
	if self:GetCaster():FindAbilityByName("special_bonus_yahya_5"):GetLevel() > 0 then return self:GetSpecialValueFor("range") + self:GetCaster():FindAbilityByName("special_bonus_yahya_5"):GetSpecialValueFor("value") end
    return self:GetSpecialValueFor("range")
end

function yahya_fodskud:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()

	local damage = self:GetSpecialValueFor("damage")
	if caster:HasTalent("special_bonus_yahya_1") then damage = damage + caster:FindAbilityByName("special_bonus_yahya_1"):GetSpecialValueFor("value") end
	local duration = self:GetSpecialValueFor("duration")

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})
	
	target:AddNewModifier(caster, self, "modifier_yahya_fodskud_debuff", {duration = duration})
end

modifier_yahya_fodskud_debuff = modifier_yahya_fodskud_debuff or class({})

function modifier_yahya_fodskud_debuff:IsDebuff() return true end

function modifier_yahya_fodskud_debuff:OnCreated()
	if IsServer() then
	end
end

function modifier_yahya_fodskud_debuff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_REDUCTION_PERCENTAGE }
	return decFuncs
end

function modifier_yahya_fodskud_debuff:GetModifierMoveSpeedReductionPercentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_debuff_percent")
end