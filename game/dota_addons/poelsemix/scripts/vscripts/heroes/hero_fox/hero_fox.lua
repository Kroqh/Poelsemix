--Q
------------------------------------
-----    LASER           XD     -----
------------------------------------
fox_laser = fox_laser or class({})

--------------------------------------------------------------------------------
-- Ability Start
function fox_laser:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local point = self:GetCursorPosition()

	-- load data
	local projectile_name = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf"
	local projectile_speed = self:GetSpecialValueFor("arrow_speed")
	local projectile_distance = self:GetSpecialValueFor("arrow_range")
	local projectile_start_radius = self:GetSpecialValueFor("arrow_width")
	local projectile_end_radius = self:GetSpecialValueFor("arrow_width")
	local projectile_vision = self:GetSpecialValueFor("arrow_vision")

	local min_damage = self:GetAbilityDamage()
	local bonus_damage = self:GetSpecialValueFor( "arrow_bonus_damage" )
	local min_stun = self:GetSpecialValueFor( "arrow_min_stun" )
	local max_stun = self:GetSpecialValueFor( "arrow_max_stun" )
	local max_distance = self:GetSpecialValueFor( "arrow_max_stunrange" )

	local projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

	-- logic
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin(),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius =projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = caster:GetTeamNumber(),

		ExtraData = {
			originX = origin.x,
			originY = origin.y,
			originZ = origin.z,

			max_distance = max_distance,
			min_stun = min_stun,
			max_stun = max_stun,

			min_damage = min_damage,
			bonus_damage = bonus_damage,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- Effects
	local sound_cast = "Hero_Mirana.ArrowCast"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function fox_laser:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if hTarget==nil then return end

	-- calculate distance percentage
	local origin = Vector( extraData.originX, extraData.originY, extraData.originZ )
	local distance = (vLocation-origin):Length2D()
	local bonus_pct = math.min(1,distance/extraData.max_distance)

	-- damage
	if (not hTarget:IsConsideredHero()) and (not hTarget:IsAncient()) and (not hTarget:IsMagicImmune()) then
		local damageTable = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = hTarget:GetHealth() + 1,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, --Optional.
		}
		ApplyDamage(damageTable)
		return true
	end

	local damageTable = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = extraData.min_damage + extraData.bonus_damage*bonus_pct,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- stun

	AddFOWViewer( self:GetCaster():GetTeamNumber(), vLocation, 500, 3, false )

	-- effects
	local sound_cast = "Hero_Mirana.ArrowImpact"
	EmitSoundOn( sound_cast, hTarget )

	return true
end

--W
-------------------------------------------
--      SPELL SHIELD
-------------------------------------------
fox_shine = fox_shine or class({})

LinkLuaModifier("modifier_shield", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shine_stun", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)


function fox_shine:OnSpellStart()
	local caster = self:GetCaster()
	local caster_pos = caster:GetAbsOrigin()
	local ability = self
	local duration = 30
	local shield_health = 100
	local radius = 1000
	local mini_stun = 0.25
	
	--Refelct modifier
	caster:AddNewModifier(caster, self, "modifier_shield", {duration = duration})

	--AOE damage
	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = ability:GetAbilityTargetFlags() 

	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,unit in ipairs(heroes) do
		print('unit: ', unit)
		ApplyDamage({victim = unit, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = 100, ability = ability})
		unit:AddNewModifier(caster, ability, "modifier_shine_stun", {duration = mini_stun})
	end
end

modifier_shine_stun = modifier_shine_stun or class({})

function modifier_shine_stun:IsPurgeable() return false end
function modifier_shine_stun:IsHidden() return false end

function modifier_shine_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"

end

function modifier_shine_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_shine_stun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end


modifier_shield = modifier_shield or class({})

function modifier_shield:IsHidden()		return false end
function modifier_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_REFLECT_SPELL 
	}
end

function modifier_shield:GetReflectSpell(params)
	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()

	-- Does not reflect allies' projectiles for any reason
	if target:GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return nil
	end

	if not target:HasModifier("modifier_imba_spell_shield_buff_reflect") then
		-- If this is a reflected ability, do nothing
		if params.ability.spell_shield_reflect then
			return nil
		end

		local pfx = ParticleManager:CreateParticle(self.reflect_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)

		local ability = self:GetParent():AddAbility(reflected_spell_name)
		ability:SetStolen(true)
		ability:SetHidden(true)

		-- Tag ability as a reflection ability
		ability.spell_shield_reflect = true

		-- Modifier counter, and add it into the old-spell list
		ability:SetRefCountsModifiers(true)

		ability:SetLevel(params.ability:GetLevel())
		-- Set target & fire spell
		self:GetParent():SetCursorCastTarget(target)

		if ability:GetToggleState() then
			ability:ToggleAbility()
		end

		ability:OnSpellStart()
		
		-- This isn't considered vanilla behavior, but at minimum it should resolve any lingering channeled abilities...
		if ability.OnChannelFinish then
			ability:OnChannelFinish(false)
		end	
	end

	return false
end


--E
------------------------------------
-----    DASH           XD     -----
------------------------------------
fox_dash = fox_dash or class({})

LinkLuaModifier("modifier_wave_cast", "heroes/hero_fox/hero_fox", LUA_MODIFIER_MOTION_NONE)

--thanks dota imba for the tutorial luv u mwah hehe xd
function fox_dash:GetAbilityTextureName()
	return "shimakaze_wave"
end

function fox_dash:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_wave_cast", {})
	self:EmitSound("shimakaze_wave")
end

function fox_dash:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
	return true
end

modifier_wave_cast = class ({})

function modifier_wave_cast:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_wave_cast:IsPurgable() return	false end
function modifier_wave_cast:IsHidden() return	true end
function modifier_wave_cast:IgnoreTenacity() return true end
function modifier_wave_cast:IsMotionController() return true end
function modifier_wave_cast:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_wave_cast:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true, }
		return state
	end
end

function modifier_wave_cast:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local range = 500
		local velocity = 5000

		local max_distance = range + GetCastRangeIncrease(caster)
		
		print(max_distance)
		local distance = (caster:GetAbsOrigin() - caster:GetCursorPosition() ):Length2D()
		if distance > max_distance then distance = max_distance end

		self.direction = ( caster:GetCursorPosition() - caster:GetAbsOrigin() ):Normalized()
		self.velocity = velocity
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
	end
end
local dashHasHitEnemy = false

function modifier_wave_cast:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local aoe = 50

		-- Slow enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for _,enemy in pairs(enemies) do
			-- If the enemy is a real hero index their move and attack speed, and grant a chronocharge
			if enemy:IsRealHero() and dashHasHitEnemy == false then
				hasHitEnemy = true
				print('Skal reduce')
				print(caster:GetAbilityByIndex(1):EndCooldown())
			end

			-- Play hit particle only on hit heroes, and their illusions to prevent the caster from finding the real hero with this skill.
			if enemy:IsHero() then
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack02.vpcf", PATTACH_ABSORIGIN, enemy)
				ParticleManager:SetParticleControl(particle, 0, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
			end

			-- Apply the slow
		end

		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end
		
		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_wave_cast:HorizontalMotion(me, dt)
	if IsServer() then
		local caster = self:GetCaster()

		if self.distance_traveled < self.distance then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
		else
			self:Destroy()
		end
	end
end

function modifier_wave_cast:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		dashHasHitEnemy = false
		Timers:CreateTimer(0.1, function()

			-- Stop the casting animation and remove caster modifier
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
		end)
	end
end