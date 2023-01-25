LinkLuaModifier("modifier_stun", "heroes/hero_stewart/hero_stewart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonny_boy", "heroes/hero_stewart/hero_stewart", LUA_MODIFIER_MOTION_NONE)
sonny_boy = class({})

function sonny_boy:OnSpellStart()
    if not IsServer() then return end
    -- Todo: Add sound effect
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_sonny_boy", {duration = duration})
end

modifier_sonny_boy = class({})

function modifier_sonny_boy:OnCreated()

end

function modifier_sonny_boy:IsPurgable() return false end

function modifier_sonny_boy:GetIntrinsicModifierName() 
    return "modifier_sonny_boy"
end

function modifier_sonny_boy:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_sonny_boy:GetModifierMoveSpeedBonus_Constant() 
    return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_sonny_boy:OnAttackLanded(keys)
    if not IsServer() then return end
    if not (keys.attacker == self:GetParent()) then return end
    local chance = self:GetAbility():GetSpecialValueFor("bashchance")
    local bash_duration = self:GetAbility():GetSpecialValueFor("bashduration")
    if RollPseudoRandom(chance, self) then
        -- Todo: sound effect
        local target = keys.target
        local duration = self:GetAbility():GetSpecialValueFor("bashduration")
        target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stun", {duration = bash_duration})
    end
end

modifier_stun = class({})
function modifier_stun:IsPurgable() return false end    
function modifier_stun:IsHidden() return false end

function modifier_stun:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stun:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stun:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }
    return state
end

en_med_guldringen = class({})

function en_med_guldringen:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local damage = self:GetSpecialValueFor("damage")
    local damage_type = self:GetAbilityDamageType()
    local damage_table = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = damage_type
    }
    ApplyDamage(damage_table)
    target:AddNewModifier(caster, self, "modifier_stun", {duration = duration})
    -- todo: sound effect
end

LinkLuaModifier("modifier_ask_for_help", "heroes/hero_stewart/hero_stewart", LUA_MODIFIER_MOTION_NONE)
ask_for_help = ask_for_help or class({})

function ask_for_help:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_ask_for_help", {duration = duration})
end

modifier_ask_for_help = modifier_ask_for_help or class({})

function modifier_ask_for_help:IsPurgable() return false end

function modifier_ask_for_help:GetIntrinsicModifierName() 
    return "modifier_ask_for_help"
end

function modifier_ask_for_help:OnCreated()
    if not IsServer() then return end
    self.stats_per_hero = self:GetAbility():GetSpecialValueFor("stats_per_hero")
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(0.2)
end

function modifier_ask_for_help:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_ask_for_help:OnIntervalThink()
    local caster = self:GetCaster()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
    local amount_of_enemies = #enemies
    self.total_stats = amount_of_enemies * self.stats_per_hero
    self:OnRefresh()
end

function modifier_ask_for_help:OnRefresh()
    if not IsServer() then return end
    self:SendBuffRefreshToClients()
end

function modifier_ask_for_help:AddCustomTransmitterData()
    return {
        total_stats = self.total_stats
    }
end

function modifier_ask_for_help:HandleCustomTransmitterData(data)
    self.total_stats = data.total_stats
end

function modifier_ask_for_help:GetModifierBonusStats_Strength()
    return self.total_stats
end

jul_pa_vesterbro = jul_pa_vesterbro or class({})

function jul_pa_vesterbro:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local damage_type = self:GetAbilityDamageType()
    local tpdelay = self:GetSpecialValueFor("tpdelay")
    local caster_pos = caster:GetAbsOrigin()
    local damage_table = {
        victim = nil,
        attacker = caster,
        damage = damage,
        damage_type = damage_type
    }

    local radius = FIND_UNITS_EVERYWHERE
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    -- teleport to each enemy
    for i, enemy in pairs(enemies) do
        Timers:CreateTimer({
            endTime = i * tpdelay,
            callback = function()
                FindClearSpaceForUnit(caster, enemy:GetAbsOrigin(), true)
                damage_table.victim = enemy
                ApplyDamage(damage_table)
                -- todo: sound effect
            end
        })
    end

    -- go back to original position
    Timers:CreateTimer({
        endTime = #enemies * tpdelay + tpdelay,
        callback = function()
            FindClearSpaceForUnit(caster, caster_pos, true)
        end
    })
end






