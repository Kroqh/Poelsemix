musashi_fire = musashi_fire  or class({})
LinkLuaModifier("modifier_musashi_fire_slashes", "heroes/hero_musashi/musashi_fire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_musashi_fire_burn", "heroes/hero_musashi/musashi_fire", LUA_MODIFIER_MOTION_NONE)

function musashi_fire :GetCastRange()
	return self:GetSpecialValueFor("range")
end


function musashi_fire :OnSpellStart()
	-- Preventing projectiles getting stuck in one spot due to potential 0 length vector
	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end

	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local point = caster:GetCursorPosition()

	local attack_modifier = "modifier_musashi_fire_slashes"

	-- Ability specials
	local range = ability:GetSpecialValueFor("range")

	local direction = (point - caster:GetAbsOrigin()):Normalized()

	caster:SetForwardVector(direction)

	-- Play cast sound

	--Begin moving to target point
	caster:AddNewModifier(caster, ability, attack_modifier, {})
    --Pass the targeted point to the modifier
	local modifier_movement_handler = caster:FindModifierByName(attack_modifier)
	modifier_movement_handler.target = point
end


--attack modifier: will handle the slashes
modifier_musashi_fire_slashes = modifier_musashi_fire_slashes or class({})

function modifier_musashi_fire_slashes:IsHidden()	return true end
function modifier_musashi_fire_slashes:IsPurgable() return	false end


function modifier_musashi_fire_slashes:OnCreated()
	--Ability properties
	self.debuff = "modifier_imba_swashbuckle_burn"
	self.particle = "particles/units/heroes/hero_musashi/musashi_fire.vpcf"
	self.hit_particle = "particles/generic_gameplay/generic_hit_blood.vpcf"
	self.slashing_sound = "Hero_Pangolier.Swashbuckle"
	self.hit_sound= "Hero_Pangolier.Swashbuckle.Damage"
	self.slash_particle = {}
	--Ability specials
	self.range = self:GetAbility():GetSpecialValueFor("range")
	self.damage = self:GetAbility():GetSpecialValueFor("damage_per_slash_physical")
	self.start_radius = self:GetAbility():GetSpecialValueFor("radius")
	self.end_radius = self:GetAbility():GetSpecialValueFor("radius")
	self.strikes = self:GetAbility():GetSpecialValueFor("strikes")
	self.attack_interval = self:GetAbility():GetSpecialValueFor("attack_interval")
	self.debuff_duration = self:GetAbility():GetSpecialValueFor("burn_duration")

    if self:GetCaster():FindAbilityByName("special_bonus_musashi_6"):GetLevel() > 0 then
        self.debuff_duration = self.debuff_duration + self:GetCaster():FindAbilityByName("special_bonus_musashi_6"):GetSpecialValueFor("value")
    end
    if self:GetCaster():FindAbilityByName("special_bonus_musashi_7"):GetLevel() > 0 then
        self.strikes = self.strikes + self:GetCaster():FindAbilityByName("special_bonus_musashi_7"):GetSpecialValueFor("value")
        self.attack_interval = self.attack_interval + self:GetCaster():FindAbilityByName("special_bonus_musashi_7"):GetSpecialValueFor("value_two")
    end


	if IsServer() then
		--variables
		self.executed_strikes = 0

		--wait one frame to acquire the target from the ability
		Timers:CreateTimer(FrameTime(), function()
			self.direction = nil -- needed for the particle
			if self.target then
				self.direction = (self.target - self:GetCaster():GetAbsOrigin()):Normalized()
				self.fixed_target = self:GetCaster():GetAbsOrigin() + self.direction * self.range -- will lock the targeting on the direction of the target on-cast
			else --no units found
				self.direction = self:GetCaster():GetForwardVector():Normalized()
				self.fixed_target = self:GetCaster():GetAbsOrigin() + self.direction * self.range
			end

			--start interval thinker
			self:StartIntervalThink(0)
		end)
	end
end

function modifier_musashi_fire_slashes:DeclareFunctions()
	local declfuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}

	return declfuncs
end

function modifier_musashi_fire_slashes:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function modifier_musashi_fire_slashes:OnIntervalThink()
	if IsServer() then

		if self.executed_strikes == self.strikes then
			self:Destroy()
			return nil
		end

        local caster = self:GetCaster()
	    local ability = self:GetAbility()

		--play slashing particle
		self.slash_particle[self.executed_strikes] = ParticleManager:CreateParticle(self.particle, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.slash_particle[self.executed_strikes], 0, caster:GetAbsOrigin()) --origin of particle
		ParticleManager:SetParticleControl(self.slash_particle[self.executed_strikes], 1, self.direction * self.range) --direction and range of the subparticles


		--plays the attack sound
		EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), self.slashing_sound, self:GetCaster())

		--Check for enemies in the direction set on cast
		local enemies = FindUnitsInLine(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			self.fixed_target,
			nil,
			self.start_radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags()
		)

		for _,enemy in pairs(enemies) do
			--Play damage sound effect
			EmitSoundOn(self.hit_sound, enemy)


				--Play blood particle on targets
				local blood_particle = ParticleManager:CreateParticle(self.hit_particle, PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(blood_particle, 0, enemy:GetAbsOrigin()) --origin of particle
				ParticleManager:SetParticleControl(blood_particle, 2, self.direction * 500) --direction and speed of the blood spills

				-- --Apply the damage from the slash
				 local damageTable = {victim = enemy,
					 damage = self.damage,
					 damage_type = DAMAGE_TYPE_PHYSICAL,
					 damage_flags = DOTA_DAMAGE_FLAG_NONE,
					attacker = caster,
					ability = ability
				 }

                 local mod = enemy:FindModifierByNameAndCaster("modifier_musashi_fire_burn",caster)
                if mod ~= nil then
                    mod:SetStackCount(mod:GetStackCount()+1)
                else
                    enemy:AddNewModifier(caster, ability, "modifier_musashi_fire_burn", {duration = self.debuff_duration})
                    mod = enemy:FindModifierByNameAndCaster("modifier_musashi_fire_burn",caster)
                    mod:SetStackCount(1)
                end

				ApplyDamage(damageTable)
				--SendOverheadEventMessage(self:GetCaster(), OVERHEAD_ALERT_DAMAGE, enemy, self.damage, nil)


		end

		--increment the slash counter
		self.executed_strikes = self.executed_strikes + 1
        self:StartIntervalThink(self.attack_interval)
	end
end

function modifier_musashi_fire_slashes:OnRemoved()
	if IsServer() then
		--remove slash particle instances
		for k,v in pairs(self.slash_particle) do
			ParticleManager:DestroyParticle(v, false)
			ParticleManager:ReleaseParticleIndex(v)
		end
	end
end

function modifier_musashi_fire_slashes:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end


modifier_musashi_fire_burn = modifier_musashi_fire_burn or class({})

function modifier_musashi_fire_burn:IsHidden()		return false end
function modifier_musashi_fire_burn:IsDebuff()		return true end


function modifier_musashi_fire_burn:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		self.damage = ability:GetSpecialValueFor("damage_per_burn_magical")
		local tick = ability:GetSpecialValueFor("burn_tick_rate")
		self:StartIntervalThink(tick-0.1)
	end
end

function modifier_musashi_fire_burn:OnIntervalThink()
	if IsServer() then
		local target = self:GetParent()
		local caster = self:GetCaster()
        --calc damage
        local damage = self.damage * self:GetStackCount()
		ApplyDamage({victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = damage,
		ability = self:GetAbility()
		})
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("burn_tick_rate"))
	end
end


function modifier_musashi_fire_burn:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_musashi_fire_burn:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_burning_army_ambient.vpcf"
end