margrethe_gud_bevare_danmark = margrethe_gud_bevare_danmark or class({})



function margrethe_gud_bevare_danmark:OnAbilityPhaseStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:EmitSound("margrethe_gud_bevare_danmark")
    local radius = self:GetSpecialValueFor("radius")
    self.units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags() , FIND_ANY_ORDER, false)
    if not caster:HasScepter() then
        for i, unit in pairs(self.units) do
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_margrethe/gud_bevare_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    else
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_margrethe/gud_bevare_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:ReleaseParticleIndex(particle)
    end

end

function margrethe_gud_bevare_danmark:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    
    local base_heal = self:GetSpecialValueFor("base_heal")
    local scaling = self:GetSpecialValueFor("int_to_heal_scaling")

    local heal = base_heal + (scaling*caster:GetIntellect())

    if not caster:HasScepter() then
        for i, unit in pairs(self.units) do
            unit:Heal(heal, caster)
        end
    else
        local heal = heal * self:GetSpecialValueFor("scepter_heal_multi")
        caster:Heal(heal, caster)
    end



end

function margrethe_gud_bevare_danmark:GetCastRange()
    local value = self:GetSpecialValueFor("radius")
    return value
end