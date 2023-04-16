ha_army = ha_army or class({})


function ha_army:OnSpellStart()
    if not IsServer() then return end

    
    local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	

    EmitSoundOn("ha_army", self:GetCaster())
    local count = 0
    local melee = self:GetSpecialValueFor("ha_amount_melee")
    if (caster:HasTalent("special_bonus_harald_1")) then melee = melee + caster:FindAbilityByName("special_bonus_harald_1"):GetSpecialValueFor("value") end

    local ranged = self:GetSpecialValueFor("ha_amount_range")
    if (caster:HasTalent("special_bonus_harald_2")) then ranged = ranged + caster:FindAbilityByName("special_bonus_harald_2"):GetSpecialValueFor("value") end

    local duration = self:GetSpecialValueFor("duration")

    while(count < melee) do
        unit = CreateUnitByName("viking_norm",target, true, caster, nil,caster:GetTeam())
        unit:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("duration") } )
        unit:AddNewModifier(caster, self, "modifier_phased", { duration = 0.1 } )
        unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
        count = count + 1
    end

    count = 0
    while(count < ranged) do
        unit = CreateUnitByName("viking_ranged",target, true, caster, nil,caster:GetTeam())
        unit:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("duration") } )
        unit:AddNewModifier(caster, self, "modifier_phased", { duration = 0.1 } )
        unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
        count = count + 1
    end

    if (caster:HasScepter()) then
        count = 0
        local mages = self:GetSpecialValueFor("ha_amount_mage")
        while(count < mages) do
            unit = CreateUnitByName("viking_mage", target, true, caster, nil,caster:GetTeam())
            unit:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("duration") } )
            unit:AddNewModifier(caster, self, "modifier_phased", { duration = 0.1 } )
            unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
            count = count + 1
        end
    end
end