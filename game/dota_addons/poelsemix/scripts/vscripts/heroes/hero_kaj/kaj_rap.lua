
LinkLuaModifier("modifier_kaj_rap", "heroes/hero_kaj/kaj_rap", LUA_MODIFIER_MOTION_NONE)
kaj_rap = kaj_rap or class({})


function kaj_rap:GetCastRange()
    local value = self:GetSpecialValueFor("radius") 
    if self:GetCaster():FindAbilityByName("special_bonus_kaj_3"):GetLevel() > 0 then value = value + self:GetCaster():FindAbilityByName("special_bonus_kaj_3"):GetSpecialValueFor("value") end
    return value
end


function kaj_rap:OnSpellStart()
	local caster = self:GetCaster()
	if not IsServer() then return end
	caster:EmitSound("KajRap1")
	
	caster:AddNewModifier(caster, self, "modifier_kaj_rap", {duration = self:GetSpecialValueFor("delay")})
end

modifier_kaj_rap = modifier_kaj_rap or class({})


function modifier_kaj_rap:IsHidden() return false end
function modifier_kaj_rap:IsPurgable() return false end
function modifier_kaj_rap:OnCreated()
	if not IsServer() then return end
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        if self:GetCaster():FindAbilityByName("special_bonus_kaj_3"):GetLevel() > 0 then self.radius = self.radius + self:GetCaster():FindAbilityByName("special_bonus_kaj_3"):GetSpecialValueFor("value") end
        self.damage = self:GetAbility():GetSpecialValueFor("damage")
        
        self.duration = self:GetAbility():GetSpecialValueFor("knockup_duration")
        if self:GetCaster():FindAbilityByName("special_bonus_kaj_2"):GetLevel() > 0 then self.duration = self.duration + self:GetCaster():FindAbilityByName("special_bonus_kaj_2"):GetSpecialValueFor("value") end

end
function modifier_kaj_rap:OnRemoved(death)
	if not IsServer() then return end
	if death then return end
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_kajr/rap.vpcf", PATTACH_POINT, self:GetCaster())
    caster:EmitSound("KajRap2")
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle)
    -- Targeting variables
    local target_teams = ability:GetAbilityTargetTeam() 
    local target_types = ability:GetAbilityTargetType() 
    local target_flags = ability:GetAbilityTargetFlags() 

    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self.radius, target_teams, target_types, target_flags, FIND_ANY_ORDER, false)
    for _,unit in ipairs(units) do
            ApplyDamage({victim = unit,
            attacker = caster,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            damage = self.damage,
            ability = self:GetAbility()
        })
        unit:AddNewModifier(caster, ability, "modifier_knockback", 
        {should_stun = 1, knockback_height = 999, knockback_distance = 10, knockback_duration = self.duration,  duration = self.duration})
        end
	
end

function modifier_kaj_rap:GetEffectName()
	return "particles/econ/items/hoodwink/hoodwink_2022_immortal/hoodwink_2022_immortal_sharpshooter_blossom_caster_music_notes.vpcf"
end