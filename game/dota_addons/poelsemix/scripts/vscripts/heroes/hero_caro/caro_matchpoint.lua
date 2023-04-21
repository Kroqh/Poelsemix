caro_matchpoint= caro_matchpoint or class({})

function caro_matchpoint:GetCastRange()
    self:GetSpecialValueFor("range")
end
function caro_matchpoint:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:EmitSound("carogrunt")

end

function caro_matchpoint:OnChannelFinish(interrupt)
	if not IsServer() then return end
    if interrupt then return end
    local caster = self:GetCaster()
	
    target_point = caster:GetCursorPosition()
    ProjectileManager:CreateLinearProjectile( self:GetProjectile(target_point))
    
    if caster:HasScepter() then
        local left_angle = QAngle(0, 10, 0)
    local right_angle = QAngle(0, -10, 0)
    local left_pos = RotatePosition(caster:GetAbsOrigin(), left_angle,  target_point)

	local right_pos = RotatePosition(caster:GetAbsOrigin(), right_angle, target_point)

    
	ProjectileManager:CreateLinearProjectile( self:GetProjectile(left_pos))
    ProjectileManager:CreateLinearProjectile( self:GetProjectile(right_pos))
    end
end


function caro_matchpoint:GetProjectile(target_point)
    local caster = self:GetCaster()
    local projectileName = "particles/heroes/caroline/matchpoint.vpcf"
    local projectileTable =
	{
		EffectName = projectileName,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = (((target_point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * self:GetSpecialValueFor("arrow_speed"),
		fDistance = self:GetSpecialValueFor("range"),
		fStartRadius = self:GetSpecialValueFor("arrow_width"),
		fEndRadius = self:GetSpecialValueFor("arrow_width"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = self:GetAbilityTargetTeam(),
		iUnitTargetFlags = self:GetAbilityTargetFlags(),
		iUnitTargetType = self:GetAbilityTargetType(),
		iVisionRadius = 650, --flickers with lower value
		iVisionTeamNumber = caster:GetTeamNumber(),
        bProvidesVision = true
	}
    return projectileTable
end

function caro_matchpoint:OnProjectileHit(target)
    if not IsServer() then return end
    if not target then return false end
    local caster = self:GetCaster()
    target:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun_duration") } )
    local damage = self:GetSpecialValueFor("damage")
    if caster:HasTalent("special_bonus_caro_8") then damage = damage + caster:FindAbilityByName("special_bonus_caro_8"):GetSpecialValueFor("value") end

    local damageTable = {
        victim			= target,
        damage			= damage,
        damage_type		= self:GetAbilityDamageType(),
        attacker		    = caster,
        ability			= self

      }
      ApplyDamage(damageTable)
      if caster:HasTalent("special_bonus_caro_7") then return false end
      return true
end