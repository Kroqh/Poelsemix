
--UPGRADE SKILLS
LinkLuaModifier("modifier_upgrade_skills", "heroes/hero_cid/cid_upgrade_skills", LUA_MODIFIER_MOTION_NONE)
upgrade_skills = upgrade_skills or class({})

function upgrade_skills:GetCooldown(level)
	local cd = self.BaseClass.GetCooldown(self,level)
	if self:GetCaster():FindAbilityByName("special_bonus_cid_3"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_cid_3"):GetSpecialValueFor("value") end 
    return cd
end


function upgrade_skills:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_upgrade_skills", {duration = duration})
		caster:RemoveModifierByName("modifier_multiclick")
		self:EmitSound("ch2_conquer")
		local particle = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
		local reborn = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)

		--ty dota imba
		ParticleManager:SetParticleControl( reborn, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( reborn, 1, Vector(1.5,1.5,1.5) )
		ParticleManager:SetParticleControl( reborn, 3, caster:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(reborn)
		StartSoundEvent( "Hero_Phoenix.SuperNova.Explode", caster)
	end
end

modifier_upgrade_skills = modifier_upgrade_skills or class({})

function modifier_upgrade_skills:IsPurgeable() return false end

function modifier_upgrade_skills:OnCreated()
	if IsServer() then
		self.particle_fx = "particles/heroes/cid/cid_tornado.vpcf"
		self.particle_circle = "particles/heroes/cid/cid_tornado_circle.vpcf"
		self.pfx = ParticleManager:CreateParticle(self.particle_fx, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
		self.pfx_circle = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
		

		ParticleManager:SetParticleControlEnt(self.pfx_circle, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		-- 10 second delayed, run once using gametime (respect pauses)
 		Timers:CreateTimer({
  		 	endTime = 0.20,
   			callback = function()
    			self.pfx_circle2 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle2, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})
 		Timers:CreateTimer({
  		 	endTime = 0.4,
   			callback = function()
    			self.pfx_circle3 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle3, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})

 		Timers:CreateTimer({
  		 	endTime = 0.6,
   			callback = function()
    			self.pfx_circle4 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle4, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})

 		Timers:CreateTimer({
  		 	endTime = 0.8,
   			callback = function()
    			self.pfx_circle5 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle5, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})

 		 	Timers:CreateTimer({
  		 	endTime = 1,
   			callback = function()
    			self.pfx_circle6 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle6, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})
	end
end

function modifier_upgrade_skills:OnRefresh()
	if IsServer() then
		local caster = self:GetCaster()

		caster:RemoveModifierByName("modifier_upgrade_skills") 
		self:GetAbility():OnSpellStart()
	end
end

function modifier_upgrade_skills:DeclareFunctions()
	local decFuncs = 
		{MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
	return decFuncs
end

function modifier_upgrade_skills:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("ms")
end

function modifier_upgrade_skills:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)

		ParticleManager:DestroyParticle(self.pfx_circle, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_circle)

		ParticleManager:DestroyParticle(self.pfx_circle2, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_circle2)

		ParticleManager:DestroyParticle(self.pfx_circle3, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_circle3)	

		ParticleManager:DestroyParticle(self.pfx_circle4, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_circle4)

		ParticleManager:DestroyParticle(self.pfx_circle5, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_circle5)

		ParticleManager:DestroyParticle(self.pfx_circle6, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_circle6)

		self:GetAbility():StopSound("ch2_conquer")
	end
end

function modifier_upgrade_skills:GetStatusEffectName()
	return "particles/econ/items/juggernaut/jugg_arcana/status_effect_jugg_arcana_omni.vpcf"
end

function modifier_upgrade_skills:StatusEffectPriority()
	return 10
end
