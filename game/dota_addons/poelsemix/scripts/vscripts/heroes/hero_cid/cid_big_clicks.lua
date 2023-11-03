--BIG CLICKS
LinkLuaModifier("modifier_big_clicks", "heroes/hero_cid/cid_big_clicks", LUA_MODIFIER_MOTION_NONE)

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

--big clicks modifier
modifier_big_clicks = modifier_big_clicks or class({})

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


