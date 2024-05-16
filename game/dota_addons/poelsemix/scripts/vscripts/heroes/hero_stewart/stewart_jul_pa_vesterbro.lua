
LinkLuaModifier("modifier_stewart_jul_invis","heroes/hero_stewart/stewart_jul_pa_vesterbro.lua",LUA_MODIFIER_MOTION_NONE)
stewart_jul_pa_vesterbro = stewart_jul_pa_vesterbro or class({})

function stewart_jul_pa_vesterbro:GetCastRange()
    local value = self:GetSpecialValueFor("range")
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_7"):GetLevel() > 0 then value = FIND_UNITS_EVERYWHERE end 
    return value
end

function stewart_jul_pa_vesterbro:CastFilterResultLocation()
	if IsServer() then
		local caster = self:GetCaster()
        local radius = self:GetSpecialValueFor("range")
        local caster_pos = caster:GetAbsOrigin()
        if self:GetCaster():FindAbilityByName("special_bonus_stewart_7"):GetLevel() > 0 then radius = FIND_UNITS_EVERYWHERE end 
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)

		if #enemies >= 1 then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function stewart_jul_pa_vesterbro:GetCustomCastErrorLocation()
	return "NO NEARBY ENEMIES"
end

function stewart_jul_pa_vesterbro:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local damage_type = self:GetAbilityDamageType()
    local tpdelay = self:GetSpecialValueFor("tpdelay")
    local radius = self:GetSpecialValueFor("range")
    local caster_pos = caster:GetAbsOrigin()
    if self:GetCaster():FindAbilityByName("special_bonus_stewart_7"):GetLevel() > 0 then radius = FIND_UNITS_EVERYWHERE end 

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_CLOSEST, false)
    caster:AddNewModifier(caster, self, "modifier_stewart_jul_invis", {})

    local guldringen = caster:FindAbilityByName("stewart_en_med_guldringen")
    local scepter = (caster:HasScepter() and guldringen:GetLevel() > 0)
    if scepter then guldringen:Apply(caster) end

    -- teleport to each enemy
    for i, enemy in pairs(enemies) do
        Timers:CreateTimer({
            endTime = (i-1) * tpdelay,
            callback = function()
                FindClearSpaceForUnit(caster, enemy:GetAbsOrigin(), true)

                if caster:HasModifier("modifier_stewart_guldring_active") then
                    caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
                else
                    caster:StartGesture(ACT_DOTA_ATTACK)
                end
                
                caster:PerformAttack(enemy, false, true, true, false, false, false, false)
                enemy:EmitSound("stewart_god_jul")
                if scepter then guldringen:Apply(caster) end
                
            end
        })
    end

    -- go back to original position
    local time = ((#enemies * tpdelay) - tpdelay/2) --delay for cd reset on scepter to work proper
    Timers:CreateTimer({
        endTime = time,
        callback = function()
            FindClearSpaceForUnit(caster, caster_pos, true)
            caster:RemoveModifierByName("modifier_stewart_jul_invis")
            if scepter and not guldringen:IsCooldownReady() then caster:RemoveModifierByName("modifier_stewart_guldring_active") end
        end
    })
end



modifier_stewart_jul_invis = modifier_stewart_jul_invis or class({})



function modifier_stewart_jul_invis:IsDebuff()
	return false
end

function modifier_stewart_jul_invis:IsPurgable()
	return false
end
function modifier_stewart_jul_invis:IsHidden()
	return false
end

function modifier_stewart_jul_invis:CheckState()
	if IsServer() then
		local state = {	[MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED]  = true}
		return state
	end
end



