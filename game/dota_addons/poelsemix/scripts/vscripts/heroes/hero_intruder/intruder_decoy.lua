intruder_decoy = intruder_decoy or class({})
LinkLuaModifier("modifier_intruder_stealth", "heroes/hero_intruder/modifier_intruder_stealth", LUA_MODIFIER_MOTION_NONE)

function intruder_decoy:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local unit_name = caster:GetUnitName()
    local origin = caster:GetAbsOrigin() + RandomVector(50)
    caster:AddNewModifier(caster, ability, "modifier_intruder_stealth", {duration = self:GetSpecialValueFor("invis_dur")})

    local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())

    local targetLevel = caster:GetLevel()
	for i=1,targetLevel-1 do
		illusion:HeroLevelUp(false)
	end

    illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the target
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end


    illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = self:GetSpecialValueFor("clone_dur"), outgoing_damage = self:GetSpecialValueFor("clone_outgoing"), incoming_damage = 0 })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()
end