LinkLuaModifier("modifier_vader_lightning", "heroes/hero_vader/vader_lightning", LUA_MODIFIER_MOTION_NONE)

vader_lightning = vader_lightning or class({})

function vader_lightning :OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		target = self:GetCursorTarget()
		target:AddNewModifier(caster, self, "modifier_vader_lightning", {duration = self:GetSpecialValueFor("duration")})
		
	end
	
end

function vader_lightning:GetCastRange()
	return self:GetSpecialValueFor("range")
end


modifier_vader_lightning = modifier_vader_lightning or class({})


function modifier_vader_lightning:IsHidden()		return false end
function modifier_vader_lightning:IsPurgable()		return true end
function modifier_vader_lightning:IsDebuff()		return true end

function modifier_vader_lightning:OnCreated()
	if not IsServer() then return end
	self.tick_rate =  self:GetAbility():GetSpecialValueFor("tickrate")
	self.damage_sec = self:GetAbility():GetSpecialValueFor("damage_sec")
	if self:GetCaster():FindAbilityByName("special_bonus_vader_2"):GetLevel() > 0 then self.damage_sec = self.damage_sec + self:GetCaster():FindAbilityByName("special_bonus_vader_2"):GetSpecialValueFor("value") end

	self.scepter_dmg = self.damage_sec * (self:GetAbility():GetSpecialValueFor("scepter_dmg_percent") / 100)
	self.maxrange = self:GetAbility():GetEffectiveCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster())
	self.scepter_range = self:GetAbility():GetSpecialValueFor("scepter_range")
	self:StartIntervalThink(self.tick_rate)
	self:GetParent():EmitSound("vader_lightning")
end

function modifier_vader_lightning:OnIntervalThink()
    if not IsServer() then return end
		if   FindDistance(self:GetParent():GetAbsOrigin(), self:GetCaster():GetAbsOrigin()) > self.maxrange + 50 then
		 	self:Destroy()
		 	return
	 	end
	ApplyDamage({victim = self:GetParent(),
	attacker = self:GetCaster(),
	damage_type = self:GetAbility():GetAbilityDamageType(),
	damage = self.tick_rate *  self.damage_sec,
	ability = self:GetAbility()})

	self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(self.lightning_particle)


	if self:GetCaster():HasScepter() then
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.scepter_range, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_CLOSEST, false)) do
			if (enemy ~= self:GetParent()) then
				self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(self.lightning_particle)

				ApplyDamage({
					victim 			= enemy,
					damage 			= self.tick_rate * self.scepter_dmg,
					damage_type = self:GetAbility():GetAbilityDamageType(),
					attacker 		= self:GetCaster(),
					ability 		= self:GetAbility()
				})
			end
		end
	end
end

function modifier_vader_lightning:OnDestroy()
		if not IsServer() then return end
		self:GetParent():StopSound("vader_lightning")
		
end