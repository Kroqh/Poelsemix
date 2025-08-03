vader_throw = vader_throw or class({})

function vader_throw :OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		self:Throw(target,caster)
		caster:EmitSound("vader_throw")
	end
end

function vader_throw:GetCastRange()
	return self:GetSpecialValueFor("range")
end


function vader_throw:Throw(target, source)
		local particle = "particles/units/heroes/vader/lightsaber_throw.vpcf"
		local attach = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 
		if target  == self:GetCaster() then 
			particle = "particles/units/heroes/vader/lightsaber_throw_return.vpcf"
			attach = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		end
		local speed = self:GetSpecialValueFor("projectile_speed")

		



		local saber = 
			{
				Target = target,
				Source = source,
				Ability = self,
				EffectName = particle,
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
				iSourceAttachment = attach,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(saber)
end

function vader_throw:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	
	if target == caster
	then
		if caster:HasModifier("modifier_vader_wrath") then
			caster:FindModifierByName("modifier_vader_wrath"):AddStacks(self:GetSpecialValueFor("wrath_on_catch"))
		end
	return end

	

	local damage = self:GetSpecialValueFor("damage")

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})

	self:Throw(caster, target)

	target:EmitSound("vader_throw_hit")
	
end