marvelous_sky = marvelous_sky or class({})

LinkLuaModifier("marvelous_sky_buff", "heroes/hero_marvelous/marvelous_sky", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("marvelous_sky_aura", "heroes/hero_marvelous/marvelous_sky", LUA_MODIFIER_MOTION_NONE)

function marvelous_sky:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local cast_point =self:GetCursorPosition()
    caster:EmitSound("marvelous_sky")
    dur = self:GetSpecialValueFor("duration")
    CreateModifierThinker(caster, self, "marvelous_sky_aura", {
		duration = dur
	}, GetGroundPosition(cast_point, nil), caster:GetTeamNumber(), false)
end

function marvelous_sky:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_marvelous_6"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_marvelous_6"):GetSpecialValueFor("value") end
    return cd
end


function marvelous_sky:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")
    if self:GetCaster():FindAbilityByName("special_bonus_marvelous_1"):GetLevel() > 0 then radius = radius + self:GetCaster():FindAbilityByName("special_bonus_marvelous_1"):GetSpecialValueFor("value") end 
    return radius
end
function marvelous_sky:GetCastRange()
    local range = self:GetSpecialValueFor("cast_range")
    return range
end




marvelous_sky_aura = marvelous_sky_aura or class({})


function marvelous_sky_aura:OnCreated(keys)
	if not self:GetAbility() then self:Destroy() return end
	self.radius	= self:GetAbility():GetSpecialValueFor("radius")
    if self:GetCaster():FindAbilityByName("special_bonus_marvelous_1"):GetLevel() > 0 then self.radius = self.radius + self:GetCaster():FindAbilityByName("special_bonus_marvelous_1"):GetSpecialValueFor("value") end 
    
    if not IsServer() then return end

    local sky_fx = "particles/units/heroes/hero_marvelous/pink_sky.vpcf"

    local particle = ParticleManager:CreateParticle(sky_fx, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 0, self.radius))

		Timers:CreateTimer(keys.duration, function()
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end)
end

function marvelous_sky_aura:OnDestroy()
    if not IsServer() then return end
    return 
end

function marvelous_sky_aura:IsAura()						return true end
function marvelous_sky_aura:GetAuraDuration()				return 0.1 end
function marvelous_sky_aura:GetAuraRadius()				return self.radius end
function marvelous_sky_aura:GetAuraSearchFlags()			return self:GetAbility():GetAbilityTargetFlags() end
function marvelous_sky_aura:GetAuraSearchTeam()			return self:GetAbility():GetAbilityTargetTeam() end
function marvelous_sky_aura:GetAuraSearchType()			return self:GetAbility():GetAbilityTargetType() end
function marvelous_sky_aura:GetModifierAura()				return "marvelous_sky_buff" end



marvelous_sky_buff = marvelous_sky_buff or class({})


function  marvelous_sky_buff:IsPurgable() return false end
function  marvelous_sky_buff:IsDebuff() return false end
function  marvelous_sky_buff:IsHidden() return false end

function marvelous_sky_buff:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return decFuncs
end

function marvelous_sky_buff:GetModifierAttackSpeedPercentage()
    as = self:GetAbility():GetSpecialValueFor("attack_speed_percent")
    if self:GetCaster():FindAbilityByName("special_bonus_marvelous_4"):GetLevel() > 0 then as = as + self:GetCaster():FindAbilityByName("special_bonus_marvelous_4"):GetSpecialValueFor("value") end 
    return as
end

function marvelous_sky_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movement_speed_perc")
end