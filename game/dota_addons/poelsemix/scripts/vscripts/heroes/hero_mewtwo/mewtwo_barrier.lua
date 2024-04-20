LinkLuaModifier("modifier_mewtwo_barrier_thinker", "heroes/hero_mewtwo/mewtwo_barrier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mewtwo_barrier_buff", "heroes/hero_mewtwo/mewtwo_barrier", LUA_MODIFIER_MOTION_NONE)
mewtwo_barrier = mewtwo_barrier or class({});





function mewtwo_barrier:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function mewtwo_barrier:OnSpellStart()
	
	CreateModifierThinker(self:GetCaster(), self, "modifier_mewtwo_barrier_thinker", {
		duration = self:GetSpecialValueFor("duration")
	}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end

modifier_mewtwo_barrier_thinker = modifier_mewtwo_barrier_thinker or class({});

function modifier_mewtwo_barrier_thinker:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.radius	= self:GetAbility():GetSpecialValueFor("radius")
	if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_6"):GetLevel() > 0 then self.radius = self.radius + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_6"):GetSpecialValueFor("value") end
	
	
	if not IsServer() then return end
	self:GetParent():EmitSound("mewtwo_barrier")
	
	self.magnetic_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mewtwo/mewtwo_barrier.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.magnetic_particle, 1, Vector(self.radius, 1, 1))
	self:AddParticle(self.magnetic_particle, false, false, 1, false, false)
end

function modifier_mewtwo_barrier_thinker:OnDestroy()
	if not IsServer() then return end
    self:GetParent():StopSound("mewtwo_barrier")
end

function modifier_mewtwo_barrier_thinker:IsAura()						return true end
function modifier_mewtwo_barrier_thinker:IsAuraActiveOnDeath() 		return true end

function modifier_mewtwo_barrier_thinker:GetAuraDuration()				return 0.1 end
function modifier_mewtwo_barrier_thinker:GetAuraRadius()				return self.radius end
function modifier_mewtwo_barrier_thinker:GetAuraSearchFlags()			return self:GetAbility():GetAbilityTargetFlags() end
function modifier_mewtwo_barrier_thinker:GetAuraSearchTeam()			return self:GetAbility():GetAbilityTargetTeam() end
function modifier_mewtwo_barrier_thinker:GetAuraSearchType()			return self:GetAbility():GetAbilityTargetType() end
function modifier_mewtwo_barrier_thinker:GetModifierAura()				return "modifier_mewtwo_barrier_buff" end

modifier_mewtwo_barrier_buff = modifier_mewtwo_barrier_buff or class({});

function modifier_mewtwo_barrier_buff:IsHidden() return false end
function modifier_mewtwo_barrier_buff:IsDebuff() return false end

function modifier_mewtwo_barrier_buff:OnCreated()
	if self:GetAbility() then
        
		self.armor_bonus	= self:GetAbility():GetSpecialValueFor("armor")
        self.magic_bonus	= self:GetAbility():GetSpecialValueFor("magic_resist")
		if self:GetCaster():FindAbilityByName("special_bonus_mewtwo_4"):GetLevel() > 0 then self.magic_bonus = self.magic_bonus + self:GetCaster():FindAbilityByName("special_bonus_mewtwo_4"):GetSpecialValueFor("value") end
	else
		self:Destroy()
	end
end

function modifier_mewtwo_barrier_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_mewtwo_barrier_buff:GetModifierPhysicalArmorBonus()
	return self.armor_bonus
end

function modifier_mewtwo_barrier_buff:GetModifierMagicalResistanceBonus()
	return self.magic_bonus
end
