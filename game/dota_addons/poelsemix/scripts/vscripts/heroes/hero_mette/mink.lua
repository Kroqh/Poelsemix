mette_mink = mette_mink or class({})
LinkLuaModifier( "modifier_mink_passive", "heroes/hero_mette/mink", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mink_stats", "heroes/hero_mette/mink", LUA_MODIFIER_MOTION_NONE )

function mette_mink:GetIntrinsicModifierName()
	return "modifier_mink_passive"
end

modifier_mink_passive = modifier_mink_passive  or class({})

function modifier_mink_passive:IsPurgeable() return false end
function modifier_mink_passive:IsHidden() return true end
function modifier_mink_passive:IsPassive() return true end

function modifier_mink_passive:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("base_interval")) --for instaspawning the first

	end
end

function modifier_mink_passive:OnIntervalThink()
	if IsServer() then
        local ability = self:GetAbility()
        local parent = self:GetParent()

        if (parent:HasTalent("special_bonus_mette_3")) then
            self:StartIntervalThink(CalcInterval(self:GetParent():GetIntellect(), (ability:GetSpecialValueFor("base_interval") + parent:FindAbilityByName("special_bonus_mette_3"):GetSpecialValueFor("value"))))
        else
            self:StartIntervalThink(CalcInterval(self:GetParent():GetIntellect(), ability:GetSpecialValueFor("base_interval")))
        end
        if parent:IsAlive() == false then return end --no spawn on death
        local roll = math.random(100)
        local sum = 0
        EmitSoundOn("mette_chirp", parent)
        self:SpawnMink(1)
	end
end

function modifier_mink_passive:SpawnMink(scaler)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local parent = self:GetParent()
    local str = parent:GetStrength() * scaler
    local agi = parent:GetAgility() * scaler
    local size_multi = (str + agi) / 3 --mink hitbox is annoying, so dont let them get too big

    local str_scaling = ability:GetSpecialValueFor("hp_str_scaling")
    local agi_scaling = ability:GetSpecialValueFor("dmg_agi_scaling")
    if caster:HasTalent("special_bonus_mette_6") then str_scaling = str_scaling + caster:FindAbilityByName("special_bonus_mette_6"):GetSpecialValueFor("value") end
    if caster:HasTalent("special_bonus_mette_5") then agi_scaling  = agi_scaling  + caster:FindAbilityByName("special_bonus_mette_5"):GetSpecialValueFor("value") end

    local dmg = math.floor(agi * agi_scaling)
    local hp = math.floor(str * str_scaling) --minks have 1 hp by defeault as to not insta die

    unit = CreateUnitByName("unit_mink",parent:GetAbsOrigin(), true, parent, nil,parent:GetTeam())
    unit:AddNewModifier(caster, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
    unit:AddNewModifier(caster, ability, "modifier_mink_stats", {dmg = dmg, size_multi = size_multi} )
    unit:SetBaseMaxHealth(hp)
    unit:SetMaxHealth(hp)
    unit:SetHealth(hp) --has to have this ugly trio for it to work lol
end

function CalcInterval(input, base)
    return base / (1+(input/100))
end 


modifier_mink_stats = modifier_mink_stats  or class({})


function modifier_mink_stats:IsPurgeable() return false end
function modifier_mink_stats:IsHidden() return true end

function modifier_mink_stats:OnCreated(kv)
	if not IsServer() then return end
    self.dmg = kv.dmg
    self.size_multi = kv.size_multi
end


function modifier_mink_stats:DeclareFunctions()
	local decFuncs = {
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_MODEL_SCALE
}
    return decFuncs
end


function modifier_mink_stats:GetModifierBaseAttack_BonusDamage()
    if not IsServer() then return end
    return self.dmg
end
function modifier_mink_stats:GetModifierModelScale()
    if not IsServer() then return end
    return self.size_multi
end