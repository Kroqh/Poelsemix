LinkLuaModifier("modifier_lars_blame_taunt", "heroes/hero_lars/lars_blame", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lars_blame_target", "heroes/hero_lars/lars_blame", LUA_MODIFIER_MOTION_NONE)
lars_blame = lars_blame or class({})

function lars_blame:GetCastRange()
    return self:GetSpecialValueFor("cast_range")
end

function lars_blame:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	caster:EmitSound("LarsUlt")

    AllUnits = FindUnitsInRadius(self.target:GetTeamNumber(),
    self.target:GetAbsOrigin(),
    nil,
    FIND_UNITS_EVERYWHERE,
    self:GetAbilityTargetTeam(),
    self:GetAbilityTargetType(),
    self:GetAbilityTargetFlags(),
    FIND_ANY_ORDER,
    false)

    local duration = self:GetSpecialValueFor("duration")

    self.target:AddNewModifier(caster, self, "modifier_lars_blame_target", {duration = duration})
    for _,unit in pairs(AllUnits) do
        if unit:GetTeam() ~= caster:GetTeam() or unit:HasModifier("modifier_lars_team_swap") then
            unit:AddNewModifier(caster, self, "modifier_lars_blame_taunt", {duration = duration})
        end
    end

end
function lars_blame:OnProjectileHit(target)
	if not target then
		return nil 
	end
    target:EmitSound("lars_dirt_hit")
	local caster = self:GetCaster()
    local dirt_damage = self:GetSpecialValueFor("scepter_dirt_damage")
    ApplyDamage({attacker = caster, victim = target, ability = self, damage = dirt_damage , damage_type = DAMAGE_TYPE_MAGICAL})
    
end

modifier_lars_blame_target = modifier_lars_blame_target or class({})


function modifier_lars_blame_target:IsHidden() return false end
function modifier_lars_blame_target:IsPurgable() return false end
function modifier_lars_blame_target:IsDebuff() return true end


function modifier_lars_blame_target:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
	}
end

function modifier_lars_blame_target:GetModifierMoveSpeedBonus_Percentage() return -self:GetAbility():GetSpecialValueFor("target_slow") end

function modifier_lars_blame_target:GetEffectName()
    return "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_marker.vpcf"
end
function modifier_lars_blame_target:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
modifier_lars_blame_taunt = modifier_lars_blame_taunt or class({})


function modifier_lars_blame_taunt:IsHidden() return false end
function modifier_lars_blame_taunt:IsPurgable() return true end
function modifier_lars_blame_taunt:IsDebuff() return true end



function modifier_lars_blame_taunt:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():MoveToTargetToAttack(self:GetAbility().target)
    self.proj_timer = 9999 --makes it so that you cant get the effect by buying scepter while active
    if self:GetCaster():HasScepter() then self.proj_timer = 1 end
    self.proj_counter = 0.9
    self:StartIntervalThink(0.1) 
	
end
function modifier_lars_blame_taunt:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():MoveToTargetToAttack(self:GetAbility().target)
    if not self:GetAbility().target:IsAlive() then self:GetParent():RemoveModifierByName("modifier_lars_blame_taunt") end

    self.proj_counter = self.proj_counter + 0.1
    if self.proj_counter >= self.proj_timer then
        local dirt = 
			{
				Target = self:GetAbility().target,
				Source = self:GetParent(),
				Ability = self:GetAbility(),
				EffectName = "particles/econ/events/ti9/ti9_monkey_projectile.vpcf",
				iMoveSpeed = 800,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				ExtraData = {}
			}
		ProjectileManager:CreateTrackingProjectile(dirt)
        self.proj_counter = 0
    end

end




function modifier_lars_blame_taunt:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
	}
end

function modifier_lars_blame_taunt:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end
function modifier_lars_blame_taunt:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_lars_blame_taunt:GetStatusEffectName() return "particles/status_fx/status_effect_beserkers_call.vpcf" end
function modifier_lars_blame_taunt:StatusEffectPriority() return 5 end

function modifier_lars_blame_taunt:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("taunt_speed") end