LinkLuaModifier("modifier_brian_dak", "heroes/hero_brian/brian_dak", LUA_MODIFIER_MOTION_NONE)
brian_dak = brian_dak or class({})

function brian_dak:OnAbilityPhaseStart()  --doesnt auto start for some reason
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
end


function brian_dak:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        
        caster:AddNewModifier(caster, self, "modifier_brian_dak", {duration = duration})
        caster:EmitSound("max_sprit") 
    end
end

modifier_brian_dak = class({})

function modifier_brian_dak:IsBuff() return true end
function modifier_brian_dak:IsPurgable() return false end


function modifier_brian_dak:OnCreated()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.radius = ability:GetSpecialValueFor("radius")
    local tick_rate = ability:GetSpecialValueFor("tick_rate")
    self.damage_tick = ability:GetSpecialValueFor("damage_tick")
    if caster:HasTalent("special_bonus_brian_2") then
        tick_rate = tick_rate + caster:FindAbilityByName("special_bonus_brian_2"):GetSpecialValueFor("value")
    end
    if caster:HasTalent("special_bonus_brian_3") then
        self.radius = self.radius + caster:FindAbilityByName("special_bonus_brian_3"):GetSpecialValueFor("value")
    end

    self:StartIntervalThink(tick_rate)
end

function modifier_brian_dak:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
end
function modifier_brian_dak:OnIntervalThink()
	if not IsServer() then return end

    local particle = "particles/units/heroes/hero_brian/dak.vpcf"
	local caster = self:GetCaster()
	local ability = self:GetAbility()

    local particle_epicenter_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_epicenter_fx, 1, Vector(self.radius, self.radius, self.radius))
	ParticleManager:ReleaseParticleIndex(particle_epicenter_fx)

	local units = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, ability:GetAbilityTargetTeam(), 
	ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

    
	for _, enemy in pairs(units) do
		ApplyDamage({victim = enemy, attacker = caster, damage_type = ability:GetAbilityDamageType(), damage = self.damage_tick, ability = ability})

        enemy:AddNewModifier(caster, ability, "modifier_knockback", 
        {should_stun = 1, knockback_height = 50, knockback_distance = 0, knockback_duration = 0.1,  duration = 0.1})
	end

end
