LinkLuaModifier("modifier_gametecher_anime_power", "heroes/hero_gametecher/gametecher_anime_power", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gametecher_anime_power_cast", "heroes/hero_gametecher/gametecher_anime_power", LUA_MODIFIER_MOTION_NONE)
gametecher_anime_power = gametecher_anime_power or class({})


function gametecher_anime_power:GetCastRange()
    return self:GetSpecialValueFor("radius")
end

function gametecher_anime_power:OnAbilityPhaseStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
    caster:EmitSound("omae_wa_mou")
    caster:AddNewModifier(caster, self, "modifier_gametecher_anime_power_cast", {duration = self:GetCastPoint()})
    print(self:GetSpecialValueFor("total_duration"))

end

function gametecher_anime_power:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_6)
    caster:AddNewModifier(caster, self, "modifier_gametecher_anime_power", {duration = self:GetSpecialValueFor("total_duration")})
    for i, unit in pairs(self:GetTargets(self:GetSpecialValueFor("radius"))) do
        unit:EmitSound("nani")
    end
end

function gametecher_anime_power:GetTargets(radius)
    local targets = {}
	local caster = self:GetCaster()
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags() , FIND_ANY_ORDER, false)
	return targets
end


function gametecher_anime_power:DoBlast(radius, base_damage, int_scaling, speed)
    local caster = self:GetCaster()
    local targets = self:GetTargets(radius)
    for i, unit in pairs(targets) do
        local blast = 
			{
				Target = unit,
				Source = caster,
				Ability = self,
				EffectName = "particles/units/heroes/gametecher/ki_blast.vpcf",
				iMoveSpeed = speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData = {base_damage = base_damage, int_scaling = int_scaling}
			}
		ProjectileManager:CreateTrackingProjectile(blast)
    end
    if #targets >= 1 then self:GetCaster():EmitSound("ki_blast") end
end



function gametecher_anime_power:OnProjectileHit_ExtraData(target, location, extra)
	if not target then
		return nil 
	end
	local caster = self:GetCaster()
	local int = caster:GetIntellect()
	local damage = extra.base_damage + (int * extra.int_scaling)
	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})
end


modifier_gametecher_anime_power_cast = modifier_gametecher_anime_power_cast or class({})

function modifier_gametecher_anime_power_cast:IsHidden() return false end
function modifier_gametecher_anime_power_cast:IsPurgable() return false end

function modifier_gametecher_anime_power_cast:CheckState()
	local state = {
        [MODIFIER_STATE_FLYING] = true
    }
	return state
end


modifier_gametecher_anime_power = modifier_gametecher_anime_power or class({})

function modifier_gametecher_anime_power:IsHidden() return false end
function modifier_gametecher_anime_power:IsPurgable() return false end


function modifier_gametecher_anime_power:OnCreated()
	if not IsServer() then return end
    local parent = self:GetParent()
    parent:EmitSound("Hero_FacelessVoid.Chronosphere")

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.blast_damage = self:GetAbility():GetSpecialValueFor("blast_damage")
    self.blast_int_scaling = self:GetAbility():GetSpecialValueFor("blast_int_damage_scaling")

    if self:GetCaster():FindAbilityByName("special_bonus_gametecher_6"):GetLevel() > 0 then self.blast_int_scaling = self.blast_int_scaling + self:GetCaster():FindAbilityByName("special_bonus_gametecher_6"):GetSpecialValueFor("value") end 

    self.proj_speed = self:GetAbility():GetSpecialValueFor("projectile_speed")
    
    self.dmg_reducion = self:GetAbility():GetSpecialValueFor("reduction_while_casting")

    self.delay = self:GetAbility():GetSpecialValueFor("delay")
    self.burst_dur = self:GetAbility():GetSpecialValueFor("burst_fire_duration")

    self.normal_fire_rate = self:GetAbility():GetSpecialValueFor("normal_fire_rate")
    self.burst_fire_rate = self:GetAbility():GetSpecialValueFor("burst_fire_rate")

    self.zone = ParticleManager:CreateParticle( "particles/units/heroes/hero_gametecher/anime_zone.vpcf", PATTACH_ABSORIGIN, parent)
    ParticleManager:SetParticleControl(self.zone, 1 , Vector(self.radius,self.radius,0))
    self.time_since_last_blast = 0
    self.last_interval = 0
    self.voice_started = false
    self:StartIntervalThink(FrameTime())
end

function modifier_gametecher_anime_power:OnIntervalThink()
    if not IsServer() then return end
    self.time_since_last_blast = self.time_since_last_blast + (self:GetElapsedTime() - self.last_interval)
    self.last_interval = self:GetElapsedTime()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if self:GetElapsedTime() >= self.delay + self.burst_dur then --normal fire
        if self.time_since_last_blast >= self.normal_fire_rate then
            ability:DoBlast(self.radius, self.blast_damage, self.blast_int_scaling, self.proj_speed)
            self.time_since_last_blast = self.time_since_last_blast - self.normal_fire_rate
        end
    elseif self:GetElapsedTime() >= self.burst_dur then
        if self.voice_started == false then
            parent:EmitSound("further_beyond")
            self.voice_started =true
        end
        self.time_since_last_blast = 0
    else --burst fire
        if self.time_since_last_blast >= self.burst_fire_rate then
            ability:DoBlast(self.radius, self.blast_damage, self.blast_int_scaling, self.proj_speed)
            self.time_since_last_blast = self.time_since_last_blast - self.burst_fire_rate
        end
    end
    

    self:StartIntervalThink(FrameTime())
end


function modifier_gametecher_anime_power:OnRemoved()
	if not IsServer() then return end
    ParticleManager:DestroyParticle(self.zone, false)
    self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_6)
    self:GetParent():StopSound("further_beyond")
end

function modifier_gametecher_anime_power:GetModifierIncomingDamage_Percentage( params )
    if params.target == self:GetParent() then  
       return -self.dmg_reducion
    end
    return
end

function modifier_gametecher_anime_power:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true
    }
	return state
end

function modifier_gametecher_anime_power:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_gametecher_anime_power:GetEffectName()
    return "particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf"
end