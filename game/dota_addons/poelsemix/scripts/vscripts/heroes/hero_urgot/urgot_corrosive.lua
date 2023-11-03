LinkLuaModifier("modifier_urgot_corrosive", "heroes/hero_urgot/urgot_corrosive", LUA_MODIFIER_MOTION_NONE)


urgot_corrosive = urgot_corrosive or class({})


function urgot_corrosive:GetCastRange()
    local value = self:GetSpecialValueFor("cast_range") 
    return value
end
function urgot_corrosive:GetAOERadius()
    local value = self:GetSpecialValueFor("radius") 
    return value
end
function urgot_corrosive:GetCooldown(level)
	if IsServer() then
		if self:GetCaster():HasTalent("special_bonus_urgot_e_reduc") then
			return self.BaseClass.GetCooldown(self,level)/2
		else
			return self.BaseClass.GetCooldown(self,level)
		end
	end

end

function urgot_corrosive:OnSpellStart()
	if IsServer() then
	local caster		= self:GetCaster()
	local point 		= self:GetCursorPosition()
	local ability		= self


	EmitSoundOn("urgotEshoot", caster)

	-- Projectile
	local distance = (caster:GetAbsOrigin()-point):Length2D()

	local info =
		{
			vSpawnOrigin = caster:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1),
			Source = caster,
			Ability = ability,
			fDistance = distance,
			vVelocity = (((point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * self:GetSpecialValueFor("proj_speed"),
			EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
			bVisibleToEnemies = true,						-- Optional
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
	ProjectileManager:CreateLinearProjectile(info)
	end
end



function urgot_corrosive:OnProjectileHit( hTarget, vLocation)
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local location = vLocation
	if hTarget then
		location = hTarget:GetAbsOrigin()
	end

	local pfx_explosion = ParticleManager:CreateParticle("particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx_explosion, 0, location)

	Timers:CreateTimer(1, function()
		ParticleManager:DestroyParticle(pfx_explosion, false)
		ParticleManager:ReleaseParticleIndex(pfx_explosion)
	end)


	EmitSoundOnLocationWithCaster(location, "urgotEHit", caster)

	local units = FindUnitsInRadius(caster:GetTeamNumber(),
		location,
		nil,
		self:GetSpecialValueFor("radius"),
		self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),
		self:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,
		false)
	for _,unit in pairs(units) do
		if unit ~= caster then
			if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
				unit:AddNewModifier(caster, self, "modifier_urgot_corrosive", {duration = self:GetSpecialValueFor("duration")} )
			end
		end
	end
	return true
end


modifier_urgot_corrosive = modifier_urgot_corrosive or class({})

function modifier_urgot_corrosive:IsDebuff()			return true  end
function modifier_urgot_corrosive:IsHidden() 			return false end
function modifier_urgot_corrosive:IsPurgable() 		return true  end
function modifier_urgot_corrosive:IsPurgeException() 	return true  end
function modifier_urgot_corrosive:IsStunDebuff() 		return false end
function modifier_urgot_corrosive:RemoveOnDeath() 		return true  end

function modifier_urgot_corrosive:GetTexture()
	return "urgotE"
end

function modifier_urgot_corrosive:GetEffectName() return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff_c.vpcf" end
function modifier_urgot_corrosive:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end


function modifier_urgot_corrosive:OnCreated()
    local ability = self:GetAbility()
    self.armor_reduc = self:GetParent():GetPhysicalArmorValue(false) * (ability:GetSpecialValueFor("armor_reduction_pct") / 100)
	if not IsServer() then
		return
	end
	
	local tick = ability:GetSpecialValueFor("tick_interval")
	self:StartIntervalThink( tick )
end


function modifier_urgot_corrosive:OnIntervalThink()
	if not IsServer() then
		return
	end
	if not self:GetParent():IsAlive() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local tick = ability:GetSpecialValueFor("tick_interval")
	local dmg = ability:GetSpecialValueFor("damage_per_second") / tick
	local damageTable = {
		victim = self:GetParent(),
		attacker = caster,
		damage = dmg,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
	}
	ApplyDamage(damageTable)
end

function modifier_urgot_corrosive:DeclareFunctions()
	local func = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
	return func
end

function modifier_urgot_corrosive:GetModifierPhysicalArmorBonus()
        if self.armor_reduc ~= nil then
		    return -self.armor_reduc
        end
end

