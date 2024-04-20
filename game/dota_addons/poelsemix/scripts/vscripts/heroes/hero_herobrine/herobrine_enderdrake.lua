herobrine_enderdrake = herobrine_enderdrake or class({})
LinkLuaModifier( "modifier_herobrine_enderdrake_unit_information", "heroes/hero_herobrine/herobrine_enderdrake", LUA_MODIFIER_MOTION_NONE )


function herobrine_enderdrake:OnSpellStart()
    if not IsServer() then return end
    local target_point = self:GetCursorPosition()
    local caster = self:GetCaster()
    local ability = self
    local int = caster:GetIntellect()
    local dmg_scaling = ability:GetSpecialValueFor("dmg_int_scaling")
    local hp_scaling = ability:GetSpecialValueFor("hp_int_scaling")

    

    local dmg = math.floor(int * dmg_scaling)
    local hp = math.floor(int * hp_scaling)--minks have 1 hp by defeault as to not insta die
    unit = CreateUnitByName("npc_enderdrake",target_point, true, caster, nil, caster:GetTeam())

    unit:AddNewModifier(caster, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
    unit:AddNewModifier(caster, ability, "modifier_herobrine_enderdrake_unit_information", {dmg = dmg} )
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