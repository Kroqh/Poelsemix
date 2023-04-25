LinkLuaModifier("modifier_musashi_earth_debuff", "heroes/hero_musashi/musashi_earth", LUA_MODIFIER_MOTION_NONE)
musashi_earth = musashi_earth or class({})


function musashi_earth:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
end


function musashi_earth:OnSpellStart()

    local caster = self:GetCaster()
	caster:EmitSound("musashi_earth")
    
    local hit_location = caster:GetAbsOrigin() + (caster:GetForwardVector() * 100) --so impact is at sword location
    local radius = self:GetSpecialValueFor("radius")
    if caster:HasTalent("special_bonus_musashi_4") then
        radius = radius  + caster:FindAbilityByName("special_bonus_musashi_4"):GetSpecialValueFor("value")
    end

	-- Add stomp particle
	local particle_stomp_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_stomp_fx, 0, hit_location)
	ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(particle_stomp_fx)

    local debuff_duration = self:GetSpecialValueFor("slow_duration")
	
	-- Find all nearby enemies
	for _, enemy in pairs(FindUnitsInRadius(caster:GetTeamNumber(), hit_location, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			-- Stun them
			enemy:AddNewModifier(caster, self, "modifier_musashi_earth_debuff", {duration = debuff_duration})
            if self:GetCaster():HasTalent("special_bonus_musashi_5") then
                enemy:AddNewModifier(caster, self, "modifier_stunned", {Duration = debuff_duration})
            end
           
			
			ApplyDamage({
				victim 			= enemy,
				damage 			= self:GetSpecialValueFor("damage"),
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self
			})
	end
end

modifier_musashi_earth_debuff = modifier_musashi_earth_debuff or class({})

function modifier_musashi_earth_debuff:IsPurgable() return	true end
function modifier_musashi_earth_debuff:IsDebuff() return true end

function modifier_musashi_earth_debuff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return decFuncs
end

function modifier_musashi_earth_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow_percent")
end

function modifier_musashi_earth_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_thunder_clap.vpcf"
end
function modifier_musashi_earth_debuff:StatusEffectPriority()
	return 2
end

function modifier_musashi_earth_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end