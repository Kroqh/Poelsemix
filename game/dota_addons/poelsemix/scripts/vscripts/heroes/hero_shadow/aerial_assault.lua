aerial_assault = aerial_assault or class({})

LinkLuaModifier("modifier_mid_aerial", "heroes/hero_shadow/aerial_assault.lua", LUA_MODIFIER_MOTION_NONE)

function aerial_assault:OnSpellStart()
    if IsServer() then

        -- prevent double casting
        if self:GetCaster():FindModifierByName("modifier_mid_aerial") then
			self:RefundManaCost()
            self:EndCooldown()
			return
		end
        local caster = self:GetCaster()
		self.start_loc = caster:GetAbsOrigin()
        self.bounces = 0
		self.speed 			=	self:GetSpecialValueFor("slash_speed")
		self.damage 			= 	self:GetSpecialValueFor("damage_per_slash")
        local damage_radius 	= 	self:GetSpecialValueFor("hitbox")
        self.max_bounces          = self:GetSpecialValueFor("bounces")
        self.radius          =      self:GetSpecialValueFor("circle_radius")
        self.angle = RandomAngle()


        -- Play the cast sound
        EmitSoundOn("shadow_ult", caster)


        self.target_location = CalcNextLocation(self.start_loc, self.radius, self.angle)
        self.distance_to_location = CalcDistanceToLocation(self.target_location, self.start_loc)
        self.direction 	= (self.target_location - self.start_loc):Normalized()
        -- fire projectile
        self.projectile =
		{
			Ability				= self,
			vSpawnOrigin		= self.start_loc,
			fDistance			= self.distance_to_location,
			fStartRadius		= damage_radius,
			fEndRadius			= damage_radius,
			Source				= caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= self:GetAbilityTargetTeam(),
			iUnitTargetFlags	= self:GetAbilityTargetFlags(),
			iUnitTargetType		= self:GetAbilityTargetType(),
			bDeleteOnHit		= false,
			vVelocity 			= self.direction * self.speed * Vector(1, 1, 0),
			bProvidesVision		= true,
			iVisionRadius 		= vision,
			iVisionTeamNumber 	= caster:GetTeamNumber(),
			ExtraData			= {
                damage = self.damage
				--self.speed = self.speed * FrameTime()
			}
		}
        self.projectileID = ProjectileManager:CreateLinearProjectile(self.projectile)
        caster:FaceTowards(self.target_location)
        EmitSoundOn("shadow_slash", caster)
        caster:AddNewModifier(caster, self, "modifier_mid_aerial", {})
    end
end

function aerial_assault:OnProjectileThink_ExtraData(location, ExtraData)
    local caster = self:GetCaster()

    caster:SetAbsOrigin(Vector(location.x, location.y, GetGroundPosition(location, caster).z))
	caster:Purge(false, true, true, true, true)
end

function aerial_assault:OnProjectileHit_ExtraData(target, location, ExtraData)
    if IsServer() then
        local caster = self:GetCaster()
        if target then


            local damageTable = {
                victim = target,
				damage = ExtraData.damage,
				damage_type = self:GetAbilityDamageType(),
				attacker = self:GetCaster(),
				ability = self,
			}
            ApplyDamage(damageTable)
        end
        if  CalcDistanceToLocation(self.target_location, location) < 1 then
            if self.bounces < self.max_bounces then
                self.angle = RandomAngleOpposite(self.angle)
                self.target_location = CalcNextLocation(self.start_loc, self.radius, self.angle)
                self.distance_to_location = CalcDistanceToLocation(self.target_location, location)
                self.direction = (self.target_location - location):Normalized()
                self.projectile.direction = self.direction
                self.projectile.vSpawnOrigin = location
                self.projectile.fDistance = self.distance_to_location
                self.projectile.vVelocity = self.direction * self.speed * Vector(1, 1, 0)
                self.projectileID = ProjectileManager:CreateLinearProjectile(self.projectile)
                EmitSoundOn("shadow_slash", caster)
                caster:FaceTowards(self.target_location)
                self.bounces = self.bounces + 1
            elseif self.bounces == self.max_bounces then
                self.target_location = self.start_loc
                self.distance_to_location = CalcDistanceToLocation(self.target_location, location)
                self.direction = (self.target_location - location):Normalized()
                self.projectile.direction = self.direction
                self.projectile.vSpawnOrigin = location
                self.projectile.fDistance = self.distance_to_location
                self.projectile.vVelocity = self.direction * self.speed * Vector(1, 1, 0)
                self.projectileID = ProjectileManager:CreateLinearProjectile(self.projectile)
                caster:FaceTowards(self.target_location)
                EmitSoundOn("shadow_slash", caster)
                self.bounces = self.bounces + 1
            else
                if caster:FindModifierByName("modifier_mid_aerial") then
                    caster:FindModifierByName("modifier_mid_aerial"):Destroy()
                end
            end
        end
    end
end

modifier_mid_aerial = modifier_mid_aerial or class({})



function modifier_mid_aerial:DeclareFunctions()
	local funcs	=	{
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}
	return funcs
end
--particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_trigger_elec.vpcf
function modifier_mid_aerial:OnCreated()
    self.partfire = "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_ambient_trail.vpcf"
    self.pfx = ParticleManager:CreateParticle(self.partfire, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    self.partfire = "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_trigger_elec.vpcf"
    self.pfx2 = ParticleManager:CreateParticle(self.partfire, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
end
function modifier_mid_aerial:OnDestroy()
    ParticleManager:DestroyParticle(self.pfx, false)
    ParticleManager:DestroyParticle(self.pfx2, false)
end
function modifier_mid_aerial:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_mid_aerial:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_mid_aerial:GetAbsoluteNoDamagePure()
	return 1
end

-- Modifier properties
function modifier_mid_aerial:IsDebuff() 	return false end
function modifier_mid_aerial:IsHidden() 	return true end
function modifier_mid_aerial:IsPurgable() return false end

function RandomAngle()
    return math.random()*math.pi*2; 
end

function RandomAngleOpposite(angle)
   return angle - math.random(-20, 20)
end

function CalcNextLocation(startpos, radius, angle)
    x = math.cos(angle)*radius;
    y = math.sin(angle)*radius;
    return Vector(startpos.x + x, startpos.y + y, startpos.z)
end

function CalcDistanceToLocation(endpos, startpos)
        return (startpos-endpos):Length2D()
end