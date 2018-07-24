LinkLuaModifier("modifier_water", "heroes/hero_shimakaze/hero_shimakaze", LUA_MODIFIER_MOTION_NONE)
water = class({})

function water:GetIntrinsicModifierName()
	return "modifier_water"
end

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