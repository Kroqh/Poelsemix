
LinkLuaModifier("modifier_marauder_leap_slam", "heroes/hero_marauder/marauder_leap_slam", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marauder_leap_slam_fortify", "heroes/hero_marauder/marauder_leap_slam", LUA_MODIFIER_MOTION_NONE)
marauder_leap_slam = marauder_leap_slam or class({})


function marauder_leap_slam:GetCastRange()
	if IsClient() then --global range for server, but range visible for player
		local range = self:GetSpecialValueFor("range")
		return range
	end
end

function marauder_leap_slam:GetAOERadius()
	local range = self:GetSpecialValueFor("impact_radius")
	return range
end

function marauder_leap_slam:OnSpellStart() 
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:EmitSound("marauder_leap")
	local cyclone = caster:FindAbilityByName("marauder_cyclone")
	if cyclone ~= nil and cyclone:GetToggleState() then cyclone:ToggleAbility() end
	self.click_location = GetGroundPosition(caster:GetCursorPosition(), nil)
	if self.click_location == caster:GetAbsOrigin() then self.click_location = caster:GetAbsOrigin() + caster:GetForwardVector() * 100 end
	caster:AddNewModifier(caster, self, "modifier_marauder_leap_slam", {})
end

modifier_marauder_leap_slam = modifier_marauder_leap_slam or class({})

function modifier_marauder_leap_slam:IsPurgable() return	false end
function modifier_marauder_leap_slam:IsHidden() return	true end
function modifier_marauder_leap_slam:IgnoreTenacity() return true end
function modifier_marauder_leap_slam:IsMotionController() return true end
function modifier_marauder_leap_slam:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end


function modifier_marauder_leap_slam:CheckState()
	if not IsServer() then return end
	local state = {	[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true }
	return state
end

function modifier_marauder_leap_slam:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	self.click_location = ability.click_location
	local max_distance = ability:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
	local distance = (caster:GetAbsOrigin() - self.click_location ):Length2D()
	if distance > max_distance then distance = max_distance end
	self.direction = ( self.click_location - caster:GetAbsOrigin() ):Normalized()
	self.velocity = ability:GetSpecialValueFor("velocity")
	self.distance_traveled = 0
	self.distance = distance

	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, (self.velocity/distance))
	
	self:StartIntervalThink(FrameTime())
end

function modifier_marauder_leap_slam:OnIntervalThink()
	if not IsServer() then return end
	self:HorizontalMotion(self:GetParent(), FrameTime())
	self:VerticalMotion(self:GetParent(), FrameTime())
end

function modifier_marauder_leap_slam:HorizontalMotion(me, dt)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self.distance_traveled < self.distance then
		
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self.velocity * dt)
			self.distance_traveled = self.distance_traveled + self.velocity * dt
    else
			self:Destroy()	
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			self:marauder_leap_slam_damage(self, self.click_location)
    end
end

function modifier_marauder_leap_slam:VerticalMotion(me, dt)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local distance = self.velocity * dt
	local height = 0
	local height_change = 20

	if self.distance_traveled < self.distance / 2 then
		height = height_change
	else
		height = (-1 * height_change)
	end

	local new_pos = caster:GetAbsOrigin() + Vector(0,0,height)
	caster:SetAbsOrigin(new_pos)
end

function modifier_marauder_leap_slam:marauder_leap_slam_damage(self, click_location) 
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	local radius = ability:GetSpecialValueFor("impact_radius")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_type = ability:GetAbilityDamageType()


	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									  click_location, 
									  nil, 
									  radius, 
									  ability:GetAbilityTargetTeam(), 
									  ability:GetAbilityTargetType(), 
									  ability:GetAbilityTargetFlags(), 
									  FIND_ANY_ORDER, 
									  false)

	for _, enemy in pairs(enemies) do
		ApplyDamage({victim = enemy, 
				attacker = caster, 
				damage = damage, 
				damage_type = damage_type,
				ability = ability
			})
	end
	-- particle
	local particle = "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_leap_v2_impact_dust.vpcf"
	local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	
	-- sound
	caster:EmitSound("Hero_EarthShaker.Totem")
	local duration = ability:GetSpecialValueFor("fortify_duration")
	caster:AddNewModifier(caster, ability, "modifier_marauder_leap_slam_fortify", {duration = duration})
end

modifier_marauder_leap_slam_fortify = modifier_marauder_leap_slam_fortify or class({})

function modifier_marauder_leap_slam_fortify:IsHidden() return false end
function modifier_marauder_leap_slam:IsPurgable() return true end

function modifier_marauder_leap_slam_fortify:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
	return funcs
end

function modifier_marauder_leap_slam_fortify:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("fortify_armor")
end


function modifier_marauder_leap_slam_fortify:GetModifierPhysicalArmorBonus()
	return self.armor
end
function modifier_marauder_leap_slam_fortify:GetEffectName()
	return "particles/items2_fx/vindicators_axe_armor.vpcf"
end
