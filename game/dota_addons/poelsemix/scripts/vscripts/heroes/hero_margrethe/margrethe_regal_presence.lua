margrethe_regal_presence = margrethe_regal_presence or class({})
LinkLuaModifier( "modifier_margrethe_regal_presence", "heroes/hero_margrethe/margrethe_regal_presence", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_margrethe_regal_presence_buff", "heroes/hero_margrethe/margrethe_regal_presence", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Passive Modifier
function margrethe_regal_presence:GetIntrinsicModifierName()
	return "modifier_margrethe_regal_presence"
end

function margrethe_regal_presence:GetCastRange()
    local value = self:GetSpecialValueFor("radius")
    return value
end


modifier_margrethe_regal_presence = modifier_margrethe_regal_presence or class({})


function modifier_margrethe_regal_presence:IsPassive() return true end
function modifier_margrethe_regal_presence:IsHidden() return true end
function modifier_margrethe_regal_presence:IsPurgable() return false end

function modifier_margrethe_regal_presence:OnCreated()
    self.count = 1 
    if not IsServer() then return end

    self:StartIntervalThink(0.1)
end

function modifier_margrethe_regal_presence:OnIntervalThink()
    local caster = self:GetParent()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    self.count = 1 
    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(), DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED , FIND_ANY_ORDER, false)
    for i, unit in pairs(units) do
        if unit:GetUnitName() == "npc_queens_knight" then self.count = self.count + 1 end
    end

    local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbility():GetAbilityTargetTeam(),self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for i, hero in pairs(heroes) do
            if not hero:HasModifier("modifier_margrethe_regal_presence_buff") then
                hero:AddNewModifier(caster, self:GetAbility(), "modifier_margrethe_regal_presence_buff", {})
            end
            local mod = hero:FindModifierByName("modifier_margrethe_regal_presence_buff")
            mod:ForceRefresh()
            mod:SetStackCount(self.count)
    end

end


modifier_margrethe_regal_presence_buff = modifier_margrethe_regal_presence_buff or class({})

function modifier_margrethe_regal_presence_buff:IsPurgable() return false end

function modifier_margrethe_regal_presence_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("buff_falloff"))
end
function modifier_margrethe_regal_presence_buff:OnRefresh()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("buff_falloff"))
end

function modifier_margrethe_regal_presence_buff:OnIntervalThink()
    self:Destroy()
end

function modifier_margrethe_regal_presence_buff:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_margrethe_regal_presence_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("as_per_stack")
end
function modifier_margrethe_regal_presence_buff:GetModifierMagicalResistanceBonus()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magic_resist_per_stack")
end