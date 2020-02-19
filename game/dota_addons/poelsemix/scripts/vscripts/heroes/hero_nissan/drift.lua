LinkLuaModifier("modifier_drift_dummy", "heroes/hero_nissan/drift", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drift_burn", "heroes/hero_nissan/drift", LUA_MODIFIER_MOTION_NONE)
drift = class({})

function drift:GetAbilityTextureName()
	return "nissan_drift_icon"
end

function drift:GetCastPoint()
	local caster = self:GetCaster()

	return self:GetSpecialValueFor("cast_point")
end

modifier_drift_dummy = class({})

function modifier_drift_dummy:IsHidden() return true end

modifier_drift_burn = class({})

function modifier_drift_burn:GetEffectName() return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf" end
function modifier_drift_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_drift_burn:OnCreated()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = self:GetCaster()

	self.damage = ability:GetSpecialValueFor("damage_per_second")

	-- Talent
	if caster:HasTalent("special_bonus_nissan_3") then
    self.damage = self.damage + caster:FindAbilityByName("special_bonus_nissan_3"):GetSpecialValueFor("value")
  end

	self.tick = ability:GetSpecialValueFor("burn_tick_interval")
	self:StartIntervalThink(self.tick)
end

function modifier_drift_burn:OnIntervalThink()
	if not IsServer() then return end

	local target = self:GetParent()
	local caster = self:GetCaster()

	ApplyDamage({
				victim = target,
				attacker = caster,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage = self.damage,
				ability = self:GetAbility()
	})
end

function drift:OnSpellStart()
	if IsServer() ~= true then return end

	self:GetCaster():EmitSound("nissan_drift")

	--local ability = self:GetAbility()
	local radius = self:GetSpecialValueFor("hit_radius")
	local burn_duration = self:GetSpecialValueFor("burn_duration")

	local caster = self:GetCaster()
	local target_pos = self:GetCursorPosition()
	local caster_pos = caster:GetAbsOrigin()

	local dash_length = self:GetSpecialValueFor("dash_length")
	local dash_width = self:GetSpecialValueFor("dash_width")
	local dash_duration = self:GetSpecialValueFor("dash_duration")

	-- Talent
  if caster:HasTalent("special_bonus_nissan_2") then
    dash_duration = dash_duration + caster:FindAbilityByName("special_bonus_nissan_2"):GetSpecialValueFor("value")
  end

	local direction = (target_pos - caster_pos):Normalized()

	caster:SetForwardVector(direction)

	local forward_direction = caster:GetForwardVector()
  local right_direction = caster:GetRightVector()
  local caster_angles = caster:GetAngles()

	local start_time = GameRules:GetGameTime()
	local ellipse_center = caster_pos + forward_direction * (dash_length / 2)

	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf", PATTACH_WORLDORIGIN, nil )

  caster:AddNewModifier(caster, self, "modifier_drift_dummy", {duration = dash_duration})

	caster:SetContextThink(DoUniqueString("drift_update"), function() 
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin() + caster:GetRightVector() * 32 )
		if not caster:HasModifier("modifier_drift_dummy") then
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)
			caster:SetAbsOrigin(caster_pos)
	    return nil 
		end
		-- ellipse calculations
		local elapsed_time = GameRules:GetGameTime() - start_time
		local progress = elapsed_time / dash_duration

		self.progress = progress
		-- thanks dota imba for fixing
		local t = -dash_duration * math.pi * progress
		local x = math.sin(t) * dash_width  * 0.5
		local y = -math.cos(t) * dash_length * 0.5

		local pos = ellipse_center + right_direction * x + forward_direction * y

		-- drift effect
		local yaw = caster_angles.y + progress * -360

		pos = GetGroundPosition(pos, caster)
		
		caster:SetAbsOrigin(pos)
		caster:SetAngles(caster_angles.x, yaw, caster_angles.z)

		GridNav:DestroyTreesAroundPoint(pos, 80, false)

		-- modifier things
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
																		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do 
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_drift_burn", {duration = burn_duration})
		end

		return 0.03
	end, 0)
end