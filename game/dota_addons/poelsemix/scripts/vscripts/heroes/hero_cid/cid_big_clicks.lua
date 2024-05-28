--BIG CLICKS
LinkLuaModifier("modifier_big_clicks", "heroes/hero_cid/cid_big_clicks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_big_clicks_passive", "heroes/hero_cid/cid_big_clicks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_big_clicks_thinker", "heroes/hero_cid/cid_big_clicks", LUA_MODIFIER_MOTION_NONE)

big_clicks = big_clicks or class({})

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
            if caster:FindAbilityByName("special_bonus_cid_6"):GetLevel() > 0 then upgraded_stacks = upgraded_stacks + caster:FindAbilityByName("special_bonus_cid_6"):GetSpecialValueFor("value") end
			caster:FindModifierByName("modifier_big_clicks"):SetStackCount(upgraded_stacks)
		else
            if caster:FindAbilityByName("special_bonus_cid_6"):GetLevel() > 0 then stacks = stacks + caster:FindAbilityByName("special_bonus_cid_6"):GetSpecialValueFor("value") end
			caster:FindModifierByName("modifier_big_clicks"):SetStackCount(stacks)
		end
	end
end


function big_clicks:GetBehavior()
	if self:GetCaster():HasModifier("modifier_upgrade_skills") and self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function big_clicks:GetIntrinsicModifierName()
	return "modifier_big_clicks_thinker"
end
function big_clicks:GetManaCost( level )
	if self:GetCaster():HasModifier("modifier_upgrade_skills") and self:GetCaster():HasScepter() then
		return 0
	end

	return self.BaseClass.GetManaCost(self, level)
end


--big clicks modifier
modifier_big_clicks = modifier_big_clicks or class({})

function modifier_big_clicks:IsBuff() return true end
function modifier_big_clicks:IsPurgable() return true end
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
	if caster:FindAbilityByName("special_bonus_cid_4"):GetLevel() > 0 then self.damage = self.damage + caster:FindAbilityByName("special_bonus_cid_4"):GetSpecialValueFor("value") end
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


modifier_big_clicks_passive = modifier_big_clicks_passive or class({})

function modifier_big_clicks_passive:IsHidden() 
	if self:GetCaster():HasModifier("modifier_upgrade_skills") then
		return false
	end

	return true
end

function modifier_big_clicks_passive:IsPurgable() return false end

function modifier_big_clicks_passive:DeclareFunctions()
    local decFuncs =
        {
                MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
                MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    return decFuncs
end

function modifier_big_clicks_passive:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end


function modifier_big_clicks_passive:OnAttackLanded()
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
	end
end

function modifier_big_clicks_passive:OnCreated()
	self.particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
	local particle = "particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf"
	local caster = self:GetCaster()

	self.particle_fx = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(self.particle_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	

	self:CalcStats()
end
function modifier_big_clicks_passive:CalcStats()
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_upgrade_skills") then
		self.damage = self:GetAbility():GetSpecialValueFor("upgraded_damage")
	else
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
	if caster:FindAbilityByName("special_bonus_cid_4"):GetLevel() > 0 then self.damage = self.damage + caster:FindAbilityByName("special_bonus_cid_4"):GetSpecialValueFor("value") end
end
function modifier_big_clicks_passive:OnRefresh()
	self:CalcStats()
end
function modifier_big_clicks_passive:OnRemoved()
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

modifier_big_clicks_thinker = modifier_big_clicks_thinker or class({})

function modifier_big_clicks_thinker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_big_clicks_thinker:IsHidden() return true end
function modifier_big_clicks_thinker:IsPassive() return true end
function modifier_big_clicks_thinker:IsPurgable() return false end

function modifier_big_clicks_thinker:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster() 
		local ability = self:GetAbility()
		if caster:HasModifier("modifier_upgrade_skills") and caster:HasScepter() then
            caster:RemoveModifierByName("modifier_big_clicks")
			caster:AddNewModifier(caster, ability, "modifier_big_clicks_passive", {}) 
		else
			caster:RemoveModifierByName("modifier_big_clicks_passive")
		end
	end
end