LinkLuaModifier("modifier_slapper_slap_city", "heroes/hero_slapper/slapper_slap_city", LUA_MODIFIER_MOTION_NONE)
slapper_slap_city = slapper_slap_city or class({})

function slapper_slap_city:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		if self.bat == nil then
			self.bat = caster:GetBaseAttackTime()
		end

		
		caster:AddNewModifier(caster, self, "modifier_slapper_slap_city", {duration = duration, bat = self.bat})
		EmitSoundOn("slapper_slap_city", caster)
	end
end

modifier_slapper_slap_city = modifier_slapper_slap_city or class({})

function modifier_slapper_slap_city:IsPurgable() return true end
function modifier_slapper_slap_city:IsHidden() return false end
function modifier_slapper_slap_city:RemoveOnDeath()	return true end


function modifier_slapper_slap_city:OnCreated(keys)
    if not IsServer() then return end
	local ability = self:GetAbility()
	self.bat_time = keys.bat + ability:GetSpecialValueFor("bat_time")
	self:SetHasCustomTransmitterData(true)
	
end


function modifier_slapper_slap_city:AddCustomTransmitterData()
    return {
        bat_time = self.bat_time
    }
end

function modifier_slapper_slap_city:HandleCustomTransmitterData( data )
    self.bat_time = data.bat_time
end


function modifier_slapper_slap_city:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}	
	return decFuncs
end

function modifier_slapper_slap_city:GetModifierPreAttack_BonusDamage()
	local multiplier = self:GetAbility():GetSpecialValueFor("agi_to_damage_scaling")
	local damage =   self:GetParent():GetAgility() * multiplier
	return damage
end

function modifier_slapper_slap_city:GetModifierBaseAttackTimeConstant()
	return  self.bat_time
end 

function modifier_slapper_slap_city:GetEffectName()
	return "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf"
end