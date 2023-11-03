--POWERSURGE
LinkLuaModifier("modifier_powersurge", "heroes/hero_cid/cid_powersurge", LUA_MODIFIER_MOTION_NONE)
powersurge = powersurge or class({})

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


modifier_powersurge = modifier_powersurge or class({})

function modifier_powersurge:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
	return decFuncs
end

function modifier_powersurge:GetModifierPreAttack_BonusDamage()
	return self.baseDamage
end

function modifier_powersurge:OnCreated()
    self:SetHasCustomTransmitterData(true)
	if IsServer() then
		local caster = self:GetCaster()
		local baseDamageAverage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2
		local damage_multiplier = self:GetAbility():GetSpecialValueFor("damage_multiplier") - 1
		local damage_multiplier_upgraded = self:GetAbility():GetSpecialValueFor("damage_multiplier_upgraded") - 1

		EmitSoundOn("Hero_Clinkz.Strafe", caster)
		if caster:HasModifier("modifier_upgrade_skills") then
            if caster:FindAbilityByName("special_bonus_cid_7"):GetLevel() > 0 then damage_multiplier_upgraded = damage_multiplier_upgraded + caster:FindAbilityByName("special_bonus_cid_7"):GetSpecialValueFor("value") end
			self.baseDamage = baseDamageAverage * damage_multiplier_upgraded
		else
            if caster:FindAbilityByName("special_bonus_cid_7"):GetLevel() > 0 then damage_multiplier = damage_multiplier + caster:FindAbilityByName("special_bonus_cid_7"):GetSpecialValueFor("value") end
			self.baseDamage = baseDamageAverage * damage_multiplier
		end
        self:SendBuffRefreshToClients()
	end
end

function modifier_powersurge:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_strafe_fire.vpcf"
end

function modifier_powersurge:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powersurge:OnRefresh()
	self:OnCreated()
end

function modifier_powersurge:AddCustomTransmitterData()
    return {
        baseDamage = self.baseDamage,
    }
end
function modifier_powersurge:HandleCustomTransmitterData( data )
    self.baseDamage = data.baseDamage
end