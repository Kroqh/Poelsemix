
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_marauder_cyclone", "heroes/hero_marauder/marauder_cyclone", LUA_MODIFIER_MOTION_NONE)


LinkLuaModifier("modifier_move_only", "heroes/hero_marauder/marauder_cyclone", LUA_MODIFIER_MOTION_NONE)
move_only = move_only or class({})

function move_only:GetIntrinsicModifierName()
    return "modifier_move_only"
end

modifier_move_only = modifier_move_only or class({})

function modifier_move_only:IsHidden() return true end
function modifier_move_only:IsPurgable() return false end
function modifier_move_only:IsPassive() return true end

function modifier_move_only:CheckState()
	local state = {
	    [MODIFIER_STATE_DISARMED] = true
	}
	return state
end




marauder_cyclone = marauder_cyclone or class({})

function marauder_cyclone:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function marauder_cyclone:GetIntrinsicModifierName()
	return "modifier_move_only"
end

function marauder_cyclone:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_marauder_cyclone", {})
	else
		caster:FindModifierByName("modifier_marauder_cyclone"):Destroy()
	end
end

modifier_marauder_cyclone = modifier_marauder_cyclone or class({})

function modifier_marauder_cyclone:IsHidden() return false end
function modifier_marauder_cyclone:IsPurgeable() return false end
function modifier_marauder_cyclone:ResetToggleOnRespawn()	return true end

function modifier_marauder_cyclone:DeclareFunctions()
	return {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_marauder_cyclone:GetSpinRate()
	local spinrate = self:GetParent():GetSecondsPerAttack(false) * (self:GetAbility():GetSpecialValueFor("attack_rate") / 100)
	return spinrate
end

function modifier_marauder_cyclone:OnCreated()
	if not IsServer() then return end
	local particle = "particles/heroes/marauder/cyclone_particle.vpcf"

	local caster = self:GetCaster()
	local parent = self:GetParent()

	local damage
	

	-- CONC EFFECT
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	parent:EmitSound("Hero_Juggernaut.BladeFuryStart")

	-- self.current_orientation = caster:GetForwardVector()
	self.pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(radius * 0.35, 0, 0))

	self.rate = self:GetSpinRate()
	parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_1, (1/self.rate) )
	self:StartIntervalThink(self.rate)
end

function modifier_marauder_cyclone:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_self_slow")
end

function modifier_marauder_cyclone:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetCaster()
	local radius = self:GetAbility():GetSpecialValueFor("radius")

	local damage_scaling = self:GetAbility():GetSpecialValueFor("damage_scaling") / 100

	local damage = damage_scaling * caster:GetAverageTrueAttackDamage(nil)
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									  parent:GetAbsOrigin(), 
									  nil, 
									  radius, 
									  self:GetAbility():GetAbilityTargetTeam(), 
									  self:GetAbility():GetAbilityTargetType(), 
									  self:GetAbility():GetAbilityTargetFlags(), 
									  FIND_ANY_ORDER, 
									  false)

	for _, enemy in pairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = parent,
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility()
		})

		-- VAAL CYCLONE stacks
		--vaal_cyclone_add_stack(caster)
	end
	-- AGHS
	if caster:HasScepter() then
		self:IceNova(self, enemies)
	end

	local rate = self:GetSpinRate()
	local rate_diff = math.abs(rate-self.rate)
	if rate_diff > 0.1 then --this almagamation ensures smooth anim with rapid attack rate changes
	self.rate = rate
	parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_1, (1/rate) )
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(radius * 0.35, 0, 0))
	self:StartIntervalThink(rate)
	end

	

	
end

--function vaal_cyclone_add_stack(caster)
--	local vaal_cyclone_spell = caster:FindAbilityByName("vaal_cyclone")
--	if vaal_cyclone_spell then
--		local vaal_cyclone_modifier = caster:FindModifierByName("modifier_vaal_cyclone_stack")
--		if vaal_cyclone_modifier then
--			local stacks = vaal_cyclone_modifier:GetStackCount()
--			if stacks < vaal_cyclone_spell:GetSpecialValueFor("stacks_needed") then
--				vaal_cyclone_modifier:IncrementStackCount()
--			end
--		end
--	end
--end

function modifier_marauder_cyclone:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	self:GetParent():StopSound("Hero_Juggernaut.BladeFuryStart")
	self:GetParent():EmitSound("Hero_Juggernaut.BladeFuryStop")
end

function modifier_marauder_cyclone:IceNova(self, enemies) 
	if not IsServer() then return end

	local particle = "particles/units/heroes/hero_marauder/cyclone_ice_nova.vpcf"
	local caster = self:GetCaster()
	local scaling = self:GetAbility():GetSpecialValueFor("scepter_ice_nova_damage_int_ratio")
	local damage = self:GetParent():GetIntellect(true) * scaling
	local radius = self:GetAbility():GetSpecialValueFor("scepter_ice_nova_radius")
	local chance = self:GetAbility():GetSpecialValueFor("scepter_ice_nova_chance")
	local damage_type = DAMAGE_TYPE_MAGICAL

	for _, enemy in pairs(enemies) do
		if RollPercentage(chance) then
			print("ice nova proc")
			caster:EmitSound("Hero_Crystal.CrystalNova")
			ApplyDamage({
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = damage_type,
				ability = self:GetAbility()
			})

			local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(pfx, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, Vector(radius, radius, radius))
			ParticleManager:SetParticleControl(pfx, 2, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)
			
		end
	end
end