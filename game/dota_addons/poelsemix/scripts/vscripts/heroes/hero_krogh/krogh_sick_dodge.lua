LinkLuaModifier("modifier_krogh_sick_dodge","heroes/hero_krogh/krogh_sick_dodge.lua",LUA_MODIFIER_MOTION_NONE)

sick_dodge = sick_dodge or class({})

function sick_dodge:OnSpellStart()
	if not IsServer() then return end

    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
    caster:EmitSound("woosh_krogh")
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_krogh_sick_dodge", {duration = duration})
end

function sick_dodge:GetCooldown(level)
    local cd = self.BaseClass.GetCooldown(self,level)
    if self:GetCaster():FindAbilityByName("special_bonus_krogh_5"):GetLevel() > 0 then cd = cd + self:GetCaster():FindAbilityByName("special_bonus_krogh_5"):GetSpecialValueFor("value") end
    return cd
end


modifier_krogh_sick_dodge = modifier_krogh_sick_dodge or class({})

function modifier_krogh_sick_dodge:OnCreated()
    self.ms = 0
    if self:GetCaster():FindAbilityByName("special_bonus_krogh_4"):GetLevel() > 0 then self.ms = self:GetCaster():FindAbilityByName("special_bonus_krogh_4"):GetSpecialValueFor("value") end
    if not IsServer() then return end
    local caster = self:GetCaster()
    
end

function modifier_krogh_sick_dodge:OnRemoved()
    if not IsServer() then return end
    self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
end

function modifier_krogh_sick_dodge:IsDebuff()
	return false
end

function modifier_krogh_sick_dodge:IsPurgable()
	return false
end
function modifier_krogh_sick_dodge:IsHidden()
	return false
end

function modifier_krogh_sick_dodge:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_krogh_sick_dodge:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_krogh_sick_dodge:GetEffectAttachType()
	return PATTACH_ROOTBONE_FOLLOW
end

function modifier_krogh_sick_dodge:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_windwalk_swoop.vpcf"
end


function modifier_krogh_sick_dodge:CheckState() --otherwise dash is cancelable, dont want that - needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]  = true}
		return state
	end
end
