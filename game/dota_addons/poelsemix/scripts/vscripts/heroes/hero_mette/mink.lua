mette_mink = mette_mink or class({})
LinkLuaModifier( "modifier_mink_passive", "heroes/hero_mette/mink", LUA_MODIFIER_MOTION_NONE )

function mette_mink:GetIntrinsicModifierName()
	return "modifier_mink_passive"
end

modifier_mink_passive = modifier_mink_passive  or class({})

function modifier_mink_passive:IsPurgeable() return false end
function modifier_mink_passive:IsHidden() return true end
function modifier_mink_passive:IsPassive() return true end

function modifier_mink_passive:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1) --for instaspawning the first

	end
end

function modifier_mink_passive:OnIntervalThink()
	if IsServer() then
        local ability = self:GetAbility()
        local parent = self:GetParent()
            self:StartIntervalThink(CalcInterval(self:GetParent():GetIntellect(), ability:GetSpecialValueFor("base_interval")))
        
        local roll = math.random(100)
        local sum = 0
        print(roll)
        if roll <= ability:GetSpecialValueFor("common") then 
            local unit = CreateUnitByName("unit_mink_1",parent:GetAbsOrigin(), true, parent, nil,parent:GetTeam())
            unit:AddNewModifier(unit, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
            return
        else sum = sum + ability:GetSpecialValueFor("common") end
        if roll <= ability:GetSpecialValueFor("uncommon") + sum then 
            local unit = CreateUnitByName("unit_mink_2",parent:GetAbsOrigin(), true, parent, nil, parent:GetTeam())
            unit:AddNewModifier(unit, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
            return
        else sum = sum + ability:GetSpecialValueFor("uncommon") end
        if roll <= ability:GetSpecialValueFor("rare") + sum then 
            local unit = CreateUnitByName("unit_mink_3",parent:GetAbsOrigin(), true, parent, nil,parent:GetTeam())
            unit:AddNewModifier(unit, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
            return
        else sum = sum + ability:GetSpecialValueFor("rare") end

        if roll <= ability:GetSpecialValueFor("epic") + sum then 
            local unit = CreateUnitByName("unit_mink_4",parent:GetAbsOrigin(), true, parent, nil,parent:GetTeam())
            unit:AddNewModifier(unit, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
            return
        else sum = sum + ability:GetSpecialValueFor("epic") end
        if roll <= ability:GetSpecialValueFor("legendary") + sum then
            local unit = CreateUnitByName("unit_mink_5",parent:GetAbsOrigin(), true, parent, nil,parent:GetTeam()) 
            unit:AddNewModifier(unit, ability, "modifier_kill", { duration = ability:GetSpecialValueFor("lifetime") } )
            return
        end
        

	end
end

function CalcInterval(input, base)
    return base / (1+(input/100))
end 

