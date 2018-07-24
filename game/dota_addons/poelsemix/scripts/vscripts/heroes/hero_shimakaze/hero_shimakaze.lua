LinkLuaModifier("modifier_dangerous_sea", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dangerous_sea_pool", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dangerous_sea_pool_slow", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)

dangerous_sea = class({})
function dangerous_sea:GetIntrinsicModifierName()
	return "modifier_dangerous_sea"
end

modifier_dangerous_sea = class({})

function modifier_dangerous_sea:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()

		self.pos = caster:GetAbsOrigin()
		self:StartIntervalThink(0.1)
	end
end

function modifier_dangerous_sea:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local distanceDifference = FindDistance(self.pos, caster:GetAbsOrigin())
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		--print("caster has moved", distanceDifference)

		if distanceDifference >= 225 then
			local thinker = CreateModifierThinker(caster, self:GetAbility(), "modifier_dangerous_sea_pool", {duration = duration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
			self.pos = caster:GetAbsOrigin()
		end
	end
end

--hidden modifier
modifier_dangerous_sea_pool = class({})

function modifier_dangerous_sea_pool:OnCreated()
	if IsServer() then
		print("created")
		local particle = "particles/heroes/shimakaze/shimakaze_run_water_ground.vpcf"
		local tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
		self.caster_start = self:GetParent():GetAbsOrigin()
		self.pfx_pool = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx_pool, 0, self:GetParent():GetAbsOrigin())
		self:StartIntervalThink(tick_interval)
	end
end

function modifier_dangerous_sea_pool:OnDestroy()
	if IsServer() then 
		ParticleManager:DestroyParticle(self.pfx_pool, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_pool)
	end
end

function modifier_dangerous_sea_pool:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()

		local damage = ability:GetSpecialValueFor("damage")

		local radius = ability:GetSpecialValueFor("radius")

		local duration_slow = ability:GetSpecialValueFor("duration_slow")

		local units = FindUnitsInRadius(caster:GetTeamNumber(), self.caster_start, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do
			ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = damage, ability = ability})
			enemy:AddNewModifier(caster, ability, "modifier_dangerous_sea_pool_slow", {duration = duration_slow})
		end
	end
end

--slow modifier
modifier_dangerous_sea_pool_slow = class({})

function modifier_dangerous_sea_pool_slow:OnCreated()
	local slow_percentage = self:GetAbility():GetSpecialValueFor("move_slow")

	self.slow = slow_percentage
end

function modifier_dangerous_sea_pool_slow:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_dangerous_sea_pool_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

LinkLuaModifier("modifier_water", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
water = class({})

function water:GetIntrinsicModifierName()
	return "modifier_water"
end
--hidden modifier
modifier_water = class({})

function modifier_water:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		self.prevPos = caster:GetAbsOrigin()

		self:StartIntervalThink(0.2)
	end
end

function modifier_water:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()

		--check if hero is moving
		if self.prevPos ~= caster:GetAbsOrigin() then
			self.particle = "particles/heroes/shimakaze/shimakaze_run_water.vpcf"
			self.pfx = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(self.pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		else 
			--check if hero has moved at all
			if self.pfx ~= nil then
				for i=1,self.pfx do --else deletes all particles
					ParticleManager:DestroyParticle(i, false)
					ParticleManager:ReleaseParticleIndex(i)
					--print("deleted particle", i)
				end
			end
		end

		self.prevPos = caster:GetAbsOrigin()
	end
end
