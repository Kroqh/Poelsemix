--hurtigbrille

LinkLuaModifier("modifier_hurtigbrille", "heroes/hero_brian/brian_hurtigbrille", LUA_MODIFIER_MOTION_NONE)
hurtigbrille = hurtigbrille or class({})

function hurtigbrille:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        if caster:HasTalent("special_bonus_brian_1") then
			local duration = duration + caster:FindAbilityByName("special_bonus_brian_1"):GetSpecialValueFor("value")
        end
        
        caster:AddNewModifier(caster, self, "modifier_hurtigbrille", {duration = duration})
        caster:EmitSound("woosh_brian") 
    end
end

modifier_hurtigbrille = class({})

function modifier_hurtigbrille:IsBuff() return true end

function modifier_hurtigbrille:DeclareFunctions()

    local decFuncs =
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS

    }
    return decFuncs
end

function modifier_hurtigbrille:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end
function modifier_hurtigbrille:GetModifierBonusStats_Agility()
    return self.agi
end
function modifier_hurtigbrille:OnCreated()
    if not IsServer() then return end
    local ability = self:GetAbility()
    self.movespeed = ability:GetSpecialValueFor("move_up_self")
    self.agi = ability:GetSpecialValueFor("aspeed")
        
    local partfire = "particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_ambient_esl_fire.vpcf"
	self.pfx = ParticleManager:CreateParticle(partfire, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())




    if self:GetParent():HasScepter() then
            local particle = "particles/econ/items/ogre_magi/ogre_2022_cc/ogre_2022_cc_trail_fire.vpcf"
            self.pfx_fire = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
            self.damage = ability:GetSpecialValueFor("scepter_damage_tick")
            self.radius = ability:GetSpecialValueFor("scepter_radius")
            self:StartIntervalThink(ability:GetSpecialValueFor("scepter_tick_rate"))
    end
end
function modifier_hurtigbrille:OnDestroy()
    if self.pfx ~= nil then
        ParticleManager:DestroyParticle(self.pfx, false)
    end
    if self.pfx_fire ~= nil then 
        ParticleManager:DestroyParticle(self.pfx_fire, false)
    end
end


function modifier_hurtigbrille:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local units = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do
			ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = self.damage, ability = ability})
		end
	end
end
