LinkLuaModifier("modifier_kaj_popcorn", "heroes/hero_kaj/kaj_popcorn", LUA_MODIFIER_MOTION_NONE)
kaj_popcorn = kaj_popcorn or class({})


function kaj_popcorn:GetCastRange()
    local value = self:GetSpecialValueFor("cast_range") 
    return value
end


function kaj_popcorn:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local particle = "particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf"
		local speed = self:GetSpecialValueFor("proj_speed")
        

        local projectile = 
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
			}
		ProjectileManager:CreateTrackingProjectile(projectile)
        caster:EmitSound("KajPop2")
    end
end


function kaj_popcorn:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	if self:GetCaster():FindAbilityByName("special_bonus_kaj_1"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_kaj_1"):GetSpecialValueFor("value") end
	if self:GetCaster():FindAbilityByName("special_bonus_kaj_5"):GetLevel() > 0 then 
		local dmg = self:GetCaster():FindAbilityByName("special_bonus_kaj_5"):GetSpecialValueFor("value") 
		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = self:GetAbilityDamageType(),
		damage = dmg,
		ability = self
		})
	end
	
	target:AddNewModifier(caster, self, "modifier_kaj_popcorn", {duration = duration})
	
end


modifier_kaj_popcorn = modifier_kaj_popcorn or class({})

function modifier_kaj_popcorn:IsHidden()		return false end
function modifier_kaj_popcorn:IsDebuff()		return true end


function modifier_kaj_popcorn:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		self.damage = ability:GetSpecialValueFor("damage_tick")
		self.tick = ability:GetSpecialValueFor("tick_rate")
		self:StartIntervalThink(self.tick-0.1)
	end
end

function modifier_kaj_popcorn:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()

		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage = self.damage,
		ability = self:GetAbility()
		})
		target:AddNewModifier(caster, ability, "modifier_knockback", 
        {should_stun = 1, knockback_height = 25, knockback_distance = 10, knockback_duration = 0.1,  duration = 0.1})

		local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_explosion_white_d_arcana1.vpcf", PATTACH_CENTER_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(particle)
		target:EmitSound("KajPop1")
		self:StartIntervalThink(self.tick)
	end
end
