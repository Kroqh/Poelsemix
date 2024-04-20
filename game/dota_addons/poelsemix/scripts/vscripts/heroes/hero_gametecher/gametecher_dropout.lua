LinkLuaModifier("modifier_gametecher_dropout_stacks", "heroes/hero_gametecher/gametecher_dropout", LUA_MODIFIER_MOTION_NONE)
gametecher_dropout = gametecher_dropout or class({})


function gametecher_dropout:GetChannelTime()
    return self:GetSpecialValueFor("channel_time")
end

function gametecher_dropout:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_CHANNEL_ABILITY_2)
end

function gametecher_dropout:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:EmitSound("dropout")
    self.caster_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff_drips_b.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(self.caster_particle, 0, caster, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", caster:GetAbsOrigin(), true)

end

function gametecher_dropout:OnChannelFinish(interrupt)
	if not IsServer() then return end
    self:GetCaster():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_2)
    if interrupt then return end

    local caster = self:GetCaster()

    local xp = self:GetSpecialValueFor("xp_gain") * caster:GetLevel()
    local min_xp = self:GetSpecialValueFor("xp_gain_minimum")
    if xp < min_xp then xp = min_xp end

    caster:AddExperience(xp,0,false,false)
    if caster:HasModifier("modifier_gametecher_dropout_stacks") then 
        local mod = caster:FindModifierByName("modifier_gametecher_dropout_stacks")
        mod:SetStackCount(mod:GetStackCount()+1) 
    else
        caster:AddNewModifier(caster, self, "modifier_gametecher_dropout_stacks", {})
    end
    
    local fizzle_fx = ParticleManager:CreateParticle( "particles/econ/items/techies/techies_arcana/techies_suicide_dud_arcana.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(fizzle_fx)
    local death_fx = ParticleManager:CreateParticle( "particles/econ/courier/courier_drodo/courier_drodo_ambient_death.vpcf", PATTACH_CENTER_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(death_fx)
    caster:EmitSound("Hero_Techies.Suicide")

    if not caster:HasScepter() then
        caster:Kill(self, caster)
    end
end



modifier_gametecher_dropout_stacks = modifier_gametecher_dropout_stacks or class({})

function modifier_gametecher_dropout_stacks:IsHidden() return false end
function modifier_gametecher_dropout_stacks:IsPurgable() return false end
function modifier_gametecher_dropout_stacks:IsDebuff() return self:GetCaster():FindAbilityByName("special_bonus_gametecher_8"):GetLevel() == 0 end
function modifier_gametecher_dropout_stacks:RemoveOnDeath() return false end


function modifier_gametecher_dropout_stacks:OnCreated()
	if not IsServer() then return end
    self:SetStackCount(1)   

end

function modifier_gametecher_dropout_stacks:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}

	return funcs
end

function modifier_gametecher_dropout_stacks:GetModifierBonusStats_Intellect()
    local int = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("penalty_intellect")
    if self:GetCaster():FindAbilityByName("special_bonus_gametecher_8"):GetLevel() > 0 then int = -int end
	return int
end