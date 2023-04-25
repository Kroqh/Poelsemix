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
	if not IsServer() then return end
    if self:GetCaster():HasTalent("special_bonus_krogh_5") then  --it works men den kan godt lide at spamme consolen hvis du hover over banan
        return self.BaseClass.GetCooldown(self,level) + self:GetCaster():FindAbilityByName("special_bonus_krogh_5"):GetSpecialValueFor("value")
    else
        return self.BaseClass.GetCooldown(self,level)
    end
end


modifier_krogh_sick_dodge = modifier_krogh_sick_dodge or class({})

function modifier_krogh_sick_dodge:OnCreated()
    if not IsServer() then return end
    local caster = self:GetCaster()
    self.ms = 0
    if caster:HasTalent("special_bonus_krogh_4") then self.ms  = caster:FindAbilityByName("special_bonus_krogh_4"):GetSpecialValueFor("value") end
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
    if not IsServer() then return end
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
