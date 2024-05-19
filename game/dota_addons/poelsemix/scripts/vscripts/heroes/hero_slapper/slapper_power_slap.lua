LinkLuaModifier("modifier_slapper_power_slap_knockup","heroes/hero_slapper/slapper_power_slap.lua",LUA_MODIFIER_MOTION_NONE)

slapper_power_slap = slapper_power_slap or class({})


function slapper_power_slap:GetCastRange()
	local range = self:GetSpecialValueFor("range")
	if self:GetCaster():HasModifier("modifier_slapper_rammusteinu") then range = range * self:GetSpecialValueFor("rammusteinu_range_multi") end
	return range
end

function slapper_power_slap:GetAOERadius()
	local value = self:GetSpecialValueFor("radius")
	return value
end


function slapper_power_slap:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
        local point = self:GetCursorPosition()
		local radius = self:GetSpecialValueFor("radius")
		local duration = self:GetSpecialValueFor("knockup_duration")
		local height = self:GetSpecialValueFor("knockup_height")
		local str_scale = self:GetSpecialValueFor("str_damage_scaling")
		local damage = self:GetSpecialValueFor("damage") + (caster:GetStrength() * str_scale)
		local particle = ""
		if self:GetCaster():HasModifier("modifier_slapper_rammusteinu") then
			EmitSoundOn("slapper_power_slap_rammusteinu", caster)
			particle = "particles/units/heroes/hero_slapper/power_slap_rammusteinu.vpcf"
		else
			EmitSoundOn("slapper_power_slap", caster)
			particle = "particles/units/heroes/hero_slapper/power_slap_normal.vpcf"
		end
        AddFOWViewer(caster:GetTeamNumber(), point, radius, 1, true)

		local particle_raze_fx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle_raze_fx, 0, point)
		ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(radius, 1, 1))
		ParticleManager:ReleaseParticleIndex(particle_raze_fx)

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityDamageType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

		for _, target in pairs(enemies) do
			target:AddNewModifier(caster, self, "modifier_knockback", {should_stun = 1, knockback_height = height, knockback_distance = 0, knockback_duration = duration,  duration = duration})
			ApplyDamage({victim = target,
			attacker = caster,
			damage_type = self:GetAbilityDamageType(),
			damage = damage,
			ability = self})

		end
	end
end




modifier_slapper_power_slap_knockup = modifier_slapper_power_slap_knockup or class({})

function modifier_slapper_power_slap_knockup:IsDebuff() return true end
function modifier_slapper_power_slap_knockup:IsHidden() return false end
function modifier_slapper_power_slap_knockup:IsPurgable() return false end
function modifier_slapper_power_slap_knockup:IsStunDebuff() return true end
function modifier_slapper_power_slap_knockup:IsMotionController()  return true end
function modifier_slapper_power_slap_knockup:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_slapper_power_slap_knockup:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	self:StartIntervalThink(FrameTime())
	if IsServer() then
		self:GetParent():StartGesture(ACT_DOTA_FLAIL)
		self.abs = self:GetParent():GetAbsOrigin()
		self.cyc_pos = self:GetParent():GetAbsOrigin()
	end
end

function modifier_slapper_power_slap_knockup:OnIntervalThink()
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_slapper_power_slap_knockup:HorizontalMotion(unit, time)
	if not IsServer() then return end
	-- Change the Face Angle
	-- Change the height at the first and last 0.3 sec
	if self:GetElapsedTime() <= 0.3 then
		self.cyc_pos.z = self.cyc_pos.z + 50
		self:GetParent():SetAbsOrigin(self.cyc_pos)
	elseif self:GetDuration() - self:GetElapsedTime() < 0.3 then
		self.step = self.step or (self.cyc_pos.z - self.abs.z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
		self.cyc_pos.z = self.cyc_pos.z - self.step
		self:GetParent():SetAbsOrigin(self.cyc_pos)
    end
end

function modifier_slapper_power_slap_knockup:OnDestroy()
	if not IsServer() then return end
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	self:GetParent():SetAbsOrigin(self.abs)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_slapper_power_slap_knockup:CheckState()
	local state =
		{
			[MODIFIER_STATE_STUNNED] = true,
		}
	return state
end
