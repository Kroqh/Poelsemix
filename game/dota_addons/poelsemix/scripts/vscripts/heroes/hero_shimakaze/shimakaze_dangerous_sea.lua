
LinkLuaModifier("shimakaze_modifier_dangerous_sea", "heroes/hero_shimakaze/shimakaze_dangerous_sea", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shimakaze_modifier_dangerous_sea_pool", "heroes/hero_shimakaze/shimakaze_dangerous_sea", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shimakaze_modifier_dangerous_sea_pool_slow", "heroes/hero_shimakaze/shimakaze_dangerous_sea", LUA_MODIFIER_MOTION_NONE)

shimakaze_dangerous_sea = shimakaze_dangerous_sea or class({})
function shimakaze_dangerous_sea:GetIntrinsicModifierName()
	return "shimakaze_modifier_dangerous_sea"
end


shimakaze_modifier_dangerous_sea = shimakaze_modifier_dangerous_sea or class({})

function shimakaze_modifier_dangerous_sea:OnCreated()
	if IsServer() then
		local parent= self:GetParent()
        self.prevPos = parent:GetAbsOrigin()
		self.distance = 0
		self:StartIntervalThink(FrameTime())
	end
end

function shimakaze_modifier_dangerous_sea:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		self.distance = self.distance + FindDistance(self.prevPos, parent:GetAbsOrigin())
		local duration = self:GetAbility():GetSpecialValueFor("duration")
        if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_7"):GetLevel() > 0 then duration = duration + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_7"):GetSpecialValueFor("value") end
		local distance_req = self:GetAbility():GetSpecialValueFor("distance_req")

		if self.distance >= distance_req then
			local thinker = CreateModifierThinker(parent, self:GetAbility(), "shimakaze_modifier_dangerous_sea_pool", {duration = duration}, parent:GetAbsOrigin(), parent:GetTeamNumber(), false)
			self.particle = "particles/heroes/shimakaze/shimakaze_run_water.vpcf"
			self.pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControlEnt(self.pfx, 2, parent, PATTACH_POINT_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)
			self.pos = parent:GetAbsOrigin()
			self.distance = self.distance % distance_req --ensure blinking doesnt spam on arrival
		end

		self.prevPos = parent:GetAbsOrigin()
	end
end


shimakaze_modifier_dangerous_sea_pool = shimakaze_modifier_dangerous_sea_pool or class({})

function shimakaze_modifier_dangerous_sea_pool:OnCreated()
	if IsServer() then
		--print("created thinker")
		local particle = "particles/heroes/shimakaze/shimakaze_run_water_ground.vpcf"
		local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
		self.caster_start = self:GetParent():GetAbsOrigin()
		self.pfx_pool = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx_pool, 0, self:GetParent():GetAbsOrigin())
		self.ability_damage = 0
		self:StartIntervalThink(tick_interval)
	end
end

function shimakaze_modifier_dangerous_sea_pool:OnDestroy()
	if IsServer() then 
		ParticleManager:DestroyParticle(self.pfx_pool, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_pool)
	end
end

function shimakaze_modifier_dangerous_sea_pool:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local damage = ability:GetSpecialValueFor("damage")
		local intellect = self:GetCaster():GetIntellect(true)
		local radius = ability:GetSpecialValueFor("radius")
		local duration_slow = ability:GetSpecialValueFor("duration_slow")
		local int_scaling_aghs = ability:GetSpecialValueFor("int_scaling_aghs")
		local int_scaling = ability:GetSpecialValueFor("int_scaling")	

		if caster:HasScepter() then
			self.ability_damage = damage + intellect*int_scaling_aghs
		else
			self.ability_damage = damage + intellect*int_scaling
		end

		local units = FindUnitsInRadius(caster:GetTeamNumber(), self.caster_start, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do
			ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = self.ability_damage, ability = ability})
			enemy:AddNewModifier(caster, ability, "shimakaze_modifier_dangerous_sea_pool_slow", {duration = duration_slow})
		end
	end
end

--slow modifier
shimakaze_modifier_dangerous_sea_pool_slow = shimakaze_modifier_dangerous_sea_pool_slow or class({})

function shimakaze_modifier_dangerous_sea_pool_slow:OnCreated()
	local slow_percentage = self:GetAbility():GetSpecialValueFor("move_slow")
    if self:GetCaster():FindAbilityByName("special_bonus_shimakaze_8"):GetLevel() > 0 then slow_percentage = slow_percentage + self:GetCaster():FindAbilityByName("special_bonus_shimakaze_8"):GetSpecialValueFor("value") end
	self.slow = slow_percentage
end

function shimakaze_modifier_dangerous_sea_pool_slow:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function shimakaze_modifier_dangerous_sea_pool_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

