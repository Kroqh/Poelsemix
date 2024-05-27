LinkLuaModifier("modifier_hurtigbrille", "heroes/hero_brian/brian_hurtigbrille", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_hurtigbrille_burn", "heroes/hero_brian/brian_hurtigbrille", LUA_MODIFIER_MOTION_NONE )
hurtigbrille = hurtigbrille or class({})

function hurtigbrille:OnAbilityPhaseStart()  --doesnt auto start for some reason
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)
end


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
       self:StartIntervalThink(FrameTime())
       self.prevPos = self:GetParent():GetAbsOrigin()
       self.distance = 0
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
		local parent = self:GetParent()
		self.distance = self.distance + FindDistance(self.prevPos, parent:GetAbsOrigin())
		local duration = self:GetAbility():GetSpecialValueFor("scepter_duration")
		local distance_req = self:GetAbility():GetSpecialValueFor("scepter_radius")

		if self.distance >= distance_req then
			local thinker = CreateModifierThinker(parent, self:GetAbility(), "modifier_hurtigbrille_burn", {duration = duration}, parent:GetAbsOrigin(), parent:GetTeamNumber(), false)
            self.distance = self.distance % distance_req --ensure blinking doesnt spam on arrival
        end

		self.prevPos = parent:GetAbsOrigin()
	end
end


modifier_hurtigbrille_burn = modifier_hurtigbrille_burn or class({})

function modifier_hurtigbrille_burn:OnCreated(keys)
	if IsServer() then
		local particle = "particles/heroes/brian/hurtig_brille_fire_trail.vpcf"
		local tick_interval = self:GetAbility():GetSpecialValueFor("scepter_tick_rate")
		self.pfx_pool = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx_pool, 0, self:GetParent():GetAbsOrigin())
		self.ability_damage = self:GetAbility():GetSpecialValueFor("scepter_damage_per_fire") * (tick_interval/self:GetAbility():GetSpecialValueFor("scepter_duration"))
        self.radius = self:GetAbility():GetSpecialValueFor("scepter_radius")
		self:StartIntervalThink(tick_interval)
	end
end

function modifier_hurtigbrille_burn:OnDestroy()
	if IsServer() then 
		ParticleManager:DestroyParticle(self.pfx_pool, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_pool)
	end
end

function modifier_hurtigbrille_burn:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local units = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do
			ApplyDamage({victim = enemy, attacker = caster, damage_type = DAMAGE_TYPE_MAGICAL, damage = self.ability_damage, ability = ability})
		end
	end
end
