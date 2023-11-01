LinkLuaModifier("modifier_ryge_skyd_en_due", "heroes/hero_ryge/ryge_skyd_en_due", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ryge_skyd_en_due_target", "heroes/hero_ryge/ryge_skyd_en_due", LUA_MODIFIER_MOTION_NONE)


ryge_skyd_en_due = ryge_skyd_en_due or class({})


function ryge_skyd_en_due:GetCastRange()
	local scaling = self:GetSpecialValueFor("range_agi_scaling")
	if self:GetCaster():FindAbilityByName("special_bonus_ryge_8"):GetLevel() > 0 then scaling = scaling + self:GetCaster():FindAbilityByName("special_bonus_ryge_8"):GetSpecialValueFor("value") end
	return self:GetSpecialValueFor("base_range") + (scaling * self:GetCaster():GetAgility())
end

function ryge_skyd_en_due:OnSpellStart()
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	if not IsServer() then return end
	self.target:EmitSound("SorenUltStart")
	self.ricochets = 0
	
	caster:AddNewModifier(caster, self, "modifier_ryge_skyd_en_due", {duration = self:GetSpecialValueFor("channel_time")})
	self.target:AddNewModifier(caster, self, "modifier_ryge_skyd_en_due_target", {duration = self:GetSpecialValueFor("channel_time")})
end

function ryge_skyd_en_due:OnProjectileHit(target)
	if not target then
		return nil 
	end

	local caster = self:GetCaster()

	local scaling = self:GetSpecialValueFor("damage_agi_scaling")
	if caster:FindAbilityByName("special_bonus_ryge_7"):GetLevel() > 0 then scaling = scaling + caster:FindAbilityByName("special_bonus_ryge_7"):GetSpecialValueFor("value") end

	local damage = self:GetSpecialValueFor("base_damage") + (scaling * caster:GetAgility())
	target:EmitSound("SorenUltHit")
	ApplyDamage({victim = target,
	attacker = caster,
	damage_type = self:GetAbilityDamageType(),
	damage = damage,
	ability = self})

	if caster:HasScepter() and self.ricochets < self:GetSpecialValueFor("scepter_ricochets") then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("scepter_range"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		local new_target = units[1]
		if new_target == target then new_target = units[2] end
		if new_target ~= nil then 
			local proj = 
		{
			Target = new_target,
			Source = target,
			Ability = self,
			EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
			iMoveSpeed =  self:GetSpecialValueFor("projectile_speed"),
			bDodgeable = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			bProvidesVision = false,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			ExtraData = {}
		}
		ProjectileManager:CreateTrackingProjectile(proj)
		self.ricochets = self.ricochets + 1
		end
	end

end

modifier_ryge_skyd_en_due = modifier_ryge_skyd_en_due or class({})


function modifier_ryge_skyd_en_due:IsHidden() return false end
function modifier_ryge_skyd_en_due:IsPurgable() return false end
function modifier_ryge_skyd_en_due:OnCreated()
	if not IsServer() then return end
    self.target = self:GetAbility():GetCursorTarget()

end
function modifier_ryge_skyd_en_due:OnRemoved(death)
	
	
	if not IsServer() then return end
	self.target:RemoveModifierByName("modifier_ryge_skyd_en_due_target")
	if death then return end
	self:GetParent():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

	local proj = 
	{
		Target = self.target,
		Source = self:GetParent(),
		Ability = self:GetAbility(),
		EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
		iMoveSpeed =  self:GetAbility():GetSpecialValueFor("projectile_speed") ,
		bDodgeable = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		bProvidesVision = false,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		ExtraData = {}
	}
	ProjectileManager:CreateTrackingProjectile(proj)
end

function modifier_ryge_skyd_en_due:CheckState()
	local state = {[MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_DISARMED] = true}
	return state
end

function modifier_ryge_skyd_en_due:GetEffectName()
	return "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon/wd_ti10_immortal_ambient_crimson_birds.vpcf"
end

modifier_ryge_skyd_en_due_target = modifier_ryge_skyd_en_due_target or class({})

function modifier_ryge_skyd_en_due_target:IsHidden() return true end
function modifier_ryge_skyd_en_due_target:IsPurgable() return false end

function modifier_ryge_skyd_en_due_target:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_ryge_skyd_en_due_target:GetEffectName()
	return "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_crosshair_bullseye.vpcf"
end


function modifier_ryge_skyd_en_due_target:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
end
function modifier_ryge_skyd_en_due_target:GetModifierProvidesFOWVision() 
	return 1
end