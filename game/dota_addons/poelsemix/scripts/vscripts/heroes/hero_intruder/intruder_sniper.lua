LinkLuaModifier("modifier_intruder_sniper", "heroes/hero_intruder/intruder_sniper", LUA_MODIFIER_MOTION_NONE)

intruder_sniper = intruder_sniper or class({})


function intruder_sniper:OnSpellStart() 
	if IsServer() then
		local caster = self:GetCaster()

        ammo = self:GetSpecialValueFor("ammo")
        EmitSoundOn("intruder_reload_sniper", caster)
        if caster:HasTalent("special_bonus_intruder_4") then ammo = ammo + caster:FindAbilityByName("special_bonus_intruder_4"):GetSpecialValueFor("value") end
        if caster:HasModifier("modifier_intruder_sniper") then
            ammo = ammo + caster:FindModifierByName("modifier_intruder_sniper"):GetStackCount()
            caster:FindModifierByName("modifier_intruder_sniper"):SetStackCount(ammo)
        else
            caster:AddNewModifier(caster, self, "modifier_intruder_sniper", {})
            caster:FindModifierByName("modifier_intruder_sniper"):SetStackCount(ammo)
        end
	end
end


modifier_intruder_sniper = modifier_intruder_sniper or class({})

function modifier_intruder_sniper:IsBuff() return true end
function modifier_intruder_sniper:IsPurgable() return true end
function modifier_intruder_sniper:IsHidden() return false end


function modifier_intruder_sniper:DeclareFunctions()
    local decFuncs =
        {
                MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
                MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
                MODIFIER_EVENT_ON_ATTACK_START
        }
    return decFuncs
end

function modifier_intruder_sniper:OnAttackStart( params )
    if IsServer() then
        if params.attacker ~= self:GetParent() then return end
        if params.target == nil then return end
        EmitSoundOn("intruder_sniper", params.attacker)
    end
	end
	

function modifier_intruder_sniper:OnAttackLanded(params)
    if IsServer() then
        if (params.attacker ~= self:GetParent()) then return end 
        self:DecrementStackCount()
        if self:GetStackCount() == 0 then self:Destroy() end

    end
end

function modifier_intruder_sniper:GetModifierBaseAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("damage")
    end
end

function modifier_intruder_sniper:GetModifierBaseAttackTimeConstant()
    if self:GetCaster():HasScepter() then return nil end

	return self:GetAbility():GetSpecialValueFor("base_as_penalty")
end 

function modifier_intruder_sniper:GetModifierAttackRangeBonus()
	if self:GetCaster():FindAbilityByName("special_bonus_intruder_3"):GetLevel() > 0 then return self:GetCaster():FindAbilityByName("special_bonus_intruder_3"):GetSpecialValueFor("value") + self:GetAbility():GetSpecialValueFor("range") end
    return self:GetAbility():GetSpecialValueFor("range")
end

function modifier_intruder_sniper:OnCreated()
    if IsServer() then
        self:GetCaster():SetRangedProjectileName("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf")
    end
end

function modifier_intruder_sniper:OnDestroy()
    if IsServer() then
        self:GetCaster():SetRangedProjectileName("particles/units/heroes/hero_sniper/sniper_base_attack.vpcf")
    end
end