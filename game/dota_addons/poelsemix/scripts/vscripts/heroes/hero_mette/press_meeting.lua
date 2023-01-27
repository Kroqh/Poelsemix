press_meeting = press_meeting or class({})


function press_meeting:OnSpellStart()

    caster = self:GetCaster()
    local radius = 700
    local angle = 30
    local particle_rose = "particles/heroes/mette/rose_bed.vpcf"
    FindClearSpaceForUnit(caster, CalcNextLocation(radius,angle), true);
    particle_rose_fx1 = ParticleManager:CreateParticle(particle_rose, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle_rose_fx1, 0, caster:GetAbsOrigin())
    for _, enemy in pairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
        if enemy:IsRealHero() then
            angle = angle + 1
            FindClearSpaceForUnit(enemy, CalcNextLocation(radius,angle), true);
            particle_rose_fx2 = ParticleManager:CreateParticle(particle_rose, PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControl(particle_rose_fx2, 0, enemy:GetAbsOrigin())
            mink = nil
            level = self:GetLevel()
            if level == 1 then
                mink = "unit_mink_3"
            elseif level == 2 then
                mink = "unit_mink_4"
            elseif level == 3 then
                mink = "unit_mink_5"
            end
            unit = CreateUnitByName(mink,enemy:GetAbsOrigin(), true, caster, nil, caster:GetTeam()) 
            unit:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("lifetime") } )

            if caster:HasScepter() then
                print("test")
                enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun_dur_aghs") } )
            end
            
        end
    end

    EmitSoundOn("mette_chirp", caster)
    EmitSoundOn("mette_press", caster)
end



function CalcNextLocation(radius, angle)
    x = math.cos(angle)*radius;
    y = math.sin(angle)*radius;
    return Vector(x, y)
end