
--huge click
LinkLuaModifier("modifier_huge_click_attack", "heroes/hero_cid/cid_huge_click", LUA_MODIFIER_MOTION_NONE)

huge_click = huge_click or class({})

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
modifier_huge_click_attack = modifier_huge_click_attack or class({})


function modifier_huge_click_attack:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND}

	return decFuncs
end

function modifier_huge_click_attack:GetAttackSound()
	return "click"
end
function modifier_huge_click_attack:IsPurgable() return false end
function modifier_huge_click_attack:IsHidden() return true end

function modifier_huge_click_attack:OnCreated()
		self.damage_modifier = self:GetAbility():GetSpecialValueFor("damage_modifier")
		self.damage_modifier_upgraded = self:GetAbility():GetSpecialValueFor("damage_modifier_upgraded") 
		
		self.particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
end

function modifier_huge_click_attack:GetModifierPreAttack_CriticalStrike()
	if IsServer() then
		local caster = self:GetCaster() 
		local rand = RandomInt(1, 100)
		local target = caster:GetAttackTarget()
		local chance = self:GetAbility():GetSpecialValueFor("chance")
        if caster:FindAbilityByName("special_bonus_cid_5"):GetLevel() > 0 then chance = chance + caster:FindAbilityByName("special_bonus_cid_5"):GetSpecialValueFor("value") end
		
		if rand <= chance then
			if caster:HasModifier("modifier_upgrade_skills") then
				damage = self.damage_modifier_upgraded

			else
				damage = self.damage_modifier
				
			end
	        if caster:FindAbilityByName("special_bonus_cid_1"):GetLevel() > 0 then damage = damage + caster:FindAbilityByName("special_bonus_cid_1"):GetSpecialValueFor("value") end
			local particle_abyssal_fx = ParticleManager:CreateParticle(self.particle_abyssal, PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_abyssal_fx) 

			self:GetAbility():EmitSound("huge_click")
			return damage
		end

		return nil
	end
end

