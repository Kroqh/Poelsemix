

LinkLuaModifier("modifier_mewtwo_psychic_kb", "heroes/hero_mewtwo/mewtwo_psychic", LUA_MODIFIER_MOTION_HORIZONTAL)
mewtwo_psychic = mewtwo_psychic or class({});


function mewtwo_psychic:GetCastRange()
	local range = self:GetSpecialValueFor("range")
	return range
end

function mewtwo_psychic:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_1"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_1"):GetSpecialValueFor("value") end
    return cd
end



function mewtwo_psychic:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():EmitSound("mewtwo_psychic");
    end
end
function mewtwo_psychic:OnVectorCastStart(vStartLocation, vDirection)
	if IsServer() then


		local caster 						= self:GetCaster();
		local point = vStartLocation
		local knockback_vector = vDirection
		local cast_vector = (point - caster:GetAbsOrigin()):Normalized()
		local ability = self

		local particle_radius 				= self:GetSpecialValueFor("particle_radius");
		local damage 						= self:GetSpecialValueFor("damage");
		local speed							= self:GetSpecialValueFor("projectile_speed")
		local range							= self:GetSpecialValueFor("range")
		local knockback_dist				= self:GetSpecialValueFor("knockback_dist")
		local knockback_time				= self:GetSpecialValueFor("knockback_time")
		local pierce_talent = self:GetCaster():FindAbilityByName("special_bonus_mewtwo_5"):GetLevel() > 0
		local target_type = ability:GetAbilityTargetType()

		if pierce_talent then
			target_type = target_type + DOTA_UNIT_TARGET_BASIC
		end

		ProjectileManager:CreateLinearProjectile(
		{
			vSpawnOrigin = caster:GetAbsOrigin(),
			fDistance = range,
			Ability 					= self,
			iSourceAttachment 			= DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 ,
			EffectName 					= "particles/econ/heroes/mewtwo/psychic/mewtwo_psychic.vpcf",
			fStartRadius = particle_radius,
			fEndRadius = particle_radius,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = target_type,
			iUnitTargetFlags = ability:GetAbilityTargetFlags(),
			bDeleteOnHit = true,
			Source = caster,
			vVelocity =   cast_vector * speed * Vector(1, 1, 0),
			bProvidesVision = false,
			ExtraData = 
				{damage 						= damage,
				knockback_dist 	 				= knockback_dist,
				point_1_x = self:GetCursorPosition().x,
				point_1_y = self:GetCursorPosition().y,
				point_2_x = point.x + vDirection.x,
				point_2_y = point.y + vDirection.y, --bruh why the fuck cant i just pass the vector instead of this shitty patchwork hack
				knockback_time = knockback_time,
				pierce_talent = pierce_talent
			}
			
		});	
	end
end



function mewtwo_psychic:OnProjectileHit_ExtraData(target, location, extra_data)
    if  not IsServer() then return end
	if not target then
		return nil
	end

   -- Ability properties
	local caster = self:GetCaster()

	-- Apply damage
	local damageTable = {victim = target,
		damage = extra_data.damage,
		damage_type = self:GetAbilityDamageType(),
		attacker = caster,
		ability = self
	}
	
	ApplyDamage(damageTable)
	EmitSoundOn("mewtwo_psychic_hit", target)
	target:AddNewModifier(caster, self, "modifier_mewtwo_psychic_kb", {point_1_x = extra_data.point_1_x,point_2_x = extra_data.point_2_x,point_1_y = extra_data.point_1_y,point_2_y = extra_data.point_2_y} )
	if  extra_data.pierce_talent ~= 1 then --booleans gets converted to int when passed through extra data for some reason
		return true
	else
		return false
	end
end

modifier_mewtwo_psychic_kb = modifier_mewtwo_psychic_kb or class ({})

function modifier_mewtwo_psychic_kb:IsPurgable() return	false end
function modifier_mewtwo_psychic_kb:IsHidden() return	false end
function modifier_mewtwo_psychic_kb:IsDebuff() return	true end
function modifier_mewtwo_psychic_kb:IgnoreTenacity() return true end
function modifier_mewtwo_psychic_kb:IsMotionController() return true end
function modifier_mewtwo_psychic_kb:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_mewtwo_psychic_kb:CheckState() --otherwise dash is cancelable, dont want that, needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
		return state
	end
end

function modifier_mewtwo_psychic_kb:OnCreated(keys)
	if not IsServer() then return end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local distance = ability:GetSpecialValueFor("knockback_dist")

		self.direction = (Vector(keys.point_2_x-keys.point_1_x,keys.point_2_y-keys.point_1_y)):Normalized()
		self.velocity = distance / ability:GetSpecialValueFor("knockback_time")
		self.distance_traveled = 0
		self.distance = distance

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
end

function modifier_mewtwo_psychic_kb:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
			return nil
		end

		self:HorizontalMotion(self:GetParent(), self.frametime)
	end
end

function modifier_mewtwo_psychic_kb:HorizontalMotion(me, dt)
	if IsServer() then
		local parent = self:GetParent()

		if self.distance_traveled < self.distance then
			parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
        else
    	
			self:Destroy()
		end
	end
end

function modifier_mewtwo_psychic_kb:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end
function modifier_mewtwo_psychic_kb:GetEffectName()
	return "particles/units/heroes/hero_mewtwo/mewtwo_psychic_hit.vpcf"
end