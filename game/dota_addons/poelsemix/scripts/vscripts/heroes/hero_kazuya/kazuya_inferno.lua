kazuya_inferno = kazuya_inferno or class({})
LinkLuaModifier("modifier_kazuya_demon", "heroes/hero_kazuya/kazuya_inferno", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kazuya_status", "heroes/hero_kazuya/kazuya_inferno", LUA_MODIFIER_MOTION_NONE)

function kazuya_inferno:OnAbilityPhaseStart()
    if not IsServer() then return end
    caster = self:GetCaster()
    local fury_cost  = self:GetSpecialValueFor("fury_cost")
	if caster:HasTalent("special_bonus_kazuya_7") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_7"):GetSpecialValueFor("value") end
	caster:FindModifierByName("modifier_kazuya_rage_fury_handler"):ChangeFury(-fury_cost, false)
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
    EmitSoundOn("kazuya_inferno", caster)
    
    if caster:HasScepter() then 
        local mod = caster:AddNewModifier(caster, self, "modifier_kazuya_demon", {duration = self:GetSpecialValueFor("demon_duration")})
        mod:SetCanDemon(false)
        EmitSoundOn("kazuya_inferno_kill", caster)
        
    else
        if not caster:HasModifier("modifier_kazuya_demon") then caster:AddNewModifier(caster, self, "modifier_kazuya_demon", {duration = 0.8})
        else caster:FindModifierByName("modifier_kazuya_demon"):SetCanDemon(true) end
    end
end

function kazuya_inferno:GetCustomCastErrorLocation()
	local caster = self:GetCaster()
	local fury_cost  = self:GetSpecialValueFor("fury_cost")
	if caster:HasTalent("special_bonus_kazuya_7") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_7"):GetSpecialValueFor("value") end
	return string.format("Fury needed: %s", fury_cost)
end

function kazuya_inferno:CastFilterResultLocation()
	if IsServer() then
		local caster = self:GetCaster()
		local fury_cost  = self:GetSpecialValueFor("fury_cost")
		if caster:HasTalent("special_bonus_kazuya_7") then fury_cost = fury_cost + caster:FindAbilityByName("special_bonus_kazuya_7"):GetSpecialValueFor("value") end
		if caster:FindModifierByName("modifier_kazuya_rage_fury_handler"):GetEnoughFury(fury_cost) then
			return UF_SUCCESS
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function kazuya_inferno:GetCastRange()
    return self:GetSpecialValueFor("range")
end

function kazuya_inferno:OnSpellStart()
    if not IsServer() then return end
    caster = self:GetCaster()
    local range = self:GetSpecialValueFor("range")
    local particleName = "particles/heroes/kazuya/inferno.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, nil )
    local target_point = self:GetCursorPosition()

    actual_target = caster:GetAbsOrigin() + ((target_point - caster:GetAbsOrigin()):Normalized() * range)

    local laser_pfx = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)	
	ParticleManager:SetParticleControl(laser_pfx, 1, target_point)
    ParticleManager:SetParticleControlEnt(laser_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_eyes", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(laser_pfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_eyes", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(laser_pfx, 9, caster, PATTACH_POINT_FOLLOW, "attach_eyes", caster:GetAbsOrigin(), true)

    local units = FindUnitsInLine(caster:GetTeamNumber(),
				caster:GetAbsOrigin(),
				target_point ,
				nil,
				self:GetSpecialValueFor("laser_width"),
				self:GetAbilityTargetTeam(),
				self:GetAbilityTargetType(),
				self:GetAbilityTargetFlags()
            )

			for _,unit in pairs(units) do
				ApplyDamage({victim = unit,
	            attacker = caster,
	            damage_type = self:GetAbilityDamageType(),
	            damage = self:GetSpecialValueFor("damage"),
	            ability = self})
			end
            


    
    Timers:CreateTimer({
    endTime = 0.5,
    callback = function() 
        if caster:HasModifier("modifier_kazuya_demon") then caster:FindModifierByName("modifier_kazuya_demon"):SetCanDemon(false) end
    end
    }) --Giving it some leverage
end


modifier_kazuya_demon = modifier_kazuya_demon or class({})

function modifier_kazuya_demon:IsPurgable() return false end
function modifier_kazuya_demon:IsHidden() return false end

function modifier_kazuya_demon:DeclareFunctions()
	local decFuncs = {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE ,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
}
    return decFuncs
end
function modifier_kazuya_demon:SetCanDemon(canDemon)
    self.canDemon = canDemon
end

function modifier_kazuya_demon:OnCreated()
	if not IsServer() then return end
		self:SetCanDemon(true)
        self.wings = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_wings_night.vmdl"})
       
		self.wings:FollowEntity(self:GetParent(), false)
        self.wings:SetModelScale(0.4)
        self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_kazuya_status", {duration = 0.55})
        self:StartIntervalThink(0.5)

end
function modifier_kazuya_demon:OnHeroKilled(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end
    if self.canDemon then
        canDemon = false
        self:SetDuration(self:GetAbility():GetSpecialValueFor("demon_duration"), true)
        EmitSoundOn("kazuya_inferno_kill", keys.attacker)
    end
end
function modifier_kazuya_demon:OnIntervalThink()
	if not IsServer() then end
    self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_kazuya_status", {duration = 0.55})
end


function modifier_kazuya_demon:OnDestroy()
	if not IsServer() then return end
        self.wings:Destroy()
        if self:GetParent():HasModifier("modifier_kazuya_status") then self:GetParent():RemoveModifierByName("modifier_kazuya_status") end

end



function modifier_kazuya_demon:GetTexture()
	return "kazuya_inferno"
end
function  modifier_kazuya_demon:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("demon_spell_amp")
end
function  modifier_kazuya_demon:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("demon_attack_damage")
end



modifier_kazuya_status = modifier_kazuya_status or class({}) --Exists to make sure demon form is correctly raged visually

function modifier_kazuya_status:IsPurgable() return false end
function modifier_kazuya_status:IsHidden() return true end
function modifier_kazuya_status:GetStatusEffectName()

    if self:GetParent():HasModifier("modifier_kazuya_rage") then return "particles/heroes/kazuya/kazuya_demon_rage.vpcf"end
    return "particles/heroes/kazuya/kazuya_demon.vpcf"
end

function modifier_kazuya_status:StatusEffectPriority()
    return 6
end