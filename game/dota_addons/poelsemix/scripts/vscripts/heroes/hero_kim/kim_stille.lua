LinkLuaModifier("modifier_stille_cast", "heroes/hero_kim/kim_stille", LUA_MODIFIER_MOTION_NONE)
kim_stille = kim_stille or class({})
--thanks dota imba for the tutorial luv u mwah hehe xd
function kim_stille:GetAbilityTextureName()
	return "kim_stille"
end

function kim_stille:OnSpellStart()
	local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_stille_cast", {})
    
end

function kim_stille:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
	return true
end

modifier_stille_cast = class ({})

function modifier_stille_cast:IsPurgable() return	false end
function modifier_stille_cast:IsHidden() return	true end
function modifier_stille_cast:IgnoreTenacity() return true end
function modifier_stille_cast:IsMotionController() return true end
function modifier_stille_cast:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_stille_cast:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end

function modifier_stille_cast:OnCreated()
	if not IsServer() then return end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster:EmitSound("kim_stille")
		local max_distance = ability:GetSpecialValueFor("range") + GetCastRangeIncrease(caster)
	
		
		local distance = (caster:GetAbsOrigin() - caster:GetCursorPosition() ):Length2D()
		if distance > max_distance then distance = max_distance end

		self.direction = ( caster:GetCursorPosition() - caster:GetAbsOrigin() ):Normalized()
		self.velocity = ability:GetSpecialValueFor("velocity")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
end

function modifier_stille_cast:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end

		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_stille_cast:HorizontalMotion(me, dt)
	if IsServer() then
		local caster = self:GetCaster()

		if self.distance_traveled < self.distance then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
        else
			
    		local ability = self:GetAbility()
			local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY 
			local target_types = DOTA_UNIT_TARGET_ALL 
			local target_flags = DOTA_UNIT_TARGET_FLAG_NONE 
			local radius = ability:GetSpecialValueFor("radius")
			local projectile_speed = ability:GetSpecialValueFor("velocity_projectile")


			local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)
			for _, enemy in  pairs(units) do

				local  bolt_projectile = {Target = enemy,
							  Source = caster,
							  Ability = ability,
							  EffectName = "particles/units/heroes/hero_enigma/enigma_base_attack.vpcf",
							  iMoveSpeed = projectile_speed,
							  bDodgeable = false, 
							  bVisibleToEnemies = true,
							  bReplaceExisting = false,
							  bProvidesVision = true,
							  iVisionRadius = 20,
							  iVisionTeamNumber = caster:GetTeamNumber()
	}

				ProjectileManager:CreateTrackingProjectile(bolt_projectile)  
				
				
				
				
    		end
			self:Destroy()
		end
	end
end

function kim_stille:OnProjectileHit(target, location)
	if not IsServer() then return end
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		ApplyDamage({victim = target, attacker = caster, damage = self:GetSpecialValueFor("dmg"), damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(caster, self, "modifier_stille_silence", {duration = duration})
end

function modifier_stille_cast:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
		end)
	end
end


LinkLuaModifier("modifier_stille_silence", "heroes/hero_kim/kim_stille", LUA_MODIFIER_MOTION_NONE)
modifier_stille_silence = modifier_stille_silence or class({})

function modifier_stille_silence:IsDebuff() return true end

function modifier_stille_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_stille_silence:CheckState()
	local state = {[MODIFIER_STATE_SILENCED] = true}
	return state
end

function modifier_stille_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
