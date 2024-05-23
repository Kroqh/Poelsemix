herobrine_enderdrake = herobrine_enderdrake or class({})
LinkLuaModifier( "modifier_herobrine_enderdrake_unit_information", "heroes/hero_herobrine/herobrine_enderdrake", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_herobrine_enderdrake_burn", "heroes/hero_herobrine/herobrine_enderdrake", LUA_MODIFIER_MOTION_NONE )

function herobrine_enderdrake:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local ability = self
    local int = caster:GetIntellect(true)
    local dmg_scaling = ability:GetSpecialValueFor("dmg_int_scaling")
    if self:GetCaster():FindAbilityByName("special_bonus_herobrine_3"):GetLevel() > 0 then dmg_scaling = dmg_scaling + self:GetCaster():FindAbilityByName("special_bonus_herobrine_3"):GetSpecialValueFor("value") end
    local hp_scaling = ability:GetSpecialValueFor("hp_int_scaling")

    

    local dmg = math.floor(int * dmg_scaling)
    local hp = math.floor(int * hp_scaling)
    unit = CreateUnitByName("npc_enderdrake",target_point, true, caster, nil, caster:GetTeam())

    unit:AddNewModifier(caster, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
    unit:AddNewModifier(caster, ability, "modifier_herobrine_enderdrake_unit_information", {dmg = dmg} )
    unit:SetTeam(caster:GetTeamNumber())
	unit:SetOwner(caster)
    unit:SetBaseMaxHealth(hp)
    unit:SetMaxHealth(hp)
    unit:SetHealth(hp) --has to have this ugly trio for it to work lol
    unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

    EmitSoundOn("herobrine_enderdrake_spawn", unit)
end




modifier_herobrine_enderdrake_unit_information = modifier_herobrine_enderdrake_unit_information  or class({})


function modifier_herobrine_enderdrake_unit_information:IsPurgable() return false end
function modifier_herobrine_enderdrake_unit_information:IsHidden() return true end

function modifier_herobrine_enderdrake_unit_information:OnCreated(kv)
	if not IsServer() then return end
    self.dmg = kv.dmg
end

function modifier_herobrine_enderdrake_unit_information:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
}
    return decFuncs
end


function modifier_herobrine_enderdrake_unit_information:GetModifierBaseAttack_BonusDamage()
    if not IsServer() then return end
    return self.dmg
end
function modifier_herobrine_enderdrake_unit_information:GetAttackSound()
    return "herobrine_enderdrake_attack"
end

function modifier_herobrine_enderdrake_unit_information:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
    if self:GetCaster():FindAbilityByName("special_bonus_herobrine_6"):GetLevel() > 0 then
        local thinker = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_herobrine_enderdrake_burn", {duration = self:GetCaster():FindAbilityByName("special_bonus_herobrine_6"):GetSpecialValueFor("duration"), damage = self:GetParent():GetAverageTrueAttackDamage(nil)}, params.target:GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
    end
end


modifier_herobrine_enderdrake_burn = modifier_herobrine_enderdrake_burn or class({})

function modifier_herobrine_enderdrake_burn:OnCreated(keys)
	if IsServer() then
		local particle = "particles/econ/items/herobrine/dragon_breath.vpcf"
		local tick_interval = self:GetCaster():FindAbilityByName("special_bonus_herobrine_6"):GetSpecialValueFor("tick_interval")
		self.pfx_pool = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx_pool, 0, self:GetParent():GetAbsOrigin())
		self.ability_damage = keys.damage * (tick_interval/self:GetCaster():FindAbilityByName("special_bonus_herobrine_6"):GetSpecialValueFor("duration"))
        self.radius = self:GetCaster():FindAbilityByName("special_bonus_herobrine_6"):GetSpecialValueFor("radius")
		self:StartIntervalThink(tick_interval)
	end
end

function modifier_herobrine_enderdrake_burn:OnDestroy()
	if IsServer() then 
		ParticleManager:DestroyParticle(self.pfx_pool, false)
		ParticleManager:ReleaseParticleIndex(self.pfx_pool)
	end
end

function modifier_herobrine_enderdrake_burn:OnIntervalThink()
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