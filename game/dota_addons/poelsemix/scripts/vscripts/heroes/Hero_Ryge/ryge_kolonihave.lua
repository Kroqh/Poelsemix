LinkLuaModifier("modifier_ryge_kolonihave_thinker", "heroes/hero_ryge/ryge_kolonihave", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ryge_kolonihave_buff", "heroes/hero_ryge/ryge_kolonihave", LUA_MODIFIER_MOTION_NONE)
kolonihave = kolonihave or class({});





function kolonihave:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function kolonihave:OnSpellStart()
	
	CreateModifierThinker(self:GetCaster(), self, "modifier_ryge_kolonihave_thinker", {
		duration = self:GetSpecialValueFor("duration")
	}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end

modifier_ryge_kolonihave_thinker = modifier_ryge_kolonihave_thinker or class({});

function modifier_ryge_kolonihave_thinker:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.radius	= self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
    self:StartIntervalThink(0)
	
end
function modifier_ryge_kolonihave_thinker:OnIntervalThink()
	if not IsServer() then return end
    ParticleManager:CreateParticle("particles/econ/items/enchantress/enchantress_lodestar/ench_death_lodestar_flower.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent());
    self:StartIntervalThink(0.5)
	
end

function modifier_ryge_kolonihave_thinker:IsAura()						return true end
function modifier_ryge_kolonihave_thinker:IsAuraActiveOnDeath() 		return true end

function modifier_ryge_kolonihave_thinker:GetAuraDuration()				return 0.1 end
function modifier_ryge_kolonihave_thinker:GetAuraRadius()				return self.radius end
function modifier_ryge_kolonihave_thinker:GetAuraSearchFlags()			return self:GetAbility():GetAbilityTargetFlags() end
function modifier_ryge_kolonihave_thinker:GetAuraSearchTeam()			return self:GetAbility():GetAbilityTargetTeam() end
function modifier_ryge_kolonihave_thinker:GetAuraSearchType()			return self:GetAbility():GetAbilityTargetType() end
function modifier_ryge_kolonihave_thinker:GetModifierAura()				return "modifier_ryge_kolonihave_buff" end


modifier_ryge_kolonihave_buff = modifier_ryge_kolonihave_buff or class({});

function modifier_ryge_kolonihave_buff:IsHidden() return false end
function modifier_ryge_kolonihave_buff:IsDebuff() return false end

function modifier_ryge_kolonihave_buff:OnCreated()
	if self:GetAbility() then
        
		self.ms_bonus	= self:GetAbility():GetSpecialValueFor("movement_speed")
        self.as_bonus	= self:GetAbility():GetSpecialValueFor("attack_speed")
	else
		self:Destroy()
	end
    if not IsServer() then return end
    self:StartIntervalThink(0)
	
end
function modifier_ryge_kolonihave_buff:OnIntervalThink()
	if not IsServer() then return end
    ParticleManager:CreateParticle("particles/econ/items/enchantress/enchantress_lodestar/ench_death_lodestar_flower.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent());
    self:StartIntervalThink(0.5)
	
end
function modifier_ryge_kolonihave_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_ryge_kolonihave_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end

function modifier_ryge_kolonihave_buff:GetModifierMoveSpeedBonus_Constant()
	return self.ms_bonus
end