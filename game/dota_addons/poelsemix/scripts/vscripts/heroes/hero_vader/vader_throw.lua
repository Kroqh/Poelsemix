LinkLuaModifier( "modifier_vader_throw_catch_talent", "heroes/hero_vader/vader_throw", LUA_MODIFIER_MOTION_NONE )

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

	local range = self:GetSpecialValueFor("range")

	if self:GetCaster():HasModifier("modifier_vader_wrath") then
		if self:GetCaster():FindAbilityByName("special_bonus_vader_3"):GetLevel() > 0 then
			range = range + self:GetCaster():GetModifierStackCount("modifier_vader_wrath",self:GetCaster())
		end
	end

	return range
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

		if self:GetCaster():FindAbilityByName("special_bonus_vader_6"):GetLevel() > 0 then
		caster:AddNewModifier(caster, self, "modifier_vader_throw_catch_talent", {duration = self:GetCaster():FindAbilityByName("special_bonus_vader_6"):GetSpecialValueFor("value")})
	end
	return end

	

	local damage = self:GetSpecialValueFor("damage")

	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})

	self:Throw(caster, target)

	if self:GetCaster():FindAbilityByName("special_bonus_vader_1"):GetLevel() > 0 then
		target:AddNewModifier(caster, self, "modifier_disarmed", {duration = self:GetCaster():FindAbilityByName("special_bonus_vader_1"):GetSpecialValueFor("value")})
	end

	target:EmitSound("vader_throw_hit")
end

modifier_vader_throw_catch_talent = modifier_vader_throw_catch_talent or class({})

function modifier_vader_throw_catch_talent:IsHidden() return false end
function modifier_vader_throw_catch_talent:IsPurgable() return false end
function modifier_vader_throw_catch_talent:IsDebuff() return false end

function modifier_vader_throw_catch_talent:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_vader_throw_catch_talent:GetEffectName()
    return "particles/units/heroes/hero_vader/saber_glow.vpcf"
end

function modifier_vader_throw_catch_talent:OnAttackLanded( params )
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_vader_wrath") then
			


			if (params.attacker ~= self:GetParent()) then return end 
				local damageTable = {
				victim = params.target,
				damage = self:GetCaster():FindModifierByName("modifier_vader_wrath"):GetStackCount(),
				damage_type = DAMAGE_TYPE_PHYSICAL,
				attacker = params.attacker,
				ability = self:GetAbility()
			}

		ApplyDamage(damageTable)
		self:GetParent():RemoveModifierByName("modifier_vader_throw_catch_talent")
		end
	end
end