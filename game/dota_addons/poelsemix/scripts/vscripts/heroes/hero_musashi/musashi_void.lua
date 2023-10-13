LinkLuaModifier("modifier_musashi_void","heroes/hero_musashi/musashi_void.lua",LUA_MODIFIER_MOTION_NONE)

musashi_void = musashi_void or class({})

function musashi_void:OnSpellStart()
	if not IsServer() then return end

    local caster = self:GetCaster()
    caster:EmitSound("musashi_void_start")
    local duration = self:GetSpecialValueFor("charge_duration")

    self.invisible = 0
    if self:GetCaster():FindAbilityByName("special_bonus_musashi_8"):GetLevel() > 0 then
        self.invisible = 1
    end
    caster:AddNewModifier(caster, self, "modifier_musashi_void", {duration = duration})
end

function musashi_void:OnProjectileHit_ExtraData(target, location, ExtraData)
	if target then
		ApplyDamage({attacker = self:GetCaster(), victim = target, ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
	end
end

modifier_musashi_void = modifier_musashi_void or class({})

function modifier_musashi_void:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("charge_duration") - 0.1)
end

function modifier_musashi_void:OnIntervalThink()
	if IsServer() then

        local caster = self:GetCaster()
	    local ability = self:GetAbility()
        local caster_loc = caster:GetAbsOrigin()

		-- Parameters
		local damage = ability:GetSpecialValueFor("damage")
		local start_radius = ability:GetSpecialValueFor("start_radius")
		local end_radius = 200 --ability:GetSpecialValueFor("end_radius")
		local travel_distance =  400--ability:GetSpecialValueFor("travel_distance")
		local projectile_speed = 1800 --ability:GetSpecialValueFor("projectile_speed")
		local direction = caster:GetForwardVector()

        local projectile =
			{
				Ability				= ability,
				EffectName			= "particles/units/heroes/hero_musashi/musashi_void_slash.vpcf",
				vSpawnOrigin		= caster_loc,
				fDistance			= travel_distance,
				fStartRadius		= start_radius,
				fEndRadius			= end_radius,
				Source				= caster,
				bHasFrontalCone		= true,
				bReplaceExisting	= false,
				iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
				iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
				iUnitTargetType		= ability:GetAbilityTargetType(),
				bDeleteOnHit		= false,
				vVelocity			= Vector(direction.x,direction.y,0) * projectile_speed,
				bProvidesVision		= false,
                ExtraData			= {damage = damage}
			}

        ProjectileManager:CreateLinearProjectile(projectile)
        EmitSoundOnLocationWithCaster(caster_loc, "musashi_void_slash", caster) --has to be on location or wont work for enemies while invisible
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)

	end
end

function modifier_musashi_void:StatusEffectPriority()
	return 99
end
function modifier_musashi_void:GetStatusEffectName()
	return "particles/status_fx/status_effect_void_spirit_astral_step_debuff.vpcf"
end
function modifier_musashi_void:GetEffectName()
	return "particles/units/heroes/hero_void_spirit/void_spirit_inactive_aether_remnant_b.vpcf"
end

function modifier_musashi_void:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_musashi_void:IsDebuff() 
	return false
end

function modifier_musashi_void:IsPurgable()
	return false
end
function modifier_musashi_void:IsHidden()
	return false
end

function modifier_musashi_void:DeclareFunctions()
	local declfuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_INVISIBILITY_LEVEL}

	return declfuncs
end

function modifier_musashi_void:GetOverrideAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_6
end


function modifier_musashi_void:CheckState() --otherwise dash is cancelable, dont want that - needs no unit collision to not get caught at the end of dash
	if IsServer() then
		local state = {	[MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVISIBLE] = self:GetAbility().invisible == 1,
		[MODIFIER_STATE_NO_UNIT_COLLISION]  = true}
		return state
	end
end
function modifier_musashi_void:GetModifierInvisibilityLevel()
	return self:GetAbility().invisible
end