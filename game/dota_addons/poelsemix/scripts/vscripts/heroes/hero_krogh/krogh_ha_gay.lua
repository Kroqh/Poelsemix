LinkLuaModifier("modifier_generic_taunt","generic_mods/modifier_generic_taunt.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ha_gay","heroes/hero_krogh/krogh_ha_gay.lua",LUA_MODIFIER_MOTION_NONE)

ha_gay = ha_gay or class({})

function ha_gay:OnSpellStart()
	if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    target:EmitSound("hagay")
    local duration = self:GetSpecialValueFor("duration")
    if caster:HasTalent("special_bonus_krogh_2") then duration = duration + caster:FindAbilityByName("special_bonus_krogh_2"):GetSpecialValueFor("value") end
    target:AddNewModifier(caster, self, "modifier_generic_taunt", {duration = duration, is_hidden = true, is_purgeable = true})
    target:AddNewModifier(caster, self, "modifier_ha_gay", {duration = duration})
end

modifier_ha_gay = modifier_ha_gay or class({})

function modifier_ha_gay:OnCreated()
    if not IsServer() then return end
    local caster = self:GetCaster()
    self.emasculate = false
    if caster:HasTalent("special_bonus_krogh_1") then self.emasculate = true end

    self.soulbind_particle = ParticleManager:CreateParticle("particles/heroes/krogh/ha_gay_chain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.soulbind_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
	ParticleManager:SetParticleControlEnt(self.soulbind_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    if (self.emasculate) then
        self.emasculate_particle = ParticleManager:CreateParticle("particles/econ/events/plus/high_five/high_five_lvl3_overhead_hearts.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    end
end

function modifier_ha_gay:GetModifierProvidesFOWVision()
    return 1
end


function modifier_ha_gay:OnRemoved()
	if not IsServer() then return end
    ParticleManager:DestroyParticle(self.soulbind_particle, true)
    if (self.emasculate) then
        ParticleManager:DestroyParticle(self.emasculate_particle, true)
    end
end

function modifier_ha_gay:IsDebuff()
	return true
end

function modifier_ha_gay:IsPurgable()
	return true
end
function modifier_ha_gay:IsHidden()
	return true
end

function modifier_ha_gay:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
end

function modifier_ha_gay:GetModifierBonusStats_Strength()
    if  not IsServer() then return end
    if self.emasculate then return self:GetCaster():FindAbilityByName("special_bonus_krogh_1"):GetSpecialValueFor("value") else return 0 end
end