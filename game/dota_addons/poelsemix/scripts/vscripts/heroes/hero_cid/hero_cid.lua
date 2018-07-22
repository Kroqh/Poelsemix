--BIG CLICKS
LinkLuaModifier("modifier_big_clicks", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)

big_clicks = class({})

function big_clicks:GetAbilityTextureName()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_upgrade_skills") then
		return "big_clicks_upgraded_icon"
	end

	return "big_clicks_icon"
end

function big_clicks:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local stacks = self:GetSpecialValueFor("stacks")
		local upgraded_stacks = self:GetSpecialValueFor("upgraded_stacks") 

		caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")
		caster:AddNewModifier(caster, self, "modifier_big_clicks", {duration = duration})

		if caster:HasModifier("modifier_upgrade_skills") then
			caster:FindModifierByName("modifier_big_clicks"):SetStackCount(upgraded_stacks)
		else
			caster:FindModifierByName("modifier_big_clicks"):SetStackCount(stacks)
		end
	end
end

--big clicks modifier
modifier_big_clicks = class({})

function modifier_big_clicks:IsBuff() return true end
function modifier_big_clicks:IsPurgeable() return true end
function modifier_big_clicks:IsHidden() return false end

function modifier_big_clicks:DeclareFunctions()
		local decFuncs =
			{
					MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_EVENT_ON_ATTACK_LANDED
			}
		return decFuncs
end

function modifier_big_clicks:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

function modifier_big_clicks:OnCreated()
	self.particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
	local particle = "particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf"
	local caster = self:GetCaster()

	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(self.particle_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	

	if caster:HasModifier("modifier_upgrade_skills") then
		self.damage = self:GetAbility():GetSpecialValueFor("upgraded_damage")
	else
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_big_clicks:OnAttackLanded()
	if IsServer() then
		local caster = self:GetCaster() 
		local target = caster:GetAttackTarget()
		local particle_abyssal_fx = ParticleManager:CreateParticle(self.particle_abyssal, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_abyssal_fx)
		
		--ty dota imba
		local coup = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(coup, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(coup, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(coup)
		
		self:GetAbility():EmitSound("big_clicks")
		local stacks = self:GetStackCount()

		if stacks > 1 then
			self:SetStackCount(stacks - 1)
		else
			self:Destroy()
		end
	end
end

function modifier_big_clicks:OnRefresh()
	self:OnDestroy()
	self:OnCreated()
end

function modifier_big_clicks:OnDestroy()
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

--multiclick

LinkLuaModifier("modifier_multiclick", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_multiclick_passive", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_multiclick_thinker", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)

multiclick = class({})

function multiclick:GetAbilityTextureName()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_upgrade_skills") then
		return "multiclick_upgraded_icon"
	end

	return "multiclick_icon"
end

function multiclick:GetBehavior()
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function multiclick:GetIntrinsicModifierName()
	return "modifier_multiclick_thinker"
end

function multiclick:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local stacks = self:GetSpecialValueFor("stacks")

		caster:AddNewModifier(caster, self, "modifier_multiclick", {duration = duration})
		caster:FindModifierByName("modifier_multiclick"):SetStackCount(stacks)
		caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")
	end
end

function multiclick:GetManaCost( level )
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return 0
	end

	return self.BaseClass.GetManaCost(self, level)
end

--multiclick modifier
modifier_multiclick = class({})

function modifier_multiclick:IsBuff() return true end
function modifier_multiclick:IsPurgeable() return true end
function modifier_multiclick:IsHidden() return false end

function modifier_multiclick:DeclareFunctions()
		local decFuncs =
			{
					MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
					MODIFIER_EVENT_ON_ATTACK_LANDED

			}
		return decFuncs
end

function modifier_multiclick:GetModifierBaseAttackTimeConstant()
	return self.attackTime
end 

function modifier_multiclick:OnCreated()
	self.attackTime = self:GetAbility():GetSpecialValueFor("bat")
	
	local caster = self:GetCaster()

	self.pfx = "particles/econ/items/wisp/wisp_guardian_ti7.vpcf"
	self.wisp_fx = ParticleManager:CreateParticle(self.pfx, PATTACH_ABSORIGIN_FOLLOW, caster) 
	ParticleManager:SetParticleControlEnt(self.wisp_fx, 0, caster, PATTACH_OVERHEAD_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
end

function modifier_multiclick:OnAttackLanded()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_upgrade_skills") then return end
		local stacks = self:GetStackCount()

		if stacks > 1 then
			self:SetStackCount(stacks - 1)
		else
			self:Destroy()
		end
	end
end

function modifier_multiclick:OnDestroy()
	ParticleManager:DestroyParticle(self.wisp_fx, false)
	ParticleManager:ReleaseParticleIndex(self.wisp_fx)
end

--multiclick passive modifier
modifier_multiclick_passive = class({})

function modifier_multiclick_passive:IsHidden() 
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return false
	end

	return true
end

function modifier_multiclick_passive:IsPurgeable() return false end

function modifier_multiclick_passive:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
	return decFuncs
end

function modifier_multiclick_passive:GetModifierBaseAttackTimeConstant()
	return self.upgraded_bat
end

function modifier_multiclick_passive:OnCreated()
	self.upgraded_bat = self:GetAbility():GetSpecialValueFor("bat_upgraded")
end

function modifier_multiclick_passive:OnRefresh()
	self:OnCreated()
end

modifier_multiclick_thinker = class({})

function modifier_multiclick_thinker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_multiclick_thinker:IsHidden() return true end
function modifier_multiclick_thinker:IsPurgeable() return false end

function modifier_multiclick_thinker:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster() 
		local ability = self:GetAbility()

		if caster:HasModifier("modifier_upgrade_skills") then
			caster:AddNewModifier(caster, ability, "modifier_multiclick_passive", {}) 
		else
			caster:RemoveModifierByName("modifier_multiclick_passive")
		end
	end
end

--huge click
LinkLuaModifier("modifier_huge_click_attack", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)

huge_click = class({})

function huge_click:GetAbilityTextureName()
	local caster = self:GetCaster() 
	
	if caster:HasModifier("modifier_upgrade_skills") then
		return "huge_click_upgraded_icon"
	end
	
	return "huge_click_icon"
end

function huge_click:GetIntrinsicModifierName()
	return "modifier_huge_click_attack"
end 

--huge click modifier
modifier_huge_click_attack = class({})

function modifier_huge_click_attack:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}

	return decFuncs
end

function modifier_huge_click_attack:IsPurgeable() return false end
function modifier_huge_click_attack:IsHidden() return true end

function modifier_huge_click_attack:OnCreated()
		self.damage_modifier = self:GetAbility():GetSpecialValueFor("damage_modifier")
		self.damage_modifier_upgraded = self:GetAbility():GetSpecialValueFor("damage_modifier_upgraded") 
		self.chance = self:GetAbility():GetSpecialValueFor("chance")
		self.particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
end

function modifier_huge_click_attack:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		local caster = self:GetCaster() 
		local rand = RandomInt(1, 100)
		local target = caster:GetAttackTarget()
		
		
		if rand <= self.chance then
			if caster:HasModifier("modifier_upgrade_skills") then
				damage = self.damage_modifier_upgraded

			else
				damage = self.damage_modifier
				
			end
			local particle_abyssal_fx = ParticleManager:CreateParticle(self.particle_abyssal, PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_abyssal_fx) 

			self:GetAbility():EmitSound("huge_click")
			return damage
		end

		return nil
	end
end

--POWERSURGE
LinkLuaModifier("modifier_powersurge", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
powersurge = class({})

function powersurge:GetAbilityTextureName()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_upgrade_skills") then
		return "powersurge_upgraded_icon"
	end

	return "powersurge_icon"
end

function powersurge:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_powersurge", {duration = duration}) 
	end
end

modifier_powersurge = class({})

function modifier_powersurge:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
	
	return decFuncs
end

function modifier_powersurge:GetModifierBaseAttack_BonusDamage()
	return self.baseDamage
end

function modifier_powersurge:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local baseDamageAverage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2
		local damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier") 
		local damage_multiplier_upgraded = self:GetAbility():GetSpecialValueFor("damage_multiplier_upgraded")
		EmitSoundOn("Hero_Clinkz.Strafe", caster)
		
		if caster:HasModifier("modifier_upgrade_skills") then
			self.baseDamage = baseDamageAverage * damage_multiplier_upgraded
		else
			self.baseDamage = baseDamageAverage * damage_multiplier
		end
	end
end

function modifier_powersurge:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_strafe_fire.vpcf"
end

function modifier_powersurge:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powersurge:OnRefresh()
	self.baseDamage = 0
	self:OnCreated()
end


--UPGRADE SKILLS
LinkLuaModifier("modifier_upgrade_skills", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
upgrade_skills = class({})

function upgrade_skills:GetAbilityTextureName()
	return "upgrade_skills"
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
		caster:SetModelScale(2)
	end
end

modifier_upgrade_skills = class({})

function modifier_upgrade_skills:IsPurgeable() return false end

function modifier_upgrade_skills:OnCreated()
	if IsServer() then
		self.particle_fx = "particles/heroes/cid/cid_tornado.vpcf"
		self.particle_circle = "particles/heroes/cid/cid_tornado_circle.vpcf"
		self.pfx = ParticleManager:CreateParticle(self.particle_fx, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
		self.pfx_circle = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster()) 
		

		ParticleManager:SetParticleControlEnt(self.pfx_circle, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
		-- 10 second delayed, run once using gametime (respect pauses)
 		Timers:CreateTimer({
  		 	endTime = 0.20,
   			callback = function()
    			self.pfx_circle2 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle2, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})
 		Timers:CreateTimer({
  		 	endTime = 0.4,
   			callback = function()
    			self.pfx_circle3 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle3, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})

 		Timers:CreateTimer({
  		 	endTime = 0.6,
   			callback = function()
    			self.pfx_circle4 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle4, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})

 		Timers:CreateTimer({
  		 	endTime = 0.8,
   			callback = function()
    			self.pfx_circle5 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle5, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
 		    end
 			})

 		 	Timers:CreateTimer({
  		 	endTime = 1,
   			callback = function()
    			self.pfx_circle6 = ParticleManager:CreateParticle(self.particle_circle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    			ParticleManager:SetParticleControlEnt(self.pfx_circle6, 1, self:GetCaster(), PATTACH_OVERHEAD_FOLLOW, "attach_origin", self:GetCaster():GetAbsOrigin(), true)
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
		{MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
	return decFuncs
end

function modifier_upgrade_skills:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("ms")
end

function modifier_upgrade_skills:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		caster:SetModelScale(1)
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

function modifier_upgrade_skills:GetModifierModelChange()
	return "models/creeps/neutral_creeps/n_creep_dragonspawn_a/n_creep_dragonspawn_a.vmdl"
end

function modifier_upgrade_skills:GetStatusEffectName()
	return "particles/econ/items/juggernaut/jugg_arcana/status_effect_jugg_arcana_omni.vpcf"
end

function modifier_upgrade_skills:StatusEffectPriority()
	return 10
end

--right click sound
LinkLuaModifier("modifier_click", "heroes/hero_cid/hero_cid", LUA_MODIFIER_MOTION_NONE)
click = class({})

function click:GetIntrinsicModifierName() 
	return "modifier_click"
end

modifier_click = class({})

function modifier_click:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
	end
end

function modifier_click:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return decFuncs
end

function modifier_click:IsHidden() return true end
function modifier_click:IsPurgeable() return false end
function modifier_click:IsDebuff() return false end

function modifier_click:OnAttackLanded(keys)
	if IsServer() then
		local attacker = keys.attacker

		--print("Caster is", self.parent:GetUnitName() )
		--print("Attacker is", attacker:GetUnitName() )

		if self.parent == attacker then
			self:GetAbility():EmitSound("click")
		end
	end
end

function modifier_click:OnRefresh()
	if IsServer() then
		self:OnCreated()
	end
end