LinkLuaModifier("modifier_slapper_rammusteinu", "heroes/hero_slapper/slapper_rammusteinu", LUA_MODIFIER_MOTION_NONE)
slapper_rammusteinu = slapper_rammusteinu or class({})


function slapper_rammusteinu:OnAbilityPhaseStart() 
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
    self:GetCaster():EmitSound("slapper_rammusteinu")
	return true
end

function slapper_rammusteinu:OnSpellStart() 
	if not IsServer() then return end
	local caster = self:GetCaster();
    local duration = self:GetSpecialValueFor("duration");

    caster:AddNewModifier(caster, self, "modifier_slapper_rammusteinu", {duration = duration});
end


modifier_slapper_rammusteinu = modifier_slapper_rammusteinu or class({})

function modifier_slapper_rammusteinu:IsPurgable() return true end
function modifier_slapper_rammusteinu:IsHidden() return false end

function modifier_slapper_rammusteinu:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()

    parent:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    pfx = "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_3_e.vpcf"
    self.pfx_fire1 = ParticleManager:CreateParticle(pfx, PATTACH_POINT_FOLLOW, parent)
    --ParticleManager:SetParticleControlEnt(self.pfx_fire1, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), false)

end

function modifier_slapper_rammusteinu:OnRemoved()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.pfx_fire1, false)
    --ParticleManager:ReleaseParticleIndex(self.pfx_fire1)
    
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function modifier_slapper_rammusteinu:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_PROJECTILE_SPEED
	}
end

function modifier_slapper_rammusteinu:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_range")
end
function modifier_slapper_rammusteinu:GetModifierProjectileSpeed()
    return 700
end
function modifier_slapper_rammusteinu:GetModifierProjectileName()
	return "particles/heroes/slapper/rammusteinu_attack.vpcf"
end

function modifier_slapper_rammusteinu:OnAttackLanded(params)
	if (params.attacker ~= self:GetParent()) then return end 
    if not IsServer() then return end
    caster = self:GetCaster()

    local damage = self:GetAbility():GetSpecialValueFor("int_magic_damage_ratio") * caster:GetIntellect()

		ApplyDamage({victim = params.target,
		attacker = caster,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage = damage,
		ability = self:GetAbility()
		})

end

function modifier_slapper_rammusteinu:GetModifierModelChange()
	return "models/slapper/slapper_rammusteinu.vmdl"
end

function modifier_slapper_rammusteinu:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_slapper_rammusteinu:GetEffectName()
    return "particles/units/heroes/hero_slapper/rammusteinu_burst.vpcf"
end