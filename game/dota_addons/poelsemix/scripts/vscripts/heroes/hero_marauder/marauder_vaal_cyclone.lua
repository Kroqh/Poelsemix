
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_marauder_vaal_cyclone", "heroes/hero_marauder/marauder_vaal_cyclone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vaal_cyclone_stack", "heroes/hero_marauder/marauder_vaal_cyclone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marauder_vaal_cyclone_suck", "heroes/hero_marauder/marauder_vaal_cyclone", LUA_MODIFIER_MOTION_NONE)

marauder_vaal_cyclone = marauder_vaal_cyclone or class({})

function marauder_vaal_cyclone:GetIntrinsicModifierName()
	return "modifier_vaal_cyclone_stack"
end

function marauder_vaal_cyclone:GetBehavior()
	if self:GetCaster():FindAbilityByName("special_bonus_marauder_5"):GetLevel() > 0 then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function marauder_vaal_cyclone:CastFilterResult()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local modifier = "modifier_vaal_cyclone_stack"
	local max_stacks = self:GetSpecialValueFor("stacks_needed")

	local current_stacks = caster:GetModifierStackCount(modifier, caster)
	if current_stacks >= max_stacks then
		caster:FindModifierByName("modifier_vaal_cyclone_stack"):SetStackCount(0)

		local cyclone_spell = caster:FindAbilityByName("marauder_cyclone")
		if cyclone_spell:GetToggleState() then
			cyclone_spell:ToggleAbility()
		end

		return UF_SUCCESS
	end
	
	return UF_FAIL_CUSTOM
end

function marauder_vaal_cyclone:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

function marauder_vaal_cyclone:GetCustomCastError()
	return "NOT ENOUGH STACKS"
end

function marauder_vaal_cyclone:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_marauder_vaal_cyclone", {outgoing = 1,duration = duration})
	caster:AddNewModifier(caster, self, "modifier_marauder_vaal_cyclone_suck", {duration = duration})
end

function marauder_vaal_cyclone:OnChannelFinish()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_marauder_vaal_cyclone")
	caster:RemoveModifierByName("modifier_marauder_vaal_cyclone_suck")
end


function marauder_vaal_cyclone:GetCastRange()
	return self:GetActualRadius()
end

function marauder_vaal_cyclone:GetActualRadius()
	local radius = self:GetSpecialValueFor("radius")
	local multi = 1
	if self:GetCaster():HasModifier("modifier_marauder_blood_rage") then multi = multi + (self:GetCaster():FindAbilityByName("marauder_blood_rage"):GetIncreaser()) end
	radius = radius * multi
	return radius
end


modifier_marauder_vaal_cyclone = modifier_marauder_vaal_cyclone or class({})

function modifier_marauder_vaal_cyclone:IsHidden() return false end
function modifier_marauder_vaal_cyclone:IsPurgable() return false end


function modifier_marauder_vaal_cyclone:CalcDamageScaling()
	local damage = self:GetAbility():GetSpecialValueFor("damage_scaling") / 100

	local multi = 1
	if self:GetParent():HasModifier("modifier_marauder_blood_rage") then multi = multi + (self:GetCaster():FindAbilityByName("marauder_blood_rage"):GetIncreaser()) end
	damage = damage * multi * self.outgoing_multi
	return damage
end


function modifier_marauder_vaal_cyclone:GetSpinRate()
	local spinrate = self:GetParent():GetSecondsPerAttack(false) * (self:GetAbility():GetSpecialValueFor("attack_rate") / 100)

	local multi = 1
	if self:GetParent():HasModifier("modifier_marauder_blood_rage") then multi = multi - (self:GetCaster():FindAbilityByName("marauder_blood_rage"):GetIncreaser()) end
	spinrate = spinrate * multi

	return spinrate
end

function modifier_marauder_vaal_cyclone:OnCreated(kv)
	if not IsServer() then return end
	local particle = "particles/heroes/marauder/vaal_cyclone.vpcf"
	self.outgoing_multi = kv.outgoing
	local caster = self:GetCaster()
	local parent = self:GetParent()

	local damage
	

	-- CONC EFFECT
	local radius = self:GetAbility():GetActualRadius()
	parent:EmitSound("Hero_Juggernaut.BladeFuryStart")

	-- self.current_orientation = caster:GetForwardVector()
	self.pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(radius * 0.35, 0, 0))

	self.rate = self:GetSpinRate()
	parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_2, (1/self.rate) )
	self:StartIntervalThink(self.rate)
end

function modifier_marauder_vaal_cyclone:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local radius = self:GetAbility():GetActualRadius()
	local damage = self:CalcDamageScaling() * caster:GetAverageTrueAttackDamage(nil)
	
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
	end

	local rate = self:GetSpinRate()
	local rate_diff = math.abs(rate-self.rate)
	if rate_diff > 0.1 then --this almagamation ensures smooth anim with rapid attack rate changes
	self.rate = rate
	parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_2)
	parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_2, (1/rate) )
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(radius * 0.35, 0, 0))
	self:StartIntervalThink(rate)
	end

	

	
end

function modifier_marauder_vaal_cyclone:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, true)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_2)
	self:GetParent():StopSound("Hero_Juggernaut.BladeFuryStart")
	self:GetParent():EmitSound("Hero_Juggernaut.BladeFuryStop")
end

modifier_vaal_cyclone_stack = modifier_vaal_cyclone_stack or class({})

function modifier_vaal_cyclone_stack:IsHidden() return false end
function modifier_vaal_cyclone_stack:IsPurgable() return false end
function modifier_vaal_cyclone_stack:IsPassive() return true end




modifier_marauder_vaal_cyclone_suck = modifier_marauder_vaal_cyclone_suck or class({})

function modifier_marauder_vaal_cyclone_suck:IsHidden() return true end
function modifier_marauder_vaal_cyclone_suck:IsPurgable() return false end


function modifier_marauder_vaal_cyclone_suck:OnCreated(kv)
	if not IsServer() then return end
	self.pull_amount = self:GetAbility():GetSpecialValueFor("pull_distance") / 100
	self:StartIntervalThink(0.05)
end

function modifier_marauder_vaal_cyclone_suck:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local radius = self:GetAbility():GetActualRadius()
	local parent_pos = parent:GetAbsOrigin()
	
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
		if not enemy:IsCurrentlyHorizontalMotionControlled() or enemy:IsCurrentlyVerticalMotionControlled() then
			local enemy_pos = enemy:GetAbsOrigin()
			local direction = (parent_pos - enemy_pos)
			FindClearSpaceForUnit(enemy, enemy_pos + direction * self.pull_amount, true)
		end
	end
	

	
end