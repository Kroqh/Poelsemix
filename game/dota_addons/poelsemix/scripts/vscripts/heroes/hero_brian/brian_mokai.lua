LinkLuaModifier("modifier_mokai","heroes/hero_brian/brian_mokai.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_taunt","generic_mods/modifier_generic_taunt.lua",LUA_MODIFIER_MOTION_NONE)


mokai = mokai or class({})

function mokai:OnAbilityPhaseStart()  --doesnt auto start for some reason
	self:GetCaster():StartGesture(ACT_DOTA_CHANNEL_ABILITY_2)
end

function mokai:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:EmitSound("mokaidrink")
    self.caster_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff_drips_b.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(self.caster_particle, 0, caster, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", caster:GetAbsOrigin(), true)

end

function mokai:OnChannelFinish(interrupt)
	if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_2)
    ParticleManager:DestroyParticle(self.caster_particle, true)
    if interrupt then return end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    if caster:HasTalent("special_bonus_brian_6") then duration = duration + caster:FindAbilityByName("special_bonus_brian_6"):GetSpecialValueFor("value") end
    caster:AddNewModifier(caster, self, "modifier_mokai", {duration = duration})
    if caster:HasTalent("special_bonus_brian_4") then
        local caster_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(caster_particle, 2, Vector(0, 0, 0))
	    ParticleManager:ReleaseParticleIndex(caster_particle)
        self:GetCaster():EmitSound("brian_fc")
        for _, enemy in pairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, caster:FindAbilityByName("special_bonus_brian_4"):GetSpecialValueFor("value"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
            enemy:AddNewModifier(caster, self, "modifier_generic_taunt", {duration = duration})
        end
    end
end

modifier_mokai = modifier_mokai or class({})


function modifier_mokai:IsBuff() return true end
function modifier_mokai:IsPurgable() return true end

function modifier_mokai:DeclareFunctions()

    local decFuncs =
    {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MISS_PERCENTAGE


    }
    return decFuncs
end

function modifier_mokai:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end
function modifier_mokai:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_mokai:GetModifierMiss_Percentage()
    return self.misschance
end

function modifier_mokai:OnCreated()
    if not IsServer() then return end
    self.misschance = 0
    if not self:GetCaster():HasTalent("special_bonus_brian_5") then
        self.misschance = self:GetAbility():GetSpecialValueFor("miss_chance")
    end
end
function modifier_mokai:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end