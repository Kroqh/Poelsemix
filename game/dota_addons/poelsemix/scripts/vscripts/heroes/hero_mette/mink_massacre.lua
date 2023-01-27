mink_massacre = mink_massacre or class({})



function mink_massacre:OnSpellStart()
    caster = self:GetCaster()
    target_point = self:GetCursorPosition()

    EmitSoundOn("mette_lev_med_det", caster)

    particle_gas = "particles/units/heroes/hero_death_prophet/death_prophet_death_gasburst.vpcf"
    rarityCount = 0
    for _, unit in pairs(FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, 0, 0, false)) do
        rarity = GetRarityMulti(unit:GetUnitName())
        if rarity > 0 then
            caster:ModifyGold(rarity * self:GetSpecialValueFor("base_gold_mink"), true, 0)
            
            particle_gas_fx = ParticleManager:CreateParticle(particle_gas, PATTACH_ABSORIGIN , unit)
            unit:ForceKill(false)
            
            rarityCount = rarityCount + rarity 
        end
    end

    if rarityCount > 0 then

        countGold = 0 

        if (caster:HasTalent("special_bonus_mette_2")) then
            countGold= (self:GetSpecialValueFor("base_gold_mink")+caster:FindAbilityByName("special_bonus_mette_2"):GetSpecialValueFor("value")) * rarityCount
        else
            countGold = self:GetSpecialValueFor("base_gold_mink") * rarityCount
        end
        print(countGold)
        caster:ModifyGold(rarityCount * countGold, true, 0)
        EmitSoundOnLocationWithCaster(target_point,"mette_scream", caster)
        modifier = caster:FindModifierByName("modifier_mink_massacre_mod")

        countInt = 0
        if (caster:HasTalent("special_bonus_mette_1")) then
            countInt= (self:GetSpecialValueFor("base_int_mink")+caster:FindAbilityByName("special_bonus_mette_1"):GetSpecialValueFor("value")) * rarityCount
        else
            countInt = self:GetSpecialValueFor("base_int_mink") * rarityCount
        end
        print(countInt)
        if modifier then
            modifier:SetStackCount(modifier:GetStackCount() + countInt)
        else
            modifier = caster:AddNewModifier(caster, self, "modifier_mink_massacre_mod", nil)
            modifier:SetStackCount(countInt)
        end
    end


    

end

function mink_massacre:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end


modifier_mink_massacre_mod = modifier_mink_massacre_mod  or class({})
LinkLuaModifier("modifier_mink_massacre_mod", "heroes/hero_mette/mink_massacre", LUA_MODIFIER_MOTION_NONE)

function modifier_mink_massacre_mod:IsPurgeable() return false end
function modifier_mink_massacre_mod:IsHidden() return false end
function modifier_mink_massacre_mod:IsPassive() return true end
function modifier_mink_massacre_mod:IsPassive() return true end
function modifier_mink_massacre_mod:RemoveOnDeath()	return false end
function modifier_mink_massacre_mod:IsDebuff()	return false end
function modifier_mink_massacre_mod:GetAttributes()	return MODIFIER_ATTRIBUTE_PERMANT end

function modifier_mink_massacre_mod:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_mink_massacre_mod:GetModifierBonusStats_Intellect()
	return 1 * self:GetStackCount()
end


function GetRarityMulti(unit_name)
    if unit_name == "unit_mink_1" then
        return 1
    elseif unit_name == "unit_mink_2" then
        return 2
    elseif unit_name == "unit_mink_3" then
        return 3
    elseif unit_name == "unit_mink_4" then
        return 4
    elseif unit_name == "unit_mink_5" then
        return 5
    else return 0 end
end