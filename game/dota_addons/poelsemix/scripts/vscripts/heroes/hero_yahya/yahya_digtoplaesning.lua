LinkLuaModifier("modifier_yahya_digtoplaesning", "heroes/hero_yahya/yahya_digtoplaesning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yahya_digtoplaesning_debuff", "heroes/hero_yahya/yahya_digtoplaesning", LUA_MODIFIER_MOTION_NONE)
yahya_digtoplaesning = yahya_digtoplaesning or class({})


function yahya_digtoplaesning:OnSpellStart()
    
	if IsServer() then  
        local caster = self:GetCaster()
		EmitSoundOn("digt", caster)
        caster:AddNewModifier(caster, self, "modifier_yahya_digtoplaesning", {duration = self:GetSpecialValueFor("duration")})
	end
end

function yahya_digtoplaesning:GetCastRange()
	if self:GetCaster():FindAbilityByName("special_bonus_yahya_6"):GetLevel() > 0 then return self:GetSpecialValueFor("radius") + self:GetCaster():FindAbilityByName("special_bonus_yahya_6"):GetSpecialValueFor("value") end
    return self:GetSpecialValueFor("radius")
end

modifier_yahya_digtoplaesning = modifier_yahya_digtoplaesning or class({})

function modifier_yahya_digtoplaesning:IsBuff() return true end
function modifier_yahya_digtoplaesning:IsPurgable() return false end

function modifier_yahya_digtoplaesning:GetEffectAttachType()
    return "PATTACH_ABSORIGIN_FOLLOW"
end
function modifier_yahya_digtoplaesning:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end


function modifier_yahya_digtoplaesning:OnCreated()
    if not IsServer() then return end
    self.modlist = {}
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.radius = ability:GetSpecialValueFor("radius")
    if self:GetCaster():FindAbilityByName("special_bonus_yahya_6"):GetLevel() > 0 then
        self.radius = self.radius + self:GetCaster():FindAbilityByName("special_bonus_yahya_6"):GetSpecialValueFor("value")
    end
    local tick_rate = ability:GetSpecialValueFor("tick_rate")

    self:StartIntervalThink(tick_rate)
end

function modifier_yahya_digtoplaesning:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local stun_dur_multi = ability:GetSpecialValueFor("stun_per_interval_ratio")
    for _, mod in pairs(self.modlist) do
        if caster:HasTalent("special_bonus_yahya_3") then 
            local damage = caster:FindAbilityByName("special_bonus_yahya_3"):GetSpecialValueFor("value")
            ApplyDamage({victim = mod:GetParent(), attacker = caster, damage_type = ability:GetAbilityDamageType(), damage = damage * mod:GetStackCount(), ability = ability})
        end

		
        mod:GetParent():AddNewModifier(caster, ability, "modifier_stunned", {duration = mod:GetStackCount() * stun_dur_multi / 10})
        EmitSoundOn("yahya_applause", mod:GetParent())
        mod:GetParent():RemoveModifierByNameAndCaster("modifier_yahya_digtoplaesning_debuff", caster)
        
	end
end

function modifier_yahya_digtoplaesning:OnIntervalThink()
	if not IsServer() then return end


	local caster = self:GetCaster()
	local ability = self:GetAbility()


	local units = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, ability:GetAbilityTargetTeam(), 
	ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

    
	for _, enemy in pairs(units) do
		--ApplyDamage({victim = enemy, attacker = caster, damage_type = ability:GetAbilityDamageType(), damage = self.damage_tick, ability = ability})
        local mod = enemy:FindModifierByNameAndCaster("modifier_yahya_digtoplaesning_debuff",caster)
        if mod ~= nil then
            mod:SetStackCount(mod:GetStackCount()+1)
        else
            enemy:AddNewModifier(caster, ability, "modifier_yahya_digtoplaesning_debuff", {duration = ability:GetSpecialValueFor("duration") +0.1})
            mod = enemy:FindModifierByNameAndCaster("modifier_yahya_digtoplaesning_debuff",caster)
            mod:SetStackCount(1)
            table.insert(self.modlist, mod)
        end

        
	end

end

modifier_yahya_digtoplaesning_debuff = modifier_yahya_digtoplaesning_debuff or class({})

function modifier_yahya_digtoplaesning_debuff:IsDebuff() return true end
function modifier_yahya_digtoplaesning_debuff:IsPurgable() return true end

function modifier_yahya_digtoplaesning_debuff:GetEffectAttachType()
    return "PATTACH_ABSORIGIN_FOLLOW"
end
function modifier_yahya_digtoplaesning_debuff:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_beam.vpcf"
end
